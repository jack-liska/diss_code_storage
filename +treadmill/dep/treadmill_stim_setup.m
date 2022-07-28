function p=treadmill_stim_setup(p)
% setup file for training fixation and saccades (overlap, memory, visual)
% example:
% load settingsStruct  % if you want to load specfic settings
% p=pldaps(@sacTrainingSetup,'subj', settingsStruct); % settingsStruct optional
% p.run

%IMPORTANT: if you close out of PLDAPS session and then reload that same
%object things might get wonky, as in not calculated right, in the number
%of correct trials

% Add Paths (make sure this is right on a per rig basis)


% if(p.trial.inputType == 2)
%     KbStrokeWait;
%     
%     KbQueueCreate(p.trial.inputDev);
%     KbQueueStart(p.trial.inputDev);
% end

% Trial function


% Default trial parameters (stimulus stuff etc.)

p.defaultParameters.stimulus.states.SCENE = [];
p.defaultParameters.pldaps.trialFunction='treadmill.treadmill_stim';

% trial length (s) (defaults)
p.trial.pldaps.maxTrialLength = 30;
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength*60;%% not disploaying at frate currently. Hard codep.trial.display.frate;

p.defaultParameters.pldaps.finish = 5;%number of total trials to make????


for(i = 1:p.defaultParameters.pldaps.finish)
    
    p.conditions{i}.soa = 0;
    p.conditions{i}.targLoc = [0 0];
end




%% Initializes all interated trial states 
p = defaultTrialVariables(p); % this is called from the 'huklabBasics' folder, make sure it's in your path
p.trial.mouse.cursorX = NaN; % want to put these in defaultTrialVariables
p.trial.mouse.cursorY = NaN;
p.trial.pldaps.goodtrial = NaN; % needed preallocate some fields
p.trial.pldaps.breakfix = NaN;
 
% initialization to make things easier in analysis
p.trial.stimulus.timeTargEntered = NaN;

%-------------------------------------------------------------------------%
% Reward
p.trial.behavior.reward.amount = .06; %ml default
p.trial.behavior.reward.jitter = 0.2; %randomly jitters reward after correct trial

%p.trial.behavior.reward.amount = .05; %ml = stretch Alvin out...

%-------------------------------------------------------------------------%
% Fixation
p.trial.stimulus.fixationXY   = [0 0]; % degrees (not sure if this is actually converted to pix in memSac, so check this if you change the location)
p.trial.stimulus.fixVisSize = [.5 .5];% in degrees - trying to scale it for different viewing distance - CG 

% fp timing
p.trial.stimulus.jitter.preTrial     = [.5 1]; % (iti) randomly jittered for each trial
p.trial.stimulus.fixWait      = 15; % amount of time to wait for the monkey to start fixation before breaking the trial       
p.trial.stimulus.fpDuration = 1; % (s) fp duration 

% fp contrast (%), p.trial.display.clut.fixation = [rgba]
p.trial.stimulus.fpContrast = 100; % in percent

%-------------------------------------------------------------------------%
% Windows
p.trial.stimulus.fpWin 			= [5 5]; % x,y radius of ellipse (if circle, should be the same), should be like 2 deg. diameter [1 1] or slightly bigger
p.trial.stimulus.winScaleVisual = .2; % scale targwin with eccentricity (no vis-guided yet)
p.trial.stimulus.winScaleMemory = .3; % currently scaling is conducted differently with mouseAsTarg than randomTarg
p.trial.stimulus.winScale = p.trial.stimulus.winScaleMemory; % This is usually set in the trial function 



%-------------------------------------------------------------------------%
% Misc. Initialization/Drawing/stimulus - Probably don't need some of this
p.trial.pldaps.draw.frameDropPlot.use = 0;
% p.trial.stimulus.showTarg = 0;

%-------------------------------------------------------------------------%
% TRAINING MODES
p.trial.trainingMode.flag = 'sac'; % 'fix','map','sac','mgs' % can build a GUI for this...
% initialize everything off (these are just flags) - DO NOT MESS WITH THEM HERE - just the trainingMode.flag above
p.trial.trainingMode.fixationTraining = false;
p.trial.trainingMode.mappingWithScenes = false;
p.trial.trainingMode.saccadeTraining = false;
p.trial.trainingMode.mgs = false; % not implemented yet, still use memSac

%-------------------------------------------------------------------------%
% Targets
p.trial.stimulus.mouseAsTargPerTrial = 0; %manual placement of target with mouse


% Target Contrast (%)
%p.trial.display.clut.red = [rgba] % **** Doesn't work right now because you can't
%change the alpha value with datapixx for some reason, wtf
p.trial.stimulus.targContrast = 100;
p.trial.display.clut.fp = 1*[1 1 1];% [p.trial.display.clut.red; p.trial.stimulus.targContrast/100]; % used for fp

% Target Flash 
p.trial.stimulus.targFlashOn = 1;
p.trial.stimulus.targFlashDur = inf; % 200ms
p.trial.stimulus.targdotWpostFlash = p.trial.stimulus.targdotW; % pix - size of targ after flash, 1 for training, 8 for normal vis0guided saccades
p.trial.stimulus.postFlashTraining = 0; % if you want to shrink targ after flash for training purposes, basically a visually guided saccade

% Timing
p.trial.stimulus.targWait = 100; %(playing with this for training) grace time to saccade from fp to target location
p.trial.stimulus.targHold = .3; % .3 (.2 for alvin training) - this is the amount of time the monkey must hold after saccade to where the target was

p.trial.stimulus.targOntime = NaN; % calculated in the trial based on fpOff (taking into account when fixation is acquired) and the desired asynchrony with the FP
p.trial.stimulus.targDuration = inf; % (s)
p.trial.stimulus.frameTargOn = [nan nan];
p.trial.stimulus.timeTargetOn = [nan nan];

% Overlap (negative) or Gap (positive)
% p.trial.stimulus.targFpAsynchony = 0; % offset between fpOff and targOn (negative means targOn before fpOff and vice versa, zero means they are equal)

% Targets Location
p.trial.stimulus.targ1XYdeg = [10 5]; % deg [10 0]  % keep an eye on jittering the sign flip of 'y' below
p.trial.stimulus.targ2XYdeg = [-10 -5]; % deg [-10 0]

p.trial.stimulus.targXYdeg = [15 15];% Visual Angle 
p.trial.stimulus.rfMode = 0; % if you want to use the mouse to place the target in the rf and have it alternate between there and 180deg
p.trial.stimulus.jitter.rfModeJitter = 0; % binary rf mode jitter on or off (not implented yet, but normal jitter should work wtf)

% Target size
p.trial.stimulus.targdotW = 20; %pix 8 = standard, 2 = training
p.trial.stimulus.targVisSize = [1 1];

% Spatial Jitter
p.trial.stimulus.jitter.jitterSpaceOn = 0;
p.trial.stimulus.jitter.targLoc = 1; % scalar, magnitude of spatial jitter
p.trial.stimulus.jitter.ySign = true; %boolean

% Temporal Jitter 
p.trial.stimulus.jitter.jitterTimeOn = 1; % CAREFUL if you try to change asynchrony later in the GUI and have this on
p.trial.stimulus.jitter.fpDuration = [.75 1]; %s [1 2]
p.trial.stimulus.jitter.asynchronyRange = [0 0];%s negative = overlap, positive =gap (when the target comes on relative to the fp going off)


%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
% Mapping RFs with natural scenes
% Params
p.trial.stimulus.sceneDuration = 200; % (s)
p.trial.stimulus.sceneProp = 100; % size of image in relation to the screen (in percent), 100 = scene is the full screen size
p.trial.stimulus.showScene = 0; % initialization (do not change)
p.trial.stimulus.showSceneWin = 0; % just for drawing for troubleshooting

% % Paths to images, randomize for this sesh, save info etc.  
% p.trial.stimulus.fileInfo.scenePath = '/Users/huklab/Documents/MATLAB/elh/Stimuli/lipreinst_stimuli/scenemodel/natural40/';
% p.trial.stimulus.fileInfo.sceneFormat = 'jpg';
% p.trial.stimulus.fileInfo.savePath = '/Users/huklab/Documents/MATLAB/elh/Stimuli/lipreinst_stimuli/sceneOrderData/';
% p.trial.stimulus.fileInfo.sceneImages = dir([p.trial.stimulus.fileInfo.scenePath '*.' p.trial.stimulus.fileInfo.sceneFormat]);
% sceneImages_mask = randperm(length(p.trial.stimulus.fileInfo.sceneImages));
% p.trial.stimulus.sceneNames = cell(length(sceneImages_mask),1);
% % 
% for i = 1:length(sceneImages_mask)
% p.trial.stimulus.sceneNames{i} = p.trial.stimulus.fileInfo.sceneImages(sceneImages_mask(i)).name;
% end
% % proliferate random blocks (no repeats within a block) to the max number of trials
% tempBlock = [];
% for i = 1:(length(p.conditions) / size(p.trial.stimulus.sceneNames,1))  
%     sceneBlock = datasample(p.trial.stimulus.sceneNames,size(p.trial.stimulus.sceneNames,1),1,'replace',false);
%     tempBlock = vertcat(tempBlock, sceneBlock);   
% end
% % put in conds (so we have this saved somewhere in case we want to look at which image was shown on particular trials
% for j = 1:length(p.conditions)
%     p.conditions{j}.sceneNames =  tempBlock{j};
% end

% TODO:also set up window the size of the ismage that the eyes must stay within

%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
% Colors
p.defaultParameters.display.humanCLUT(12,:)=[1 0 0];
p.defaultParameters.display.monkeyCLUT(12,:)=[0 1 0];

p.defaultParameters.display.humanCLUT(13,:)=[0 1 0];
p.defaultParameters.display.monkeyCLUT(13,:)=p.defaultParameters.display.bgColor;
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.hGreen=12*[1 1 1]';
else
    p.defaultParameters.display.clut.hGreen=p.defaultParameters.display.humanCLUT(12+1,:)';
end

p.defaultParameters.display.humanCLUT(14,:)=[1 0 0];
p.defaultParameters.display.monkeyCLUT(14,:)=p.defaultParameters.display.bgColor;
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.hRed=13*[1 1 1]';
else
    p.defaultParameters.display.clut.hRed=p.defaultParameters.display.humanCLUT(13+1,:)';
end

p.defaultParameters.display.humanCLUT(15,:)=[0 0 0];
p.defaultParameters.display.monkeyCLUT(15,:)=p.defaultParameters.display.bgColor;
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.hBlack=14*[1 1 1]';
else
    p.defaultParameters.display.clut.hBlack=p.defaultParameters.display.humanCLUT(14+1,:)';
end

p.defaultParameters.display.humanCLUT(16,:)=[1 0 0];
p.defaultParameters.display.monkeyCLUT(16,:)=[1 0 0];
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.bRed=15*[1 1 1]';
else
    p.defaultParameters.display.clut.bRed=p.defaultParameters.display.humanCLUT(15+1,:)';
end

p.defaultParameters.display.humanCLUT(17,:)=[0 1 0];
p.defaultParameters.display.monkeyCLUT(17,:)=[0 1 0];
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.bGreen=16*[1 1 1]';
else
    p.defaultParameters.display.clut.bGreen=p.defaultParameters.display.humanCLUT(16+1,:)';
end

p.defaultParameters.display.humanCLUT(18,:)=[1 1 1];
p.defaultParameters.display.monkeyCLUT(18,:)=[1 1 1];
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.bWhite=17*[1 1 1]';
else
    p.defaultParameters.display.clut.bWhite=p.defaultParameters.display.humanCLUT(17+1,:)';
end

p.defaultParameters.display.humanCLUT(19,:)=[0 0 0];
p.defaultParameters.display.monkeyCLUT(19,:)=[0 0 0];
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.bBlack=18*[1 1 1]';
else
    p.defaultParameters.display.clut.bBlack=p.defaultParameters.display.humanCLUT(18+1,:)';
end

p.defaultParameters.display.humanCLUT(20,:)=[0 0 1];
p.defaultParameters.display.monkeyCLUT(20,:)=[0 0 1];
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.bBlue=19*[1 1 1]';
else
    p.defaultParameters.display.clut.bBlue=p.defaultParameters.display.humanCLUT(19+1,:)';
end

p.defaultParameters.display.humanCLUT(21,:)=[0 0 1];
p.defaultParameters.display.monkeyCLUT(21,:)=p.defaultParameters.display.bgColor;
if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
    p.defaultParameters.display.clut.hBlue=20*[1 1 1]';
else
    p.defaultParameters.display.clut.hBlue=p.defaultParameters.display.humanCLUT(20+1,:)';
end


% % % % % Eric's color additions since there is no easy way to fuck with alpha
% % % value with datapixx here is my sort of workaround
% % %p.trial.display.clut.redA % is the variable to use in the trial function
% % 
% % % p.defaultParameters.display.humanCLUT(22,:)=[.8 .1 .1];
% % % p.defaultParameters.display.monkeyCLUT(22,:)=[.8 .1 .1]; 
% % 
% % p.defaultParameters.display.humanCLUT(22,:)=[.7 .15 .15];
% % p.defaultParameters.display.monkeyCLUT(22,:)=[.7 .15 .15]; 
% % 
% % if p.defaultParameters.datapixx.use && p.defaultParameters.display.useOverlay
% %     p.defaultParameters.display.clut.redA=21*[1 1 1]';
% % else
% %     p.defaultParameters.display.clut.redA=p.defaultParameters.display.humanCLUT(21+1,:)';
% % end
% % 
% % 

end % sacTrainingSetup

