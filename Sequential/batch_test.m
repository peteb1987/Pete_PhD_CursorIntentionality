% Base script for batch testing cursor intentionality demonstrator

clup;
dbstop if error;

% Select input
filename = '14Mouse.txt';

% Load and pre-process data
[track, click_times, click_locs] = PreProcess( filename );

% Batch test
global test_par;
lambda_range = 0;0.001:0.001:0.01;
buffer_range = [10:10:90 100:100:1500];
results = zeros(length(buffer_range), length(lambda_range));
for ii = 1:length(buffer_range)
    for jj = 1:length(lambda_range)
        test_par.BUFFER_LENGTH = buffer_range(ii);
        test_par.LAMBDA = lambda_range(jj);

        disp(['testing lambda=' num2str(test_par.LAMBDA) ', buffer length ' num2str(test_par.BUFFER_LENGTH)]);
        
        % Run Processing Function
        results(ii, jj) = GenericSetUpAndAnalysis(track, click_times, click_locs);
        
    end
end

[best_ii, best_jj] = find(results==max(results(:)),1);

buffer_range(best_ii)
lambda_range(best_jj)