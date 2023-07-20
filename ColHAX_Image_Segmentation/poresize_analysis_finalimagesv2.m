% Pore size segmentation for final data by Sayantan Bhattacharya 
clear;
clc;

%% Load file output location (make Analyzed Images Final folder?)
basedir='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/Analyzed Images Final/';
%Load file input location
basedir2='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/';
%basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/Analyzed Images Final/';
%basedir2='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';

% Name hydrogel types
geltype={'4A2C','2A2C','4C','C4','4A'};
%geltype={'HAX30','C2HX30','C6HX30','C4','C4HX20','C4HX30','C4HAX40'};
% Xbar=categorical(geltype);
G=length(geltype);
%trials={'Replicate 1'}; 
trials={'Replicate 1','Replicate 2','Replicate 3'}; %Are there three replicates of each data type or is it run 3 dif times? 
T=length(trials);
ylim=960; %Size of file? 
%ylim=880;
magnification=0.256;%(%pixels/microns)0.404
%magnification=17;%(%pixels/microns)
meanporesize=zeros(G,T,3);
stdporesize=zeros(G,T,3);

savedir=[basedir2,'Results/','segmentimage/']; %Save in the folder we made for files
if ~exist(savedir,'dir')
    mkdir(savedir);
end

%Load images in a loop
for i=1%:G
    for j=1:T

        imagedir=fullfile([basedir,geltype{i},filesep,trials{j}]);

        list_ims=dir(fullfile(imagedir,'*.tif'));
        Nim=length(list_ims);

        for n=1:Nim

            savename=[savedir,geltype{i},'_',trials{j},'_',list_ims(n,1).name(1:end-4)];

            img1=imread([imagedir,filesep,list_ims(n,1).name]);
            img1crop=img1(1:ylim,:);

            img1filtered=entropyfilt(im2double(img1crop),true(7));
            figure;imagesc(img1filtered);

            X=img1crop;
            Idouble = im2double(X); 
            LL=quantile(Idouble(:),0.05);
            UL=quantile(Idouble(:),0.95);
            
            % Adjust data to span data range.
%             X = imadjust(X);
            X = imadjust(X,[LL UL],[]);

            img1filtered2=entropyfilt(X,true(7));
            figure;imagesc(img1filtered2);
%             Xc=imcomplement(X);
            thresh_sens=0.50;
            % Threshold image - adaptive threshold
            BW = imbinarize(X, 'adaptive', 'Sensitivity', thresh_sens, 'ForegroundPolarity', 'bright');
            
            % Invert mask
            BW = imcomplement(BW);

            img1filtered2=entropyfilt(BW,true(7));
            figure;imagesc(img1filtered2);

            %Close mask with disk
            radius = 2;%9,12;
            decomposition = 0;
            se = strel('disk', radius, decomposition);
            BWclose = imclose(BW, se);
            
            % Open mask with disk
            radius = 2;%9,12;
            decomposition = 0;
            se = strel('disk', radius, decomposition);
            BWopen = imopen(BWclose, se);
            img1filtered2=entropyfilt(BWopen,true(7));
            figure;imagesc(img1filtered2);

            figure;
            subplot(2,2,1);imagesc(img1crop);
            subplot(2,2,2);imagesc(BW);
            subplot(2,2,3);imagesc(BWopen);
            subplot(2,2,4);imagesc(BWclose);

            core = erosion_dilation(BW,0,8);
            figure;imagesc(core);

            BWsobel = edge(BW,'sobel');figure;imagesc(BWsobel);title('Sobel');
            BWcanny = edge(BW,'canny');figure;imagesc(BWcanny);title('Canny');
            BWsobel = edge(BW,'zerocross');figure;imagesc(BWsobel);title('Zerocross');
            BWsobel = edge(BW,'log');figure;imagesc(BWsobel);title('Log');
            BWsobel = edge(BW,'prewitt');figure;imagesc(BWsobel);title('prewitt');

            fillcanny=imfill(BWcanny);figure;imagesc(fillcanny);title('fillcanny');


%             S1= im2double(img1crop);
%             figure;imagesc(S1);
%             [~,S] = graycomatrix(S1,'NumLevels',20,'GrayLimits',[],'Offset',[0 1; -1 1;-1 0;-1 -1]);
%             figure;imagesc(S)


%             if i==1
%                 [BW,maskedImage] = segmentImageHAX(img1crop);
%             else
%                 [BW,maskedImage] = segmentImage(img1crop);
%             end
            
%             [label2,meanarea,stddevarea,Numofelem]=poresize_calculate(BW,magnification,img1crop,savename);
%             pause(0.01);
            
            Nvals = [1 2 4 8];
            for mt = 1:length(Nvals)
                [thresh, metric] = multithresh(img1crop, Nvals(mt) );
                disp(['N = ' int2str(Nvals(mt)) '  |  metric = ' num2str(metric)]);
            end

            seg_I = imquantize(img1crop,thresh);
            figure;imagesc(seg_I)

%             meanporesize(i,j,n)=sqrt(meanarea*4/pi)/magnification;
%             stdporesize(i,j,n)=sqrt(stddevarea*4/pi)/magnification;

            meanporesize(i,j,n)=meanarea/magnification;
            stdporesize(i,j,n)=stddevarea/magnification;


        end
    end
end
% keyboard; 
%%
meanporesize1=mean(reshape(meanporesize,G,T*3),2); %GelTypes = 5, trials x3 (why?)
stdporesize1=mean(reshape(stdporesize,G,T*3),2);
errhigh=meanporesize1+stdporesize1;
errlow=meanporesize1-stdporesize1;

Xbar1=categorical({'HAX30','C2HX30','C4HX30','C6HX30'});
Xbar1=reordercats(Xbar1,{'HAX30','C2HX30','C4HX30','C6HX30'});
Xbar2=categorical({'C4','C4HX20','C4HX30','C4HAX40'});
Xbar2=reordercats(Xbar2,{'C4','C4HX20','C4HX30','C4HAX40'});
figure;
bar(Xbar1',meanporesize1([1 2 6 3])); %Whats 1 2 6 3?
hold on;
er = errorbar(Xbar1',meanporesize1([1 2 6 3]),errlow([1 2 6 3]),errhigh([1 2 6 3]));    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off;
set(gca,'FontSize',20);
% print(gcf,'-dpng',[savedir,'poresie_1.png'],'-r200');


figure;
bar(Xbar2',meanporesize1([4 5 6 7]));
hold on;
er = errorbar(Xbar2',meanporesize1([4 5 6 7]),errlow([4 5 6 7]),errhigh([4 5 6 7]));    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
hold off;
set(gca,'FontSize',20);
% print(gcf,'-dpng',[savedir,'poresie_2.png'],'-r200');

%%
function [label2,meanarea,stddevarea,Numofelem]=poresize_calculate(binary_img,magnification,img1crop,savename)
% BW=imbinarize(im2double(img1));
%% Connected components
CC = bwconncomp(binary_img,8);
% CC = bwconncomp(BW,8);
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');
%% plotting
% close all;
% figure(11);imshow(labeloverlay(img1,label2));
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
area1=sqrt(area1*4/pi);%Equivalent Diameter conversion

area1(area1<=0.2*magnification)=[];%remove diameters less than 0.2 microns
area1(area1>=40*magnification)=[];%remove diameters greater than 40 microns

Numofelem=length(area1);
meanarea=mean(area1(2:end));
stddevarea=std(area1(2:end));
% % % medianarea=median(area1(2:end));

figure(12);
% histogram(area1(2:end),0:10:250); 
subplot(1,3,1);imshow(labeloverlay(img1crop,label2));
subplot(1,3,2);imshow(img1crop);hold on;plot((1:10)*magnification+500,500*ones(10,1),'r-','LineWidth',3);hold off;
subplot(1,3,3);histogram(area1/magnification); axis square;
title(['mean diameter=',num2str(meanarea/magnification,'%03.2f')]);
set(gcf,'position',[100,100,900,300]);
% print(gcf,'-dpng',[savename,'_segmented_img_overlay.png']);

if meanarea==0
    keyboard;
end

end
