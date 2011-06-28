function drawSojourn( track )
% Draw an entire track or sojourn

figure, hold on, xlim([0, 1280]), ylim([0, 800]);
plot(track.x, track.y, '-');
% for ii = 1:track.N
%     if strcmp(track.events{ii}, 'T')
%         plot(track.x(ii), track.y(ii), 'xr')
%     end
%     if strcmp(track.events{ii}, 'O')
%         plot(track.x(ii), track.y(ii), 'xg')
%     end
% end

end

