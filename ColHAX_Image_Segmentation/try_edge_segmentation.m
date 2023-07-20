clc;close all;
imgdir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/Analyzed Images Final/HAX30/Replicate 1/1l2_003.tif';

I = imread(imgdir);
I=I(1:880,:);
I=adapthisteq(I);
figure;imshow(I)
title('Original Image');
%%
[Gmag, Gdir] = imgradient(I,'central');
figure;imshowpair(Gmag, Gdir, 'montage');
I=Gdir;
%%
[~,threshold] = edge(I,'canny');
fudgeFactor = 1;
BWs = edge(I,'canny',threshold * fudgeFactor);
%Display the resulting binary gradient mask.
figure;imshow(BWs)
title('Binary Gradient Mask')
%%
se90 = strel('line',3,90);
se0 = strel('line',3,0);
% Dilate the binary gradient mask using the vertical structuring element followed by the horizontal structuring element. 
% The imdilate function dilates the image.
BWsdil = imdilate(BWs,[se90 se0]);
figure;imshow(BWsdil)
title('Dilated Gradient Mask')
%%
BWdfill = imfill(BWsdil,'holes');
figure;imshow(BWdfill)
title('Binary Image with Filled Holes')
%%
BWnobord = BWdfill;%imclearborder(4);
% BWnobord = imclearborder(BWdfill,4);
figure;imshow(BWnobord)
title('Cleared Border Image')
%%
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
figure;imshow(BWfinal)
title('Segmented Image');
%%
figure;imshow(labeloverlay(I,BWfinal))
title('Mask Over Original Image')
