%Código para detectar placas - Proyecto Final Ecuaciones Diferenciales
%  Integrantes:
%     Ariana Rodriguez Castañeda
%     Emiliano Montes Gómez
%     Lizbeth Rocío Trujillo Salgado
close all;
clearvars;
clc;

% Ejectuamos el main
trainingImages;
mainmenu;

%Funcion para guardar el .mat con el que se entrena al programa la
%comparación de imágenes
function trainingImages
    path = dir("LettsAndNums_TrainModel");
    fileNames = {path.name};
    fileNames = fileNames(3:end);
    images = cell(2,length(fileNames));
    for i=1:length(fileNames)
        images(1,i)={imread(['LettsAndNums_TrainModel','/',cell2mat(fileNames(i))])};
    
        temp=cell2mat(fileNames(i));
    
        images(2,i)={temp(1)};
    end

    save("imagefilldata.mat","images");
end


% Función main
function mainmenu

    %Creamos interfaz gráfica
    fig = uifigure("Name","Detector de Placas","Position",[50,50,300,300]);
    label = uilabel(fig,"WordWrap","on");
    label.Position = [46, 150, 200, 100];
    label.Text = "¡Bienvenido al detector de placas! Seleccione un archivo:";
    label.FontSize = 20;


    %El botón para leer la imagen que el usuario introduzca como input, y
    %que, posteriormente, realizará todo el proceso de detección
    btn = uibutton(fig,'push', 'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn),"Text","Seleccionar");

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
    
    %Hacemos la imagen binaria, mediante treshold
    treshold = graythresh(img);
    image = imbinarize(img,treshold);
    reverse = imcomplement(image);
    figure, imshow(reverse);
    
    %Quitamos objetos o figuras que no nos sirvan con bwareopen, que,
    %mediante un cierto número de píxeles, elimina componentes conectados
    %ue tienen más o menos píxeles según nos convenga 
     if w> 2000
         temp=bwareaopen(reverse,3500);
     else
         temp=bwareaopen(reverse, 3000);
     end
    figure, imshow(temp);
    temp2=reverse-temp;
    temp2=bwareaopen(temp2,250);

    %Utilizamos el operador de Sobel para detectar bordes y así, detectar
    %los caracteres de la placa
    temp2 = edge(temp2,"sobel");
    %Dilatamos los bordes
    B = strel("line",2,0);
    temp2 = imdilate(temp2,B);

    figure, imshow(temp2);
    
    
    %Cargamos nuestro .mat con la información para comparar
    load imagefilldata;
    %Detectamos los caracteres con un rectángulo
    [lbls, objs] = bwlabel(temp2);
    objfts = regionprops(lbls,"BoundingBox");
    for n=1:size(objfts,1)
        rectangle('Position',objfts(n).BoundingBox, 'EdgeColor','y','LineWidth',2);
    end
    
    %Arreglo que contendrá nuestra placa para imprimirla en consola
    plate = [];
    t = [];
    %Leemos los caracteres 
    for n=1:objs
        [r,c]=find(lbls==n);
        char=reverse(min(r):max(r), min(c):max(c)); 
        char=imresize(char,[42,24]);
        %figure, imshow(char), title('Character');
        x=[];
        %Encontrando el número de caracteres
        charnum=size(images,2);
        %Hacemos la comparación
        for k=1: charnum
            y=corr2(images{1,k},char);
            x=[x y];
        end  
        t=[t max(x)];
        
        %Eliminamos caracteres que no tengan una relación con un cierto
        %rango
        if max(x)> 0.5
            %Buscamos un caracter que coincida
            maxIndex=find(x==max(x));
            %Lo guardamos en el arreglo para posteriormente imprimirlo en
            %consola
            finalChar=cell2mat(images(2,maxIndex));
            plate=[plate, finalChar];
        end
    end
    %Impresión final
    figure, title("Result");
    subplot(2,2,1); imshow(dispimg); title("Original Image");
    subplot(2,2,2); imshow(reverse); title("Tresholded and Filtered Image");
    subplot(2,2,3); imshow(temp); title("What we dont need from the image");
    subplot(2,2,4); imshow(temp2); title("Detected Plate");
    fprintf("Placas: ");
    fprintf(plate);
    

end
