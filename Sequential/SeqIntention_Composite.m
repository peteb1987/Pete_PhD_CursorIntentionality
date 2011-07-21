function [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Composite( k, track, dummy_locs, time_buffer, like_buffer )
% Sequential intention tracking composite method - bearing at high speed,
% drift and low speed

THRESH = 0.5;
BNG_SIGMA = 10;
DRIFT_SIGMA = 100;
LAMBDA = 0.004;
BUFFER_LENGTH = 1200;

N_locs = length(dummy_locs);
chosen_button = [];

if k > 1
    
    % Get new position and time
    pos = [track.x(k) track.y(k)];
    time = track.t(k);
    
    % Get last position and time
    prev_pos = [track.x(k-1) track.y(k-1)];
    prev_time = track.t(k-1);
    
    velocity = (pos - prev_pos) ./ (time - prev_time);
    speed = sqrt(velocity(1)^2+velocity(2)^2);
    
    % Work out likelihood
    if speed > THRESH
        % bearing at high speed
        heading = atan2((pos(2)-prev_pos(2)),(pos(1)-prev_pos(1)));
        target_bearings = atan2( bsxfun(@minus,dummy_locs(:,2),prev_pos(2)),bsxfun(@minus,dummy_locs(:,1),prev_pos(1)) );
        like = log(normpdf(target_bearings, heading, sqrt(BNG_SIGMA)));
    else
        % drift at low speed
        sigma = DRIFT_SIGMA*(exp(2*LAMBDA*(time-prev_time))-1)/(2*LAMBDA);
        mu = repmat(pos, N_locs, 1) - dummy_locs - exp(-LAMBDA*(time-prev_time))*(bsxfun(@minus,prev_pos,dummy_locs));
        like = log(normpdf(mu(:,1), 0, sqrt(sigma)));
        like = like + log(normpdf(mu(:,2), 0, sqrt(sigma)));
    end
    
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

