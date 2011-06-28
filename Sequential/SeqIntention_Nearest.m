function [  ] = SeqIntention_Nearest( track, click_times, click_locs, handles )
%SEQINTENTION Sequential intention tracking using nearest-over-window
%method

global CONSTANTS;
global FLAGS;

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
    
    if (k==1) || (track.t(k) > click_times(click_ind))
        
        % Increment click pointer
        click_ind = click_ind + 1;
        
        if click_ind > length(click_times)
            break;
        end
        
        [ dummy_locs, correct_button, handles ] = NextClick( click_ind, click_locs, handles );
        
        % Reset everything
        buffer = zeros(0,2);
        
    end
    
    % Get new position and time
    pos = [track.x(k) track.y(k)];
    time = track.t(k);
    
    % Work out nearest target
    dist_sq = (dummy_locs(:,1) - pos(1)).^2 + (dummy_locs(:,2) - pos(2)).^2;
    nrst = find(dist_sq==min(dist_sq), 1);
    
    % Add time and index of nearest target to buffer
    buffer = [buffer; time, nrst];
    
    % Remove old things from the front of the buffer
    while buffer(1, 1) < time-BUFFER_LENGTH
        buffer(1, :) = [];
    end
    
    % Find modal button
    chosen_button = mode(buffer(:,2));
    
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

