function [interframeDist, speed] = GetRunDist()

%Determines the distance traveled between frames so the correct image can
%be displayed to the dome

Datapixx('RegWrRd');   % Update registers for GetAdcStatus
status = Datapixx('GetAdcStatus');

% Read the ADC buffer data since last frame
[adcData, adcTimetags] = Datapixx('ReadAdcBuffer', status.newBufferFrames);
restingVoltage = 2.5; %Don't forget to fix this
%plot(adcTimetags, adcData);

%low speed issue code
% interframeDist = ((median(adcData)-restingVoltage)/10)*length(adcData);
% speed = median(adcData)-restingVoltage;

%fix testing code
adcData = adcData-restingVoltage;
interframeDist = (mean(adcData)/10)*length(adcData);
speed = mean(adcData);

% if interframeDist <= 0.01 && interframeDist >= -0.01
%     interframeDist = 0;
% end
%fprintf('Distance traveled last frame was % cm\n', interframeDist);
% Job done
Datapixx('StopAdcSchedule');
Datapixx('RegWrRd');

end