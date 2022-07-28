function p=treadmill_stim(p,state)
% trial file for sacTraining (training fixation and saccades)
% relies on sacTrainingSetup.m which sets up initial parameters

% Runs through default trial states (Drawing, frame flipping and updating etc.)
pldapsDefaultTrialFunction(p,state);
%%
% *** TRIAL STATES *** Only called once at the beginning of each trial
%-----------------------------------------------------------------%
%-----------------------------------------------------------------%
switch state
    case p.trial.pldaps.trialStates.trialSetup
        
        %% GENERAL trial setup for any task
        p.trial.display.w2px = p.trial.display.w2px/57.29*p.trial.display.viewdist;
        % convert deg to pix for fp win
        p.trial.stimulus.fpWinPx = p.trial.stimulus.fpWin.*p.trial.display.w2px'; % deg to pix (instead of p.trial.display.ppd): x,y of the circle (elipse)
        
        % convert deg to pix for fp
        p.trial.stimulus.fpPx = p.trial.stimulus.fixationXY.*p.trial.display.w2px';
        
        % convert dege to pix for fp target
        p.trial.stimulus.fpTargPx = p.trial.stimulus.fixVisSize.*p.trial.display.w2px';
        
        % set up random ITI
        p.trial.stimulus.preTrial = p.trial.stimulus.jitter.preTrial(1) + (p.trial.stimulus.jitter.preTrial(2)-p.trial.stimulus.jitter.preTrial(1)).*rand(1);
        
        % set up reward wait
        p.trial.stimulus.rewardWait = p.trial.behavior.reward.jitter * rand;
        
        % set FP contrast (%), [rgba]
        %p.trial.display.clut.fixation = [p.trial.display.clut.fixation; p.trial.stimulus.fpContrast/100]; % CARFFUL, we overwrite this variable but jsut to add an alpha value
        p.trial.display.clut.fp = [p.trial.display.clut.red; p.trial.stimulus.targContrast/100];
        
        % set Target contrast (%), [rgba]  ***IMPORTANT*** Just commented
        % out so I could change contrast below for just part of the target
        % and I was overwriting things, so if you want to change the target
        % contrast for the whole trial you need this here but it will
        % interfere with the mode where you draw the target - must deal wit
        % this later **** didn't have time to make this work yet so
        % commenting back in...
        %p.trial.display.clut.red = [p.trial.display.clut.red; p.trial.stimulus.targContrast/100]; %CAREFUL, overwriting, like above.  /dumb i should update this from 'red' and make the color of this and fp variables, also if you try to overwrite it later****
        
        %-----------------------------------------------------------------%
        %-----------------------------------------------------------------%
        %% Switch between each training mode
        
        if strcmp(p.trial.trainingMode.flag,'fix')
            % Fixation Training
            p.trial.trainingMode.fixationTraining = true;
        elseif strcmp(p.trial.trainingMode.flag,'map')
            % Mapping with Scenes
            p.trial.trainingMode.mappingWithScenes = true;
            %-----------------------------------------------------------------%
            % Load in image for RF mapping with Natural Scenes (mapping mode only)
            
            % Proportion of the screen you want image of the scene
            % displayed (ONLY FOR SCNE MODE, but needed to do it outside teh if-else for the purposes of my sceneHeld in-line func),changed this
            p.trial.stimulus.sceneSize = [p.trial.display.winRect(4)*(p.trial.stimulus.sceneProp/100) p.trial.display.winRect(3)*(p.trial.stimulus.sceneProp/100)]; % NOTE:THis has to be 4,3 weird, but right, so this might be screwing up x-y later for the window!! **should be ok now
            
            % Calculate scene window (THIS IS ONLY TO CHECK TO SEE IF THE
            % EYES ARE WITHIN THE SCENE) - BTW THIS SHIT WAS TRICKY AND
            % MESSED UP BY OLD CODE, so this was my nice simple solution
            p.trial.stimulus.sceneRect = fliplr(p.trial.stimulus.sceneSize) - p.trial.display.ctr(1:2);
            
            % Load in Image files
            %%p.trial.stimulus.sceneImageFile = [p.trial.stimulus.fileInfo.scenePath p.trial.stimulus.sceneNames{p.trial.pldaps.iTrial}]; % old way
            p.trial.stimulus.sceneImageFile = [p.trial.stimulus.fileInfo.scenePath p.conditions{p.trial.pldaps.iTrial}.sceneNames]; % new way :-)
            
            % Background
            p.trial.stimulus.sceneImage = imread(p.trial.stimulus.sceneImageFile, p.trial.stimulus.fileInfo.sceneFormat); % Read in image
            
            p.trial.stimulus.sceneImage = imresize(p.trial.stimulus.sceneImage, [p.trial.stimulus.sceneSize(1) p.trial.stimulus.sceneSize(2)]); % Resize Image to screen
            p.trial.stimulus.sceneImageTexture = Screen('MakeTexture', p.trial.display.ptr, p.trial.stimulus.sceneImage); % Create Texture
            
            
            %-----------------------------------------------------------------%
        elseif strcmp(p.trial.trainingMode.flag,'sac')
            % Saccade training (currently for overlaps or gaps, some offset of target on fp)
            p.trial.trainingMode.saccadeTraining = true;
            %         elseif strcmp(p.trial.trainingMode.flag,'mgs')
            %             % MGS training (from memSac.m) - need to build visual back in here
            %             p.trial.trainingMode.mgs = true;
        else
            error('No training mode selected.')
        end
        
        
        %-----------------------------------------------------------------%
        % Setup Target
        
        
        % sampling cursor here as well just so I don't have to modify pldapsDefaultTrialFunction (it wasn't being stored in the p object)
        [p.trial.mouse.cursorX,p.trial.mouse.cursorY,p.trial.mouse.isMouseButtonDown] = GetMouse();
        
        
        
        %-----------------------------------------------------------------%
        % ---Jitter Stimulus---%
%         
%         % Jitter Time
%         if p.trial.stimulus.jitter.jitterTimeOn
%             p.trial.stimulus.fpDuration = (p.trial.stimulus.jitter.fpDuration(1) + (p.trial.stimulus.jitter.fpDuration(2)-p.trial.stimulus.jitter.fpDuration(1)).*rand(1));
%             %             p.trial.stimulus.targFpAsynchony = (p.trial.stimulus.jitter.asynchronyRange(1) + (p.trial.stimulus.jitter.asynchronyRange(2)-p.trial.stimulus.jitter.asynchronyRange(1)).*rand(1)); % looks like it's fine that there negatives for overlap
%         end
%         
%         
%         % Calculate window of each target
%         p.trial.stimulus.targPx = p.trial.stimulus.targVisSize.*p.trial.display.w2px';
%         
%         
%         for(i = 1:length((p.conditions{p.trial.pldaps.iTrial}.targLoc)))
%             if(p.conditions{p.trial.pldaps.iTrial}.soa <= 0) % flip array structure based on SOA
%                 targLoc = p.conditions{p.trial.pldaps.iTrial}.targLoc;
%             else
%                 targLoc = p.conditions{p.trial.pldaps.iTrial}.targLoc(end:-1:1);
%             end
%             
%             p.trial.stimulus.targLoc(i,:) = [cosd(targLoc(i)) sind(targLoc(i))].*[p.trial.stimulus.targXYdeg(1)*p.trial.display.w2px(1) p.trial.stimulus.targXYdeg(1)*p.trial.display.w2px(2)]; % deg to pix
%             p.trial.stimulus.targWin(i,:) = p.trial.stimulus.fpWinPx + [1 1] * (sqrt(sum((p.trial.stimulus.targLoc(i,:) - p.trial.stimulus.fixationXY).^2))*p.trial.stimulus.winScale); % fpWin in Px here
%             p.trial.stimulus.targSize(i,:) = [-p.trial.stimulus.targPx(1) -p.trial.stimulus.targPx(2) p.trial.stimulus.targPx(1) p.trial.stimulus.targPx(2)] + [p.trial.display.ctr(1:2) + p.trial.stimulus.targLoc(i,:),p.trial.display.ctr(1:2) + p.trial.stimulus.targLoc(i,:)]; % all in Pix = p.trial.stimulus.fpWinPx + [1 1] * (sqrt(sum((p.trial.stimulus.targLoc(i,:) - p.trial.stimulus.fixationXY).^2))*p.trial.stimulus.winScale); % fpWin in Px here
%             
%             p.trial.stimulus.targRect(i,:) = [-p.trial.stimulus.targWin(i,1) -p.trial.stimulus.targWin(i,2) p.trial.stimulus.targWin(i,1) p.trial.stimulus.targWin(i,2)] + [p.trial.display.ctr(1:2) + p.trial.stimulus.targLoc(i,:),p.trial.display.ctr(1:2) + p.trial.stimulus.targLoc(i,:)];
%         end
%         
%         %-----------------------------------------------------------------%
%         % Calculate fixation target and window
%         
%         
%         p.trial.stimulus.fixSize = [-p.trial.stimulus.fpTargPx(1) -p.trial.stimulus.fpTargPx(2) p.trial.stimulus.fpTargPx(1) p.trial.stimulus.fpTargPx(2)] + [p.trial.display.ctr(1:2) + p.trial.stimulus.fixationXY,p.trial.display.ctr(1:2) + p.trial.stimulus.fixationXY]; % all in Pix
%         p.trial.stimulus.fixRect = [-p.trial.stimulus.fpWinPx(1) -p.trial.stimulus.fpWinPx(2) p.trial.stimulus.fpWinPx(1) p.trial.stimulus.fpWinPx(2)] + [p.trial.display.ctr(1:2) + p.trial.stimulus.fixationXY,p.trial.display.ctr(1:2) + p.trial.stimulus.fixationXY]; % all in Pix
%         
%         % Starting stimulus states for fixaiton (don't forget p.trial.stimulus.states different then p.trial.pldaps.trialStates)
%         p.trial.state = p.trial.stimulus.states.START; % NEED THIS!
%         p.trial.stimulus.showFixationPoint = 1; % fix on (I think I need this here rather than just in the setup, weird)
%         
        %-----------------------------------------------------------------%
        % computing and displaying running mean of percent correct
        % (IMPORTANT: be careful, if you close out of PLDAPS session and then reload that same object things might get wonky, as in not calculated right)
        if p.trial.pldaps.iTrial > 1
            goodtrials = cell2mat(cellfun(@(x) nansum(x.pldaps.goodtrial), p.data, 'UniformOutput', false)); % nansuming every cell as a trick to turn the nans into zeros
            breaktrials = cell2mat(cellfun(@(x) isnan(x.pldaps.goodtrial), p.data, 'UniformOutput', false));
            pc = nansum(goodtrials) / (length(goodtrials) - sum(breaktrials));
            disp(['goodtrials ' num2str(nansum(goodtrials)) '/' num2str((length(goodtrials) - sum(breaktrials))) '; ' num2str(pc*100) '% correct']);
        end
        
        %-----------------------------------------------------------------%
        %-----------------------------------------------------------------%
        % *** FRAME STATES *** %
%     case p.trial.pldaps.trialStates.framePrepareDrawing
%         
%         p = checkFixation(p);
%         
%         p = checkTargetFixation(p);
%         
%         p = checkTrialState(p);
%         
%         
%         % save eye position on every frame
%         
%         p.trial.stimulus.eyeXYs(:,p.trial.iFrame)= [p.trial.eyeX-p.trial.display.pWidth/2; p.trial.eyeY-p.trial.display.pHeight/2];
%         
%         %-----------------------------------------------------------------%
%         % sampling cursor here as well just so I don't have to modify pldapsDefaultTrialFunction (it wasn't being stored in the p object)
%         [p.trial.mouse.cursorX,p.trial.mouse.cursorY,p.trial.mouse.isMouseButtonDown] = GetMouse();
%         
%         %-----------------------------------------------------------------%
%         %-----------------------------------------------------------------%
    case p.trial.pldaps.trialStates.frameDraw
        %%
        
        if p.trial.treadmill.exp == 2
        
            % Load in that sweet, sweet texture
            global allShots;     
    %         if p.trial.treadmill.datapixx.isRunning == 1
    %             [interframeDist, speed] = treadmill.GetRunDist();
    % 
    %             p.trial.treadmill.speed(p.trial.iFrame) = speed;
    %         else
    %             interframeDist =0;
    %         end

    %         p.trial.treadmill.datapixx.isRunning = 1;

            if(p.trial.iFrame > 1) 
    %             %store the actual position so we can accurately add distance
    %             %between frames
    %             p.trial.treadmill.locationActual(p.trial.iFrame) = p.trial.treadmill.location(end) + (interframeDist * p.trial.treadmill.ATU);
    %             %now that we have the actual position stored, round so we can
    %             %display the correct image
    %             p.trial.treadmill.location(p.trial.iFrame) = round(p.trial.treadmill.locationActual(p.trial.iFrame));

    %           arduino as arduino
                p.trial.treadmill.locationSpace(p.trial.iFrame) = readCount(p.static.encoder) * p.trial.treadmill.scaleFactor; %current distance in cm
                p.trial.treadmill.locationFrame(p.trial.iFrame) = round(p.trial.treadmill.locationSpace(p.trial.iFrame)/p.trial.treadmill.ATU)+1;


                %arduino as serial
    %             fwrite(p.trial.treadmill.arduino, 'a');     
    %             p.trial.treadmill.locationSpace(p.trial.iFrame) = p.trial.treadmill.locationSpace(p.trial.iFrame-1) + (str2double(fscanf(p.trial.treadmill.arduino)) * p.trial.treadmill.scaleFactor); %current distance in cm            
    %             p.trial.treadmill.locationFrame(p.trial.iFrame) = round(p.trial.treadmill.locationSpace(p.trial.iFrame)/p.trial.treadmill.ATU)+1;
    %             
    %              if mod(p.trial.iFrame, 2) == 0 
    %               p.trial.treadmill.locationSpace(p.trial.iFrame) = readCount(p.static.encoder) * p.trial.treadmill.arduino.scaleFactor; %current distance in cm
    %               p.trial.treadmill.locationFrame(p.trial.iFrame) = round(p.trial.treadmill.locationSpace(p.trial.iFrame)/p.trial.treadmill.ATU)+1;
    %              else
    %               p.trial.treadmill.locationSpace(p.trial.iFrame) = p.trial.treadmill.locationSpace(p.trial.iFrame-1) + (p.trial.treadmill.locationSpace(p.trial.iFrame-1) - p.trial.treadmill.locationSpace(p.trial.iFrame-2));
    %               p.trial.treadmill.locationFrame(p.trial.iFrame) = round(p.trial.treadmill.locationSpace(p.trial.iFrame)/p.trial.treadmill.ATU)+1;
    %              end
            else

                %arduino as arduino
                resetCount(p.static.encoder);
                p.trial.treadmill.locationSpace(p.trial.iFrame) = 0;
                p.trial.treadmill.locationFrame(p.trial.iFrame) = 1;

                %arduino as serial
    %             %fwrite(p.trial.treadmill.arduino, 'a');
    %             p.trial.treadmill.locationSpace(p.trial.iFrame) = 0;
    %             p.trial.treadmill.locationFrame(p.trial.iFrame) = 1;
            end 

            %overwrite all this for acclimation/replay
            if p.trial.acclimation == 1
                p.trial.treadmill.locationFrame(p.trial.iFrame) = round(p.trial.iFrame/2);
            end

            if p.trial.treadmill.locationFrame(p.trial.iFrame) <= 1
                p.trial.treadmill.locationFrame(p.trial.iFrame) = 1;
                p.trial.treadmill.locationSpace(p.trial.iFrame) = 0;
                resetCount(p.static.encoder);
            end

            if(p.trial.iFrame > 1) 
                Screen('Close',p.trial.stimulus.scene) 
            end

            if p.trial.treadmill.locationFrame(p.trial.iFrame) > p.trial.treadmill.endPoint
                p.trial.treadmill.locationFrame(p.trial.iFrame) = p.trial.treadmill.endPoint;
            end

            p.trial.stimulus.scene = Screen('MakeTexture',p.trial.display.ptr,allShots(:,:,p.trial.treadmill.locationFrame(p.trial.iFrame),p.trial.treadmill.grateDir(p.trial.pldaps.iTrial)),[],4);
            Screen('DrawTexture',p.trial.display.ptr,p.trial.stimulus.scene);

            treadmill.InitAdc();

            if floor(p.trial.treadmill.locationFrame(p.trial.iFrame)/200) == (p.trial.treadmill.locationFrame(p.trial.iFrame)/200)
                pds.behavior.reward.give(p,p.trial.stimulus.rewardAmount);
            end
        end
        
        if p.trial.treadmill.exp == 1
            
        
        %Draw Fixation pt
%         if p.trial.stimulus.showFixationPoint && p.trial.ttime > p.trial.stimulus.preTrial % how long to wait until we start drawing fp)
%             
%             Screen('SelectStereoDrawBuffer',p.trial.display.ptr,0);
%             Screen('FillArc', p.trial.display.ptr, p.trial.display.clut.stimulus, p.trial.stimulus.fixSize, 0, 360)
%             
%             Screen('SelectStereoDrawBuffer',p.trial.display.ptr,1);
%             Screen('FillArc', p.trial.display.ptr, p.trial.display.clut.stimulus, p.trial.stimulus.fixSize, 0, 360)
%             
%             
%             if isnan(p.trial.stimulus.timeFpOn)
%                 p.trial.stimulus.timeFpOn = p.trial.ttime;
%                 p.trial.stimulus.frameFpOn = p.trial.iFrame;
%             end
        end
        
        % Draw Mouse
%         if p.trial.pldaps.draw.cursor.showCursor
%             Screen('Drawdots',  p.trial.display.overlayptr,  [p.trial.mouse.cursorX,p.trial.mouse.cursorY], ...
%                 p.trial.stimulus.eyeW, p.trial.display.clut.cursor, [0 0],0);
%         end
        
%         % Draw fixation window
%         if p.trial.stimulus.showFixWin       
%             Screen('SelectStereoDrawBuffer',p.trial.display.ptr,0);
%             Screen('DrawArc', p.trial.display.overlayptr, p.trial.display.clut.eye0, p.trial.stimulus.fixRect, 0, 360);
%             
%             Screen('SelectStereoDrawBuffer',p.trial.display.ptr,1);
%             Screen('DrawArc', p.trial.display.overlayptr, p.trial.display.clut.eye1, p.trial.stimulus.fixRect, 0, 360);
%         end
        
        % Draw scene eye window
        if p.trial.stimulus.showSceneWin
            Screen('FrameRect', p.trial.display.overlayptr,p.trial.display.clut.window,p.trial.stimulus.sceneRect);
        end
        
        %-----------------------------------------------------------------%
        
%         % Draw Target window
%         if p.trial.stimulus.showTargWin
%             for(i = 1:size(p.trial.stimulus.targLoc,2))
%                 Screen('SelectStereoDrawBuffer',p.trial.display.ptr,0);
%                 Screen('DrawArc', p.trial.display.overlayptr, p.trial.display.clut.eye0, p.trial.stimulus.targRect(i,:), 0, 360)
%                 
%                 Screen('SelectStereoDrawBuffer',p.trial.display.ptr,1);
%                 Screen('DrawArc', p.trial.display.overlayptr, p.trial.display.clut.eye1, p.trial.stimulus.targRect(i,:), 0, 360)
%             end
%         end

        
        % Draw Target
        %normal drawing target mode (make sure you're in saccade
        %training mode... and then timings) - for overlaps (no
        %flash)
%         for(i = 1:size(p.trial.stimulus.targLoc,2))
%             if p.trial.trainingMode.saccadeTraining && ~p.trial.stimulus.targFlashOn && p.trial.iFrame > p.trial.stimulus.frameTargetOn(i) && p.trial.iFrame < (p.trial.stimulus.frameTargetOn(i) + p.trial.display.frate*p.trial.stimulus.targDuration)
%                 %                       Screen('Drawdots',  p.trial.display.overlayptr, p.trial.stimulus.targLoc, ...
%                 %                           p.trial.stimulus.targdotW, p.trial.display.clut.red, p.trial.display.ctr(1:2),1);
%                 %
%                 
%                 Screen('FillArc', p.trial.display.ptr, p.trial.display.clut.stimulus, p.trial.stimulus.targSize(i,:), 0, 360)
%                 p.trial.stimulus.frameTargetOn(i) = p.trial.iFrame;
%                 
%             end
%         end
        
%                 if p.trial.stimulus.postFlashTraining
%         
%                     if p.trial.trainingMode.saccadeTraining && p.trial.stimulus.targFlashOn && ~any(p.trial.stimulus.targdotWpostFlash) && p.trial.ttime > p.trial.stimulus.targOntime && p.trial.ttime > (p.trial.stimulus.targOntime+ p.trial.stimulus.targFlashDur) && p.trial.ttime < (p.trial.stimulus.targOntime + p.trial.stimulus.targDuration)
%                         % don't draw a dot after flash if width is zero
%         
%                     elseif p.trial.trainingMode.saccadeTraining && p.trial.stimulus.targFlashOn && p.trial.ttime > p.trial.stimulus.targOntime && p.trial.ttime > (p.trial.stimulus.targOntime + p.trial.stimulus.targFlashDur) && p.trial.ttime < (p.trial.stimulus.targOntime + p.trial.stimulus.targDuration)
%                         % draw the size dot specified after target is flashed
%                         Screen('Drawdots',  p.trial.display.overlayptr, p.trial.stimulus.targLoc, ...
%                             p.trial.stimulus.targdotWpostFlash, p.trial.display.clut.red, p.trial.display.ctr(1:2),1);
%                         p.trial.stimulus.frameTargetOn = p.trial.iFrame;
%         
%                         % need this still?
%                     elseif p.trial.trainingMode.saccadeTraining && p.trial.stimulus.targFlashOn && p.trial.ttime > (p.trial.stimulus.targOntime + p.trial.stimulus.targFlashDur) && p.trial.ttime < (p.trial.stimulus.targOntime + p.trial.stimulus.targDuration)
%                         Screen('Drawdots',  p.trial.display.overlayptr, p.trial.stimulus.targLoc, ...
%                             p.trial.stimulus.targdotW, p.trial.display.clut.red, p.trial.display.ctr(1:2),1);
%                         p.trial.stimulus.frameTargetOn = p.trial.iFrame;
%         
%                     end
%                 end
        
        
%         if(~isnan(p.trial.stimulus.frameTargetOn(1)))
%             for(i = 1:size(p.trial.stimulus.targLoc,2))
%                 % normal target flash - like memory guided saccades
%                 if p.trial.trainingMode.saccadeTraining && p.trial.stimulus.targFlashOn
%                     
%                     if p.trial.iFrame > p.trial.stimulus.frameTargetOn(i) && p.trial.iFrame < (p.trial.stimulus.frameTargetOn(i) + p.trial.display.frate*p.trial.stimulus.targFlashDur)
%                         
%                         
%                         Screen('SelectStereoDrawBuffer',p.trial.display.ptr,0);
%                         Screen('FillArc', p.trial.display.ptr, p.trial.display.clut.stimulus, p.trial.stimulus.targSize(i,:), 0, 360)
%                         
%                         Screen('SelectStereoDrawBuffer',p.trial.display.ptr,1);
%                         Screen('FillArc', p.trial.display.ptr, p.trial.display.clut.stimulus, p.trial.stimulus.targSize(i,:), 0, 360)
%                         
%                         if isnan(p.trial.stimulus.timeTargetOn(i))
%                             p.trial.stimulus.timeTargetOn(i) = p.trial.ttime;
%                         end
%                     end
%                     
%                 end
%             end
%         end
%         
%         %-----------------------------------------------------------------%
%         % Draw Natural Scene for naive mapping
%         if p.trial.trainingMode.mappingWithScenes && p.trial.stimulus.showScene % timing done in inline function
%             Screen('DrawTexture',p.trial.display.ptr,p.trial.stimulus.sceneImageTexture); % drawing is done in the center by default, change the destination rect if desired
%         end
        
        
        
    case p.trial.pldaps.trialStates.frameFlip
        % If you want the trial to have a maximum time based on frames
        % if the trial has exceeded maximum duration, end trial and move to the next
        
        if p.trial.iFrame > 1
            if p.trial.iFrame == p.trial.pldaps.maxFrames
                p.trial.flagNextTrial=true;
            end
                if p.trial.treadmill.exp == 2
                    if p.trial.treadmill.locationFrame(end) == p.trial.treadmill.endPoint
                        p.trial.flagNextTrial=true;
                        p.trial.pldaps.goodtrial = true;
                    end
                end
        end
    end


end % end treadmill_stim


%%helper functions
%-------------------------------------------------------------------------%
%%% INLINE FUNCTIONS
%-------------------------------------------------------------------------%


% function held = fixationHeld(p)
% 
% %% Add code for KbPress only
% if p.trial.inputType == 2
%     held = 1;
% else
%     
%     held = max(circlewindow(([p.trial.eyeX p.trial.eyeY]-(p.trial.stimulus.fixationXY+p.trial.display.ctr(1:2)))',p.trial.stimulus.fpWinPx(1),p.trial.stimulus.fpWinPx(2)));
% end
% 
% end
% 
% function held = targetHeld(p)

%% Add code for KbPress only
% if p.trial.inputType == 2
%     
%     [keyPressed, firstPressQ] = KbQueueCheck(p.trial.inputDev);
%     held = 0;
%     if keyPressed
%         if(firstPressQ(p.trial.keyboard.codes.Larrow))
%             p.trial.stimulus.response = 0;
%             held = 1;
%         elseif(firstPressQ(p.trial.keyboard.codes.Rarrow))
%             p.trial.stimulus.response = 1;
%             held = 1;
%         end
%         
%     else
%         held = 0;
%     end
%     
% else
%     
%     for(i = 1:size(p.trial.stimulus.targLoc,2))
%         held = max(circlewindow(([p.trial.eyeX p.trial.eyeY]-(p.trial.stimulus.targLoc(i,:)+p.trial.display.ctr(1:2)))',p.trial.stimulus.targWin(1,i),p.trial.stimulus.targWin(2,i)));
%         
%         if(held == 1)
%             p.trial.stimulus.response = i;
%             break
%         end
%     end
% end

% end
% 
% function held = sceneHeld(p)
% % drawing is done in the center by default, change the destination rect if desired (in drawing the scene texture above as well, and make that your sceneLoc)
% 
% held = squarewindow([p.trial.eyeX p.trial.eyeY]-p.trial.display.ctr(1:2), p.trial.stimulus.sceneRect(1), p.trial.stimulus.sceneRect(2)); % w,h
% end
% 
% % CHECK FIXATION
% %---------------------------------------------------------------------%
% function p = checkFixation(p)
% % WAITING FOR SUBJECT FIXATION (***all modes go through this***)
% %
% 
% 
% fixating=fixationHeld(p);
% if  p.trial.state == p.trial.stimulus.states.START
%     
%     if fixating && p.trial.ttime > p.trial.stimulus.preTrial && p.trial.ttime < (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait)  % first part - to make sure the target is not accidently shown before the fp
%         
%         p.trial.stimulus.timeFpEntered = p.trial.ttime; % you can do this here because you immediately leave this state so you don't overwrite it
%         p.trial.stimulus.frameFpEntered = p.trial.iFrame;
%         
%         % Change all this into frame counter instead of time counter - more
%         % precise time
%         
%         p.trial.stimulus.timeFpOff = p.trial.stimulus.timeFpEntered + p.trial.stimulus.fpDuration;
%         p.trial.stimulus.frameFpOff = p.trial.stimulus.frameFpEntered + round(p.trial.stimulus.fpDuration)*p.trial.display.frate; % 60 Hz refresh rate
%         p.trial.stimulus.frameTargetOn = [p.trial.stimulus.frameFpOff (p.trial.stimulus.frameFpOff + abs(p.conditions{p.trial.pldaps.iTrial}.soa))]; % two timers for T1 and T2 - IN FRAMES AND NOT IN SECS!!!!!!!
%         
%         
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial);
%         end
%         p.trial.state = p.trial.stimulus.states.FPHOLD;
%         
%     elseif p.trial.ttime  > (p.trial.stimulus.preTrial+p.trial.stimulus.fixWait)
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial);
%         end
%         p.trial.stimulus.timeBreakFix = p.trial.ttime;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
% end
% 
% % check if fixation is held (***different for each mode***)
% %---------------------------------------------------------------------%
% % FIXATION TRAINING
% if p.trial.state == p.trial.stimulus.states.FPHOLD && p.trial.trainingMode.fixationTraining
%     
%     if fixating && p.trial.iFrame > p.trial.stimulus.frameFpOff
%         
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial);
%         end
%         
%         p.trial.stimulus.timeFpOff  = p.trial.ttime;
%         p.trial.stimulus.frameFpOff = p.trial.iFrame;
%         
%         p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE; % end trial if successful (just for fixation training)
%         
%     elseif ~fixating && p.trial.iFrame <= p.trial.stimulus.frameFpOff
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial);
%         end
%         p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%         
%     end
% end
% %---------------------------------------------------------------------%
% % OVERLAP SACCADE TRAINING
% if p.trial.state == p.trial.stimulus.states.FPHOLD && p.trial.trainingMode.saccadeTraining
%     
%     % just break if you ever leave the fp win before
%     % it goes off
%     fixating=fixationHeld(p); % shouldn't have to recall this here...
%     if ~fixating
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
%         end
%         p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
%     
%     % moved up to fixation function
%     %p.trial.stimulus.targOntime = (p.trial.stimulus.timeFpOff + p.trial.stimulus.targFpAsynchony); % Calc time of target on
%     
%     if fixating && p.trial.iFrame > p.trial.stimulus.frameFpOff
%         
%         % Turn off fixation point (cue to make saccade) - GO SIGNAL
%         p.trial.stimulus.showFixationPoint = 0;
%         
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial);
%         end
%         
%         p.trial.stimulus.timeFpOff  = p.trial.ttime;
%         p.trial.stimulus.frameFpOff = p.trial.iFrame;
%         
%         p.trial.state = p.trial.stimulus.states.CHOOSETARG; % NEXT STATE: TARGET (need some grace time to saccade)
%         
%     elseif ~fixating && p.trial.iFrame <= p.trial.stimulus.frameFpOff
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial);
%         end
%         p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%         
%     end
% end
%---------------------------------------------------------------------%
% %         % MAPPING WITH NATURAL SCENES (THIS IS STILL WITHIN checkFixation probably a bad idea... ugh... it should really be a different state)
% %         if p.trial.state == p.trial.stimulus.states.FPHOLD && p.trial.trainingMode.mappingWithScenes
% %
% %             if fixating && p.trial.ttime > p.trial.stimulus.timeFpOff && p.trial.stimulus.sceneOnFlag == 0 % quick and dirty way of doing it
% %
% %                 if p.trial.datapixx.use
% %                     pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial)
% %                 end
% %
% %                 p.trial.stimulus.timeFpOff  = p.trial.ttime;
% %                 p.trial.stimulus.frameFpOff = p.trial.iFrame;
% %
% %                 %p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
% %                 p.trial.stimulus.sceneOnFlag = 1;
% %                 p.trial.stimulus.sceneOntime = p.trial.ttime;
% %
% %             elseif ~fixating && p.trial.ttime < p.trial.stimulus.timeFpOff
% %                 if p.trial.datapixx.use
% %                     pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
% %                 end
% %                 p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
% %                 p.trial.state = p.trial.stimulus.states.BREAKFIX;
% %
% %             elseif p.trial.stimulus.sceneOnFlag && p.trial.ttime < (p.trial.stimulus.timeFpOff + p.trial.stimulus.sceneDuration)
% %
% %                 p.trial.stimulus.showScene = 1; % subject is free to look wherever until the end (should probably extent window to be the size of the scene or screen)
% %
% %             elseif p.trial.stimulus.sceneOnFlag && p.trial.ttime > (p.trial.stimulus.timeFpOff + p.trial.stimulus.sceneDuration)
% %                 p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE; % subject is free to look wherever until the end (should probably extent window to be the size of the scene or screen)
% %             end
% %         end
%---------------------------------------------------------------------%
% if p.trial.state == p.trial.stimulus.states.FPHOLD && p.trial.trainingMode.mappingWithScenes
%     
%     if fixating && p.trial.iFrame > p.trial.stimulus.frameFpOff
%         
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.FIXATION,p.trial.pldaps.iTrial);
%         end
%         
%         p.trial.stimulus.timeFpOff  = p.trial.ttime; % this is ok right because as soon as it is assigned, we will switch out of this state
%         p.trial.stimulus.frameFpOff = p.trial.iFrame;
%         
%         p.trial.state = p.trial.stimulus.states.SCENE;
%         
%     elseif ~fixating && p.trial.iFrame <= p.trial.stimulus.frameFpOff
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial);
%         end
%         p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
% end
% 
% end % end checkFixation

% CHECK SCENE 'FIXATION' (eyes just have to be within scene window, not really fixation, just keeping consistent with naming these functions
% function p = checkSceneFixation(p)
% 
% if p.trial.trainingMode.mappingWithScenes
%     
%     eyesWithinScene = sceneHeld(p);
%     
%     %disp(eyesWithinScene) % for testing
%     
%     if p.trial.state == p.trial.stimulus.states.SCENE
%         
%         p.trial.stimulus.showScene = 1;
%         p.trial.stimulus.showFixationPoint = 0; % turn off FP (***TODO: version where you have to maintain fixation throughout the scene display, and obvious the fp stays on)
%         
%         if eyesWithinScene && p.trial.ttime > (p.trial.stimulus.timeFpOff + p.trial.stimulus.sceneDuration) % the time the fp goes off is basically the time the scene goes on
%             
%             p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
%             
%         elseif ~eyesWithinScene && p.trial.ttime <= (p.trial.stimulus.timeFpOff + p.trial.stimulus.sceneDuration)
%             if p.trial.datapixx.use
%                 pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial);
%             end
%             p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%             p.trial.state = p.trial.stimulus.states.BREAKFIX;
%         end
%         
%     end
%     
% end
% 
% end
% 
% % CHECK TARGET FIXATION
% function p = checkTargetFixation(p)
% 
% fixatingTarget = targetHeld(p);

% % CHOOSE TARGET
% if p.trial.state == p.trial.stimulus.states.CHOOSETARG
%     
%     if fixatingTarget % && p.trial.ttime
%         p.trial.stimulus.timeTargEntered = p.trial.ttime;
%         %p.trial.stimulus.targAcquired = 1; %so you can't leave and come back - Not necessary
%         if p.trial.inputType == 2 % SKIP HOLD TARGET IF USING KB INPUT
%             p.trial.stimulus.timeComplete = p.trial.ttime;
%             p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
%         else
%             p.trial.state = p.trial.stimulus.states.HOLDTARG;
%         end
%     elseif ~fixatingTarget && p.trial.ttime > (p.trial.stimulus.timeFpOff + p.trial.stimulus.targWait)
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
% end

% % HOLD TARGET
% if p.trial.state == p.trial.stimulus.states.HOLDTARG
%     
%     % Break if they ever leave the target window after acquiring it
%     if ~fixatingTarget
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.BREAKFIX,p.trial.pldaps.iTrial)
%         end
%         p.trial.stimulus.timeBreakFix = GetSecs - p.trial.trstart;
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
%     
%     if fixatingTarget && p.trial.ttime > (p.trial.stimulus.timeTargEntered + p.trial.stimulus.targHold)
%         % TRIALCOMPLETE
%         p.trial.stimulus.timeComplete = p.trial.ttime;
%         p.trial.state = p.trial.stimulus.states.TRIALCOMPLETE;
%     elseif ~fixatingTarget && p.trial.ttime <= (p.trial.stimulus.timeTargEntered + p.trial.stimulus.targHold)
%         % BREAKFIX
%         p.trial.state = p.trial.stimulus.states.BREAKFIX;
%         %         elseif p.trial.stimulus.targAcquired && ~fixatingTarget
%         %             % once you acquire the target you an not leave prematurely and come back
%         %             p.trial.state = p.trial.stimulus.states.BREAKFIX;
%     end
% end
% 
% end



% TRIAL COMPLETE? -- GIVE REWARD IF GOOD
%---------------------------------------------------------------------%
% function p = checkTrialState(p)
% if p.trial.state == p.trial.stimulus.states.TRIALCOMPLETE
%     
%     
%     p.trial.pldaps.goodtrial = true;
%     p.trial.pldaps.breakfix = false;
%     
%     if p.trial.ttime > p.trial.stimulus.timeComplete + p.trial.stimulus.rewardWait
%         
%         % added amount input in setup file here
%         pds.behavior.reward.give(p,p.trial.behavior.reward.amount); % ***sound is played in this fuction as well so if you want to add a Psychportaudio stop command you have to do it here as well
%         
%         % %                end
%         
%         
%         if p.trial.datapixx.use
%             pds.datapixx.flipBit(p.trial.event.TRIALEND,p.trial.pldaps.iTrial);
%         end
%         p.trial.flagNextTrial = true;
%     end
%     
% end

% if p.trial.state == p.trial.stimulus.states.BREAKFIX
%     
%     p.trial.pldaps.goodtrial = false;
%     p.trial.pldaps.breakfix = true;
%     
%     
%     if p.trial.sound.use
%         PsychPortAudio('Start', p.trial.sound.breakfix, 1, [], [], GetSecs + .1);
%         
%         %[startTime endPositionSecs xruns estStopTime] = PsychPortAudio('Stop', pahandle [, waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]);
%         PsychPortAudio('Stop',p.trial.sound.breakfix, 1);
%         
%         %             if p.trial.ttime > p.trial.stimulus.timeBreakFix + p.trial.stimulus.breakFixPenalty
%         
%         %             end
%     end
%     p.trial.flagNextTrial = true;
%   
%   
%end
% end

