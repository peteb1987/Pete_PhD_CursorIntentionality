function [track, sojourns, click_times, click_locs] = prelimProcessing_SimonsData(filename)
% Input cursor data from file and clean it up.

% Data input
load tracedata.mat

track = struct('x', [], 'y', [], 't', []);

x = data(:,2);
y = data(:,3);
timestamp = data(:,4);
events = data(:,1);

% Offset time
t0 = timestamp(1);
t = timestamp - t0;
N = length(t);

% Identify click times and locations
click_times = [];
click_locs = [];
for ii = N-1:-1:1
    if events(ii)~=events(ii+1)
        
        % Add to list
        click_times = [t(ii);click_times];
        click_locs = [[x(ii), y(ii)]; click_locs];
        
    end
end

track.x = x;
track.y = y;
track.t = t;
track.N = N;
track.events = events;

% Add a click to the start and end of the data set
click_times = [0; click_times; max(t)+1];
click_locs = [[0 0]; click_locs; [0 0]];

% K shall be the number of sojourns (inter-click periods)
K = length(click_times) - 1;

% Create a structure array of sojourns
sojourns = repmat(struct('x', [], 'y', [], 't', [], 'events', [], 'N', []), K, 1);
for k = 1:K
    ind = (t>=click_times(k)) & (t<=click_times(k+1));
    start = find(ind, 1, 'first');
    stop = find(ind, 1, 'last');
    sojourns(k).t = t(start:stop);
    sojourns(k).x = x(start:stop);
    sojourns(k).y = y(start:stop);
    sojourns(k).events = events(start:stop);
    sojourns(k).N = length(sojourns(k).t);
end

end