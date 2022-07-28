function [p] = doTread_grate(subj, stimMode)
% force close serial ports. messy but it has to be done
delete(instrfind);

KbName('UnifyKeyNames');

if nargin<1 || isempty(subj)
    subj = "test";
end

if nargin<2 || isempty(stimMode)
    stimMode = 'grates';
end

pss.pldaps.modNames.currentStim = {stimMode};

pss.pldaps.pause.preExperiment = 0;
% enable propixx rear projection

pss.datapixx.enablePropixxRearProjection = true;

% syringe pump settings

pss.newEraSyringePump.use = true;
pss.newEraSyringePump.port = '/dev/ttyUSB0';
%pss.newEraSyringePump.refillVol = 30;
pss.newEraSyringePump.allowNewDiameter = true;
pss.newEraSyringePump.diameter = 30;
pss.behavior.reward.defaultAmount = 10;

% treadmill settings

pss.treadmill.use = true;
pss.treadmill.port = '/dev/ttyACM0';
pss.treadmill.circ = 94.25; % hand calculated circumference
pss.treadmill.scaleFactor = pss.treadmill.circ / 20000; %linear length in cm of one encoder tick (20000 ticks per prev)

% generic encoder settings

% pss.encoder.port = '/dev/ttyACM0';
% pss.encoder.circ = 94.25;
% pss.encoder.scaleFactor = pss.encoder.circ / 20000; % linear length in cm of one encoder tick (20000 ticks per prev)
% pss.encoder.frameInterval = 1;

%% testing framelock
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING
%  pss.pldaps.trialMasterFunction = 'runModularTrial_frameLock';
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING
% MAKE SURE DISABLED BEFORE RUNNING


%% Eyelink + tracking
pss.tracking.use = true;
pss.eyelink.use = true;

pss.eyelink.useAsEyepos = pss.eyelink.use;
% make .mouse param respect eyelink use state
pss.mouse.useAseyepos = ~pss.eyelink.useAsEyepos;
pss.pldaps.draw.eyepos.use = true;

%% Module Inventory
% -100: pldaps default trial function
%  1:   fixation
%  2:   base timing module
%  5:   treadmill module
%  6:   serial rotary encoder module
%  7:   treadmill reward module
%  10:  grating drawing module

%% display settings
pss.display.viewdist = 60; % dome radius, fixed value
pss.display.ipd = 1.3; % human == 6.5;  macaque == 3.25; marmoset == 1.3;
pss.display.useOverlay = 1;

% pss.display.screenSize = [];
 pss.display.scrnNum = 1;

pss.display.stereomode = 4; %0==mono 2D; 3&4==freeFuse 3D; See Screen('OpenWindow?')

pss.display.useGL = 1;
pss.display.multisample = 2;

%% (-100) pldaps default trial function
sn = 'pdTrialFxn';
pss.(sn) = pldapsModule('modName', sn, 'name', 'pldapsDefaultTrial', 'order', -100);

%% (1) fixation Module
sn = 'fix';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmFreeView', 'order', 1);

pss.(sn).use = false;

if pss.(sn).use == 1

    % set this module as the active fixation module
    % -- This is used to get/assign/update current .eyeX, .eyeY, .deltaXY positions
    pss.pldaps.modNames.currentFix = {sn};
else
    pss.(sn).on = false;
end

%% (2) base trial timing & behavioral control module
sn = 'pmBase';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmBase', 'order', 2);

expDur = 15;
stimDur = 40;
pss.(sn).stateDur = [NaN, 0.24, stimDur, NaN]; %tied to state numbers in pmBase (initParams near bottom)
pss.(sn).haveGenGrates = 0;

%% (5) treadmill module

sn = 'pmTread';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmTread', 'order', 5);

pss.(sn).use = true;
pss.(sn).rewardMode = 'dist'; % MODES dist = fixed reward per unit distance; time = scaled based on distance between time intervals
pss.(sn).rewardDist = pss.treadmill.circ * 2; % one reward instance per revolution

%% (6) serial rotary encoder module

sn = 'pmEncoder';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmEncoder', 'order', 6);

pss.(sn).use = false;
% generic encoder settings

pss.(sn).port = '/dev/ttyACM0';
pss.(sn).circ = 94.25;
pss.(sn).scaleFactor = pss.(sn).circ / 20000; % linear length in cm of one encoder tick (20000 ticks per prev)
pss.(sn).frameInterval = 1; % how many frames between calls to the encoder

%% (7) treadmill reward module

sn = 'pmTreadReward';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmTreadReward', 'order', 7);

pss.(sn).use = false;

% reward modes
% dist = give based on fixed distance
% rand = give randomly
% equi = read moving vs non-moving trials and randomly reward both equally
pss.(sn).rewardMode = 'dist';
pss.(sn).rewardDist = pss.treadmill.circ * 2; % dist only, one reward instance per 2 revolutions
%% (10) drifting grating module fullGrates

switch stimMode
    case 'grates'
        
        sn = 'grates';
        
        tmpModule = pldapsModule('modName', sn, 'name', 'treadmill.pmFullGrates', 'order', 10);
        
        tmpModule.use = true;
        tmpModule.on = false;
        
        % shared stimulus parameters
        tmpModule.contrast = 0.5;
        tmpModule.grateTf = 2; % drift speed (Hz)
        tmpModule.grateSf = 10; %grate size (px) 1cpd@60cm = 1cm = 20px
        tmpModule.phaseStep = tmpModule.grateTf/60*360; %frate 120
        %%%%%tmpModule.grateSf = 120 * rad2deg(sin(grateSf/2));
        
        %parameters updated by condMatrix before each trial
        tmpModule.dirs = 0;
        
        % stimulus onset timing + reps-per-trial
        
        % actual length of presentations
        repLength = 1.000; % seconds
        % number of presentations based on presentation length
        tmpModule.isi = 0.250;
        nCopies = stimDur/(repLength + tmpModule.isi);
        
        stimModuleDur = stimDur/nCopies;
        
        
    case 'gratesShort'
        
        sn = 'gratesShort';
        
        tmpModule = pldapsModule('modName', sn, 'name', 'treadmill.pmFullGrates', 'order', 10);
        
        tmpModule.use = true;
        tmpModule.on = false;
        
        % shared stimulus parameters
        tmpModule.contrast = 0.5;
        tmpModule.grateTf = 2; % drift speed (Hz)
        tmpModule.grateSf = 10; %grate size (px)
        tmpModule.phaseStep = tmpModule.grateTf/120*360; %frate 120
        %%%%%tmpModule.grateSf = 120 * rad2deg(sin(grateSf/2));
        
        %parameters updated by condMatrix before each trial
        tmpModule.dirs = 0;
        
        % stimulus onset timing + reps-per-trial
        
        % actual length of presentations
        repLength = 0.060; % seconds
        % number of presentations based on presentation length
        tmpModule.isi = 0.44;
        nCopies = stimDur/(repLength + tmpModule.isi);
        
        stimModuleDur = stimDur/nCopies;       
        
end

% report to command window
fprintLineBreak;
sr = 1000;
fprintf('\t~~~\tstimDur: %3.2fms,  isi: %3.2fms  ...x%d== %2.2fs total\n', (stimModuleDur-tmpModule.isi)*sr, tmpModule.isi*sr, nCopies, stimDur);
fprintLineBreak;

% --- MATRIX MODULE SETUP ---
% Create duplicate/indexed stim modules for each repetition w/in a trial
matrixModNames = {};
for i = 1:nCopies
    mN = sprintf('%s%0.2d', sn, i);
    pss.(mN) = tmpModule;
    pss.(mN).stateFunction.modName = mN;
    pss.(mN).stateFunction.matrixModule = true;
    % timing: each module [onset, offset] time in sec (relative to STIMULUS state start)
    basedur = (i-1)*stimModuleDur;
    pss.(mN).modOnDur = [0, stimModuleDur-tmpModule.isi] + basedur; % subtract isi from offset
    % module names [for local use]
    matrixModNames{i} = mN;
end

%% Create pldaps object for this experiment
p = pldaps(subj, pss);

%% Define parameters of condition matrix

% drift directions
dinc = 30; % direction increment
dirs = dinc:dinc:360; % motion directions

for i = 1:size(dirs, 2)
    c{i} = struct('dirs', dirs(i));
end

%% Generate condMatrix and add to pldaps

p.condMatrix.conditions = c;

p.condMatrix = condMatrix(p, 'randMode', 1 , 'nPasses', expDur * 10);

%% run exp

p.run;

end
