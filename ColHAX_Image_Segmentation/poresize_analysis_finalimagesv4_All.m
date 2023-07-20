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
%geltype={"2A2C","4A","4A2C-2001","4A2C-2011","4C","4C - 250","4C - 10K"};
geltype={"2A2C","4A","4A2C","4C"};
%geltype={'HAX30','C2HX30','C6HX30','C4','C4HX20','C4HX30','C4HAX40'};
% Xbar=categorical(geltype);
G=length(geltype);
%trials={"Replicate 1"}; 
%trials={'Replicate 1','Replicate 2','Replicate 3','Replicate 4'}; %Three biological replicates of data  

%T=length(trials);
ycrop=892; % y-axis pixel size of file
%ycrop=880; 
magnification = 0.504;%(%pixels/microns)- this is for 50X - 504 pixels/ mm
magnification2 = 2.52; %(%pixels/microns) specifically for collagen 250X - 2.52 pixels/ um
magnification3 = 100.8; %(%pixels/microns) specifically for collagen 10,000X - 504 pixels/ mm
%magnification=17;%(%pixels/microns)
%meanporesize=zeros(G,T);
%stdporesize=zeros(G,T); 

%% Save file portion 
excelcol={'A2','B2','C2'}; %WHY DID YOU MAKE THIS STATIC THIS SHOULD BE DYNAMIC BASED ON NUM OF GELS

excelcellnames = {"Replicate", "Mean","Standard Deviation"};

savedir=[basedir2,'/Results'];
if ~exist(savedir,'dir')
    mkdir(savedir);
end

%% Load images in a loop
for i=1:G
    sampledir = fullfile(basedir+geltype{i}); %go to subfolder with dif samples
    %trialsdir = dir([sampledir '/*.tif']); %directory of tif files in folder
    trialsdir = dir(fullfile(sampledir, '*.tif')); %make var with tif files 
    T = length(trialsdir); %count number of files in folder so replicates number changes %try numel if not
    meanporesize=zeros(T);
    stdporesize=zeros(T);
    poresize=zeros(2000,T);%large number to make sure nothing gets cut off
    %MAKE SURE TO REMOVE 0s LATER BEFORE STATS 
    %poresize = zeros(length(i));
    %trialnames = cell(T);
    %trialnames(:) = trialsdir.name;
    %writematrix(trialsnames.','poresize2.xlsx','Sheet',geltype{i},'Range','A1:E1');
    for j=1:T
        
        %for n=1:Nim
        %save figures in this folder
        savename= fullfile(savedir,'/segmentimage/',geltype{i} + "_" + trialsdir(j,1).name(1:end-4)+'.fig');% end-4 removes .tif
        img1=imread([trialsdir(j,1).folder,filesep,trialsdir(j,1).name]);
        img1crop=img1(1:ycrop,:);

        if i <= 3
            %Smaller mask
            [BW,maskedImage] = segmentImage5(img1crop);
            %Magnification 1 for 50X AgCol
            [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});
            %imshow(originalImage);
            meanporesize(i,j)=meanarea/magnification;
            stdporesize(i,j)=stddevarea/magnification;
            poresize_indv =deq/magnification;
            poresize_indvlen = length(poresize_indv);
            poresize(1:poresize_indvlen,j) = poresize_indv;
        elseif i == 4 && j == 1
            %Larger mask
            [BW,maskedImage] = segmentImage(img1crop);
            %Magnification 3 for 10K collagen
            [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification3,img1crop,savename,geltype{i});
            meanporesize(i,j)=meanarea/magnification3;
            stdporesize(i,j)=stddevarea/magnification3;
            poresize_indv =deq/magnification3;
            poresize_indvlen = length(poresize_indv);
            poresize(1:poresize_indvlen,j) = poresize_indv;
        else 
            %Larger mask
            [BW,maskedImage] = segmentImage(img1crop);
            %Magnification 2 for 250K collagen
            [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification2,img1crop,savename,geltype{i});
            meanporesize(i,j)=meanarea/magnification2;
            stdporesize(i,j)=stddevarea/magnification2;
            poresize_indv =deq/magnification2;
            poresize_indvlen = length(poresize_indv);
            poresize(1:poresize_indvlen,j) = poresize_indv;
        end 

    end
            writematrix(poresize(:,:),'poresize2.xlsx','Sheet',geltype{i}, 'Range','A2:E2000')
            % Creating Poresize Statistics Excel
            % writecell(excelcellnames.',fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','A1:A10')
            % writematrix(trialsdir.name,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B1:E1')
            % writematrix(meanporesize,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B2:E2')
            % writematrix(stdporesize,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B3:E3')

end
% keyboard;
% save([savedir,'poresize_allimages.mat'],'poresize');
% %% Compares avg and standard dev of the three replicates
% meanporesizearray=reshape(meanporesize,G,T);
% meanporesize1=mean(meanporesizearray,2);
% meanporesize1(1)=mean(meanporesizearray(1,1:8));
% 
% stdporesizearray=reshape(stdporesize,G,T);
% stdporesize1=mean(stdporesizearray,2);
% stdporesize1(1)=mean(stdporesizearray(1,1:8));
% 
% errhigh=stdporesize1;
% errlow=stdporesize1;
% 
% Xbar1=categorical({'HAX30','C2HX30','C4HX30','C6HX30'});
% Xbar1=reordercats(Xbar1,{'HAX30','C2HX30','C4HX30','C6HX30'});
% Xbar2=categorical({'C4','C4HX20','C4HX30','C4HAX40'});
% Xbar2=reordercats(Xbar2,{'C4','C4HX20','C4HX30','C4HAX40'});
% figure; %MAKE FIGURE 1 WITH DIF MIXES IN HAX
% bar(Xbar1',meanporesize1([1 2 6 3]));
% hold on;
% er = errorbar(Xbar1',meanporesize1([1 2 6 3]),errlow([1 2 6 3]),errhigh([1 2 6 3]));    
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';
% er.LineWidth=3;
% hold off;
% ylabel('Pore Size (\mum)');
% ylim([0 10]);
% set(gca,'FontSize',20);
% % print(gcf,'-dpng',[savedir,'poresie_1.png'],'-r200');
% 
% figure; %MAKE FIGURE 2 WITH DIF MIXES IN C4
% bar(Xbar2',meanporesize1([4 5 6 7]));
% hold on;
% er = errorbar(Xbar2',meanporesize1([4 5 6 7]),errlow([4 5 6 7]),errhigh([4 5 6 7]));    
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% er.LineWidth=3;
% hold off;
% ylabel('Pore Size (\mum)');
% ylim([0 10]);
% set(gca,'FontSize',20);
% % print(gcf,'-dpng',[savedir,'poresie_2.png'],'-r200');
% %
% %geltype
% %[meanporesize1 stdporesize1]
% 
% % save([savedir,'poresize_allimages.mat'],'poresize','meanporesize1','stdporesize1');
%% Make colored blobs in a mask, based off of connected components
%CHANGE MAG FOR THE THREE DIF OPTIONS
function [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(binary_img,magnification,img1crop,savename,geltype)
% BW=imbinarize(im2double(img1));
% CONNECTED COMPONENTS
CC = bwconncomp(binary_img,8);
% CC = bwconncomp(BW,8);
%boundaries = bwboundaries(binary_img);

% Area calculations
label2 = labelmatrix(CC);
stats = regionprops(CC,'Centroid','Area','MajorAxisLength','MinorAxisLength');

area1=([stats.Area]);
area1=sqrt(area1*4/pi);%Equivalent Diameter conversion

for i = 1:G
    for j=1:T
        if i <= 3
            area1(area1<=0.2*magnification)=[];%remove diameters less than 0.2 microns
            area1(area1>=200*magnification)=[];%remove diameters greater than 100 microns
        elseif i == 4 && j == 1 %Magnification 3 for 10K collagen
            area1(area1<=0.2*magnification3)=[];%remove diameters less than 0.2 microns
            area1(area1>=200*magnification3)=[];%remove diameters greater than 100 microns
        else
            area1(area1<=0.2*magnification2)=[];%remove diameters less than 0.2 microns
            area1(area1>=200*magnification2)=[];%remove diameters greater than 100 microns
        end 
    end
end 
Numofelem=length(area1);
meanarea=mean(area1(1:end));
stddevarea=std(area1(1:end));
deq=area1;

%% plotting figure with mask, without mask and with histogram of diameters
figure(12);
tiledlayout(1,3,'TileSpacing','tight');
% histogram(area1(2:end),0:10:250); 
nexttile;imshow(labeloverlay(img1crop,label2)); 
nexttile;imshow(img1crop);hold on;plot((1:10)*magnification+500,500*ones(10,1),'r-','LineWidth',3);hold off;
title(geltype);
bins1=0:10:300; %changes histogram limits (0 - 200) and intervals (10) 
for i=1:G
    for j=1:T
        if i <= 3
            nexttile;histogram(area1/magnification,bins1); axis square;
        elseif i == 4 && j == 1 %Magnification 3 for 10K collagen
            nexttile;histogram(area1/magnification3,bins1); axis square;
        else
            nexttile;histogram(area1/magnification2,bins1); axis square;
        end 
    end
end
title(['mean diameter=',num2str(meanarea/magnification,'%03.2f'),'\mum']);
% set(gcf,'position',[100,100,900,300]);
set(gcf,'position',[100,700,1200,600]); %gcf returns the current figure handle 
savefig(savename)
% print(gcf,'-dpng',[savename,'_segmented_img_overlay.png']);

% img1filtered2=entropyfilt(img1crop,true(3));
% figure;imagesc(img1filtered2);

if meanarea==0
    keyboard;
end

end

%% Perform t-test on data
%function [p_valuet, hypothesis] = Ttestplot(variable,groups) 


%end

%% Plot data as histograms (to mimic Clarisse: greyscale from L - R, significance, 

%geltype2 = {'4% Agarose', '4% Collagen', '4% Agarose 2% Collagen-2001', '4% Agarose 2% Collagen-2011', '2% Agarose 2% Collagen'};
%geltype={"2A2C","4A","4A2C-2001","4A2C-2011","4C"};

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
