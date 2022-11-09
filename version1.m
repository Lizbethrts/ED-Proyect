close all;
clearvars;
clc;


mainmenu;


close all;

function mainmenu

fig = uifigure;
label = uilabel(fig)
plot((1:10).^2)
title('\color[rgb]{0 .5 .5}Dtector\')
label.Text = "Detector de placas";

label.Position = [100 120 83000 50];
btn = uibutton(fig,'push', 'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn));




end

function plotButtonPushed(btn)
    defaultFileName = fullfile(pwd, '*.*');
    [baseFileName, folder] = uigetfile(defaultFileName, "Select a File");
    if baseFileName == 0
        return;
    end
    all_figures = findall(0,"type","figure");
    close(all_figures);

    fullFileName = fullfile(folder, baseFileName)
    originalimage = imread(fullFileName);
    img = im2gray(imread(fullFileName));
    
    img = medfilt2(uint8(img),[9,9]);   
   
    kH = [-1 -2 -1; 0 0 0; 1 2 1];
    kV = kH';
    
    imBH = imfilter(img,kH);
    imBV = imfilter(img,kV);
    img2 = (imBH.*0.5) + (imBV.*0.5);

    A = zeros(size(img));
    A(img>230) = 1;

    A = edge(A,"Sobel");

    B = strel("line",2,0);
    imgf = imdilate(A,B);

    subplot(2,2,1); imshow(originalimage); title("Original");
    subplot(2,2,2); imshow(imgf); title("Detected");
    subplot(2,2,3); imshow(img2); title("?");

end
