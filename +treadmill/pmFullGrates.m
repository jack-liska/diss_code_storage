function p = pmFullGrates(p, state, sn)

% generates fullscreen drifting gratings optimized for marmoset V1

snBase = sn(1:end-2);

switch state
    % frame states
    case p.trial.pldaps.trialStates.frameUpdate
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        if p.trial.(sn).on
            
            % update grating phase

            p.trial.(sn).Gpars = p.trial.(sn).Gpars + p.trial.(sn).phaseStep;
           
        end
        
    case p.trial.pldaps.trialStates.frameDraw
        drawGrates(p, sn);
    
    % trial states
        
    case p.trial.pldaps.trialStates.trialPrepare

            p.trial.(sn).Gpars = 0;
            p.trial.(sn).graTex = p.trial.pmBase.graTex;
            
    case p.trial.pldaps.trialStates.experimentCleanUp
        
        % this is already empty by the time it's closed?
        
% %          Screen('Close', p.trial.(sn).graTex);

end

%% nested functions

%% drawGrates
function drawGrates(p, sn)

    if p.trial.(sn).on        
        Screen('DrawTexture', p.trial.display.ptr, p.trial.(sn).graTex, [], [], p.trial.(sn).dirs, [],[],[],[], 1, [p.trial.(sn).Gpars, 1/p.trial.(sn).grateSf, p.trial.(sn).contrast, 0]);
    end
    
end


%% trialPrepare
    function trialPrepare(p, sn)
 % generate grating % NEED TO MAKE THIS HAPPEN ONCE PER TRIAL
%         p.trial.(sn).graTex = CreateProceduralSineGrating(p.trial.display.ptr, p.trial.display.screenSize(3), p.trial.display.screenSize(4), [], [], [] );
%        
%         p.trial.(sn).Gpars = 0;
%         p.trial.(sn).haveGenGrates = 1;
    end
end