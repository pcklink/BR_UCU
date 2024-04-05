% This script illustrates how to record some eye data from the Tobii Pro Fusion
% in the stereoscope setup with dual screens that runs linux.

% Calibrate the eyetracker ===
CalibrateEyetracker;
% This script switches the monitors to mirror mode so that they both show the same thing.
% it also mirrors all video from PTB-3 to account for the fact that the participant views
% the screen via a mirror. It then communicates with the Tobii to do the calibration.

% Use these code snippets in your experiment ===
% Start communication --
eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % path to the eyetracker toolbox
run(fullfile(eyetracker.toolboxfld,'addTittaToPath')); % add toolbox to path
eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
settings = Titta.getDefaults(eyetracker.type); % specify which eyetracker
settings.debugMode = false
EThndl = Titta(settings); % load settings
EThndl.init(); % initiate eyetracker
EThndl.buffer.start('gaze'); WaitSecs(.8); % start gazebuffer and wait a bit for it to start

% Run the experiment --
% Do whatever you want while recording the eye data
EThndl.sendMessage('FixStart',vbl) % send messages with a timestamp to the eyetracker (to sync with behavior)
% Do whatever you want while recording the eye data

% Stop communication and save data --
EThndl.buffer.stop('gaze'); % close the buffer
fn = 'eyedata'; % create a label
EThndl.saveData(fn, true); % save
EThndl.deInit(); % shut down communication with eyetracker



