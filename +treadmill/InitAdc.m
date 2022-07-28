function InitAdc()

%Initializes ADC after previous frame display

AssertOpenGL;   % We use PTB-3

if Datapixx('isReady') == 0
    Datapixx('Open');
    Datapixx('StopAllSchedules');
    Datapixx('RegWrRd');
end% Synchronize Datapixx registers to local register cache

%% test stuff
% dacData = [3.5 3.5 3.5 3.5 3.5 3.5 3.5 3.5 3.5];
% Datapixx('WriteDacBuffer', dacData);
% 
% Datapixx('SetDacSchedule', 0, 1e5, 0, [0 1], 0, nDacSamples);
% Datapixx('StartDacSchedule');
% Datapixx('RegWrRd');

%%real stuff

% Configure ADC to acquire 1 channel (ADC0 ) at 1 kSPS.
% Configure to take as many samples as exist between frames.
Datapixx('SetAdcSchedule', 0, 1e3, 0,[0],[] ,1000);
Datapixx('DisableDacAdcLoopback');  
Datapixx('DisableAdcFreeRunning'); % For microsecond-precise sample windows
Datapixx('StartAdcSchedule'); % Start ADC acquisition immediately
Datapixx('RegWrRd');

end