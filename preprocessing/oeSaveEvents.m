function oeSaveEvents(inDir, name, exptDate, outDir, RecNumber)
%% Read in events from open ephys kwik file

% name=[name(1:end-12) '.kwe'];
filename=[inDir filesep name];

%% save out digital events
%load events only
	timestamps = hdf5read(filename, '/event_types/TTL/events/time_samples');
    highlow = hdf5read(filename, '/event_types/TTL/events/user_data/eventID');
    bitNumber = hdf5read(filename, '/event_types/TTL/events/user_data/event_channels');

    % timestamps=[timestamps]

    strobeSet=find(bitNumber==7 & highlow==1);
    strobeUnset=find(bitNumber==7 & highlow==0);
    strobeUnset=[1; strobeUnset];

    value=nan(size(strobeSet));
    for iStrobe=1:length(strobeSet)
         ts=timestamps <= timestamps(strobeSet(iStrobe)) & timestamps >= timestamps(strobeUnset(iStrobe)) & bitNumber~=7;
         value(iStrobe)=sum(2.^bitNumber(ts) .* highlow(ts));
    end

    eventTimes=double(timestamps(strobeSet));
    eventValues = value;
    flagBits = nan(size(value));
    flagData = value;
    invertedBits = false;
    switchbits = false;
    
    %eventSamples depends on recording number.
    location='/recordings';
    info=h5info([inDir filesep name],location);
    nRecs=length(info.Groups);
    for iRec=1:nRecs
        iRecNumber=(info.Groups(iRec).Name(13:end));
        if str2num(iRecNumber)==RecNumber
            %toutDir=([outDir '_R' iRecNumber]);
            
            st_index=strcmp('start_time',{info.Groups(iRec).Attributes.Name});
            recStartTime = double(info.Groups(iRec).Attributes(st_index).Value);
            eventSamples=eventTimes-recStartTime;
            
            %save([toutDir filesep name(1:end-4) '_events.mat'], 'eventTimes', 'eventSamples', 'eventValues', 'flagBits', 'flagData', 'invertedBits', 'switchbits','recStartTime');
            save([outDir filesep 'events_' exptDate '.mat'], 'eventTimes', 'eventSamples', 'eventValues', 'flagBits', 'flagData', 'invertedBits', 'switchbits','recStartTime');
        end
    end
