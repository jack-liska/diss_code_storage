function [p] = tread_grate(subj, stimMode)

KbName('UnifyKeyNames');

if nargin<1 || isempty(subj)
    subj = "test"
end

if nargin<2 || isempty(stimMode)
    stimMode = 'grates';
end

pss.pldaps,modNames.currentStim = {stimMode};

pss.pldaps.pause.preExperiment = 0;

pss.newEraSyringePump.use = true;
pss.newEraSyringePump.refillVol = 30;
pss.behavior.reward.defaultAmount = 0.04;

%% Eyelink + tracking
pss.eyelink.use = false;

pss.eyelink.useAasEyepos = pss.eyelink.use;
% make .mouse param respect eyelink use state
pss.mouse.useAseyepos = ~pss.eyelink.useAsEyepos;
pss.pldaps.draw.eyepos.use = true;

%% Module Inventory
% -100: pldaps default trial function
%  1:   fixation
%  2:   base timing module
%  10:  grating drawing module

%% display settings
pss.display.viewdist = 60 % dome radius, fixed value
pss.display.ipd = 1.3 % human == 6.5;  macaque == 3.25; marmoset == 1.3;
pss.display.useOverlay = 1;

% pss.display.screenSize = [];
% pss.display.scrnNum = 0;

pss.display.stereomode = 4 %0==mono 2D; 3&4==freeFuse 3D; See Screen('OpenWindow?')

pss.display.useGL = 1;
pss.display.multisample = 2;

%% (-100) pldaps dedault trial function
sn = 'pdTrialFxn';
pss.(sn) = pldapsModule('modName', sn, 'name', 'pldapsDefaultTrial', 'order', -100);

%% (1) fixation Module
sn = 'fix';
pss.(sn).pldapsModule('modName', sn, 'name', 'modularDemo.pmFixDot', 'order', 1);

pss.(sn).use = false;
pss.(sn).on = true;
pss.(sn).mode = 2;   % eye position limit mode (0==pass/none, 1==square, 2==circle[euclidean]);  mode==2 strongly recommended;
pss.(sn).fixPos = [0 0];    % fixation xy in vis.deg, z in cm;    %NOTE: Recommended to leave z-position empty to ensure fixation is always rendered at current .display.viewdist
pss.(sn).fixLim = fixRadius*[1 1]; % fixation window limits (x,y)  % (visual degrees; if isscalar, y==x; if mode==2, radius limit; if mode==1, box half-width limit;)
pss.(sn).dotType = 5;      % 2 = classic PTB anti-aliased dot, 3:9 = geodesic sphere (Linux-only), 10:22 3D sphere (mercator; slow) (see help text from pmFixDot module for info on extended dotTypes available)

if pss.(sn).dotType <=2
    % pixels if classic PTB fixation dot
    pss.(sn).dotSz = 5; 
else
    % visual degrees of OpenGL dot
    pss.(sn).dotSz = 0.5; % vis. deg
end

% set this module as the active fixation module
% -- This is used to get/assign/update current .eyeX, .eyeY, .deltaXY positions
pss.pldaps.modNames.currentFix = {sn};

%% (2) base trial timing & behavioral control module
sn = 'pmBase';
pss.(sn) = pldapsModule('modName', sn, 'name', 'treadmill.pmBase', 'order', 2)

stimDur = 30;
pss.(sn).stateDur = [NaN, 0.24, stimeDur, NaN];

%% (10) drifting grating module fullGrates

switch stimMode
    case 'grates'
        
        sn = 'grates';
        
end

%% Create pldaps object for this experiment
p = pldaps(subj, pss);

%% Define parameters of condition matrix

% drift directions
dinc = 30; % direction increment
dirs = dinc:dinc:360; % motion directions
