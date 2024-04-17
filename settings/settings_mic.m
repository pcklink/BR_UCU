% ================================
% settings_def
% ================================

% This is the default and annotated settings file
% it will be loaded if nu explicit settings file is specified

% Best practice is to copy this file, rename it and adapt it for you experiment
% e.g., settings_NO.m, settings_NZ.m, settings_BA.m

% -------------------------------
%% Hardware ----
% -------------------------------
% monitor ---
monitor.gamma = 1; %2.2; % used for linearizaion of contrast, measured by CP [DO NOT CHANGE]
monitor.distance = 690; % mm distance to screen
monitor.fliphorizontal = true; % mirror the video buffer to account for stereoscope mirrors
monitor.stereomode = 4; % 4 = uncrossed screen halves / 5 = crossed screen halves [CHECK THIS!]
monitor.maxpenwidth = 7; % Graphics card limitation, you can try ti increase, but may get errors
monitor.DebugMode = 'CKHOME';% Debug mode allows subscreen stim display
% set this to 'NoDebug' when running the experiments
% NoDebug / UU / CKHOME / CKNIN

% eyetracker ---
eyetracker.do = false; % using an eyetracker or not
eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
eyetracker.calibrate = true; % calibration as part of experiment (alternative is to do it separately
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % path to the eyetracker toolbox

% sound ---
sound.recordmic = true; % necessary for verbal reports
sound.startbeep = true; % you might want to use this as a start marker on the recorded track
sound.mic.maxsec = []; % infinite if empty
sound.mic.device = 6; % auto if empty, only necessary if multiple are present
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
%% prestimulus adapt/cue (can be omitted) --
prestim(1).type = 'grating'; % stimulus type
prestim(1).attentiontype = 'exogenous'; % exogenous/endogenous
prestim(1).sf = 2; % spatial frequency in cycles/deg
prestim(1).contrast = 0.1; % contrast 0-1
prestim(1).orient = [45 -45]; % degrees clockwise [grating1 grating2]
prestim(1).driftspeed = [0 0]; % deg/s positive is rightward [grating1 grating2]
%NB! ideally pick a combi of spatial freqency and speed for which one period of the
% grating should be moved an integer number of frames at 60 Hz [60/(sf*speed) = integer]
prestim(1).transient.contrastincr = 0.6; % change in contrast for exogenous attention
prestim(1).transient.stim = 1; % which stim gets the transient
prestim(1).transient.duration = 0.200; % how long is the contrast change
prestim(1).transient.timewindow = [-2 -1]; % when can it happen relative to end of prestim [max min]
prestim(1).instruct = []; % show an instruction before the trial starts (nothing if empty)
prestim(1).quest = 'Left or Right'; % question text after the prestim (ke-press left/right is logged)

prestim(2).type = 'dots'; % stimulus type
prestim(2).attentiontype = 'exogenous'; % exogenous/endogenous
prestim(2).dotsize = 0.25; % deg (there may be GPU based limitations)
prestim(2).dotdensity = 3; % dots/deg2
prestim(2).dotlifetime = 10; % dot life in # frames ([] is unlimited)
prestim(2).contrast = 0.2; % contrast of the dots
prestim(2).contrastbin = true; % if true all dots have either the min or max value of the contrast
prestim(2).color = []; % leave empty for luminance contrast
prestim(2).driftspeed = [-1.5 0; 1.5 0]; % deg/s positive is rightward [dots1 dots2]
prestim(2).transient.contrastincr = 0.6; % change in contrast for exogenous attention
prestim(2).transient.stim = 1; % which stim gets the transient
prestim(2).transient.duration = 0.200; % how long is the contrast change
prestim(2).transient.timewindow = [-2 -1]; % when can it happen relative to end of prestim [max min]
prestim(2).instruct = []; % show an instruction before the trial starts (nothing if empty)
prestim(2).quest = 'Left or Right'; % question text after the prestim (ke-press left/right is logged)

% for endogenous grating prestim
% show superimposed drifting gratings that change in orientation over time
prestim(3).type = 'grating'; % stimulus type
prestim(3).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(3).sf = 2; % spatial frequency in cycles/deg
prestim(3).contrast = 0.2; % contrast 0-1
prestim(3).orientations = [-45 -45; 45 45]; % degrees clockwise [start_stim1 end_stim1; start_stim2 end_stim2]
prestim(3).driftspeed = [-1.5 1.5]; % deg/s positive is rightward [grating1 grating2]
prestim(3).trackstim = 1; % which stimulus should be tracked
prestim(3).change.degpersec = 2; % deg/f (choose integer frame counts)
prestim(3).change.interval = [0.5 1.5]; % how long can a period of same direction change last [min max]
prestim(3).change.prob = 0.1; % probability of direction change
prestim(3).instruct = 'Attend LEFT\nkey to start'; % show an instruction before the trial starts (nothing if empty)
prestim(3).quest = 'Left\nor\nRight?';  % question text after the prestim (ke-press left/right is logged)
prestim(3).durations = [1 3 1]; %[static rotating static] in seconds
% NB! make sure these durations add up to trialtime.PrestimT

% for endogenous dots prestim
% show transparent moving dots that change in direction over time
prestim(4).type = 'dots';  % stimulus type
prestim(4).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(4).dotsize = 0.25; % deg (there may be GPU based limitations)
prestim(4).dotdensity = 3; % dots/deg2
prestim(4).dotlifetime = 10; % dot life in # frames ([] is unlimited)
prestim(4).contrast = 0.8; % contrast 0-1
prestim(4).contrastbin = true; % if true all dots have either the min or max value of the contrast
prestim(4).color = [1 0 0;0 1 0]; % leave empty for luminance contrast [R1 G1 B1; R2 G2 B2]
prestim(4).orientations = [-45 -45; 45 45]; % drift angle degrees clockwise [start_stim1 end_stim1; start_stim2 end_stim2]
% orientations is not used for dots
prestim(4).driftspeed = [-1.5 0; 1.5 0]; % deg/s positive is rightward/down [H1 V1;H2 V2]
prestim(4).trackstim = 1; % which stimulus should be tracked
prestim(4).change.degpersec = 2; % deg/sec (choose integer frame counts
prestim(4).change.interval = [0.5 1.5]; % how long can a period of same direction change last [min max]
prestim(4).change.prob = 0.05; % probability of direction change
prestim(4).instruct = 'Attend LEFT\nkey to start'; % question text after the prestim (ke-press left/right is logged)
prestim(4).quest = 'Left\nor\nRight?'; % [static rotating static] in seconds
prestim(4).durations = [1 3 1]; %[static rotating static]
% NB! make sure these durations add up to trialtime.PrestimT

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

stim(3).type = 'dots'; % stimulus type
stim(3).dotsize = 0.25; % deg
stim(3).dotdensity = 3; % dots/deg2
stim(3).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(3).contrast = 1;  % contrast 0-1
stim(3).contrastbin = true; % if true, only use highest and lowest
stim(3).color = []; % leave empty for luminance contrast
stim(3).driftspeed = [1.5 0]; % [h v] deg/s positive is rightward/down

stim(4).type = 'dots'; % stimulus type
stim(4).dotsize = 0.25; % deg
stim(4).dotdensity = 3; % dots/deg2
stim(4).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(4).contrast = 1;  % contrast 0-1
stim(4).contrastbin = true; % if true, only use highest and lowest
stim(4).color = []; % leave empty for luminance contrast
stim(4).driftspeed = [-1.5 0]; % [h v] deg/s positive is rightward/down

stim(5).type = 'image'; % load a bitmap
stim(5).image = 'image-01.bmp'; % should be in the images folder
stim(5).overlay.type = 'dots'; % overlay type of stimulus
stim(5).overlay.dotsize = 0.25; % deg
stim(5).overlay.dotdensity = 3; % dots/deg2
stim(5).overlay.dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(5).overlay.contrast = 1;  % contrast 0-1
stim(5).overlay.contrastbin = true; % if true all dots have either the min or max value of the contrast
stim(5).overlay.color = []; % [R G B] if empty, contrast is used
stim(5).overlay.opacity = 0.5; % transparancy 0-1
stim(5).overlay.driftspeed = [1.5 0]; % [h v] deg/s positive is rightward/down

stim(6).type = 'image'; % load a bitmap
stim(6).image = 'image-02.bmp'; % should be in the images folder
stim(6).overlay.type = 'lines';  % overlay type of stimulus
stim(6).overlay.linewidth = 0.1; % deg
stim(6).overlay.linedensity = 2; % lines/deg
stim(6).overlay.color = [0 0 0]; % [R G B] if empty, contrast is used
stim(6).overlay.opacity = 0.5; % transparancy 0-1
stim(6).overlay.orientation = 'vertical'; % horizontal/vertical
stim(6).overlay.driftspeed = 1.5; % deg/s positive is rightward/down

% -------------------------------
%% Experiment structure ----
% -------------------------------

% trials --
trialtype(1).stimsize = [4 4]; % wchich stimuli [left right]
trialtype(1).prestim = []; % which prestim
trialtype(1).eye(1).stim = 1; % stim for eye1
trialtype(1).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(1).time.FixT = 1; %s time without stimus / with alignment
trialtype(1).time.PrestimT = []; %s leave empty or set zero for none
trialtype(1).time.PrestimGapT = 1; %s between prestim and stim
trialtype(1).time.StimT = 5; %s stimulus duration
trialtype(1).time.ITIT  = 1; %s intertrial interval
trialtype(1).replay = false; % replay trial?
trialtype(1).replayminmax = [3 6]; % min/max epoch duration
trialtype(1).poststimquest = []; % question text after the prestim (ke-press left/right is logged)
% leave empty for none

% blocks --
block(1).reportmode = 'key'; % key/verbal/none
block(1).trials = 1; % which trialtypes in the block
block(1).randomizetrials = false; % randomize in block
block(1).repeattrials = 3; % repeat trial sets this many times
block(1).instruction = ['Some text to\n' ...
    'tell people what\n to do.\n\nPress key to start']; % replace with text you want

% expt --
expt.blockorder = []; % set for a specific order, empty means 1:end
expt.randomizeblocks = true; % overrules order
expt.blockrepeats = 1; % randomization only within set of repeats
expt.thanktext = 'That was it\nThank you!';
expt.thankdur = 2; % seconds
