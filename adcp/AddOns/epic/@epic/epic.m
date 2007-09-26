function self = epic(theFilename, thePermission)

% epic/epic -- Constructor for "epic" class.
%  epic('theFilename', 'thePermission') returns an "epic"
%   object, derived from the "netcdf" class.  This routine
%   does not verify that 'theFilename' refers to an actual
%   EPIC file.


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

  
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-May-1997 11:15:01.
% Updated    09-Sep-1999 11:45:31.

if nargout > 0, self = []; end

if nargin < 1, help(mfilename), return, end

if nargout < 1 & nargin == 1
	if isequal(theFilename, 'version')
		helpdlg(help('epic/version'), 'epic')
		return
	end
end

if nargin == 1
   theNetCDF = netcdf(theFilename);
  elseif nargin == 2
   theNetCDF = netcdf(theFilename, thePermission);
end

if isempty(theNetCDF), return, end

theStruct.ignore = [];
result = class(theStruct, 'epic', theNetCDF);

if nargout > 0
   self = result;
else
   ncans(result)
end
