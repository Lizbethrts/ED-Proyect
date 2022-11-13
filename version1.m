%Código para detectar placas - Proyecto Final Ecuaciones Diferenciales
%  Integrantes:
%     Ariana Rodriguez Castañeda
%     Emiliano Montes Gómez
%     Lizbeth Rocío Trujillo Salgado
close all;
clearvars;
clc;

% Ejectuamos el main
mainmenu;

% Función main
function mainmenu

    %Creamos interfaz gráfica
    fig = uifigure;
    label = uilabel(fig);

    label.Position = [100 120 83000 50];
    %El botón para leer la imagen que el usuario introduzca como input, y
    %que, posteriormente, realizará todo el proceso de detección
    btn = uibutton(fig,'push', 'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn));

end

function plotButtonPushed(btn)
    %Seleccionamos imagen
    defaultFileName = fullfile(pwd, '*.*');
    [file, path] = uigetfile(defaultFileName, "Select a File");
    if isequal(file,0)
        disp("User selected Cancel")
    end
    all_figures = findall(0,"type","figure");
    close(all_figures);

    %Cargamos imagen con los debidos procesos, imread() y posteriormente la
    %transofrmamos a esacala de grises
    fullFileName = fullfile(path, file);
    img = im2gray(imread(fullFileName));
    dispimg = imresize(img,[300,500]);
    figure, imshow(dispimg);

    %Aplicamos filtros para que sea mejor el resultado de la imagen y no
    %detectemos imperfecciones
    img = medfilt2(img);
    img = imgaussfilt(img,4,"FilterSize",[5,5]);
    img = uint8(img);

    %Guardamos el tamaño de la imagen que nos servirá posteriormente y
    %re-ajustamos
    [h, w]=size(img);
    img = imresize(img,[300,500]);
    
    treshold = graythresh(img);
    figure, imshow(treshold);
    image = imbinarize(img,treshold);
    reverse = imcomplement(image);
    figure, imshow(reverse);
    
     if w> 2000
         temp=bwareaopen(reverse,3500);
     else
         temp=bwareaopen(reverse, 3000);
     end
    figure, imshow(temp);

    temp2=reverse-temp;
    temp2=bwareaopen(temp2,250);

    temp2 = edge(temp2,"sobel");
    B = strel("line",2,0);

    temp2 = imdilate(temp2,B);

    figure, imshow(temp2);
%     
%     figure, imshow(reverse);
%     figure, imshow(temp2);
% 
%     temp2 = edge(temp2,"sobel");
%     dilated = strel("line",2,0);
%     tempf = imdilate(temp2,dilated);
% 
%     figure, imshow(tempf);

    load LettsAndNums_TrainModel
    [lbls, objs] = bwlabel(temp2);
    objfts = regionprops(lbls,"BoundingBox");
    for n=1:size(objfts,1)
        rectangle('Position',objfts(n).BoundingBox, 'EdgeColor','y','LineWidth',2);
    end

    plate = [];
    t = [];

    for n=1:objs
        [r,c]=find(lbls==n);
        char=reverse(min(r):max(r), min(c):max(c)); 
        char=imresize(char,[42,24]);

        x=[];
        charnum=size(images,2);
        for k=1: charnum
            y=corr2(images{1,k},char);
            x=[x y];
        end  
        t=[t max(x)];
        
        if max(x)> 0.6
            maxIndex=find(x==max(x));
            finalChar=cell2mat(images(2,maxIndex));
            plate=[plate, finalChar];
        end
    end
    
    fprintf("Placa: ")
    fprintf(plate);

end
