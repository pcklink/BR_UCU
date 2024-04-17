% ================================
% settings_def
% ================================

% This is the default and annotated settings file
% it will be loaded if nu explicit settings file is specified

% -------------------------------
%% Hardware ----
% -------------------------------
% monitor ---
monitor.gamma = 2.2; % used for linearizaion of contrast, measured by CP [DO NOT CHANGE]
monitor.distance = 690; % mm distance to screen
monitor.fliphorizontal = true; % mirror the video buffer to account for stereoscope mirrors
monitor.stereomode = 4; % 4 = uncrossed screen halves / 5 = crossed screen halves [CHECK THIS!]
monitor.maxpenwidth = 7; % Graphics card limitation, you can try ti increase, but may get errors
monitor.DebugMode = 'NoDebug';% Debug mode allows subscreen stim display
% set this to 'NoDebug' when running the experiments
% NoDebug / UU / CKHOME / CKNIN

% eyetracker ---
eyetracker.do = true; % using an eyetracker or not
eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
eyetracker.calibrate = true; % calibration as part of experiment (alternative is to do it separately
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % path to the eyetracker toolbox

% sound ---
sound.recordmic = true; % necessary for verbal reports
sound.startbeep = true; % you might want to use this as a start marker on the recorded track
sound.mic.maxsec = []; % infinite if empty
sound.mic.device = 5; % auto if empty, only necessary if multiple are present
sound.mic.nchan = 1; % mono or stereo mic
sound.play.device = 0; % auto if empty, only necessary if multiple are present
sound.play.nchan = 2; % mono or stereo 
sound.beepfile = 'beep.wav'; % should be in root folder; plays as marker

% keys ---
keys.esc = 'ESCAPE'; % escapes stops the experiment
keys.resp = {'LeftArrow','RightArrow'}; % use arrow keys for responses

% log location ---
log.fld = 'log'; % base log folder, a subfolder with YYYYMMDD_HHMM start time label wil be created

% -------------------------------
%% Stimuli ----
% -------------------------------

% NB! For our current setup:
% 1 dva is about 45.5 pixels, % 1 s is 60 frames
% drift speed < 1.32 means less than 1pix/fr
% better go a bit higher for smooth motion

% all specified stimuli are prepared by the run code
% so don't specify anything you do not intend to use

% ---------------------------------------------
%% background --
bg.color = [0.5 0.5 0.5]; % [R G B] 0 = black, 1 = white
bg.textcolor = [1 1 1]; % [R G B]
% there is a fame and crosshair around the stimulus to help alignment
bg.align.Frame.Type = 0; % 0 = oval, 1 = rectangle
bg.align.Frame.PenWidth = .2; % in deg
bg.align.Frame.CrossLength = [6 6]; % in deg
bg.align.Frame.Color = [0 0 0]; % [R G B] range: 0-1
% There can be alignment 'bubbles' in the background to help alignment
bg.align.AlignCircles.draw = true; % if false these are not drawn
bg.align.AlignCircles.n = 150; % number of circles drawn in full window
bg.align.AlignCircles.ColorRange = [0.3 0.7]; % [R G B] range: 0-1
bg.align.AlignCircles.SizeRange = [.5 1]; % in deg
bg.align.AlignCircles.OpenArea = [8 8]; % in deg

% fixation dot
fix.size = 0.2; % dva diameter
fix.color = [1 0 0]; % [R G B]

% ---------------------------------------------
% ---------------------------------------------

%% stimulus --
stim(1).type = 'grating'; % stimulus type
stim(1).sf = 2; % spatial frequency in cycles/deg
stim(1).contrast = 1; % contrast 0-1
stim(1).orient = 45; % degrees clockwise
stim(1).driftspeed = 1.5; % deg/s 

stim(2).type = 'grating'; % stimulus type
stim(2).sf = 2; % spatial frequency in cycles/deg
stim(2).contrast = 1; % contrast 0-1
stim(2).orient = -45; % degrees clockwise
stim(2).driftspeed = 1.5; % deg/s

% -------------------------------
%% Experiment structure ----
% -------------------------------

% timing --
% Choose timing consisten with 60Hz refresh rate
% so multiples of 1/60 s
trialtime.FixT = 1; %s time without stimus / with alignment
trialtime.PrestimT = []; %s leave empty or set zero for none
trialtime.PrestimGapT = 0; %s between prestim and stim
trialtime.StimT = 5; %s stimulus duration
trialtime.ITIT  = 0; %s intertrial interval

% simulated rivalry 1
trialtype(1).stimsize = [4 4]; % wchich stimuli [left right]
trialtype(1).prestim = 2; % whic prestim
trialtype(1).eye(1).stim = 1; % stim for eye1
trialtype(1).eye(2).stim = 2; % stim for eye2
trialtype(1).replay = false; % replay trial?
trialtype(1).replayminmax = [3 6]; % min/max epoch duration
trialtype(1).poststimquest = []; % question text after the prestim (ke-press left/right is logged)
% leave empty for none

% simulated rivalry 2
trialtype(2).stimsize = [4 4]; % wchich stimuli [left right]
trialtype(2).prestim = 2; % whic prestim
trialtype(2).eye(1).stim = 2; % stim for eye1
trialtype(2).eye(2).stim = 1; % stim for eye2
trialtype(2).replay = false; % replay trial?
trialtype(2).replayminmax = [3 6]; % min/max epoch duration
trialtype(2).poststimquest = []; % question text after the prestim (ke-press left/right is logged)

%% key press

% key: simulated
block(1).reportmode = 'key'; % key/verbal/none
block(1).trials = [1,2]; % which trialtypes in the block
block(1).randomizetrials = false; % randomize in block
block(1).repeattrials = 6; % repeat trial sets this many times
block(1).instruction = ['hehe\n' ...
    'tell people what\n to do.\n\nPress key to start']; % replace with text you want

% key: real
block(2).reportmode = 'key'; % key/verbal/none
block(2).trials = 1; % which trialtypes in the block
block(2).randomizetrials = false; % randomize in block
block(2).repeattrials = 24; % repeat trial sets this many times
% block(2).instruction = ['Press key\n' ...
    % 'tell people what\n to do.\n\nPress key to start']; % replace with text you want

%% verbal 

% block(3).reportmode = 'verbal'; % key/verbal/none
% block(3).trials = [1 2]; % which trialtypes in the block
% block(3).randomizetrials = false; % randomize in block
% block(3).repeattrials = 10; % repeat trial sets this many times
% block(3).instruction = ['Some text to\n' ...
    % 'tell people what\n to do.\n\nPress key to start']; % replace with text you want

%% no report

% block(4).reportmode = 'none'; % key/verbal/none
% block(4).trials = 1; % which trialtypes in the block
% block(4).randomizetrials = false; % randomize in block
% block(4).repeattrials = 10; % repeat trial sets this many times
% block(4).instruction = ['Some text to\n' ...
    % 'tell people what\n to do.\n\nPress key to start']; % replace with text you want

% expt --
expt.blockorder = []; % set for a specific order, empty means 1:end
expt.randomizeblocks = true; % overrules order
expt.blockrepeats = 1; % randomization only within set of repeats
expt.thanktext = 'That is it!\nThank you for your participation!';
expt.thankdur = 3; % seconds
