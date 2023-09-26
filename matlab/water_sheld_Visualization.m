close all;
%%
I = imread('C:/Users/rxiao/Desktop/PhD/figs/chapter4/ccRCC_seg_15.png');
I=double(I);
%D = bwdist(~bw);
DI = bwdist(I);
D = D(:,:,1);
figure;
imagesc(D);
%%
figure(1),imagesc(D)
set(gcf, 'Color', 'w')
axis off
export_fig(figure(1),'C:/Users/rxiao/Desktop/PhD/figs/chapter4/diatance_transform.png')
%%
figure(2),imagesc(E)
set(gcf, 'Color', 'w')
axis off
export_fig(figure(2),'C:/Users/rxiao/Desktop/PhD/figs/chapter4/diatance_transform_max.png')

%%
E=max(D(:))-D;
Ld1 = watershed(E);
mask = imextendedmin(E,2);
D2 = imimposemin(E,mask);
Ld2 = watershed(D2);
Ld3 = watershed(D2);
%%
figure;
imagesc(E);
%%
figure;
imshow(label2rgb(Ld3,'parula','w','shuffle')),title('distance transform SKELETON');

%%
figure;
imshow(label2rgb(Ld1,'parula','w','shuffle')),title('distance transform before modified');
%%
figure;
imshow(label2rgb(Ld2,'parula','w','shuffle')),title('distance transform after modified');
%%
mask2 = imextendedmin(E,2);
D3 = imimposemin(E,mask2);
Ld13 = watershed(D);
%%
figure;
imshow(label2rgb(Ld13,'parula','w','shuffle')),title('distance transform after modified');

%%
figure;
imagesc(D2);
%%
E=max(D(:))-D;
figure;
imagesc(E);
%%

Ld = watershed(D);
Ld1 = watershed(E);
%%
figure;
imshow(label2rgb(Ld,'parula','w','shuffle')),title('distance transform after modified');
%%
figure;
imshow(label2rgb(Ld1,'parula','w','shuffle')),title('distance transform after modified');

%%
imwrite(label2rgb(Ld,'parula','w','shuffle'),"C:/Users/rxiao/Desktop/PhD/figs/chapter4/over_seg1.png")
%%
bw2 = I;
bw2(Ld == 0) = 255;
% 
mask = imextendedmin(E,2);

% 
D2 = imimposemin(E,mask);
Ld2 = watershed(D2);

%%
figure;
imshow(label2rgb(D2,'parula','w','shuffle')),title('distance transform after modified');
%%
figure;
imshow(label2rgb(Ld2,'parula','w','shuffle')),title('distance transform after modified');
%%
imwrite(label2rgb(Ld2,'parula','w','shuffle'),"C:/Users/rxiao/Desktop/PhD/figs/chapter4/distance transform after modified1.png")
%%
Ld2 = watershed(D2);
a=unique(Ld2(1,:));
a(a==0) = []; 
b=unique(Ld2(2000,:));
b(b==0) = []; 
c=unique(Ld2(:,1)');
c(c==0) = []; 
d=unique(Ld2(:,2000)');
d(d==0) = []; 
e=unique([a,b,c,d]);
for pixel_i = 1:length(e)
    Ld2(Ld2==e(pixel_i))=0;
end   
    
%%
figure;
imshow(label2rgb(Ld2,'parula','w','shuffle')),title('distance transform after modified');

%%
imwrite(label2rgb(Ld2,'parula','w','shuffle'),"C:/Users/rxiao/Desktop/PhD/figs/chapter4/REMOVE_distance transform after modified1.png")

%%
figure
imshow(I)
hold on
himage = imshow(label2rgb(Ld2,'parula','w','shuffle'));
himage.AlphaData = 0.3;
title('Lrgb superimposed transparently on original image after modified')
%%
cc=bwconncomp(Ld2);  %find target grid 
L=labelmatrix(cc);   %assign target label 
area=regionprops(L,'Area');  %obtain target area 
area=[area(:).Area]; 
perimeter=regionprops(L,'Perimeter');    %obtain target perimeter 
perimeter=[perimeter(:).Perimeter]; 
Ecc=regionprops(L,'Eccentricity');   %obtain target eccentricity  
ecc=[Ecc(:).Eccentricity]; 
centroid=regionprops(L,'Centroid');  %obtain target centroid 

mean_Area=mean(area);
mean_Eccentricity=mean(ecc);
median_Eccentricity=median(ecc);
