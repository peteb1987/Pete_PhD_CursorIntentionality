clup;

dbstop if error

filename = '5Mouse.txt';

[track, sojourns, click_times, click_locs] = prelimProcessing(filename);
K = length(sojourns);

%%% TESTING AREA %%%

plot_list = 25;%1:40;

for k = plot_list
    [kf_mean, kf_var] = kalmanFilter(sojourns(k));
    
    [ cp, v ] = detectChangePoints( kf_mean );
    
    
    x_est = cellfun(@(x) x(1), kf_mean);
    y_est = cellfun(@(x) x(2), kf_mean);
%     xdot_est = cellfun(@(x) x(3), kf_mean);
%     ydot_est = cellfun(@(x) x(4), kf_mean);
    
    drawSojourn(sojourns(k));
    plot(x_est, y_est, '-r')
    
    for jj = cp'
        plot(sojourns(k).x(jj), sojourns(k).y(jj), 'k*');
    end
    
    figure, hold on, plot(sojourns(k).t, v);
    for jj = cp'
        plot(sojourns(k).t(jj), v(jj), 'k*');
    end
    
end

% for k = plot_list
%     [sojourns(k)] = detectChangePoints(sojourns(k));
% end





%%% END OF TESTING AREA %%%

% for k = plot_list
%     drawSojourn(sojourns(k));
% end
% 
% drawSojourn(track);