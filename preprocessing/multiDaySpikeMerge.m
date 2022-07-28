%% multi-day spike processing and merging code

%% assign core variables

coreDir = '/media/jack/DATA/gruData/'; % directory that all files are within
startDate = '20210420'; % first date to use, in this case the first 60ms date (01/26), first eye tracked + long date (4/20)
endDate = '20210426'; % final date to use, if any. otherwise takes all successive dates

if ~exist('endDate')
    endDate = '99999999';
end

% v1Latency = .025; % 25ms seems like a reasonable value based on Albrecht
% grateEndOffset = 0; % fixed duration added to the end of the spike count window
preStimWindow = 0.200; % time (in seconds) to add to beginning of trial presentation for spike assignment
allUnits = {};

%% do the processing and combine units

% find all the applicable dates

workingDir = struct2cell(dir(coreDir));
workingDir = workingDir(1,:);
workingDatesIndex = str2double(workingDir) >= str2double(startDate) & str2double(workingDir) <= str2double(endDate);
workingDates = workingDir(workingDatesIndex == 1);
recentDate = num2str(max(str2double(workingDates)));

% load most recent merged ephys file
        
ephysFiles = strcat([coreDir recentDate '/Spikes/sortedSpikes/merged/gru_All_cat.mat']);

%load in ephys times

spikeTimes = load(ephysFiles);

% loop through each date


for currDate = 1:size(workingDates, 2)
    
    tic
    
    %% set up directory stuff
    
    dataDate = workingDates{currDate};
    
    fprintf('Current day %d out of %d.\n', currDate, size(workingDates, 2));
    
    % find and load behav file
    
    behavDir = strcat([coreDir dataDate '/Behavior/']);
    cd(behavDir);
    behavName = dir;
    
    for currBehav = 3:size(behavName, 1)
        behavFiles = strcat([behavDir behavName(currBehav).name]);
        
        % convert and load event file
        
        loadDir = strcat([coreDir dataDate '/Events']);
        outDir = strcat([coreDir dataDate '/Events/Converted']);
        isConverted = dir(outDir);
        if size(isConverted, 1) < 3
            oeSaveEvents(loadDir, 'experiment1.kwe', dataDate , outDir, 0)
        end
        ephysEventsFiles = strcat([coreDir dataDate '/Events/Converted/events_' dataDate '.mat']);
        
        
% %         % load ephys file
% %         
% %         ephysFiles = strcat([coreDir dataDate '/Spikes/sortedSpikes/merged/gru_All_cat.mat']);
        
        % define output dir
        
        saveDir = strcat([coreDir dataDate '/Analysis']);
        
        PDS=load(behavFiles, '-mat');
        [EP2PTBfit, E2PTB,PTB2E]=ephys.synchronizeEphysClock(PDS, ephysEventsFiles);
        
        screen_latency=PDS.baseParams.display.ifi;
        PDS = correctForScreenLatency(PDS, screen_latency);
        
% %         %load in ephys times
% %         
% %         spikeTimes = load(ephysFiles);
        
        %% count spikes for each grating presentation
        
        % grab only units from the deired day
        tmpDate = strcat([dataDate(1:4) '-' dataDate(5:6) '-' dataDate(7:8)]);
        dateIndex = find(contains(string(spikeTimes.z.RecId), tmpDate));
        if numel(dateIndex) > 1
            dateIndex = dateIndex(1);
        end
        ourUnits = spikeTimes.z.Units{1, dateIndex};
        
        %grab the duration of the
        
        % pre-populate table with headers
        
        columnNames = {'unitNum', 'trial', 'dir', 'spikeCount', 'pos1', 'pos2', 'pos3', 'pos4', 'stimDur', 'date', 'isiFire', 'trueStimDur'};
        varTypes = {'double'};
        vartypes = repelem(varTypes, 12);        
        
        % step into a unit
        
        for currUnit = 1:size(ourUnits, 1)
            
            %make table for unit
            
            sortedUnit = table('Size', [0, numel(columnNames)], 'VariableTypes', vartypes, 'VariableNames', columnNames);
            
            unitSpikeTimes = [];
            
            %convert to PTB time for current unit
            
            PTBspikeTime = E2PTB(spikeTimes.z.Times{1,dateIndex}{ourUnits(currUnit)});
            
            % step into a trial
            
            for currTrial = 1:size(PDS.data, 2)
                
                % pull trial start time
                
                %start for pre-referenced time
                if ~isfield(PDS.data{1,currTrial}.pmBase, 'statesStartTime') || ~isfield(PDS.data{1,currTrial}.pmBase, 'statesStartTime')
                   
                    continue;
                    
                else
                    
%                 trialStart = PDS.data{1,currTrial}.trstart + PDS.data{1,currTrial}.pmBase.statesStartTime(3) + v1Latency;
                  trialStart = PDS.data{1,currTrial}.timing.flipTimes(1,PDS.data{1,currTrial}.pmBase.statesStartFrame(3));
                
                end
                %         % if you fucked up and left framelock on
                %         trialStart = PDS.data{1,currTrial}.pmBase.statesStartTime(3) + pvcLag;
                
                % % % %         % find out how many grates were presented DO THIS LATER
                % % %
                % % % %         % create index array of every grate (should un-hard code this later)
                % % % %
                % % % %         grateIndex = fieldnames(PDS.data{1, currTrial});
                % % % %         grateIndex = grateIndex(9:38);
                
                % find the location of all the structs containing the grate
                % parameters and pre-emptively pull a cell of all params
                grateParamLocs = find(contains(fieldnames(PDS.baseParams), 'grate'));
                paramCell = struct2cell(PDS.baseParams);
                
                % pull data from one grate at a time
                
                for currGrate = 1:size(PDS.data{1,currTrial}.pmBase.condsShown, 2)
                    
                    % populate unit number
                    tmpTable(1,1) = {ourUnits(currUnit)};
                    % populate trial number
                    tmpTable(1,2) = {currTrial};
                    % populate grating dir
                    tmpTable(1,3) = {PDS.data{1,currTrial}.pmBase.condsShown(currGrate)*30};
                    % populate spike count
                    
                    % find time of beginning and end of presentation
                    % add presentation start offset
                    grateStart = trialStart + paramCell{grateParamLocs(currGrate)}.modOnDur(1);
                    grateEnd = trialStart + paramCell{grateParamLocs(currGrate)}.modOnDur(2);
                    grateStartFrame = find(PDS.data{1,currTrial}.timing.flipTimes(1,:) > grateStart, 1, 'first');
                    grateEndFrame = find(PDS.data{1,currTrial}.timing.flipTimes(1,:) > grateEnd, 1, 'first');
                    grateStartTime = PDS.data{1,currTrial}.timing.flipTimes(1,grateStartFrame);
                    if grateEndFrame + 1 <= size(PDS.data{1,currTrial}.timing.flipTimes, 1)
                        grateEndTime = PDS.data{1,currTrial}.timing.flipTimes(1,grateEndFrame + 1);
                    else
                        grateEndTime = PDS.data{1,currTrial}.timing.flipTimes(1,grateEndFrame);
                    end
                    isiEndFrame = find(PDS.data{1,currTrial}.timing.flipTimes(1,:) > grateEnd + paramCell{grateParamLocs(currGrate)}.isi, 1, 'first');
                    isiEndTime = PDS.data{1,currTrial}.timing.flipTimes(1,isiEndFrame);
                    
                    % count number of spikes between start and end
                    tmpTable(1,4) = {numel(find(PTBspikeTime >= grateStartTime & PTBspikeTime <= grateEndTime))};
                    
                    % sample the isi for 200ms to get baseline firing rate
                    tmpTable(1,11) = {numel(find(PTBspikeTime >= grateEndTime + 0.140 & PTBspikeTime <= grateEndTime + 0.340))};
                    
                    % check speed at 4 points during trial
                    if isempty(grateStartTime) || isempty(grateEndTime)
                        continue
                        
                    else
                        
                    sampleTimes = linspace(grateStartTime, grateEndTime, 4);
                    
                    end
                    
                    % catch condition for files with the old locationSpace
                    % format
                    
                    if size(PDS.data{currTrial}.locationSpace, 1) == 1
                        PDS.data{currTrial}.locationSpace(2,:) = PDS.data{currTrial}.locationSpace(1,:);
                    end
                    
                    for i = 1 : size(sampleTimes, 2)
                        [minValue, closestIndex] = min(abs(sampleTimes(i) - PDS.data{1,currTrial}.timing.flipTimes(1,:)));
                        tmpTable(1, 4 + i) = {PDS.data{1,currTrial}.locationSpace(2,closestIndex)};
                    end
                    
                    % record stim duration & date
                    
                    tmpTable{1, 9} = grateEnd - grateStart;
                    tmpTable{1, 10} = str2double(dataDate);
                    tmpTable{1, 12} = grateEndTime - grateStartTime;
                    
                    % read it out into a bigger table
                    
                    sortedUnit = [sortedUnit; tmpTable];
                      
                    arentSpike = isempty(find(PTBspikeTime >= grateStartTime - preStimWindow & PTBspikeTime <= isiEndTime, 1));

                    if arentSpike == 1

                        grateSpikeTimes{1,1} = nan;
                        grateSpikeTimes{1,2} = grateStartTime;
                        grateSpikeTimes{1,3} = grateEndTime;
                        grateSpikeTimes{1,4} = isiEndTime;
                        grateSpikeTimes{1,5} = dataDate;

                    else

                        grateSpikeTimes{1,1} = PTBspikeTime(PTBspikeTime >= grateStartTime - preStimWindow & PTBspikeTime <= isiEndTime)';
                        grateSpikeTimes{1,2} = grateStartTime;
                        grateSpikeTimes{1,3} = grateEndTime;
                        grateSpikeTimes{1,4} = isiEndTime;
                        grateSpikeTimes{1,5} = dataDate;
                        grateSpikeTimes{1,6} = preStimWindow;
                        
                    end  
                    
                    unitSpikeTimes = [unitSpikeTimes; grateSpikeTimes];
                    
                end
                                                
            end
            
            % find out if we've already seen this unit and format accordingly
            
            if size(allUnits, 2) > 0 && sum(cell2mat(allUnits(2,:)) == sortedUnit.unitNum(1)) > 0
                
                cellIndex = find(cell2mat(allUnits(2,:)) == sortedUnit.unitNum(1));
                allUnits{1,cellIndex} = [allUnits{1,cellIndex};sortedUnit];
                allUnits{3,cellIndex} = [allUnits{3,cellIndex};unitSpikeTimes];
                
            else
                
                allUnits{1,end+1} = sortedUnit;
                allUnits{2,end} = sortedUnit.unitNum(1);
                allUnits{3,end} = unitSpikeTimes;
                
            end
            
        end
        
    end
    
    toc
    
end

preStim = num2str(preStimWindow);
saveName = ['allUnitsMerged_' date '_' preStim(end-1:end)];
% recordings.(saveName) = allUnits;
cd(coreDir);
save(saveName, 'allUnits');


