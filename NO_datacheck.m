% load data
cd pilot-data
load('eyedata_20240423_1845');
load('logfile.mat');
cd ..

% re-reference the time of events
tt = log.ev.t-log.ev.t(1);

% get block starts
blockstarts = tt(strcmp(log.ev.type,'BlockStart'));
bsi = find(strcmp(log.ev.type,'BlockStart'));

% get trial starts
trialstarts = tt(strcmp(log.ev.type,'StimStart'));
tsi = find(strcmp(log.ev.type,'StimStart'));

% get trial stops
trialstops = tt(strcmp(log.ev.type,'StimStop'));
tssi = find(strcmp(log.ev.type,'StimStop'));

% get epoch starts (replay)
epochstarts = tt(strcmp(log.ev.type,'EpochStart'));
esi = find(strcmp(log.ev.type,'EpochStart'));
est = [];
for ep = esi'
    est = [est;log.ev.info{ep}(2)];
end

% get key-left
kli = find(strcmp(log.ev.type,'KeyPress').*strcmp(log.ev.info,'LeftArrow'));
keyleft = tt(kli);

% get key-right
kri = find(strcmp(log.ev.type,'KeyPress').*strcmp(log.ev.info,'RightArrow'));
keyright = tt(kri);

% get eyetrace info on a per-trial basis
eyeX = data.gaze.left.gazePoint.inUserCoords(1,:)./settings.monitor.Deg2Pix;
eyeT = 0:1/60:(length(eyeX)-1)/60;
eyeTd = data.gaze.systemTimeStamp;
% rereference time
bs1 = blockstarts(1);
bs1e = messages{find(strcmp(messages(:,2),'BlockStart'),1,'first'),1};
bs1ei = find(eyeTd <= bs1e,1,"last");
dt = eyeT(bs1ei) - bs1;
eyeT2 = eyeT -dt;

%% plot the timeline
nb = length(settings.expt.blockorder);
for b=1:nb
    figure; sgtitle(['Block - ' num2str(b) ' ' settings.block(b).reportmode])
    nt = length(settings.block(b).trials);
    d = ceil(sqrt(nt));
    thisblock0 = blockstarts(b);
    fti = find(trialstarts>thisblock0,1,'first');


    for ti = 1:nt
        trial0 = trialstarts(fti+ti-1);
        trial1 = trialstops(fti+ti-1);
        
        switch settings.block(b).reportmode
            case 'key'
                selkeyl = keyleft(keyleft>trial0 & keyleft<trial1);
                selkeyr = keyright(keyright>trial0 & keyright<trial1);
                subplot(d-1,d,ti); hold on;
                seleye = (eyeT2>trial0 & eyeT2<trial1);
                
                subplot(d-1,d,ti); hold on;
                
                % plot trial keypresses
                plot(selkeyl-trial0,2*ones(size(selkeyl)),'ro','MarkerFaceColor','r');
                plot(selkeyr-trial0,ones(size(selkeyr)),'bo','MarkerFaceColor','b');
                set(gca,'ylim',[-1 3]);
                %plot eye
                plot(eyeT2(seleye)-trial0, eyeX(seleye),'g');
    
                % % if replay plot the direction
                ttype = settings.block(b).trials(ti);
                if settings.trialtype(ttype).replay
                    selepoch = (epochstarts>=trial0 & epochstarts<trial1);
                    rp = est(selepoch);
                    stairs([epochstarts(selepoch)-trial0; 125],...
                        [rp; rp(end-1)]);
                    title(['Trial: ' num2str(ti) ' REPLAY']);
                    legend({'left key','right key','eyeX','replay'})
                    set(gca,'xlim',[0 30]);
                else
                    title(['Trial: ' num2str(ti)]);
                    legend({'left key','right key','eyeX'})
                    set(gca,'xlim',[0 120]);
                end
                xlabel('time(s)');

            case 'verbal'
                voice = log.block(b).trial(ti).voicetrack(1,:);
                td = settings.trialtype(log.block(b).trial(ti).T).time.StimT;
                vt = 0:1/44100:td;

                % rescale voicetrack 
                nv = 1.5 + 1.5*(voice./max(abs(voice)));
                
                % get eye
                seleye = (eyeT2>trial0 & eyeT2<trial1);
                                
                subplot(d-1,d,ti); hold on;
                plot(vt, 3+nv(1:length(vt))); % plot voice
                plot(eyeT2(seleye)-trial0, eyeX(seleye),'g'); % plot eye
                set(gca,'ylim',[-1 3]);

                % % if replay plot the direction
                ttype = settings.block(b).trials(ti);
                if settings.trialtype(ttype).replay
                    selepoch = (epochstarts>=trial0 & epochstarts<trial1);
                    rp = est(selepoch);
                    stairs([epochstarts(selepoch)-trial0; 125],...
                        [rp; rp(end-1)]);
                    title(['Trial: ' num2str(ti) ' REPLAY']);
                    legend({'voice','eyeX','replay'})
                    set(gca,'xlim',[0 30]);
                else
                    title(['Trial: ' num2str(ti)]);
                    legend({'voice','eyeX'})
                    set(gca,'xlim',[0 120]);
                end
                xlabel('time(s)');

            case 'none'
                seleye = (eyeT2>trial0 & eyeT2<trial1);
                subplot(d-1,d,ti); hold on;
                plot(eyeT2(seleye)-trial0, eyeX(seleye),'g');
                set(gca,'ylim',[-1 3]);

                 % % if replay plot the direction
                ttype = settings.block(b).trials(ti);
                if settings.trialtype(ttype).replay
                    selepoch = (epochstarts>=trial0 & epochstarts<trial1);
                    rp = est(selepoch);
                    stairs([epochstarts(selepoch)-trial0; 125],...
                        [rp; rp(end-1)]);
                    title(['Trial: ' num2str(ti) ' REPLAY']);
                    legend({'eyeX','replay'})
                    set(gca,'xlim',[0 30]);
                else
                    title(['Trial: ' num2str(ti)]);
                    legend({'eyeX'})
                    set(gca,'xlim',[0 120]);
                end
                xlabel('time(s)');
             
        end
    end
end
