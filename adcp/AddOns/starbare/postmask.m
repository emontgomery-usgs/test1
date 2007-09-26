function postmask(theADCPFile, theMaskFile, theNewADCPFile)

% postmask -- Mask an ADCP data file, based on a mask file.
%  postmask('theADCPFile', 'theMaskFile', 'theNewADCPFile')
%   creates and masks a copy of the given ADCP file, using
%   the information given in the mask file.  The ADCP data
%   are set to their respective fill-values wherever the
%   corresponding mask values are non-zero.  All other
%   values remain intact, including those which already
%   equal the fill-value.  When filenames are not given,
%   the "uigetfile" dialog is invoked.


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

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jul-1999 15:55:04.
% Updated    14-Jul-1999 16:46:34.
% updated    14-Jul-2005 (SDR)- Fixed error when copying theADCPFile to the
%               theNewADCPFile so that it can now properly locate the file

CHUNK = 1000;

if nargin < 1, help(mfilename), end

if nargin < 1, theADCPFile = ''; end
if nargin < 2, theMaskFile = ''; end
if nargin < 3, theNewADCPFile = ''; end

if isempty(theADCPFile), theADCPFile = '*'; end
if isempty(theMaskFile), theMaskFile = '*'; end
if isempty(theNewADCPFile), theNewADCPFile = '*'; end

% Get ADCP and mask filenames.

if any(theADCPFile == '*')
	[theFile, thePath] = uigetfile(theADCPFile, 'Select ADCP File:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theADCPFile = [thePath theFile];
end

theSuggested = [theADCPFile '.masked'];
f = find(theSuggested == filesep);
if any(f), theSuggested(1:f(end)) = ''; end

if any(theMaskFile == '*')
	[theFile, thePath] = uigetfile(theMaskFile, 'Select Mask File:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theMaskFile = [thePath theFile];
end

if any(theNewADCPFile == '*')
	if isequal(theNewADCPFile, '*')
		theNewADCPFile = theSuggested;
	end
	[theFile, thePath] = uiputfile(theNewADCPFile, 'Save As ADCP File:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	theNewADCPFile = [thePath theFile];
end

% Copy the ADCP file to a new output file.

if ~isequal(theADCPFile, theNewADCPFile)
	if exist(theNewADCPFile) == 2
		delete(theNewADCPFile)
	end
	if isunix
		eval(['!cp ' theADCPFile ' ' theNewADCPFile])
	elseif any(findstr(lower(computer), 'pcwin')) | isVMS
		%eval(['!copy ' theADCPFile ' ' theNewADCPFile])
        copyfile(theADCPFile,theNewADCPFile) %added 7/14/05 SDR
	elseif any(findstr(lower(computer), 'mac')) & ...
			exist('aduplicate') == 2
		feval('aduplicate', theADCPFile, theNewADCPFile)
	else
		fcopy(theADCPFile, theNewADCPFile)
	end
end

% Open the files.

theADCP = netcdf(theNewADCPFile, 'write');
if isempty(theADCP), return, end
theMask = netcdf(theMaskFile, 'nowrite');
if isempty(theMask), close(theADCP), return, end

% Select those ADCP variables for which
%  there is a corresponding mask variable.

theMaskVars = var(theMask);
theADCPVars = cell(size(theMaskVars));
for i = 1:length(theMaskVars)
	theADCPVars{i} = theADCP{name(theMaskVars{i})};
end

% Read, mask, and write the ADCP data by
%  chunks of records (see CHUNK size above).

for k = 1:length(theMaskVars)
	if ~isempty(theADCPVars{k})
		disp([' ## Masking: ' name(theADCPVars{k})])
		theFillValue = fillval(theADCPVars{k});
		nRecords = size(theMaskVars{k}, 1);
		j = 0;
		while j < nRecords
			remaining = nRecords - j;
			disp([' ## Remaining: ' int2str(remaining) ' records...'])
			i = (j+1):min(j+CHUNK, nRecords);
			theADCPData = theADCPVars{k}(i, :);
			theMaskData = theMaskVars{k}(i, :);
			isMasked = find(theMaskData);
			if any(isMasked)
				theADCPData(isMasked) = theFillValue;
				theADCPVars{k}(i, :) = theADCPData;
			end
			j = j + CHUNK;
		end
	end
end

% Close the files.

close(theMask)
close(theADCP)
