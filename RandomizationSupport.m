% RandomizationSupport

% I was thinking of making 4 blocks: 
% 1 - button-press
% 2 - button-press catch trial
% 3 - no report 
% 4 - no report catch trial
% 
% This is necessary because I wanted to have a different number of trials for each.
% However, in the experiment block order I want the button press and no report to be separated
% (one following the other) but having normal and catch trials (randomized) in both button 
% press and no report. I'm not sure how this could be done.

% Use 'block chunks' to randomize within chunks and chunk order, but not
% across chunks

% assuming the above listed numbering for block types
blockchunk{1} = [1 2]; % button press, exo
blockchunk{2} = [3 4];% button press, endo
blockchunk{3} = [5 6]; % no report, exo
blockchunk{4} = [7 8];% no report, endo 

blockrepeats = 1; % repeat 'sets' of blocks

blockorder = [];

randomchunkorder = false;
randomblocksinchunk = true;

for i = 1:blockrepeats
    % randomize block chunk order
    if randomchunkorder
        j = randperm(length(blockchunk));
    else
        j = 1:length(blockchunk);
    end
    for j = j
        %randomize within chunk
        if randomblocksinchunk
            k = blockchunk{j}(randperm(length(blockchunk{j})));
        else
            k = blockchunk{j};
        end
        blockorder = [blockorder k];
    end
end

