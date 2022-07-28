function treadmill_grate_noFix(subj,useWheel) 
% useWheel: 0 - intermittent reward; 1 - give reward based on wheel motion

% default setting for subj name, input type, viewdist, and grbl_command

tic

IOPort closeall

if nargin == 0 
    subj = 'test';
end

if nargin < 1
    useWheel = 0;
end

%% Creating the pldaps data struct 

load settingsStruct.mat;


p = pldaps(@treadmill.treadmill_stim_setup,subj,settingsStruct);

p = pdsDefaultTrialStructure(p); 

p.trial.display.scrnNum = 1;
%p.trial.display.screenSize = [];
p.trial.display.frate = 120;
%p.trial.pldaps.maxTrialLength = 100;


p.defaultParameters.pldaps.finish = 30;


p.trial.display.viewdist = 60; %dome radius


p.trial.treadmill.use = useWheel;
p.trial.treadmill.port = '/dev/ttyACM0';
p.trial.treadmill.exp = 1;


p.trial.newEraSyringePump.use = true;
p.trial.newEraSyringePump.port = '/dev/ttyUSB0';
p.trial.newEraSyringePump.triggerMode = 'ST';
p.trial.stimulus.rewardAmount = 15;


p.defaultParameters.display.ptr = 10;
p.defaultParameters.display.overlayptr = 11;
p.trial.display.useOverlay = 1;
p.trial.datapixx.use = 0;
% p.trial.sound.use = 1;
p.defaultParameters.display.useGL = 0;


p.trial.pldaps.pause.preExperiment = true;


p.trial.pldaps.trialMasterFunction = 'runModularTrial';
p.trial.pldaps.useModularStateFunctions = 1;

p.trial.stimulus.randomNumberGenerater = 'mt19937ar';

%need?
% if p.trial.eyelink.use
%     p.trial.eyelink.custom_calibration = 1;
%     % 9-point calibration
%     p.trial.eyelink.calSettings.calibration_type = 'HV9';
%     % use restricted range for calibration on HUGE screens  
%     
%     if viewdist < 60
%         eyeCalScale = 0.2      % 0.4 good for 85cm view dist (Kipp 2018),  0.2 worked at 45 cm
%     else 
%         eyeCalScale = 0.45
%     end
% 
%     p.trial.eyelink.custom_calibrationScale = eyeCalScale;
%     p.trial.eyelink.calSettings.calibration_area_proportion = sprintf('%2.2f %2.2f', eyeCalScale*[1 1]);
%     % pull in validation corner points a bit more
%     p.trial.eyelink.calSettings.calibration_corner_scaling = '0.85';
%     p.trial.eyelink.calSettings.validation_corner_scaling = '0.85';
%     
%     p.trial.eyelink.saveEDF = 1;
% end


Screen('Preference', 'SkipSyncTests', 0);

%% Initiate Treadmill
if (p.trial.treadmill.use == 1)

% arduino as arduino
    p.static.arduinoUno = arduino(p.trial.treadmill.port, 'Uno', 'Libraries', 'rotaryEncoder');
    p.static.encoder = rotaryEncoder(p.static.arduinoUno, 'D2', 'D3');

%arduino as serial
%     delete(instrfind);
%     p.trial.treadmill.arduino = serial(p.trial.treadmill.port, 'BaudRate', 115200);
%     fopen(p.trial.treadmill.arduino);
    %fwrite(p.trial.treadmill.serial, 'B');
    %need brake command in here somewhere (in the manual)
%     treadmill.CheckWorking
%         if treadmill.CheckWorking.IsWorking ~= 1
%             disp('Treadmill is not functioning! Check connection.');
%             stop;
%         end
end

%% run code 
p.run


toc

end