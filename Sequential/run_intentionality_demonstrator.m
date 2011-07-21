% Base script for cursor intentionality demonstrator

clup;
dbstop if error;

% Select input
filename = '1Mouse.txt';
alg = 'MRD';

% Load and pre-process data
[track, click_times, click_locs] = PreProcess( filename );

% Run Processing Function
[correct, mov] = GenericSetUpAndAnalysis(track, click_times, click_locs);

disp(correct);

if ~isempty(mov)
    aviObj = VideoWriter([filename(1:end-4) alg]);
    open(aviObj);
    writeVideo(aviObj,mov);
    close(aviObj);
end