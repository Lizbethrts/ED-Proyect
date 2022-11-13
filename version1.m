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
    originalimage = imread(fullFileName);
    img = im2gray(imread(fullFileName));

    %Aplicamos filtros para que sea mejor el resultado de la imagen y no
    %detectemos imperfecciones
    img = medfilt2(img);
    img = imgaussfilt(img,4,"FilterSize",[5,5]);
    img = uint8(img);
    figure, imshow(img);


    treshold = graythresh(img);
    figure, imshow(treshold);
    image = imbinarize(img,treshold);
    reverse = imcomplement(image);
    figure, imshow(reverse);


    load LettsAndNums_TrainModel;
    [lbls, objs] = bwlabel(reverse);
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
        
        if max(x)> 0.388
            maxIndex=find(x==max(x));
            finalChar=cell2mat(images(2,maxIndex));
            plate=[plate, finalChar];
        end
    end
    
    fprintf("Placa: ")
    fprintf(plate);


end
