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
monitor.gamma = 2.2; % used for linearizaion of contrast, measured by CP [DO NOT CHANGE]
monitor.distance = 690; % mm distance to screen
monitor.fliphorizontal = true; % mirror the video buffer to account for stereoscope mirrors
monitor.stereomode = 4; % 4 = uncrossed screen halves / 5 = crossed screen halves [CHECK THIS!]
monitor.maxpenwidth = 7; % Graphics card limitation, you can try to increase, but may get errors

% eyetracker ---
eyetracker.do = true; % using an eyetracker or not
eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
eyetracker.calibrate = true; % calibration as part of experiment (alternative is to do it separately
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % path to the eyetracker toolbox

% sound ---
sound.recordmic = false; % necessary for verbal reports
sound.startbeep = false; % you might want to use this as a start marker on the recorded track
sound.mic.maxsec = []; % infinite if empty
sound.mic.device = []; % auto if empty, only necessary if multiple are present
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
prestim(1).type = 'dots'; % stimulus type
prestim(1).attentiontype = 'exogenous'; % exogenous/endogenous
prestim(1).dotsize = 0.25; % deg (there may be GPU based limitations)
prestim(1).dotdensity = 3; % dots/deg2
prestim(1).dotlifetime = 10; % dot life in # frames ([] is unlimited)
prestim(1).contrast = 0.2; % contrast of the dots
prestim(1).contrastbin = true; % if true all dots have either the min or max value of the contrast
prestim(1).color = []; % leave empty for luminance contrast
prestim(1).driftspeed = [-1.5 0; 1.5 0]; % deg/s positive is rightward [dots1 dots2]
prestim(1).transient.contrastincr = 0.6; % change in contrast for exogenous attention
prestim(1).transient.stim = 1; % which stim gets the transient
prestim(1).transient.duration = 150; % how long is the contrast change
prestim(1).transient.timewindow = [-2 -1]; % when can it happen relative to end of prestim [max min]
prestim(1).instruct = ['Fix your gaze on the red dot in the middle.']; % show an instruction before the trial starts (nothing if empty)
% prestim(1).quest = 'Left or Right'; % question text after the prestim (key-press left/right is logged)

% for endogenous dots prestim
% show transparent moving dots that change in direction over time
prestim(2).type = 'dots';  % stimulus type
prestim(2).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(2).dotsize = 0.25; % deg (there may be GPU based limitations)
prestim(2).dotdensity = 3; % dots/deg2
prestim(2).dotlifetime = 10; % dot life in # frames ([] is unlimited)
prestim(2).contrast = 0.8; % contrast 0-1
prestim(2).contrastbin = true; % if true all dots have either the min or max value of the contrast
prestim(2).color = [1 0 0;0 1 0]; % leave empty for luminance contrast [R1 G1 B1; R2 G2 B2]
prestim(2).orientations = [-45 -45; 45 45]; % drift angle degrees clockwise [start_stim1 end_stim1; start_stim2 end_stim2]
% orientations is not used for dots
prestim(2).driftspeed = [-1.5 0; 1.5 0]; % deg/s positive is rightward/down [H1 V1;H2 V2]
prestim(2).trackstim = 1; % which stimulus should be tracked
prestim(2).change.degpersec = 2; % deg/sec (choose integer frame counts
prestim(2).change.interval = [0.5 1.5]; % how long can a period of same direction change last [min max]
prestim(2).change.prob = 0.05; % probability of direction change
prestim(2).instruct = 'Attend dots moving LEFT\npress key to start'; % question text after the prestim (ke-press left/right is logged)
prestim(2).quest = 'Did you follow dots moving\nLeft\nor\nRight?'; % [static rotating static] in seconds
prestim(2).durations = [1 3 1]; %[static rotating static]
% NB! make sure these durations add up to trialtime.PrestimT

% for endogenous dots prestim -> track other stimulus
% show transparent moving dots that change in direction over time
prestim(3).type = 'dots';  % stimulus type
prestim(3).attentiontype = 'endogenous'; % exogenous/endogenous
prestim(3).dotsize = 0.25; % deg (there may be GPU based limitations)
prestim(3).dotdensity = 3; % dots/deg2
prestim(3).dotlifetime = 10; % dot life in # frames ([] is unlimited)
prestim(3).contrast = 0.8; % contrast 0-1
prestim(3).contrastbin = true; % if true all dots have either the min or max value of the contrast
prestim(3).color = [1 0 0;0 1 0]; % leave empty for luminance contrast [R1 G1 B1; R2 G2 B2]
prestim(3).orientations = [-45 -45; 45 45]; % drift angle degrees clockwise [start_stim1 end_stim1; start_stim2 end_stim2]
% orientations is not used for dots
prestim(3).driftspeed = [-1.5 0; 1.5 0]; % deg/s positive is rightward/down [H1 V1;H2 V2]
prestim(3).trackstim = 3; % which stimulus should be tracked
prestim(3).change.degpersec = 2; % deg/sec (choose integer frame counts
prestim(3).change.interval = [0.5 1.5]; % how long can a period of same direction change last [min max]
prestim(3).change.prob = 0.05; % probability of direction change
prestim(3).instruct = 'Attend dots moving RIGHT\npress key to start'; % question text after the prestim (ke-press left/right is logged)
prestim(3).quest = 'Did you follow dots moving\nLeft\nor\nRight?'; % [static rotating static] in seconds
prestim(3).durations = [1 3 1]; %[static rotating static]
% NB! make sure these durations add up to trialtime.PrestimT

% ---------------------------------------------

%% stimulus --
stim(1).type = 'dots'; % stimulus type
stim(1).dotsize = 0.25; % deg
stim(1).dotdensity = 3; % dots/deg2
stim(1).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(1).contrast = 1;  % contrast 0-1
stim(1).contrastbin = true; % if true, only use highest and lowest
stim(1).color = []; % leave empty for luminance contrast
stim(1).driftspeed = [1.5 0]; % [h v] deg/s positive is rightward/down

stim(2).type = 'dots'; % stimulus type
stim(2).dotsize = 0.25; % deg
stim(2).dotdensity = 3; % dots/deg2
stim(2).dotlifetime = 10; % dot life in # frames ([] is unlimited)
stim(2).contrast = 1;  % contrast 0-1
stim(2).contrastbin = true; % if true, only use highest and lowest
stim(2).color = []; % leave empty for luminance contrast
stim(2).driftspeed = [-1.5 0]; % [h v] deg/s positive is rightward/down

% -------------------------------
%% Experiment structure ----
% -------------------------------

% trials --
% exogenous dots trial
trialtype(1).stimsize = [4 4]; % which stimuli [left right]
trialtype(1).prestim = 1; % which prestim
trialtype(1).eye(1).stim = 1; % stim for eye1
trialtype(1).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(1).time.FixT = 0.5; %s time without stimus / with alignment
trialtype(1).time.PrestimT = 2; %s leave empty or set zero for none
trialtype(1).time.PrestimGapT = 0.25; %s between prestim and stim
trialtype(1).time.StimT = 1.5; %s stimulus duration
trialtype(1).time.ITIT  = 0.5; %s intertrial interval

% exogenous dots trial - eyes changed
trialtype(2).stimsize = [4 4]; % which stimuli [left right]
trialtype(2).prestim = 1; % which prestim
trialtype(2).eye(1).stim = 2; % stim for eye1
trialtype(2).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(2).time.FixT = 1; %s time without stimus / with alignment
trialtype(2).time.PrestimT = 1; %s leave empty or set zero for none
trialtype(2).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(2).time.StimT = 1; %s stimulus duration
trialtype(2).time.ITIT  = 1; %s intertrial interval

% exogenous dots catch trial
trialtype(3).stimsize = [4 4]; % which stimuli [left right]
trialtype(3).prestim = 1; % which prestim
trialtype(3).eye(1).stim = 1; % stim for eye1
trialtype(3).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(3).time.FixT = 1; %s time without stimus / with alignment
trialtype(3).time.PrestimT = 1; %s leave empty or set zero for none
trialtype(3).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(3).time.StimT = 1; %s stimulus duration
trialtype(3).time.ITIT  = 1; %s intertrial interval

% exogenous dots catch trial - other direction
trialtype(4).stimsize = [4 4]; % which stimuli [left right]
trialtype(4).prestim = 1; % which prestim
trialtype(4).eye(1).stim = 2; % stim for eye1
trialtype(4).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(4).time.FixT = 1; %s time without stimus / with alignment
trialtype(4).time.PrestimT = 1; %s leave empty or set zero for none
trialtype(4).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(4).time.StimT = 1; %s stimulus duration
trialtype(4).time.ITIT  = 1; %s intertrial interval

% endogenous dots trial
trialtype(5).stimsize = [4 4]; % which stimuli [left right]
trialtype(5).prestim = 2; % which prestim
trialtype(5).eye(1).stim = 1; % stim for eye1
trialtype(5).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(5).time.FixT = 1; %s time without stimus / with alignment
trialtype(5).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(5).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(5).time.StimT = 1; %s stimulus duration
trialtype(5).time.ITIT  = 1; %s intertrial interval

% endogenous dots trial - track other direction
trialtype(6).stimsize = [4 4]; % which stimuli [left right]
trialtype(6).prestim = 3; % which prestim
trialtype(6).eye(1).stim = 1; % stim for eye1
trialtype(6).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(6).time.FixT = 1; %s time without stimus / with alignment
trialtype(6).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(6).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(6).time.StimT = 1; %s stimulus duration
trialtype(6).time.ITIT  = 1; %s intertrial interval

% endogenous dots trial - eyes changed
trialtype(7).stimsize = [4 4]; % which stimuli [left right]
trialtype(7).prestim = 2; % which prestim
trialtype(7).eye(1).stim = 2; % stim for eye1
trialtype(7).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(7).time.FixT = 1; %s time without stimus / with alignment
trialtype(7).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(7).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(7).time.StimT = 1; %s stimulus duration
trialtype(7).time.ITIT  = 1; %s intertrial interval

% endogenous dots trial - eyes changed + track other direction
trialtype(8).stimsize = [4 4]; % which stimuli [left right]
trialtype(8).prestim = 3; % which prestim
trialtype(8).eye(1).stim = 2; % stim for eye1
trialtype(8).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(8).time.FixT = 1; %s time without stimus / with alignment
trialtype(8).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(8).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(8).time.StimT = 1; %s stimulus duration
trialtype(8).time.ITIT  = 1; %s intertrial interval

% endogenous dots catch trial
trialtype(9).stimsize = [4 4]; % which stimuli [left right]
trialtype(9).prestim = 2; % which prestim
trialtype(9).eye(1).stim = 1; % stim for eye1
trialtype(9).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(9).time.FixT = 1; %s time without stimus / with alignment
trialtype(9).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(9).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(9).time.StimT = 1; %s stimulus duration
trialtype(9).time.ITIT  = 1; %s intertrial interval

% endogenous dots catch trial - track other direction
trialtype(10).stimsize = [4 4]; % which stimuli [left right]
trialtype(10).prestim = 3; % which prestim
trialtype(10).eye(1).stim = 1; % stim for eye1
trialtype(10).eye(2).stim = 1; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(10).time.FixT = 1; %s time without stimus / with alignment
trialtype(10).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(10).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(10).time.StimT = 1; %s stimulus duration
trialtype(10).time.ITIT  = 1; %s intertrial interval


% endogenous dots catch trial - stimuli moving to direction
trialtype(11).stimsize = [4 4]; % which stimuli [left right]
trialtype(11).prestim = 2; % which prestim
trialtype(11).eye(1).stim = 2; % stim for eye1
trialtype(11).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(11).time.FixT = 1; %s time without stimus / with alignment
trialtype(11).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(11).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(11).time.StimT = 1; %s stimulus duration
trialtype(11).time.ITIT  = 1; %s intertrial interval

% endogenous dots catch trial - stimuli moving to direction + track other
% direction
trialtype(12).stimsize = [4 4]; % which stimuli [left right]
trialtype(12).prestim = 3; % which prestim
trialtype(12).eye(1).stim = 2; % stim for eye1
trialtype(12).eye(2).stim = 2; % stim for eye2
% Choose timing consistent with 60Hz refresh rate
% so multiples of 1/60 s
trialtype(12).time.FixT = 1; %s time without stimus / with alignment
trialtype(12).time.PrestimT = 6; %s leave empty or set zero for none
trialtype(12).time.PrestimGapT = 0.5; %s between prestim and stim
trialtype(12).time.StimT = 1; %s stimulus duration
trialtype(12).time.ITIT  = 1; %s intertrial interval

% blocks --
% button-press report
block(1).reportmode = 'key'; % key/verbal/none
block(1).trials = [1 2 5 6 7 8]; % which trialtypes in the block
block(1).randomizetrials = true; % randomize in block
block(1).repeattrials = 2; % repeat trial sets this many times
block(1).instruction = ['Press left or right button \n' ...
    'according to what direction of movement \n you are seeing\nor is dominant.\nPress key to start']; % replace with text you want
% button-press report catch trial block
block(2).reportmode = 'key'; % key/verbal/none
block(2).trials = [3 4 9 10 11 12]; % which trialtypes in the block
block(2).randomizetrials = true; % randomize in block
block(2).repeattrials = 1; % repeat trial sets this many times
block(2).instruction = ['Press left or right button \n' ...
    'according to what direction of movement \nis more dominant.\n\nPress key to start']; % replace with text you want

% no report
block(3).reportmode = 'none'; % key/verbal/none
block(3).trials = [1 2 5 6 7 8]; % which trialtypes in the block
block(3).randomizetrials = true; % randomize in block
block(3).repeattrials = 2; % repeat trial sets this many times
block(3).instruction = ['Do not press buttons now. to\n' ...
    'Just attend the fixation dot\nin the middle.\n\nPress key to start']; % replace with text you want
% no report catch trial block
block(4).reportmode = 'none'; % key/verbal/none
block(4).trials = [3 4 9 10 11 12]; % which trialtypes in the block
block(4).randomizetrials = true; % randomize in block
block(4).repeattrials = 1; % repeat trial sets this many times
block(4).instruction = ['Do not press buttons now. to\n' ...
    'Just attend the fixation dot\nin the middle.\n\nPress key to start'];  % replace with text you want

% expt --
expt.blockorder = []; % set for a specific order, empty means 1:end
expt.randomizeblocks = false; % overrules order
expt.blockrepeats = 1; % randomization only within set of repeats
expt.thanktext = 'That was it\nThank you!';
expt.thankdur = 2; % seconds
