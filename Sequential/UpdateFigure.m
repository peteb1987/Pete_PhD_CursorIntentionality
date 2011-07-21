function [ handles ] = UpdateFigure( k, track, dummy_locs, shade, chosen_button, correct_button, handles )
%UPDATEFIGURE Summary of this function goes here
%   Detailed explanation goes here

% Drawing
figure(handles.fig);
delete(handles.plot);
handles.plot = plot(track.x(1:k), track.y(1:k));

if all(~isnan(shade))
    delete(handles.posteriors);
    handles.posteriors = zeros(length(dummy_locs), 1);
    for ii=1:size(dummy_locs,1),
        handles.posteriors(ii) = rectangle('Position', [dummy_locs(ii,1)-20 dummy_locs(ii,2)-20 40 40], 'Curvature', [1 1], 'FaceColor', [shade(ii), shade(ii), shade(ii)]);
    end
end

delete(handles.correct);
handles.correct = rectangle('Position', [dummy_locs(correct_button,1)-20 dummy_locs(correct_button,2)-20 40 40], 'Curvature', [1 1], 'EdgeColor', [1 0 0], 'LineWidth', 2);

delete(handles.chosen);
handles.chosen = plot(dummy_locs(chosen_button,1), dummy_locs(chosen_button,2), 'xr', 'markersize', 10);

end

