function [ cp, v ] = detectChangePoints( kf_mean )
% Detect change points in a track

x_est = cellfun(@(x) x(1), kf_mean);
y_est = cellfun(@(x) x(2), kf_mean);
xdot_est = cellfun(@(x) x(3), kf_mean);
ydot_est = cellfun(@(x) x(4), kf_mean);

[b, v] = cart2pol(xdot_est, ydot_est);

cp = 1;
primed = true;
for ii = 3:length(v)
    if v(ii) > 0.2
        primed = true;
    end
    if (primed) && (v(ii)>v(ii-1)) && (v(ii-1)<v(ii-2))
        cp = [cp; ii];
        primed = false;
%     elseif (primed) && (abs(b(ii)-b(ii-1)) > pi/4)
%         cp = [cp; ii];
%         primed = false;
%     end
end

end

