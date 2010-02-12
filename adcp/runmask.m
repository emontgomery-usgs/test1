function [theNewADCPFile, theMaskFile] = runmask (rawcdf,theMaskFile,theNewADCPFile, noninteractive)

%RUNMASK runs the masking functions to produce a newly masked file.
%This will use the settings in the cdf file to mask and then allow the user
%to pick additional bad points.
%If no data file is given, the uigetfile is invoked
%If no mask file is given the file is created based on the rawcdf filename
%If a name is not give for the New ADCP File, the uigetfile dialog is invoked
%
%function [theNewADCPFile, theMaskFile] = runmask (rawcdf,theMaskFile,theNewADCPFile, noninteractive)
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
%mkadcpmask.m, fillmask.m (premask.m), StareBare Browser, postmask.m


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
%	mkadcpmask.m
%	fillmsk.m
%	StarBare directory, including postmask.m and modified premask

% Updated 18-jun-2008 (MM) change to SVN revision info
% update 13-mar-2008 - replace starbeam with maskADCP
% update 31-jan-2007 - remove batch calls
% updated 26-jan-2007 - update mins and maxes
% updated 22-dec-2006 - added ability to run noninteractive
%updated 09-Jul-2001 - corrected capitalization problems so won't crash in UNIX (ALR)
%updated 28-Dec-2000 09:03:22 - Added linefeeds to thecomment for history attribute (ALR)
%updated 10-Aug-1999 16:20:42


ncquiet

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1063 $';
disp(sprintf('%s %s running',mfilename,rev_info))


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

% Get ADCP filename.
if any(theNewADCPFile == '*')
    %[theFile, thePath] = uiputfile(theNewADCPFile, 'Save masked ADCP File As:');
    [theFile, thePath] = uiputfile('*M.cdf', 'Save masked ADCP File As:');
    if ~any(theFile), return, end
    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    theNewADCPFile = [thePath theFile];
end

replacemask = 0;
if isempty(theMaskFile) || ~exist(theMaskFile,'file'),
    % if the file doesn't exist or wasn't supplied, we have to make something
    [p, outFile] = fileparts(rawcdf);
    theMaskFile = fullfile(p,[outFile '.msk']);
end

if exist(theMaskFile,'file'),
    % if we are interactive, ask to replace the mask file
    if ~noninteractive,
        button = questdlg(sprintf('Replace existing mask file %s?',theMaskFile),...
            'Yes','No');
        replacemask = 0;
        if ~isempty(button) || ~strcmpi(button,'cancel'),
            if strcmpi(button,'yes'),
                disp(sprintf('%s replacing %s from scratch',mfilename,theMaskFile))
                replacemask = 1;
            end
        end
    end
else % it doesn't exist, we need to make it
    replacemask = 1; 
end

if replacemask,
    if isempty(theMaskFile) || ~exist(theMaskFile,'file')
        [p, outFile] = fileparts(rawcdf);
        theMaskFile = fullfile(p,[outFile '.msk']);
        mkadcpmask(rawcdf,theMaskFile);
        disp('Created mask file, '), disp(theMaskFile);
    end

    %fill it based on the rdi criteria
    [theMaskFile]=fillmsk(rawcdf,theMaskFile);

    % fix the mask file's coordinate variables
    % also fix the newly generated file's coordinate variables as they seem to
    % get messed up too.
    %fixmask(rawcdf,theMaskFile);
else
    disp(sprintf('%s using existing mask file %s',mfilename,theMaskFile));
end

if ~noninteractive,
    disp('The maskADCP window will open');
    disp('Mark any additional bad data points');
    disp('Then close the maskADCP window, and hit enter at the >> prompt');
    pause(5)

    maskADCP('file',rawcdf,'mask',theMaskFile)

    pause

    % make sure maskADCP is closed and files are closed
    kids = allchild(findobj); % all the open windows
    for idx = 1:length(kids),
        if length(kids) > 1,
            if any(strcmp(get(kids{idx},'Tag'),'maskADCPwindow')),
                for fidx = 1:length(kids{idx})
                    if strcmp(get(kids{idx}(fidx),'Tag'),'maskADCPwindow'),
                        delete(kids{idx}(fidx)); % deleting the maskADCP object will close files properly
                    end
                end
            end
        elseif strcmp(get(kids,'Tag'),'maskADCPwindow'),
            delete(kids); % deleting the maskADCP object will close files properly
        end
    end
end

%Write the masked data file(still in beam coordinates)
postmask(rawcdf,theMaskFile,theNewADCPFile);

%fixmask(rawcdf,theNewADCPFile);

disp('Masking is complete based on the read mask file');

%Add in history comment
thecomment = sprintf('The data were filtered using rdi quality control factors in %s %s\n',...
    mfilename, rev_info);
history(theNewADCPFile,thecomment);

cdf = netcdf(rawcdf,'write');
% add minimums and maximums
add_minmaxvalues(cdf);
close(cdf)

