function tread_on(p,portname)
%% Function to open up the USB-Serial port
% Also contains all the config parameters for the treadmill
delete(instrfind);
%p.trial.treadmill.serial = serial(portname);
p.trial.treadmill.serial = serial('/dev/ttyUSB0');
fopen(p.trial.treadmill.serial);
set(p.trial.treadmill.serial,'baudrate',57600);
set(p.trial.treadmill.serial,'timeout',60);
%read a few bytes then flush
disp(fscanf(p.trial.treadmill.serial,'%s'));
disp(fscanf(p.trial.treadmill.serial,'%s'));
for i=1:5
    fscanf(p.trial.treadmill.serial,'%s')
end
disp(fscanf(p.trial.treadmill.serial,'%s'));
fscanf(p.trial.treadmill.serial,'%s')
fscanf(p.trial.treadmill.serial,'%s')
fread(p.trial.treadmill.serial,6);
%read optical resolution of sensor
fwrite(p.trial.treadmill.serial,'GO');
disp('Optical resolution');
disp(fscanf(p.trial.treadmill.serial,'%s', 10));
flushinput(p.trial.treadmill.serial);

fwrite(p.trial.treadmill.serial, 'B')

% %% Get resting voltage for today's data
% Datapixx('RegWrRd');   % Update registers for GetAdcStatus
% pause(2);
% status = Datapixx('GetAdcStatus');
% 
% % Read the ADC buffer data since last frame
% [adcData, adcTimetags] = Datapixx('ReadAdcBuffer', status.newBufferFrames);
% p.restingVoltage = mean(adcData);
% fprintf('Resting voltage is % cm\n', p.restingVoltage);


%%BRAKE
%fwrite(p.trial.treadmill.serial, 'B')
