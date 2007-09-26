function theResult = enable(self)

% ps/enable -- Enable "ps" callbacks.
%  enable(self) enables all the callbacks associated
%   with self, a "ps" object, except that the "CreateFcn"
%   and "DeleteFcn" are enabled only for figures.  The
%   actions are directed to "psevent", using the actual
%   callback names, as in "psevent ButtonDownFcn".


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
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
 
% Version of 27-Oct-1999 23:30:10.
% Updated    09-Dec-1999 02:42:24.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

theHandle = handle(self);
h = findobj(theHandle);

for k = 1:length(h)
	theType = get(h(k), 'Type');
	theEvents = {};
	switch theType
	case 'figure'
		theEvents = [theEvents ...
			{'WindowButtonDownFcn', 'ResizeFcn', ...
			'CreateFcn', 'CloseRequestFcn'} ...
			];
	case {'axes', 'line', 'patch', 'surface', 'text', 'light'}
		theEvents = [theEvents {'ButtonDownFcn'}];
	case 'uicontrol'
		theEvents = [theEvents {'ButtonDownFcn', 'Callback'}];
	case 'uimenu'
		if ~any(get(h(k), 'Children'))
			theEvents = [theEvents {'Callback'}];
		end
	otherwise
	end
	for i = 1:length(theEvents)
		set(h(k), theEvents{i}, ['psevent ' theEvents{i}])
	end
end

if nargout > 0, theResult = self; end
