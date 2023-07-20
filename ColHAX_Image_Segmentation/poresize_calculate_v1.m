function [label2,meanarea,stddevarea,Numofelem]=poresize_calculate_v1(img1)

%convert to double
% S= imcomplement(entropyfilt(im2double(img1),strel('disk',9).Neighborhood));
% S1= im2double(img1);
% [~,S] = graycomatrix(S1,'NumLevels',20,'GrayLimits',[],'Offset',[0 1; -1 1;-1 0;-1 -1]);
S= im2double(img1);

% Gray_Image = (S-min(S(:)))./(max(S(:))-min(S(:)));
% Enhanced_Image = adapthisteq(Gray_Image, 'numTiles', [8 8], 'nBins', 128,'ClipLimit', 0.1);
% IG = imgaussfilt(Enhanced_Image,3);
% Enhanced_Image=Gray_Image;
% figure;imagesc(Enhanced_Image);
% binary_img=imbinarize(Enhanced_Image);
% binary_img=imbinarize(IG);

binary_img=imbinarize(S);

% % Avg_Filter = fspecial('average', [81 81]);
% % Filtered_Image = imfilter(Enhanced_Image, Avg_Filter);
% % % figure, imshow(Filtered_Image)
% % % title('Filtered Image');
% % 
% % Substracted_Image = imsubtract(Filtered_Image,Enhanced_Image);

% % binary_img=imbinarize(Substracted_Image);


% Clean_Image = (bwareaopen(binary_img, 150));

% figure; imshow(binary_img);title('binary img');


% seD = strel('disk',1);
% img_dilate=imdilate(binary_img,seD);
% figure; imshow(img_dilate);title('img_dilate');
% 
% seE = strel('disk',1);
% img_erode = imerode(img_dilate,seE);
% figure; imshow(img_erode);title('img_erode');
% 
% pre_processed_img=img_erode;
% pre_processed_img=bwareaopen(binary_img,17);%binary_img;
pre_processed_img=binary_img;

% Clean_Image = imclose(binary_img, seD1);
% figure; imshow(Clean_Image);title('Clean Image');

% binary_img_comp=Clean_Image;

% binary_img_comp = imcomplement(binary_img);
% figure; imshow(binary_img_comp)
% title('binary_img_comp');

% % [B,L] = bwboundaries(pre_processed_img,'noholes');
% % figure;imshow(label2rgb(L, @jet, [.5 .5 .5]))
% % hold on
% % for k = 1:length(B)
% %    boundary = B{k};
% %    if size(boundary,1)>2
% %     plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);
% %    end
% % end
% % hold off;
%Median filtering image
% filtimg1=adapthisteq(img1);
% filtimg1=medfilt2(filtimg2,[5 5]);
%Binarize image
% binary_img=imbinarize(filtimg1,'adaptive','Sensitivity',0.7);
% % binary_img=imbinarize(filtimg1);
% figure;imagesc(binary_img);title('Binarized Image');

%% Image erosion and filling


% seD = strel('diamond',1);
% seD = strel('disk',1);
% img_erode = imerode(binary_img_comp,seD);
% img_erode = imerode(filtimg1,seD);
% figure;imagesc(img_erode);title('Eroded Binarized Image');
% imwrite(img_erode,[basedir,Cname,filesep,'Eroded_Binary_inv_5000_02.tif']);


%% Connected components
CC = bwconncomp(pre_processed_img,8);
% CC = bwconncomp(L,8);
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');
%% plotting
% close all;
figure(11);imshow(labeloverlay(img1,label2));
% % figure(11);imshow(img1);
% % hold on;
% % imshow(label2rgb(label2,'jet','k','shuffle'));
% % title('Connected Components Over Original Image');
% % hold off;
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
area1(area1<=17)=[];
area1(area1>=50*170)=[];

Numofelem=length(area1);
meanarea=mean(area1(2:end));
stddevarea=std(area1(2:end));
% % % medianarea=median(area1(2:end));

% figure;histogram(area1(2:end),0:10:250); 
% title(['mean area=',num2str(meanarea,'%03.2f')]);
% print(gcf,'-dpng',[basedir,Cname,filesep,'area_new_histogram_inv_5000_02.png']);

if meanarea==0
    keyboard;
end

end
