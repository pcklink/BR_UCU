%% VIDEO NOTES =======================

% advanced video output adjust
PsychImaging('PrepareConfiguration');

% Flip horizontal
PsychImaging('AddTask','AllViews','FlipHorizontal');

StereoMode = 5;
% 4 left/right split uncrossed
% 5 left/right split cross-eyed
% Not sure which one works best in combination with horizntal flipping
% I guess crossed with flipping
[w, rect] = Screen('OpenWindow', ScrNr, color, wrect, [], 2, StereoMode);

% fb=[0 1] % select stereo framebuffer for drawing
Screen('SelectStereoDrawBuffer', w, fb);

% Flip everything at once
vbl = Screen('Flip', w);

% Gamma Correction to allow intensity in fractions
gamma=2.2;
[OLD_Gamtable, dacbits, reallutsize] = ...
        Screen('ReadNormalizedGammaTable', ScrNr);
GamCor=(0:1/255:1).^(1/gamma));
Gamtable=[GamCor;GamCor;GamCor]';
Screen('LoadNormalizedGammaTable', ScrNr, Gamtable);


%% EYETRACKER NOTES =================

