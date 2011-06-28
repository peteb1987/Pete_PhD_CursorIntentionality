clup;

dbstop if error

filename = '1Mouse.txt';

[track, sojourns, click_times, click_locs] = prelimProcessing(filename);
K = length(sojourns);

%%% TESTING AREA %%%

plot_list = 2:K;%70:80;%

list_sweep_avg_rel_heading = [];
list_sweep_rel_end_locs = [];
list_sweep_rel_bng = [];
list_sweep_speed = [];
list_shudders_rel_bng = [];
list_shudders_speed = [];

sweep_avg_heading_variance = 0.2;
sweep_rel_end_covar = 3000;
shudder_heading_variance = 1;

lh_grid = zeros(128, 80);
coords_x = 10 * cumsum(ones(128, 1));
coords_y = 10 * cumsum(ones(80, 1));

for k = plot_list
    
    lh_grid = zeros(128, 80);

    [ sweeps, shudders ] = smoothAndDisect(sojourns(k));
    
%     % Draw sojourn and overlay sweeps and shudders
%     drawSojourn(sojourns(k));
%     for ii = 1:length(sweeps)
%         x = cellfun(@(x) x(1), sweeps(ii).state);
%         y = cellfun(@(x) x(2), sweeps(ii).state);
%         plot(x, y, '-r', 'LineWidth', 2);
%     end
%     for ii = 1:length(shudders)
%         plot(shudders(ii).x, shudders(ii).y, '-g', 'LineWidth', 2);
%     end
    
%     % Plot velocity
%     figure, hold on, ylim([0, 5]);
%     for ii = 1:length(shudders)
%         plot(shudders(ii).t, shudders(ii).v);
%     end
%     for ii = 1:length(sweeps)
%         plot(sweeps(ii).t, sweeps(ii).v);
%     end
%     plot([min(sojourns(k).t), max(sojourns(k).t)], [0.25, 0.25], 'k-')
%     plot([min(sojourns(k).t), max(sojourns(k).t)], [0.5, 0.5], 'k-')
    
    for ii = 1:length(sweeps)
        
        % Headings
        sweep_vector = sweeps(ii).state{end}(1:2) - sweeps(ii).state{1}(1:2);
        [avg_heading, distance_moved] = cart2pol(sweep_vector(1), sweep_vector(2));
        init_target_vector = click_locs(k+1, :)' - sweeps(ii).state{1}(1:2);
        [init_tgt_bearing, init_tgt_distance] = cart2pol(init_target_vector(1), init_target_vector(2));
        avg_rel_heading = avg_heading - init_tgt_bearing;
        avg_rel_heading(avg_rel_heading>pi)=avg_rel_heading(avg_rel_heading>pi)-2*pi;
        avg_rel_heading(avg_rel_heading<-pi)=avg_rel_heading(avg_rel_heading<-pi)+2*pi;
        list_sweep_avg_rel_heading = [list_sweep_avg_rel_heading; avg_rel_heading];
        
        % End locations
        end_loc = sweeps(ii).state{end}(1:2);
        rel_end_loc = end_loc - click_locs(k+1, :)';
        list_sweep_rel_end_locs = [list_sweep_rel_end_locs; rel_end_loc'];
        
        
%         % Likelihoods
%         for xx = 1:128
%             for yy = 1:80
%                 targ_pos = [coords_x(xx); coords_y(yy)];
%                 targ_vector = targ_pos - sweeps(ii).state{1}(1:2);
%                 [targ_bng, targ_rng] = cart2pol(targ_vector(1), targ_vector(2));
%                 if targ_bng-avg_heading>pi, targ_bng=targ_bng-2*pi; end
%                 if targ_bng-avg_heading<-pi, targ_bng=targ_bng+2*pi; end
%                 
%                 lh_grid(xx, yy) = lh_grid(xx, yy) + log( normpdf(avg_heading, targ_bng, sqrt(sweep_avg_heading_variance)) );
%                 
%                 lh_grid(xx, yy) = lh_grid(xx, yy) + log( mvnpdf(sweeps(ii).state{end}(1:2)', targ_pos', sweep_rel_end_covar*ones(1,2)) );
%                 
%             end
%         end
        
        
        % Continuous speeds and bearings
        x = cellfun(@(x) x(1), sweeps(ii).state);
        y = cellfun(@(x) x(2), sweeps(ii).state);
        xdot = cellfun(@(x) x(3), sweeps(ii).state);
        ydot = cellfun(@(x) x(4), sweeps(ii).state);
        for jj = 2:length(sweeps(ii).t)
            
            [heading, speed] = cart2pol(xdot(1), ydot(2));
            
            target_vector = click_locs(k+1, :)' - [x(jj); y(jj)];
            [tgt_bearing, tgt_distance] = cart2pol(target_vector(1), target_vector(2));
            
            rel_bng = heading - tgt_bearing;
            rel_bng(rel_bng>pi)=rel_bng(rel_bng>pi)-2*pi;
            rel_bng(rel_bng<-pi)=rel_bng(rel_bng<-pi)+2*pi;
            
            list_sweep_rel_bng = [list_sweep_rel_bng; rel_bng];
            list_sweep_speed = [list_sweep_speed; speed];
            
        end
        
    end
    
%     figure, contour(coords_x, coords_y, lh_grid'), xlim([0, 1280]), ylim([0, 800]);
    
    for ii = 1:length(shudders)
        for jj = 2:length(shudders(ii).t)
            
            vel = [shudders(ii).x(jj)-shudders(ii).x(jj-1); shudders(ii).y(jj)-shudders(ii).y(jj-1)] / (shudders(ii).t(jj)-shudders(ii).t(jj-1));
            [heading, speed] = cart2pol(vel(1), vel(2));
            
            target_vector = click_locs(k+1, :)' - [shudders(ii).x(jj); shudders(ii).y(jj)];
            [tgt_bearing, tgt_distance] = cart2pol(target_vector(1), target_vector(2));

            rel_bng = heading - tgt_bearing;
            rel_bng(rel_bng>pi)=rel_bng(rel_bng>pi)-2*pi;
            rel_bng(rel_bng<-pi)=rel_bng(rel_bng<-pi)+2*pi;
        
            list_shudders_rel_bng = [list_shudders_rel_bng; rel_bng];
            list_shudders_speed = [list_shudders_speed; speed];
            
%             % Likelihoods
%             for xx = 1:128
%                 for yy = 1:80
% 
%                     target_vector = [coords_x(xx); coords_y(yy)] - [shudders(ii).x(jj); shudders(ii).y(jj)];
%                     [tgt_bearing, tgt_distance] = cart2pol(target_vector(1), target_vector(2));
%                     
%                     if tgt_bearing-heading>pi, tgt_bearing=tgt_bearing-2*pi; end
%                     if tgt_bearing-heading<-pi, tgt_bearing=tgt_bearing+2*pi; end
%                     
%                     lh_grid(xx, yy) = lh_grid(xx, yy) + log( normpdf(heading, tgt_bearing, sqrt(shudder_heading_variance)) );
%                     
%                 end
%             end
            
        end
    end
    
%     figure, hold on, contour(coords_x, coords_y, lh_grid'), xlim([0, 1280]), ylim([0, 800]);
%     [xx, yy] = find(lh_grid==max(lh_grid(:)));
%     plot(coords_x(xx), coords_y(yy), 'ok', 'markersize', 5);
        
end

figure, hist(list_sweep_avg_rel_heading, 100), xlim([-3.5, 3.5]);
figure, plot(list_sweep_rel_end_locs(:, 1), list_sweep_rel_end_locs(:, 2), 'x')

list_sweep_rel_end_dists = sqrt( sum( list_sweep_rel_end_locs.^2, 2) );
figure, hist(list_sweep_rel_end_dists, 100);

figure, hist(list_shudders_rel_bng, 100), xlim([-3.5, 3.5]);
figure, hist(list_shudders_speed, 100);

figure, hist(list_sweep_rel_bng, 100), xlim([-3.5, 3.5]);
figure, hist(list_sweep_speed, 100);







