close all;
clearvars;
clc;

% Have user browse for a file, from a specified "starting folder."
% For convenience in browsing, set a starting folder from which to browse.
startingFolder = pwd;  % or 'C:\wherever';
if ~isfolder(startingFolder)
	% If that folder doesn't exist, just start in the current folder.
	startingFolder = pwd;
end
% Get the name of the file that the user wants to use.
defaultFileName = fullfile(startingFolder, '*.*');
[baseFileName, folder] = uigetfile(defaultFileName, 'Select a file');
if baseFileName == 0
	% User clicked the Cancel button.
	return;
end
fullFileName = fullfile(folder, baseFileName)
theImage = imread(fullFileName);
imshow(theImage);
