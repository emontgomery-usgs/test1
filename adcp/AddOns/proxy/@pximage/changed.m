function theResult = changed(self, newFlag)

% pximage/changed -- Get/set "change" flag.
%  changed(self) returns the "change" flag of self,
%   a "pximage" object, either 0 or 1.
%  changed(self, newFlag) sets the "changed" flag
%   of self to the newFlag, either 0 or 1.


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
 
% Version of 12-Jan-1999 18:06:37.

if nargin < 1, help(mfilename), return, end

if nargin < 2
	result = pxget(self, 'itHasChanged');
else
	result = self;
	pxset(result, 'itHasChanged', newFlag);
end

if nargout > 0
	theResult = result;
else
	disp(result)
end
