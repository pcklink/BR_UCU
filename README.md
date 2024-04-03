# Binocular Rivalry
This code was written to perform binocular rivalry experiments on a mirror stereoscope set-up, e.g. at the Department of Experimental Psychology of Utrecht University. The documentation below provides some guidance to the experimental code.

Written by Chris Klink (p.c.klink@uu.nl)

## The setup
The setup is outfitted with a computer that runs a Linux Mint operating system that drives two LCD monitors on the integrated Intel graphics (2*DisplayPort). We have tried two concrete graphics cards, with various levels of success, but neither provided all the features we needed.
Experimental control can be done in various ways. E.g., Python 3 is installed, but we will run the current experiment in Matlab and the [Psychtoolbox-3](http://psychtoolbox.org/) extensions.
Participants are seated with their heads in a chin- and head-rest. They then view the two screens through a set of mirrors so that their left eye sees the left screen and the right eye sees the right screen. This setup can then be used to run binocular rivalry or stereoscopy experiments.

## Eye-tracking    
The set-up in lab space E003 has a [Tobii Pro Fusion eye tracker](https://www.tobii.com/products/eye-trackers/screen-based/tobii-pro-fusion?creative=641444153221&keyword=eyetracking%20software&matchtype=p&network=g&device=c&utm_source=google&utm_medium=cpc&utm_campaign=&utm_term=eyetracking%20software&gad_source=1) that can track the eyes through the hot-mirror of the stereoscope. This method is explained in [Brascamp & Naber, (2017)](https://psycnet.apa.org/record/2017-33915-010). The eyetracker can be calibrated with the `CalibrateEyetracker` function which sets the monitors in mirror mode to perform calibration and switches them back to extended mode when done. The equivalent code can also be run as part of the `BR_UCU` routine. Both methods call the `calibrateTobii.m` file to perform the calibration. 

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

All settings and responses will automatically be saved in a log-file with the timestamp of when the experiment was run. THis file will be in a folder that you specify in the settings file.

