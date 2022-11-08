close all;
clearvars;
clc;


mainmenu;

function mainmenu

fig = uifigure;
btn = uibutton(fig,'push', 'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn));


end

function plotButtonPushed(btn)
    defaultFileName = fullfile(pwd, '*.*');
    [baseFileName, folder] = uigetfile(defaultFileName, "Select a File");
    if baseFileName == 0
        return;
    end
    fullFileName = fullfile(folder, baseFileName)
    img = rgb2gray(imread(fullFileName));
    imshow(img);
    img = medfilt2(uint8(img),[9,9]);
    imshow(img);
    A = zeros(size(img));
    A(img>230) = 1;

    A = edge(A,"Sobel");
    imshow(A);

    B = strel("line",2,0);
    imgf = imdilate(A,B);
    imshow(imgf);
    

end