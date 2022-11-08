close all;
clearvars;
clc;


buttonPlot;


function buttonPlot
% Create a figure window
fig = uifigure;

% Create a UI axes
ax = uiaxes('Parent',fig,...
            'Units','pixels',...
            'Position', [104, 123, 300, 201]);   

% Create a push button
btn = uibutton(fig,'push',...
               'Position',[420, 218, 100, 22],...
               'ButtonPushedFcn', @(btn,event) plotButtonPushed(btn,ax));
end

% Create the function for the ButtonPushedFcn callback
function plotButtonPushed(btn,ax)
        x = linspace(0,2*pi,100);
        y = sin(x);
        plot(ax,x,y)
end