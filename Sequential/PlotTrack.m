function PlotTrack( track, click_locs )
%PLOTTRACK Plot track

figure; hold on;
    
for i=1:size(click_locs,1),
	rectangle('Position', [click_locs(i,1)-20 click_locs(i,2)-20 40 40], 'Curvature', [1 1]);
end

plot(track.x, track.y);

set(gca, 'DataAspectRatio', [1 1 1]);
xlim([0, 1280]); ylim([0, 800]);
xlabel('x (pixels)'); ylabel('y (pixels)');
    
end

