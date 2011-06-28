function [ sweeps, shudders ] = smoothAndDisect( track )
% Chop up a sojourn in to "sweeps" and "shudders". Run a Kalman smoother
% over the sweeps.

v_thresh = 0.5;

sweeps = repmat(struct('state', [], 'variance', [], 't', [], 'v', []),0,1);
shudders = repmat(struct('x', [], 'y', [], 't', [], 'v', []),0,1);

x_sh = zeros(track.N, 1);
y_sh = zeros(track.N, 1);
t_sh = zeros(track.N, 1);
v_sh = zeros(track.N, 1);
ii_start = 1;

% Loop through measurement points
ii = 2;
while ii <= track.N
    
    v_sh(ii-ii_start) = sqrt( (track.x(ii)-track.x(ii-1))^2 + (track.y(ii)-track.y(ii-1))^2 ) / (track.t(ii) - track.t(ii-1));
    if (v_sh(ii-ii_start) > v_thresh) || ii==track.N
        
        % End shudder
        x_sh(ii-ii_start:end) = [];
        y_sh(ii-ii_start:end) = [];
        t_sh(ii-ii_start:end) = [];
        v_sh(ii-ii_start:end) = [];
                
        shudders = [shudders; struct('x', x_sh, 'y', y_sh, 't', t_sh, 'v', v_sh)];
        
        if ii < track.N
            
            % Run sweep smoother on remaining points
            [sw, ii] = smoothSweep(track, ii-1);
            sweeps = [sweeps; sw];
        
        end
        
        ii = ii + 1;
        
        % Start a new shudder
        N_rem = track.N - ii + 1;
        ii_start = ii - 1;
        x_sh = zeros(N_rem, 1);
        y_sh = zeros(N_rem, 1);
        t_sh = zeros(N_rem, 1);
        v_sh = zeros(N_rem, 1);

    else
        
        % Add point to shudder
        x_sh(ii-ii_start) = track.x(ii);
        y_sh(ii-ii_start) = track.y(ii);
        t_sh(ii-ii_start) = track.t(ii);
        
        ii = ii + 1;
        
    end
    
end


end

function [sweep, stop] = smoothSweep(track, start)

ProcNoiseVar = 1E-4;
ObsNoiseVar = 1/12;
KF_init_var = 1E-10;
v_thresh = 0.25;

% Initialise arrays
N = track.t(end) - track.t(start) + 1;
t = track.t(start):track.t(end);
state = cell(size(t));
variance = cell(size(t));
p_state = cell(size(t));
p_variance = cell(size(t));

% Initialise KF
P = track.t(start+1) - track.t(start);
state{1} = [track.x(start); track.y(start); 0; 0];
state{1}(3:4) = [(track.x(start+1)-track.x(start))/P; (track.y(start+1)-track.y(start))/P];
variance{1} = KF_init_var * eye(4);

for ii = 2:N
    
    P = 1;
    A = [1 0 P 0; 0 1 0 P; 0 0 1 0; 0 0 0 1];
    C = [1 0 0 0; 0 1 0 0];
    Q = ProcNoiseVar * [P^3/3 0 P^2/2 0; 0 P^3/3 0 P^2/2; P^2/2 0 P 0; 0 P^2/2 0 P];
    R = ObsNoiseVar * eye(2);
    
    % Prediction step
    p_state{ii} = A * state{ii-1};
    p_variance{ii} = A * variance{ii-1} * A' + Q;
    
    % Update step
    if any(t(ii)==track.t)
        ind = find(t(ii)==track.t);
        y = [track.x(ind); track.y(ind)] - C * p_state{ii};
        s = C * p_variance{ii} * C' + R;
        gain = p_variance{ii} * C' / s;
        state{ii} = p_state{ii} + gain * y;
        variance{ii} = (eye(4)-gain*C) * p_variance{ii};
    else
        state{ii} = p_state{ii};
        variance{ii} = p_variance{ii};
    end
    
    v = sqrt( sum(state{ii}(3:4).^2) );
    if v < v_thresh
        ii_stop = ii;
        break
    end
    
    ii_stop = ii;
    
end

N = ii_stop;
b_state = cell(N, 1);
b_variance = cell(N, 1);
b_state{N} = state{N}; b_variance{N} = variance{N};
% Smoothing
for ii = ii_stop-1:-1:1
    
    G = variance{ii}*A'/p_variance{ii+1};
    b_state{ii} = state{ii} + G * (b_state{ii+1}-p_state{ii+1});
    b_variance{ii} = variance{ii} + G * (b_variance{ii+1}-p_variance{ii+1}) * G';
    
end

state = b_state;
variance = b_variance;
t(N+1:end) = [];

stop = find(abs(track.t - t(ii_stop))==min(abs(track.t - t(ii_stop))))-1;
ii_stop = find(track.t(stop)==t);
state(ii_stop+1:end) = [];
variance(ii_stop+1:end) = [];
t(ii_stop+1:end) = [];

xdot = cellfun(@(x) x(3), state);
ydot = cellfun(@(x) x(4), state);
v = sqrt(xdot.^2 + ydot.^2);

% sweep = struct('state', state, 'variance', variance, 't', t, 'N', N);
sweep.state = state;
sweep.variance = variance;
sweep.t = t;
sweep.v = v;

end