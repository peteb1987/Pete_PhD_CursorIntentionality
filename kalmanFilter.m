function [ EstState, EstVar ] = kalmanFilter( track )
% Kalman filter a track according to NCVM

ProcNoiseVar = 1E-4;
ObsNoiseVar = 1/12;

N = track.N;

PredState = cell(N, 1);
PredVar = cell(N, 1);

EstState = cell(N, 1);
EstVar = cell(N, 1);

% Initialise
P = track.t(2) - track.t(1);
EstState{1} = [track.x(1); track.y(1); 0; 0];
EstState{1}(3:4) = [(track.x(1)-track.x(2))/P; (track.y(1)-track.y(2))/P];
EstVar{1} = 1E-40 * eye(4);

% Loop through sample points
for ii = 2:N
    
    P = track.t(ii) - track.t(ii-1);
    A = [1 0 P 0; 0 1 0 P; 0 0 1 0; 0 0 0 1];
    C = [1 0 0 0; 0 1 0 0];
    Q = ProcNoiseVar * [P^3/3 0 P^2/2 0; 0 P^3/3 0 P^2/2; P^2/2 0 P 0; 0 P^2/2 0 P];
    R = ObsNoiseVar * eye(2);

    % Prediction step
    PredState{ii} = A * EstState{ii-1};
    PredVar{ii} = A * EstVar{ii-1} * A' + Q;
    
    % Update step
    y = [track.x(ii); track.y(ii)] - C * PredState{ii};
    s = C * PredVar{ii} * C' + R;
    gain = PredVar{ii} * C' / s;
    EstState{ii} = PredState{ii} + gain * y;
    EstVar{ii} = (eye(4)-gain*C) * PredVar{ii};

end
    
    
    %%%%%%%%%%%%%%%


end

