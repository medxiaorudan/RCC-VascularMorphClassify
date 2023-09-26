function Road = detecRoad(im_in,n,gamma, window_size)
%function Road = detecRoad(name1,n,gamma)

%esta funcion solo implementa la primera parte, la primer etapa del paper.
%despues vendrian las otras 2 que no estoy usando

%dep=img original
%n=with of filament (in pixels)

lambda = 4./3.;
sigma = 3*n/(4*sqrt(2));
gamma = 1.5/gamma;%%en paper es cte, = 1/3. Es el aspect ratio (?)

dimension    = size(im_in);
routes = zeros(dimension(1),dimension(2));
% taille = 41;%%al pedo, no se usa

for k=0:15

  theta = k*pi/16;%discretiza 2pi en 16 angulos conl os que define la direccion theta

first_half = half_gabor(im_in, window_size, theta, sigma, lambda, gamma, +1);%CentralRoad crea funcion gabor y comboluciona co dep, eso es lo que devuelve (A,B)
second_half = half_gabor(im_in, window_size, theta, sigma, lambda, gamma, -1);%el 1,-1 es para el sentido como esta definido en paper
response =min(first_half,second_half);
routes = max(routes,response); % take the maximum response
% routes = first_half;
end


% figure
% 
% image(routes);
% colormap(gray(128))
%   visu = max(dep/2,10*routes);
% figure
% image(visu);
% colormap(gray(256))
  
Road=routes;
