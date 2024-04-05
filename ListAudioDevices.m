% this script lists the available audio devices and most important specs
% use it to select the input and output devices you want to use
% set the correct idx an nchan in the settings file

fprintf('=========================================\n')
fprintf('AUDIO DEVICES AVAILABLE ON THIS SYSTEM\n')
fprintf('=========================================\n')


audiodevices = PsychPortAudio('GetDevices');
for i=1:length(audiodevices)
    fprintf(['Audio device '...
        num2str(audiodevices(i).DeviceIndex) ' ' ...
        audiodevices(i).DeviceName '\n'...
        'nIn = ' num2str(audiodevices(i).NrInputChannels) ', '...
        'nOut = ' num2str(audiodevices(i).NrOutputChannels) ', '...
        'SR = ' num2str(audiodevices(i).DefaultSampleRate) '\n']);
end
