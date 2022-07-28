%% treadmill tuning analysis

%% setup data files

behavFiles = '/media/jack/DATA/poster stuff 2021/Gru/20210107/Behavior/gru_20210108_1418.PDS';

ephysEventsFiles = '/media/jack/DATA/poster stuff 2021/Gru/20210107/Events/Converted/events_20210107.mat';

ephysFiles = '/media/jack/DATA/poster stuff 2021/Gru/20210107/Spikes/sortedSpikes/merged/gru_All_cat.mat';

saveDir = '/media/jack/DATA/poster stuff 2021/Gru/20210107/Analysis';

PDS=load(behavFiles, '-mat');
   [EP2PTBfit, E2PTB,PTB2E]=ephys.synchronizeEphysClock(PDS, ephysEventsFiles);
   
screen_latency=PDS.baseParams.display.ifi;
PDS = correctForScreenLatency(PDS, screen_latency);
   
   %load in ephys times

spikeTimes = load(ephysFiles);

%% analysis variables

pvcLag = .050; %50ms lag time to V1

%% count spikes for each grating presentation

% grab only units from the deired day

ourUnits = spikeTimes.z.Units{1, 3};

% pre-populate table with headers

columnNames = {'unitNum', 'trial', 'dir', 'spikeCount', 'pos1', 'pos2', 'pos3', 'pos4'};
varTypes = {'double'};
vartypes = repelem(varTypes, 8);

sortedUnit = table('Size', [0, numel(columnNames)], 'VariableTypes', vartypes, 'VariableNames', columnNames);

% step into a unit

for currUnit = 1:size(ourUnits, 1)
    
    %make table for unit
    
    sortedUnit = table('Size', [0, numel(columnNames)], 'VariableTypes', vartypes, 'VariableNames', columnNames);
    
    %convert to PTB time for current unit
    
    PTBspikeTime = E2PTB(spikeTimes.z.Times{1,3}{ourUnits(currUnit)});
    
    % step into a trial
    
    for currTrial = 1:size(PDS.data, 2)-1
        
        % pull trial start time
        
        trialStart = PDS.data{1,currTrial}.timing.datapixxTRIALSTART(1) + PDS.data{1,currTrial}.pmBase.statesStartTime(3) + pvcLag;
        
        
        % find out how many grates were presented DO THIS LATER
        
        % create index array of every grate (should un-hard code this later)
        
        grateIndex = fieldnames(PDS.data{1, currTrial});
        grateIndex = grateIndex(9:38);
        
        %pull data from one grate at a time
        
        for currGrate = 1:30
            
            % populate unit number
            tmpTable(1,1) = {ourUnits(currUnit)};
            % populate trial number
            tmpTable(1,2) = {currTrial};
            % populate grating dir
            tmpTable(1,3) = {PDS.data{1,currTrial}.(grateIndex{currGrate}).dirs};
            % populate spike count
            
            % find time of beginning of presentation
            % add presentation start offset
            grateStart = trialStart + (1.25 * (currGrate - 1));
            grateEnd = grateStart + 1;
            
            % count number of spikes between start and end
            tmpTable(1,4) = {numel(find(PTBspikeTime >= grateStart & PTBspikeTime <= grateEnd))};
            
            %check speed at 4 points during trial
            sampleTimes = linspace(grateStart, grateEnd, 4);
            for i = 1 : size(sampleTimes, 2)
                [minValue, closestIndex] = min(abs(sampleTimes(i) - PDS.data{1,currTrial}.timing.flipTimes(1,:)));
                tmpTable(1, 4 + i) = {PDS.data{1,currTrial}.locationSpace(closestIndex)};
            end
            
            sortedUnit = [sortedUnit; tmpTable];
            
        end
        
    end

    allUnits{currUnit} = sortedUnit;
    
end

%% save out all unit data
saveName = ['allUnits_' behavFiles(end-20:end-4)];
recordings.(saveName) = allUnits;
cd(saveDir);
save(saveName, 'recordings');


%% merge data from multiple experiment files on the same day

tmpCell = struct2cell(recordings);
tmpCell2(1,:) = tmpCell{1,:};
tmpCell2(2,:) = tmpCell{2,:};
lastTrial = tmpCell{1,1}{1,1}.trial(end);

for i = 1 : size(tmpCell2, 2)
    tmpCell2{2,i}.trial = tmpCell2{2,i}.trial + lastTrial;
end
for i = 1 : size(tmpCell2, 2)
    mergedUnits{1,i} = [tmpCell2{1,i}; tmpCell2{2,i}];
end
%% plot stuff


%% fixed params
plotDirs = [30:30:360];
speedThresh = 3; % cm/s (arbitrary)

%% individual tuning curves

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
subNumber = 0;
%figure;
for plotUnit = 1 : size(allUnits,2)
    
    tmpUnit = mergedUnits{plotUnit};
    
    if sum(tmpUnit.spikeCount) > 3000
    
           clearvars moveIndex statIndex tmpDir ;
           
        for currDir = 1 : size(plotDirs, 2)

            moveIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1) > speedThresh;
            statIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1) < speedThresh;
            tmpDir(1, currDir) = mean(tmpUnit.spikeCount(moveIndex));
            tmpDir(2, currDir) = mean(tmpUnit.spikeCount(statIndex));
            tmpDir(3, currDir) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
            tmpDir(4, currDir) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));
            tmpDir(5, currDir) = mean(abs(tmpUnit.pos4(moveIndex) - tmpUnit.pos1(moveIndex)));
            tmpDir(6, currDir) = mean(abs(tmpUnit.pos4(statIndex) - tmpUnit.pos1(statIndex)));

        end
        
%         subNumber = subNumber +1;
% 
%         subplot(4, 5, subNumber);

        figure;
        errorbar(plotDirs, tmpDir(1,:), tmpDir(3,:),'r');
        hold on;
        errorbar(plotDirs, tmpDir(2,:), tmpDir(4,:), 'b');
        title(['Unit ' num2str(tmpUnit.unitNum(1)) ' spikes n = ' num2str(sum(tmpUnit.spikeCount))]);
        xticks(0:60:360);
        xlabel('drift direction');
        ylabel('spike rate (Hz)'); 
        legend('moving', 'stationary');
    
    end
    
end

legend('moving', 'stationary');
% sgtitle(['unit histograms for moving vs stationary trials where stationary is <' num2str(speedThresh) 'cm/s']);
%% overall avg firing rate changes
deviation = 0;
clear tmpDir;
for plotUnit = 1 : size(mergedUnits,2)
    
    tmpUnit = mergedUnits{plotUnit};
    
    if sum(tmpUnit.spikeCount) > 1000
    
        for currDir = 1 : size(plotDirs, 2)

            moveIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1) > speedThresh;
            statIndex = tmpUnit.dir == plotDirs(currDir) & abs(tmpUnit.pos4 - tmpUnit.pos1) < speedThresh;
            tmpDir(plotUnit, currDir) = mean(tmpUnit.spikeCount(moveIndex));
            tmpDir(plotUnit, currDir+12) = mean(tmpUnit.spikeCount(statIndex));
            tmpDir(plotUnit, currDir+24) = std(tmpUnit.spikeCount(moveIndex)) / sqrt(sum(moveIndex));
            tmpDir(plotUnit, currDir+36) = std(tmpUnit.spikeCount(statIndex)) / sqrt(sum(statIndex));
        end
        
        if deviation == 1
            tmpDir(plotUnit, 1:12) = tmpDir(plotUnit, 1:12) - mean(tmpDir(plotUnit, 1:12));
            tmpDir(plotUnit, 13:24) = tmpDir(plotUnit, 13:24) - mean(tmpDir(plotUnit, 13:24));
        end
    else
        tmpDir(plotUnit, 1:48) = nan;
    end
    
end

figure;
allAvg = mean(tmpDir(:,1:24), 1, 'omitnan');
popSEMs(1:12) = sum((tmpDir(:,25:36).^2), 1, 'omitnan') ./ 1344; %number of trials from last analysis
popSEMs(13:24) = sum((tmpDir(:,37:48).^2), 1, 'omitnan') ./ 2228;
errorbar(plotDirs, allAvg(1,1:12), popSEMs(1,1:12), 'r');
hold on;
errorbar(plotDirs, allAvg(1,13:24), popSEMs(1,13:24), 'b');
xticks(0:60:360);
xlabel('drift direction');
if deviation == 1
    ylabel('difference from mean spike rate (Hz)');
else
    ylabel('spike rate (Hz)'); 
end
legend('moving', 'stationary');

%% speed hists for moving and stationary trials

clearvars tmpDir tmpUnit moveIndex statIndex subNumber;
allSpeeds = {nan; nan};
subnumber = 1;
for plotUnit = 1 : size(mergedUnits,2)
    
    tmpUnit = mergedUnits{plotUnit};
    
    if sum(tmpUnit.spikeCount) > 3000
    
        clearvars moveIndex statIndex tmpDir ;
        %index which trials were moving and which were stationary
        moveIndex = abs(tmpUnit.pos4 - tmpUnit.pos1) > speedThresh;
        statIndex = abs(tmpUnit.pos4 - tmpUnit.pos1) < speedThresh;
        allSpeeds{1,1} = [allSpeeds{1,1} abs(tmpUnit.pos4(moveIndex) - tmpUnit.pos1(moveIndex))'];
        allSpeeds{2,1} = [allSpeeds{2,1} abs(tmpUnit.pos4(statIndex) - tmpUnit.pos1(statIndex))'];

    end
    
end
figure;
histogram(allSpeeds{2,1}, 'FaceColor', 'b','Binwidth', 1, 'Normalization', 'cdf');
hold on;
histogram(allSpeeds{1,1}, 'FaceColor', 'r','BinWidth', 1, 'normalization', 'cdf');
legend('moving', 'stationary');
xlabel('speed (cm/s)');
xlim([0 80]);
