function [ EstState, EstVar ] = kalmanFilterWithAcc( track )
% Kalman filter a track according to NCVM

ProcNoiseVar = 1E-7;
ObsNoiseVar = 1/12;

t = (min(track.t):max(track.t))';
N = length(t);

PredState = cell(N, 1);
PredVar = cell(N, 1);

EstState = cell(N, 1);
EstVar = cell(N, 1);

% Initialise
P = track.t(2) - track.t(1);
EstState{1} = [track.x(1); track.y(1); 0; 0; 0; 0];
EstState{1}(3:4) = [(track.x(2)-track.x(1))/P; (track.y(2)-track.y(1))/P];
EstVar{1} = 1E-20 * eye(6);

% Loop through sample points
for ii = 2:N
    
%     P = track.t(ii) - track.t(ii-1);
    P = 1;
    A = [1 0 P 0 P^2/2 0 ; 0 1 0 P 0 P^2/2; 0 0 1 0 P 0; 0 0 0 1 0 P; 0 0 0 0 1 0; 0 0 0 0 0 1];
    C = [1 0 0 0 0 0; 0 1 0 0 0 0];
    Q_sub = [P^3/3 0 P^2/2 0; 0 P^3/3 0 P^2/2; P^2/2 0 P 0; 0 P^2/2 0 P];
    Q = ProcNoiseVar * [ [(P^5/20)*eye(2), (P^4/8)*eye(2), (P^3/6)*eye(2)]; [ (P^4/8)*eye(2); (P^3/6)*eye(2) ], Q_sub ];
    R = ObsNoiseVar * eye(2);

    % Prediction step
    PredState{ii} = A * EstState{ii-1};
    PredVar{ii} = A * EstVar{ii-1} * A' + Q;
    
    % Update step
    if any(t(ii)==track.t)
        ind = find(t(ii)==track.t);
        y = [track.x(ind); track.y(ind)] - C * PredState{ii};
        s = C * PredVar{ii} * C' + R;
        gain = PredVar{ii} * C' / s;
        EstState{ii} = PredState{ii} + gain * y;
        EstVar{ii} = (eye(6)-gain*C) * PredVar{ii};
    else
        EstState{ii} = PredState{ii};
        EstVar{ii} = PredVar{ii};
    end

end


BackState = cell(N, 1);
BackVar = cell(N, 1);
BackState{N} = EstState{N}; BackVar{N} = EstVar{N};
% Smoothing
for k = N-1:-1:1
    
    G = EstVar{k}*A'/PredVar{k+1};
    BackState{k} = EstState{k} + G * (BackState{k+1}-PredState{k+1});
    BackVar{k} = EstVar{k} + G * (BackVar{k+1}-PredVar{k+1}) * G';
    
end

EstState = BackState;
EstVar = BackVar;

end

