% settings_def

%% Hardware ----
% monitor ---
monitor.gamma = 2.2; % used for linearizaion of contrast
monitor.distance = 690; % mm
monitor.fliphorizontal = true; % mirror the video buffer to account for mirrors
monitor.stereomode = 4; % 4 uncrossed screen halves / 5 crossed screen halves
monitor.maxpenwidth = 7;

% eyetracker ---
eyetracker.do = false; % using an eyetracker or not
eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
eyetracker.calibrate = true; % calibration as part of experiment
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % check this

% sound ---
sound.recordmic = false; % necessary for verbal reports
sound.startbeep = false; % you might want to use this as a start marker
sound.mic.maxsec = []; % infinite if empty (code a stop)
sound.mic.device = []; % auto if empty
sound.beepfile = 'beep.wav';

% keys ---
keys.esc = 'escape';
keys.resp = {'Left','Right'};

% log location ---
log.fld = 'default_log';

%% Stimuli ----
% background --
bg.color = [0.5 0.5 0.5];
bg.textcolor = [1 1 1];
% bg.align.Frame.Size = stimulus size + .5; % in deg (define after stim)
bg.align.Frame.Type = 0; % 0 = oval, 1 = rectangle
bg.align.Frame.PenWidth = .2; % in deg
bg.align.Frame.CrossLength = [6 6]; % in deg
bg.align.Frame.Color = [0 0 0]; % [R G B] range: 0-1
bg.align.AlignCircles.draw = true; % if false these are not drawn
bg.align.AlignCircles.n = 150; % number of circles drawn in full window
bg.align.AlignCircles.ColorRange = [0.3 0.7]; % [R G B] range: 0-1
bg.align.AlignCircles.SizeRange = [.5 2]; % in deg

fix.size = 0.2; % dva diameter
fix.color = [1 0 0];

% ---------------------------------------------
% prestimulus adapt/cue (can be omitted) --
prestim(1).type = 'grating';
prestim(1).attentiontype = 'exogenous'; % exogenous/endogenous
prestim(1).sf = 2; % spatial frequency in cycles/deg
prestim(1).contrast = 0.8; % contrast 0-1
prestim(1).orient = [0 0]; % degrees clockwise
prestim(1).driftspeed = [-1 1]; % deg/s positive is rightward
%NB! pick a combi of spatial freqency and speed for which one period of the
% grating should be moved an integer number of frames at 60 Hz 
% [60/(sf*speed) = integer]
prestim(1).transient.contrastincr = 0.2;
prestim(1).transient.eye = 'left';
prestim(1).transient.duration = 0.500;
prestim(1).transient.timewindow = [-2 -0.1]; % relative to end of prestim

prestim(2).type = 'dots';
prestim(2).attentiontype = 'exogenous'; % exogenous/endogenous
prestim(2).dotsize = 0.05; % deg (there may be GPU based limitations)
prestim(2).dotdensity = 3; % dots/deg2
prestim(2).contrast = 0.8;
prestim(2).contrastbin = true;
prestim(2).color = []; % leave empty for luminance contrast
prestim(2).driftspeed = [-1 1]; % deg/s positive is rightward
prestim(2).transient.contrastincr = 0.2;
prestim(2).transient.eye = 'right';
prestim(2).transient.duration = 0.500; % pick an integer number of frames in s
prestim(2).transient.timewindow = [-2 -0.1]; % relative to end of prestim


% for endogenous grating prestim
% show superimposed drifting gratings that change in orientation over time
prestim(3).type = 'grating';
prestim(3).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(3).sf = 2; % spatial frequency in cycles/deg
prestim(3).contrast = 0.8; % contrast 0-1
prestim(3).orientations = [280 80; 80 280]; % degrees clockwise [start end]
prestim(3).driftspeed = 1; % deg/s positive is rightward
prestim(3).trackstim = 1; % 
prestim(3).change.degpersec = 2/60; % deg/sec (choose integer frame counts
prestim(3).change.interval = [0.5 1.5]; 
prestim(3).change.prob = 0.05;
prestim(3).instruct = 'Attend LEFT\nkey to start';
prestim(3).quest = 'Left\nor\nRight?';
prestim(3).durations = [1 3 1]; %[static rotating static]
% NB! make sure these durations add up to trialtime.PrestimT


% for endogenous dots prestim
% show transparent moving dots that change in direction over time
prestim(4).type = 'dots';
prestim(4).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(4).dotsize = 0.05; % deg (there may be GPU based limitations)
prestim(4).dotdensity = 3; % dots/deg2
prestim(4).contrast = 0.8;
prestim(4).contrastbin = true;
prestim(4).color = []; % leave empty for luminance contrast
prestim(4).orientations = [280 80; 80 280]; % degrees clockwise [start end]
prestim(4).driftspeed = 1; % deg/s positive is rightward
prestim(4).trackstim = 1; % 
prestim(4).change.degpersec = 2/60; % deg/sec (choose integer frame counts
prestim(4).change.interval = [0.5 1.5]; 
prestim(4).change.prob = 0.05;
prestim(4).instruct = 'Attend LEFT\nkey to start';
prestim(4).quest = 'Left\nor\nRight?';
prestim(4).durations = [1 3 1]; %[static rotating static]
% NB! make sure these durations add up to trialtime.PrestimT

% ---------------------------------------------

% stimulus --
stim(1).type = 'grating';
stim(1).sf = 2; % spatial frequency in cycles/deg
stim(1).contrast = 1; % contrast 0-1
stim(1).orient = 45; % degrees clockwise
stim(1).driftspeed = 1.5; % deg/s 

stim(2).type = 'grating';
stim(2).sf = 2; % spatial frequency in cycles/deg
stim(2).contrast = 1; % contrast 0-1
stim(2).orient = -45; % degrees clockwise
stim(2).driftspeed = 1.5; % deg/s 

stim(3).type = 'dots';
stim(3).dotsize = 0.5; % deg
stim(3).dotdensity = 3; % dots/deg2
stim(3).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(3).contrast = 1;
stim(3).contrastbin = true; % if true, only use highest and lowest
stim(3).color = []; % leave empty for luminance contrast
stim(3).driftspeed = [1 0]; % [h v] deg/s positive is rightward/down

stim(4).type = 'dots';
stim(4).dotsize = 0.5; % deg
stim(4).dotdensity = 3; % dots/deg2
stim(4).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(4).contrast = 1;
stim(4).contrastbin = true; % if true, only use highest and lowest
stim(4).color = []; % leave empty for luminance contrast
stim(4).driftspeed = [-1 0]; % [h v] deg/s positive is rightward/down

stim(5).type = 'image';
stim(5).image = 'image-01.bmp'; %should be in the images folder
stim(5).overlay.type = 'dots';
stim(5).overlay.dotsize = 0.1; % deg
stim(5).overlay.dotdensity = 3; % dots/deg2
stim(5).overlay.dotlifetime = 10;
stim(5).overlay.contrast = 1;
stim(5).overlay.contrastbin = true;
stim(5).overlay.color = [];
stim(5).overlay.opacity = 0.5;
stim(5).overlay.driftspeed = [1.5 0]; % [h v] deg/s positive is rightward/down

stim(6).type = 'image';
stim(6).image = 'image-02.bmp';
stim(6).overlay.type = 'lines';
stim(6).overlay.linewidth = 0.1; % deg
stim(6).overlay.linedensity = 2; % lines/deg
stim(6).overlay.color = [0 0 0];
stim(6).overlay.opacity = 0.5;
stim(6).overlay.orientation = 'vertical'; % horizontal/vertical
stim(6).overlay.driftspeed = 1.5; % deg/s positive is rightward/down

%% Experiment structure ----
% timing --
% Choose timing consisten with 60Hz refresh rate
% so multiples of 1/60 s
trialtime.FixT = 1; %s time without stimus / with alignment
trialtime.PrestimT = []; %s leave empty or set zero for none
trialtime.PrestimGapT = 1; %s between prestim and stim
trialtime.StimT = 5; %s stimulus duration
trialtime.ITI = 2; %s leave empty for key-press

% trials --
trialtype(1).stimsize = [4 4];
trialtype(1).prestim = [];
trialtype(1).eye(1).stim = 5;
trialtype(1).eye(2).stim = 6;

% blocks --
block(1).reportmode = 'key'; % key/verbal/none
block(1).trials = 1;
block(1).randomizetrials = false;
block(1).repeattrials = 1;
block(1).instruction = ['Some text to\n' ...
    'tell people what\n to do.\n\nPress key to start']; % replace with text you want

% expt --
expt.blockorder = []; % set for a specific order, empty means 1:end
expt.randomizeblocks = true; % overrules order
expt.blockrepeats = 1; % randomization only within set of repeats
expt.thanktext = 'That was it.\nThank you!';

%% Logging ----
log.fld = 'log';