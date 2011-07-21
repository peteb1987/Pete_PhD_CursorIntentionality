function [ chosen_button, SubMove, time_buffer, like_buffer ] = SeqIntention_Submovement( k, track, dummy_locs, SubMove, time_buffer, like_buffer )
% Sequential intention tracking using submovement model - divide the motion
% into sojourns. Treat entire sojourn as drift.

% global test_par;
%
% LAMBDA = test_par.LAMBDA;
% BUFFER_LENGTH = test_par.BUFFER_LENGTH;

LAMBDA = 0.014;         % 0.003 for mouse, 0.005-0.01 for trackball
SPEED_THRESH = 0.25;
MARGIN = 0;
SM_LAMBDA = 0.03;
BUFFER_LENGTH = 2000;

N_locs = length(dummy_locs);
chosen_button = [];

sm = SubMove.sm;
start_pos = SubMove.start_pos;
start_time = SubMove.start_time;
start_k = SubMove.start_k;

if k > 1
    
    % Get new position and time
    pos = [track.x(k) track.y(k)];
    time = track.t(k);
    
    % Get last position and time
    prev_pos = [track.x(k-1) track.y(k-1)];
    prev_time = track.t(k-1);
    
    % Speed and velocity
    velocity = (pos - prev_pos) ./ (time - prev_time);
    speed = sqrt(velocity(1)^2+velocity(2)^2);
    
    if (speed > SPEED_THRESH+MARGIN) && (~sm)
        % Begin submovement
        sm = true;
        start_pos = prev_pos;
        start_time = prev_time;
        start_k = k;
        
    elseif (speed < SPEED_THRESH) && (sm)
        % End submovement
        sm = false;
        end_pos = pos;
        end_time = time;
        end_k = k;
        
        sigma = end_time-start_time;
        mu = repmat(end_pos-start_pos, N_locs, 1) - SM_LAMBDA*(end_time-start_time)*bsxfun(@minus, dummy_locs, start_pos);
        like = log(normpdf(mu(:,1), 0, sqrt(sigma)));
        like = like + log(normpdf(mu(:,2), 0, sqrt(sigma)));
        
        % Add time and likelihoods to buffer
        time_buffer = [time_buffer; time];
        like_buffer = [like_buffer; like'];
        
    elseif sm
        % Mid-submovement
        sigma = time-start_time;
        mu = repmat(pos-start_pos, N_locs, 1) - SM_LAMBDA*(time-start_time)*bsxfun(@minus, dummy_locs, start_pos);
        like = log(normpdf(mu(:,1), 0, sqrt(sigma)));
        like = like + log(normpdf(mu(:,2), 0, sqrt(sigma)));
        
        if (size(time_buffer,1)>0) && (time_buffer(end) == prev_time)
            time_buffer(end) = [];
            like_buffer(end,:) = [];
        end
        
        % Add time and likelihoods to buffer
        time_buffer = [time_buffer; time];
        like_buffer = [like_buffer; like'];
        
    elseif (speed < SPEED_THRESH)
        % Normal drift term
        
        % Work out likelihood
        sigma = (exp(2*LAMBDA*(time-prev_time))-1)/(2*LAMBDA);
        mu = repmat(pos, N_locs, 1) - dummy_locs - exp(-LAMBDA*(time-prev_time))*(bsxfun(@minus,prev_pos,dummy_locs));
        like = log(normpdf(mu(:,1), 0, sqrt(sigma)));
        like = like + log(normpdf(mu(:,2), 0, sqrt(sigma)));
        
        % Add time and likelihoods to buffer
        time_buffer = [time_buffer; time];
        like_buffer = [like_buffer; like'];
        
    end
    
    % Remove old things from the front of the buffer
    while (size(time_buffer, 1)>0) && (time_buffer(1) < time-BUFFER_LENGTH)
        time_buffer(1, :) = [];
        like_buffer(1, :) = [];
    end
    
    % Find ML button
    total_like = sum(like_buffer, 1);
    chosen_button = find(total_like==max(total_like),1);
    
end

SubMove.sm = sm;
SubMove.start_pos = start_pos;
SubMove.start_time = start_time;
SubMove.start_k = start_k;

end

