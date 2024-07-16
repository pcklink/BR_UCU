% Example script for collecting data for a particular set of TrialTypes

% load data
load(fullfile('BA_epochs','data','ALL_EPOCHS'));

%% fix participant 'MA'
EPOCHS(6).Block(3) = EPOCHS(5).Block(1);
EPOCHS(5:13) = EPOCHS(6:14);
EPOCHS(14) = [];

%% Collect data =====
% Trialtypes to combine
ttc = 2:9; % << I picked this pretty randomly
% for non-continuous lists use something like [1,3,7,14,etc]

OUTPUT = []; COLLECT = [];
% loop over participants
for s=1:length(EPOCHS)
    % loop over blocks
    for b=1:length(EPOCHS(s).Block)
        % loop over trials
        for t = 1:length(EPOCHS(s).Block(b).Trial)
            % if TrialType is among the selected
            if ismember(EPOCHS(s).Block(b).Trial(t).TrialType,ttc)
                % get epoch list
                keys = EPOCHS(s).Block(b).Trial(t).epochskey;
                % if epochs are reported
                if ~isempty(keys)
                    % get the total duration left and right
                    totleft = sum(keys(keys(:,3)==-1,2));
                    totright = sum(keys(keys(:,3)==1,2));
                    % collect these values
                    COLLECT = [COLLECT;...
                        s b t totleft totright];
                end
            end
        end
    end
    % calculate the sum over all trials for this subject
    tlr = COLLECT(COLLECT(:,1)==s,[4 5]);
    OUTPUT = [OUTPUT; s sum(tlr,1)];
end
fprintf('SUM OF EPOCHS LEFT/RIGHT PER PARTICIPANT\n')
fprintf('SUBJECT -- LEFT -- RIGHT\n')
OUTPUT

%% Plot the data ====
mSUM = mean(OUTPUT(:,2:3));
sdSUM = std(OUTPUT(:,2:3));
semSUM = sdSUM./sqrt(size(OUTPUT,1));

figure;
subplot(1,2,1); hold on;
bar(1:2,mSUM);
errorbar(1:2,mSUM,sdSUM,'LineStyle','none');
title('Mean and standard deviation of cumulative percept duration');
set(gca,'xlim',[0.5 2.5],'xtick',1:2,'xticklabels',{'LEFT-ARROW','RIGHT-ARROW'});

subplot(1,2,2); hold on;
plot(1:2,OUTPUT(:,2:3));
errorbar(1:2,mSUM,sdSUM,'r','LineWidth',3);
title('Individual participants');
set(gca,'xlim',[0.5 2.5],'xtick',1:2,'xticklabels',{'LEFT-ARROW','RIGHT-ARROW'});

% do a ttest
[H,P,CI,STATS] = ttest(OUTPUT(:,2),OUTPUT(:,3));
fprintf('Paired ttest on LEFT vs RIGHT\n');
fprintf(['t = ' num2str(STATS.tstat) ', df = ' num2str(STATS.df) ...
    ', p = ' num2str(P) '\n']);
