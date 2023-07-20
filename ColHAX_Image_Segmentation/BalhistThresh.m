%Reading Image & converting data type to double
imgdir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/Analyzed Images Final/HAX30/Replicate 1/1l2_003.tif';
img= imread(imgdir);
% img=imread('LovelySpider.jpeg');
%img(:,:,[2:3]= [] % uncomment this if image is rgb
figure
subplot(2,1,1)
imshow(img)
title('Original Image')
img=double(img);


I=img(:);           % Calculating Histogram
hst=zeros(1,256);
for ii =0:255
    hst(ii+1)=sum(I==ii);
end

for ii=1:256        % Calculating Start Point
    if hst(ii)>0
        stpt=ii;
        break
    end
end
for ii=256:-1:1     % Calculating End point
    if hst(ii)>0
        endpt=ii;
        break
    end
end
mdpnt=round((stpt+endpt)/2);    %mid point
lsum=sum(hst(stpt:mdpnt));      % sum of left side
rsum=sum(hst(mdpnt:endpt));     % sum of right side
while lsum ~= rsum              % iterative process of finding
    if rsum>lsum                % balanced mid point
        endpt=endpt-1;
        if round((stpt+endpt)/2)< mdpnt
            mdpnt=mdpnt+1;
            lsum=sum(hst(stpt:mdpnt));
            rsum=sum(hst(mdpnt:endpt));
            
        end
    else
        stpt=stpt+1;
        if round((stpt+endpt)/2) > mdpnt
            mdpnt=mdpnt-1;
            lsum=sum(hst(stpt:mdpnt));
            rsum=sum(hst(mdpnt:endpt));
            
        end
    end
            
            
end

% for image processing
nimg=zeros(size(img));
rng=size(img);
for ii=1:rng(1)
    for jj=1:rng(2)
        if img(ii,jj)<=(mdpnt/2) %point from where the image's background is separated
            nimg(ii,jj)=255;
        else
            nimg(ii,jj)=0;
        end
    end
end


subplot(2,1,2)
imshow(nimg)
title('Processed Image')

I=nimg(:);           % Calculating Histogram
hst2=zeros(1,256);
for ii =0:255
    hst2(ii+1)=sum(I==ii);
end
figure
subplot(2,1,1)
stem(hst)
grid on
title('original Image Histogram')
axis([1 256 0 65000])
subplot(2,1,2)
stem(hst2)
title('processed Image Histogram')

figure
stem(hst)
grid on
%axis([0 172 0 65000])
hold on
stem(mdpnt,hst(mdpnt),'red', 'linewidth',2)
disp('The balanced threshold value of Histogram is :')
disp(mdpnt)