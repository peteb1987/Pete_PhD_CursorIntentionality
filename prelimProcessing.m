function [track, sojourns, click_times, click_locs] = prelimProcessing(filename)

% Data input
fid = fopen(filename);
data = textscan(fid, '%u %u %u %s', 'delimiter', ',');

track = struct('x', [], 'y', [], 't', []);

x = double(data{1});
y = double(data{2});
timestamp = double(data{3});
events = [data{4}; {''}];

% Offset time
t0 = timestamp(1);
t = timestamp - t0;
N = length(t);

% There's a lot of concurrent timestamps! For now, lets just delete the
% data corresponding to the second one (unless its a click)
for ii = N:-1:2
    if t(ii) == t(ii-1)
        ind_del = ii;
        if strcmp(events{ind_del}, 'Click')
            ind_del = ind_del - 1;
        end
        x(ind_del)=[];
        y(ind_del)=[];
        t(ind_del)=[];
        events(ind_del)=[];
        N = N - 1;
    end
end

% Identify click times and locations
click_times = [];
click_locs = [];
for ii = N:-1:1
    if strcmp(events{ii}, 'Click')
        
        % Add to list
        click_times = [t(ii);click_times];
        click_locs = [[x(ii-1), y(ii-1)]; click_locs];
        
        % Remove blank click rows
        x(ii)=[];
        y(ii)=[];
        t(ii)=[];
        events(ii)=[];
        N = N - 1;
        
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