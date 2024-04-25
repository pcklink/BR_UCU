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

%% plot the timeline
nb = length(settings.expt.blockorder);
for b=1%:nb
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
                % plot trial keypresses
                plot(selkeyl-trial0,2*ones(size(selkeyl)),'ro','MarkerFaceColor','r');
                plot(selkeyr-trial0,ones(size(selkeyr)),'bo','MarkerFaceColor','b');
                title(['Trial: ' num2str(ti)]);
                legend({'left key','right key'})
                set(gca,'ylim',[0 4]);
    
                % % if replay plot the direction
                % ttype = ettings.block(b).trials(ti);
                % if settings.trialtype(ttype).replay
                selepoch = (epochstarts>=trial0 & epochstarts<trial1);
                stairs(epochstarts(selepoch)-trial0,est(selepoch));


            case 'verbal'

            case 'none'
        end
        
        
        

    end
end
