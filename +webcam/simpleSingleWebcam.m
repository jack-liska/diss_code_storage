% this script creates a single simple webcam with preview that grabs a 
% GetSecs timestamp at the beginning and end of acquisition.
% once things are set up, you should be able to simply run the 'start
% recording' section at experiment start, and the 'stop recording' section
% at experiment end. This will ALWAYS need first-time setup, as every rig
% has different lighting, geometry, hard drive layouts, etc.

% THIS SCRIPT SHOULD ALWAYS BE RUN IN ITS OWN INSTANCE OF MATLAB

% JL Oct 2021

%% first time stuff
% decide your output path and assign the outputPath variable to it
% run >imaqhwinfo to find the name of your camer and set it in the
% videoinput function on line 27.
% run >imaqtool and play around with settings, find a resolution and format 
% that works, set find an ROI that only gets you the portion of the camera 
% you want (important to reduce file size), find the brightness, white 
% balance, etc., that work for your setup and copy them into the setup block below

%% set up the camera

% animal
subj = 'brie';

% define the camera object
marmieCam1 = videoinput('linuxvideo', 1, 'RGB24_800x600');
src1 = getselectedsource(marmieCam1);
src1.PowerLineFrequency = '60 Hz';
src1.WhiteBalanceMode = 'auto';
src1.Brightness = 170;

% have it grab frames until we tell it to stop
marmieCam1.FramesPerTrigger = Inf;

% set ROI to reduce filesize bloat
marmieCam1.ROIPosition = [100 200 400 300];

% set the logging type and path
marmieCam1.LoggingMode = 'disk';


outputPath = '/media/huklab/New Volume/rawVideo/';
outputPrefix = 'marmieCam1';
outputDate = datestr(now,'ddmmyy');
i = 0; outputSuffix = '00';
cd(outputPath);
% Generate the file name
fileName = strcat(outputPrefix,'_',subj,'_',outputDate,'_',outputSuffix);

% add a suffix if the file name exists
while exist([outputPath [fileName '.avi']],'file')
    i = i+1; 
    outputSuffix = num2str(i,'%.2d');
    fileName = strcat(outputPrefix,'_',subj,'_',outputDate,'_',outputSuffix);
end

diskLogger = VideoWriter([outputPath fileName], 'Uncompressed AVI');
marmieCam1.DiskLogger = diskLogger;

%%

% start recording
preview(marmieCam1);
start(marmieCam1);
vidStartTime = GetSecs;

%%

stop(marmieCam1);
vidEndTime = GetSecs;

cd(outputPath);
save(fileName, 'vidStartTime', 'vidEndTime');

%% read it out to check
% V = VideoReader('/media/jack/DATA/vidtest/VidTest.avi');
% vidLength = vidEndTime - vidStartTime;
% framelast = read(V, inf);