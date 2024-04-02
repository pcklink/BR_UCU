% CalibrateEyetracker

% set screens in mirror mode
system("xrandr --output DP-1 --same-as DP-0") % set monitors mirrored
WaitSecs(3)

% do calibration
calibrateTobii;

% set screens in extended mode
system("xrandr --output DP-1 --right-of DP-0") % set monitors mirrored
WaitSecs(3)