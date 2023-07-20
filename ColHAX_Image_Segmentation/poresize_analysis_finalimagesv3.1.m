% Pore size segmentation for final data by Sayantan Bhattacharya 
clear;
% clc;

%% Load file output location (make Analyzed Images Final folder?) and name samples
%Load file input location
basedir='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/Analyzed Images Final/';
%Load file input location
basedir2='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/';
%basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/Analyzed Images Final/';
%basedir2='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';
% SAMPLE NAMES
geltype={"2A2C","4A","4A2C-2001","4A2C-2011","4C"};
%geltype={'HAX30','C2HX30','C6HX30','C4','C4HX20','C4HX30','C4HAX40'};
% Xbar=categorical(geltype);
G=length(geltype);
trials={"Replicate 1"}; %Are there three replicates of each data type or is it run 3 dif times? 
%trials={'Replicate 1','Replicate 2','Replicate 3'}; %Are there three replicates of each data type or is it run 3 dif times? 
T=length(trials);
ycrop=892; % y-axis pixel size of file?
%ycrop=880; 
magnification=0.504;%(%pixels/microns)0.404
%magnification=17;%(%pixels/microns)
meanporesize=zeros(G,T);
stdporesize=zeros(G,T);
%poresize=cell(G,T); Removed as we are storing this as a flatten array

excelcol={'A2','B2','C2'}; %WHY DID YOU MAKE THIS STATIC THIS SHOULD BE DYNAMIC BASED ON NUM OF GELS

excelcellnames = {"Replicate", "Mean","Standard Deviation"};

savedir=[basedir2,'/Results'];
if ~exist(savedir,'dir')
    mkdir(savedir);
end

%Load images in a loop
for i=1:G
    for j=1:T

        %imagedir=fullfile([basedir,geltype{i},filesep,trials{j}]);
        imagedir = basedir;
        list_ims=dir(fullfile(imagedir, geltype{i} + '.tif'));
        Nim=length(list_ims);
%         writecell(trials(j),'poresize.xlsx','Sheet',geltype{i},'WriteMode','append')
        writecell(trials(j),'poresize2.xlsx','Sheet',geltype{i},'Range','A1:E1') %Moved from line 75Removed ,'WriteMode','append', added 'Range','A1:C1'
        for n=1:Nim

            savename= fullfile(savedir,'/segmentimage/',geltype{i} + "_" + trials{j} + "_" + list_ims(n,1).name(1:end-4));
            
            img1=imread([imagedir,filesep,list_ims(n,1).name]);
            img1crop=img1(1:ycrop,:);


            [BW,maskedImage] = segmentImage(img1crop);
% %             figure;imagesc(~maskedImage);
% % 
% %             img1filtered2=stdfilt(im2double(img1crop),true(5));
% %             img1filtered2(img1filtered2<0.05)=0;
% %             figure;imagesc(img1filtered2);
% %             img1filtered2=stdfilt(im2double(imadjust(img1crop)),true(5));
% %             img1filtered2(img1filtered2<0.05)=0;
% %             figure;imagesc(img1filtered2);

            [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});

            meanporesize(i,j)=meanarea/magnification;
            stdporesize(i,j)=stddevarea/magnification;
            poresize =deq/magnification;

            % Creating PoreSize Excel File
            flattenporesize = reshape(poresize,[],1);
            writematrix(flattenporesize(:),'poresize2.xlsx','Sheet',geltype{i}, 'Range','A2:A500') %Should not be done this way but matlab
            %is not appending properly to the file. 

            % Creating Poresize Statistics Excel
            writecell(excelcellnames.',fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','A1:A3')
            writecell(trials(j),fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B1')
            writematrix(meanporesize(i,j),fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B2')
            writematrix(stdporesize(i,j),fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B3')

        end

    

    end
end
% keyboard;
% save([savedir,'poresize_allimages.mat'],'poresize');
%%
%meanporesizearray=reshape(meanporesize,G,T);
%meanporesize1=mean(meanporesizearray,2);
%meanporesize1(1)=mean(meanporesizearray(1,1:8));

%stdporesizearray=reshape(stdporesize,G,T);
%stdporesize1=mean(stdporesizearray,2);
%stdporesize1(1)=mean(stdporesizearray(1,1:8));

%errhigh=stdporesize1;
%errlow=stdporesize1;

%Xbar1=categorical({'HAX30','C2HX30','C4HX30','C6HX30'});
%Xbar1=reordercats(Xbar1,{'HAX30','C2HX30','C4HX30','C6HX30'});
%Xbar2=categorical({'C4','C4HX20','C4HX30','C4HAX40'});
%Xbar2=reordercats(Xbar2,{'C4','C4HX20','C4HX30','C4HAX40'});
%figure; %MAKE FIGURE 1 WITH DIF MIXES IN HAX
%bar(Xbar1',meanporesize1([1 2 6 3]));
%hold on;
%er = errorbar(Xbar1',meanporesize1([1 2 6 3]),errlow([1 2 6 3]),errhigh([1 2 6 3]));    
%er.Color = [0 0 0];                            
%er.LineStyle = 'none';
%er.LineWidth=3;
%hold off;
%ylabel('Pore Size (\mum)');
%ylim([0 10]);
%set(gca,'FontSize',20);
%% print(gcf,'-dpng',[savedir,'poresie_1.png'],'-r200');

%figure; %MAKE FIGURE 2 WITH DIF MIXES IN C4
%bar(Xbar2',meanporesize1([4 5 6 7]));
%hold on;
%er = errorbar(Xbar2',meanporesize1([4 5 6 7]),errlow([4 5 6 7]),errhigh([4 5 6 7]));    
%er.Color = [0 0 0];                            
%er.LineStyle = 'none';  
%er.LineWidth=3;
%hold off;
%ylabel('Pore Size (\mum)');
%ylim([0 10]);
%set(gca,'FontSize',20);
%% print(gcf,'-dpng',[savedir,'poresie_2.png'],'-r200');
%%
% geltype
%[meanporesize1 stdporesize1]

% save([savedir,'poresize_allimages.mat'],'poresize','meanporesize1','stdporesize1');
%%
function [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(binary_img,magnification,img1crop,savename,geltype)
% BW=imbinarize(im2double(img1));
%% Connected components
CC = bwconncomp(binary_img,8);
% CC = bwconncomp(BW,8);
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');

area1=([stats.Area]);
area1=sqrt(area1*4/pi);%Equivalent Diameter conversion

area1(area1<=0.2*magnification)=[];%remove diameters less than 0.3 microns
area1(area1>=100*magnification)=[];%remove diameters greater than 100 microns

Numofelem=length(area1);
meanarea=mean(area1(1:end));
stddevarea=std(area1(1:end));
deq=area1;

%% plotting
figure(12);
tiledlayout(1,3,'TileSpacing','tight');
% histogram(area1(2:end),0:10:250); 
nexttile;imshow(labeloverlay(img1crop,label2));
nexttile;imshow(img1crop);hold on;plot((1:10)*magnification+500,500*ones(10,1),'r-','LineWidth',3);hold off;
title(geltype);
bins1=0:10:100;
nexttile;histogram(area1/magnification,bins1); axis square;
title(['mean diameter=',num2str(meanarea/magnification,'%03.2f'),'\mum']);
% set(gcf,'position',[100,100,900,300]);
set(gcf,'position',[100,700,1200,600]);
savefig(savename)
% print(gcf,'-dpng',[savename,'_segmented_img_overlay.png']);

% img1filtered2=entropyfilt(img1crop,true(3));
% figure;imagesc(img1filtered2);

if meanarea==0
    keyboard;
end

end

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
