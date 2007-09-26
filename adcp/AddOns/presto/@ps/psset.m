function theResult = psset(self, theField, theValue)

% ps/psset -- Set a "ps" field value.
%  psset(self, 'theField', thevalue) sets the value
%   of 'theField' associated with self, a "ps" object,
%   to theValue.  If the field is the name of a graphics
%   associated with the handle of self, that property is
%   set.
%  psset(self, 'theField') returns the value of the field.
%  psset(self) returns all the current "ps" fields in a 
%   "struct".


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
 
% Version of 09-Dec-1999 00:44:58.
% Updated    09-Dec-1999 00:44:58.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

result = [];

if nargin < 2
	result = data(self);
elseif nargin < 3
	try
		if ~isequal(lower(theField), 'userdata')
			result = get(handle(self), theField);
		else
			theData = data(self);
			result = theData.UserData;
		end
	catch
		theData = data(self);
		if isfield(theData, theField)
			result = getfield(theData, theField);
		end
	end
else
	try
		if ~isequal(lower(theField), 'userdata')
			set(handle(self), theField, theValue);
			result = self;
		else
			theData = setfield(data(self), 'UserData', theValue);
			result = data(self, theData);
		end
	catch
		theData = setfield(data(self), theField, theValue);
		result = data(self, theData);
	end
end

if nargout > 0
	theResult = result;
else
	assignin('caller', 'ans', result)
end
