function calibrateTobii(eyetracker, log)
% taken from readmeMinimal_mirror.m
% this file should be called AFTER setting the monitors up in mirror mode
% use the standalone script CalibrateEyetracker or build it into the
% experiment

if nargin < 2
    log.fld = 'default_log';
    cdt = datetime('now', 'Format', 'yyyyMMdd_HHmm');
    log.Label = datestr(cdt, 'yyyymmdd_HHMM'); %#ok<*DATST>
    [~,~] = mkdir(fullfile(cd, log.fld, log.Label));
end
if nargin < 1
    eyetracker.type = 'Tobii Pro Fusion'; % which eyetracker
    eyetracker.toolboxfld = '/home/chris/Documents/MATLAB/Titta'; % check this
end

% set monitors of stereoscopic setup in mirrored mode
system("xrandr --output DP-2 --same-as DP-1") % set monitors mirrored 

scr = max(Screen('Screens'));
run(fullfile(eyetracker.toolboxfld,'addTittaToPath'));

try
    % get setup struct (can edit that of course):
    settings = Titta.getDefaults(eyetracker.type);
    % request some debug output to command window, can skip for normal use
    settings.debugMode      = true;
    % calibration display - use custom calibration drawer
    calViz                      = AnimatedCalibrationDisplay();
    settings.cal.drawFunction   = @calViz.doDraw;
    
    % init
    EThndl = Titta(settings);
    EThndl.init();
    
    % open PTB screen
    % mirror horizontally --------
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask','AllViews','FlipHorizontal');
    % ----------------------------
    [wpnt,~] = PsychImaging('OpenWindow', scr, 127, [], [], [], [], 4);
    Priority(1);
    KbName('UnifyKeyNames');    % for correct operation of the setup/calibration interface, calling this is required
    
    % do calibration (info about validation accuracy will be stored in eye
    % tracker messages, and more info is collected by the
    % EThndl.collectSessionData() call below)
    ListenChar(-1);
    EThndl.calibrate(wpnt);
    ListenChar(0);
    % shut down
    EThndl.deInit();   
    sca
    % set monitors of stereoscopic setup in mirrored mode
    system("xrandr --output DP-2 --right-of DP-1") % set monitors extended 
catch me
    sca
    ListenChar(0);
    rethrow(me)
    system("xrandr --output DP-2 --right-of DP-1") % set monitors extended 
end
