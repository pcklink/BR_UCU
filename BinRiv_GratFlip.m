function BinRiv_GratFlip

% ====== NB! LOGGING HAS NOT BEEN IMPLEMENTED IN THIS DEMO ================

%% Initiate =============================================================
clear all; clc; % clear workspace and command window
QuitScript=false; % allow escape after pressing escape

stereoMode=4; %(6 = Red-Green 4 or 5 = mirror stereoscope)
% 4 left/right split uncrossed
% 5 left/right split cross-eyed
% Not sure which one works best in combination with horizntal flipping
% I guess crossed with flipping

% Use this to flip frame buffers horizontally
FlipHorizontal = true;

warning off; %#ok<*WNOFF>
Debug=false; % if true, stuff is presented in a sub-window
framenr = 0; % count frames for CFS control
KeyWasDown=false; % initialize with no key pressed

%% Hardware Parameters ====================================================
HARDWARE.GammaCorrection = 1; % 1= no gamma correction
HARDWARE.DistFromScreen = 570; % TO BE MEASURED!

%% STIMULI ================================================================
% Generic ===============
STIM.BackColor = [0.5 0.5 0.5]; % [R G B] range: 0-1
STIM.Size = [3 4]; % [widht height] in deg

% Alignment ===============
STIM.Frame.Size = STIM.Size + .5; % in deg
STIM.Frame.PenWidth = .2; % in deg
STIM.Frame.PenWidthPixMax10=true; % on some setups there's a limit to penwidth
STIM.Frame.DashLength = .2; % deg, scaling of dashed lines
STIM.Frame.DashPattern = [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1]; %default
STIM.Frame.CrossLength = STIM.Frame.Size + 2; % in deg
STIM.Frame.Color = [0 0 0]; % [R G B] range: 0-1

STIM.AlignCircles.draw = true; % if false these are not drawn
STIM.AlignCircles.n = 150; % number of circles drawn in full window
STIM.AlignCircles.ColorRange = [0.3 0.7]; % [R G B] range: 0-1
STIM.AlignCircles.SizeRange = [.5 2]; % in deg

% Suppressor for CFS ===============
STIM.Mondrian.NoRects = 10000; % number of rectangles for full window
STIM.Mondrian.SizeRange = [.1 1]; % [min max] deg
STIM.Mondrian.ColorRange = [0 1]; % [min max] deg
STIM.Mondrian.Greyscale = false; % color or grey values
STIM.Mondrian.ChangeNFrames = 2; % new pttern every nth frame

% Gratings ===============
STIM.Grat.SF = [2.5 2.5]; % spatial frequency in cycles/deg
STIM.Grat.Contrast = [1 1]; % contrast 0-1
STIM.Grat.Orient = [45 135]; % degrees clockwise

% Toggle values ===============
TOGGLE.DrawStim = false; %spacebar toggles stim presentation
TOGGLE.SwitchStim = false; % 's' switches eye assignment
TOGGLE.AlignCircles = true; % 'c' toggles presentation of alignment circles

% eye assignment (fixed for now) ===============
STIM.Eye1 = {'Grating',1}; % if image/grating the second value denotes which
STIM.Eye2 = {'Grating',2}; % if mondrian, the second value is meaningless

try
    %% Initialize & Calculate Stimuli =====================================
    % Reduce PTB3 verbosity
    oldLevel = Screen('Preference', 'Verbosity', 0); %#ok<*NASGU>
    Screen('Preference', 'VisualDebuglevel', 0);
    Screen('Preference','SkipSyncTests',1);

    %Do some basic initializing
    AssertOpenGL;
    HideCursor;
    KbName('UnifyKeyNames');

    %Define response keys
    KeySwitch=KbName('s');
    KeyShow=KbName('space');
    KeyAlign=KbName('c');
    if ~IsLinux
        KeyBreak=KbName('Escape');
    else
        KeyBreak=KbName('ESCAPE');
    end
    ListenChar(2); % silence keyboard for matlab

    % Get screen info
    scr=Screen('screens'); % get screen info
    STIM.Screen.ScrNr=max(scr); % use the screen with the highest #

    % Gamma Correction to allow intensity in fractions
    [OLD_Gamtable, dacbits, reallutsize] = ...
        Screen('ReadNormalizedGammaTable', STIM.Screen.ScrNr);
    GamCor=(0:1/255:1).^HARDWARE.GammaCorrection;
    Gamtable=[GamCor;GamCor;GamCor]';
    Screen('LoadNormalizedGammaTable',STIM.Screen.ScrNr, Gamtable);

    % Get the screen size in pixels
    [STIM.Screen.PixWidth, STIM.Screen.PixHeight] = ...
        Screen('WindowSize',STIM.Screen.ScrNr);
    % Get the screen size in mm
    [STIM.Screen.MmWidth, STIM.Screen.MmHeight] = ...
        Screen('DisplaySize',STIM.Screen.ScrNr);

    % Get some basic color intensities
    STIM.Screen.white=WhiteIndex(STIM.Screen.ScrNr);
    STIM.Screen.black=BlackIndex(STIM.Screen.ScrNr);
    STIM.Screen.grey=(STIM.Screen.white+STIM.Screen.black)/2;

    % Define conversion factors
    STIM.Screen.Mm2Pix=STIM.Screen.PixWidth/STIM.Screen.MmWidth;
    STIM.Screen.Deg2Pix=(tand(1)*HARDWARE.DistFromScreen)*...
        STIM.Screen.PixWidth/STIM.Screen.MmWidth;

    % Determine color of on screen text and feedback
    % depends on background color --> Black or white
    if max(STIM.BackColor) > .5
        STIM.TextIntensity = STIM.Screen.black;
    else STIM.TextIntensity = STIM.Screen.white;
    end

    % Open a double-buffered window on screen
    if Debug==1 % if in debug mode, only open a 75 screen
        % WindowRect=...
        %     [0 0 .75*STIM.Screen.PixWidth .75*STIM.Screen.PixHeight]; %debug
        WindowRect=...
            [1080 0 1080+1920 1080]; %debug
    else
        WindowRect=[]; %fullscreen
    end

    % Open a window
    PsychImaging('PrepareConfiguration');
    if FlipHorizontal
        PsychImaging('AddTask','AllViews','FlipHorizontal');
    end

    [STIM.Screen.window, STIM.Screen.windowRect] = ...
        PsychImaging('OpenWindow',STIM.Screen.ScrNr,...
        STIM.BackColor*STIM.Screen.white,WindowRect,[],2,stereoMode);
    % Get the center of screen coordinates
    STIM.Screen.Center = ...
        [STIM.Screen.windowRect(3)/2 STIM.Screen.windowRect(4)/2];

    % Define blend function for anti-aliassing
    [sourceFactorOld, destinationFactorOld, colorMaskOld] = ...
        Screen('BlendFunction', STIM.Screen.window, ...
        GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    % Initialize text options
    Screen('Textfont',STIM.Screen.window,'Arial');
    Screen('TextSize',STIM.Screen.window,20);
    Screen('TextStyle',STIM.Screen.window,0);

    % Maximum useable priorityLevel on this system:
    priorityLevel=MaxPriority(STIM.Screen.window);
    Priority(priorityLevel);

    % Get the refreshrate
    STIM.Screen.FrameDur = Screen('GetFlipInterval',STIM.Screen.window);

    % Align Circles =====================
    %random colors within range
    STIM.AlignCircles.Colors = ...
        (STIM.AlignCircles.ColorRange(2)-STIM.AlignCircles.ColorRange(1)).*...
        rand(1,STIM.AlignCircles.n)+ STIM.AlignCircles.ColorRange(1);
    %greyscale r=g=b
    STIM.AlignCircles.Colors=[STIM.AlignCircles.Colors; ...
        STIM.AlignCircles.Colors; STIM.AlignCircles.Colors];
    %random sizes within range
    STIM.AlignCircles.Sizes = ...
        (STIM.AlignCircles.SizeRange(2)-STIM.AlignCircles.SizeRange(1)).*...
        rand(1,STIM.AlignCircles.n)+ STIM.AlignCircles.SizeRange(1);
    STIM.AlignCircles.Sizes = [STIM.AlignCircles.Sizes;STIM.AlignCircles.Sizes];

    %calculate coordinates for these circles
    if STIM.AlignCircles.n > 0
        % size in pix
        STIM.AlignCircles.SizesPix = round(STIM.AlignCircles.Sizes.*STIM.Screen.Deg2Pix);
        % The left-top corners
        STIM.AlignCircles.LTCorner = ...
            [-25+rand(1,STIM.AlignCircles.n).*STIM.Screen.PixWidth;...
            -25+rand(1,STIM.AlignCircles.n).*STIM.Screen.PixHeight];
        % the full rectangles
        STIM.AlignCircles.Rects = [STIM.AlignCircles.LTCorner(1,:);...
            STIM.AlignCircles.LTCorner(2,:);...
            STIM.AlignCircles.LTCorner(1,:) + STIM.AlignCircles.SizesPix(1,:);...
            STIM.AlignCircles.LTCorner(2,:) + STIM.AlignCircles.SizesPix(2,:)];
    end

    % Align Crossbars =====================
    % length in pix
    STIM.Frame.CrossLengthPix = round(...
        STIM.Frame.CrossLength.*STIM.Screen.Deg2Pix);
    % penwidth in pix
    STIM.Frame.PenWidthPix = round(...
        STIM.Frame.PenWidth.*STIM.Screen.Deg2Pix);
    % maximum of 10 pix width on some systems
    if STIM.Frame.PenWidthPixMax10 && STIM.Frame.PenWidthPix>10
        STIM.Frame.PenWidthPix=10;
    end

    % Framerect =====================
    STIM.Frame.SizePix=round(STIM.Frame.Size.*STIM.Screen.Deg2Pix);

    % Dashes =====================
    STIM.Frame.DashLengthPix = round(...
        STIM.Frame.DashLength.*STIM.Screen.Deg2Pix);

    % Mondrian =====================
    %random colors within range
    STIM.Mondrian.Colors = ...
        (STIM.Mondrian.ColorRange(2)-STIM.Mondrian.ColorRange(1)).*...
        rand(3,STIM.Mondrian.NoRects)+ STIM.Mondrian.ColorRange(1);
    %greyscale if required
    if STIM.Mondrian.Greyscale
        STIM.Mondrian.Colors(2,:)=STIM.Mondrian.Colors(1,:);
        STIM.Mondrian.Colors(3,:)=STIM.Mondrian.Colors(1,:);
    end
    %random sizes within range
    STIM.Mondrian.Sizes = ...
        (STIM.Mondrian.SizeRange(2)-STIM.Mondrian.SizeRange(1)).*...
        rand(2,STIM.Mondrian.NoRects)+ STIM.Mondrian.SizeRange(1);
    % sizes in pix
    STIM.Mondrian.SizesPix = round(STIM.Mondrian.Sizes.*STIM.Screen.Deg2Pix);
    %left top corners
    STIM.Mondrian.LTCorner = ...
        [-10 + rand(1,STIM.Mondrian.NoRects).*STIM.Screen.PixWidth;...
        -10 + rand(1,STIM.Mondrian.NoRects).*STIM.Screen.PixHeight];
    %full rectangles
    STIM.Mondrian.Rects = [STIM.Mondrian.LTCorner(1,:);...
        STIM.Mondrian.LTCorner(2,:);...
        STIM.Mondrian.LTCorner(1,:) + STIM.Mondrian.SizesPix(1,:);...
        STIM.Mondrian.LTCorner(2,:) + STIM.Mondrian.SizesPix(2,:)];
    % draw fullscreen mondrian in offscreen window
    % we later take random subsamples from this
    [STIM.Screen.MondrianWindow, STIM.Screen.MondrianRect]=...
        Screen('OpenOffscreenWindow',STIM.Screen.ScrNr,...
        STIM.BackColor.*STIM.Screen.white,WindowRect);
    Screen('FillRect',STIM.Screen.MondrianWindow,...
        STIM.Mondrian.Colors.*STIM.Screen.white,...
        STIM.Mondrian.Rects);

    % Stimuli Grat/Image =====================
    % size in pix
    STIM.SizePix = round(STIM.Size.*STIM.Screen.Deg2Pix); 
    % rectangles
    STIM.StimRect = ...
        [STIM.Screen.Center(1)-STIM.SizePix(1)/2;...
        STIM.Screen.Center(2)-STIM.SizePix(2)/2;...
        STIM.Screen.Center(1)+STIM.SizePix(1)/2;...
        STIM.Screen.Center(2)+STIM.SizePix(2)/2];

    % Grating =====================
    if strcmp(STIM.Eye1{1},'Grating') || strcmp(STIM.Eye2{1},'Grating')

        % Get screen height for square mesh
        s=STIM.Screen.PixHeight/2;

        for i=1:length(STIM.Grat.SF)
            % Create mesh for texture
            [x,y]=meshgrid(-s:s-1, -s:s-1);
            % Create the grating
            f=(STIM.Grat.SF(i)/STIM.Screen.Deg2Pix)*(2*pi); % cycles/pixel
            angle=0; %basic, we can rotate later
            a=cos(angle)*f; b=sin(angle)*f;phase=0;
            m=sin(a*x+b*y+phase);
            gratingtex=(STIM.Screen.grey+...
                STIM.Screen.grey*m*STIM.Grat.Contrast(i));
            % Create the grating texture
            GratingTexture(i)=...
                Screen('MakeTexture', STIM.Screen.window, gratingtex); %#ok<SAGROW>
        end

        % Create a transparency mask:
        % Layer 1 is background
        maskblob=ones(2*s, 2*s, 2) * STIM.BackColor(1)*STIM.Screen.white;
        % Layer 2 is gaussian transparency with size of Target
        szdiag = min(STIM.Frame.Size);
        szmax = sqrt(.5*szdiag^2)-STIM.Frame.PenWidth;
        maskblob(:,:,2)= STIM.Screen.white * (1-exp(...
            -((x/(szmax/4*STIM.Screen.Deg2Pix)).^2)-...
            ((y/(szmax/4*STIM.Screen.Deg2Pix)).^2)));
        % Create the mask texture:
        MaskTexture=...
            Screen('MakeTexture', STIM.Screen.window, maskblob);

    end

    %% Run presentation ===================================================
    while ~QuitScript
        framenr = framenr+1; % keep track of framenumbers
        for fb=[0 1]; % both framebuffers for stereomode
            % fb=0 left on screen / left eye / Eye1
            % select framebuffer ===============
            Screen('SelectStereoDrawBuffer', STIM.Screen.window, fb);

            % Draw alignment circles ===============
            if STIM.AlignCircles.draw && TOGGLE.AlignCircles
                Screen('FillOval',STIM.Screen.window,...
                    STIM.AlignCircles.Colors.*STIM.Screen.white,...
                    STIM.AlignCircles.Rects);
            end

            % Draw crosshairs ===============
            xy=[-STIM.Frame.CrossLengthPix(1)/2 STIM.Frame.CrossLengthPix(1)/2 0 0;...
                0 0 -STIM.Frame.CrossLengthPix(2)/2 STIM.Frame.CrossLengthPix(2)/2];
            Screen('Drawlines',STIM.Screen.window,xy,...
                STIM.Frame.PenWidthPix,...
                STIM.Frame.Color.*STIM.Screen.white,STIM.Screen.Center);

            % Draw empty background rect ===============
            RectBorders = ...
                [STIM.Screen.Center(1)-(STIM.Frame.SizePix(1)/2+STIM.Frame.PenWidthPix/2);...
                STIM.Screen.Center(2)-(STIM.Frame.SizePix(2)/2+STIM.Frame.PenWidthPix/2);...
                STIM.Screen.Center(1)+(STIM.Frame.SizePix(1)/2+STIM.Frame.PenWidthPix/2);...
                STIM.Screen.Center(2)+(STIM.Frame.SizePix(2)/2+STIM.Frame.PenWidthPix/2)];
            Screen('FillRect',STIM.Screen.window,...
                STIM.BackColor.*STIM.Screen.white,RectBorders);

            % Draw frame rect ===============
            Screen('FrameRect',STIM.Screen.window,...
                STIM.Frame.Color.*STIM.Screen.white,RectBorders,...
                STIM.Frame.PenWidthPix);

            % Draw dashed frame rect ===============
            % calculate line coordinates
            fxy = [-STIM.Frame.SizePix(1)/2 STIM.Frame.SizePix(1)/2 ...
                STIM.Frame.SizePix(1)/2 STIM.Frame.SizePix(1)/2 ...
                STIM.Frame.SizePix(1)/2 -STIM.Frame.SizePix(1)/2 ...
                -STIM.Frame.SizePix(1)/2 -STIM.Frame.SizePix(1)/2 ;...
                -STIM.Frame.SizePix(2)/2 -STIM.Frame.SizePix(2)/2 ...
                -STIM.Frame.SizePix(2)/2 STIM.Frame.SizePix(2)/2 ...
                STIM.Frame.SizePix(2)/2 STIM.Frame.SizePix(2)/2 ...
                -STIM.Frame.SizePix(2)/2 STIM.Frame.SizePix(2)/2];
            % enable drawin dashed lines
            [stippleEnabled, stippleFactor, stipleVector]=Screen(...
                'LineStipple', STIM.Screen.window, 1,...
                STIM.Frame.DashLengthPix,STIM.Frame.DashPattern);
            Screen('Drawlines',STIM.Screen.window,fxy,...
                STIM.Frame.PenWidthPix,...
                STIM.Screen.white,STIM.Screen.Center);
            % disable drawing dashed lines
            [stippleEnabled, stippleFactor, stipleVector]=Screen(...
                'LineStipple', STIM.Screen.window, 0);

            if TOGGLE.DrawStim
                % Draw image texture ===============
                if (fb == 1 && strcmp(STIM.Eye1{1},'Image'))
                    Screen('DrawTexture',STIM.Screen.window,...
                        ImageTexture(STIM.Eye1{2}),[],STIM.ImgRect);
                elseif (fb == 0 && strcmp(STIM.Eye2{1},'Image'))
                    Screen('DrawTexture',STIM.Screen.window,...
                        ImageTexture(STIM.Eye2{2}),[],STIM.ImgRect);
                end

                % Draw grating ===============
                if (fb == 1 && strcmp(STIM.Eye1{1},'Grating'))
                    szmaxpix = round(szmax*STIM.Screen.Deg2Pix);
                    GratSrc = [s-szmaxpix/2;s-szmaxpix/2;...
                        s+szmaxpix/2; s+szmaxpix/2];
                    GratDest = [STIM.Screen.Center(1)-szmaxpix/2;...
                        STIM.Screen.Center(2)-szmaxpix/2;...
                        STIM.Screen.Center(1)+szmaxpix/2;...
                        STIM.Screen.Center(2)+szmaxpix/2];
                    % grating
                    Screen('DrawTexture',STIM.Screen.window, ...
                        GratingTexture(STIM.Eye1{2}), ...
                        GratSrc,GratDest,...
                        STIM.Grat.Orient(STIM.Eye1{2}));
                    % mask
                    Screen('DrawTexture',STIM.Screen.window, ...
                        MaskTexture, ...
                        GratSrc,GratDest,...
                        STIM.Grat.Orient(STIM.Eye1{2}));
                elseif (fb == 0 && strcmp(STIM.Eye2{1},'Grating'))
                    szmaxpix = round(szmax*STIM.Screen.Deg2Pix);
                    GratSrc = [s-szmaxpix/2;s-szmaxpix/2;...
                        s+szmaxpix/2; s+szmaxpix/2];
                    GratDest = [STIM.Screen.Center(1)-szmaxpix/2;...
                        STIM.Screen.Center(2)-szmaxpix/2;...
                        STIM.Screen.Center(1)+szmaxpix/2;...
                        STIM.Screen.Center(2)+szmaxpix/2];
                    % grating
                    Screen('DrawTexture',STIM.Screen.window, ...
                        GratingTexture(STIM.Eye2{2}), ...
                        GratSrc,GratDest,...
                        STIM.Grat.Orient(STIM.Eye2{2}));
                    % mask
                    Screen('DrawTexture',STIM.Screen.window, ...
                        MaskTexture, ...
                        GratSrc,GratDest,...
                        STIM.Grat.Orient(STIM.Eye1{2}));
                end
                % Draw mondrians  ===============
                % Pick a new rect from the large offscreen window
                if (fb == 1 && strcmp(STIM.Eye1{1},'Mondrian')) || ...
                        (fb == 0 && strcmp(STIM.Eye2{1},'Mondrian'))
                    if framenr == 1 || mod(framenr-1,STIM.Mondrian.ChangeNFrames)==0
                        srcrect = [0 0 STIM.SizePix(1) STIM.SizePix(2)]';
                        srcrect([1 3])=srcrect([1 3])+ ...
                            rand(1)*(STIM.Screen.windowRect(3)-STIM.SizePix(1));
                        srcrect([2 4])=srcrect([2 4])+ ...
                            rand(1)*(STIM.Screen.windowRect(4)-STIM.SizePix(2));
                    end
                    % draw
                    Screen('DrawTexture',STIM.Screen.window,STIM.Screen.MondrianWindow,...
                        srcrect,STIM.StimRect);
                end
            end
        end
        % Flip the screen buffer when ready
        vbl = Screen('Flip', STIM.Screen.window);

        % Record keypress as response
        [keyIsDown,secs,keyCode]=KbCheck;
        if keyIsDown && ~KeyWasDown
            if keyCode(KeyBreak) %break when escape is pressed
                QuitScript=true;
                break;
            elseif keyCode(KeyShow) % toggle stimulus presentation
                if TOGGLE.DrawStim
                    TOGGLE.DrawStim=false;
                else
                    TOGGLE.DrawStim=true;
                end
            elseif keyCode(KeyAlign) % toggle alignment circles
                if TOGGLE.AlignCircles
                    TOGGLE.AlignCircles=false;
                else
                    TOGGLE.AlignCircles=true;
                end
            elseif keyCode(KeySwitch) % switch stimuli between eyes
                STIM.oldEye1 = STIM.Eye1;STIM.oldEye2 = STIM.Eye2;
                STIM.Eye2=STIM.oldEye1; STIM.Eye1=STIM.oldEye2;
            end
            KeyWasDown=true;
        elseif ~keyIsDown && KeyWasDown % key is released
            KeyWasDown=false;
        end

    end

    %% Clean up ===========================================================
    Screen('LoadNormalizedGammaTable',STIM.Screen.window, OLD_Gamtable);
    Screen('CloseAll');ListenChar();

catch
    %% Clean up ===========================================================
    Screen('CloseAll');ListenChar();
    psychrethrow(psychlasterror);
    Screen('LoadNormalizedGammaTable',STIM.Screen.window, OLD_Gamtable);
end