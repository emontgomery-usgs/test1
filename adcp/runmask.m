function [theNewADCPFile, theMaskFile] = runmask (rawcdf,theMaskFile,theNewADCPFile, noninteractive)

%function [theNewADCPFile, theMaskFile] = runmask (rawcdf,theMaskFile,theNewADCPFile, noninteractive)
%This function runs the masking functions to produce a newly masked file.
%This will use the settings in the cdf file to mask and then allow the user
%to pick additional bad points.  
%If no data file is given, the uigetfile is invoked
%If no mask file is given the file is created based on the rawcdf filename
%If a name is not give for the New ADCP File, the uigetfile dialog is invoked
%
%INPUTS:
%	rawcdf = the Netcdf file created directly from the binary ADCP file
%	theMaskFile = identical in size and structure to the cdf file containing
%		0's if the data is good and 1's if it is bad
%	theNewADCPFile = a name for the output
%   noninteractive = suppress interactive masking step
%
%OUTPUTS:
%	theNewADCPFile = the masked data file with same attributes as the raw data file
%	theMaskFile = netcdf file containing 0's if the data is good 
%		and 1's if it is bad
%
%Here is a list of the functions in the order of call: 
%ncmkmask.m, fillmask.m (premask.m), StareBare Browser, postmask.m


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. Côté, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andrée L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

 

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov
%
%Sub-programs
%	ncmkmask.m
%	fillmsk.m
%	StarBare directory, including postmask.m and modified premask 

version = 1.1;
% update 31-jan-2007 - remove batch calls
% updated 26-jan-2007 - update mins and maxes
% updated 22-dec-2006 - added ability to run noninteractive
%updated 09-Jul-2001 - corrected capitalization problems so won't crash in UNIX (ALR)
%updated 28-Dec-2000 09:03:22 - Added linefeeds to thecomment for history attribute (ALR)
%updated 10-Aug-1999 16:20:42


ncquiet

%tell us what function is running
Mname=mfilename;
disp('')
disp([ Mname ' is currently running']);


if nargin < 1, help(mfilename), end

if nargin < 1, rawcdf = ''; end
if nargin < 2, theMaskFile = ''; end
if nargin < 3, theNewADCPFile = ''; end
if nargin < 4, noninteractive = 0; end

if isempty(rawcdf), rawcdf = '*'; end
if isempty(theNewADCPFile), theNewADCPFile = '*'; end

% Get ADCP filename.
if any(rawcdf == '*')
	[theFile, thePath] = uigetfile(rawcdf, 'Select Netcdf ADCP File:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	rawcdf = [thePath theFile];
end

%create the mask file.
if isempty(theMaskFile) || ~exist(theMaskFile,'file')
	[p, outFile, ext, v] = fileparts(rawcdf);
	theMaskFile = fullfile(p,[outFile '.msk']);
	ncmkmask(rawcdf,theMaskFile);
	disp('Created mask file, '), disp(theMaskFile);
end

% Get ADCP filename.
if any(theNewADCPFile == '*')
	[theFile, thePath] = uiputfile(theNewADCPFile, 'Save masked ADCP File As:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theNewADCPFile = [thePath theFile];
end

%fill it based on the rdi criteria
[theMaskFile,velR,corT,echI,Pgd]=fillmsk(rawcdf,theMaskFile);

if ~noninteractive,
    disp('In the following figure bad velocity data are displayed in black');
    disp('Mark any additional bad data points');
    disp('Then click "Done" on the StarBare menu, and hit enter');
    pause(5)

    %check it out
    starbare(rawcdf,theMaskFile);

    pause

    %If the starbare window is not closed, make sure masking is complete
    h=findobj('Name','starbare Browser');
    if ~isempty(h);
        disp('Please close starbare window if masking is complete.');
        wait(1)
        figure(gcf)
        disp(' ');
        disp('Hit any key to continue "runmask.m"');
        pause
    end
end
      
%Write the masked data file(still in beam coordinates)
postmask(rawcdf,theMaskFile,theNewADCPFile);
disp('Masking is complete based on the read mask file');

%Add in history comment
thecomment = sprintf('The data were filtered using rdi quality control factors in %s v%3.1f\n',mfilename, version);
history(theNewADCPFile,thecomment);

cdf = netcdf(rawcdf,'write')
% add minimums and maximums
add_minmaxvalues(cdf);
close(cdf)

