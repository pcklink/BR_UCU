% monitor ---
monitor.gamma = 2.2; 
monitor.distance = 690; 
monitor.fliphorizontal = true; 
monitor.stereomode = 4; 
monitor.maxpenwidth = 7; 
monitor.DebugMode = 'NoDebug'; %-> how to  

% eyetracker ---
eyetracker.do = false; 
eyetracker.type = 'Tobii Pro Fusion'; 
eyetracker.calibrate = true; 
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; 

% sound ---
sound.recordmic = false; 
sound.startbeep = false; 
sound.mic.maxsec = []; 
sound.mic.device = []; 
sound.mic.nchan = []; 
sound.play.device = 0; 
sound.play.nchan = 2; 
sound.beepfile = 'beep.wav'; 

% keys ---
keys.esc = 'ESCAPE'; 
keys.resp = {'LeftArrow','DownArrow','RightArrow'}; %-> not sure if I have done this correctly  

% log location ---
log.fld = 'log_BA'; 

%% background --
bg.color = [0.5 0.5 0.5]; 
bg.textcolor = [1 1 1];
bg.align.Frame.Type = 0;  % 0 for oval, 1 for rectangular
bg.align.Frame.PenWidth = .2;
bg.align.Frame.CrossLength = [6 6];
bg.align.Frame.Color = [0 0 0]; 
bg.align.AlignCircles.draw = true; 
bg.align.AlignCircles.n = 150; 
bg.align.AlignCircles.ColorRange = [0.3 0.7]; 
bg.align.AlignCircles.SizeRange = [.5 1]; 
bg.align.AlignCircles.OpenArea = [8 8];

% fixation dot
fix.size = 0.2;  % -> enlarge? 
fix.color = [1 0 0];

% stimuli

stim(1).type = 'image';
stim(1).image = 'happy_real.jpg';
stim(1).overlay.type = 'lines';
stim(1).overlay.linewidth = 0.1;
stim(1).overlay.linedensity = 3;
stim(1).overlay.color = [0 0 0];
stim(1).overlay.opacity = 0.7;
stim(1).overlay.orientation = 'vertical';
stim(1).overlay.driftspeed = 2;

stim(2).type = 'image';
stim(2).image = 'happy_real.jpg';
stim(2).overlay.type = 'lines';
stim(2).overlay.linewidth = 0.1;
stim(2).overlay.linedensity = 3;
stim(2).overlay.color = [0 0 0];
stim(2).overlay.opacity = 0.7;
stim(2).overlay.orientation = 'vertical';
stim(2).overlay.driftspeed = -2;

stim(3).type = 'image';
stim(3).image = 'surprised_real.jpg';
stim(3).overlay.type = 'lines';
stim(3).overlay.linewidth = 0.1;
stim(3).overlay.linedensity = 3;
stim(3).overlay.color = [0 0 0];
stim(3).overlay.opacity = 0.5;
stim(3).overlay.orientation = 'vertical';
stim(3).overlay.driftspeed = 1.5;

stim(4).type = 'image';
stim(4).image = 'surprised_real.jpg';
stim(4).overlay.type = 'lines';
stim(4).overlay.linewidth = 0.1;
stim(4).overlay.linedensity = 3;
stim(4).overlay.color = [0 0 0];
stim(4).overlay.opacity = 0.5;
stim(4).overlay.orientation = 'vertical';
stim(4).overlay.driftspeed = -1.5;

stim(5).type = 'image';
stim(5).image = 'neutral_real.jpg';
stim(5).overlay.type = 'lines';
stim(5).overlay.linewidth = 0.1;
stim(5).overlay.linedensity = 3;
stim(5).overlay.color = [0 0 0];
stim(5).overlay.opacity = 0.5;
stim(5).overlay.orientation = 'vertical';
stim(5).overlay.driftspeed = 1.5;

stim(6).type = 'image';
stim(6).image = 'neutral_real.jpg';
stim(6).overlay.type = 'lines';
stim(6).overlay.linewidth = 0.1;
stim(6).overlay.linedensity = 3;
stim(6).overlay.color = [0 0 0];
stim(6).overlay.opacity = 0.5;
stim(6).overlay.orientation = 'vertical';
stim(6).overlay.driftspeed = -1.5;

%% Experiment structure 

% trials: simulated rivalry 1 -> What does this do?
trialtype(1).stimsize = [4 4];
trialtype(1).prestim = []; %-> How do I delete this prestim
trialtype(1).eye(1).stim = 1;
trialtype(1).eye(2).stim = 2;
trialtype(1).time.FixT = 0.5;
trialtype(1).time.PrestimT = [];
trialtype(1).time.PrestimGapT = 0;
trialtype(1).time.StimT = 5;
trialtype(1).time.ITIT  = 0;
trialtype(1).replay = true;
trialtype(1).replayminmax = [1 4];
trialtype(1).poststimquest = [];

% condition: positive valence rightward grating vs neutral leftward grating  
trialtype(2) = trialtype(1);
trialtype(2).eye(1).stim = 1;
trialtype(2).eye(2).stim = 6;
trialtype(2).time.FixT = 0;
trialtype(2).time.PrestimT = [];
trialtype(2).time.PrestimGapT = 0;
trialtype(2).time.StimT = 120;
trialtype(2).time.ITIT  = 0;
trialtype(2).replay = false;
trialtype(2).replayminmax = [1 4];

% condition: neutral leftward grating vs positive valence rightward grating
trialtype(3) = trialtype(1);
trialtype(3).eye(1).stim = 6;
trialtype(3).eye(2).stim = 1;
trialtype(3).time.FixT = 0;
trialtype(3).time.PrestimT = [];
trialtype(3).time.PrestimGapT = 0;
trialtype(3).time.StimT = 120;
trialtype(3).time.ITIT  = 0;
trialtype(3).replay = false;
trialtype(3).replayminmax = [1 4];

%condition: positive valence leftward grating vs neutral rightward grating
trialtype(4) = trialtype(1);
trialtype(4).eye(1).stim = 2;
trialtype(4).eye(2).stim = 5;
trialtype(4).time.FixT = 0;
trialtype(4).time.PrestimT = [];
trialtype(4).time.PrestimGapT = 0;
trialtype(4).time.StimT = 120;
trialtype(4).time.ITIT  = 0;
trialtype(4).replay = false;
trialtype(4).replayminmax = [1 4];

%condition: neutral rightward grating vs positive valence leftward grating
trialtype(5) = trialtype(1);
trialtype(5).eye(1).stim = 5;
trialtype(5).eye(2).stim = 2;
trialtype(5).time.FixT = 0;
trialtype(5).time.PrestimT = [];
trialtype(5).time.PrestimGapT = 0;
trialtype(5).time.StimT = 120;
trialtype(5).time.ITIT  = 0;
trialtype(5).replay = false;
trialtype(5).replayminmax = [1 4];

%condition: negative valence rightward grating vs neutral leftward grating
trialtype(6) = trialtype(1);
trialtype(6).eye(1).stim = 3;
trialtype(6).eye(2).stim = 6;
trialtype(6).time.FixT = 0;
trialtype(6).time.PrestimT = [];
trialtype(6).time.PrestimGapT = 0;
trialtype(6).time.StimT = 120;
trialtype(6).time.ITIT  = 0;
trialtype(6).replay = false;
trialtype(6).replayminmax = [1 4];

%condition: neutral leftward grating vs negative valence rightward grating
trialtype(7) = trialtype(1);
trialtype(7).eye(1).stim = 6;
trialtype(7).eye(2).stim = 3;
trialtype(7).time.FixT = 0;
trialtype(7).time.PrestimT = [];
trialtype(7).time.PrestimGapT = 0;
trialtype(7).time.StimT = 120;
trialtype(7).time.ITIT  = 0;
trialtype(7).replay = false;
trialtype(7).replayminmax = [1 4];

%condition: negative valence leftward grating vs neutral rightward grating
trialtype(8) = trialtype(1);
trialtype(8).eye(1).stim = 4;
trialtype(8).eye(2).stim = 5;
trialtype(8).time.FixT = 0;
trialtype(8).time.PrestimT = [];
trialtype(8).time.PrestimGapT = 0;
trialtype(8).time.StimT = 120;
trialtype(8).time.ITIT  = 0;
trialtype(8).replay = false;
trialtype(8).replayminmax = [1 4];

%condition: neutral rightward grating vs negative valence leftward grating 
trialtype(9) = trialtype(1);
trialtype(9).prestim = [];
trialtype(9).eye(1).stim = 5;
trialtype(9).eye(2).stim = 4;
trialtype(9).time.FixT = 0;
trialtype(9).time.PrestimT = [];
trialtype(9).time.PrestimGapT = 0;
trialtype(9).time.StimT = 120;
trialtype(9).time.ITIT  = 0;
trialtype(9).replay = false;
trialtype(9).replayminmax = [1 4];

% block: training
block(1).reportmode = 'key';
block(1).trials = [2,9]; 
block(1).randomizetrials = true;
block(1).repeattrials = 1;
block(1).instruction = ['Click the left key to report emotional faces\n' ...
    'Click the center key to report neutral faces\n Click the right key to report if you are unsure.\n\nPress key to start'];



%%

% expt --
expt.blockorder = [];
expt.randomizeblocks = true;
expt.blockrepeats = 1;
expt.thanktext = 'Thats it, all done.\nThank you so much for participating!';
expt.thankdur = 1;
