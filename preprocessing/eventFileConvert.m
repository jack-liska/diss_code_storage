loadDir = '/media/jack/DATA/gruData/Gru/20210128/Events';
outDir = '/media/jack/DATA/gruData/Gru/20210128/Events/Converted';
RecNumber=0;

a=dir(loadDir);
a=a([a.isdir]);
a=a(~cellfun(@isempty,(regexp({a.name},'^\D+_(\d+)-(\d+)-(\d+)_(\d+)-(\d+)-(\d+)_.*'))));
aId=cellfun(@(x) regexp(x,'^\D+_(\d+)-(\d+)-(\d+)_(\d+)-(\d+)-(\d+)_.*','tokens'),{a.name});
% make date directory for this date
mkdir(outDir);

for iDir=6:length(a)
    %thisdate=a(iDir).name;
    srcFolder=a(iDir).name;
    exptDate=sprintf('%s-%s-%s_%s-%s-%s',aId{iDir}{1},aId{iDir}{2},aId{iDir}{3},aId{iDir}{4},aId{iDir}{5},aId{iDir}{6});
    %da=datenum([thisdate ' 08:00'],'yyyymmdd HH:MM');
    fprintf(2,'Starting to convert session %s (%i of %i)\n',outDir, iDir, length(a));
    % save processed kwe file as mat file for clock syncing later
    kweFile = dir([loadDir filesep srcFolder filesep '*.kwe*']);
    %assert(length(kweFile)==1, sprintf('There should be exactly one file with ending *.kwe in %s',[loadDir filesep srcFolder]))
    if length(kweFile)==1
        oeSaveEvents([loadDir filesep srcFolder], kweFile.name, exptDate , outDir, RecNumber);
    else
        sprintf('%s',exptDate)
    end
end
