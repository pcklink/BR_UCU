%% Data processing 
DataFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/log_BA';
AnalysisFld = '/Users/chris/Documents/TEACHING/UU/PF/UCU_thesis/2024/BR_UCU/analysis';
cd(DataFld);

logflds = {...
    'ES','JBL','KvR','LdO','MA-block3','MA-block12','MB','MS',...
    'NS','NZ','OK','PJR-block13','SH','SvR'};

FigType = 'png';

%% Load the data
for f = 1:length(logflds)   
    fprintf(['Getting data from session ' num2str(f) '/' num2str(length(logflds)) '\n'])
    warning off
    D(f).log = load(fullfile(DataFld,logflds{f},'logfile.mat'));
    eyefile = dir(fullfile(DataFld,logflds{f},'eyedata*'));
    D(f).eye = load(fullfile(eyefile.folder,eyefile.name));
    warning on  
end
cd(AnalysisFld)

%% Process the data
for d = 7:length(D)  % datasets
    fprintf(['Data session ' num2str(d) '\n']);
    % - Demographic info (age, sex, left/right handed, participant ID) 
    SUBJECT = D(d).log.log.Subject;
    AGE = D(d).log.log.Age;
    GENDER = D(d).log.log.Gender;
    HANDEDNESS = D(d).log.log.Handedness;

    EPOCHS(d).Sub = SUBJECT;
    EPOCHS(d).Age = AGE;
    EPOCHS(d).Gender = GENDER;
    EPOCHS(d).Handedness = HANDEDNESS;

    traw = D(d).log.log.ev.t;
    tt = traw - traw(1);

    % get block starts
    blockstarts = tt(strcmp(D(d).log.log.ev.type,'BlockStart'));
    bsi = find(strcmp(D(d).log.log.ev.type,'BlockStart'));

    % get trial starts
    trialstarts = tt(strcmp(D(d).log.log.ev.type,'StimStart'));
    tsi = find(strcmp(D(d).log.log.ev.type,'StimStart'));
    
    % get trial stops
    trialstops = tt(strcmp(D(d).log.log.ev.type,'StimStop'));
    tssi = find(strcmp(D(d).log.log.ev.type,'StimStop'));
      
    % get stim key-left
    s_kli = find(strcmp(D(d).log.log.ev.type,'KeyPress').*strcmp(D(d).log.log.ev.info,'LeftArrow'));
    s_keyleft = tt(s_kli);
    
    % get stim key-right
    s_kri = find(strcmp(D(d).log.log.ev.type,'KeyPress').*strcmp(D(d).log.log.ev.info,'RightArrow'));
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
        SessFld = fullfile(fullfile(DataFld,logflds{d}));
        BlockNr = D(d).log.settings.expt.blockorder(b);
        fprintf(['Block ' num2str(BlockNr) '\n']);
        BlockType = D(d).log.settings.block(BlockNr).reportmode;
        
        nTrials = length(D(d).log.log.block(b).trial);
        trialsthisblock = firstblocktrial:firstblocktrial+nTrials-1;
        EPOCHS(d).Block(b).Type = BlockType;

        ttb=0;
        for ti = 1:nTrials
            TrialNr = trialsthisblock(ti); 
            ttb = ttb+1;
            %TrialType = D(d).log.settings.block(BlockNr).trials(ttb);
            TrialType = D(d).log.log.block(b).trial(ti).T;

            StimEye1 = D(d).log.settings.trialtype(TrialType).eye(1).stim;
            StimEye2 = D(d).log.settings.trialtype(TrialType).eye(2).stim;
          
            si_now = trialstarts(TrialNr);
            si_stop = trialstops(TrialNr);

            lkeys = find(s_keyleft > si_now & ...
                s_keyleft < si_stop);
            LKt = s_keyleft(lkeys);
            rkeys = find(s_keyright > si_now & ...
                s_keyright < si_stop);
            RKt = s_keyright(rkeys);

            keyepochs = [LKt -ones(length(LKt),1); ...
                RKt ones(length(RKt),1)];
            [~,sortorder] = sort(keyepochs(:,1));
            keyepochs = keyepochs(sortorder,:);
            if ~isempty(keyepochs)
                keyepochs = [keyepochs(1:end-1,1) ...
                    diff(keyepochs(:,1)) keyepochs(1:end-1,2)];
            end

            EPOCHS(d).Block(b).Trial(TrialNr).epochskey = keyepochs;
            EPOCHS(d).Block(b).Trial(TrialNr).epochskey_hdr = ...
                {'start(s)','dur(s)','percept'};

            % eye ----
            % take entire signal
            ei1 = find(eyeT2 >= si_now, 1, 'first');
            ei2 = find(eyeT2 <= si_stop, 1, 'last');
            EYEX = eyeX(ei1:ei2);
            timeeye = eyeT2(ei1:ei2);
                       
            x = EYEX; t = timeeye;
            t = t - t(1);
            v = (diff(x))*60; % velocity in deg/s
            sw = round(60*0.5); % smoothing window 500 ms
            
            if sum(~isnan(x))>5
                f=figure('visible','on');
                subplot(3,1,1); hold off;
                plot(t,x,'o-'); hold on;
                plot([t(1) t(end)],[0 0],'w');
                title('X position with LOWESS smoothing @100ms')
                sdur = si_stop-si_now;
                span = (1*60)./(sdur*60);
                span = 30;

                xlowess = smooth(t,x,30,'loess');
                v = (diff(xlowess))*60; % velocity in deg/s
                sw = round(60/10); % smoothing window 100 ms
                plot(t,xlowess,'r-','LineWidth',2)

                % acceleration
                subplot(3,1,2); hold off;
                plot([t(1) t(end)],[0 0],'w'); hold on;
                plot(t(3:end),abs(diff(v)),'g-','LineWidth',2);
                title(sprintf(['Acceleration dva/s2']));

                % velocity
                subplot(3,1,3); hold off;
                plot([t(1) t(end)],[0 0],'w'); hold on;
                area(t(2:end),smooth(v,sw));
                plot(t(2:end),smooth(v,sw),'r-','LineWidth',2);
                title(sprintf('Horizontal velocity dva/s'));

                % detect zero crossings
                signal = smooth(v,sw);
                vt=t(2:end);
                pos = signal>0;
                neg = signal<0';

                changepol = diff(pos) ~= 0;
                cp = logical([0 changepol']);
                if any(cp)
                    plot([vt(cp)' vt(cp)'],[-0.5  0.5],'m-');
                end
                sgtitle(['Eyetrace --- ' SUBJECT ' B-' num2str(BlockNr) ...
                    ' T-' num2str(TrialNr)]);

                zct = vt(cp); zcv = signal(cp);
                eyeepochs = []; eei = 1;
                for zci = 1:length(zct)-1
                    epochdur = zct(zci+1)-zct(zci);
                    epochstart = zct(zci);
                    epochval = zcv(zci);
                    eyeepochs = [eyeepochs; ...
                        epochstart epochdur epochval epochval./abs(epochval)];
                end
                
                switch FigType
                    case 'png'
                        fn = ['Sub-' SUBJECT '_Sess-' num2str(d) '_B-' num2str(b) ...
                            '_T-' sprintf('%02d',TrialNr)  '_EYE.png'];
                        [~,~] = mkdir(fullfile('BA_epochs','figs','png'));
                        set(f,"Position",[100 100 1200 800], 'InvertHardcopy', 'off')
                        saveas(f,fullfile('BA_epochs','figs','png',fn));
                    case 'fig'
                        fn = ['Sub-' SUBJECT '_Sess-' num2str(d) '_B-' num2str(b) ...
                            '_T-' sprintf('%02d',TrialNr)  '_EYE.fig'];
                        %set(f,"Position",[100 100 1200 800], 'InvertHardcopy', 'off')
                        %[~,~] = mkdir(fullfile('BA_epochs','figs','fig'));
                        [~,~] = mkdir(fullfile('BA_epochs','figs','fig_olddesktop'));
                        %saveas(f,fullfile('BA_epochs','figs','fig',fn));
                        saveas(f,fullfile('BA_epochs','figs','fig_olddesktop',fn));
                end
                close(f);

                EPOCHS(d).Block(b).Trial(TrialNr).epochseye = eyeepochs;
                EPOCHS(d).Block(b).Trial(TrialNr).epochseye_hdr = ...
                    {'start(s)','dur(s)','mVal','Percept'};
            else
                EPOCHS(d).Block(b).Trial(TrialNr).epochseye = [];
                EPOCHS(d).Block(b).Trial(TrialNr).epochseye_hdr = ...
                    {'start(s)','dur(s)','mVal','Percept'};
            end
        end
        firstblocktrial = trialsthisblock(end)+1;
    end
end

%% Save the results
[~,~] = mkdir('BA_epochs','data');
for i=1:length(EPOCHS)
    fprintf(['Saving session ' num2str(i) '\n']);
    epochs = EPOCHS(i);
    session = logflds{i};%folders(i).name;
    save(fullfile('BA_epochs','data',['epochs_' session]),'epochs','session');
end