%Kmeans_segmentation
RGB = imread('kobi.png');
RGB = imresize(RGB,0.5);
figure(1);imshow(RGB);
L = imsegkmeans(RGB,2);
B = labeloverlay(RGB,L);
figure(2);imshow(B)
title('Labeled Image');
wavelength = 2.^(0:5) * 3;
orientation = 0:45:135;
g = gabor(wavelength,orientation);
I = im2gray(im2single(RGB));
gabormag = imgaborfilt(I,g);
figure(3);montage(gabormag,'Size',[4 6]);
for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),3*sigma); 
end
montage(gabormag,'Size',[4 6]);
nrows = size(RGB,1);
ncols = size(RGB,2);
[X,Y] = meshgrid(1:ncols,1:nrows);
featureSet = cat(3,I,gabormag,X,Y);
L2 = imsegkmeans(featureSet,2,'NormalizeInput',true);
C = labeloverlay(RGB,L2);
figure(4);imshow(C)
title('Labeled Image with Additional Pixel Information')
