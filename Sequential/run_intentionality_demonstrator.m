% Base script for cursor intentionality demonstrator

clup;
dbstop if error;

% Select input
filename = '21Mouse.txt';

% Load and pre-process data
[track, click_times, click_locs] = PreProcess( filename );

% Run Processing Function
SeqIntention_Nearest(track, click_times, click_locs);