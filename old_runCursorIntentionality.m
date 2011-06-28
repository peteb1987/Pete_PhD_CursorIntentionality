clup;

dbstop if error

filename = '14Mouse.txt';

[track, sojourns, click_times, click_locs] = prelimProcessing(filename);
K = length(sojourns);

%%% TESTING AREA %%%

v_thresh = 0.25;
plot_list = 2:20;%K;
% plot_list(plot_list==7) = [];

init_bng_errs = [];
init_acc = [];

sweep_accel = [];
sweep_rel_bng = [];
sweep_tgt_perp = [];
sweep_bng_errs = [];
sweep_init_err = [];
stop_locs = [];

for k = plot_list
    [kf_mean, kf_var] = kalmanFilter(sojourns(k));
    
%     [ cp, v ] = detectChangePoints( kf_mean );
    [ sweeps, v_kf ] = detectSweeps( kf_mean, sojourns(k) );
    
    xdot = [0; diff(sojourns(k).x)./diff(sojourns(k).t)];
    ydot = [0; diff(sojourns(k).y)./diff(sojourns(k).t)];
    
    
    x_est = cellfun(@(x) x(1), kf_mean);
    y_est = cellfun(@(x) x(2), kf_mean);
    xdot_est = cellfun(@(x) x(3), kf_mean);
    ydot_est = cellfun(@(x) x(4), kf_mean);
    
    xdotdot_est = [0; diff(xdot_est)];
    ydotdot_est = [0; diff(ydot_est)];
    
    [b, v] = cart2pol(xdot_est, ydot_est);
    aT = xdotdot_est.*cos(b) + ydotdot_est.*sin(b);
    aP = -xdotdot_est.*sin(b) + ydotdot_est.*cos(b);
    
    drawSojourn(sojourns(k));
    plot(x_est, y_est, '-r')
    
%     for jj = 1:length(shudders)
%         
%         
%         
%     end
    
    for jj = 1:length(sweeps)
%         if sweeps(jj).big
            plot(x_est(sweeps(jj).start:sweeps(jj).stop), y_est(sweeps(jj).start:sweeps(jj).stop), '-', 'color', [rand, 0.5, rand], 'LineWidth', 2);
%         else
%             plot(x_est(sweeps(jj).start:sweeps(jj).stop), y_est(sweeps(jj).start:sweeps(jj).stop), '-', 'color', [.75 .75 .75], 'LineWidth', 2);
%         end
        
        % Examine bearings
        [bng_init, speed_init] = cart2pol(sweeps(jj).v_init(1), sweeps(jj).v_init(2));
        tgt_vector = click_locs(k+1, :)' - [x_est(sweeps(jj).start); y_est(sweeps(jj).start)];
        [init_tgt_bng, ~] = cart2pol(tgt_vector(1), tgt_vector(2));
        
        bng_diff = bng_init - init_tgt_bng;
        if bng_diff > pi
            bng_diff = bng_diff - pi;
        elseif bng_diff < -pi
            bng_diff = bng_diff + pi;
        end
        
        init_bng_errs = [init_bng_errs; bng_diff];
        init_acc = [init_acc; aT(sweeps(jj).start)];
        
        % Examine drift
        perp_innov = aP(sweeps(jj).start:sweeps(jj).stop);
        sweep_accel = [sweep_accel; mean(perp_innov)];
        
        [heading, speed] = cart2pol(xdot_est(sweeps(jj).start:sweeps(jj).stop), ydot_est(sweeps(jj).start:sweeps(jj).stop));
        
        
        tgt_vector = repmat(click_locs(k+1, :)', 1, sweeps(jj).stop-sweeps(jj).start+1) - [x_est(sweeps(jj).start:sweeps(jj).stop), y_est(sweeps(jj).start:sweeps(jj).stop)]';
        [tgt_bng, tgt_range] = cart2pol(tgt_vector(1, :)', tgt_vector(2, :)');
        rel_bng = tgt_bng-heading;
        rel_bng(rel_bng>pi) = rel_bng(rel_bng>pi) - pi;
        rel_bng(rel_bng<-pi) = rel_bng(rel_bng<-pi) + pi;
        sweep_rel_bng = [sweep_rel_bng; mean(rel_bng)];
        
        tgt_perp = tgt_range .* sin(rel_bng);
        sweep_tgt_perp = [sweep_tgt_perp; mean(tgt_perp)];
        
        bng_diff = heading - tgt_bng;
        bng_diff(bng_diff>pi) = bng_diff(bng_diff>pi) - pi;
        bng_diff(bng_diff<-pi) = bng_diff(bng_diff<-pi) + pi;
        sweep_bng_errs = [sweep_bng_errs; bng_diff];
        
        head_err_from_init = mean(heading) - init_tgt_bng;
        head_err_from_init(head_err_from_init>pi) = head_err_from_init(head_err_from_init>pi) - pi;
        head_err_from_init(head_err_from_init<-pi) = head_err_from_init(head_err_from_init<-pi) + pi;
        sweep_init_err = [sweep_init_err; head_err_from_init];
        
        
        % Stopping locations
        stop_tgt_vector = click_locs(k+1, :) - [x_est(sweeps(jj).stop), y_est(sweeps(jj).stop)];
        stop_locs = [stop_locs; stop_tgt_vector];
        
        
    end
    

    
    figure, hold on, plot(min(sojourns(k).t):max(sojourns(k).t), v_kf), plot([min(sojourns(k).t), max(sojourns(k).t)], [v_thresh, v_thresh], 'k-'), ylim([0, 5]);
    figure, hold on, plot(min(sojourns(k).t):max(sojourns(k).t), aT, 'b'), plot(min(sojourns(k).t):max(sojourns(k).t), aP, 'r')%, plot(sojourns(k).t, aP_filt, 'g');
    
end

% figure, hist(init_bng_errs, 50), title('Sweep initial bearing errors');
% figure, hist(sweep_bng_errs, 50), title('Sweep bearing errors');
% figure, hist(sweep_rel_bng, 50), title('Sweep average bearing errors');
% figure, hist(sweep_init_err, 50), title('Sweep heading errors');
% figure, plot(stop_locs(:,1), stop_locs(:,2), 'x');

% figure, hist(init_acc, 30), title('Sweep initial acceleration');


% for k = plot_list
%     [sojourns(k)] = detectChangePoints(sojourns(k));
% end





%%% END OF TESTING AREA %%%

% for k = plot_list
%     drawSojourn(sojourns(k));
% end
% 
% drawSojourn(track);