%% IRIS
% This start file adds the paths needed to run IRIS
% Run this file before running any of the models


% Identify path for IRIS
newdir  = 'C:';

% Change path to reference your IRIS toolbox location 
irispathstr = [newdir filesep 'IRIS'];
addpath(irispathstr)

% Start IRIS
iris.startup()

%% MATLAB Report Generator
% Add path to Report folder

pathstr = [newdir filesep 'Publish'];
addpath(pathstr)

clear variables
