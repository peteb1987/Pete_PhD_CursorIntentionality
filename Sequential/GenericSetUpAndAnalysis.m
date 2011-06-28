function [  ] = GenericSetUpAndAnalysis(track, click_times, click_locs)
%GENERICSETUPANDANALYSIS Set up figures, call inference algorithms, analyse
%results, etc.

global CONSTANTS;
global FLAGS;

% Flags
FLAGS.PLOT = false;

% Constants
CONSTANTS.DUMMY_SPACING = 100;
CONSTANTS.SLOWDOWN = 1;

if FLAGS.PLOT
    % Draw figure
    handles.fig = figure; hold on;
    set(gca, 'DataAspectRatio', [1 1 1]);
    xlim([0, 1280]); ylim([0, 800]);
    xlabel('x (pixels)'); ylabel('y (pixels)');
    handles.dummy = [];
    handles.correct = [];
    handles.chosen = [];
    handles.plot = [];
else
    handles = [];
end

%%%%%

% SeqIntention_Nearest(track, click_times, click_locs, handles);
% SeqIntention_Drift(track, click_times, click_locs, handles);
% SeqIntention_PiecewiseDrift(track, click_times, click_locs, handles);
% SeqIntention_Bearing(track, click_times, click_locs, handles);
SeqIntention_Composite(track, click_times, click_locs, handles);

%%%%%

end

