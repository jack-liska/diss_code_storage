function p = pmTread(p, state, sn)

% module that controls the treadmill and records position, speed, and
% reward related to it

switch state
    
    % frame states
    case p.trial.pldaps.trialStates.frameUpdate

        if iseven(p.trial.iFrame) == 1 && p.trial.iFrame > 1
            
            p.trial.locationSpace(1,p.trial.iFrame) = readCount(p.static.encoder);
            p.trial.locationSpace(2,p.trial.iFrame) = p.trial.locationSpace(1,p.trial.iFrame) * p.trial.treadmill.scaleFactor; %current distance in cm
            
        elseif p.trial.iFrame == 1
            
            resetCount(p.static.encoder);
            p.trial.locationSpace(1:2, p.trial.iFrame) = [0; 0];
            
        else
            
            p.trial.locationSpace(2, p.trial.iFrame) = p.trial.locationSpace(2, p.trial.iFrame-1);
            
        end
        
        switch p.trial.(sn).rewardMode
           
            case 'dist'
                
                if p.trial.locationSpace(2, p.trial.iFrame) > p.trial.nextReward && p.trial.locationSpace(2, p.trial.iFrame - 1) < p.trial.nextReward
                    
                    pds.behavior.reward.give(p);
                    p.trial.nextReward = p.trial.nextReward + p.trial.(sn).rewardDist;
                end
                
            case 'time'
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameDraw
        
        
    % trial states
    
    case p.trial.pldaps.trialStates.trialPrepare
         
        p.trial.nextReward = p.trial.(sn).rewardDist;
        
    % expt states
    
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        p.static.arduinoUno = arduino(p.trial.treadmill.port, 'Uno', 'Libraries', 'rotaryEncoder');
        p.static.encoder = rotaryEncoder(p.static.arduinoUno, 'D3', 'D2');
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        p.trial.locationSpace = 0;
        
    case p.trial.pldaps.trialStates.experimentCleanUp
        
end