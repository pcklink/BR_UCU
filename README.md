# Binocular Rivalry
This code was written to perform binocular rivalry experiments on a mirror stereoscope set-up, e.g. at the Department of Experimental Psychology of Utrecht University. The documentation below provides some guidance to the experimental code.

Written by Chris Klink (p.c.klink@uu.nl)

## The setup
The setup is outfitted with a computer that runs a Linux Mint operating system that drives two LCD monitors on the integrated Intel graphics (2*DisplayPort). We have tried two concrete graphics cards, with various levels of success, but neither provided all the features we needed.
Experimental control can be done in various ways. E.g., Python 3 is installed, but we will run the current experiment in Matlab and the [Psychtoolbox-3](http://psychtoolbox.org/) extensions.
Participants are seated with their heads in a chin- and head-rest. They then view the two screens through a set of mirrors so that their left eye sees the left screen and the right eye sees the right screen. This setup can then be used to run binocular rivalry or stereoscopy experiments.

## Eye-tracking    
The set-up in lab space E003 has a [Tobii Pro Fusion eye tracker](https://www.tobii.com/products/eye-trackers/screen-based/tobii-pro-fusion?creative=641444153221&keyword=eyetracking%20software&matchtype=p&network=g&device=c&utm_source=google&utm_medium=cpc&utm_campaign=&utm_term=eyetracking%20software&gad_source=1) that can track the eyes through the hot-mirror of the stereoscope. This method is explained in [Brascamp & Naber, (2017)](https://psycnet.apa.org/record/2017-33915-010). The eyetracker can be calibrated with the `CalibrateEyetracker` function which sets the monitors in mirror mode to perform calibration and switches them back to extended mode when done. The equivalent code can also be run as part of the `BR_UCU` routine by setting the `eyetracker.calibrate` variable to `true`. Both methods call the `calibrateTobii.m` file to perform the calibration. 

In the calibration screen you have the following key options:    
`shift-escape`: hard exit from the calibration mode. By default, this causes en error to be thrown and script execution to stop if that error is not caught.    
`shift-s`: skip calibration. If still at setup screen for the first time, the last calibration (perhaps of a previous session) remains active. To clear any calibration, first enter the calibration screen and immediately then skip with this key combination.

Additional key options that you probably won't need but are nevertheless good to know about.    

Only in the **Setup** display:       
`spacebar`: start a calibration (setup.cal)       
`e`: toggle eye images      
`p`: return to validation result display, available if there are any previous calibrations     
`c`: open menu to change which eye will be calibrated (both, left, right). The menu can be keyboard-controlled: each of the items in the menu are preceded by the number to press to activate that option.     

In the **Calibration and validation** display:    
`escape`: return to setup screen.      
`r`: restart calibration sequence from the beginning     
`backspace`: redo the current calibration/validation point.     
`spacebar`: accept current calibration/validation point. (also done automatically)     

In the **Validation result** display:     
`spacebar`: select currently displayed calibration and exit the interface/continue experiment    
`escape`: start a new calibration     
`v`: revalidate the current calibration      
`s`: return to the setup screen      
`c`: bring up a menu from which other calibrations performed in the same session can be selected
`g`: toggle whether online gaze position is visualized on the screen    
`p`: bring up plot of gaze and pupil data collected during validation    
`t`: toggle between whether gaze data collected during validation or during calibration is shown in the interface      
`x`: toggle between whether gaze data and calibrations are shown in screen space or tracker space     


## Audio   
The script can record audio and saves the tracks as a wav file per trial titled `voice_b-<BLOCKNUM>_t-<TRIALNUM>.wav`. The audiotrack is also saved as a matrix in the regular log file. If you choose to do this, it is highly recommended to also play a sound to mark the start of a trial. In order for all of this to work, you will need to tell the experiment script what the device IDs are for the recording and playing devices, and whether they are mono or stereo. If you leave this empty, default values will be used which are not guaranteed to work. There is a little script `ListAudioDevices` that will print the necessary information about the audiodevices that are present on the system to the command window. Get the proper device IDs adn the corresponding number of audio channels from this list and enter them in your settings file. 

## How to run an experiment
The initial code was written to facilitate three thesis project for UCU students in the spring of 2024. It runs by executing `BR_UCU("settings-file")` where `"settings-file"` specifies the name of an m-file with settings that defines the experimental parameters. When a file-specification is omitted, the default `"settings_def"` is loaded (i.e., the `settings_def.m` file).
Interfacing wth the eye-tracker via Matlab is done using the [Titta toolbox](https://github.com/dcnieho/Titta), with some adjustments to account for the fact that observers view the screen via a mirror.

## Stimulus control
The default `settings_def.m` file is annotated to explain what all variables are. The `BR_UCU.m` also has lots of comments explaining what happens where. The main aspects are also explained below.

### Epochs
Every **experiment** contains a set of **blocks** of **trials**. A **trialtype** specifies which stimuli will be shown in a **trial** and you specify which **trialtypes** are part of a **block**, how many times the **trials** are repeated in a **block** and how many times the **blocks** are **repeated** withing an **experiment**. You can also randomize **trials** in a **block** and **blocks** in an **experiment**.

A **block** starts with an instruction screen that will be displayed until the participant presses a key on the keyboard. It then proceeds to run trials:

A trial can contain the following epochs:
- *Fix*: a period with only the background elements and a fixation dot    
- *Prestim* [OPTIONAL]: a cueing period that can be used for *endogenous* or *exogenous* attention manipulations (see below)     
- *Gap* [OPTIONAL]: A brief period with only the background elements    
- *Stim*: The main stimulus period during which responses are collected    
- *ITI*: A brief period with only the background elements 

For each **block** you can specify a **recordmode**. This does nothing for the code but can help you coordinate. In the hardware settings of the settings file you can specify if an **audiotrack** and/or **eye-trace** needs to be recorded. If this is done, it will be done for every block, but you tell your observers through an instruction screen how they are expected to report. Likewise **key-presees** are also always registered and logged.

At the start of the experiment, there will be several questions in the matlab command window forcing you to register the initials, age, handedness, and gender of your participants. Additional questions can be added here, but don't overdo it.

The experiment ends with a brief 'thank you' screen.

### Stimulus options
Stimulus options are different for the optional *prestim* period and the obligatory *stim* period.

In **prestim** there will always be the same two stimuli presented together on both screens. Depending on the type of attention observers either track one of the stimuli while it gradually changes over time (endogenous) or one of the stimuli briefly changes contrast (exogenous).

You can specify the following stimuli:
- Gratings (drifting or static) that:
  - change orientation (endo)
  - have a brief contrast change (exo)
- Moving dots that
  - change direction (endo)
  - have a brief contrast change (exo)    
  
Do test this, as some configuration are perceptually a bit weird. Find out what works for your question.

In **stim** the stimuli can be different for the two eyes to evoke binocular rivalry. Do check if the left/right assignment is as planned; the mirror may make things a bit more complex. Here you have even more stimulus options:
- Drifting gratings
- Drifting dots
- A bitmap image with an overlay of:
  - drifting lines
  - drifting dots
See `settings_def.m` for details.

All settings and responses will automatically be saved in a log-file with the timestamp of when the experiment was run. This file will be in a folder that you specify in the settings file.

