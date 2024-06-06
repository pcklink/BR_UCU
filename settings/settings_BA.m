% monitor ---
monitor.gamma = 2.2; 
monitor.distance = 690; 
monitor.fliphorizontal = true; 
monitor.stereomode = 4; 
monitor.maxpenwidth = 7; 
monitor.DebugMode = 'NoDebug'; %-> NoDebug during experiment 'CKHOME'

% eyetracker ---
eyetracker.do = true; 
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
keys.resp = {'LeftArrow','RightArrow'}; 

% log location ---
log.fld = 'log_BA'; 

%% background --
bg.color = [0.5 0.5 0.5]; 
bg.textcolor = [1 1 1];
bg.align.Frame.Type = 1;  % 0 for oval, 1 for rectangular
bg.align.Frame.PenWidth = .2;
bg.align.Frame.CrossLength = [6 6];
bg.align.Frame.Color = [0 0 0]; 
bg.align.AlignCircles.draw = true; 
bg.align.AlignCircles.n = 150; 
bg.align.AlignCircles.ColorRange = [0.3 0.7]; 
bg.align.AlignCircles.SizeRange = [.5 1]; 
bg.align.AlignCircles.OpenArea = [8 8];

% fixation dot
fix.size = 0.2;  
fix.color = [1 0 0];

% stimuli
% stimuli block 1
stim(1).type = 'image';
stim(1).image = 'happy_real.jpg';
stim(1).rotation = 0;
stim(1).overlay.type = 'lines';
stim(1).overlay.linewidth = 0.1;
stim(1).overlay.linedensity = 3;
stim(1).overlay.color = [0 0 0]; %-> 255 0 0 
stim(1).overlay.opacity = 0.7;
stim(1).overlay.orientation = 'vertical';
stim(1).overlay.driftspeed = 1.5;

stim(2).type = 'image';
stim(2).image = 'happy_real.jpg';
stim(2).rotation = 0;
stim(2).overlay.type = 'lines';
stim(2).overlay.linewidth = 0.1;
stim(2).overlay.linedensity = 3;
stim(2).overlay.color = [0 0 0];
stim(2).overlay.opacity = 0.7;
stim(2).overlay.orientation = 'vertical';
stim(2).overlay.driftspeed = -1.5;

stim(3).type = 'image';
stim(3).image = 'surprised_real.jpg';
stim(3).rotation = 0;
stim(3).overlay.type = 'lines';
stim(3).overlay.linewidth = 0.1;
stim(3).overlay.linedensity = 3;
stim(3).overlay.color = [0 0 0];
stim(3).overlay.opacity = 0.5;
stim(3).overlay.orientation = 'vertical';
stim(3).overlay.driftspeed = 1.5;

stim(4).type = 'image';
stim(4).image = 'surprised_real.jpg';
stim(4).rotation = 0;
stim(4).overlay.type = 'lines';
stim(4).overlay.linewidth = 0.1;
stim(4).overlay.linedensity = 3;
stim(4).overlay.color = [0 0 0];
stim(4).overlay.opacity = 0.5;
stim(4).overlay.orientation = 'vertical';
stim(4).overlay.driftspeed = -1.5;

stim(5).type = 'image';
stim(5).image = 'neutral_real.jpg';
stim(5).rotation = 0;
stim(5).overlay.type = 'lines';
stim(5).overlay.linewidth = 0.1;
stim(5).overlay.linedensity = 3;
stim(5).overlay.color = [0 0 0];
stim(5).overlay.opacity = 0.5;
stim(5).overlay.orientation = 'vertical';
stim(5).overlay.driftspeed = 1.5;

stim(6).type = 'image';
stim(6).image = 'neutral_real.jpg';
stim(6).rotation = 0;
stim(6).overlay.type = 'lines';
stim(6).overlay.linewidth = 0.1;
stim(6).overlay.linedensity = 3;
stim(6).overlay.color = [0 0 0];
stim(6).overlay.opacity = 0.5;
stim(6).overlay.orientation = 'vertical';
stim(6).overlay.driftspeed = -1.5;

% stimuli block 2 - low level features
stim(7).type = 'image';
stim(7).image = 'happy_real.jpg';
stim(7).rotation = 180;
stim(7).overlay.type = 'lines';
stim(7).overlay.linewidth = 0.1;
stim(7).overlay.linedensity = 3;
stim(7).overlay.color = [0 0 0]; %-> 255 0 0 
stim(7).overlay.opacity = 0.7;
stim(7).overlay.orientation = 'vertical';
stim(7).overlay.driftspeed = 1.5;

stim(8).type = 'image';
stim(8).image = 'happy_real.jpg';
stim(8).rotation = 180;
stim(8).overlay.type = 'lines';
stim(8).overlay.linewidth = 0.1;
stim(8).overlay.linedensity = 3;
stim(8).overlay.color = [0 0 0];
stim(8).overlay.opacity = 0.7;
stim(8).overlay.orientation = 'vertical';
stim(8).overlay.driftspeed = -1.5;

stim(9).type = 'image';
stim(9).image = 'surprised_real.jpg';
stim(9).rotation = 180;
stim(9).overlay.type = 'lines';
stim(9).overlay.linewidth = 0.1;
stim(9).overlay.linedensity = 3;
stim(9).overlay.color = [0 0 0];
stim(9).overlay.opacity = 0.5;
stim(9).overlay.orientation = 'vertical';
stim(9).overlay.driftspeed = 1.5;

stim(10).type = 'image';
stim(10).image = 'surprised_real.jpg';
stim(10).rotation = 180;
stim(10).overlay.type = 'lines';
stim(10).overlay.linewidth = 0.1;
stim(10).overlay.linedensity = 3;
stim(10).overlay.color = [0 0 0];
stim(10).overlay.opacity = 0.5;
stim(10).overlay.orientation = 'vertical';
stim(10).overlay.driftspeed = -1.5;

stim(11).type = 'image';
stim(11).image = 'neutral_real.jpg';
stim(11).rotation = 180;
stim(11).overlay.type = 'lines';
stim(11).overlay.linewidth = 0.1;
stim(11).overlay.linedensity = 3;
stim(11).overlay.color = [0 0 0];
stim(11).overlay.opacity = 0.5;
stim(11).overlay.orientation = 'vertical';
stim(11).overlay.driftspeed = 1.5;

stim(12).type = 'image';
stim(12).image = 'neutral_real.jpg';
stim(12).rotation = 180;
stim(12).overlay.type = 'lines';
stim(12).overlay.linewidth = 0.1;
stim(12).overlay.linedensity = 3;
stim(12).overlay.color = [0 0 0];
stim(12).overlay.opacity = 0.5;
stim(12).overlay.orientation = 'vertical';
stim(12).overlay.driftspeed = -1.5;

%stimuli block 3 - different drift speeds 
stim(13).type = 'image';
stim(13).image = 'happy_real.jpg';
stim(13).rotation = 0;
stim(13).overlay.type = 'lines';
stim(13).overlay.linewidth = 0.1;
stim(13).overlay.linedensity = 3;
stim(13).overlay.color = [0 0 0]; %-> 255 0 0 
stim(13).overlay.opacity = 0.7;
stim(13).overlay.orientation = 'vertical';
stim(13).overlay.driftspeed = 2.5;

stim(14).type = 'image';
stim(14).image = 'happy_real.jpg';
stim(14).rotation = 0;
stim(14).overlay.type = 'lines';
stim(14).overlay.linewidth = 0.1;
stim(14).overlay.linedensity = 3;
stim(14).overlay.color = [0 0 0];
stim(14).overlay.opacity = 0.7;
stim(14).overlay.orientation = 'vertical';
stim(14).overlay.driftspeed = -1.5;

stim(15).type = 'image';
stim(15).image = 'surprised_real.jpg';
stim(15).rotation = 0;
stim(15).overlay.type = 'lines';
stim(15).overlay.linewidth = 0.1;
stim(15).overlay.linedensity = 3;
stim(15).overlay.color = [0 0 0];
stim(15).overlay.opacity = 0.5;
stim(15).overlay.orientation = 'vertical';
stim(15).overlay.driftspeed = 1.5;

stim(16).type = 'image';
stim(16).image = 'surprised_real.jpg';
stim(16).rotation = 0;
stim(16).overlay.type = 'lines';
stim(16).overlay.linewidth = 0.1;
stim(16).overlay.linedensity = 3;
stim(16).overlay.color = [0 0 0];
stim(16).overlay.opacity = 0.5;
stim(16).overlay.orientation = 'vertical';
stim(16).overlay.driftspeed = -2.0;

stim(17).type = 'image';
stim(17).image = 'neutral_real.jpg';
stim(17).rotation = 0;
stim(17).overlay.type = 'lines';
stim(17).overlay.linewidth = 0.1;
stim(17).overlay.linedensity = 3;
stim(17).overlay.color = [0 0 0];
stim(17).overlay.opacity = 0.5;
stim(17).overlay.orientation = 'vertical';
stim(17).overlay.driftspeed = 1.5;

stim(18).type = 'image';
stim(18).image = 'neutral_real.jpg';
stim(18).rotation = 0;
stim(18).overlay.type = 'lines';
stim(18).overlay.linewidth = 0.1;
stim(18).overlay.linedensity = 3;
stim(18).overlay.color = [0 0 0];
stim(18).overlay.opacity = 0.5;
stim(18).overlay.orientation = 'vertical';
stim(18).overlay.driftspeed = -2.5;
%% Experiment structure 

% trials: simulated rivalry 1 
trialtype(1).stimsize = [4 4];
trialtype(1).prestim = []; 
trialtype(1).eye(1).stim = 1;
trialtype(1).eye(2).stim = 2;
trialtype(1).time.FixT = 0.5;
trialtype(1).time.PrestimT = [];
trialtype(1).time.PrestimGapT = 0;
trialtype(1).time.StimT = 5;
trialtype(1).time.ITIT  = 0;
trialtype(1).replay = false;
trialtype(1).replayminmax = [1 4];
trialtype(1).poststimquest = [];

% condition: positive valence rightward grating vs neutral leftward grating  
trialtype(2) = trialtype(1);
trialtype(2).eye(1).stim = 1;
trialtype(2).eye(2).stim = 6;
trialtype(2).time.FixT = 0.5;
trialtype(2).time.PrestimT = [];
trialtype(2).time.PrestimGapT = 0;
trialtype(2).time.StimT = 30;
trialtype(2).time.ITIT  = 0;
trialtype(2).replay = false;
trialtype(2).replayminmax = [1 4];

% condition: neutral leftward grating vs positive valence rightward grating
trialtype(3) = trialtype(1);
trialtype(3).eye(1).stim = 6;
trialtype(3).eye(2).stim = 1;
trialtype(3).time.FixT = 0.5;
trialtype(3).time.PrestimT = [];
trialtype(3).time.PrestimGapT = 0;
trialtype(3).time.StimT = 30;
trialtype(3).time.ITIT  = 0;
trialtype(3).replay = false;
trialtype(3).replayminmax = [1 4];

%condition: positive valence leftward grating vs neutral rightward grating
trialtype(4) = trialtype(1);
trialtype(4).eye(1).stim = 2;
trialtype(4).eye(2).stim = 5;
trialtype(4).time.FixT = 0.5;
trialtype(4).time.PrestimT = [];
trialtype(4).time.PrestimGapT = 0;
trialtype(4).time.StimT = 30;
trialtype(4).time.ITIT  = 0;
trialtype(4).replay = false;
trialtype(4).replayminmax = [1 4];

%condition: neutral rightward grating vs positive valence leftward grating
trialtype(5) = trialtype(1);
trialtype(5).eye(1).stim = 5;
trialtype(5).eye(2).stim = 2;
trialtype(5).time.FixT = 0.5;
trialtype(5).time.PrestimT = [];
trialtype(5).time.PrestimGapT = 0;
trialtype(5).time.StimT = 30;
trialtype(5).time.ITIT  = 0;
trialtype(5).replay = false;
trialtype(5).replayminmax = [1 4];

%condition: negative valence rightward grating vs neutral leftward grating
trialtype(6) = trialtype(1);
trialtype(6).eye(1).stim = 3;
trialtype(6).eye(2).stim = 6;
trialtype(6).time.FixT = 0.5;
trialtype(6).time.PrestimT = [];
trialtype(6).time.PrestimGapT = 0;
trialtype(6).time.StimT = 30;
trialtype(6).time.ITIT  = 0;
trialtype(6).replay = false;
trialtype(6).replayminmax = [1 4];

%condition: neutral leftward grating vs negative valence rightward grating
trialtype(7) = trialtype(1);
trialtype(7).eye(1).stim = 6;
trialtype(7).eye(2).stim = 3;
trialtype(7).time.FixT = 0.5;
trialtype(7).time.PrestimT = [];
trialtype(7).time.PrestimGapT = 0;
trialtype(7).time.StimT = 30;
trialtype(7).time.ITIT  = 0;
trialtype(7).replay = false;
trialtype(7).replayminmax = [1 4];

%condition: negative valence leftward grating vs neutral rightward grating
trialtype(8) = trialtype(1);
trialtype(8).eye(1).stim = 4;
trialtype(8).eye(2).stim = 5;
trialtype(8).time.FixT = 0.5;
trialtype(8).time.PrestimT = [];
trialtype(8).time.PrestimGapT = 0;
trialtype(8).time.StimT = 30;
trialtype(8).time.ITIT  = 0;
trialtype(8).replay = false;
trialtype(8).replayminmax = [1 4];

%condition: neutral rightward grating vs negative valence leftward grating 
trialtype(9) = trialtype(1);
trialtype(9).prestim = [];
trialtype(9).eye(1).stim = 5;
trialtype(9).eye(2).stim = 4;
trialtype(9).time.FixT = 0.5;
trialtype(9).time.PrestimT = [];
trialtype(9).time.PrestimGapT = 0;
trialtype(9).time.StimT = 30;
trialtype(9).time.ITIT  = 0;
trialtype(9).replay = false;
trialtype(9).replayminmax = [1 4];

%% trialtypes low-level features
% condition: positive valence rightward grating vs neutral leftward grating  
trialtype(10) = trialtype(1);
trialtype(10).eye(1).stim = 7;
trialtype(10).eye(2).stim = 12;
trialtype(10).time.FixT = 0.5;
trialtype(10).time.PrestimT = [];
trialtype(10).time.PrestimGapT = 0;
trialtype(10).time.StimT = 30;
trialtype(10).time.ITIT  = 0;
trialtype(10).replay = false;
trialtype(10).replayminmax = [1 4];

% condition: neutral leftward grating vs positive valence rightward grating
trialtype(11) = trialtype(1);
trialtype(11).eye(1).stim = 12;
trialtype(11).eye(2).stim = 7;
trialtype(11).time.FixT = 0.5;
trialtype(11).time.PrestimT = [];
trialtype(11).time.PrestimGapT = 0;
trialtype(11).time.StimT = 30;
trialtype(11).time.ITIT  = 0;
trialtype(11).replay = false;
trialtype(11).replayminmax = [1 4];

%condition: positive valence leftward grating vs neutral rightward grating
trialtype(12) = trialtype(1);
trialtype(12).eye(1).stim = 8;
trialtype(12).eye(2).stim = 11;
trialtype(12).time.FixT = 0.5;
trialtype(12).time.PrestimT = [];
trialtype(12).time.PrestimGapT = 0;
trialtype(12).time.StimT = 30;
trialtype(12).time.ITIT  = 0;
trialtype(12).replay = false;
trialtype(12).replayminmax = [1 4];

%condition: neutral rightward grating vs positive valence leftward grating
trialtype(13) = trialtype(1);
trialtype(13).eye(1).stim = 11;
trialtype(13).eye(2).stim = 8;
trialtype(13).time.FixT = 0.5;
trialtype(13).time.PrestimT = [];
trialtype(13).time.PrestimGapT = 0;
trialtype(13).time.StimT = 30;
trialtype(13).time.ITIT  = 0;
trialtype(13).replay = false;
trialtype(13).replayminmax = [1 4];

%condition: negative valence rightward grating vs neutral leftward grating
trialtype(14) = trialtype(1);
trialtype(14).eye(1).stim = 9;
trialtype(14).eye(2).stim = 12;
trialtype(14).time.FixT = 0.5;
trialtype(14).time.PrestimT = [];
trialtype(14).time.PrestimGapT = 0;
trialtype(14).time.StimT = 30;
trialtype(14).time.ITIT  = 0;
trialtype(14).replay = false;
trialtype(14).replayminmax = [1 4];

%condition: neutral leftward grating vs negative valence rightward grating
trialtype(15) = trialtype(1);
trialtype(15).eye(1).stim = 12;
trialtype(15).eye(2).stim = 9;
trialtype(15).time.FixT = 0.5;
trialtype(15).time.PrestimT = [];
trialtype(15).time.PrestimGapT = 0;
trialtype(15).time.StimT = 30;
trialtype(15).time.ITIT  = 0;
trialtype(15).replay = false;
trialtype(15).replayminmax = [1 4];

%condition: negative valence leftward grating vs neutral rightward grating
trialtype(16) = trialtype(1);
trialtype(16).eye(1).stim = 10;
trialtype(16).eye(2).stim = 11;
trialtype(16).time.FixT = 0.5;
trialtype(16).time.PrestimT = [];
trialtype(16).time.PrestimGapT = 0;
trialtype(16).time.StimT = 30;
trialtype(16).time.ITIT  = 0;
trialtype(16).replay = false;
trialtype(16).replayminmax = [1 4];

%condition: neutral rightward grating vs negative valence leftward grating 
trialtype(17) = trialtype(1);
trialtype(17).prestim = [];
trialtype(17).eye(1).stim = 11;
trialtype(17).eye(2).stim = 10;
trialtype(17).time.FixT = 0.5;
trialtype(17).time.PrestimT = [];
trialtype(17).time.PrestimGapT = 0;
trialtype(17).time.StimT = 30;
trialtype(17).time.ITIT  = 0;
trialtype(17).replay = false;
trialtype(17).replayminmax = [1 4];

%% trialtypes different drifting speeds
% condition: positive valence rightward grating vs neutral leftward grating  
trialtype(18) = trialtype(1);
trialtype(18).eye(1).stim = 13;
trialtype(18).eye(2).stim = 18;
trialtype(18).time.FixT = 0.5;
trialtype(18).time.PrestimT = [];
trialtype(18).time.PrestimGapT = 0;
trialtype(18).time.StimT = 30;
trialtype(18).time.ITIT  = 0;
trialtype(18).replay = false;
trialtype(18).replayminmax = [1 4];

% condition: neutral leftward grating vs positive valence rightward grating
trialtype(19) = trialtype(1);
trialtype(19).eye(1).stim = 18;
trialtype(19).eye(2).stim = 13;
trialtype(19).time.FixT = 0.5;
trialtype(19).time.PrestimT = [];
trialtype(19).time.PrestimGapT = 0;
trialtype(19).time.StimT = 30;
trialtype(19).time.ITIT  = 0;
trialtype(19).replay = false;
trialtype(19).replayminmax = [1 4];

%condition: positive valence leftward grating vs neutral rightward grating
trialtype(20) = trialtype(1);
trialtype(20).eye(1).stim = 14;
trialtype(20).eye(2).stim = 17;
trialtype(20).time.FixT = 0.5;
trialtype(20).time.PrestimT = [];
trialtype(20).time.PrestimGapT = 0;
trialtype(20).time.StimT = 30;
trialtype(20).time.ITIT  = 0;
trialtype(20).replay = false;
trialtype(20).replayminmax = [1 4];

%condition: neutral rightward grating vs positive valence leftward grating
trialtype(21) = trialtype(1);
trialtype(21).eye(1).stim = 17;
trialtype(21).eye(2).stim = 14;
trialtype(21).time.FixT = 0.5;
trialtype(21).time.PrestimT = [];
trialtype(21).time.PrestimGapT = 0;
trialtype(21).time.StimT = 30;
trialtype(21).time.ITIT  = 0;
trialtype(21).replay = false;
trialtype(21).replayminmax = [1 4];

%condition: negative valence rightward grating vs neutral leftward grating
trialtype(22) = trialtype(1);
trialtype(22).eye(1).stim = 15;
trialtype(22).eye(2).stim = 18;
trialtype(22).time.FixT = 0.5;
trialtype(22).time.PrestimT = [];
trialtype(22).time.PrestimGapT = 0;
trialtype(22).time.StimT = 30;
trialtype(22).time.ITIT  = 0;
trialtype(22).replay = false;
trialtype(22).replayminmax = [1 4];

%condition: neutral leftward grating vs negative valence rightward grating
trialtype(23) = trialtype(1);
trialtype(23).eye(1).stim = 18;
trialtype(23).eye(2).stim = 15;
trialtype(23).time.FixT = 0.5;
trialtype(23).time.PrestimT = [];
trialtype(23).time.PrestimGapT = 0;
trialtype(23).time.StimT = 30;
trialtype(23).time.ITIT  = 0;
trialtype(23).replay = false;
trialtype(23).replayminmax = [1 4];

%condition: negative valence leftward grating vs neutral rightward grating
trialtype(24) = trialtype(1);
trialtype(24).eye(1).stim = 16;
trialtype(24).eye(2).stim = 17;
trialtype(24).time.FixT = 0.5;
trialtype(24).time.PrestimT = [];
trialtype(24).time.PrestimGapT = 0;
trialtype(24).time.StimT = 30;
trialtype(24).time.ITIT  = 0;
trialtype(24).replay = false;
trialtype(24).replayminmax = [1 4];

%condition: neutral rightward grating vs negative valence leftward grating 
trialtype(25) = trialtype(1);
trialtype(25).prestim = [];
trialtype(25).eye(1).stim = 17;
trialtype(25).eye(2).stim = 16;
trialtype(25).time.FixT = 0.5;
trialtype(25).time.PrestimT = [];
trialtype(25).time.PrestimGapT = 0;
trialtype(25).time.StimT = 30;
trialtype(25).time.ITIT  = 0;
trialtype(25).replay = false;
trialtype(25).replayminmax = [1 4];

% block: key report 
block(1).reportmode = 'key';
block(1).trials = [2,3,4,5,6,7,8,9]; 
block(1).randomizetrials = true;
block(1).repeattrials = 2;
block(1).randrepmode = 'randomrepeat'; % randomrepeat or repeatrandom
block(1).instruction = ['Hold the left key to report emotional faces\n' ...
    'Hold the right key to report neutral faces \n Release keys if you are unsure.\n\nPress any key to start'];

% here you can define image to show with the instructions
block(1).instruct.imgdo = false;
block(1).instruct.img(1).file = 'happy_real.jpg';
block(1).instruct.img(1).position = [-2 -3]; 
block(1).instruct.img(1).size = [3 3];
block(1).instruct.img(1).rotation = 0;
block(1).instruct.img(2).file = 'neutral_real.jpg';
block(1).instruct.img(2).position = [2 -3]; 
block(1).instruct.img(2).size = [3 3];
block(1).instruct.img(2).rotation = 180;

% block: low level features
block(2).reportmode = 'key'; 
block(2).trials = [10,11,12,13,14,15,16,17]; 
block(2).randomizetrials = true; 
block(2).repeattrials = 2; 
block(2).randrepmode = 'randomrepeat'; % randomrepeat or repeatrandom
block(2).instruction = ['Hold the left key to report emotional faces\n' ...
    'Hold the right key to report neutral faces \n Release keys if you are unsure.\n\nPress any key to start'];
block(2).instruct.imgdo = false;

%['You do not have to report anything. \n' ... 'Just pay attention. \n\nPress any key to start']; 

% block: different drifting speeds 
block(3).reportmode = 'key'; 
block(3).trials = [18,19,20,21,22,23,24,25]; 
block(3).randomizetrials = true; 
block(3).repeattrials = 2; 
block(3).randrepmode = 'randomrepeat'; % randomrepeat or repeatrandom
block(3).instruction = ['Hold the left key to report emotional faces\n' ...
    'Hold the right key to report neutral faces \n Release keys if you are unsure.\n\nPress any key to start'];
block(3).instruct.imgdo = false;

%%

% expt --
expt.blockorder = [1 2 3];
expt.randomizeblocks = true;
expt.blockrepeats = 1;
expt.thanktext = 'Thats it, all done.\nThank you so much for participating!';
expt.thankdur = 5;
