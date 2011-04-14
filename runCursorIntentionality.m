clup;

dbstop if error

filename = '1Mouse.txt';

[track, sojourns, click_times, click_locs] = prelimProcessing(filename);
K = length(sojourns);

%%% TESTING AREA %%%

plot_list = 2:10;

for k = plot_list
    [kf_mean, kf_var] = kalmanFilter(sojourns(k));
    
%     [ cp, v ] = detectChangePoints( kf_mean );
    [ sweeps, v_kf ] = detectSweeps( kf_mean, sojourns(k) );
    
    x_est = cellfun(@(x) x(1), kf_mean);
    y_est = cellfun(@(x) x(2), kf_mean);
%     xdot_est = cellfun(@(x) x(3), kf_mean);
%     ydot_est = cellfun(@(x) x(4), kf_mean);
    
    drawSojourn(sojourns(k));
    plot(x_est, y_est, '-r')
    for jj = 1:length(sweeps)
        plot(x_est(sweeps{jj}(1):sweeps{jj}(2)), y_est(sweeps{jj}(1):sweeps{jj}(2)), 'k-', 'LineWidth', 2);
    end
    
    xdot = [0; diff(sojourns(k).x)./diff(sojourns(k).t)];
    ydot = [0; diff(sojourns(k).y)./diff(sojourns(k).t)];
    
    xdotdot = [0; diff(xdot)./diff(sojourns(k).t)];
    ydotdot = [0; diff(ydot)./diff(sojourns(k).t)];
    
    [b, v] = cart2pol(xdot, ydot);
    
    aT = xdotdot.*cos(b) + ydotdot.*sin(b);
    aP = -xdotdot.*sin(b) + ydotdot.*cos(b);
    
    figure, hold on, plot(sojourns(k).t, v_kf);
    plot(sojourns(k).t, v, 'r');
    figure, hold on, plot(sojourns(k).t, aT, 'b'), plot(sojourns(k).t, aP, 'r');
    
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