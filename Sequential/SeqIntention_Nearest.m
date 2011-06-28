function [  ] = SeqIntention_Nearest( track, click_times, click_locs )
%SEQINTENTION Sequential intention tracking using nearest-over-window
%method

% Constants
DUMMY_SPACING = 100;
BUFFER_LENGTH = 1000;
SLOWDOWN = 1;

% Draw figure
f = figure; hold on;
set(gca, 'DataAspectRatio', [1 1 1]);
xlim([0, 1280]); ylim([0, 800]);
xlabel('x (pixels)'); ylabel('y (pixels)');
dummy_handles = [];
correct_handle = [];
chosen_handle = [];
plot_handle = [];

% Set click index - which click is next
click_ind = 1;

% time array
end_proc_time = cell(track.N,1);
end_proc_time{1} = clock;

for k = 1:track.N
    
    if (k==1) || (track.t(k) > click_times(click_ind))
        
        % Increment click pointer
        click_ind = click_ind + 1;
        
        if click_ind > length(click_times)
            break;
        end
        
        % Create an array of targets, tiled from the correct location
        dummy_offset_x = mod(click_locs(click_ind, 1), DUMMY_SPACING);
        dummy_offset_y = mod(click_locs(click_ind, 2), DUMMY_SPACING);
        dummy_x = (0:DUMMY_SPACING:1200) + dummy_offset_x;
        dummy_y = (0:DUMMY_SPACING:800) + dummy_offset_y;
        dummy_locs = zeros(length(dummy_x)*length(dummy_y), 2);
        count = 1;
        for ii = 1:length(dummy_x)
            for jj = 1:length(dummy_y)
                dummy_locs(count, 1) = dummy_x(ii);
                dummy_locs(count, 2) = dummy_y(jj);
                count = count + 1;
            end
        end
        
        % Plot targets
        delete(dummy_handles);
        delete(correct_handle);
        dummy_handles = zeros(length(dummy_locs), 1);
        for ii=1:size(dummy_locs,1),
            dummy_handles(ii) = rectangle('Position', [dummy_locs(ii,1)-20 dummy_locs(ii,2)-20 40 40], 'Curvature', [1 1]);
        end
        correct_handle = rectangle('Position', [click_locs(click_ind,1)-20 click_locs(click_ind,2)-20 40 40], 'Curvature', [1 1], 'EdgeColor', [1 0 0], 'LineWidth', 2);
        
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
    
    % Drawing
    figure(f);
    delete(plot_handle);
    plot_handle = plot(track.x(1:k), track.y(1:k));
    delete(chosen_handle);
    chosen_handle = plot(dummy_locs(chosen_button,1), dummy_locs(chosen_button,2), 'xr', 'markersize', 10);
    
    % Wait
    if k > 1
        end_proc_time{k} = clock;
        time_rem = (track.t(k)-track.t(k-1))/(1000*SLOWDOWN) - etime(end_proc_time{k}, end_proc_time{k-1});
        if time_rem > 0
            pause(time_rem);
        else
%             disp(time_rem);
        end
    end
    
end




end

