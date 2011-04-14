function [ sweeps, v ] = detectSweeps( kf_mean, track )
% Detect sweep sections in a track

x_est = cellfun(@(x) x(1), kf_mean);
y_est = cellfun(@(x) x(2), kf_mean);
xdot_est = cellfun(@(x) x(3), kf_mean);
ydot_est = cellfun(@(x) x(4), kf_mean);

[~, v] = cart2pol(xdot_est, ydot_est);

vl = 0.25;
vu = 1;

sweeps = cell(0,1);

in = false;
big = false;
for ii = 2:length(v)
    if ~in && v(ii)>vl
        start = ii;
        in = true;
        
    elseif in && v(ii)<vl
        stop = ii-1;
        in = false;
        big = false;
        
        if stop - start > 1
            sweeps = [sweeps; {[start, stop]}];
        end
        
    elseif in && ~big && v(ii)>vu
        big = true;
        
    elseif in && big && v(ii-1)<vu && v(ii)>v(ii-1) && v(ii-2)>v(ii-1)
        stop = ii-1;
        
        if stop - start > 1
            sweeps = [sweeps; {[start, stop]}];
        end
        
        start = ii;
        big = false;

    end
    
end


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
