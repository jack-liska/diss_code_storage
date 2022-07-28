x = spatialPattern([1000 3000],-1);
xMin = min(x);
xMin = min(xMin);
xMax = max(x);
xMax = max(xMax);
xImage = mat2gray(x, [xMin xMax]);
imshow(xImage);

fs = 10000;
dt = 1/fs;
StopTime = 1; 
t = (0:dt:StopTime)';
F = 60; 
data = sin(2*pi*F*t);
plot(t,data)
T = 4*(1/F) ;
tt = 0:dt:T+dt ;
d = sin(2*pi*F*tt) ;
dMin = min(d);
dMin = min(dMin);
dMax = max(d);
dMax = max(dMax);
vertWaves = mat2gray(d, [dMin dMax]);
plot(tt,vertWaves);

for i=1:1000
    for j=1:length(vertWaves)
        xImage(i, (1249+j)) = vertWaves(j);
    end
end
imshow(xImage);
imwrite(xImage,'pinkNoisePlusBars.png');