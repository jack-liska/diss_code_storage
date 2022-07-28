%% new matlab package

ardUno = arduino('/dev/ttyACM0', 'Uno', 'Libraries', 'rotaryEncoder');
%ardDue = arduino('/dev/ttyACM0', 'Due', 'Libraries', 'rotaryEncoder');

rEncoder = rotaryEncoder(ardUno, 'D2', 'D3');
% rEncoder = rotaryEncoder(ardDue, 'D2', 'D3');

fRate = 120;
frameTimes = zeros(2,10*fRate);

%%

resetCount(rEncoder);
    
frameTimes(1,1) = readCount(rEncoder);

for frame = 1:(10*fRate)
    [frameTimes(1,frame), frameTimes(2,frame)] = readCount(rEncoder);
    %frameTimes(2,frame) = posixtime(datetime);
end

%%

frameDeltas = zeros(1,size(frameTimes, 2));

for i = 2:size(frameTimes, 2)
   
    frameDeltas(1,i) = frameTimes(1,i) - frameTimes(1,i-1);
    frameDeltas(2,i) = frameTimes(2,i) - frameTimes(2,i-1);
end

frameDeltas(2,:) = frameDeltas(2,:) * 1000; %convert to ms

figure;
histogram(frameDeltas(2,:), 30);
frameMean = mean(frameDeltas(2,:));
xline(frameMean, 'LineWidth', 2);
frameStd = std(frameDeltas(2,:));
xline(frameMean-frameStd, ':r', 'LineWidth', 2);
xline(frameMean+frameStd, ':r', 'LineWidth', 2);
xlabel('read time (ms)');

% figure
% scatter(frameDeltas(1,:),frameDeltas(2,:));


%% let's do the same thing in serial
delete(instrfind);
s = serial('/dev/ttyACM0', 'BaudRate', 115200);

fRate = 120;
frameTimes = zeros(2,10*fRate);
fopen(s);


%%
fwrite(s, 'a');

for frame = 1:(10*fRate)
    flushinput(s);
    str2num(fscanf(s));
    frameTimes(2,frame) = posixtime(datetime);
end

%%

frameDeltas = zeros(1,size(frameTimes, 2));

for i = 2:size(frameTimes, 2)
   
    frameDeltas(1,i) = frameTimes(1,i) - frameTimes(1,i-1);
    frameDeltas(2,i) = frameTimes(2,i) - frameTimes(2,i-1);
end

frameDeltas(2,:) = frameDeltas(2,:) * 1000; %convert to ms

figure;
histogram(frameDeltas(2,:), 30);
frameMean = mean(frameDeltas(2,:));
xline(frameMean);
frameStd = std(frameDeltas(2,:));
xline(frameMean-frameStd);
xline(frameMean+frameStd);

figure
scatter(frameDeltas(1,:),frameDeltas(2,:));

%% trying the old matlab Arduino toolbox

ard = legacyArdControl.arduino('/dev/ttyACM0');
ard.encoderAttach(0, 2, 3);

fRate = 120;
frameTimes = zeros(2,10*fRate);

%%

ard.encoderReset(0);
    
frameTimes(1,1) = ard.encoderRead(0);

for frame = 1:(10*fRate)
    [frameTimes(1,frame), frameTimes(2,frame)] = ard.encoderRead(0);
    %frameTimes(2,frame) = posixtime(datetime);
end

%%

frameDeltas = zeros(1,size(frameTimes, 2));

for i = 2:size(frameTimes, 2)
   
    frameDeltas(1,i) = frameTimes(1,i) - frameTimes(1,i-1);
    frameDeltas(2,i) = frameTimes(2,i) - frameTimes(2,i-1);
end

frameDeltas(2,:) = frameDeltas(2,:) * 1000; %convert to ms

figure;
histogram(frameDeltas(2,:), 30);
frameMean = mean(frameDeltas(2,:));
xline(frameMean);
frameStd = std(frameDeltas(2,:));
xline(frameMean-frameStd);
xline(frameMean+frameStd);

figure
scatter(frameDeltas(1,:),frameDeltas(2,:));