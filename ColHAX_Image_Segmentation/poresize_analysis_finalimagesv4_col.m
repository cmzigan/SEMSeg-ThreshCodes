% Pore size segmentation for final data by Sayantan Bhattacharya 
clear;
clc;

%% Load file output location (make Analyzed Images Final folder?) and name samples
%Load file input location
%basedir='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/Analyzed Images Final/4C';
basedir='/Users/claudiaba/Library/CloudStorage/Box-Box/ChanLab/ColHAX_Image_Segmentation/Analyzed Images Final/4C';
%Load file input location
%basedir2='/Users/claudiaba/Documents/ColHA_Porosity/ColHAX_Image_Segmentation/';
basedir2='/Users/claudiaba/Library/CloudStorage/Box-Box/ChanLab/ColHAX_Image_Segmentation/';
%basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/Analyzed Images Final/';
%basedir2='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';
% SAMPLE NAMES
%geltype={"2A2C","4A","4A2C-2001","4A2C-2011","4C","4C - 250","4C - 10K"};
geltype={"4C - 10K","4C - 250","4C - 250b"};
%geltype={'HAX30','C2HX30','C6HX30','C4','C4HX20','C4HX30','C4HAX40'};
% Xbar=categorical(geltype);
G=length(geltype);
trials={"Replicate 1"}; 
%trials={'Replicate 1','Replicate 2','Replicate 3'}; %Three biological replicates of data  
T=length(trials);
ycrop=892; % y-axis pixel size of file
%ycrop=880; 
%magnification=0.504;%(%pixels/microns)- this is for 50X - 504 pixels/ mm
magnification2 = 2.52; %(%pixels/microns) specifically for collagen 250X - 2.52 pixels/ um
magnification3 = 100.8; %(%pixels/microns) specifically for collagen 10,000X - 504 pixels/ mm
%magnification=17;%(%pixels/microns)
meanporesize=zeros(G,T);
stdporesize=zeros(G,T);
%poresize=cell(G,T); Removed as we are storing this as a flattened array

%% Save file portion 
excelcol={'A2','B2','C2'}; 

excelcellnames = {"Replicate", "Mean","Standard Deviation"};

savedir=[basedir,'/Results'];%WAS BASEDIR2
if ~exist(savedir,'dir')
    mkdir(savedir);
end
%% Load images in a loop
gelporesize= NaN(2000,G); %Bin for all poresizes later
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
            
            % if i==1 
            %     [BW,maskedImage] = segmentImage(img1crop); %Larger open bin for 10K collagen
            %     %imshow(originalImage);
            % else
            %     [BW,maskedImage] = segmentImage(img1crop); %Smaller open bin for 250K collagen
            % end 

%             figure;imagesc(~maskedImage);
% 
%             img1filtered2=stdfilt(im2double(img1crop),true(5));
%             img1filtered2(img1filtered2<0.05)=0;
%             figure;imagesc(img1filtered2);
%             img1filtered2=stdfilt(im2double(imadjust(img1crop)),true(5));
%             img1filtered2(img1filtered2<0.05)=0;
%             figure;imagesc(img1filtered2);

            if i==1 
                %Magnification 3 for 10K collagen
                [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification3,img1crop,savename,geltype{i});
                %imshow(originalImage);
                meanporesize(i,j)=meanarea/magnification3;
                stdporesize(i,j)=stddevarea/magnification3;
                poresize =deq/magnification3;
            else
                %Magnification 2 for 250K collagen
                [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification2,img1crop,savename,geltype{i});
                meanporesize(i,j)=meanarea/magnification2;
                stdporesize(i,j)=stddevarea/magnification2;
                poresize =deq/magnification2;
            end 

            %[label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});

            % meanporesize(i,j)=meanarea/magnification2;
            % stdporesize(i,j)=stddevarea/magnification2;
            % poresize =deq/magnification2;

            % Creating PoreSize Excel File
            poresize_flat = reshape(poresize,[],1);
            poresize_flatlen = length(poresize_flat);
            gelporesize(1:length(poresize_flat),i)=poresize_flat; %Put all files together in this
            
            flattenporesize = reshape(poresize,[],1);
            writematrix(flattenporesize(:),'poresizeCol.xlsx','Sheet',geltype{i}, 'Range','A2:A500') %Should not be done this way but matlab
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

%% Plot data as histograms (to mimic Clarisse: greyscale from L - R, significance, 

% [h,p12,ci] = ttest2(gelporesize(:,1),gelporesize(:,2))
% [h,p13,ci] = ttest2(gelporesize(:,1),gelporesize(:,3))
% [h,p23,ci] = ttest2(gelporesize(:,2),gelporesize(:,3))

highmag = [gelporesize(:,2),gelporesize(:,3)];%Combine only the data from col 2 and 3 which are the 250X mag data 
highmag_flat = reshape(highmag,[],1); %Reshape it to all be one column (still with NaNs)

categories = {'4% Collagen'};
x = categorical(categories);
y = mean(highmag_flat, 'omitnan');%Mean of data without NaNs
std_y = std(highmag_flat,'omitnan');
usercolors = [0.7882,0.4667,0.4667];
%p_values = [p12,p13,p23];
figure()
hold on

for i=1:length(categories)
    bar(i, y(i), 'FaceColor', usercolors(i,:), 'BarWidth', 0.8)
    errorbar(i, y(i), std_y(i)/sqrt(std_y(i)), 'k', 'HandleVisibility', 'off','LineWidth',2)
    ylim([0 90])
end
%text((1), [1]*y(1)*1.15, '______________','FontSize',15);
%text((1.5), y(1)*1.15, '***','FontSize',15);
%text((1), [1]*y(1)*1.2, '___________________________','FontSize',15);
%text((1), [1]*y(1)*1.18, '|','FontSize',5);
%text((2), y(1)*1.2, '***','FontSize', 15);

xticks(1:numel(categories));
xticklabels(categories);

ylabel('Diameter (um)', 'FontSize', 15)
%group_labels = {' Day 3', ' Day 7', ' Day 14', ' Day 21'};
%set(gca,'xtick','xticklabel',group_labels, 'FontSize', 15)%,[1:4]
%xlabel('Hydrogel','FontSize',15)
% legend('4% Agarose', '4% Agarose - 2mg/mL Collagen-I', '2% Agarose - 2mg/mL Collagen-I')%,'4mg/mL Collagen-I'
axis padded

%% Compares avg and standard dev of the three replicates
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
%% Make colored blobs in a mask, based off of connected components
function [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(binary_img,magnification2,img1crop,savename,geltype)
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

%area1(area1<=0.2*magnification2)=[];%remove diameters less than 0.2 microns
%area1(area1>=200*magnification2)=[];%remove diameters greater than 100 microns

if i==1 
    %Magnification 3 for 10K collagen
    area1(area1<=0.1*magnification3)=[];%remove diameters less than 0.2 microns
    area1(area1>=200*magnification3)=[];%remove diameters greater than 100 microns
else
    %Magnification 2 for 250K collagen
    area1(area1<=0.2*magnification2)=[];%remove diameters less than 0.2 microns
    area1(area1>=200*magnification2)=[];%remove diameters greater than 100 microns
end 

Numofelem=length(area1);
meanarea=mean(area1(1:end));
stddevarea=std(area1(1:end));
deq=area1;

%% plotting
figure(12);
tiledlayout(1,3,'TileSpacing','tight');
% histogram(area1(2:end),0:10:250); 
nexttile;imshow(labeloverlay(img1crop,label2)); 
nexttile;imshow(img1crop);hold on;plot((1:10)*magnification2+500,500*ones(10,1),'r-','LineWidth',3);hold off;
title(geltype);
bins1=0:5:50; %changes histogram limits (0 - 200) and intervals (10) 
nexttile;histogram(area1/magnification2,bins1); axis square;
title(['mean diameter=',num2str(meanarea/magnification2,'%03.2f'),'\mum']);
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
