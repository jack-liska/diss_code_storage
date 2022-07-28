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
subj = 'test';

% define the camera object
marmieCamFace = videoinput('linuxvideo', 1, 'RGB24_800x600');
marmieCamBody = videoinput('linuxvideo', 2, 'RGB24_800x600');
src1 = getselectedsource(marmieCamFace);
src2 = getselectedsource(marmieCamBody);
src1.PowerLineFrequency = '60 Hz';
src2.PowerLineFrequency = '60 Hz';
src1.WhiteBalanceMode = 'auto';
src2.WhiteBalanceMode = 'auto';
src1.Brightness = 170;
src2.Brightness = 170;

% have it grab frames until we tell it to stop
marmieCamFace.FramesPerTrigger = Inf;
marmieCamBody.FramesPerTrigger = Inf;

% set ROI to reduce filesize bloat
marmieCamFace.ROIPosition = [100 200 400 300];
marmieCamBody.ROIPosition = [100 200 400 300];

% set the logging type and path
marmieCamFace.LoggingMode = 'disk';
marmieCamBody.LoggingMode = 'disk';

% % define the properties of an image object to display the previews in
% nBands = marmieCamFace.NumberOfBands;
% vidRes = marmieCamFace.ROIPosition;
% hImage = image( zeros(vidRes(3), vidRes(4), nBands) );

outputPath = '/media/huklab/New Volume/rawVideo/';
outputPrefixFace = 'marmieCamFace';
outputPrefixBody = 'marmieCamBody';
outputDate = datestr(now,'ddmmyy');
i = 0; j=0; outputSuffixFace = '00'; outputSuffixBody = '00';
cd(outputPath);
% Generate the file name
fileNameFace = strcat(outputPrefixFace,'_',subj,'_',outputDate,'_',outputSuffixFace);
fileNameBody = strcat(outputPrefixBody,'_',subj,'_',outputDate,'_',outputSuffixBody);
% add a suffix if the file name exists
while exist([outputPath [fileNameFace '.avi']],'file')
    i = i+1; 
    outputSuffix = num2str(i,'%.2d');
    fileNameFace = strcat(outputPrefixFace,'_',subj,'_',outputDate,'_',outputSuffixFace);
end
while exist([outputPath [fileNameBody '.avi']],'file')
    j = j+1; 
    outputSuffix = num2str(j,'%.2d');
    fileNameBody = strcat(outputPrefixBody,'_',subj,'_',outputDate,'_',outputSuffixBody);
end

diskLoggerFace = VideoWriter([outputPath fileNameFace], 'Uncompressed AVI');
diskLoggerBody = VideoWriter([outputPath fileNameBody], 'Uncompressed AVI');
marmieCamFace.DiskLogger = diskLoggerFace;
marmieCamBody.DiskLogger = diskLoggerBody;

%%

% start recording
set(0,'DefaultFigureWindowStyle','normal');
preview(marmieCamFace); preview(marmieCamBody);
start(marmieCamFace); start(marmieCamBody);
vidStartTime = GetSecs;

%%

stop(marmieCamFace); stop(marmieCamBody);
vidEndTime = GetSecs;

cd(outputPath);
save(fileNameFace, 'vidStartTime', 'vidEndTime');
save(fileNameBody, 'vidStartTime', 'vidEndTime');

%% read it out to check
% V = VideoReader('/media/jack/DATA/vidtest/VidTest.avi');
% vidLength = vidEndTime - vidStartTime;
% framelast = read(V, inf);