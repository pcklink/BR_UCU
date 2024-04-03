function BR_UCU(settings_file)

% Running a range of binocular rivalry experiments for UCU projects.
% Use a settings file to configure.
% This file should ideally not be edited.
%
% The code interfaces with a Tobii Pro Fusion eyetracker
% Chris Klink p.c.klink@uu.nl

%% Process arguments ------
if nargin<1
    settings_file = 'settings_def';
else
    log.settings_file = settings_file;
end

% Debug mode
% NoDebug / UU / CKHOME / CKNIN
DebugMode = 'NoDebug';

% load settings
monitor = []; eyetracker = [];
sound = []; keys = [];
bg = []; fix = []; prestim = []; stim = [];
trialtime = []; trialtype = [];
block = []; expt = [];
run(settings_file)
[RunPath,~,~] = fileparts(mfilename('fullpath'));

% log set-up --
cdt = datetime('now', 'Format', 'yyyyMMdd_HHmm');
log.Label = datestr(cdt, 'yyyymmdd_HHMM'); %#ok<*DATST>
[~,~] = mkdir(fullfile(RunPath, log.fld, log.Label));

if strcmp(DebugMode, 'NoDebug')
    % Get registration info & check against existing data    % Get subject info
    log.Subject = input('Subject initials: ','s');
    log.Gender = input('Gender (m/f/x): ','s');
    log.Age = input('Age: ','s');
    log.Handedness = input('Left(L)/Right(R) handed: ','s');
else
    log.Subject = 'TEST';
    log.Gender = 'x';
    log.Age = 0;
    log.Handedness = 'R';
end


%% Calibrate eye tracker ------
if eyetracker.do && eyetracker.calibrate % alternatively do this with a separate script
    try
        SetMonitors('mirrored');
        calibrateTobii(eyetracker, log);
        SetMonitors('extended')
    catch
        fprintf('ERROR doing eyetracker calibration\n')
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

    %Do some basic initializing
    PsychDefaultSetup(2);
    HideCursor;
    %ListenChar(2); % silence keyboard for matlab

    % Get screen info
    scr = Screen('screens'); % get screen info
    monitor.scr = max(scr); % use the screen with the highest #

    % Gamma Correction to allow intensity in fractions
    [monitor.OLD_Gamtable, monitor.dacbits, monitor.reallutsize] = ...
        Screen('ReadNormalizedGammaTable', monitor.scr);
    GamCor = (0:1/255:1).^(1/monitor.gamma);
    Gamtable = [GamCor;GamCor;GamCor]';
    Screen('LoadNormalizedGammaTable',monitor.scr, Gamtable);

    % Get the screen size in pixels
    [monitor.PixWidth, monitor.PixHeight] = ...
        Screen('WindowSize',monitor.scr);
    % Get the screen size in mm
    [monitor.MmWidth, monitor.MmHeight] = ...
        Screen('DisplaySize',monitor.scr);

    % Define conversion factors
    monitor.Mm2Pix = monitor.PixWidth/monitor.MmWidth;
    monitor.Deg2Pix = (tand(1)*monitor.distance)*...
        monitor.PixWidth/monitor.MmWidth;


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

    % Open a window
    PsychImaging('PrepareConfiguration');
    if monitor.fliphorizontal
        PsychImaging('AddTask','AllViews','FlipHorizontal');
    end
    [monitor.w, monitor.wrect] = ...
        PsychImaging('OpenWindow', monitor.scr, bg.color, ...
        WindowRect, [], 2, monitor.stereomode); %#ok<*NODEF>

    % Get the center of screen coordinates
    monitor.center = [monitor.wrect(3)/2 monitor.wrect(4)/2];

    % Define blend function for anti-aliassing
    [monitor.sourceFactorOld, monitor.destinationFactorOld, ...
        monitor.colorMaskOld] = Screen('BlendFunction', monitor.w, ...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Initialize text options
    Screen('Textfont', monitor.w, 'Arial');
    Screen('TextSize', monitor.w, 20);
    Screen('TextStyle', monitor.w, 0);

    % Maximum useable priorityLevel on this system:
    priorityLevel = MaxPriority(monitor.w); Priority(priorityLevel);

    % Get the refreshrate
    monitor.FrameDur = Screen('GetFlipInterval', monitor.w);
    monitor.refreshRate = round(Screen('NominalFrameRate', monitor.scr));

    % Log init
    log.ev = array2table(nan(0,3),'VariableNames',{'t','type','info'});

    % Eyetracker init --
    if eyetracker.do
        run(fullfile(eyetracker.toolboxfld,'addTittaToPath'));
        settings = Titta.getDefaults(eyetracker.type);
        settings.debugMode = false;
        EThndl = Titta(settings);
        EThndl.init();
        EThndl.buffer.start('gaze'); WaitSecs(.8);
        log.ev = [log.ev; {GetSecs,'EyeStart','GazeBuffer'}];
    end

    % Sound init --
    if sound.recordmic
        % mic device
        reqlatencyclass = 2;
        InitializePsychSound(double(reqlatencyclass > 1));
        hmic = PsychPortAudio('Open', sound.mic.device, 2, ...
            reqlatencyclass, [], 2);
        snd = PsychPortAudio('GetStatus', hmic);
        sndfreq = snd.SampleRate;
        PsychPortAudio('GetAudioData', hmic, 10);

        % play device
        [y, wavfreq] = psychwavread(sound.beepfile);
        hplay = PsychPortAudio('Open', [], 1, 0, wavfreq, 2);
        wavedata = [y';y'];
        nrchannels = 2;
        PsychPortAudio('FillBuffer', hplay, wavedata);
    end


    %% Prepare stimuli ------
    %% alignment stim --
    if bg.align.AlignCircles.draw
        if bg.align.AlignCircles.n > 0

            % random colors within range
            bg.align.AlignCircles.Colors = (bg.align.AlignCircles.ColorRange(2) - ...
                bg.align.AlignCircles.ColorRange(1)) .* ...
                rand(1,bg.align.AlignCircles.n) + ...
                bg.align.AlignCircles.ColorRange(1);
            bg.align.AlignCircles.Colors = [...
                bg.align.AlignCircles.Colors; ...
                bg.align.AlignCircles.Colors; ...
                bg.align.AlignCircles.Colors];

            % random sizes within range
            bg.align.AlignCircles.Sizes = (bg.align.AlignCircles.SizeRange(2) - ...
                bg.align.AlignCircles.SizeRange(1)) .*...
                rand(1,bg.align.AlignCircles.n) + ...
                bg.align.AlignCircles.SizeRange(1);
            bg.align.AlignCircles.Sizes = [...
                bg.align.AlignCircles.Sizes;...
                bg.align.AlignCircles.Sizes];

            % size in pix
            bg.align.AlignCircles.SizesPix = round(...
                bg.align.AlignCircles.Sizes .* monitor.Deg2Pix);

            % rects
            bg.align.AlignCircles.Rects = [...
                zeros(1,size(bg.align.AlignCircles.SizesPix,2)); ...
                zeros(1,size(bg.align.AlignCircles.SizesPix,2));
                bg.align.AlignCircles.SizesPix(1,:); ...
                bg.align.AlignCircles.SizesPix(2,:)];

            % locations
            bg.align.AlignCircles.XY = [...
                round(rand(1,size(bg.align.AlignCircles.SizesPix,2)).*...
                (monitor.wrect(3)-monitor.wrect(1)));...
                round(rand(1,size(bg.align.AlignCircles.SizesPix,2)).*...
                (monitor.wrect(4)-monitor.wrect(2)))];

            % center rect on points
            for r = 1: size(bg.align.AlignCircles.Rects,2)
                bg.align.AlignCircles.Rects(:,r) = ...
                    CenterRectOnPoint(bg.align.AlignCircles.Rects(:,r),...
                    bg.align.AlignCircles.XY(1,r),...
                    bg.align.AlignCircles.XY(2,r));
            end

            % open area
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

        fix.sizepix = round(fix.size.*monitor.Deg2Pix);
        fix.rect = [0 0 fix.sizepix fix.sizepix];
        fix.rect = CenterRectOnPoint(fix.rect, ...
            monitor.center(1), monitor.center(2));
    end

    % Align Crossbars =====================
    % length in pix
    bg.align.Frame.CrossLengthPix = round(...
        bg.align.Frame.CrossLength .* monitor.Deg2Pix);
    % penwidth in pix
    bg.align.Frame.PenWidthPix = round(...
        bg.align.Frame.PenWidth .* monitor.Deg2Pix);

    if bg.align.Frame.PenWidthPix > monitor.maxpenwidth
        bg.align.Frame.PenWidthPix = monitor.maxpenwidth;
    end

    %% prestim --
    if trialtime.PrestimT % only if a prestim phase is set
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
                    if strcmp(prestim(ps).attentiontype,'exogenous')
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
                        prestim(ps).driftspeed.*monitor.Deg2Pix);
                    prestim(ps).driftpixframe = round(...
                        prestim(ps).driftpixsec ./ monitor.refreshRate);
                    prestim(ps).driftreset = monitor.refreshRate./...
                        (prestim(ps).sf*prestim(ps).driftspeed); % nframes to full period drift
                case 'dots'
                    % do most of this on the fly
                    prestim(ps).dotsizepix = round(prestim(ps).dotsize * monitor.Deg2Pix);
                    % speed
                    prestim(ps).driftpixsec = round(...
                        prestim(ps).driftspeed.*monitor.Deg2Pix);
                    prestim(ps).driftpixframe = round(...
                        prestim(ps).driftpixsec ./ monitor.refreshRate);
            end
        end
        %fprintf('Prestim created\n');
    end

    %% stim --
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
        for rt = 1:block(B).repeattrials
            if block(B).randomizetrials
                TRIALS = [TRIALS TL(randperm(length(TL)))];
            else
                TRIALS = [TRIALS TL];
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

        log.ev = [log.ev; {vbl,'ExpStart','Instruction'}];
        if eyetracker.do
            EThndl.sendMessage('ExpStart',vbl)
        end

        % wait for key
        [secs, ~, ~] = KbWait();
        log.ev = [log.ev; {secs,'KeyStart','none'}];
        if eyetracker.do
            EThndl.sendMessage('KeyStart',secs)
        end

        for fb = [0 1] % both framebuffers for stereomode
            Screen('SelectStereoDrawBuffer', monitor.w, fb);
            Screen('FillRect', monitor.w, bg.color, []);
        end
        Screen('DrawingFinished',monitor.w);
        vbl = Screen('Flip', monitor.w);
        pause(0.1) % brief gap with just bg before trial starts


        %% run the trials
        t=1;
        while t <= length(TRIALS) && ~StopExp
            T = TRIALS(t); log.trial(t).T = T;

            %% generic
            StimSizePix = round(trialtype(T).stimsize .* monitor.Deg2Pix);
            bg.align.Frame.SizePix = StimSizePix;
            [mX, mY] = meshgrid(1:StimSizePix(1), 1:StimSizePix(2));

            maskcenter = StimSizePix/2;
            maskradius = StimSizePix/2;
            dH = (mX - maskcenter(1)) / maskradius(1);
            dV = (mY- maskcenter(2)) / maskradius(2);
            maskmat = (dH.^2 + dV.^2 <= 1);
            maskbg = ~isnan(maskmat);

            masktext(:,:,1) = maskbg .* bg.color(1);
            masktext(:,:,2) = maskbg .* bg.color(2);
            masktext(:,:,3) = maskbg .* bg.color(3);
            masktext(:,:,4) = -maskmat+1;

            StimMask = Screen('MakeTexture', monitor.w, masktext);
            %fprintf('Mask created\n')

            ps = trialtype(T).prestim;

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

            log.ev = [log.ev; {vbl,'FixStart','none'}];
            if eyetracker.do
                EThndl.sendMessage('FixStart',vbl)
            end

            while (GetSecs-FixT0) < trialtime.FixT && ~StopExp
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
            if trialtime.PrestimT % only if a prestim phase is set
                % get a series of orientation for prestim frames
                switch prestim(ps).attentiontype
                    case 'endogenous'
                        psOris = CreatePrestimEndoOri(monitor, prestim, ps);
                    case 'exogenous'
                        total_fr = round(trialtime.PrestimT*monitor.refreshRate);
                        trans_frw = round(...
                            prestim(ps).transient.timewindow*monitor.refreshRate + total_fr);
                        trans_frw = Shuffle(trans_frw(1):trans_frw(2));
                        transframes = [trans_frw(1) trans_frw(1)+...
                            round(prestim(ps).transient.duration*monitor.refreshRate)];
                end

                % instruction screen --
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

                f=1; % framenuber
                while (vbl - PreStimT0) < trialtime.PrestimT && ~StopExp
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
                                                psOris(a,cF+1),...
                                                [],0.5);
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
                                                % - move
                                                prestim(ps).driftpixframeXY = [...
                                                    sind(psOris(a,cF+1)).* prestim(ps).driftpixframe(a) ...
                                                    cosd(psOris(a,cF+1)).* prestim(ps).driftpixframe(a)];
                                                
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
                                                    prestim(ps).orient(a),...
                                                    [],0.5);
                                            else
                                                Screen('DrawTexture',monitor.w, ...
                                                    prestim(ps).GratText0, ...
                                                    grect,drect,...
                                                    prestim(ps).orient(a),...
                                                    [],0.5);
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

                                                        prestim(ps).dotcols{a} = [...
                                                            prestim(ps).dotcol(a,:);...
                                                            prestim(ps).dotcol(a,:);...
                                                            prestim(ps).dotcol(a,:)];
                                                        prestim(ps).dotcolstrans{a} = [...
                                                            prestim(ps).dotcoltrans(a,:);...
                                                            prestim(ps).dotcoltrans(a,:);...
                                                            prestim(ps).dotcoltrans(a,:)];
                                                    end
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

                        % fixation dot
                        Screen('FillOval', monitor.w, fix.color, fix.rect);
                    end
                    Screen('DrawingFinished',monitor.w);
                    vbl = Screen('Flip', monitor.w, vbl+0.9*monitor.FrameDur);
                    cF=cF+1; f=f+1;

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
                RespLogged = false;
                while  ~RespLogged
                    [KeyIsDown,keys.secs,keys.keyCode] = KbCheck;
                    if KeyIsDown
                        keys.LastKey = KbName(find(keys.keyCode)); % Get the name of the pressed key
                        if strcmp(keys.LastKey,keys.resp{1}) || strcmp(keys.LastKey,keys.resp{2})
                            log.ev = [log.ev; {keys.secs,'PreStimResponse',keys.LastKey}];
                            RespLogged = true;
                        elseif strcmp(keys.LastKey,keys.esc)
                            RespLogged = true;
                            StopExp = true;
                            break;
                        end
                    end
                end
            end


            %% GAP ---
            % bg alignment
            for fb = [0 1]
                DrawBackground(monitor, fb, bg);
                DrawAlignFrame(monitor, fb, bg);
            end
            Screen('DrawingFinished',monitor.w);
            vbl = Screen('Flip', monitor.w);
            GapT0 = vbl;

            log.ev = [log.ev; {secs,'GapStart',T}];
            if eyetracker.do
                EThndl.sendMessage('GapStart',secs)
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

            while (GetSecs - GapT0) < trialtime.PrestimGapT && ~StopExp
                % check keys for escape
                [~, ~, keyCode] = KbCheck;
                if strcmp(KbName(find(keyCode)),keys.esc)
                    StopExp = true;
                    break;
                end
            end
            vbl = GetSecs;


            %% STIM ---
            StimStarted = 0;
            StimT0 = 0; vbl = 0; cF = 0;
            keys.KeyWasDown = false;
            keys.KeyIsDown = false;
            keys.LastKey = [];
            %fprintf('Starting stim\n')

            while vbl-StimStarted < trialtime.StimT  && ~StopExp
                % stim
                for fb = [0 1]
                    DrawBackground(monitor, fb, bg);
                    % which stim
                    ss = trialtype(T).eye(fb+1).stim;
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
                                stim(ss).orient);
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
                            Screen('DrawTexture', monitor.w,...
                                stim(ss).imgtex,[],drect);
                            switch stim(ss).overlay.type
                                case 'dots'
                                    if cF == 0 % - first frame
                                        % locations
                                        stim(ss).overlay.nDots = round(...
                                            stim(ss).overlay.dotdensity * ...
                                            trialtype(T).stimsize(1) * ...
                                            trialtype(T).stimsize(2));
                                        stim(ss).overlay.dotfb(fb+1).xy = [...
                                            round(- StimSizePix(1)/2 + ...
                                            rand(1,stim(ss).overlay.nDots).*StimSizePix(1)); ...
                                            round(- StimSizePix(2)/2 + ...
                                            rand(1,stim(ss).overlay.nDots).*StimSizePix(1))];
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
                                        stim(ss).overlay.dotage = round(rand(1,stim(ss).overlay.nDots).*...
                                            stim(ss).overlay.dotlifetime);
                                    else
                                        % - move
                                        for a = 1:2
                                            stim(ss).overlay.dotfb(fb+1).xy(a,:) = stim(ss).overlay.dotfb(fb+1).xy(a,:) + ...
                                                stim(ss).overlay.driftpixframe(a);
                                            oof = stim(ss).overlay.dotfb(fb+1).xy(a,:) > ...
                                                round(StimSizePix(a)/2);
                                            stim(ss).overlay.dotfb(fb+1).xy(a,oof) = stim(ss).overlay.dotfb(fb+1).xy(a,oof) - ...
                                                round(StimSizePix(a)/2);
                                            oof = stim(ss).overlay.dotfb(fb+1).xy(a,:) < ...
                                                round(-StimSizePix(a)/2);
                                            stim(ss).dotfb(fb+1).overlay.xy(a,oof) = stim(ss).overlay.dotfb(fb+1).xy(a,oof) + ...
                                                round(StimSizePix(a)/2);
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
                                                rand(1,stim(ss).overlay.nDots).*StimSizePix(1))];
                                            stim(ss).overlay.dotfb(fb+1).xy(:,dd) = newdotsxy(:,dd);
                                        end
                                    end
                                    % - draw
                                    Screen('DrawDots',monitor.w,...
                                        stim(ss).overlay.dotfb(fb+1).xy, stim(ss).overlay.dotsizepix, ...
                                        stim(ss).overlay.dotcol,monitor.center,1)
                                    drect = [0 0 StimSizePix(1)+10 StimSizePix(2)+10];
                                    drect = CenterRectOnPoint(drect,...
                                        monitor.center(1), monitor.center(2));
                                    Screen('DrawTexture', monitor.w, ....
                                        StimMask, [], drect, []);
                                case 'lines'
                                    if cF == 0 % first frame
                                        switch stim(ss).overlay.orientation
                                            case 'horizontal'
                                                stim(ss).overlay.nLines = ...
                                                    round(...
                                                    stim(ss).overlay.linedensity * ...
                                                    trialtype(T).stimsize(1));
                                                linexy = zeros(1,2*stim(ss).overlay.nLines);
                                                linexy(1,1:2:end) = -StimSizePix(1)/2;
                                                linexy(1,2:2:end) = StimSizePix(1)/2;
                                                linexy(2,1:2:end) = -StimSizePix(2)/2 : ...
                                                    StimSizePix(2)/stim(ss).overlay.nLines : ...
                                                    StimSizePix(2)/2 - StimSizePix(2)/stim(ss).overlay.nLines;
                                                linexy(2,2:2:end) = linexy(2,1:2:end);

                                            case 'vertical'
                                                stim(ss).overlay.nLines = ...
                                                    round(...
                                                    stim(ss).overlay.linedensity * ...
                                                    trialtype(T).stimsize(2));
                                                linexy = zeros(1,2*stim(ss).overlay.nLines);
                                                linexy(2,1:2:end) = -StimSizePix(2)/2;
                                                linexy(2,2:2:end) = StimSizePix(2)/2;
                                                linexy(1,1:2:end) = -StimSizePix(1)/2 : ...
                                                    StimSizePix(1)/stim(ss).overlay.nLines : ...
                                                    StimSizePix(1)/2 - StimSizePix(1)/stim(ss).overlay.nLines;
                                                linexy(1,2:2:end) = linexy(1,1:2:end);
                                        end
                                        stim(ss).overlay.linecol = [stim(ss).overlay.color ...
                                            stim(ss).overlay.opacity];
                                    else
                                        switch stim(ss).overlay.orientation
                                            case 'horizontal'
                                                linexy(2,:) = linexy(2,:) + stim(ss).overlay.driftpixframe;
                                                oof = linexy(2,:) > StimSizePix(2)/2;
                                                linexy(2,oof) = linexy(2,oof)-StimSizePix(2);
                                            case 'vertical'
                                                linexy(1,:) = linexy(1,:) + stim(ss).overlay.driftpixframe;
                                                oof = linexy(1,:) > StimSizePix(1)/2;
                                                linexy(1,oof) = linexy(1,oof)-StimSizePix(1);
                                        end
                                    end
                                    % - draw
                                    Screen('DrawLines',monitor.w,...
                                        linexy, stim(ss).overlay.linewidthpix, ...
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
                elseif keys.LogNewKey
                    log.ev = [log.ev; {keys.secs,'KeyPress',keys.LastKey}];
                end
                % Can we fetch the mic buffer every screen refresh --
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

            % stop audio capture
            if sound.recordmic
                % Stop audio capture --
                PsychPortAudio('Stop', hmic);
                PsychPortAudio('Stop', hplay, 1);
                % last fetch
                audiodata = PsychPortAudio('GetAudioData', hmic);
                % Attach it to our full sound vector:
                voicetrack = [voicetrack audiodata];
                log.trial(t).voicetrack = voicetrack;
                log.trial(t).voicefile = ['voice_' num2str(t) '.wav'];
                voicetrack = [];
                % Close the audio device --
                PsychPortAudio('Close', hmic);
                PsychPortAudio('Close', hplay);
                % Save the sound file to 'sndfile'
                sndfile = fullfile(RunPath, log.fld, log.Label, log.trial(t).voicefile);
                if ~isempty(sndfile)
                    psychwavwrite(transpose(voicetrack), sndfreq, 16, sndfile)
                end
            end
            t=t+1; % next trial
        end
        b=b+1; % next block
    end
    %% Save the logs ------
    settings.monitor = monitor;
    settings.eyetracker = eyetracker;
    settings.sound = sound;
    settings.keys = keys;
    settings.bg = bg;
    settings.fix = fix;
    settings.prestim = prestim;
    settings.stim = stim;
    settings.trialtime = trialtime;
    settings.trialtype = trialtype;
    settings.block = block;
    settings.expt = expt;

    save(fullfile(RunPath, log.fld, log.Label, 'logfile'),'settings','log');

    % save the eye data and close off tracker
    if eyetracker.do
        EThndl.buffer.stop('gaze');
        dat = EThndl.collectSessionData();
        dat.expt.resolution = monitor.wrect(3:4);
        fn = ['eyedata_' log.Label];
        EThndl.saveData(dat, fullfile(log.fld,log.Label,fn), true);
        EThndl.deInit();
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
    sca; ShowCursor;
end

%% Repeating functions
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
        elseif keys.KeyIsDown && keys.KeyWasDown % still holding key
            if strcmp(keys.LastKey, KbName(find(keys.keyCode)))
                if keys.LastKey ~= KbName(find(keys.keyCode))
                    keys.LastKey = KbName(find(keys.keyCode));
                    keys.LogNewKey = true;
                else
                    keys.LogNewKey = false;
                end
            end
        elseif ~keys.KeyIsDown && keys.KeyWasDown % stop holding key
            keys.LastKey = 'none';
            keys.LogNewKey = false;
            keys.KeyWasDown = false;
        else
            keys.LogNewKey = false;
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
        pause(3); % wait a few seconds for this to settle
    end

    function [psOris] = CreatePrestimEndoOri(monitor, prestim, ps)
        psOris =[];
        for g = 1:2
            TargetOri = prestim(ps).orientations(g,:);
            dA = prestim(ps).change.degpersec;
            pC = prestim(ps).change.prob;
            cInt = prestim(ps).change.interval*monitor.refreshRate;
            nSteps = round(prestim(ps).durations(2)*monitor.refreshRate);

            startstatic = TargetOri(1).*ones(1, ...
                round(prestim(ps).durations(1)*monitor.refreshRate));
            stopstatic = TargetOri(1).*ones(1, ...
                round(prestim(ps).durations(1)*monitor.refreshRate));

            noChange = false;
            Ori = startstatic;
            LastChange = 0;
            TC = TargetOri(1);

            for ns = 1:nSteps
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
                        if abs((nSteps-s)*dA) <= 360-dT
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