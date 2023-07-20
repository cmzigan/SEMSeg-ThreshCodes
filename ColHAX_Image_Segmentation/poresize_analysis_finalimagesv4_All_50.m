% Pore size segmentation for final data by Sayantan Bhattacharya 
clear;
% clc;

%% Load file output location (make Analyzed Images Final folder?) and name samples
%Load file input location
basedir='/Users/claudiaba/Library/CloudStorage/Box-Box/ChanLab/ColHAX_Image_Segmentation/old50X';
%Load file input location
basedir2='/Users/claudiaba/Library/CloudStorage/Box-Box/ChanLab/ColHAX_Image_Segmentation';
% SAMPLE NAMES
%geltype={"2A2C","4A","4A2C-2001","4A2C-2011","4C","4C - 250","4C - 10K"};
%geltype={"2C","4C","4A2C","4A","2A2C","2A"};
geltype={"4A2C","4A","2A2C"};
%geltype={'HAX30','C2HX30','C6HX30','C4','C4HX20','C4HX30','C4HAX40'};
% Xbar=categorical(geltype);
G=length(geltype);
%trials={"Replicate 1"}; 
trials={'Replicate 1','Replicate 2','Replicate 3','Replicate 4','Replicate 5'}; %Three biological replicates of data  
T=length(trials);
ycrop=892; % y-axis pixel size of file
%ycrop=880; 
magnification = 0.504;%(%pixels/microns)- this is for 50X - 504 pixels/ mm
%magnification1 = 1.365; %(%pixels/microns)- this is for 150X - 1.365 pixels/ mm
%magnification2 = 2.52; %(%pixels/microns) specifically for collagen 250X - 2.52 pixels/ um
%magnification3 = 100.8; %(%pixels/microns) specifically for collagen 10,000X - 504 pixels/ mm
%magnification=17;%(%pixels/microns)
meanporesize=zeros(G,T);
stdporesize=zeros(G,T); 

%% Save file portion 
excelcol={'A2','B2','C2'}; %WHY DID YOU MAKE THIS STATIC THIS SHOULD BE DYNAMIC BASED ON NUM OF GELS

excelcellnames = {"Replicate", "Mean","Standard Deviation"};

savedir=[basedir2,'/Results50X']; %,'/segmentimage','/150Xsegmented'];
if ~exist(savedir,'dir')
    mkdir(savedir);
end
if ~exist(savedir + "/segmentimage",'dir');%Added dir
    mkdir(savedir + "/segmentimage");
end

%% Load images in a loop
gelporesize= NaN(10000,G); %Bin for all poresizes later
% % poresize_col = [];
for i=1:G
    sampledir = fullfile(basedir+"/"+geltype{i}); %go to subfolder with dif samples
    %trialsdir = dir([sampledir '/*.tif']); %directory of tif files in folder
    trialsdir = dir(fullfile(sampledir, '*.tif')); %make var with tif files 
    %meanporesize=zeros(T);
    %stdporesize=zeros(T);
    poresize=NaN(2000,T);
    for j=1:T
        %for n=1:Nim
        %save figures in this folder
        savename= fullfile(savedir,'/segmentimage/',geltype{i} + "_" + trialsdir(j,1).name(1:end-4)+'.fig');% end-4 removes .tif
        img1=imread([trialsdir(j,1).folder,filesep,trialsdir(j,1).name]);
        img1crop=img1(1:ycrop,:); 

        [BW,maskedImage] = segmentImage5(img1crop);
        %Magnification 2 for 50X
        [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});
        %imshow(originalImage);
        meanporesize(i,j)=meanarea/magnification;
        stdporesize(i,j)=stddevarea/magnification;
        poresize_indv =deq/magnification;
        poresize_indvlen = length(poresize_indv);
        poresize(1:poresize_indvlen,j) = poresize_indv;
        % if i <= 1 %Collagens only
        %     %Smaller mask
        %     [BW,maskedImage] = segmentImage5(img1crop);
        %     %Magnification 2 for 250X Col
        %     [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});
        %     %imshow(originalImage);
        %     meanporesize(i,j)=meanarea/magnification;
        %     stdporesize(i,j)=stddevarea/magnification;
        %     poresize_indv =deq/magnification;
        %     poresize_indvlen = length(poresize_indv);
        %     poresize(1:poresize_indvlen,j) = poresize_indv;
        % elseif i <= 2
        %     %Larger mask
        %     [BW,maskedImage] = segmentImage5(img1crop);
        %     %Magnification 2 for 250X 4A and 4A2C
        %     [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});
        %     meanporesize(i,j)=meanarea/magnification;
        %     stdporesize(i,j)=stddevarea/magnification;
        %     poresize_indv =deq/magnification;
        %     poresize_indvlen = length(poresize_indv);
        %     poresize(1:poresize_indvlen,j) = poresize_indv;
        % else 
        %     %Larger mask
        %     [BW,maskedImage] = segmentImage5(img1crop);
        %     %Magnification 2 for 250X 2A and 2A2C
        %     [label2,meanarea,stddevarea,Numofelem,deq]=poresize_calculate(BW,magnification,img1crop,savename,geltype{i});
        %     meanporesize(i,j)=meanarea/magnification;
        %     stdporesize(i,j)=stddevarea/magnification;
        %     poresize_indv =deq/magnification;
        %     poresize_indvlen = length(poresize_indv);
        %     poresize(1:poresize_indvlen,j) = poresize_indv;
        %     gelporesize = poresize(:);
        % end 
        % % poresizeColumns = [poresize_col, poresize];
        poresize_flat = reshape(poresize,[],1);
        poresize_flatlen = length(poresize_flat);
        gelporesize(1:length(poresize_flat),i)=poresize_flat; %Put all files together in this
    end


    %SAVE TO EXCEL FILE 
    if ~isempty(poresize)
       
    writematrix(poresize(:,:),'poresize50X.xlsx','Sheet',geltype{i}, 'Range','A2:E2000')
    % Creating Poresize Statistics Excel
    % writecell(excelcellnames.',fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','A1:A10')
    % writematrix(trialsdir.name,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B1:E1')
    % writematrix(meanporesize,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B2:E2')
    % writematrix(stdporesize,fullfile(savedir,'/poreStats.xlsx'),'Sheet',geltype{i},'Range','B3:E3')
    else
        fprintf("Image %i no pores detected\n", i)
    end
end

[h,p12,ci] = ttest2(gelporesize(:,1),gelporesize(:,2))
[h,p13,ci] = ttest2(gelporesize(:,1),gelporesize(:,3))
[h,p23,ci] = ttest2(gelporesize(:,2),gelporesize(:,3))

%4A should be yellow (1.0000,0.9765,0.6588) , 4A2C should be green, 2A2C should be blue (0.6588,0.7882,1.000), 4C should be red (0.7882,0.4667,0.4667) – in case any of the colorings are messed up!
%categories={'4A2C','4A','2A2C'}; %Hardcoded to have 3 categories
categories = {'4% Agarose', '4% Agarose', '2% Agarose'};
categories2 = {'- 2mg/mL Collagen-I', '', '- 2mg/mL Collagen-I'};
labelArray = [categories; categories2]; %Make a matrix
labelArray = strjust(pad(labelArray),'center'); % 'left'(default)|'right'|'center
tickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
x = categorical(categories);
y = mean(gelporesize, 'omitnan');
std_y = std(gelporesize,'omitnan');
usercolors = [0.6588,0.7882,0.4667;1.0000,0.9765,0.6588;0.6588,0.7882,1.000];
p_values = [p12,p13,p23];
figure()
hold on

for i=1:length(categories)
    bar(i, y(i), 'FaceColor', usercolors(i,:), 'BarWidth', 0.8)
    errorbar(i, y(i), std_y(i)/sqrt(std_y(i)), 'k', 'HandleVisibility', 'off','LineWidth',2)
    ylim([0 90])
end
text((1), [1]*y(1)*1.15, '______________','FontSize',15);
text((1.5), y(1)*1.15, '***','FontSize',15);
text((1), [1]*y(1)*1.2, '___________________________','FontSize',15);
%text((1), [1]*y(1)*1.18, '|','FontSize',5);
text((2), y(1)*1.2, '***','FontSize', 15);

xticks(1:numel(categories));
xticklabels(tickLabels);
%xlabel({'First line';'Second line'})

ylabel('Diameter (um)', 'FontSize', 12)
%group_labels = {' Day 3', ' Day 7', ' Day 14', ' Day 21'};
%set(gca,'xtick','xticklabel',group_labels, 'FontSize', 15)%,[1:4]
%xlabel('Hydrogel','FontSize',15)
% legend('4% Agarose', '4% Agarose - 2mg/mL Collagen-I', '2% Agarose - 2mg/mL Collagen-I')%,'4mg/mL Collagen-I'
axis padded


%% Make colored blobs in a mask, based off of connected components
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

area1(area1<=0.2*magnification)=[];%remove diameters less than 0.2 microns
area1(area1>=200*magnification)=[];%remove diameters greater than 100 microns

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
nexttile;histogram(area1/magnification,bins1); axis square;
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
