function [ sweeps, v ] = detectSweeps( kf_mean, track )
% Detect sweep sections in a track

x_est = cellfun(@(x) x(1), kf_mean);
y_est = cellfun(@(x) x(2), kf_mean);
xdot_est = cellfun(@(x) x(3), kf_mean);
ydot_est = cellfun(@(x) x(4), kf_mean);

[~, v] = cart2pol(xdot_est, ydot_est);


dv = 0.1;

sweeps = [];

start = 1;
stop = 0;

min_v = inf;
max_v = 0;
min_ii = 1;
max_ii = 1;
rising = true;

for ii = 2:length(v)
    if v(ii)>max_v
        max_v = v(ii);
        max_ii = ii;
    elseif v(ii)<min_v
        min_v = v(ii);
        min_ii = ii;
    end
    
    if rising && v(ii)<(max_v-dv)
        rising = false;
        max_v = v(ii);
        max_ii = ii;
        min_v = v(ii);
        min_ii = ii;
    end
    
    if (~rising && v(ii)>(min_v+dv)) || (ii==length(v))
        
        % End sweep
        stop = min_ii-1;
        if (ii==length(v))
            stop = ii;
        end
        
        sw = struct('start', start, 'stop', stop, 'v_init', [xdot_est(start); ydot_est(start)]);
        sweeps = [sweeps; sw];
        
        % Start new sweep
        start = min_ii;
        rising = true;
        max_v = v(ii);
        max_ii = ii;
        min_v = v(ii);
        min_ii = ii;
    end
   
    
end





% vl = 0.25;
% vu = 1;
% 
% sweeps = [];
% shudders = [];
% 
% start = 1;
% stop = 0;
% 
% in = false;
% big = false;
% for ii = 2:length(v)
%     if ~in && v(ii)>vl
%         
%         % Start sweep
%         start = ii;
%         in = true;
%         
%         % save shudder
%         if start - stop > 1
%             sh = struct('start', stop + 1, 'stop', start-1);
%             shudders = [shudders; sh];
%         end
%         
%     elseif in && v(ii)<vl
%         % Stop sweep
%         stop = ii-1;
%         in = false;
%         
%         if stop - start > 1
%             sw = struct('start', start, 'stop', stop, 'v_init', [xdot_est(start); ydot_est(start)], 'big', big);
%             sweeps = [sweeps; sw];
%         end
%         
%         big = false;
%         
%     elseif in && ~big && v(ii)>vu
%         % Big sweep
%         big = true;
%         
%     elseif in && big && v(ii-1)<vu && v(ii)>v(ii-1) && v(ii-2)>v(ii-1)
%         % Restart sweep
%         stop = ii-1;
%         
%         if stop - start > 1
%             sw = struct('start', start, 'stop', stop, 'v_init', [xdot_est(start); ydot_est(stop)], 'big', big);
%             sweeps = [sweeps; sw];
%         end
%         
%         start = ii;
%         big = false;
% 
%     end
%     
% end


% fast = false(size(v));
% for ii = 1:length(v)
%     if v(ii) > 0.25
%         fast(ii) = true;
%     end
% end
% 
% in = false;
% for ii = 1:length(fast)
%     if fast(ii) && ~in
%         start = ii;
%         in = true;
%         
%     elseif ~fast(ii) && in
%         stop = ii-1;
%         in = false;
%         
% %         if track.t(stop)-track.t(start) > 
%         if stop - start > 1
%             sweeps = [sweeps; {[start, stop]}];
%         end
%         
%     end
% end
        

end
