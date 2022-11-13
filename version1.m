close all;
clearvars;
clc;

mainmenu;

function mainmenu

    fig = uifigure;
    label = uilabel(fig)

    label.Position = [100 120 83000 50];
    btn = uibutton(fig,'push', 'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn));

end

function plotButtonPushed(btn)

    defaultFileName = fullfile(pwd, '*.*');
    [file, path] = uigetfile(defaultFileName, "Select a File");
    if isequal(file,0)
        disp("User selected Cancel")
    end
    all_figures = findall(0,"type","figure");
    close(all_figures);

    fullFileName = fullfile(path, file)
    originalimage = imread(fullFileName);
    img = im2gray(imread(fullFileName));
    
    img = medfilt2(uint8(img),[9,9]);   

    A = zeros(size(img));
    A(img > 150) = 1;

    A = edge(A,"Sobel");

    B = strel("line",2,0);
    imgf = imdilate(A,B);

    subplot(1,2,1); imshow(originalimage); title("Original");
    subplot(1,2,2); imshow(imgf); title("Detected");

end
