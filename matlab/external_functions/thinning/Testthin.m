function Testthin

%% This is the thinning Algorithm in Matlab as bwmorph(Image,'thin')
% Author: zhengguo dai
% Email: zhgdai@126.com
% Company: Beijing JX Digital Wave Co.ltd

%% Load a Image
% close all ;
IterThinning = 100 ;
Image = imread('bw2.bmp') ;
% if isbw(Image) == 0
%     Image = im2bw( Image ) ;
% end
Raw = Image ;

for Iter = 1:IterThinning
    OutBW1 = Condition1( Image, 0 ) ;
    OutBW2 = Condition2( OutBW1, 0 ) ;
    Image = OutBW2 ;
end


%% debug and compare the result in Matlab
I = bwmorph(Raw, 'thin',IterThinning );
close all ;
figure,imshow( Raw ) ;
figure,imshow( I ) ;
figure,imshow( OutBW2 ) ;