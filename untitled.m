%Cargamos imagen:
img = rgb2gray(imread("streetNoisy.png"));
figure(); imshow(img);

%Aplicamos filtro de mediana para reducir el ruido
img = medfilt2(uint8(img), [9,9]);
figure(); imshow(img);

%Aplicamos Tresholding
A = zeros(size(img));
A(img>230) = 1;

%Detectamos bordes con Sobel
A = edge(A, "Sobel");
figure(); imshow(A);

%Ajustamos
B = strel('line',2,0);
imgf = imdilate(A,B);
figure(); imshow(imgf);

%% 
clc;
clearvars;
close all;

%% 
clc;
clearvars;
