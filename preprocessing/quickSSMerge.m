%% set paths, import data, select animal

addFreeViewingPaths('jacklaptop') % switch to your user
addpath Analysis/HukLabTreadmill/

% session list generation

sesslist = io.dataFactoryTreadmill();

% select animal

animal = 'brie'; %'brie'

if strcmp(animal,'gru') == 1
    
    sessStart = 12;
    sessEnd = 24;
    
elseif strcmp(animal,'brie') == 1
    
    sessStart = 27;
    sessEnd = size(sesslist, 2);
    
else
    
    stop
    
end

A.frBaseR = [];
A.frBaseS = [];
A.frStimR = [];
A.frStimS = [];
A.NC = [];

for sessionId = sessStart:sessEnd
    
    % get data into the format we want it
    Exp = io.dataFactoryTreadmill(sessionId);
    Exp.spikeTimes = Exp.osp.st;
    Exp.spikeIds = Exp.osp.clu;
    
    % convert to D struct format
    D = io.get_drifting_grating_output(Exp);
    
    % run simple analysis
    
    thresh = 3;
    nboot = 100;
    
    unitList = unique(D.spikeIds);
    NC = numel(unitList);
    
    corrRho = zeros(NC,1);
    corrPval = zeros(NC,1);
    
    frBaseR = zeros(NC,3);
    frBaseS = zeros(NC,3);
    
    frStimR = zeros(NC,3);
    frStimS = zeros(NC,3);
    
    for cc = 1:NC
        unitId = unitList(cc);
        [stimDir, robs, runSpd, opts] = bin_ssunit(D, unitId, 'win', [-.2 .2]);
        
        goodIx = getStableRange(sum(robs,2), 'plot', false);
        
        stimDir = stimDir(goodIx);
        robs = robs(goodIx,:);
        runSpd = runSpd(goodIx,:);
        
        iix = opts.lags < 0;
        frbase = sum(robs(:,iix),2) / (max(opts.lags(iix)) - min(opts.lags(iix)));
        
        spd = mean(runSpd,2);
        
        [corrRho(cc), corrPval(cc)] = corr(spd, frbase, 'type', 'Spearman');
        
        runTrials = find(spd > thresh);
        statTrials = find(abs(spd) < 1);
        mixTrials = [runTrials; statTrials];
        
        nrun = numel(runTrials);
        nstat = numel(statTrials);
        
        n = min(nrun, nstat);
        
        frBaseR(cc,:) = prctile(mean(frbase(runTrials(randi(nrun, [n nboot])))), [2.5 50 97.5]);
        frBaseS(cc,:) = prctile(mean(frbase(statTrials(randi(nstat, [n nboot])))), [2.5 50 97.5]);
        
        iix = opts.lags > 0.04 & opts.lags < opts.lags(end)-.15;
        frstim = sum(robs(:,iix),2) / (max(opts.lags(iix)) - min(opts.lags(iix)));
        
        frStimR(cc,:) = prctile(mean(frstim(runTrials(randi(nrun, [n nboot])))), [2.5 50 97.5]);
        frStimS(cc,:) = prctile(mean(frstim(statTrials(randi(nstat, [n nboot])))), [2.5 50 97.5]);
        
        A.frBaseR = [A.frBaseR;frBaseR];
        A.frBaseS = [A.frBaseS;frBaseS];
        A.frStimR = [A.frStimR;frStimR];
        A.frStimS = [A.frStimS;frStimS];
        A.NC = [A.NC;NC];
        
    end
    
end

%% do the combined plot

frBaseR = A.frBaseR;
frBaseS = A.frBaseS;
frStimR = A.frStimR;
frStimS = A.frStimS;
NC = A.NC;
nboot = 100;

incBaseIx = find(frBaseR(:,2) > frBaseS(:,3));
decBaseIx = find(frBaseR(:,2) < frBaseS(:,1));

incStimIx = find(frStimR(:,2) > frStimS(:,3));
decStimIx = find(frStimR(:,2) < frStimS(:,1));

figure(1); clf
set(gcf, 'Color', 'w')
ms = 4;
cmap = lines;
subplot(1,2,1)
plot(frBaseS(:,[2 2])', frBaseR(:,[1 3])', 'Color', .5*[1 1 1]); hold on
plot(frBaseS(:,[1 3])', frBaseR(:,[2 2])', 'Color', .5*[1 1 1])
plot(frBaseS(:,2), frBaseR(:,2), 'o', 'Color', cmap(1,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(1,:))
plot(frBaseS(incBaseIx,2), frBaseR(incBaseIx,2), 'o', 'Color', cmap(2,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(2,:))
plot(frBaseS(decBaseIx,2), frBaseR(decBaseIx,2), 'o', 'Color', cmap(3,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(3,:))

xlabel('Stationary')
ylabel('Running')
title('Baseline Firing Rate')

set(gca, 'Xscale', 'log', 'Yscale', 'log')
plot(xlim, xlim, 'k')

subplot(1,2,2)
plot(frStimS(:,[2 2])', frStimR(:,[1 3])', 'Color', .5*[1 1 1]); hold on
plot(frStimS(:,[1 3])', frStimR(:,[2 2])', 'Color', .5*[1 1 1])
plot(frStimS(:,2), frStimR(:,2), 'o', 'Color', cmap(1,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(1,:))
plot(frStimS(incStimIx,2), frStimR(incStimIx,2), 'o', 'Color', cmap(2,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(2,:))
plot(frStimS(decStimIx,2), frStimR(decStimIx,2), 'o', 'Color', cmap(3,:), 'MarkerSize', ms, 'MarkerFaceColor', cmap(3,:))

xlabel('Stationary Firing Rate')
ylabel('Running Firing Rate')
title('Stim-driven firing rate')

set(gca, 'Xscale', 'log', 'Yscale', 'log')
plot(xlim, xlim, 'k')

nIncBase = numel(incBaseIx);
nDecBase = numel(decBaseIx);

nIncStim = numel(incStimIx);
nDecStim = numel(decStimIx);

modUnits = unique([incBaseIx; decBaseIx; incStimIx; decStimIx]);
nModUnits = numel(modUnits);

fprintf('%d/%d (%02.2f%%) increased baseline firing rate\n', nIncBase, NC, 100*nIncBase/NC)
fprintf('%d/%d (%02.2f%%) decreased baseline firing rate\n', nDecBase, NC, 100*nDecBase/NC)

fprintf('%d/%d (%02.2f%%) increased stim firing rate\n', nIncStim, NC, 100*nIncStim/NC)
fprintf('%d/%d (%02.2f%%) decreased stim firing rate\n', nDecStim, NC, 100*nDecStim/NC)

fprintf('%d/%d (%02.2f%%) total modulated units\n', nModUnits, NC, 100*nModUnits/NC)

[pvalStim, ~, sStim] = signrank(frStimS(:,2), frStimR(:,2));
[pvalBase, ~, sBase] = signrank(frBaseS(:,2), frBaseR(:,2));

fprintf('Wilcoxon signed rank test:\n')
fprintf('Baseline rates: p = %02.10f\n', pvalBase)
fprintf('Stim-driven rates: p = %02.10f\n', pvalStim)

good = ~(frBaseR(:,2)==0 | frBaseS(:,2)==0);

m = geomean(frBaseR(good,2)./frBaseS(good,2));
ci = bootci(nboot, @geomean, frBaseR(good,2)./frBaseS(good,2));

fprintf("geometric mean baseline firing rate ratio (Running:Stationary) is %02.3f [%02.3f, %02.3f] (n=%d)\n", m, ci(1), ci(2), sum(good)) 

m = geomean(frStimR(:,2)./frStimS(:,2));
ci = bootci(nboot, @geomean, frStimR(:,2)./frStimS(:,2));

fprintf("geometric mean stim-driven firing rate ratio (Running:Stationary) is %02.3f [%02.3f, %02.3f] (n=%d)\n", m, ci(1), ci(2), NC)