function [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Drift( k, track, dummy_locs, time_buffer, like_buffer )
% Sequential intention tracking using drift model method

% global test_par;
% 
% LAMBDA = test_par.LAMBDA;
% BUFFER_LENGTH = test_par.BUFFER_LENGTH;

SIGMA = 100;
LAMBDA = 0.012;
BUFFER_LENGTH = 10;

N_locs = length(dummy_locs);
chosen_button = [];

% Get new position and time
pos = [track.x(k) track.y(k)];
time = track.t(k);

if k > 1

    % Get last position and time
    prev_pos = [track.x(k-1) track.y(k-1)];
    prev_time = track.t(k-1);
    
    % Work out likelihood
    sigma = SIGMA*(1-exp(-2*LAMBDA*(time-prev_time)))/(2*LAMBDA);
    mu = repmat(pos, N_locs, 1) - dummy_locs - exp(-LAMBDA*(time-prev_time))*(bsxfun(@minus,prev_pos,dummy_locs));
    like = log(normpdf(mu(:,1), 0, sqrt(sigma)));
    like = like + log(normpdf(mu(:,2), 0, sqrt(sigma)));
    
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

