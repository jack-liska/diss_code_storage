%%%treadmill corridor stimulus generation

%generate pink noise
justNoise = spatialPattern([1000 1000],-1);
justNoise = mat2gray(justNoise,[min(min(justNoise)) max(max(justNoise))]);

%generate sine wave of desired frequency
t = (0:1/2000:1);
numCycles = 20; 
sines = sin(2*pi*numCycles*t);

%add sine to preallocated matrix

%vertical bars
bars = zeros(1000, 1000);
for i=1:1000
    for j=1:1000
        bars(i, j) = sines(j);
    end
end

justBars = mat2gray(bars, [min(min(bars)) max(max(bars))]);

%slap both together and save out
noisePlusBars = [justNoise, justBars];
filename = sprintf('0_degrees_%s.png', datestr(now,'yyyymmdd_HHMM'));
imwrite(noisePlusBars, filename);

%arbitrary rotation code goes here


%45 degree angled bars
bars = zeros(1000, 1000);
for i=1:1000
    for j=1:1000
        bars(i, j) = sines(j+i);
    end
end

justBars = mat2gray(bars, [min(min(bars)) max(max(bars))]);

noisePlusBars = [justNoise, justBars];
filename = sprintf('45_degrees_%s.png', datestr(now,'yyyymmdd_HHMM'));
imwrite(noisePlusBars, filename);

%90 degree angled bars
bars = zeros(1000, 1000);
for i=1:1000
    for j=1:1000
        bars(j, i) = sines(j);
    end
end

justBars = mat2gray(bars, [min(min(bars)) max(max(bars))]);

noisePlusBars = [justNoise, justBars];
filename = sprintf('90_degrees_%s.png', datestr(now,'yyyymmdd_HHMM'));
imwrite(noisePlusBars, filename);

%135 degree angled bars
bars = zeros(1000, 1000);
for i=1:1000
    for j=1:1000
        bars(i, j) = sines(j+i);
    end
end

bars = rot90(bars);

justBars = mat2gray(bars, [min(min(bars)) max(max(bars))]);

noisePlusBars = [justNoise, justBars];
filename = sprintf('135_degrees_%s.png', datestr(now,'yyyymmdd_HHMM'));
imwrite(noisePlusBars, filename);

%imshow(noisePlusBars)
