loc = '135Degree';
dest = '3FaceBars135Deg20200109';

cd (loc);

for i=1:length(dir)-1
    a = imread(strcat(num2str(i),' shot.png'));
    a = rgb2gray(a);
    cd ../;
    cd (dest);
    save(strcat(num2str(i),' shot.mat'),'a');
    cd ../;
    cd (loc);
end

cd(dest);

for i=1:(length(dir('*.mat'))-1)
    load(strcat(num2str(i+1),' shot.mat'));
    if(i == 1) 
        allShots = a;
    else 
        allShots(:,:,i) = a;
    end 
    
end

save('allShots.mat','allShots', '-v7.3');