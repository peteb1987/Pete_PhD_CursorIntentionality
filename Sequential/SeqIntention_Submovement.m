function [ correct_proportion ] = SeqIntention_Submovement( track, click_times, click_locs, handles )
%SEQINTENTION Sequential intention tracking using drift model method

global CONSTANTS;
global FLAGS;

% global test_par;
% 
% LAMBDA = test_par.LAMBDA;
% BUFFER_LENGTH = test_par.BUFFER_LENGTH;

LAMBDA = 0.014;         % 0.003 for mouse, 0.005-0.01 for trackball
SPEED_THRESH = 0.25;
MARGIN = 0;
SM_LAMBDA = 0.03;
BUFFER_LENGTH = 2000;


% Set click index - which click is next
click_ind = 1;

% time array
end_proc_time = cell(track.N,1);
end_proc_time{1} = clock;

% performance eval
right_time = 0;
wrong_time = 0;

%%%%%

sm = false;

%%%%%

for k = 1:track.N
    
%     if ~FLAGS.PLOT
%         disp([num2str(k) ' out of ' num2str(track.N)]);
%     end
    
    if (k==1) || (track.t(k) > click_times(click_ind))
        
        % Increment click pointer
        click_ind = click_ind + 1;
        
        if click_ind > length(click_times)
            break;
        end
        
        [ dummy_locs, correct_button, handles ] = NextClick( click_ind, click_locs, handles );
        N_locs = length(dummy_locs);
        
        % Reset everything
        time_buffer = zeros(0,1);
        like_buffer = zeros(0,N_locs);
        
    end
    
    %%%%%
    
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
    
    %%%%%
    
    if k>1
        
        if chosen_button == correct_button
            right_time = right_time + (track.t(k)-track.t(k-1));
        else
            wrong_time = wrong_time + (track.t(k)-track.t(k-1));
        end
        
        if FLAGS.PLOT
            
            [ handles ] = UpdateFigure( k, track, dummy_locs, chosen_button, handles );
            disp(['Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);
            
        end
    end
    
    % Wait
    if (k > 1) && (FLAGS.PLOT)
        end_proc_time{k} = clock;
        time_rem = (track.t(k)-track.t(k-1))/(1000/CONSTANTS.SLOWDOWN) - etime(end_proc_time{k}, end_proc_time{k-1});
        if time_rem > 0
            pause(time_rem);
        else
%             disp(time_rem);
        end
    end
    
end

disp(['   Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);

correct_proportion = right_time / (right_time+wrong_time);

end

