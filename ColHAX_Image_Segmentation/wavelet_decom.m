% rng default;
% N=10;
% x = 256*rand([1 N]);
% y = 256*rand([1 N]);
% figure(1);voronoi(x,y);
% 
% P=[x' y'];
% DT = delaunayTriangulation(P);
% T=DT.ConnectivityList;
% figure(2);voronoi(x,y,T);
% axis equal

clc;

basedir='/Users/sayantanbhatttacharya/Library/CloudStorage/Box-Box/2021.12.15 Images for Alternate Analyses/cryoSEM/';


img1=imread([basedir,filesep,'C4',filesep,'inv_5000_02.tif']);
% img1=imread('/Users/aether/Box/2021.12.15 Images for Alternate Analyses/cryoSEM/C6HAX30/inv_5000_02.tif');
% img1=imread('/Users/aether/Box/2021.12.15 Images for Alternate Analyses/cryoSEM/HAX/inv_5000_02.tif');


figure(1);imagesc(img1);

%% Continuous wavelet decomposition using Morlet wavelet
sc=8;
% figure(1);
% cwtmorl = cwtft2(img1,'scales',1:sc,'angles',0:pi/2:3*pi/2,'plot');
cwtmorl = cwtft2(img1,'wavelet','mexh','scales',1:sc,'angles',0:pi/2:3*pi/2);

for i=1:sc
    t=tiledlayout(1,2);
    t.TileSpacing = 'compact';
    t.Padding = 'compact';
    % figure(2);
    nexttile;imagesc(abs(squeeze(cwtmorl.cfs(:,:,1,i,1))));%colorbar;%caxis([0 50]);
    axis image;
    
    levl=i;
    filimg_temp=(abs(squeeze(cwtmorl.cfs(:,:,1,levl,1))));
    filimg1=uint8(255*filimg_temp/max(filimg_temp(:)));
    % figure(11);imshow(filimg1);hold off;
    L = imsegkmeans(filimg1,2);
    B = labeloverlay(filimg1,L);
    
    nexttile;imshow(B);title('Labeled Image');axis image;
    
%     print(gcf,'-dpng',['/Users/aether/Box/2021.12.15 Images for Alternate Analyses/cryoSEM/C4/','segmented1_',num2str(i,'%02.0f'),'.png']);
    
    pause(1);
end
%% imseg kmeans
levl=2;
filimg_temp=(abs(squeeze(cwtmorl.cfs(:,:,1,levl,1))));
filimg1=uint8(255*filimg_temp/max(filimg_temp(:)));
figure(11);imshow(filimg1);hold off;
L = imsegkmeans(filimg1,2);
B = labeloverlay(filimg1,L);
figure(12);imshow(B);title('Labeled Image')

%% Discrete haar wavelet decomposition
% X=img1;
% [c,s]=wavedec2(X,2,'haar');
% 
% %Extract the level 1 approximation and detail coefficients.
% [H1,V1,D1] = detcoef2('all',c,s,1);
% A1 = appcoef2(c,s,'haar',1);
% 
% %Use wcodemat to rescale the coefficients based on their absolute values. Display the rescaled coefficients.
% V1img = wcodemat(V1,255,'mat',1);
% H1img = wcodemat(H1,255,'mat',1);
% D1img = wcodemat(D1,255,'mat',1);
% A1img = wcodemat(A1,255,'mat',1);
% 
% figure(3);
% subplot(2,2,1)
% imagesc(A1img)
% colormap pink(255)
% title('Approximation Coef. of Level 1')
% 
% subplot(2,2,2)
% imagesc(H1img)
% title('Horizontal Detail Coef. of Level 1')
% 
% subplot(2,2,3)
% imagesc(V1img)
% title('Vertical Detail Coef. of Level 1')
% 
% subplot(2,2,4)
% imagesc(D1img)
% title('Diagonal Detail Coef. of Level 1')
%%
% X=img1;N=5;
% [c,s]=wavedec2(X,N,'haar');
% 
% for i=1:N
% %Extract the level 1 approximation and detail coefficients.
% [H1,V1,D1] = detcoef2('all',c,s,i);
% A1 = appcoef2(c,s,'haar',i);
% 
% V1img = wcodemat(V1,255,'mat',1);
% H1img = wcodemat(H1,255,'mat',1);
% D1img = wcodemat(D1,255,'mat',1);
% A1img = wcodemat(A1,255,'mat',1);
% 
% figure(3);
% subplot(1,N,i)
% imagesc(A1img)
% colormap pink(255)
% title(['Approximation Coef. of Level ', int2str(i)])
% axis image
% 
% % subplot(2,2,2)
% % imagesc(H1img)
% % title('Horizontal Detail Coef. of Level 1')
% % 
% % subplot(2,2,3)
% % imagesc(V1img)
% % title('Vertical Detail Coef. of Level 1')
% % 
% % subplot(2,2,4)
% % imagesc(D1img)
% % title('Diagonal Detail Coef. of Level 1')
% 
% pause(1);
% end