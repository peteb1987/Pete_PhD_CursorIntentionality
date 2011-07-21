function [ chosen_button, time_buffer, like_buffer ] = SeqIntention_PiecewiseDrift( k, track, dummy_locs, time_buffer, like_buffer )
% Sequential intention tracking using piecewise drift model - normal drift
% (velocity proportional to distance) when close to targets, constant
% velocity towards target when far away.

BUFFER_LENGTH = 100;
RADIUS = 0;
SIGMA_NEAR = 1;
LAMBDA = 0.003;
SIGMA_FAR = 1;
CONST = 1;

N_locs = length(dummy_locs);
chosen_button = [];

if k > 1
    
    % Get new position and time
    pos = [track.x(k) track.y(k)];
    time = track.t(k);
    
    % Get last position and time
    prev_pos = [track.x(k-1) track.y(k-1)];
    prev_time = track.t(k-1);
    
    % Work out likelihood
    dist = sqrt((dummy_locs(:,1) - pos(1)).^2 + (dummy_locs(:,2) - pos(2)).^2);
    
    sigma_near = SIGMA_NEAR * (exp(2*LAMBDA*(time-prev_time))-1)/(2*LAMBDA);
    mu_near = repmat(pos, N_locs, 1) - dummy_locs - exp(-LAMBDA*(time-prev_time))*(bsxfun(@minus,prev_pos,dummy_locs));
    
    tgt_vect = bsxfun(@minus, dummy_locs, prev_pos);
    tgt_dist = sqrt(sum(tgt_vect.^2,2));
    mu_far = repmat(pos-prev_pos, N_locs, 1) - CONST * (time-prev_time) * (bsxfun(@rdivide,tgt_vect,tgt_dist));
    sigma_far = SIGMA_FAR * (time-prev_time);
    
    like_near = log(normpdf(mu_near(:,1), 0, sqrt(sigma_near)));
    like_near = like_near + log(normpdf(mu_near(:,2), 0, sqrt(sigma_near)));
    
    like_far = log(normpdf(mu_far(:,1), 0, sqrt(sigma_far)));
    like_far = like_far + log(normpdf(mu_far(:,2), 0, sqrt(sigma_far)));
    
    like = like_near;
    like(dist>RADIUS) = like_far(dist>RADIUS);
    
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

