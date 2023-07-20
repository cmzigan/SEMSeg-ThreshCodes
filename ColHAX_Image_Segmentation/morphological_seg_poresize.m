% clc;
close all;
basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';
casename1={'C4','C6HAX30','HAX'};
Cname=casename1{3};
% img1=imread([basedir,filesep,'C4',filesep,'inv_5000_02.tif']);
% img1=imread([basedir,filesep,'C6HAX30',filesep,'inv_5000_02.tif']);
img1=imread([basedir,Cname,filesep,'inv_5000_02.tif']);

%Median filtering image
% filtimg1=imsharpen(img1);
% filtimg2=medfilt2(img1,[3 3]);
% filtimg1=imadjust(filtimg2,[0 1],[0 1],1);

% filtimg1=imadjust(img1);

% filtimg1=imadjust(img1,[0 1],[0 1],1);
filtimg1=adapthisteq(img1);
% filtimg1=adapthisteq(filtimg2);

%Binarize image
% binary_img=imbinarize(filtimg1,'adaptive','Sensitivity',0.7);
binary_img=imbinarize(filtimg1);
% figure;imagesc(binary_img);title('Binarized Image');
% 
% figure;montage({img1, filtimg1})
% figure;imagesc(binary_img);
% imwrite(binary_img,[basedir,Cname,filesep,'Binary_inv_5000_02.tif']);

% figure;montage({BW1, BW2, BW3});
% keyboard;
%% Image erosion and filling


% seD = strel('diamond',1);
seD = strel('disk',1);
img_erode = imerode(binary_img,seD);
% img_erode = imerode(filtimg1,seD);
% figure;imagesc(img_erode);title('Eroded Binarized Image');
% imwrite(img_erode,[basedir,Cname,filesep,'Eroded_Binary_inv_5000_02.tif']);


% img_clearb = imclearborder(img_erode,4);
% figure;imagesc(img_clearb);

% binary_img=imbinarize(img_erode);
% figure;imagesc(binary_img)

% img_fill=imfill(binary_img,8,'holes');
% figure;imagesc(img_fill);

% img_fill=imfill(img_erode,8,'holes');
% img_clearb = imclearborder(img_erode,4);
% img_clearb = imclearborder(binary_img,4);
% figure;imagesc(img_fill);


% pre_processed_img=img_clearb;
pre_processed_img=img_erode;
% pre_processed_img=img_fill;
%% Connected components
CC = bwconncomp(pre_processed_img,8);
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');
%% plotting
% close all;
% figure;imshow(labeloverlay(img1,label2));
figure;imshow(label2rgb(label2,'jet','k','shuffle'));
title('Connected Components Over Original Image')
% print(gcf,'-dpng',[basedir,Cname,filesep,'labelmatrix_new2_seg_inv_5000_02.png']);

% BWoutline = bwperim(label2);
% Segout = img1; 
% Segout(BWoutline) = 255; 
% figure;imshow(Segout)
% title('Outlined Original Image')
% figure;imagesc(label2);colormap('hot')
% print(gcf,'-dpng',[basedir,Cname,filesep,'labelmatrix2_seg_inv_5000_02.png']);
% area1=sqrt([stats.Area]/pi);
area1=([stats.Area]);
length(area1)
area1(area1<=5)=[];
area1(area1>=1000000)=[];
length(area1)
figure;histogram(area1(2:end),0:10:250); 
meanarea=mean(area1(2:end));
medianarea=median(area1(2:end));
title(['median area=',num2str(meanarea,'%03.2f')]);
% print(gcf,'-dpng',[basedir,Cname,filesep,'area_new_histogram_inv_5000_02.png']);
