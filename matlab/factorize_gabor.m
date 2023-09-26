clear all;
close all;
clc;

theta = pi/4;
taille = 5;
demi = ceil(taille/2);
sens = -1;
sigma = 5;
lambda = 10;
gamma = 3;


tic
gabor = zeros(taille);
gabor = zeros(taille);
x2 = zeros(taille);
y2 = zeros(taille);

for i=1 : taille
    for j=1:taille
        x1 = (i-demi)*cos(theta)+(j-demi)*sin(theta);
        y1 = (j-demi)*cos(theta)-(i-demi)*sin(theta);
        if (sens*x1)>0
            gabor(i,j) = cos((pi*x1)/(sqrt(2)*sigma*lambda))*exp(-(x1*x1+gamma*gamma*y1*y1)/(2*sigma*sigma));
        end
    end
end
toc

for i=1 : taille
    for j=1:taille
        x2 = (i-demi)*cos(theta)+(j-demi)*sin(theta);
        y2 = (j-demi)*cos(theta)-(i-demi)*sin(theta);
        if (sens*x2)>0
            gabor3(i,j) = cos((pi*x1)/(sqrt(2)*sigma*lambda))*exp(-(x1*x1+gamma*gamma*y1*y1)/(2*sigma*sigma));
        end
    end
end
toc

tic
one_to_taille_ligne = transpose(1:taille)*ones(1, taille);
% one_to_taille_ligne = transpose(one_to_taille_ligne);
x = (one_to_taille_ligne - demi)*cos(theta) + (one_to_taille_ligne' - demi)*sin(theta);
y = (one_to_taille_ligne' - demi)*cos(theta) - (one_to_taille_ligne - demi)*sin(theta);
gabor2 = (sens*x > 0) .* cos(x*pi/(sqrt(2)*sigma*lambda)).*exp(-(x.^2 + gamma^2*y.^2)/(2*sigma^2));
toc

norm(x1 - x)/max(norm(x1), norm(x))
norm(y1 - y)/max(norm(y1), norm(y))

% % unique(gabor2(:))
norm(gabor2 - gabor)/max(norm(gabor2), norm(gabor))