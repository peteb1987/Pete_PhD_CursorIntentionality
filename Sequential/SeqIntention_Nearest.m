function [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Nearest( k, track, dummy_locs, time_buffer, like_buffer )
%Sequential intention tracking using nearest-over-window method

% global test_par;
% BUFFER_LENGTH = test_par.BUFFER_LENGTH;

BUFFER_LENGTH = 10;

% Get new position and time
pos = [track.x(k) track.y(k)];
time = track.t(k);
    
% Work out nearest target
dist_sq = (dummy_locs(:,1) - pos(1)).^2 + (dummy_locs(:,2) - pos(2)).^2;
% nrst = find(dist_sq==min(dist_sq), 1);

% Add time and index of nearest target to buffer
% time_buffer = [time_buffer; time, nrst];
time_buffer = [time_buffer; time];
like_buffer = [like_buffer; dist_sq'];

% Remove old things from the front of the buffer
while time_buffer(1, 1) < time-BUFFER_LENGTH
    time_buffer(1, :) = [];
    like_buffer(1, :) = [];
end

% Find modal button
sum_sq = sum(like_buffer, 1);
chosen_button = find(sum_sq==min(sum_sq),1);
    
end

