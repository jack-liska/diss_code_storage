function p = pmTreadReward(p, state, sn)

%   reward paradigm for treadmill tasks
%   dist - give based on fixed distance traveled
%   rndTime - give reward at n random times throughout each trial


switch state
    
    % frame states
    case p.trial.pldaps.trialStates.frameUpdate
        
        switch p.trial.(sn).rewardMode
            
            case 'dist'
                
              if p.trial.locationSpace(2, p.trial.iFrame) > p.trial.nextReward && p.trial.locationSpace(2, p.trial.iFrame - 1) < p.trial.nextReward
                    
                    pds.behavior.reward.give(p);
                    p.trial.nextReward = p.trial.nextReward + p.trial.(sn).rewardDist;
                end
                
            case 'rndTime'
        end
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        p.trial.nextReward = 0;
end

end

