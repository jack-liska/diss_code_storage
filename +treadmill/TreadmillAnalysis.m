%Treadmill simple analysis

%%preanalysis

BehavFiles = 'C:\Users\Jack Liska\Documents\Data\Barry\20191204\Behav\Barry_20191204treadmill.treadmill_stim_setup_1329.PDS';

ephysEventsFiles = 'C:\Users\Jack Liska\Documents\Data\Barry\20191204\Ephys\events_2019-12-04_13-28-56.mat';

ephysfile = 'C:\Users\Jack Liska\Documents\Data\Barry\20191204\Ephys\barry_2019-12-04_13-28-56.mat';

PDS=load(BehavFiles, '-mat');
   [EP2PTBfit, E2PTB,PTB2E]=ephys.synchronizeEphysClock(PDS, ephysEventsFiles);
   
screen_latency=PDS.baseParams.display.ifi;
PDS = correctForScreenLatency(PDS, screen_latency);
   
   %load in ephys times

   spikeTimes = load(ephysfile);
   

spikeLocsUnits = {};
processed20191204 = {};

   
for someunits = 1:length(spikeTimes.m.Times)   
   
   if length(spikeTimes.m.Times{someunits}) > 2000
    
       PTBSpikeTimes = E2PTB(spikeTimes.m.Times{someunits});

        %assign spikes to their frames
        for i = 1:length(PDS.data)
            thisTrialsSpikes = [];
            for p = 1:length(PTBSpikeTimes)
                if PTBSpikeTimes(p,1) >= PDS.data{1,i}.timing.flipTimes(1,1) && PTBSpikeTimes(p,1) <= PDS.data{1,i}.timing.flipTimes(1,length(PDS.data{1,i}.timing.flipTimes))
                    thisTrialsSpikes= [thisTrialsSpikes ; PTBSpikeTimes(p,1)];
                end               
            end           
            trialSpikeCell{i} = thisTrialsSpikes;
        end
        trialLength=(cellfun(@(x) size(x,1), trialSpikeCell));
        trialSpikes = nan(max(trialLength),i);
        for q = 1:i
            trialSpikes(1:trialLength(q),q)=trialSpikeCell{q};
        end
        %subtract out the time of the first frame to get relative spike times
        
        clear PTBSpikeTimes;

        %assign hallway locations to spikes

        for q = 1:10
            for i = 1:length(PDS.data{1,q}.timing.flipTimes)
                for p = 1:length(trialSpikes(:,q))
                    if trialSpikes(p,q) >= PDS.data{1,q}.timing.flipTimes(1,i) && trialSpikes(p,q) <= PDS.data{1,q}.timing.flipTimes(1,i+1)
                        spikeLocs(p,q) = PDS.data{1,q}.treadmill.location(i);

                    end
                end
            end
            spikeLocs(spikeLocs(:,q)==0,q)=NaN;
        end
        spikeLocsUnits{1,end+1} = someunits;
        spikeLocsUnits{2,end} = spikeLocs;

        clear trialspikes;
        clear spikeLocs;

        %plot hists
   end
end
processed20191204{1} = {spikeLocsUnits};
%%
rawunithists = {};
for p = 1:length(processed20191204{1,1}{1,1})
        for i = 1:10
           x= histcounts(processed20191204{1,1}{1,1}{2,p}(:,i), 78);
           
           %plot(x,'LineWidth',2);
           
           X(i,:) = x;
           
        end
        rawunithists{1, end+1} = processed20191204{1,1}{1,1}(1,p);
        rawunithists{2, end} = X;
        clear X;


end
processed20191204{2} = {rawunithists};
%%
%         %%plot from rawunithists
figure
M = [];
hold on;
grid on;
for i=1:13 % length(processed20191204{1,1}{1,1})
    
    figure
    %hold on;
    %             errorbar(mean(processed20191204{1,1}{1,1}{2,i}),std(processed20191204{1,1}{1,1}{2,i}));
    plot(mean(processed20191204{1,2}{1,1}{2,i}));
    M2(i,:) = mean(processed20191204{1,2}{1,1}{2,i});
    %title(someunits);
    %plot(mean(M2));
end



hold off

figure, plot(mean(M,1));
% figure, plot(mean(M),'k','LineWidth',5)
%
%         clear PTBSpikeTimes;
%             %histogram(trialSpikesPlusLoc(:,2));
%%
processed20191204{1} = {rawunithists};
processed20191204{end+1} = {spikeLocsUnits};

%%
save('processed20191204.mat', 'processed20191204');






%%random spike generation
firsthalf = rand([20000,1])*(PDS.data{1,1}.timing.flipTimes(1,1122)-PDS.data{1,1}.timing.flipTimes(1,1))+PDS.data{1,1}.timing.flipTimes(1,1);
secondhalf = rand([40000,1])*(PDS.data{1,1}.timing.flipTimes(1,end)-PDS.data{1,1}.timing.flipTimes(1,1122))+PDS.data{1,1}.timing.flipTimes(1,1122);
fullfake = cat(1,firsthalf,secondhalf);

PTBSpikeTimes = fullfake;
clear trialSpikes;
trialSpikes = [];
for i = 1:length(PDS.data)
    q=1;
    for p = 1:length(PTBSpikeTimes)
        if PTBSpikeTimes(p,1) >= PDS.data{1,i}.timing.flipTimes(1,1) && PTBSpikeTimes(p,1) <= PDS.data{1,i}.timing.flipTimes(1,length(PDS.data{1,i}.timing.flipTimes))
            trialSpikes(q,i)= PTBSpikeTimes(p,1);
            q=q+1;
        end
    end
    trialSpikes(trialSpikes(:,i)==0,i)=NaN;
end
%subtract out the time of the first frame to get relative spike times

realtimetrialSpikes = trialSpikes - PTBSpikeTimes(1,1);

%assign hallway locations to spikes

for q = 1:10
    for i = 1:length(PDS.data{1,q}.timing.flipTimes)
        for p = 1:length(trialSpikes(:,q))
            if trialSpikes(p,q) >= PDS.data{1,q}.timing.flipTimes(1,i) && trialSpikes(p,q) <= PDS.data{1,q}.timing.flipTimes(1,i+1)
                spikeLocs(p,q) = PDS.data{1,q}.treadmill.location(i);
                
            end
        end
    end
    spikeLocs(spikeLocs(:,q)==0,q)=NaN;
end

for i = 1:10
   x= histcounts(spikeLocs, 15 );
   
   plot(x,'LineWidth',2);
   
   X(i,:) = x;
   
end
rawunithists{end+1} = X;
clear X;
% figure
% plot(mean(X));