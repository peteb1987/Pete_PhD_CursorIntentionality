function [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Bearing( k, track, dummy_locs, time_buffer, like_buffer )
% Sequential intention tracking using bearing model method

% global test_par;
% BUFFER_LENGTH = test_par.BUFFER_LENGTH;

SIGMA = 10;
BUFFER_LENGTH = 100;

chosen_button = [];

if k > 1
    
    % Get new position and time
    pos = [track.x(k) track.y(k)];
    time = track.t(k);
    
    % Get last position and time
    prev_pos = [track.x(k-1) track.y(k-1)];
    prev_time = track.t(k-1);
    
    % Work out likelihood
    heading = atan2((pos(2)-prev_pos(2)),(pos(1)-prev_pos(1)));
    target_bearings = atan2( bsxfun(@minus,dummy_locs(:,2),prev_pos(2)),bsxfun(@minus,dummy_locs(:,1),prev_pos(1)) );
    like = log(normpdf(target_bearings, heading, sqrt(SIGMA)));
    
    % Add time and likelihoods to buffer
    time_buffer = [time_buffer; time];
    like_buffer = [like_buffer; like'];
    
    % Remove old things from the front of the buffer
    while time_buffer(1) < time-BUFFER_LENGTH
        time_buffer(1, :) = [];
        like_buffer(1, :) = [];
    end
    
    % Find ML button
    total_like = sum(like_buffer, 1);
    chosen_button = find(total_like==max(total_like),1);
    
end

end

