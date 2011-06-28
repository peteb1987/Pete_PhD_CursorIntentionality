function [ dummy_locs, correct_button, handles ] = NextClick( click_ind, click_locs, handles )
%NEXTCLICK Updates and redraws grid of dummy targets

global CONSTANTS;
global FLAGS;

% Create an array of targets, tiled from the correct location
dummy_offset_x = mod(click_locs(click_ind, 1), CONSTANTS.DUMMY_SPACING);
dummy_offset_y = mod(click_locs(click_ind, 2), CONSTANTS.DUMMY_SPACING);
dummy_x = (0:CONSTANTS.DUMMY_SPACING:1200) + dummy_offset_x;
dummy_y = (0:CONSTANTS.DUMMY_SPACING:800) + dummy_offset_y;
dummy_locs = zeros(length(dummy_x)*length(dummy_y), 2);
count = 1;
for ii = 1:length(dummy_x)
    for jj = 1:length(dummy_y)
        dummy_locs(count, 1) = dummy_x(ii);
        dummy_locs(count, 2) = dummy_y(jj);
        count = count + 1;
    end
end

% Find the correct button
x_right = dummy_locs(:,1)==click_locs(click_ind,1);
y_right = dummy_locs(:,2)==click_locs(click_ind,2);
correct_button = find(x_right & y_right, 1);

if FLAGS.PLOT
    % Plot targets
    delete(handles.dummy);
    delete(handles.correct);
    handles.dummy = zeros(length(dummy_locs), 1);
    for ii=1:size(dummy_locs,1),
        handles.dummy(ii) = rectangle('Position', [dummy_locs(ii,1)-20 dummy_locs(ii,2)-20 40 40], 'Curvature', [1 1]);
    end
    handles.correct = rectangle('Position', [click_locs(click_ind,1)-20 click_locs(click_ind,2)-20 40 40], 'Curvature', [1 1], 'EdgeColor', [1 0 0], 'LineWidth', 2);
end


end

