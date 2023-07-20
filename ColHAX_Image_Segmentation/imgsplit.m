function Image_Blocks= imgsplit(Image, Block_Size)
% Image = imread("peppers.png");
[Image_Height,Image_Width,~] = size(Image);

% Block_Size = 50;
Number_Of_Blocks_Vertically = ceil(Image_Height/Block_Size);
Number_Of_Blocks_Horizontally = ceil(Image_Width/Block_Size);
Image_Blocks = struct('Blocks',[]);

Index = 1;
for Row = 1: +Block_Size: Number_Of_Blocks_Vertically*Block_Size
    for Column = 1: +Block_Size: Number_Of_Blocks_Horizontally*Block_Size
        
    Row_End = Row + Block_Size - 1;
    Column_End = Column + Block_Size - 1;
        
    if Row_End > Image_Height
       Row_End = Image_Height;
    end
    
    if Column_End > Image_Width
       Column_End = Image_Width;
    end
    
    Temporary_Tile = Image(Row:Row_End,Column:Column_End,:);
    
    %Storing blocks/tiles in structure for later use%
    Image_Blocks(Index).Blocks = Temporary_Tile;
    subplot(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally,Index); imshow(Temporary_Tile);
    Index = Index + 1;
    
    end  
end

%***************************************************%
%Uncomment to save the images to seperate .jpg files%
%***************************************************%
% for Block_Index = 1: length(Image_Blocks)
%     imwrite(Image_Blocks(Block_Index).Blocks,"Block" + num2str(Block_Index) + ".jpg"); 
% end

end
%%
%{
Image=imcomplement(im2double(img1crop));

[Image_Height,Image_Width,~] = size(Image);

Block_Size = 16;
numlevel=20;
Number_Of_Blocks_Vertically = ceil(Image_Height/Block_Size);
Number_Of_Blocks_Horizontally = ceil(Image_Width/Block_Size);

contrast1=zeros(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally);
homogeneity1=zeros(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally);
correlation1=zeros(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally);
energy1=zeros(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally);

Row=1: +Block_Size: Number_Of_Blocks_Vertically*Block_Size;
Column=1: +Block_Size: Number_Of_Blocks_Horizontally*Block_Size;

for ik=1: Number_Of_Blocks_Vertically
    for jk = 1: Number_Of_Blocks_Horizontally
        
    Row_End = Row(ik) + Block_Size - 1;
    Column_End = Column(jk) + Block_Size - 1;
        
    if Row_End > Image_Height
       Row_End = Image_Height;
    end
    
    if Column_End > Image_Width
       Column_End = Image_Width;
    end
    
    Temporary_Tile = Image(Row(ik):Row_End,Column(jk):Column_End,:);
    [glcm,~] = graycomatrix(Temporary_Tile,'NumLevels',numlevel,'GrayLimits',[],'Offset',[0 1; -1 1;-1 0;-1 -1]);
    stats = graycoprops(glcm,{'Contrast','Homogeneity','Correlation','Energy'});

    contrast1(ik,jk)=mean(stats.Contrast);
    homogeneity1(ik,jk)=mean(stats.Homogeneity);
    correlation1(ik,jk)=mean(stats.Correlation);
    energy1(ik,jk)=mean(stats.Energy);


    
    %Storing blocks/tiles in structure for later use%
%                 Image_Blocks(Index).Blocks = Temporary_Tile;
%                 subplot(Number_Of_Blocks_Vertically,Number_Of_Blocks_Horizontally,Index); imshow(Temporary_Tile);
%                 Index = Index + 1;
    
    end  
end

figure;imagesc(contrast1)
figure;imagesc(homogeneity1)
figure;imagesc(correlation1)
figure;imagesc(energy1)

%}