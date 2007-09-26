function theResult = isps(theItem)

% isps -- Is this a "ps" object?
%  isps(theItem) returns logical(1) (TRUE) if theItem
%   is a "ps" object or is derived from the "ps"
%   class; otherwise, it returns logical(0) (FALSE).
%   If theItem is a handle, the corresponding "UserData"
%   is examined instead.


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
 
% Version of 07-Dec-1999 23:19:23.
% Updated    09-Dec-1999 05:26:41.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

result = logical(0);

switch class(theItem)
case 'double'
	if ishandle(theItem)
		u = get(theItem, 'UserData');
		if isstruct(u) & isfield(u, 'ps_Self')
			result = isa(getfield(u, 'ps_Self'), 'ps');
		end
	end
otherwise
	result = isa(theItem, 'ps');
end

if nargout > 0
	theResult = result;
else
	assignin('caller', 'ans', result)
	disp(result)
end
