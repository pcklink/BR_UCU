function BR_UCU(settings_file)

% Running a range of binocular rivalry experiments for UCU projects.
% Use a settings file to configure.
% This file should ideally not be edited.
%
% The code interfaces with a Tobii Pro Fusion eyetracker
% Chris Klink p.c.klink@uu.nl

%% Process arguments ------
if nargin<1 % no arguments provided
    settings_file = 'settings_def'; % the default
end
log.settings_file = settings_file; % log the file name

% load settings ---
% variables need to be preallocated when they come from the settings file
monitor = []; eyetracker = []; sound = []; keys = [];
bg = []; fix = []; prestim = []; stim = [];
trialtype = []; block = []; expt = [];

% get the location of this file for relative filepaths
[RunPath,~,~] = fileparts(mfilename('fullpath'));

% get the info from the settings file
run(fullfile(RunPath,'settings',settings_file));

% Debug mode allows subscreen stim display
DebugMode = monitor.DebugMode;

% log set-up --
% get a timestamp
cdt = datetime('now', 'Format', 'yyyyMMdd_HHmm');
log.Label = datestr(cdt, 'yyyymmdd_HHMM'); %#ok<*DATST>
% create a folder for the log files
[~,~] = mkdir(fullfile(RunPath, log.fld, log.Label));

% get subject information
if strcmp(DebugMode, 'NoDebug')
    % Get registration info & check against existing data    % Get subject info
    log.Subject = input('Subject initials: ','s');
    log.Gender = input('Gender (m/f/x): ','s');
    log.Age = input('Age: ','s');
    log.Handedness = input('Left(L)/Right(R) handed: ','s');
else % when running in debug mode use some dummy values
    log.Subject = 'TEST';
    log.Gender = 'x';
    log.Age = 0;
    log.Handedness = 'R';
end

%% Calibrate eye tracker ------
if eyetracker.do && eyetracker.calibrate % alternatively do this with a separate script
    try
        SetMonitors('mirrored'); % set monitors in mirrored mode
        calibrateTobii(eyetracker, log); % run calibration
        SetMonitors('extended'); % set monitors in extended mode
    catch
        fprintf('ERROR doing eyetracker calibration\n'); % we'll go here if something goes wrong
    end
end

%% Run experiment ------
try
    %% Hardware setup ------
    % Monitor --
    % Reduce PTB3 verbosity
    oldLevel = Screen('Preference', 'Verbosity', 0); %#ok<*NASGU>
    Screen('Preference', 'VisualDebuglevel', 0);
    Screen('Preference','SkipSyncTests',1);

    % Do some basic initializing
    PsychDefaultSetup(2); HideCursor;
    % ListenChar(2); % silence keyboard for matlab

    % Get screen info --
    scr = Screen('screens'); % get screen info
    monitor.scr = max(scr); % use the screen with the highest #
    % for our setup the two monitors form one large screen
    % using stereomode later on then splits this into a left/right half
    % that you draw stimuli on independently

    % Gamma Correction to allow intensity in fractions --
    % Each pixel can have an intensity values specified in 8 bits (0-255)
    % We have initialized PTB to use relative values 0-1 instead of bit values 0-255
    % Still, the light intensity of a pixel does not scale linearly with the bit value
    % so doubling what we put in does not double the output intensity
    % Here we correct for that and make it linear.
    % This holds for grey-scale values only.
    % Gamma correcting color values is a pita because
    % the RGB also interact making the function very complex
    [monitor.OLD_Gamtable, monitor.dacbits, monitor.reallutsize] = ...
        Screen('ReadNormalizedGammaTable', monitor.scr);
    GamCor = (0:1/255:1).^(1/monitor.gamma);
    Gamtable = [GamCor;GamCor;GamCor]';
    Screen('LoadNormalizedGammaTable',monitor.scr, Gamtable);
    % we save the uncorrected gamma-table and put it back at the end so the screen looks normal again
    % gamma correction depends on monitor settings: DO NOT CHANGE BRIGHTNESS OR CONTRAST

    % Get the screen size in pixels
    [monitor.PixWidth, monitor.PixHeight] = ...
        Screen('WindowSize',monitor.scr);
    % Get the screen size in mm
    [monitor.MmWidth, monitor.MmHeight] = ...
        Screen('DisplaySize',monitor.scr);

    % Define conversion factors between these values
    monitor.Mm2Pix = monitor.PixWidth/monitor.MmWidth; % convert mm to pixels
    monitor.Deg2Pix = (tand(1)*monitor.distance)*...
        monitor.PixWidth/monitor.MmWidth; % convert degrees visual angles to pixels on the screen

    % Define a stimulus window to draw in
    % this defines a rectangle [upperleft-X upperleft-Y lowerreight-X lowerright-Y]
    % in pixels, start counting from the top left corner of the screen
    switch DebugMode
        case 'NoDebug'
            WindowRect = []; %fullscreen
        case 'UU'
            WindowRect = [0 0 1200 600]; %#ok<*UNRCH> %debug
        case 'CKHOME'
            WindowRect = [1080 0 1080+1500 750]; %#ok<*UNRCH> %debug
        case 'CKNIN'
            WindowRect = [1920 0 1920+1500 750]; %#ok<*UNRCH> %debug
    end

    % Open a window in this 'screen'
    PsychImaging('PrepareConfiguration'); % this allows structural handling of video like mirroring
    if monitor.fliphorizontal % if this is set 'true' in the settings
        PsychImaging('AddTask','AllViews','FlipHorizontal'); % mirror all video output horizontally
    end
    [monitor.w, monitor.wrect] = ...
        PsychImaging('OpenWindow', monitor.scr, bg.color, ...
        WindowRect, [], 2, monitor.stereomode); %#ok<*NODEF> % open the actual window

    % Get the center of screen coordinates
    monitor.center = [monitor.wrect(3)/2 monitor.wrect(4)/2];

    % Define blend function for anti-aliassing (creates smooth shapes)
    [monitor.sourceFactorOld, monitor.destinationFactorOld, ...
        monitor.colorMaskOld] = Screen('BlendFunction', monitor.w, ...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Initialize text options
    Screen('Textfont', monitor.w, 'Arial');
    Screen('TextSize', monitor.w, 20); Screen('TextStyle', monitor.w, 0);

    % Maximum useable priorityLevel on this system:
    priorityLevel = MaxPriority(monitor.w); Priority(priorityLevel);

    % Get the frame duration and refreshrate
    % NB! we measure it from the hardware instead of hardcoding it
    monitor.FrameDur = Screen('GetFlipInterval', monitor.w);
    monitor.refreshRate = round(Screen('NominalFrameRate', monitor.scr));

    % Log initiation. Create a table for events.
    log.ev = array2table(nan(0,3),'VariableNames',{'t','type','info'});
    % three colums 1) timestamp, 2) label, 3) extra information

    % Eyetracker init --
    if eyetracker.do % the settings file determines whether we use an eyetracker or not
        run(fullfile(eyetracker.toolboxfld,'addTittaToPath')); % add toolbox to path
        settings = Titta.getDefaults(eyetracker.type); % specify which eyetracker
        settings.debugMode = false;
        EThndl = Titta(settings); % load settings
        EThndl.init(); % initiate eyetracker
        EThndl.buffer.start('gaze'); WaitSecs(.8); % start gazebuffer and wait a bit for it to start
        log.ev = [log.ev; {GetSecs,'EyeStart','GazeBuffer'}]; % log this start
        fprintf('Eyetracker initialized\n');
    end

    % Sound init --
    if sound.recordmic
        % mic device
        reqlatencyclass = 2;
        InitializePsychSound(double(reqlatencyclass > 1)); % initialize the sound support
        hmic = PsychPortAudio('Open', sound.mic.device, 2, ...
            reqlatencyclass, [], sound.mic.nchan); % get a handle to a recording device
        snd = PsychPortAudio('GetStatus', hmic); % get some specs from the mic
        sndfreq = snd.SampleRate;
        PsychPortAudio('GetAudioData', hmic, 10);

        % play device
        [y, wavfreq] = psychwavread(sound.beepfile); % read in a sound file
        hplay = PsychPortAudio('Open', sound.play.device, 1, ...
            0, wavfreq, sound.play.nchan); % get a handle to a playing device
        wavedata = [y';y']; nrchannels = sound.play.nchan;
        PsychPortAudio('FillBuffer', hplay, wavedata); % load the sound into a buffer
    end

    %% Prepare stimuli ------
    %% alignment stim --
    % the alignment stimuli are a set of 'bubbles' that are in the same location on both screens
    % they can facilitate binocular merging
    if bg.align.AlignCircles.draw % only create them when we need them
        if bg.align.AlignCircles.n > 0 % only create them if we want to have more than 0

            % random colors within range [greyscale]
            bg.align.AlignCircles.Colors = (bg.align.AlignCircles.ColorRange(2) - ...
                bg.align.AlignCircles.ColorRange(1)) .* ...
                rand(1,bg.align.AlignCircles.n) + ...
                bg.align.AlignCircles.ColorRange(1);
            % colors need to be RGB so we use the same values three times for greyscale
            bg.align.AlignCircles.Colors = [...
                bg.align.AlignCircles.Colors; ...
                bg.align.AlignCircles.Colors; ...
                bg.align.AlignCircles.Colors];

            % random sizes within range
            bg.align.AlignCircles.Sizes = (bg.align.AlignCircles.SizeRange(2) - ...
                bg.align.AlignCircles.SizeRange(1)) .*...
                rand(1,bg.align.AlignCircles.n) + ...
                bg.align.AlignCircles.SizeRange(1);
            % we make them circular so horizontal size and vertical size are the same
            bg.align.AlignCircles.Sizes = [...
                bg.align.AlignCircles.Sizes;...
                bg.align.AlignCircles.Sizes];

            % size in pix (convert from degrees)
            bg.align.AlignCircles.SizesPix = round(...
                bg.align.AlignCircles.Sizes .* monitor.Deg2Pix);

            % rects
            % use the sizes to define rectangular areas [TL-X TL-Y BR-X BR-Y]
            bg.align.AlignCircles.Rects = [...
                zeros(1,size(bg.align.AlignCircles.SizesPix,2)); ...
                zeros(1,size(bg.align.AlignCircles.SizesPix,2));
                bg.align.AlignCircles.SizesPix(1,:); ...
                bg.align.AlignCircles.SizesPix(2,:)];

            % locations
            % the centers of these rectangles
            bg.align.AlignCircles.XY = [...
                round(rand(1,size(bg.align.AlignCircles.SizesPix,2)).*...
                (monitor.wrect(3)-monitor.wrect(1)));...
                round(rand(1,size(bg.align.AlignCircles.SizesPix,2)).*...
                (monitor.wrect(4)-monitor.wrect(2)))];

            % center rect on points
            % place the rectangles on the points
            for r = 1: size(bg.align.AlignCircles.Rects,2)
                bg.align.AlignCircles.Rects(:,r) = ...
                    CenterRectOnPoint(bg.align.AlignCircles.Rects(:,r),...
                    bg.align.AlignCircles.XY(1,r),...
                    bg.align.AlignCircles.XY(2,r));
            end

            % open area
            % free up a central area without bubbles for stimulus presentation
            bg.align.AlignCircles.OpenAreaPix = ...
                bg.align.AlignCircles.OpenArea.* monitor.Deg2Pix;
            OpenRect = [-bg.align.AlignCircles.OpenAreaPix(1)/2 ...
                -bg.align.AlignCircles.OpenAreaPix(2)/2 ...
                bg.align.AlignCircles.OpenAreaPix(1)/2 ...
                bg.align.AlignCircles.OpenAreaPix(2)/2];
            OpenRect = CenterRectOnPoint(OpenRect,...
                monitor.center(1), monitor.center(2));

            % remove bubbles that are in open area
            keepbubbles = true(1,size(bg.align.AlignCircles.XY,2));
            for d = 1:size(bg.align.AlignCircles.XY,2)
                if IsInRect(bg.align.AlignCircles.XY(1,d),...
                        bg.align.AlignCircles.XY(2,d),OpenRect)
                    keepbubbles(d) = false;
                end
            end

            bg.align.AlignCircles.Rects = bg.align.AlignCircles.Rects(:,keepbubbles);
            bg.align.AlignCircles.Colors = bg.align.AlignCircles.Colors(:,keepbubbles);
        end

        % define a fixation dot
        fix.sizepix = round(fix.size.*monitor.Deg2Pix); % size
        fix.rect = [0 0 fix.sizepix fix.sizepix]; % rectangle
        fix.rect = CenterRectOnPoint(fix.rect, ...
            monitor.center(1), monitor.center(2)); % place it in the center
    end

    % Align Crossbars =====================
    % length in pix
    bg.align.Frame.CrossLengthPix = round(...
        bg.align.Frame.CrossLength .* monitor.Deg2Pix);
    % penwidth in pix
    bg.align.Frame.PenWidthPix = round(...
        bg.align.Frame.PenWidth .* monitor.Deg2Pix);
    % there is a maximum for lines and dots that is hardware dependent
    if bg.align.Frame.PenWidthPix > monitor.maxpenwidth
        bg.align.Frame.PenWidthPix = monitor.maxpenwidth;
    end

    %% prestim --
    % prestim are the stimuli used for cueing in the exo/endogenous attention experiments
    for ps = 1:length(prestim)
        switch prestim(ps).type
            case 'grating'
                % Get screen height for square mesh
                s = round(monitor.PixHeight/2);
                % Create mesh for texture
                [x,y] = meshgrid(-s:s-1, -s:s-1);
                % Create the grating
                f = (prestim(ps).sf/monitor.Deg2Pix)*(2*pi); % cycles/pixel
                angle = 0; %basic, we can rotate when drawing
                a = cos(angle)*f; b = sin(angle)*f; phase=0;
                m = sin(a*x+b*y+phase);
                grattex0 = (0.5+0.5*m*prestim(ps).contrast);
                if strcmp(prestim(ps).attentiontype,'exogenous') % for exo, also create an increased contrast version
                    grattex1 = (0.5+0.5*m*...
                        (prestim(ps).contrast + prestim(ps).transient.contrastincr));
                end
                % Create the grating textures
                prestim(ps).GratText0 = ...
                    Screen('MakeTexture', monitor.w, grattex0); %#ok<*AGROW>
                if strcmp(prestim(ps).attentiontype,'exogenous')
                    prestim(ps).GratText1 = ...
                        Screen('MakeTexture', monitor.w, grattex1);
                end
                % speed
                prestim(ps).driftpixsec = round(...
                    prestim(ps).driftspeed.*monitor.Deg2Pix); % invert direction because we shift the cutting rect
                prestim(ps).driftpixframe = round(...
                    prestim(ps).driftpixsec ./ monitor.refreshRate);
                prestim(ps).driftreset = monitor.refreshRate./...
                    (prestim(ps).sf*prestim(ps).driftspeed); % nframes to full period drift
            case 'dots'
                % do most of this on the fly later
                prestim(ps).dotsizepix = round(prestim(ps).dotsize * monitor.Deg2Pix);
                % speed
                prestim(ps).driftpixsec = round(...
                    prestim(ps).driftspeed.*monitor.Deg2Pix);
                prestim(ps).driftpixframe = round(...
                    prestim(ps).driftpixsec ./ monitor.refreshRate);
        end
    end
    %fprintf('Prestim created\n');

    %% stim --
    % the main binocular rivalry stimuli
    for ss = 1:length(stim)
        switch stim(ss).type
            case 'grating'
                % Get screen height for square mesh
                s = round(monitor.PixHeight/2);
                % Create mesh for texture
                [x,y] = meshgrid(-s:s-1, -s:s-1);
                % Create the grating
                f = (stim(ss).sf/monitor.Deg2Pix)*(2*pi); % cycles/pixel
                angle = 0; %basic, we can rotate when drawing
                a = cos(angle)*f; b = sin(angle)*f; phase=0;
                m = sin(a*x+b*y+phase);
                grattex = (0.5+0.5*m*stim(ss).contrast);
                % Create the grating textures
                stim(ss).GratText = ...
                    Screen('MakeTexture', monitor.w, grattex);
                % speed
                stim(ss).driftpixsec = round(...
                    stim(ss).driftspeed.*monitor.Deg2Pix);
                stim(ss).driftpixframe = round(...
                    stim(ss).driftpixsec ./ monitor.refreshRate);
                stim(ss).driftreset = monitor.refreshRate./...
                    (stim(ss).sf*stim(ss).driftspeed); % nframes to full period drift
            case 'dots'
                % do most of this on the fly
                stim(ss).dotsizepix = round(stim(ss).dotsize * monitor.Deg2Pix);
                % speed
                stim(ss).driftpixsec = round(...
                    stim(ss).driftspeed.*monitor.Deg2Pix);
                stim(ss).driftpixframe = round(...
                    stim(ss).driftpixsec ./ monitor.refreshRate);
            case 'image'
                % load image
                stim(ss).imgmat = imread(fullfile(RunPath,'images',stim(ss).image));
                % make greyscale and single luminance values matrix
                if size(stim(ss).imgmat,3) == 3
                    stim(ss).imgmat = uint8(mean(stim(ss).imgmat,3));
                end
                % to texture
                stim(ss).imgtex = Screen('MakeTexture', monitor.w, stim(ss).imgmat);
                switch stim(ss).overlay.type
                    case 'dots'
                        stim(ss).overlay.dotsizepix = ...
                            round(stim(ss).overlay.dotsize * monitor.Deg2Pix);
                    case 'lines'
                        stim(ss).overlay.linewidthpix = ...
                            round(stim(ss).overlay.linewidth * monitor.Deg2Pix);
                end
                % speed
                stim(ss).overlay.driftpixsec = round(...
                    stim(ss).overlay.driftspeed.*monitor.Deg2Pix);
                stim(ss).overlay.driftpixframe = round(...
                    stim(ss).overlay.driftpixsec ./ monitor.refreshRate);
        end
    end


    %% dynamics --
    % define the structure of an eperiment
    if ~expt.blockorder
        expt.blockorder = 1:length(block);
    end
    expt.blocks = [];
    for b = 1:expt.blockrepeats
        if expt.randomizeblocks
            expt.blocks = [expt.blocks randperm(length(block)) ];
        elseif ~isempty(expt.blockorder)
            expt.blocks = [expt.blocks expt.blockorder];
        else
            expt.blocks = [expt.blocks 1:length(block)];
        end
    end

    %% Run the experiment ------
    StopExp = false;

    %% Loop over blocks
    b=1;
    while b <= length(expt.blocks) && ~StopExp
        B = expt.blocks(b);
        TRIALS = []; TL = block(B).trials;
        % create a list of trials for the current block
        if ~isfield(block,'randrepmode')
            block(B).randrepmode = 'randomrepeat';
        end
        switch block(B).randrepmode
            case 'randomrepeat'
                for rt = 1:block(B).repeattrials
                    if block(B).randomizetrials
                        TRIALS = [TRIALS TL(randperm(length(TL)))];
                    else
                        TRIALS = [TRIALS TL];
                    end
                end
            case 'repeatrandom'
                for rt = 1:block(B).repeattrials
                    TRIALS = [TRIALS TL];
                    if block(B).randomizetrials
                        TRIALS = TRIALS(randperm(length(TRIALS)));
                    end
                end
            otherwise
                for rt = 1:block(B).repeattrials
                    if block(B).randomizetrials
                        TRIALS = [TRIALS TL(randperm(length(TL)))];
                    else
                        TRIALS = [TRIALS TL];
                    end
                end
        end

        %% instruction screen -
        for fb = [0 1] % both framebuffers for stereomode
            Screen('SelectStereoDrawBuffer', monitor.w, fb);
            % BG
            Screen('FillRect', monitor.w, bg.color, []);
            % text
            DrawFormattedText(monitor.w,block(B).instruction, ...
                'center','center',bg.textcolor);
        end
        Screen('DrawingFinished',monitor.w);
        vbl = Screen('Flip', monitor.w);

        log.ev = [log.ev; {vbl,'BlockStart',b}]; % log
        if eyetracker.do
            EThndl.sendMessage('BlockStart',vbl); % send message to eyetracker log
        end

        % wait for key
        [secs, ~, ~] = KbWait();
        log.ev = [log.ev; {secs,'KeyStart','none'}];
        if eyetracker.do
            EThndl.sendMessage('KeyStart',secs)
        end

        for fb = [0 1] % both framebuffers for stereomode
            Screen('SelectStereoDrawBuffer', monitor.w, fb);
            Screen('FillRect', monitor.w, bg.color, []); % empty screen with background color
        end
        Screen('DrawingFinished',monitor.w);
        vbl = Screen('Flip', monitor.w);
        pause(0.1) % brief gap with just bg before trial starts

        %% run the trials
        t=1;
        while t <= length(TRIALS) && ~StopExp
            T = TRIALS(t); log.block(b).trial(t).T = T;

            %% generic
            % specify some stimulus-independent features
            StimSizePix = round(trialtype(T).stimsize .* monitor.Deg2Pix);
            bg.align.Frame.SizePix = StimSizePix;


            % create an oval mask to show the stimulus in
            [mX, mY] = meshgrid(1:StimSizePix(1), 1:StimSizePix(2));
            if bg.align.Frame.Type == 0 % oval mask
                maskcenter = StimSizePix/2;
                maskradius = StimSizePix/2;
                dH = (mX - maskcenter(1)) / maskradius(1);
                dV = (mY- maskcenter(2)) / maskradius(2);
                maskmat = (dH.^2 + dV.^2 <= 1);
            else
                maskmat = ones(StimSizePix);
            end

            maskbg = ~isnan(maskmat);
            masktext(:,:,1) = maskbg .* bg.color(1); % file the first 3 layers with background color
            masktext(:,:,2) = maskbg .* bg.color(2);
            masktext(:,:,3) = maskbg .* bg.color(3);
            masktext(:,:,4) = -maskmat+1; % the fourth laye is an opacity mask that defines transparancy

            StimMask = Screen('MakeTexture', monitor.w, masktext); % load the array to texture in video memory
            %fprintf('Mask created\n')

            ps = trialtype(T).prestim; % which prestim?

            %% FIX ----
            FixT0 = 0; vbl = 0;
            for fb = [0 1]
                DrawBackground(monitor, fb, bg);
                DrawAlignFrame(monitor, fb, bg);
                Screen('FillOval', monitor.w, fix.color, fix.rect);
            end
            Screen('DrawingFinished',monitor.w);
            vbl = Screen('Flip', monitor.w);
            FixT0 = vbl;

            log.ev = [log.ev; {vbl,'FixStart',t}]; % log
            if eyetracker.do
                EThndl.sendMessage('FixStart',vbl) % log on eyetracker
            end

            while (GetSecs-FixT0) < trialtype(T).time.FixT && ~StopExp
                % check keys for escape
                [secs, ~, keyCode] = KbCheck;
                if strcmp(KbName(find(keyCode)),keys.esc)
                    StopExp = true;
                    log.ev = [log.ev; {secs,'KeyStop','none'}];
                    if eyetracker.do
                        EThndl.sendMessage('KeyStop',secs)
                    end
                    break;
                end
            end
            vbl = GetSecs;


            %% PRESTIM ----
            % the prestim phase
            if trialtype(T).time.PrestimT % only if a prestim phase is set
                % get a series of orientation for prestim frames
                switch prestim(ps).attentiontype
                    case 'endogenous'
                        psOris = CreatePrestimEndoOri(monitor, prestim, ps); % create a series of orientation values
                    case 'exogenous'
                        % define which videoframes wil show the high contrast stimulus
                        total_fr = round(trialtype(T).time.PrestimT*monitor.refreshRate);
                        trans_frw = round(...
                            prestim(ps).transient.timewindow*monitor.refreshRate + total_fr);
                        trans_frw = Shuffle(trans_frw(1):trans_frw(2));
                        transframes = [trans_frw(1) trans_frw(1)+...
                            round(prestim(ps).transient.duration*monitor.refreshRate)];
                end

                % instruction screen --
                % tell your participants what to do
                for fb = [0 1] % both framebuffers for stereomode
                    % BG
                    DrawBackground(monitor, fb, bg);
                    % text
                    if ~isempty(prestim(ps).instruct)
                        DrawFormattedText(monitor.w,prestim(ps).instruct, ...
                            'center','center',bg.textcolor);
                    else
                        DrawFormattedText(monitor.w,'Press key', ...
                            'center','center',bg.textcolor);
                    end
                end
                Screen('DrawingFinished',monitor.w);
                vbl = Screen('Flip', monitor.w);

                % wait for key
                [secs, ~, ~] = KbWait();

                PreStimStarted = false;
                PreStimT0 = 0; vbl = 0; cF = 0;

                % safety check
                if strcmp(prestim(ps).attentiontype,'endogenous') && ...
                        sum(prestim(ps).durations) < trialtype(T).time.PrestimT
                    PreStimT = sum(prestim(ps).durations);
                    fprintf(['ALERT: Your requested prestim time of ' ...
                        num2str(trialtype(T).time.PrestimT) 's is longer than ' ...
                        'your prestim definition of ' num2str(PreStimT) 's.\n']);
                    fprintf(['The prestim time was adjusted down to ' ...
                        num2str(PreStimT) 's. Check your settings file.\n']);
                else
                    PreStimT = trialtype(T).time.PrestimT;
                end

                f=1; % framenumber
                while (vbl - PreStimT0) < PreStimT && ~StopExp
                    %[vbl - PreStimT0 f]

                    % run this for the predetermined duration
                    % show the stimulus
                    for fb = [0 1]
                        DrawBackground(monitor, fb, bg);
                        switch prestim(ps).attentiontype
                            case 'endogenous'
                                switch prestim(ps).type
                                    case 'grating'
                                        for a = 1:2
                                            % - get rect
                                            rectshift = ...
                                                mod(cF,prestim(ps).driftreset(a)) * ...
                                                prestim(ps).driftpixframe(a);
                                            grect = [rectshift 0 ...
                                                StimSizePix(1)+rectshift StimSizePix(2)];
                                            drect = [0 0 StimSizePix(1) StimSizePix(2)];
                                            drect = CenterRectOnPoint(drect,...
                                                monitor.center(1), monitor.center(2));

                                            % - draw
                                            Screen('DrawTexture',monitor.w, ...
                                                prestim(ps).GratText0, ...
                                                grect,drect,...
                                                psOris(a,cF+1)+180,...
                                                [],0.5); % add 180 because we drift the cutting rect
                                            Screen('DrawTexture', monitor.w, ....
                                                StimMask, [], drect, psOris(a,cF+1));
                                        end
                                    case 'dots'
                                        for a=1:2
                                            % - first frame
                                            if cF == 0
                                                % locations
                                                prestim(ps).nDots = round(...
                                                    prestim(ps).dotdensity * ...
                                                    trialtype(T).stimsize(1) * ...
                                                    trialtype(T).stimsize(2));
                                                prestim(ps).dot.xy{a} = [...
                                                    round(- StimSizePix(1)/2 + ...
                                                    rand(1,prestim(ps).nDots).*StimSizePix(1)); ...
                                                    round(- StimSizePix(2)/2 + ...
                                                    rand(1,prestim(ps).nDots).*StimSizePix(1))];

                                                % colors
                                                if ~isempty(prestim(ps).color)
                                                    prestim(ps).dotcol = prestim(ps).color(a,:);
                                                    prestim(ps).dotcols{a} = prestim(ps).dotcol;
                                                else
                                                    if prestim(ps).contrastbin
                                                        prestim(ps).dotcol(a,:) = 0.5 + ...
                                                            (round(rand(1,prestim(ps).nDots)).*prestim(ps).contrast) - ...
                                                            prestim(ps).contrast/2;
                                                    else
                                                        prestim(ps).dotcol(a,:) = 0.5 + ...
                                                            (rand(1,prestim(ps).nDots).*prestim(ps).contrast) - ...
                                                            prestim(ps).contrast/2;
                                                    end
                                                    prestim(ps).dotcols{a} = [...
                                                        prestim(ps).dotcol(a,:);...
                                                        prestim(ps).dotcol(a,:);...
                                                        prestim(ps).dotcol(a,:)];
                                                end
                                                % dot age
                                                prestim(ps).dotage(a,:) = round(rand(1,prestim(ps).nDots).*...
                                                    prestim(ps).dotlifetime);

                                            else
                                                % in case we want just one frame too many due to
                                                if f > size(psOris,2)
                                                    f = size(psOris,2);
                                                end

                                                % - move
                                                prestim(ps).driftpixframeXY = [...
                                                    sind(psOris(a,f)).* prestim(ps).driftpixframe(a) ...
                                                    cosd(psOris(a,f)).* prestim(ps).driftpixframe(a)];

                                                for d=1:2
                                                    prestim(ps).dot.xy{a}(d,:) = ...
                                                        prestim(ps).dot.xy{a}(d,:) + prestim(ps).driftpixframeXY(d);
                                                    oof = prestim(ps).dot.xy{a}(d,:) > ...
                                                        round(StimSizePix(d)/2);
                                                    prestim(ps).dot.xy{a}(d,oof) = prestim(ps).dot.xy{a}(d,oof) - ...
                                                        round(StimSizePix(d)/2);
                                                    oof = prestim(ps).dot.xy{a}(d,:) < ...
                                                        round(-StimSizePix(d)/2);
                                                    prestim(ps).dot.xy{a}(d,oof) = prestim(ps).dot.xy{a}(d,oof) + ...
                                                        round(StimSizePix(d)/2);
                                                end

                                                prestim(ps).dotage(a,:) = prestim(ps).dotage(a,:)+1;
                                                if ~isempty(prestim(ps).dotlifetime)
                                                    dd = prestim(ps).dotage(a,:) > prestim(ps).dotlifetime;
                                                    prestim(ps).dotage(a,dd) = prestim(ps).dotage(a,dd)-...
                                                        prestim(ps).dotlifetime;
                                                    % new locations for 'dead dots'
                                                    newdotsxy = [...
                                                        round(-StimSizePix(1)/2 + ...
                                                        rand(1,prestim(ps).nDots).*StimSizePix(1)); ...
                                                        round(- StimSizePix(2)/2 + ...
                                                        rand(1,prestim(ps).nDots).*StimSizePix(1))];
                                                    prestim(ps).dot.xy{a}(1,dd) = newdotsxy(1,dd);
                                                    prestim(ps).dot.xy{a}(2,dd) = newdotsxy(2,dd);
                                                end
                                            end

                                            % - draw
                                            Screen('DrawDots',monitor.w,...
                                                prestim(ps).dot.xy{a}, prestim(ps).dotsizepix, ...
                                                prestim(ps).dotcols{a},monitor.center,1);

                                        end
                                        drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                                        drect = CenterRectOnPoint(drect,...
                                            monitor.center(1), monitor.center(2));
                                        Screen('DrawTexture', monitor.w, ....
                                            StimMask, [], drect, []);
                                end
                            case 'exogenous'
                                switch prestim(ps).type
                                    case 'grating'
                                        for a=1:2
                                            % - get rect
                                            rectshift = ...
                                                mod(cF,prestim(ps).driftreset(a)).* ...
                                                prestim(ps).driftpixframe(a);
                                            grect = [rectshift 0 ...
                                                StimSizePix(1)+rectshift StimSizePix(2)];
                                            drect = [0 0 StimSizePix(1) StimSizePix(2)];
                                            drect = CenterRectOnPoint(drect,...
                                                monitor.center(1), monitor.center(2));
                                            % - draw
                                            if f >= transframes(1) && f <= transframes(2) && ...
                                                    a == prestim(ps).transient.stim
                                                Screen('DrawTexture',monitor.w, ...
                                                    prestim(ps).GratText1, ...
                                                    grect,drect,...
                                                    prestim(ps).orient(a)+180,...
                                                    [],0.5); % add 180 because we drift the cutting rect
                                            else
                                                Screen('DrawTexture',monitor.w, ...
                                                    prestim(ps).GratText0, ...
                                                    grect,drect,...
                                                    prestim(ps).orient(a)+180,...
                                                    [],0.5); % add 180 because we drift the cutting rect
                                            end
                                            Screen('DrawTexture', monitor.w, ....
                                                StimMask, [], drect, prestim(ps).orient(a));
                                        end
                                    case 'dots'
                                        for a=1:2
                                            % - first frame
                                            if cF == 0
                                                % locations
                                                prestim(ps).nDots = round(...
                                                    prestim(ps).dotdensity * ...
                                                    trialtype(T).stimsize(1) * ...
                                                    trialtype(T).stimsize(2));
                                                prestim(ps).dot.xy{a} = [...
                                                    round(- StimSizePix(1)/2 + ...
                                                    rand(1,prestim(ps).nDots).*StimSizePix(1)); ...
                                                    round(- StimSizePix(2)/2 + ...
                                                    rand(1,prestim(ps).nDots).*StimSizePix(1))];

                                                % colors
                                                if ~isempty(prestim(ps).color)
                                                    prestim(ps).dotcol = prestim(ps).color(a,:);
                                                    prestim(ps).dotcols{a} = prestim(ps).dotcol;
                                                    prestim(ps).dotcoltrans = prestim(ps).color(a,:)+...
                                                        prestim(ps).transient.contrastincr;
                                                    prestim(ps).dotcolstrans{a} = prestim(ps).dotcoltrans;
                                                else
                                                    if prestim(ps).contrastbin
                                                        prestim(ps).dotcol(a,:) = 0.5 + ...
                                                            (round(rand(1,prestim(ps).nDots)).*prestim(ps).contrast) - ...
                                                            prestim(ps).contrast/2;
                                                        coltrans = ...
                                                            prestim(ps).contrast+prestim(ps).transient.contrastincr;
                                                        prestim(ps).dotcoltrans(a,:) = 0.5 + ...
                                                            (round(rand(1,prestim(ps).nDots)).*coltrans) - ...
                                                            coltrans/2;
                                                    else
                                                        prestim(ps).dotcol(a,:) = 0.5 + ...
                                                            (rand(1,prestim(ps).nDots).*prestim(ps).contrast) - ...
                                                            prestim(ps).contrast/2;
                                                        coltrans = ...
                                                            prestim(ps).contrast+prestim(ps).transient.contrastincr;
                                                        prestim(ps).dotcoltrans(a,:) = 0.5 + ...
                                                            (rand(1,prestim(ps).nDots).*coltrans) - ...
                                                            coltrans/2;
                                                    end
                                                    prestim(ps).dotcols{a} = [...
                                                        prestim(ps).dotcol(a,:);...
                                                        prestim(ps).dotcol(a,:);...
                                                        prestim(ps).dotcol(a,:)];
                                                    prestim(ps).dotcolstrans{a} = [...
                                                        prestim(ps).dotcoltrans(a,:);...
                                                        prestim(ps).dotcoltrans(a,:);...
                                                        prestim(ps).dotcoltrans(a,:)];
                                                end
                                                % dot age
                                                prestim(ps).dotage(a,:) = round(rand(1,prestim(ps).nDots).*...
                                                    prestim(ps).dotlifetime);
                                            else
                                                % - move
                                                for d=1:2
                                                    prestim(ps).dot.xy{a}(d,:) = ...
                                                        prestim(ps).dot.xy{a}(d,:) + prestim(ps).driftpixframe(a,d);
                                                    oof = prestim(ps).dot.xy{a}(d,:) > ...
                                                        round(StimSizePix(d)/2);
                                                    prestim(ps).dot.xy{a}(d,oof) = prestim(ps).dot.xy{a}(d,oof) - ...
                                                        round(StimSizePix(d)/2);
                                                    oof = prestim(ps).dot.xy{a}(d,:) < ...
                                                        round(-StimSizePix(d)/2);
                                                    prestim(ps).dot.xy{a}(d,oof) = prestim(ps).dot.xy{a}(d,oof) + ...
                                                        round(StimSizePix(d)/2);
                                                end


                                                prestim(ps).dotage(a,:) = prestim(ps).dotage(a,:)+1;
                                                if ~isempty(prestim(ps).dotlifetime)
                                                    dd = prestim(ps).dotage(a,:) > prestim(ps).dotlifetime;
                                                    prestim(ps).dotage(a,dd) = prestim(ps).dotage(a,dd)-...
                                                        prestim(ps).dotlifetime;
                                                    % new locations for 'dead dots'
                                                    newdotsxy = [...
                                                        round(-StimSizePix(1)/2 + ...
                                                        rand(1,prestim(ps).nDots).*StimSizePix(1)); ...
                                                        round(- StimSizePix(2)/2 + ...
                                                        rand(1,prestim(ps).nDots).*StimSizePix(1))];
                                                    prestim(ps).dot.xy{a}(1,dd) = newdotsxy(1,dd);
                                                    prestim(ps).dot.xy{a}(2,dd) = newdotsxy(2,dd);
                                                end
                                            end

                                            % - draw
                                            if f >= transframes(1) && f <= transframes(2) && ...
                                                    a == prestim(ps).transient.stim
                                                %fprintf('drawing transient\n')
                                                Screen('DrawDots',monitor.w,...
                                                    prestim(ps).dot.xy{a}, prestim(ps).dotsizepix, ...
                                                    prestim(ps).dotcolstrans{a},monitor.center,1);
                                            else
                                                Screen('DrawDots',monitor.w,...
                                                    prestim(ps).dot.xy{a}, prestim(ps).dotsizepix, ...
                                                    prestim(ps).dotcols{a},...
                                                    monitor.center,1);
                                            end
                                        end
                                        drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                                        drect = CenterRectOnPoint(drect,...
                                            monitor.center(1), monitor.center(2));
                                        Screen('DrawTexture', monitor.w, ....
                                            StimMask, [], drect, []);
                                end
                        end

                        % draw the alignment frame
                        DrawAlignFrame(monitor, fb, bg);

                        % draw the fixation dot
                        Screen('FillOval', monitor.w, fix.color, fix.rect);
                    end
                    Screen('DrawingFinished',monitor.w);
                    vbl = Screen('Flip', monitor.w, vbl+0.9*monitor.FrameDur);
                    cF=cF+1; f=f+1;

                    % log the start of the prestim period
                    if ~PreStimStarted
                        log.ev = [log.ev; {vbl,'PreStimStart',T}];
                        if eyetracker.do
                            EThndl.sendMessage('PreStimStart',vbl)
                        end
                        PreStimStarted = true;
                        PreStimT0 = vbl;
                    end

                end

                % question and response screen --
                % instruction screen --
                for fb = [0 1] % both framebuffers for stereomode
                    % BG
                    DrawBackground(monitor, fb, bg);
                    % text
                    DrawFormattedText(monitor.w,prestim(ps).quest, ...
                        'center','center',bg.textcolor);
                end
                Screen('DrawingFinished',monitor.w);
                vbl = Screen('Flip', monitor.w);

                % wait for key response
                if strcmp(prestim(ps).attentiontype,'endogenous')
                    RespLogged = false;
                    while  ~RespLogged
                        [KeyIsDown,keys.secs,keys.keyCode] = KbCheck;
                        if KeyIsDown
                            keys.LastKey = KbName(find(keys.keyCode)); % Get the name of the pressed key
                            if any(strcmp(keys.LastKey,keys.resp))
                                log.ev = [log.ev; {keys.secs,'PreStimResponse',keys.LastKey}];
                                RespLogged = true;
                            elseif strcmp(keys.LastKey,keys.esc)
                                RespLogged = true;
                                StopExp = true;
                                break;
                            end
                        end
                    end
                    % wait for key to be released
                    while KeyIsDown
                        [KeyIsDown,~,~] = KbCheck;
                    end
                else
                    % wait for a bit
                    WaitSecs(prestim(ps).transient.postpause);
                end
            end

            %% GAP ---
            % a brief empty screen before the main stimulus starts
            % bg alignment
            for fb = [0 1]
                DrawBackground(monitor, fb, bg);
                DrawAlignFrame(monitor, fb, bg);
            end
            Screen('DrawingFinished',monitor.w);
            vbl = Screen('Flip', monitor.w);
            GapT0 = vbl;

            % log
            log.ev = [log.ev; {vbl,'GapStart',T}];
            if eyetracker.do
                EThndl.sendMessage('GapStart',vbl)
            end

            % start audio recording here
            if sound.recordmic
                % start recording sound --
                PsychPortAudio('Start', hmic, 0, 0, 1);
                voicetrack = [];
                s = PsychPortAudio('GetStatus', hmic);
                % play a beep to mark the start
                % Start playback immediately, wait for start, play once:
                PsychPortAudio('Start', hplay, 1, 0, 1);
            end

            while (GetSecs - GapT0) < trialtype(T).time.PrestimGapT && ~StopExp
                % check keys for escape
                [~, ~, keyCode] = KbCheck;
                if strcmp(KbName(find(keyCode)),keys.esc)
                    StopExp = true;
                    break;
                end
            end
            vbl = GetSecs;


            %% STIM ---
            % the main stimulus phase
            StimStarted = 0; EpochStarted = 0;
            StimT0 = 0; vbl = 0; cF = 0;
            keys.KeyWasDown = false;
            keys.KeyIsDown = false;
            keys.LastKey = [];
            keys.PrevKey = [];
            NewEpoch = true; NewEpochT = false;
            replaystim = ceil(2*rand(1)); % random 1 or 2
            %fprintf('Starting stim\n')

            % prep overlays if necessary
            for es=1:2
                ss = trialtype(T).eye(es).stim;
                if strcmp(stim(ss).type,'image')
                    switch stim(ss).overlay.type
                        case 'dots'
                            % locations
                            stim(ss).overlay.nDots = round(...
                                stim(ss).overlay.dotdensity * ...
                                trialtype(T).stimsize(1) * ...
                                trialtype(T).stimsize(2));
                            stim(ss).overlay.dotfb(fb+1).xy = [...
                                round(- StimSizePix(1)/2 + ...
                                rand(1,stim(ss).overlay.nDots).*StimSizePix(1)); ...
                                round(- StimSizePix(2)/2 + ...
                                rand(1,stim(ss).overlay.nDots).*StimSizePix(2))];
                            % colors
                            if ~isempty(stim(ss).overlay.color)
                                stim(ss).overlay.dotcol = [stim(ss).overlay.color ...
                                    stim(ss).overlay.opacity];
                            else
                                if stim(ss).overlay.contrastbin
                                    stim(ss).overlay.dotcol = 0.5 + ...
                                        (round(rand(1,stim(ss).overlay.nDots)).*stim(ss).overlay.contrast) - ...
                                        stim(ss).overlay.contrast/2;
                                else
                                    stim(ss).overlay.dotcol = 0.5 + ...
                                        (rand(1,stim(ss).overlay.nDots).*stim(ss).overlay.contrast) - ...
                                        stim(ss).overlay.contrast/2;
                                end
                                stim(ss).overlay.dotcol = [...
                                    stim(ss).overlay.dotcol;...
                                    stim(ss).overlay.dotcol;...
                                    stim(ss).overlay.dotcol;...
                                    stim(ss).overlay.opacity*ones(1,stim(ss).overlay.nDots)];
                            end

                            % dot age
                            if ~isempty(stim(ss).overlay.dotlifetime)
                                stim(ss).overlay.dotage = round(rand(1,stim(ss).overlay.nDots).*...
                                    stim(ss).overlay.dotlifetime);
                            else
                                stim(ss).overlay.dotage = ones(1,stim(ss).overlay.nDots);
                            end

                        case 'lines'
                            switch stim(ss).overlay.orientation
                                case 'horizontal'
                                    stim(ss).overlay.nLines = ...
                                        round(...
                                        stim(ss).overlay.linedensity * ...
                                        trialtype(T).stimsize(1));
                                    stim(ss).overlay.linexy = zeros(1,2*stim(ss).overlay.nLines);
                                    stim(ss).overlay.linexy(1,1:2:end) = -StimSizePix(1)/2;
                                    stim(ss).overlay.linexy(1,2:2:end) = StimSizePix(1)/2;
                                    stim(ss).overlay.linexy(2,1:2:end) = -StimSizePix(2)/2 : ...
                                        StimSizePix(2)/stim(ss).overlay.nLines : ...
                                        StimSizePix(2)/2 - StimSizePix(2)/stim(ss).overlay.nLines;
                                    stim(ss).overlay.linexy(2,2:2:end) = stim(ss).overlay.linexy(2,1:2:end);

                                case 'vertical'
                                    stim(ss).overlay.nLines = ...
                                        round(...
                                        stim(ss).overlay.linedensity * ...
                                        trialtype(T).stimsize(2));
                                    stim(ss).overlay.linexy = zeros(1,2*stim(ss).overlay.nLines);
                                    stim(ss).overlay.linexy(2,1:2:end) = -StimSizePix(2)/2;
                                    stim(ss).overlay.linexy(2,2:2:end) = StimSizePix(2)/2;
                                    stim(ss).overlay.linexy(1,1:2:end) = -StimSizePix(1)/2 : ...
                                        StimSizePix(1)/stim(ss).overlay.nLines : ...
                                        StimSizePix(1)/2 - StimSizePix(1)/stim(ss).overlay.nLines;
                                    stim(ss).overlay.linexy(1,2:2:end) = stim(ss).overlay.linexy(1,1:2:end);
                            end
                            stim(ss).overlay.linecol = [stim(ss).overlay.color ...
                                stim(ss).overlay.opacity];

                    end
                end
            end

            while vbl-StimStarted < trialtype(T).time.StimT  && ~StopExp
                if trialtype(T).replay
                    if ~StimStarted || NewEpoch
                        CurrEpochDur = trialtype(T).replay(1) + ...
                            (trialtype(T).replayminmax(2)-...
                            trialtype(T).replayminmax(1))*rand(1);
                        NewEpoch = false; NewEpochT = true;
                        if replaystim == 1
                            replaystim = 2;
                        elseif replaystim == 2
                            replaystim = 1;
                        end
                        si = [replaystim replaystim];
                    else
                        NewEpochT = false;
                    end
                else
                    si = [1 2];
                end


                % stim
                for fb = [0 1]
                    DrawBackground(monitor, fb, bg);
                    % which stim
                    %ss = trialtype(T).eye(si(fb+1)).stim;
                    ss = trialtype(T).eye(si(fb+1)).stim;
                    switch stim(ss).type
                        case 'grating'
                            % - get rect
                            rectshift = ...
                                mod(cF,stim(ss).driftreset) * ...
                                stim(ss).driftpixframe;
                            grect = [rectshift 0 ...
                                StimSizePix(1)+rectshift StimSizePix(2)];
                            drect = [0 0 StimSizePix(1) StimSizePix(2)];
                            drect = CenterRectOnPoint(drect,...
                                monitor.center(1), monitor.center(2));

                            % - draw
                            Screen('DrawTexture',monitor.w, ...
                                stim(ss).GratText, ...
                                grect,drect,...
                                stim(ss).orient+180); % add 180 because we drift the cutting rect
                            Screen('DrawTexture', monitor.w, ....
                                StimMask, [], drect, stim(ss).orient);
                        case 'dots'
                            % - first frame
                            if cF == 0
                                % locations
                                stim(ss).nDots = round(...
                                    stim(ss).dotdensity * ...
                                    trialtype(T).stimsize(1) * ...
                                    trialtype(T).stimsize(2));
                                stim(ss).dotfb(fb+1).xy = [...
                                    round(- StimSizePix(1)/2 + ...
                                    rand(1,stim(ss).nDots).*StimSizePix(1)); ...
                                    round(- StimSizePix(2)/2 + ...
                                    rand(1,stim(ss).nDots).*StimSizePix(1))];
                                % colors
                                if ~isempty(stim(ss).color)
                                    stim(ss).dotcol = stim(ss).color;
                                else
                                    if stim(ss).contrastbin
                                        stim(ss).dotcol = 0.5 + ...
                                            (round(rand(1,stim(ss).nDots)).*stim(ss).contrast) - ...
                                            stim(ss).contrast/2;
                                        stim(ss).dotcol = [stim(ss).dotcol;stim(ss).dotcol;stim(ss).dotcol];
                                    else
                                        stim(ss).dotcol = 0.5 + ...
                                            (rand(1,stim(ss).nDots).*stim(ss).contrast) - ...
                                            stim(ss).contrast/2;
                                        stim(ss).dotcol = [stim(ss).dotcol;stim(ss).dotcol;stim(ss).dotcol];
                                    end
                                end

                                % dot age
                                stim(ss).dotage = round(rand(1,stim(ss).nDots).*...
                                    stim(ss).dotlifetime);
                            else
                                % - move
                                for a = 1:2
                                    stim(ss).dotfb(fb+1).xy(a,:) = stim(ss).dotfb(fb+1).xy(a,:) + ...
                                        stim(ss).driftpixframe(a);
                                    oof = stim(ss).dotfb(fb+1).xy(a,:) > ...
                                        round(StimSizePix(a)/2);
                                    stim(ss).dotfb(fb+1).xy(a,oof) = stim(ss).dotfb(fb+1).xy(a,oof) - ...
                                        round(StimSizePix(a)/2);
                                    oof = stim(ss).dotfb(fb+1).xy(a,:) < ...
                                        round(-StimSizePix(a)/2);
                                    stim(ss).dotfb(fb+1).xy(a,oof) = stim(ss).dotfb(fb+1).xy(a,oof) + ...
                                        round(StimSizePix(a)/2);
                                end

                                stim(ss).dotage = stim(ss).dotage+1;
                                if ~isempty(stim(ss).dotlifetime)
                                    dd = stim(ss).dotage > stim(ss).dotlifetime;
                                    stim(ss).dotage(dd) = stim(ss).dotage(dd)-...
                                        stim(ss).dotlifetime;
                                    % new locations for 'dead dots'
                                    newdotsxy = [...
                                        round(-StimSizePix(1)/2 + ...
                                        rand(1,stim(ss).nDots).*StimSizePix(1)); ...
                                        round(- StimSizePix(2)/2 + ...
                                        rand(1,stim(ss).nDots).*StimSizePix(1))];
                                    stim(ss).dotfb(fb+1).xy(:,dd) = newdotsxy(:,dd);
                                end
                            end
                            % - draw
                            Screen('DrawDots',monitor.w,...
                                stim(ss).dotfb(fb+1).xy, stim(ss).dotsizepix, ...
                                stim(ss).dotcol,monitor.center,1);
                            drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                            drect = CenterRectOnPoint(drect,...
                                monitor.center(1), monitor.center(2));
                            Screen('DrawTexture', monitor.w, ....
                                StimMask, [], drect, []);
                        case 'image'
                            drect = [0 0 StimSizePix(1) StimSizePix(2)];
                            drect = CenterRectOnPoint(drect,...
                                monitor.center(1),monitor.center(2));
                            if isfield(stim,'rotation')
                                rot=stim(ss).rotation;
                            else
                                rot=[];
                            end
                            Screen('DrawTexture', monitor.w,...
                                stim(ss).imgtex,[],drect,rot);
                            switch stim(ss).overlay.type
                                case 'dots'
                                    if cF == 0 % - first frame
                                        % nothing
                                    else
                                        % - move
                                        for a = 1:2
                                            stim(ss).overlay.dotfb(fb+1).xy(a,:) = stim(ss).overlay.dotfb(fb+1).xy(a,:) + ...
                                                stim(ss).overlay.driftpixframe(a);
                                            oof = stim(ss).overlay.dotfb(fb+1).xy(a,:) > ...
                                                StimSizePix(a)/2;
                                            stim(ss).overlay.dotfb(fb+1).xy(a,oof) = stim(ss).overlay.dotfb(fb+1).xy(a,oof) - ...
                                                StimSizePix(a);
                                            oof = stim(ss).overlay.dotfb(fb+1).xy(a,:) < ...
                                                -StimSizePix(a)/2;
                                            stim(ss).overlay.dotfb(fb+1).xy(a,oof) = stim(ss).overlay.dotfb(fb+1).xy(a,oof) + ...
                                                StimSizePix(a);
                                        end

                                        stim(ss).overlay.dotage = stim(ss).overlay.dotage+1;
                                        if ~isempty(stim(ss).overlay.dotlifetime)
                                            dd = stim(ss).overlay.dotage > stim(ss).overlay.dotlifetime;
                                            stim(ss).overlay.dotage(dd) = stim(ss).overlay.dotage(dd)-...
                                                stim(ss).overlay.dotlifetime;
                                            % new locations for 'dead dots'
                                            newdotsxy = [...
                                                round(-StimSizePix(1)/2 + ...
                                                rand(1,stim(ss).overlay.nDots).*StimSizePix(1)); ...
                                                round(- StimSizePix(2)/2 + ...
                                                rand(1,stim(ss).overlay.nDots).*StimSizePix(2))];
                                            stim(ss).overlay.dotfb(fb+1).xy(:,dd) = newdotsxy(:,dd);
                                        end
                                    end
                                    % - draw
                                    Screen('DrawDots',monitor.w,...
                                        stim(ss).overlay.dotfb(fb+1).xy, stim(ss).overlay.dotsizepix, ...
                                        stim(ss).overlay.dotcol,monitor.center,1);
                                    drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                                    drect = CenterRectOnPoint(drect,...
                                        monitor.center(1), monitor.center(2));
                                    Screen('DrawTexture', monitor.w, ....
                                        StimMask, [], drect, []);
                                case 'lines'
                                    if cF == 0 % first frame
                                        % nothing
                                    else
                                        switch stim(ss).overlay.orientation
                                            case 'horizontal'
                                                stim(ss).overlay.linexy(2,:) = stim(ss).overlay.linexy(2,:) + stim(ss).overlay.driftpixframe;
                                                oof = stim(ss).overlay.linexy(2,:) > StimSizePix(2)/2;
                                                stim(ss).overlay.linexy(2,oof) = stim(ss).overlay.linexy(2,oof)-StimSizePix(2);
                                                oof = stim(ss).overlay.linexy(2,:) < -StimSizePix(2)/2;
                                                stim(ss).overlay.linexy(2,oof) = stim(ss).overlay.linexy(2,oof)+StimSizePix(2);
                                            case 'vertical'
                                                stim(ss).overlay.linexy(1,:) = stim(ss).overlay.linexy(1,:) + stim(ss).overlay.driftpixframe;
                                                oof = stim(ss).overlay.linexy(1,:) > StimSizePix(1)/2;
                                                stim(ss).overlay.linexy(1,oof) = stim(ss).overlay.linexy(1,oof)-StimSizePix(1);
                                                oof = stim(ss).overlay.linexy(1,:) < -StimSizePix(1)/2;
                                                stim(ss).overlay.linexy(1,oof) = stim(ss).overlay.linexy(1,oof)+StimSizePix(1);
                                        end
                                    end
                                    % - draw

                                    Screen('DrawLines',monitor.w,...
                                        stim(ss).overlay.linexy, stim(ss).overlay.linewidthpix, ...
                                        stim(ss).overlay.linecol,monitor.center,0);
                                    drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                                    drect = CenterRectOnPoint(drect,...
                                        monitor.center(1), monitor.center(2));
                                    Screen('DrawTexture', monitor.w, ....
                                        StimMask, [], drect, []);
                            end
                    end
                end
                %fprintf('stim done\n')

                % alignment after stimulus
                for fb = [0 1]
                    DrawAlignFrame(monitor, fb, bg);
                end
                %fprintf('align done\n')

                % fixation dot
                for fb = [0 1]
                    Screen('SelectStereoDrawBuffer', monitor.w, fb);
                    Screen('FillOval', monitor.w, fix.color, fix.rect);
                end
                Screen('DrawingFinished',monitor.w);
                %fprintf('fix done\n')

                vbl = Screen('Flip', monitor.w, vbl+0.9*monitor.FrameDur);
                cF= cF + 1; % current frame update
                %fprintf('flip reached\n')

                if ~StimStarted
                    % log
                    log.ev = [log.ev; {vbl,'StimStart',T}];
                    if eyetracker.do
                        EThndl.sendMessage('StimStart',vbl)
                    end
                    StimStarted = vbl;
                    if trialtype(T).replay
                        EpochStarted = vbl;
                    end
                end

                if trialtype(T).replay  && NewEpochT
                    EpochStarted = vbl;
                    % log
                    log.ev = [log.ev; {vbl,'EpochStart',[T si(fb+1)]}];
                    if eyetracker.do
                        EThndl.sendMessage('EpochStart',vbl)
                    end
                end

                if trialtype(T).replay && ...
                        vbl - EpochStarted >= CurrEpochDur
                    NewEpoch = true;
                end

                % get keypresses
                [keys] = CheckKeyPresses(keys);
                if strcmp(keys.LastKey,keys.esc)
                    StopExp = true;
                    log.ev = [log.ev; {keys.secs,'KeyStop','none'}];
                    if eyetracker.do
                        EThndl.sendMessage('KeyStop',secs)
                    end
                    break;
                elseif keys.LogKeyRelease
                    log.ev = [log.ev; {keys.secs,'KeyRelease',keys.PrevKey}];
                elseif keys.LogNewKey
                    log.ev = [log.ev; {keys.secs,'KeyPress',keys.LastKey}];
                    keys.PrevKey = keys.LastKey;
                end

                % Can we fetch the mic buffer every screen refresh? --
                % we may need to time this differently
                if sound.recordmic
                    % Retrieve pending audio data from the internal buffer
                    audiodata = PsychPortAudio('GetAudioData', hmic);
                    nrsamples = size(audiodata, 2);
                    % And attach it to our full sound vector:
                    voicetrack = [voicetrack audiodata];
                end
            end

            % done with stimulus
            log.ev = [log.ev; {vbl,'StimStop',T}];
            if eyetracker.do
                EThndl.sendMessage('StimStop',vbl)
            end
            StimStarted = true;

            % Do a response moment if requested
            if ~isempty(trialtype(T).poststimquest) && strcmp(block(B).reportmode, 'key')
                for fb = [0 1] % both framebuffers for stereomode
                    % BG
                    DrawBackground(monitor, fb, bg);
                    % text
                    DrawFormattedText(monitor.w,trialtype(T).poststimquest, ...
                        'center','center',bg.textcolor);
                end
                Screen('DrawingFinished',monitor.w);
                vbl = Screen('Flip', monitor.w);

                % wait for key response
                RespLogged = false;
                while  ~RespLogged
                    [KeyIsDown,keys.secs,keys.keyCode] = KbCheck;
                    if KeyIsDown
                        keys.LastKey = KbName(find(keys.keyCode)); % Get the name of the pressed key
                        if any(strcmp(keys.LastKey,keys.resp))
                            log.ev = [log.ev; {keys.secs,'PostStimResponse',keys.LastKey}];
                            RespLogged = true;
                        elseif strcmp(keys.LastKey,keys.esc)
                            RespLogged = true;
                            StopExp = true;
                            break;
                        end
                    end
                end
                % wait for key to be released
                while KeyIsDown
                    [KeyIsDown,~,~] = KbCheck;
                end
            end

            % stop audio capture
            if sound.recordmic
                % Stop audio capture --
                PsychPortAudio('Stop', hmic);
                PsychPortAudio('Stop', hplay, 1);
                % last fetch
                audiodata = PsychPortAudio('GetAudioData', hmic);
                % Attach it to our full sound vector:
                voicetrack = [voicetrack audiodata];
                log.block(b).trial(t).voicetrack = voicetrack;
                if size(log.block(b).trial(t).voicetrack,1) == 1
                    log.block(b).trial(t).voicetrack = [...
                        log.block(b).trial(t).voicetrack;log.block(b).trial(t).voicetrack];
                end
                log.block(b).trial(t).voicefile = ...
                    ['voice_b-' num2str(b,'%03d') '_t-' num2str(t,'%03d') '.wav'];
                voicetrack = [];
                % % Close the audio device --
                % PsychPortAudio('Close', hmic);
                % PsychPortAudio('Close', hplay);
                % Save the sound file to 'sndfile'
                sndfile = fullfile(RunPath, log.fld, log.Label, log.block(b).trial(t).voicefile);
                if ~isempty(sndfile)
                    psychwavwrite(transpose(log.block(b).trial(t).voicetrack), sndfreq, 16, sndfile)
                end
            end

            t=t+1; % next trial


            %% ITI ---
            % intertrial interval
            % bg alignment
            for fb = [0 1]
                DrawBackground(monitor, fb, bg);
                DrawAlignFrame(monitor, fb, bg);
            end
            Screen('DrawingFinished',monitor.w);
            vbl = Screen('Flip', monitor.w);
            ITIT0 = vbl;

            log.ev = [log.ev; {vbl,'ITIStart',T}];
            if eyetracker.do
                EThndl.sendMessage('ITIStart',vbl)
            end

            while (GetSecs - ITIT0) < trialtype(T).time.ITIT && ~StopExp
                % check keys for escape
                [~, ~, keyCode] = KbCheck;
                if strcmp(KbName(find(keyCode)),keys.esc)
                    StopExp = true;
                    break;
                end
            end
            vbl = GetSecs;

        end
        b=b+1; % next block
    end
    %% Save the logs ------
    % create some order in the variables
    settings.monitor = monitor; settings.eyetracker = eyetracker;
    settings.sound = sound; settings.keys = keys;
    settings.bg = bg; settings.fix = fix; settings.prestim = prestim; settings.stim = stim;
    settings.trialtype = trialtype;
    settings.block = block; settings.expt = expt;
    % save the log
    save(fullfile(RunPath, log.fld, log.Label, 'logfile'),'settings','log');

    % save the eye data and close off tracker
    if eyetracker.do
        EThndl.buffer.stop('gaze'); % close the buffer
        fn = ['eyedata_' log.Label]; % create a label
        EThndl.saveData(fullfile(RunPath,log.fld,log.Label,fn), true); % save
        EThndl.deInit(); % shut down
    end

    % close the audiodevices
    if sound.recordmic
        PsychPortAudio('Close', hmic);
        PsychPortAudio('Close', hplay);
    end

    %% Thanks screen -
    for fb = [0 1] % both framebuffers for stereomode
        Screen('SelectStereoDrawBuffer', monitor.w, fb);
        % BG
        Screen('FillRect', monitor.w, bg.color, []);
        % text
        DrawFormattedText(monitor.w, expt.thanktext, ...
            'center','center', bg.textcolor);
    end
    Screen('DrawingFinished', monitor.w);
    vbl = Screen('Flip', monitor.w);
    WaitSecs(expt.thankdur); % pause a few seconds
    Screen('LoadNormalizedGammaTable', monitor.w, monitor.OLD_Gamtable);
    sca; ListenChar(); ShowCursor;
catch
    %% Error handling
    psychrethrow(psychlasterror);
    Screen('LoadNormalizedGammaTable', monitor.w, monitor.OLD_Gamtable);
    sca; ListenChar(); ShowCursor;
end

%% Repeating functions
% these functions are used several times throughout the code
    function DrawBackground(monitor, fb,  bg)
        Screen('SelectStereoDrawBuffer', monitor.w, fb);
        % BG
        Screen('FillRect', monitor.w, bg.color, []);
        % Draw alignment circles ===============
        if bg.align.AlignCircles.draw
            Screen('FillOval',monitor.w, bg.align.AlignCircles.Colors,...
                bg.align.AlignCircles.Rects);
        end
        % Draw empty background rect ===============
        RectBorders = ...
            [0; 0;...
            bg.align.Frame.SizePix(1) + 10 + bg.align.Frame.PenWidthPix; ...
            bg.align.Frame.SizePix(2) + 10 + bg.align.Frame.PenWidthPix];
        RectBorders = CenterRectOnPoint(RectBorders,...
            monitor.center(1), monitor.center(2));
        if bg.align.Frame.Type == 0
            Screen('FillOval', monitor.w, bg.color, RectBorders);
        else
            Screen('FillRect', monitor.w, bg.color, RectBorders);
        end
        %fprintf('bubbles drawn\n');
    end

    function DrawAlignFrame(monitor, fb,  bg)
        Screen('SelectStereoDrawBuffer', monitor.w, fb);
        % Draw crosshairs ===============
        % leave center open
        xy=[-bg.align.Frame.CrossLengthPix(1)/2 ...
            -(bg.align.Frame.SizePix(1)/2 + 10) ...
            0 0;...
            0 0 ...
            -bg.align.Frame.CrossLengthPix(2)/2 ...
            -(bg.align.Frame.SizePix(2)/2 + 10)];
        Screen('Drawlines',monitor.w,xy,...
            bg.align.Frame.PenWidthPix,...
            bg.align.Frame.Color, monitor.center);
        xy=[(bg.align.Frame.SizePix(1)/2 + 10) ...
            bg.align.Frame.CrossLengthPix(1)/2 ...
            0 0;...
            0 0 ...
            (bg.align.Frame.SizePix(2)/2 + 10) ...
            bg.align.Frame.CrossLengthPix(2)/2];
        Screen('Drawlines',monitor.w,xy,...
            bg.align.Frame.PenWidthPix,...
            bg.align.Frame.Color, monitor.center);
        %fprintf('crosshair drawn\n');
        % Draw empty background rect ===============
        RectBorders = ...
            [0; 0;...
            bg.align.Frame.SizePix(1) + 10 + bg.align.Frame.PenWidthPix; ...
            bg.align.Frame.SizePix(2) + 10 + bg.align.Frame.PenWidthPix];
        RectBorders = CenterRectOnPoint(RectBorders,...
            monitor.center(1), monitor.center(2));
        if bg.align.Frame.Type == 0
            Screen('FrameOval', monitor.w, bg.align.Frame.Color, ...
                RectBorders, bg.align.Frame.PenWidthPix);
        else
            Screen('FrameRect', monitor.w, bg.align.Frame.Color, ...
                RectBorders, bg.align.Frame.PenWidthPix);
        end
        %fprintf('frame drawn\n');
    end

    function [keys] = CheckKeyPresses(keys)
        [keys.KeyIsDown,keys.secs,keys.keyCode] = KbCheck;
        if keys.KeyIsDown && ~keys.KeyWasDown % new key
            keys.LastKey = KbName(find(keys.keyCode)); % Get the name of the pressed key
            keys.KeyWasDown = true;
            keys.LogNewKey = true;
            keys.LogKeyRelease = false;
        elseif keys.KeyIsDown && keys.KeyWasDown % still holding key
            if strcmp(keys.LastKey, KbName(find(keys.keyCode)))
                if keys.LastKey ~= KbName(find(keys.keyCode))
                    keys.LastKey = KbName(find(keys.keyCode));
                    keys.LogNewKey = true;
                    keys.LogKeyRelease = true;
                else
                    keys.LogNewKey = false;
                    keys.LogKeyRelease = false;
                end
            end
        elseif ~keys.KeyIsDown && keys.KeyWasDown % stop holding key
            keys.LastKey = 'none';
            keys.LogNewKey = false;
            keys.LogKeyRelease = true;
            keys.KeyWasDown = false;
        else
            keys.LogNewKey = false;
            keys.LogKeyRelease = false;
        end
    end

    function SetMonitors(state)
        % use a system call to xrandr to set monitors
        switch state
            case 'mirrored'
                system("xrandr --output DP-2 --same-as DP-1") % set monitors mirrored
            case 'extended'
                system("xrandr --output DP-2 --right-of DP-1") % set monitors extended
        end
        WaitSecs(2); % wait a few seconds for this to settle
    end

    function [psOris] = CreatePrestimEndoOri(monitor, prestim, ps)
        psOris =[];
        for g = 1:2
            TargetOri = prestim(ps).orientations(g,:);
            dA = prestim(ps).change.degpersec;
            pC = prestim(ps).change.prob;
            cInt = round(prestim(ps).change.interval*monitor.refreshRate);
            nSteps = ceil(prestim(ps).durations(2)*monitor.refreshRate);

            startstatic = TargetOri(1).*ones(1, ...
                floor(prestim(ps).durations(1)*monitor.refreshRate));
            stopstatic = TargetOri(1).*ones(1, ...
                ceil(prestim(ps).durations(1)*monitor.refreshRate));

            noChange = false;
            Ori = startstatic;
            LastChange = 0;
            TC = TargetOri(1);

            for ns = 1:nSteps+1
                TC = TC + dA;

                if TC > 360; TC = TC-360; end
                if TC < 0; TC = TC+360; end

                Ori = [Ori TC];

                if ns-LastChange > cInt(1) && rand(1) < pC && ~noChange
                    dA = -dA;
                    LastChange = ns;
                elseif ns-LastChange == cInt(2)
                    dA = -dA;
                    LastChange = ns;
                end

                dT = TC-TargetOri(2);
                if dT > 0 && dT <180 && ~noChange
                    if dA < 0
                        if abs((nSteps-ns)*dA) <= dT
                            noChange = true;
                        end
                    elseif dA > 0
                        if abs((nSteps-ns)*dA) <= dT
                            noChange = true;
                            dA=-dA;
                            LastChange = ns;
                        end
                    end
                elseif dT >= 180 && ~noChange
                    if dA < 0
                        if abs((nSteps-ns)*dA) <= 360-dT
                            noChange = true;
                            dA=-dA;
                            LastChange = ns;
                        end
                    elseif dA > 0
                        if abs((nSteps-ns)*dA) <= 360-dT
                            noChange = true;
                        end
                    end
                elseif dT < 0  && ~noChange
                    if dA < 0
                        if abs((nSteps-ns)*dA) <= abs(dT)
                            noChange = true;
                            dA=-dA;
                            LastChange = ns;
                        end
                    elseif dA > 0
                        if abs((nSteps-ns)*dA) <= abs(dT)
                            noChange = true;
                        end
                    end
                end
            end
            Ori = [Ori stopstatic];
            psOris = [psOris; Ori];
        end
    end
end