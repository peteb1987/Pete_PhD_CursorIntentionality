function [  ] = SeqIntention_Bearing( track, click_times, click_locs, handles )
%SEQINTENTION Sequential intention tracking using bearing model method

global CONSTANTS;
global FLAGS;

SIGMA = 1;
BUFFER_LENGTH = 1000;

% Set click index - which click is next
click_ind = 1;

% time array
end_proc_time = cell(track.N,1);
end_proc_time{1} = clock;

% performance eval
right_time = 0;
wrong_time = 0;

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

disp(['Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);


end

