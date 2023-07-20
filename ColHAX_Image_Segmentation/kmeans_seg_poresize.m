clc;

basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';
casename1={'C4','C6HAX30','HAX'};
Cname=casename1{1};
% img1=imread([basedir,filesep,'C4',filesep,'inv_5000_02.tif']);
% img1=imread([basedir,filesep,'C6HAX30',filesep,'inv_5000_02.tif']);
img1=imread([basedir,Cname,filesep,'inv_5000_02.tif']);

filtimg1=medfilt2(img1,[5 5]);
filtimg2=imgaussfilt(img1,1);

% binary_img=imbinarize(img1);
% 
figure;imagesc(img1);
figure;imagesc(filtimg1);
figure;imagesc(filtimg2);
% figure;imagesc(binary_img);
% imwrite(binary_img,[basedir,Cname,filesep,'Binary_inv_5000_01.tif']);

% BW1 = edge(img1,'Canny');
% BW2 = edge(img1,'Sobel');
% BW3 = edge(img1,'log');

% BW1 = edge(binary_img,'Canny');
% BW2 = edge(binary_img,'Sobel');
% BW3 = edge(binary_img,'log');
% 
% figure;montage({BW1, BW2, BW3});
% keyboard;
%%

% RGB = img1;
% % RGB = imresize(RGB,0.5);
% % figure(1);imshow(RGB);
% [L1,centers] = imsegkmeans(RGB,2,'NormalizeInput',true,"NumAttempts",5,"MaxIterations",200,"Threshold",1e-3);
% CC1 = bwconncomp(L1);
% label1 = labelmatrix(CC1);
% B = labeloverlay(RGB,L1);
% figure(2);imshow(B);
% hold on;imagesc(label1);hold off;
% title('Labeled Image');
% print(gcf,'-dpng',[basedir,Cname,filesep,'kmeans_seg_inv_5000_02.png']);
%%
RGB = filtimg1;
se = offsetstrel('ball',2,2);
% se = offsetstrel('ball',3,3);
% se = strel('octagon',3);
RGB1=imerode(RGB,se);
% RGB1=imclose(RGB,se);
bw=imbinarize(RGB1);
fil1=imfill(bw,'holes');
CC = bwconncomp(fil1);
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');
figure;imagesc(label2);colormap('hot')
% print(gcf,'-dpng',[basedir,Cname,filesep,'labelmatrix2_seg_inv_5000_02.png']);
% area1=sqrt([stats.Area]/pi);
area1=([stats.Area]);
figure;histogram(area1(2:end),0:10:250); 
% print(gcf,'-dpng',[basedir,Cname,filesep,'area_histogram_inv_5000_02.png']);

%%
% % % % wavelength = 2.^(0:2) * 2;
% % % % orientation = 0:45:135;
% % % % g = gabor(wavelength,orientation);
% % % % I = im2gray(im2single(RGB));
% % % % gabormag = imgaborfilt(I,g);
% % % % % figure(3);montage(gabormag,'Size',[4 6]);
% % % % 
% % % % % for i = 1:length(g)
% % % % %     sigma = 0.5*g(i).Wavelength;
% % % % %     gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),3*sigma); 
% % % % % end
% % % % % figure(4);montage(gabormag,'Size',[4 6]);
% % % % 
% % % % nrows = size(RGB,1);
% % % % ncols = size(RGB,2);
% % % % [X,Y] = meshgrid(1:ncols,1:nrows);
% % % % featureSet = cat(3,I,gabormag,X,Y);
% % % % L2 = imsegkmeans(featureSet,2,'NormalizeInput',true,"NumAttempts",5,"MaxIterations",200,"Threshold",1e-3);
% % % % C = labeloverlay(RGB,L2);
% % % % figure(5);imshow(C)
% % % % title('Labeled Image with Additional Pixel Information')
% % % % % print(gcf,'-dpng',[basedir,Cname,filesep,'gabor_kmeans_seg_inv_5000_02.png']);
