%% Data processing plan 
DataFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/log';
AnalysisFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/analysis';
cd(DataFld);
contents = dir('NZ*');
folders = contents([contents.isdir]);

%% Load the data
for f = 1:length(folders)
    warning off
    D(f).log = load(fullfile(folders(f).folder,folders(f).name,'logfile.mat'));
    eyefile = dir(fullfile(folders(f).folder,folders(f).name,'eyedata*'));
    D(f).eye = load(fullfile(eyefile.folder,eyefile.name));
    warning on
    cd(AnalysisFld)
end

%% Process the data
for d = 1:length(D)  % datasets
    traw = D(d).log.log.ev.t;
    tt = traw - traw(1);

    % get block starts
    blockstarts = tt(strcmp(D(d).log.log.ev.type,'BlockStart'));
    bsi = find(strcmp(D(d).log.log.ev.type,'BlockStart'));

    % get prestim starts
    psstarts = tt(strcmp(D(d).log.log.ev.type,'PreStimStart'));
    tpsi = find(strcmp(D(d).log.log.ev.type,'PreStimStart'));

    % get trial starts
    trialstarts = tt(strcmp(D(d).log.log.ev.type,'StimStart'));
    tsi = find(strcmp(D(d).log.log.ev.type,'StimStart'));
    
    % get trial stops
    trialstops = tt(strcmp(D(d).log.log.ev.type,'StimStop'));
    tssi = find(strcmp(D(d).log.log.ev.type,'StimStop'));
    
    % get prestim key-left
    ps_kli = find(strcmp(D(d).log.log.ev.type,'PreStimResponse').*strcmp(D(d).log.log.ev.info,'LeftArrow'));
    ps_keyleft = tt(ps_kli);
    
    % get prestim key-right
    ps_kri = find(strcmp(D(d).log.log.ev.type,'PreStimResponse').*strcmp(D(d).log.log.ev.info,'RightArrow'));
    ps_keyright = tt(ps_kri);
    
    % get stim key-left
    s_kli = find(strcmp(D(d).log.log.ev.type,'PostStimResponse').*strcmp(D(d).log.log.ev.info,'LeftArrow'));
    s_keyleft = tt(s_kli);
    
    % get stim key-right
    s_kri = find(strcmp(D(d).log.log.ev.type,'PostStimResponse').*strcmp(D(d).log.log.ev.info,'RightArrow'));
    s_keyright = tt(s_kri);



    %%
    eyeX = D(d).eye.data.gaze.left.gazePoint.inUserCoords(1,:)./...
        D(d).log.settings.monitor.Deg2Pix;
    eyeT = 0:1/60:(length(eyeX)-1)/60;
    eyeTd = D(d).eye.data.gaze.systemTimeStamp;
    % rereference time
    bs1 = blockstarts(1);
    bs1e = D(d).eye.messages{find(strcmp(D(d).eye.messages(:,2),'BlockStart'),1,'first'),1};
    bs1ei = find(eyeTd <= bs1e,1,"last");
    tt(end) = eyeT(bs1ei) - bs1;
    dt = eyeT(bs1ei) - bs1;
    eyeT2 = eyeT -dt;



    firstblocktrial = 1;
    for b = 1:length(blockstarts) % blocks
        SessNr = d;
        SessFld = folders(d).name;
        BlockNr = b;
        BlockType = D(d).log.settings.block(b).reportmode;
        nTrials = length(D(d).log.settings.block(b).trials);
        trialsthisblock = firstblocktrial:firstblocktrial+nTrials;
        firstblocktrial = trialsthisblock(end)+1;
        ttb=0;
        for ti = trialsthisblock
            ttb = ttb+1;
            TrialNr = ti;
            TrialType = D(d).log.settings.block(b).trials(ttb);
            

        end

        for t = 1:length(trialstarts) % trials
            TrialNr = t;
            TrialType = D(d).log.settings.block(b).trials(t);



        
    end


%% Extract the time of 1st event (beginning of 1st trial of 1st block) 
% from the time of the other events to make comprehensive time units starting from 0 

% Mark the start and end of each block and trial 

% Mark if there was a left or right key-press at the end of every endo prestim phase 

% In report condition mark if there was right or left key-press at the end of every trial 

% Eye tracking data (only for no-report conditions, I%m not using the eye data for report condition) 

% Get eye-trace information per trial (so mark events on eye-trace data as well, align with behavioral data) 

% To determine left or right OKN: (I am not sure which one would work better – the first one is more simple but the second one might be more reliable?) 
% Compute average eye position per trial and determine left or right based on pos or neg value 
% Maybe compute average eye position just some time in the beginning of the trial (e.g. 1 s) 
% so that initial dominance is measured but I couldn’t find information on how long is the OKN and how much time is needed to detect it 

% For this: have to smooth the data, remove blinks so that average is not skewed? 
% OR 
% Compute velocity, then set a threshold for velocity of a saccade and detect saccade based 
% on this threshold being crossed –> determine direction based on saccade direction (opposite direction of stimulus movement) 

end

% In the end create a table with: 
% - Demographic info (age, sex, left/right handed, participant ID) 
% - Endo/exo  
% - Report/no-report  
% - Catch/rivalry  
% - OKN direction (left/right)  
% - Button-press (left/right) 
% - Correctness of endo key-press compared to instruction (correct/incorrect) 