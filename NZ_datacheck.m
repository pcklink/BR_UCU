%% load data
cd pilot-data
cd NZ
load('eyedata_20240425_1402');
load('logfile.mat');
cd ..
cd ..

%% trial logs
% re-reference the time of events
tt = log.ev.t-log.ev.t(1);

% get block starts
blockstarts = tt(strcmp(log.ev.type,'BlockStart'));
bsi = find(strcmp(log.ev.type,'BlockStart'));

% get prestim starts
psstarts = tt(strcmp(log.ev.type,'PreStimStart'));
tpsi = find(strcmp(log.ev.type,'PreStimStart'));

% get trial starts
trialstarts = tt(strcmp(log.ev.type,'StimStart'));
tsi = find(strcmp(log.ev.type,'StimStart'));

% get trial stops
trialstops = tt(strcmp(log.ev.type,'StimStop'));
tssi = find(strcmp(log.ev.type,'StimStop'));

% get prestim key-left
ps_kli = find(strcmp(log.ev.type,'PreStimResponse').*strcmp(log.ev.info,'LeftArrow'));
ps_keyleft = tt(ps_kli);

% get prestim key-right
ps_kri = find(strcmp(log.ev.type,'PreStimResponse').*strcmp(log.ev.info,'RightArrow'));
ps_keyright = tt(ps_kri);

% get stim key-left
s_kli = find(strcmp(log.ev.type,'PostStimResponse').*strcmp(log.ev.info,'LeftArrow'));
s_keyleft = tt(s_kli);

% get stim key-right
s_kri = find(strcmp(log.ev.type,'PostStimResponse').*strcmp(log.ev.info,'RightArrow'));
s_keyright = tt(s_kri);

%%
% get eyetrace info on a per-trial basis
eyeX = data.gaze.left.gazePoint.inUserCoords(1,:)./settings.monitor.Deg2Pix;
eyeT = 0:1/60:(length(eyeX)-1)/60;
eyeTd = data.gaze.systemTimeStamp;
% rereference time
bs1 = blockstarts(1);
bs1e = messages{find(strcmp(messages(:,2),'BlockStart'),1,'first'),1};
bs1ei = find(eyeTd <= bs1e,1,"last");
tt(end) = eyeT(bs1ei) - bs1;
eyeT2 = eyeT -dt;

%% plot the timeline
nb = length(settings.expt.blockorder);
figure; 
for b=1:2%nb
    subplot(2,1,b); hold on;
    title(['Block - ' num2str(b) ' ' settings.block(b).reportmode])
    nt = length(settings.block(b).trials);
    d = ceil(sqrt(nt));
    thisblock0 = blockstarts(b);
    if b<nb
        thisblock1 = blockstarts(b+1);
    else
        thisblock1 = tt(end);
    end

    fti = find(trialstarts>thisblock0 & trialstarts<thisblock1);
    fpsi = find(psstarts>thisblock0 & psstarts<thisblock1);
    psli = find(ps_keyleft>thisblock0 & ps_keyleft<thisblock1);
    psri = find(ps_keyright>thisblock0 & ps_keyright<thisblock1);
    sli = find(s_keyleft>thisblock0 & s_keyleft<thisblock1);
    sri = find(s_keyright>thisblock0 & s_keyright<thisblock1);
    
    seleye = (eyeT2>thisblock0 & eyeT2<thisblock1);

    plot(blockstarts, ones(size(blockstarts)).*-1,'dc');    
    hold on


    %plot eye
    plot(eyeT2(seleye), eyeX(seleye),'g');
    % plot prestim stuff
    plot(psstarts(fpsi)-thisblock0, ones(1,length(fpsi)),'sw')
    plot(ps_keyleft(psli)-thisblock0, ones(1,length(psli)),'or')
    plot(ps_keyright(psri)-thisblock0, ones(1,length(psri)),'ob')


    % plot stim stuff
    plot(trialstarts(fti)-thisblock0, 2*ones(1,length(fti)),'*w')
    plot(s_keyleft(sli)-thisblock0, 2*ones(1,length(sli)),'or')
    plot(s_keyright(sri)-thisblock0, 2*ones(1,length(sri)),'ob')
end
