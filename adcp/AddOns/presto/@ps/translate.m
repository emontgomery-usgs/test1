function theResult = translate(self, theEvent)

% ps/translate -- Translate a "ps" event.
%  translate(self, 'theEvent') converts 'theEvent'
%   to canonical form for use by "ps" event
%   handlers.  The result is lowercase, free of
%   blanks, and consists entirely of alphanumeric
%   characters and '_'.


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
 
% Version of 09-Dec-1999 02:45:49.
% Updated    09-Dec-1999 02:45:49.

if nargout > 0, theResult = []; end
if nargin < 2, help(mfilename), return, end

result = lower(theEvent);

theLetters = char([abs('a'):abs('z') abs('0'):abs('9') '_']);
for i = length(result):-1:1
	if ~any(result(i) == theLetters)
		result(i) = '';
	end
end

if nargout > 0
	theResult = result;
else
	assignin('caller', 'ans', result)
	disp(result)
end
