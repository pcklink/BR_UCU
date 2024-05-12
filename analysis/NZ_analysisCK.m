%% Data processing 
DataFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/log';
AnalysisFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/analysis';
cd(DataFld);
contents = dir('NZ*');
folders = contents([contents.isdir]);

%% Load the data
for f = 1:length(folders)
    fprintf(['Getting data from session ' num2str(f) '/' num2str(length(folders)) '\n'])
    warning off
    D(f).log = load(fullfile(folders(f).folder,folders(f).name,'logfile.mat'));
    eyefile = dir(fullfile(folders(f).folder,folders(f).name,'eyedata*'));
    D(f).eye = load(fullfile(eyefile.folder,eyefile.name));
    warning on
    cd(AnalysisFld)
end

%% Process the data
% Create a table to collect data
T={};
vNames = {'SesID','SesFld','Subject','Age','Gender','Handedness',...
    'Block','Report','TrialNum','TrialType','PreStim','StimL', 'StimR',...
    'Attention','PrestimResponse','PreStimEnd','PreStimTransient',...
    'StimResponse','Eye_slope','Eye_pval',...
    'Eye_meandiff','Eye_sumdiff','Eye_stddiff','mVel'};
row=1;
for d = 1:length(D)  % datasets
    fprintf(['Data session ' num2str(d) '\n']);
    % - Demographic info (age, sex, left/right handed, participant ID) 
    SUBJECT = D(d).log.log.Subject;
    AGE = D(d).log.log.Age;
    GENDER = D(d).log.log.Gender;
    HANDEDNESS = D(d).log.log.Handedness;

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

    eyeX = D(d).eye.data.gaze.left.gazePoint.inUserCoords(1,:)./...
        D(d).log.settings.monitor.Deg2Pix;
    eyeX(~D(d).eye.data.gaze.left.gazePoint.valid) = NaN;
    eyeT = 0:1/60:(length(eyeX)-1)/60;
    eyeTd = D(d).eye.data.gaze.systemTimeStamp;
    % rereference time
    bs1 = blockstarts(1);
    bs1e = D(d).eye.messages{find(strcmp(D(d).eye.messages(:,2),'BlockStart'),1,'first'),1};
    bs1ei = find(eyeTd <= bs1e,1,"last");
    tt(end) = eyeT(bs1ei) - bs1;
    dt = eyeT(bs1ei) - bs1;
    eyeT2 = eyeT - dt;

    firstblocktrial = 1;
    for b = 1:length(blockstarts) % blocks
        SessNr = d;
        SessFld = folders(d).name;
        BlockNr = D(d).log.settings.expt.blockorder(b);
        fprintf(['Block ' num2str(BlockNr) '\n']);
        BlockType = D(d).log.settings.block(BlockNr).reportmode;
        nTrials = length(D(d).log.settings.block(BlockNr).trials);
        trialsthisblock = firstblocktrial:firstblocktrial+nTrials-1;
        
        ttb=0;
        for ti = 1:nTrials
            TrialNr = trialsthisblock(ti); 
            ttb = ttb+1;
            TrialType = D(d).log.settings.block(BlockNr).trials(ttb);

            PreStim = D(d).log.settings.trialtype(TrialType).prestim;
            StimEye1 = D(d).log.settings.trialtype(TrialType).eye(1).stim;
            StimEye2 = D(d).log.settings.trialtype(TrialType).eye(2).stim;
            Attention = D(d).log.settings.prestim(PreStim).attentiontype;

            psi_now = psstarts(ti);
            switch Attention
                case 'exogenous'
                    PrestimResponse = 'none';
                    PreStimEnd = NaN;
                    PreStimTransient = D(d).log.settings.prestim(PreStim).transient.stim;
                case 'endogenous'
                    l1 = find(ps_keyleft > psi_now, 1, 'first');
                    r1 = find(ps_keyright > psi_now, 1, 'first');
                    if l1 < r1
                        PrestimResponse = 'left';
                    else
                        PrestimResponse = 'right';
                    end
                    PreStimEnd = D(d).log.settings.prestim(PreStim).driftspeed(2,1);
                    PreStimTransient = NaN;
            end
            
            si_now = trialstarts(ti);
            switch BlockType
                case 'key'
                    l1 = find(s_keyleft > si_now, 1, 'first');
                    r1 = find(s_keyright > si_now, 1, 'first');
                    if l1 < r1
                        StimResponse = 'left';
                    else
                        StimResponse = 'right';
                    end
                case 'none'
                    StimResponse  = 'none';
            end


            % eye ----
            % take signal from first second
            duration = 1.5;
            ei1 = find(eyeT2 >= si_now - 1, 1, 'first');
            ei2 = find(eyeT2 <= si_now + duration, 1, 'last');
            EYEX = eyeX(ei1:ei2);
            % linear regression
            timeeye = eyeT2(ei1:ei2);
            incidx = ~isnan(EYEX) & (timeeye>=si_now) & (timeeye<=si_now+1);
                        
            warning off
            lm = fitlm(timeeye(incidx),EYEX(incidx));
            slope = lm.Coefficients.Estimate("x1");
            pval = lm.Coefficients.pValue("x1");
            warning on
            % some simple values
            dEYE_SUM = sum(diff(EYEX(incidx)));
            dEYE_MEAN = mean(diff(EYEX(incidx)));
            dEYE_STD = std(diff(EYEX(incidx)));
            % --------
              
            % figure
            if row ==1
                f=figure('visible','off');
            end

            x = EYEX; t = timeeye;
            v = (diff(x))*60; % velocity in deg/s
            sw = round(60*0.5); % smoothing window 500 ms

            subplot(2,1,1); hold off;
            plot(t,x,'o-'); hold on;
            plot([t(1) t(end)],[0 0],'w');
            plot([si_now si_now],[-1,1]*max(abs(x)),'y');
            plot([si_now+1 si_now+1],[-1,1]*max(abs(x)),'y--');
            plot(timeeye(incidx),lm.Coefficients.Estimate("x1")*timeeye(incidx) + ...
                lm.Coefficients.Estimate("(Intercept)"));
            yr = max(abs(x(t>si_now & t<si_now+1)));
            if ~isnan(yr) && yr
                set(gca,'xlim',[si_now-0.5 si_now+1.5],'ylim',[-1,1]*yr);
            else
                set(gca,'xlim',[si_now-0.5 si_now+1.5]);
            end
            title('X position')

            subplot(2,1,2); hold off;
            yrr = smooth(v,sw);
            yr = max(abs(yrr(t>si_now & t<si_now+1)));
            plot(t(2:end),smooth(v,sw),'o-'); hold on;
            plot([t(1) t(end)],[0 0],'w');
            plot([si_now si_now],[-1,1]*max(abs(smooth(v,sw))),'y');
            plot([si_now+1 si_now+1],[-1,1]*max(abs(smooth(v,sw))),'y--');
            if ~isnan(yr) && yr
                set(gca,'xlim',[si_now-0.5 si_now+1.5],'ylim',[-1,1]*yr);
            else
                set(gca,'xlim',[si_now-0.5 si_now+1.5]);
            end
            title('Horizontal velocity (smoothed')

            sgtitle(['Eyetrace --- ' SUBJECT ' B-' num2str(BlockNr) ...
                ' T-' num2str(TrialNr)]);

            idx = (t>=si_now) & (t<=si_now+1);
            mVel = mean(smooth(v(idx),sw));
            
            [~,~] = mkdir('NZ_eye');
            fn = ['eye_csvrow_'  sprintf('%03d', row) '.png'];
            set(gcf,"Position",[100 100 400 800], 'InvertHardcopy', 'off')
            saveas(f,fullfile('NZ_eye',fn));

            newRow = {SessNr,SessFld,SUBJECT,str2double(AGE),GENDER,HANDEDNESS,...
                BlockNr,BlockType,TrialNr,TrialType,PreStim,StimEye1,StimEye2,...
                Attention,PrestimResponse,PreStimEnd,PreStimTransient,...
                StimResponse,slope,pval,dEYE_MEAN,dEYE_SUM,dEYE_STD,mVel};
            T = [T; newRow];

            row = row+1;
        end
        firstblocktrial = trialsthisblock(end)+1;
    end
end

%% Save the results
T = cell2table(T,"VariableNames",vNames);
writetable(T,'NZ_RESULTS.csv')