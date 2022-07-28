%% treadmill tuning analysis

%% plot stuff

cd /media/jack/DATA/gruData/;

% fixed params
plotDirs = 30:30:360;
speedThresh = 3; % cm/s (arbitrary)
%timeScale = 1; % 1/0.060; %hardcoded for now
%hzScale = 1;

%% determine whether trials were stationary or moving

for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = allUnits{1,plotUnit};
    
        clearvars moveIndex statIndex tmpDir ;
        
        %index which trials were moving and which were stationary        
        moveIndex = zeros(size(tmpUnit, 1), 1);
        tmpStimDurs = unique(tmpUnit.stimDur);
        tmpTable = table('Size', [size(tmpUnit, 1),1], 'VariableTypes', ["logical"], 'VariableNames', ["locomoting"]);
        
        %check for movement across all stim durs
        for currDur = 1 : size(tmpStimDurs, 2)
            moveIndexTmp = tmpUnit.stimDur == tmpStimDurs(currDur) & abs(tmpUnit.pos4 - tmpUnit.pos1) * (1/tmpStimDurs(currDur)) > speedThresh;
            statIndexTmp = tmpUnit.stimDur == tmpStimDurs(currDur) & abs(tmpUnit.pos4 - tmpUnit.pos1) * (1/tmpStimDurs(currDur)) < speedThresh;
            moveIndex = or(moveIndex, moveIndexTmp);
        end        
    tmpTable.locomoting = moveIndex;
    allUnits{1,plotUnit} = [allUnits{1,plotUnit} tmpTable];
    
end

%% psth for each unit

for plotUnit = 1 : size(allUnits,2)
    
    % load in the current unit and find the dates it was active
    tmpUnit = allUnits{3,plotUnit};
    [unitDates, dateFirsts] = unique(allUnits{1,plotUnit}.date,'first');
    
    % add stim info to psth block
    tmpUnit = [tmpUnit num2cell(allUnits{1,plotUnit}.dir)];
    
    %     % get stim info from each date
    %     for i = 1:size(unitDates, 1)
    %
    %         unitDates(i, 2) = allUnits{1,plotUnit}.stimDur(dateFirsts(i));
    %
    %     end
    
    % divide data into locomoting and not
    
    for isLoco = 0:1
        
        clear locoTmpUnit tmpUnitRel;
        
        locoTmpUnit = tmpUnit(allUnits{1,plotUnit}.locomoting == isLoco, :);
        
        % make all times relative to trial start
        for iTrial = 1:size(locoTmpUnit, 1)
            
            tmpUnitRel.spikes{iTrial,1} = locoTmpUnit{iTrial,1} - locoTmpUnit{iTrial,2};
            tmpUnitRel.end(iTrial,1) = locoTmpUnit{iTrial,3} - locoTmpUnit{iTrial,2};
            tmpUnitRel.date(iTrial,1) = str2double(locoTmpUnit{iTrial,5});
            if ~isempty(locoTmpUnit{iTrial,4})
                
                tmpUnitRel.isiEnd(iTrial,1) = locoTmpUnit{iTrial,4} - locoTmpUnit{iTrial,2};
                
            else
                
                tmpUnitRel.isiEnd(iTrial,1) = mean(tmpUnitRel.isiEnd(iTrial-5:iTrial-1));
                
            end
            tmpUnitRel.dir(iTrial,1) = locoTmpUnit{iTrial,7};
            
        end
        
        % set up psth parameters
        binTime = 10/1000; % ms
        binNum=floor(max(tmpUnitRel.isiEnd(:,1))/binTime);
        binEdges = linspace(-(tmpUnit{1,6}),max(tmpUnitRel.isiEnd),binNum);
        
        % assign bin number for all spikes for each trial
        for iTrial = 1:size(locoTmpUnit, 1)
            
            tmpUnitRel.trialBins{iTrial, 1} = histcounts(tmpUnitRel.spikes{iTrial, 1}, binEdges);
            cell2mat(tmpUnitRel.trialBins);
        end
        
        % untuned PSTH
        
        tmpUnitRel.trialBins = cell2mat(tmpUnitRel.trialBins);
        tmpUnitRel.trialBinsHz = tmpUnitRel.trialBins/binTime;
        tmpUnitRel.binMeans = mean(tmpUnitRel.trialBins, 1);
        tmpUnitRel.binStd = std(tmpUnitRel.trialBins);
        tmpUnitRel.binMeansHz = mean(tmpUnitRel.trialBinsHz, 1);
        tmpUnitRel.binStdHz = std(tmpUnitRel.trialBinsHz);
        tmpUnitRel.binSEMHz = tmpUnitRel.binStdHz./sqrt(sum(tmpUnitRel.trialBins));
        
        
        %plot it
        if isLoco == 0
            
            figure;
            hold on;
            plot(binEdges(2:end), tmpUnitRel.binMeansHz(1:end),'blue');
            patch([binEdges(2:end) fliplr(binEdges(2:end))], [(tmpUnitRel.binMeansHz - tmpUnitRel.binSEMHz) fliplr(tmpUnitRel.binMeansHz + tmpUnitRel.binSEMHz)], 'blue', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            tmpylim = ylim;
            patch([0 mean(tmpUnitRel.end) mean(tmpUnitRel.end) 0],  [-200 -200 200 200], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            xline(mean(tmpUnitRel.end), '--');
            xline(0, '--');
            ylim(tmpylim);
            xlim([-tmpUnit{1,6}, 1]); % un-hard code later
            title(num2str(allUnits{2, plotUnit}));
            
        else
            
            plot(binEdges(2:end), tmpUnitRel.binMeansHz(1:end),'red');
            patch([binEdges(2:end) fliplr(binEdges(2:end))], [(tmpUnitRel.binMeansHz - tmpUnitRel.binSEMHz) fliplr(tmpUnitRel.binMeansHz + tmpUnitRel.binSEMHz)], 'red', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            tmpylim = ylim;
            patch([0 mean(tmpUnitRel.end) mean(tmpUnitRel.end) 0],  [-200 -200 200 200], 'black', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
            xline(mean(tmpUnitRel.end), '--');
            xline(0, '--');
            ylim(tmpylim);
            xlim([-tmpUnit{1,6}, 1]); % un-hard code later
            title(num2str(allUnits{2, plotUnit}));
            
        end
        
    end
    
end

%% individual tuning curves

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
subNumber = 0;
%figure;
for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = allUnits{1,plotUnit};
    
    if sum(tmpUnit.spikeCount) > 300
    
           clearvars moveIndex statIndex tmpDir ;
           
        for currDir = 1 : size(plotDirs, 2)
            
            %find all the stim durs
            moveIndex = [];
            statIndex = [];
            tmpStimDurs = unique(tmpUnit.stimDur);
            
            %check for movement across all stim durs
            for currDur = 1 : size(tmpStimDurs, 2)
                moveIndexTmp = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*(1/tmpStimDurs(currDur)) > speedThresh;
                statIndexTmp = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*(1/tmpStimDurs(currDur)) < speedThresh;
                moveIndex = or(moveIndex, moveIndexTmp);
                statIndex = or(statIndex, statIndexTmp);
            end
            
            tmpDir(1, currDir) = mean(tmpUnit.spikeCount(moveIndex));
            tmpDir(2, currDir) = mean(tmpUnit.spikeCount(statIndex));
            tmpDir(3, currDir) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
            tmpDir(4, currDir) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));
            tmpDir(5, currDir) = mean(abs(tmpUnit.pos4(moveIndex) - tmpUnit.pos1(moveIndex)));
            tmpDir(6, currDir) = mean(abs(tmpUnit.pos4(statIndex) - tmpUnit.pos1(statIndex)));

        end
               
        isiFireMove = mean(tmpUnit.isiFire(moveIndex));
        isiFireStat = mean(tmpUnit.isiFire(statIndex));
        
        if isiFireMove > 5 && isiFireStat > 5
            
            figure;
            errorbar(plotDirs, tmpDir(1,:)*timeScale, tmpDir(3,:)*timeScale,'b');
            hold on;
            errorbar(plotDirs, tmpDir(2,:)*timeScale, tmpDir(4,:)*timeScale, 'r');
            yline(isiFireMove*5, ':b');
            yline(isiFireStat*5, ':r');
            title(['Unit ' num2str(tmpUnit.unitNum(1)) ', spike n = ' num2str(sum(tmpUnit.spikeCount)) ', trial n = ' num2str(size(tmpUnit, 1))]);
            xticks(0:60:360);
            xlabel('drift direction');
            ylabel('spike rate (Hz)');
            legend('moving', 'stationary');
            
        end
    
    end
    
end

legend('moving', 'stationary');
% sgtitle(['unit histograms for moving vs stationary trials where stationary is <' num2str(speedThresh) 'cm/s']);
%% overall avg firing rate changes (peak-aligned)
deviation = 0;
peakShift = 1;
clear tmpDir;
figure;

% sgtitle([num2str(allUnits{1,1}.stimDur(1)) 's presentation ' 'population activity averages from ' behavFiles(end-16:end-9) ', trial n = ' num2str(size(allUnits{1,1}, 1))]);

for alignType = 1 : 3
    
    isiFireMove = [];
    isiFireStat = [];
    
    for plotUnit = 1 : size(allUnits,2)
        
        tmpUnit = allUnits{1,plotUnit};
        
        if sum(tmpUnit.spikeCount) > 500
            
            for currDir = 1 : size(plotDirs, 2)
                
                moveIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale > speedThresh;
                statIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale < speedThresh;
                tmpMat(currDir, 1) = mean(tmpUnit.spikeCount(moveIndex));
                tmpMat(currDir, 2) = mean(tmpUnit.spikeCount(statIndex));
                tmpMat(currDir, 3) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
                tmpMat(currDir, 4) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));
            end
            
            % extract isi firing rate?
            isiMoveIndex = abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale > speedThresh;
            isiStatIndex = abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale < speedThresh;
            isiFireMove(end+1) = mean(tmpUnit.isiFire(isiMoveIndex));
            isiFireStat(end+1) = mean(tmpUnit.isiFire(isiStatIndex));
            
            switch alignType
                
                case 1
                    % locomoting peak-aligned
                    
                    [hzMax, maxIndex] = max(tmpMat(:,1));
                    tmpMatShift = circshift(tmpMat, (7 - maxIndex), 1);
                    tmpMatShift = tmpMatShift(:)';
                    tmpDir(plotUnit,:) = tmpMatShift;
                    subTitle = 'locomoting peak-aligned';
                    
                case 2
                    % stationary peak-aligned
                    [hzMax, maxIndex] = max(tmpMat(:,2));
                    tmpMatShift = circshift(tmpMat, (7 - maxIndex), 1);
                    tmpMatShift = tmpMatShift(:)';
                    tmpDir(plotUnit,:) = tmpMatShift;
                    subTitle = 'stationary peak-aligned';
                    
                case 3
                    % align to peaks separately for stationary and running
                    
                    % moving shift
                    tmpTmpMat1 = tmpMat(:,[1 3]);
                    [hzMax, maxMoveIndex] = max(tmpTmpMat1(:,1));
                    tmpTmpMat1Shift = circshift(tmpTmpMat1, (7 - maxMoveIndex), 1);
                    
                    % stat shift
                    
                    tmpTmpMat2 = tmpMat(:,[2 4]);
                    [hzMax, maxStatIndex] = max(tmpTmpMat2(:,1));
                    tmpTmpMat2Shift = circshift(tmpTmpMat2, (7 - maxStatIndex), 1);
                    
                    % stick that shit back together in the kludgiest way possible
                    tmpMatShift = zeros(12,4);
                    tmpMatShift(:,1) = tmpTmpMat1Shift(:,1);
                    tmpMatShift(:,2) = tmpTmpMat2Shift(:,1);
                    tmpMatShift(:,3) = tmpTmpMat1Shift(:,2);
                    tmpMatShift(:,4) = tmpTmpMat2Shift(:,2);
                    
                    tmpMatShift = tmpMatShift(:)';
                    if peakShift == false
                        
                        if abs(maxMoveIndex - maxStatIndex) <= 1
                            tmpDir(plotUnit,:) = tmpMatShift;
                        end
                        
                    else
                        tmpDir(plotUnit,:) = tmpMatShift;
                    end
                    subTitle = 'independently peak-aligned';
                    
            end
            
            if deviation == 1
                tmpDir(plotUnit, 1:12) = tmpDir(plotUnit, 1:12) - mean(tmpDir(plotUnit, 1:12));
                tmpDir(plotUnit, 13:24) = tmpDir(plotUnit, 13:24) - mean(tmpDir(plotUnit, 13:24));
            end
        else
            tmpDir(plotUnit, 1:48) = nan;
        end
        
    end
    
    subplot(1, 3, alignType);
    allAvg = mean(tmpDir(:,1:24), 1, 'omitnan');
    popSEMs(1:12) = sum((tmpDir(:,25:36).^2), 1, 'omitnan') ./ size(allSpeeds{1,1}, 2); %number of trials from the hist analysis
    popSEMs(13:24) = sum((tmpDir(:,37:48).^2), 1, 'omitnan') ./ size(allSpeeds{2,1}, 2);
    errorbar(allAvg(1,1:12)*timeScale, popSEMs(1,1:12)*timeScale, 'b');
    hold on;
    errorbar(allAvg(1,13:24)*timeScale, popSEMs(1,13:24)*timeScale, 'r');
    yline(mean(isiFireMove)*5, ':b');
    yline(mean(isiFireStat)*5, ':r');
    xticks(0:60:360);
    % xlabel('drift direction');
    if deviation == 1
        ylabel('difference from mean spike rate (Hz)');
    else
        ylabel('spike rate (Hz)');
    end
    legend('moving', 'stationary');
    title(subTitle);
    
    clear tmpDir
end


%% speed hists for moving and stationary trials

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
allSpeeds = {nan; nan};
subnumber = 1;
for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = allUnits{1,plotUnit};
    
    if sum(tmpUnit.spikeCount) > 500
    
        clearvars moveIndex statIndex tmpDir ;
        
        %index which trials were moving and which were stationary        
        moveIndex = zeros(size(tmpUnit, 1), 1);
        statIndex = zeros(size(tmpUnit, 1), 1);
        tmpStimDurs = unique(tmpUnit.stimDur);
        
        %check for movement across all stim durs
        for currDur = 1 : size(tmpStimDurs, 2)
            moveIndexTmp = tmpUnit.stimDur == tmpStimDurs(currDur) & abs(tmpUnit.pos4 - tmpUnit.pos1) * (1/tmpStimDurs(currDur)) > speedThresh;
            statIndexTmp = tmpUnit.stimDur == tmpStimDurs(currDur) & abs(tmpUnit.pos4 - tmpUnit.pos1) * (1/tmpStimDurs(currDur)) < speedThresh;
            moveIndex = or(moveIndex, moveIndexTmp);
            statIndex = or(statIndex, statIndexTmp);
        end        
        
        speedIndexMoveTmp = zeros(size(tmpUnit, 1), 1);
        speedIndexStatTmp = zeros(size(tmpUnit, 1), 1);

        % record speed of movement for all stim durs
        for currDur = 1 : size(tmpStimDurs, 2)
            speedIndexMoveTmp = moveIndex == 1 & tmpUnit.stimDur == tmpStimDurs(currDur);
            speedIndexStatTmp = statIndex == 1 & tmpUnit.stimDur == tmpStimDurs(currDur);
            allSpeeds{1,1} = [allSpeeds{1,1} abs(tmpUnit.pos4(speedIndexMoveTmp) - tmpUnit.pos1(speedIndexMoveTmp))'*(1/tmpStimDurs(currDur))];
            allSpeeds{2,1} = [allSpeeds{2,1} abs(tmpUnit.pos4(speedIndexStatTmp) - tmpUnit.pos1(speedIndexStatTmp))'*(1/tmpStimDurs(currDur))];
        end
%             
%         moveIndex = abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale > speedThresh;
%         statIndex = abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale < speedThresh;
%         allSpeeds{1,1} = [allSpeeds{1,1} abs(tmpUnit.pos4(moveIndex) - tmpUnit.pos1(moveIndex))'*timeScale];
%         allSpeeds{2,1} = [allSpeeds{2,1} abs(tmpUnit.pos4(statIndex) - tmpUnit.pos1(statIndex))'*timeScale];

    end
    
end

% norm hists
figure;
subplot(2,1,1);
histogram(allSpeeds{2,1}, 'FaceColor', 'r','Binwidth', 1, 'Normalization', 'cdf');
hold on;
histogram(allSpeeds{1,1}, 'FaceColor', 'b','BinWidth', 1, 'normalization', 'cdf');
legend(strcat('stationary, n =', num2str(size(allSpeeds{2,1}, 2))), strcat('moving, n =', num2str(size(allSpeeds{1,1}, 2))) );
xlabel('speed (cm/s)');
xlim([0 80]);
title('normalized hist of speeds from all trials');

% non-norm hists

subplot(2,1,2);
histogram(allSpeeds{2,1}, 'FaceColor', 'r','Binwidth', 1);
hold on;
histogram(allSpeeds{1,1}, 'FaceColor', 'b','BinWidth', 1);
legend(strcat('stationary, n =', num2str(size(allSpeeds{2,1}, 2))), strcat('moving, n =', num2str(size(allSpeeds{1,1}, 2))) );
xlabel('speed (cm/s)');
xlim([0 80]);
title('hist of speeds from all trials');

%% hist for trials-per-unit

for plotUnit = 1 : size(allUnits,2)
    
    unitTrials(plotUnit) = size(allUnits{1,plotUnit}, 1);
    
end

histogram(unitTrials);
title('trials per unit');
xlabel('trials');
ylabel('number of units');

%% hist for trials per unit locomoting and not

for plotUnit = 1 : size(allUnits,2)
    
    unitTrials(1,plotUnit) = sum(allUnits{1,plotUnit}.locomoting, 1);
    unitTrials(2,plotUnit) = size(allUnits{1,plotUnit}, 1) - unitTrials(1,plotUnit);
    
end
histogram(unitTrials(2,:), 'FaceColor', 'blue', 'BinWidth', 100);
hold on;
histogram(unitTrials(1,:), 'FaceColor', 'red', 'BinWidth', 100);
title('trials per unit');
xlabel('trials');
ylabel('number of units');
legend('stationary', 'moving');

%% hist for trials per condition by session

allDates = [];
totalTrials = [];

for plotUnit = 1 : size(allUnits,2)
    
    allDates = [allDates; unique(allUnits{1,plotUnit}.date)];
    
end

allDates = sort(unique(allDates));

for currDate = 1: size(allDates, 1)
    
    numMove = 0;
    numStat = 0;
    
    for plotUnit = 1 : size(allUnits,2)
        
        numMove = numMove + numel(find(allUnits{1,plotUnit}.date == allDates(currDate) & allUnits{1,plotUnit}.locomoting ==1));
        numStat = numStat + numel(find(allUnits{1,plotUnit}.date == allDates(currDate) & allUnits{1,plotUnit}.locomoting ==0));
        
    end
    
    totalTrials(1,currDate) = numMove;
    totalTrials(2,currDate) = numStat;
    
end
dateNums = 1:1:size(allDates, 1);
area(dateNums, totalTrials(2,:)', 'FaceColor', 'blue');
hold on;
area(dateNums, totalTrials(1,:)', 'FaceColor', 'red');
xlim([1 17]);
xticks(dateNums);
xticklabels(num2str(allDates));
xtickangle(90);
legend('stationary', 'moving');
title('trials per condition by date');
%% peak-aligned tuning curves

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
subNumber = 0;
%figure;
for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = allUnits{1,plotUnit};
    
    if sum(tmpUnit.spikeCount) > 500
    
           clearvars moveIndex statIndex tmpDir ;
           
        for currDir = 1 : size(plotDirs, 2)

            moveIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale > speedThresh;
            statIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale < speedThresh;
            tmpDir(1, currDir) = mean(tmpUnit.spikeCount(moveIndex));
            tmpDir(2, currDir) = mean(tmpUnit.spikeCount(statIndex));
            tmpDir(3, currDir) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
            tmpDir(4, currDir) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));

        end
        
        % find mean isi firing rates
        isiFireMove = mean(tmpUnit.isiFire(moveIndex));
        isiFireStat = mean(tmpUnit.isiFire(statIndex));
        isiFireMoveSEM = std(tmpUnit.isiFire(moveIndex)) / sqrt(sum(moveIndex));
        isiFireStatSEM = std(tmpUnit.isiFire(statIndex)) / sqrt(sum(statIndex));
            
        plotDirs = [30:30:360];
        [hzMax, maxIndex] = max(tmpDir(1,:));
        tmpDirShift = circshift(tmpDir, (7 - maxIndex), 2);
        tmpDirShift(:,13) = tmpDirShift(:,1);
        plotDirsShift = circshift(plotDirs, (7-maxIndex), 2);
        plotDirsShift(13) = plotDirsShift(1);

        figure;
        errorbar(tmpDirShift(1,:)*timeScale, tmpDirShift(3,:)*timeScale,'b');
        hold on;
        errorbar(tmpDirShift(2,:)*timeScale, tmpDirShift(4,:)*timeScale, 'r');
        yline(isiFireMove*5, ':b');
        yline(isiFireStat*5, ':r');
        title(['Unit ' num2str(tmpUnit.unitNum(1)) ', spike n = ' num2str(sum(tmpUnit.spikeCount)) ', trial n = ' num2str(size(tmpUnit, 1))]);
        xticks(0:60:360);
        xlabel('drift direction');
        ylabel('spike rate (Hz)'); 
        legend('moving', 'stationary');
        set(gca,'XTick',[])
    
    end
    
end


%% indepentenly-peak-aligned tuning curves

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
subNumber = 0;
%figure;
for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = allUnits{1,plotUnit};
    
    if sum(tmpUnit.spikeCount) > 500
    
           clearvars moveIndex statIndex tmpDir ;
           
        for currDir = 1 : size(plotDirs, 2)

            moveIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale > speedThresh;
            statIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1)*timeScale < speedThresh;
            tmpDir(1, currDir) = mean(tmpUnit.spikeCount(moveIndex));
            tmpDir(2, currDir) = mean(tmpUnit.spikeCount(statIndex));
            tmpDir(3, currDir) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
            tmpDir(4, currDir) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));

        end
        
        % find mean isi firing rates
        isiFireMove = mean(tmpUnit.isiFire(moveIndex));
        isiFireStat = mean(tmpUnit.isiFire(statIndex));
        isiFireMoveSEM = std(tmpUnit.isiFire(moveIndex)) / sqrt(sum(moveIndex));
        isiFireStatSEM = std(tmpUnit.isiFire(statIndex)) / sqrt(sum(statIndex));
            
        % moving shift
        tmpTmpDir1 = tmpDir([1 3],:);
        [hzMax, maxMoveIndex] = max(tmpTmpDir1(1,:));
        tmpTmpDir1Shift = circshift(tmpTmpDir1, (7 - maxMoveIndex), 2);
        
        % stat shift
        
        tmpTmpDir2 = tmpDir([2 4],:);
        [hzMax, maxStatIndex] = max(tmpTmpDir2(1,:));
        tmpTmpDir2Shift = circshift(tmpTmpDir2, (7 - maxStatIndex), 2);
        
        % stick that shit back together in the kludgiest way possible
        tmpMatShift = zeros(4,12);
        tmpMatShift(1,:) = tmpTmpDir1Shift(1,:);
        tmpMatShift(2,:) = tmpTmpDir2Shift(1,:);
        tmpMatShift(3,:) = tmpTmpDir1Shift(2,:);
        tmpMatShift(4,:) = tmpTmpDir2Shift(2,:);
        tmpDirShift = tmpMatShift;

        % plot only if both peaks are within one direction increment
        
        if abs(maxMoveIndex - maxStatIndex) <= 1
            
            figure;
            errorbar(tmpDirShift(1,:)*timeScale, tmpDirShift(3,:)*timeScale,'b');
            hold on;
            errorbar(tmpDirShift(2,:)*timeScale, tmpDirShift(4,:)*timeScale, 'r');
            yline(isiFireMove*5, ':b');
            yline(isiFireStat*5, ':r');
            title(['Unit ' num2str(tmpUnit.unitNum(1)) ', spike n = ' num2str(sum(tmpUnit.spikeCount)) ', trial n = ' num2str(size(tmpUnit, 1))]);
            xticks(0:60:360);
            xlabel('drift direction');
            ylabel('spike rate (Hz)');
            legend('moving', 'stationary');
            set(gca,'XTick',[])
            
        end
        
    end
    
end

%% deprecated

% %% setup data files
% 
% dataDate = '20210204';
% 
% coreDir = '/media/jack/DATA/gruData/';
% 
% % find and load behav file
% 
% behavDir = strcat([coreDir dataDate '/Behavior/']);
% cd(behavDir);
% behavName = dir;
% behavFiles = strcat([behavDir behavName(3).name]);
% 
% % convert and load event file 
% 
% loadDir = strcat([coreDir dataDate '/Events']);
% outDir = strcat([coreDir dataDate '/Events/Converted']);
% isConverted = dir(outDir);
% if size(isConverted, 1) < 3
%     oeSaveEvents(loadDir, 'experiment1.kwe', dataDate , outDir, 0)
% end
% ephysEventsFiles = strcat([coreDir dataDate '/Events/Converted/events_' dataDate '.mat']);
% 
% 
% % load ephys file
% 
% ephysFiles = strcat([coreDir dataDate '/Spikes/sortedSpikes/merged/gru_All_cat.mat']);
% 
% % define output dir
% 
% saveDir = strcat([coreDir dataDate '/Analysis']);
% 
% PDS=load(behavFiles, '-mat');
%    [EP2PTBfit, E2PTB,PTB2E]=ephys.synchronizeEphysClock(PDS, ephysEventsFiles);
%    
% screen_latency=PDS.baseParams.display.ifi;
% PDS = correctForScreenLatency(PDS, screen_latency);
%    
%    %load in ephys times
% 
% spikeTimes = load(ephysFiles);
% 
% % analysis variables
% 
% v1Latency = .025; % 25ms seems like a reasonable value based on Albrecht
% grateEndOffset = 0; % add a fixed duration to the end of the spike count window
% 
% %% count spikes for each grating presentation
% 
% % grab only units from the deired day
% tmpDate = strcat([dataDate(1:4) '-' dataDate(5:6) '-' dataDate(7:8)]);
% dateIndex = find(contains(string(spikeTimes.z.RecId), tmpDate));
% ourUnits = spikeTimes.z.Units{1, dateIndex};
% 
% %grab the duration of the 
%     
% % pre-populate table with headers
% 
% columnNames = {'unitNum', 'trial', 'dir', 'spikeCount', 'pos1', 'pos2', 'pos3', 'pos4', 'stimDur'};
% varTypes = {'double'};
% vartypes = repelem(varTypes, 9);
% 
% % % % sortedUnit = table('Size', [0, numel(columnNames)], 'VariableTypes', vartypes, 'VariableNames', columnNames);
% 
% % step into a unit
% 
% for currUnit = 1:size(ourUnits, 1)
%     
%     %make table for unit
%     
%     sortedUnit = table('Size', [0, numel(columnNames)], 'VariableTypes', vartypes, 'VariableNames', columnNames);
%     
%     %convert to PTB time for current unit
%     
%     PTBspikeTime = E2PTB(spikeTimes.z.Times{1,dateIndex}{ourUnits(currUnit)});
%     
%     % step into a trial
%     
%     for currTrial = 1:size(PDS.data, 2)
%                  
%         % pull trial start time
%         
%         %start for pre-referenced time
%         trialStart = PDS.data{1,currTrial}.trstart + PDS.data{1,currTrial}.pmBase.statesStartTime(3) + v1Latency;
%         
% %         % if you fucked up and left framelock on
% %         trialStart = PDS.data{1,currTrial}.pmBase.statesStartTime(3) + pvcLag;
%         
% % % % %         % find out how many grates were presented DO THIS LATER
% % % %         
% % % % %         % create index array of every grate (should un-hard code this later)
% % % % %         
% % % % %         grateIndex = fieldnames(PDS.data{1, currTrial});
% % % % %         grateIndex = grateIndex(9:38);
%         
%         % find the location of all the structs containing the grate
%         % parameters and pre-emptively pull a cell of all params
%         grateParamLocs = find(contains(fieldnames(PDS.baseParams), 'grate'));
%         paramCell = struct2cell(PDS.baseParams);
%         
%         % pull data from one grate at a time
%         
%         for currGrate = 1:size(PDS.data{1,currTrial}.pmBase.condsShown, 2)
%             
%             % populate unit number
%             tmpTable(1,1) = {ourUnits(currUnit)};
%             % populate trial number
%             tmpTable(1,2) = {currTrial};
%             % populate grating dir
%             tmpTable(1,3) = {PDS.data{1,currTrial}.pmBase.condsShown(currGrate)*30};
%             % populate spike count
%             
%             % find time of beginning and end of presentation
%             % add presentation start offset
%             grateStart = trialStart + paramCell{grateParamLocs(currGrate)}.modOnDur(1);
%             grateEnd = trialStart + paramCell{grateParamLocs(currGrate)}.modOnDur(2) + grateEndOffset;
%             
%             % count number of spikes between start and end
%             tmpTable(1,4) = {numel(find(PTBspikeTime >= grateStart & PTBspikeTime <= grateEnd))};
%             
%             % check speed at 4 points during trial
%             sampleTimes = linspace(grateStart, grateEnd, 4);
%             for i = 1 : size(sampleTimes, 2)
%                 [minValue, closestIndex] = min(abs(sampleTimes(i) - PDS.data{1,currTrial}.timing.flipTimes(1,:)));
%                 tmpTable(1, 4 + i) = {PDS.data{1,currTrial}.locationSpace(2,closestIndex)};
%             end
%             
%             % record stim duration
%             
%             tmpTable{1, 9} = grateEnd - grateStart;
%             
%             % read it out into a bigger table
%             
%             sortedUnit = [sortedUnit; tmpTable];
%             
%         end
%         
%     end
% 
%     allUnits{currUnit} = sortedUnit;
%     
% end
% 
% %% save out all unit data
% latNum = num2str(v1Latency);
% saveName = ['allUnits_' behavFiles(end-20:end-4) '_' latNum(end-1:end)];
% % recordings.(saveName) = allUnits;
% cd(saveDir);
% save(saveName, 'allUnits');
% 
% 
% 
% 
% %% if applicable merge data from multiple experiment files on the same day
% 
% tmpCell = struct2cell(recordings);
% tmpCell2(1,:) = tmpCell{1,:};
% tmpCell2(2,:) = tmpCell{2,:};
% lastTrial = tmpCell{1,1}{1,1}.trial(end);
% 
% for i = 1 : size(tmpCell2, 2)
%     tmpCell2{2,i}.trial = tmpCell2{2,i}.trial + lastTrial;
% end
% for i = 1 : size(tmpCell2, 2)
%     allUnits{1,i} = [tmpCell2{1,i}; tmpCell2{2,i}];
% end
