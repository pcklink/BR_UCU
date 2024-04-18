% ================================
% settings_def
% ================================

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

%% stimulus --
stim(1).type = 'grating'; % stimulus type
stim(1).sf = 2; % spatial frequency in cycles/deg
stim(1).contrast = 1; % contrast 0-1
stim(1).orient = 60; % degrees clockwise
stim(1).driftspeed = 1.5; % deg/s 

stim(2).type = 'grating'; % stimulus type
stim(2).sf = 2; % spatial frequency in cycles/deg
stim(2).contrast = 1; % contrast 0-1
stim(2).orient = -60; % degrees clockwise
stim(2).driftspeed = -1.5; % deg/s 

% -------------------------------
%% Experiment structure 

% trials: simulated rivalry 1
trialtype(1).stimsize = [2 2]; % which stimuli [left right]
trialtype(1).prestim = 2; % whic prestim
trialtype(1).eye(1).stim = 1; % stim for eye1
trialtype(1).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(1).time.FixT = 0; %s time without stimus / with alignment
trialtype(1).time.PrestimT = []; %s leave empty or set zero for none
trialtype(1).time.PrestimGapT = 0; %s between prestim and stim
trialtype(1).time.StimT = 30; %s stimulus duration
trialtype(1).time.ITIT  = 0; %s intertrial interval
trialtype(1).replay = true; % replay trial?
trialtype(1).replayminmax = [1 4]; % min/max epoch duration
trialtype(1).poststimquest = []; % question text after the prestim (ke-press left/right is logged)
% leave empty for none

% trials: real rivalry  
trialtype(2) = trialtype(1); % inititate copy, then change necessary things
trialtype(2).prestim = 2; % whic prestim
trialtype(2).eye(1).stim = 1; % stim for eye1
trialtype(2).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(2).time.FixT = 0; %s time without stimus / with alignment
trialtype(2).time.PrestimT = []; %s leave empty or set zero for none
trialtype(2).time.PrestimGapT = 0; %s between prestim and stim
trialtype(2).time.StimT = 120; %s stimulus duration
trialtype(2).time.ITIT  = 0; %s intertrial interval
trialtype(2).replay = false; % replay trial?
trialtype(2).replayminmax = [1 4]; % min/max epoch duration

%% 
% block: key report 
block(1).reportmode = 'key'; % key/verbal/none
block(1).trials = [1, 2]; % which trialtypes in the block
% block(1).trials = [1, 2, 2, 1, 1, 2, 2, 1]; % which trialtypes in the block
block(1).randomizetrials = false; % randomize in block
block(1).repeattrials = 1; % repeat trial sets this many times
block(1).instruction = ['Click left/right to report\n' ...
    'in which direction\n the lines are moving.\n\nPress key to start']; % replace with text you want
    
%%

% block: verbal report 
block(2).reportmode = 'verbal'; % key/verbal/none
block(2).trials = [1, 2, 2, 1, 1, 2, 2, 1]; % which trialtypes in the block
block(2).randomizetrials = false; % randomize in block
block(2).repeattrials = 1; % repeat trial sets this many times
block(2).instruction = ['Say "left"/"right" to report\n' ...
    'in which direction\n the lines are moving.\n\nPress key to start']; % replace with text you want

%%

% block: no report 
block(3).reportmode = 'none'; % key/verbal/none
block(3).trials = [1, 2, 2, 1, 1, 2, 2, 1]; % which trialtypes in the block
block(3).randomizetrials = false; % randomize in block
block(3).repeattrials = 1; % repeat trial sets this many times
block(3).instruction = ['You do not have to report anything. \n' ...
    'Just pay attention. \n\nPress key to start']; % replace with text you want

%%

% expt --
expt.blockorder = [1]; % set for a specific order, empty means 1:end
expt.randomizeblocks = false; % overrules order
expt.blockrepeats = 1; % randomization only within set of repeats
expt.thanktext = 'That was it.\nThank you for participating!';
expt.thankdur = 3; % seconds
