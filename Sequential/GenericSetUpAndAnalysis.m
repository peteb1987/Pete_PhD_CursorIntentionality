function [ correct, Mov ] = GenericSetUpAndAnalysis(track, click_times, click_locs)
%GENERICSETUPANDANALYSIS Set up figures, call inference algorithms, analyse
%results, etc.

global CONSTANTS;
global FLAGS;

% Flags
FLAGS.PLOT = true;
FLAGS.RECORD = true;

% Constants
CONSTANTS.DUMMY_SPACING = 100;
CONSTANTS.SLOWDOWN = 1;
CONSTANTS.FRAMEPER = floor(1000/30);

if FLAGS.PLOT
    % Draw figure
    handles.fig = figure; hold on;
    set(gca, 'DataAspectRatio', [1 1 1]);
    xlim([0, 1280]); ylim([0, 800]);
    xlabel('x (pixels)'); ylabel('y (pixels)');
    handles.dummy = [];
    handles.correct = [];
    handles.chosen = [];
    handles.plot = [];
    handles.posteriors = [];
else
    handles = [];
end

Mov = [];
if FLAGS.RECORD
    winsize = get(handles.fig,'Position');
    winsize(1:2) = [0 0];
    numframes = (track.t(end)-track.t(1))/CONSTANTS.FRAMEPER;
    Mov=moviein(numframes,handles.fig,winsize);
%     set(handles.fig,'NextPlot','replacechildren')
    fr = 0;
end

% Set click index - which click is next
click_ind = 1;

% array for timing animation
end_proc_time = cell(track.N,1);
end_proc_time{1} = clock;

% performance eval - count time spent with right or wrong estimate
right_time = 0;
wrong_time = 0;

chosen_button = [];

for k = 1:track.N
    
%     if ~FLAGS.PLOT
%         disp([num2str(k) ' out of ' num2str(track.N)]);
%     end
    
    % test whether a click has occured
    if (k==1) || (track.t(k) > click_times(click_ind))
        
        % Increment click pointer
        click_ind = click_ind + 1;
        
        % break out of the loop if we've run out of clicks
        if click_ind > length(click_times)
            break;
        end
        
        % generate an array of dummy locations
        [ dummy_locs, correct_button, handles ] = NextClick( click_ind, click_locs, handles );
        N_locs = length(dummy_locs);
        
        % Reset likelihood calculations
        time_buffer = zeros(0,1);
        like_buffer = zeros(0,N_locs);
        
    end

    %%%%%

    if k==1
        SubMove.sm = false;
        SubMove.start_pos = [];
        SubMove.start_time = [];
        SubMove.start_k = [];
    end
    
%     [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Nearest( k, track, dummy_locs, time_buffer, like_buffer );
    [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Drift( k, track, dummy_locs, time_buffer, like_buffer );
%     [ chosen_button, time_buffer, like_buffer ] = SeqIntention_ConstantJerk( k, track, dummy_locs, chosen_button, time_buffer, like_buffer );
%     [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Bearing( k, track, dummy_locs, time_buffer, like_buffer );
%     [ chosen_button, time_buffer, like_buffer ] = SeqIntention_Composite( k, track, dummy_locs, time_buffer, like_buffer );
%     [ chosen_button, time_buffer, like_buffer ] = SeqIntention_PiecewiseDrift( k, track, dummy_locs, time_buffer, like_buffer );
%     [ chosen_button, SubMove, time_buffer, like_buffer ] = SeqIntention_Submovement( k, track, dummy_locs, SubMove, time_buffer, like_buffer );

    %%%%%

    if k>1
        
        % see if we chose the right button and count the time
        if chosen_button == correct_button
            right_time = right_time + (track.t(k)-track.t(k-1));
        else
            wrong_time = wrong_time + (track.t(k)-track.t(k-1));
        end
        
        if FLAGS.PLOT
            
            % Update the plot
            total_like = sum(like_buffer, 1);
            like = exp(total_like);
            shade = like/max(like);
            [ handles ] = UpdateFigure( k, track, dummy_locs, shade, chosen_button, correct_button, handles );
            disp(['Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);
            
        end
    end
    
    % Wait, so the animation is timed correctly
    if (k > 1) && (FLAGS.PLOT)
        end_proc_time{k} = clock;
        time_rem = (track.t(k)-track.t(k-1))/(1000/CONSTANTS.SLOWDOWN) - etime(end_proc_time{k}, end_proc_time{k-1});
        if time_rem > 0
            pause(time_rem);
        else
%             disp(time_rem);
        end
    end
    
    if (k > 1) && (FLAGS.RECORD)
        delta = track.t(k) - fr * CONSTANTS.FRAMEPER;
        while delta > CONSTANTS.FRAMEPER
            fr = fr + 1;
            Mov(:,fr)=getframe(handles.fig,winsize);
            delta = delta - CONSTANTS.FRAMEPER;
        end
        
    end
    
end

disp(['   Correct button: ' num2str(right_time) '. Wrong button: ' num2str(wrong_time) '.']);

% output the proportion of time we spend on the right button
correct = right_time / (right_time+wrong_time);

end

