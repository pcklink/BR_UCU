% CalibrateEyetracker

% set screens in mirror mode
system("xrandr --output DP-2 --same-as DP-1") % set monitors mirrored
WaitSecs(3)

% do calibration
calibrateTobii;

% set screens in extended mode
system("xrandr --output DP-2 --right-of DP-1") % set monitors mirrored
WaitSecs(3)

%    CALIBRATIONATTEMPT = Titta.calibrate(WPNT) displays the
%    participant setup and calibration interface on the
%    PsychToolbox window specified by WPNT.
%
%    WPNT can also be an array of two window pointers.
%    In this case, the first window pointer is taken to refer
%    to the participant screen, and the second to an operator
%    screen. A minimal interface is then presented on the
%    participant screen, while full information is shown on the
%    operator screen, including a live view of gaze data and
%    eye images (if available) during calibration and
%    validation.
%
%    CALIBRATIONATTEMPT is a struct containing information
%    about the calibration/validation run.
%
%    CALIBRATIONATTEMPT = Titta.calibrate(WPNT,FLAG) provides
%    control over whether the call causes the eye tracker's
%    calibration mode to be entered or left. The available
%    flags are:
%      1 - enter calibration mode when starting calibration
%      2 - exit calibration mode when calibration finished
%      3 - (default) both enter and exit calibration mode
%
%    FLAG is used for bimonocular calibrations, when
%    Titta.calibrate() is called twice in a row, first to
%    calibrate the first eye (use FLAG=1 to enter calibration
%    mode here but not exit), and then a second time to
%    calibrate the other eye (use FLAG=2 to exit calibration
%    mode when done).
%
%    CALIBRATIONATTEMPT = Titta.calibrate(WPNT,FLAG,PREVIOUSCALIBS)
%    allows to prepopulate the interface with previous
%    calibration(s). The previously selected calibration is
%    made active and it can then be revalidated and used, or
%    replaced. PREVIOUSCALIBS is expected to be a
%    CALIBRATIONATTEMPT output from a previous run of
%    Titta.calibrate. Note that the PREVIOUSCALIBS
%    functionality should be used together with bimonocular
%    calibration _only_ when the calibration of the first eye
%    is not replaced (validating it is ok, and recommended).
%    This because prepopulating calibrations for the second eye
%    will load this previous calibration, and thus undo any new
%    calibration for the first eye.
%
%    INTERFACE
%    During anywhere on the participant setup and calibration
%    screens, the following key combinations are available:
%      shift-escape - hard exit from the calibration mode. By
%                     default (see
%                     settings.UI.hardExitClosesPTB), this
%                     causes en error to be thrown and script
%                     execution to stop if that error is not
%                     caught.
%      shift-s      - skip calibration. If still at setup
%                     screen for the first time, the last
%                     calibration (perhaps of a previous
%                     session) remains active. To clear any
%                     calibration, first enter the calibration
%                     screen and immediately then skip with
%                     this key combination.
%      shift-d      - take screenshot of the participant
%                     display, which will be stored to the
%                     current active directory (cd).
%      shift-o      - when in dual-screen mode, take a
%                     screenshot of the operator display, which
%                     will be stored to the current active
%                     directory (cd).
%      shift-g      - when in dual screen mode, by default the
%                     show gaze button on the validation result
%                     screen only shows real-time gaze position
%                     on the operator's screen. If the shift
%                     key is held down while clicking the
%                     button with the mouse, or when pressing
%                     the functionality's hotkey (g by
%                     default, see documentation of validation
%                     results screen interface below),
%                     real-time gaze will also be shown on the
%                     participant's screen.
%
%    In addition to these, the three different screens that
%    make up this procedure each have their own keys available.
%    Some of these are hardcoded, others can be changed through
%    Titta's settings. In the latter case, their default value
%    is listed here, and the settings name is indicated in
%    abbreviated form (e.g. `setup.toggEyeIm` refers to the
%    setting `settings.UI.button.setup.toggEyeIm.accelerator`,
%    gotten from Titta.getDefaults() or Titta.getOptions()).
%    For the setup and validation result displays, these keys
%    have a clickable button in the interface associated with
%    them. Most of these buttons are visible by default, but
%    some are not. You can change button visibility by
%    changing, e.g.,
%    `settings.UI.button.setup.toggEyeIm.visible`. Invisible
%    buttons can still be activated or deactivated by means of
%    the configured keys.
%
%    Setup display:
%      spacebar  - start a calibration (setup.cal)
%      e         - toggle eye images, if available
%                  (setup.toggEyeIm)
%      p         - return to validation result display,
%                  available if there are any previous
%                  calibrations (setup.prevcal)
%      c         - open menu to change which eye will be
%                  calibrated (both, left, right). The menu can
%                  be keyboard-controlled: each of the items in
%                  the menu are preceded by the number to press
%                  to activate that option. Available only if
%                  the eye tracker supports monocular
%                  calibration (setup.changeeye)
%
%    Calibration and validation display:
%      escape    - return to setup screen.
%      r         - restart calibration sequence from the
%                  beginning
%      backspace - redo the current calibration/validation
%                  point. When using the
%                  AnimatedCalibrationDisplay class
%                  (settings.cal.drawFunction), this causes the
%                  currently displayed point to blink.
%      spacebar  - accept current calibration/validation point.
%                  Whether it is needed to press spacebar to
%                  collect data for a point depends on the
%                  settings.cal.autoPace setting.
%
%    Validation result display:
%      spacebar  - select currently displayed calibration and
%                  exit the interface/continue experiment
%                  (val.continue)
%      escape    - start a new calibration (val.recal)
%      v         - revalidate the current calibration
%                  (val.reval)
%      s         - return to the setup screen (val.setup)
%      c         - bring up a menu from which other
%                  calibrations performed in the same session
%                  can be selected (val.selcal)
%      g         - toggle whether online gaze position is
%                  visualized on the screen. When in dual
%                  screen mode, gaze will only be visualized to
%                  the operator. Press shift-g (or hold down
%                  shift while pressing the interface button
%                  with the mouse) to also show the online
%                  gaze position on the participant screen
%                  (val.toggGaze)
%      p         - bring up plot of gaze and pupil data
%                  collected during validation (val.toggPlot)
%      t         - toggle between whether gaze data collected
%                  during validation or during calibration is
%                  shown in the interface (val.toggCal)
%      x         - toggle between whether gaze data and
%                  calibrations are shown in screen space or
%                  tracker space (these are the same unless
%                  settings.cal.pointPosTrackerSpace is
%                  specified) are shown in the interface
%                  (val.toggSpace)