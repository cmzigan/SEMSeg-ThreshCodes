
I=imcomplement(img1crop);
[~,threshold] = edge(I,'sobel');
fudgeFactor = 0.5;
BWs = edge(I,'sobel',threshold * fudgeFactor);

figure;imshow(BWs)
title('Binary Gradient Mask')

se90 = strel('line',3,90);
se0 = strel('line',3,0);
se45 = strel('line',3,45);
se135 = strel('line',3,135);

BWsdil = imdilate(BWs,[se135 se90 se45 se0]);
figure;imshow(BWsdil)
title('Dilated Gradient Mask')

BWdfill = imfill(BWsdil,'holes');
figure;imshow(BWdfill)
title('Binary Image with Filled Holes')

BWnobord = imclearborder(BWdfill,4);
figure;imshow(BWnobord)
title('Cleared Border Image')

seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);
figure;imshow(BWfinal)
title('Segmented Image');