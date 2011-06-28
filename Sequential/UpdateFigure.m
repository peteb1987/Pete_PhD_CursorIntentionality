function [ handles ] = UpdateFigure( k, track, dummy_locs, chosen_button, handles )
%UPDATEFIGURE Summary of this function goes here
%   Detailed explanation goes here

% Drawing
figure(handles.fig);
delete(handles.plot);
handles.plot = plot(track.x(1:k), track.y(1:k));
delete(handles.chosen);
handles.chosen = plot(dummy_locs(chosen_button,1), dummy_locs(chosen_button,2), 'xr', 'markersize', 10);


end

