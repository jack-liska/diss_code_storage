function p = pmEncoder(p, state, sn)

% module that initializes and controls the encoder and records position

% requires these values to be defined:
%   p.trial.encoder.port - port to initialize treadmill on
%   p.trial.encoder.scaleFactor - conversion factor from encoder ticks to
%   irl distance
%   p.trial.encoder.frameInterval - number of frames between encoder reads

switch state
    
    % frame states
    case p.trial.pldaps.trialStates.frameUpdate
        
        %% position update

        % Only check if lastCheck frames have passed
        if p.trial.(sn).use && p.trial.(sn).lastCheck > p.trial.(sn).frameInterval
           
            % Get current position data
            posRaw = pds.encoder.getPos(p, sn);
            if ~isempty(posRaw)
                % get new encoder position and apply offset from beginning
                % of trial
                p.trial.locationSpace(1, p.trial.iFrame)=posRaw-p.trial.(sn).offset;
                % Apply a scaling factor to go from encoder ticks to irl
                % distance
                p.trial.locationSpace(2, p.trial.iFrame)= p.trial.locationSpace(1,p.trial.iFrame) * p.trial.(sn).scaleFactor;
            else
                % Keep last value if you don't get anything from a new read
                p.trial.locationSpace(1, p.trial.iFrame) = p.trial.locationSpace(1, end);
                p.trial.locationSpace(2, p.trial.iFrame)= p.trial.locationSpace(1, p.trial.iFrame) * p.trial.(sn).scaleFactor;
            end
                      
            p.trial.wheel.lastCheck = 0;
            
            %% plot & Update trace for debugging
%             trace=p.trial.(sn).trace;
%             trace = circshift(trace,-1);
%             trace(end)=p.trial.locationSpace(1,p.trial.iFrame);
%             p.trial.(sn).trace=trace;
%             
%             axes(p.trial.(sn).traceax);
%             plot(p.trial.(sn).trace);
            
            
        else
            p.trial.(sn).lastCheck=p.trial.(sn).lastCheck+1;
        end
        
    case p.trial.pldaps.trialStates.framePrepareDrawing
        
    case p.trial.pldaps.trialStates.frameDraw
        
        
        % trial states
        
    case p.trial.pldaps.trialStates.trialPrepare
        
        % expt states
        
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        config = 'BaudRate=115200 DTR=1 RTS=1 ReceiveTimeout=1';
        %DataBits=6 StopBit=1
        oldverbo = IOPort('Verbosity',0);
        [encoder, errmsg] = IOPort('OpenSerialPort', p.trial.(sn).port, config);
        IOPort('Verbosity', oldverbo);

        if encoder < 0
            % if fails to open port, IOPort will return an invalid (-1) handle to signal the failure
            fprintf(2, '\n~!~\tUnable to open wheel com on port: %s\n\t%s\tWill attempt to continue with wheel disabled (p.trial.(sn).use=0)\n',p.trial.wheel.port, errmsg);
            p.trial.(sn).use = false;
            return
        end
        
        WaitSecs(0.1);
        if ~isempty(errmsg)
            error('pds:encoder:setup', 'Failed to open serial Port with message:\n\t%s\n', errmsg);
        end
        
        p.trial.(sn).name = encoder;
        
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
               
        [data, when, errmsg]=IOPort('Read', p.trial.(sn).name);
        
        if ~isempty(data)
            Pos_index=str2num(char(data));
            p.trial.(sn).offset = Pos_index(end,1);
        else
            fprintf('No initial signal from wheel, assuming zero offset (NOTE: wheel only sends signal on movement)\n')
            p.trial.(sn).offset = 0; % If this becomes a problem, we should put in a function to ask the board for a value
        end

        p.trial.locationSpace = p.trial.(sn).offset; %initialise wheel position
        p.trial.(sn).lastCheck=0;
        p.trial.locationSpace = [0;0];
        p.trial.(sn).samples=0; 
        p.trial.(sn).samplesTimes=[];
        p.trial.(sn).wheelSamples=[];

        %Trace tracking figure
%         p.trial.(sn).trace=zeros(1,100);
%         p.trial.(sn).tracefig=figure;
%         plot(p.trial.(sn).trace);
%         p.trial.(sn).traceax=gca;
        
    case p.trial.pldaps.trialStates.experimentCleanUp
        
        if p.trial.(sn).use
        try
            IOPort('close', p.trial.(sn).port)
        end
        
        end
end