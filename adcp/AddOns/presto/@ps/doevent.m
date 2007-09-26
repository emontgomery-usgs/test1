function theResult = doevent(self, theEvent, theMessage, varargin)

% ps/doevent -- Call "ps" event handler.
%  doevent(self, theEvent, theMessage) calls the registered
%   event handler on behalf of self, a "ps" object.  Menus
%   and controls are processed according to their "Tag"
%   property.  A notice is posted whenever an appropriate
%   event-handler cannot be found.


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
 
% Version of 05-Nov-1999 19:28:46.
% Updated    10-Dec-1999 00:56:21.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = '(none)'; end
if nargin < 3, theMessage = []; end

result = [];

h = gcbo;
if isempty(h) & ishandle(theMessage)
	h = theMessage;
end

% Menus and controls are processed via "Tag".

switch get(h, 'Type')
case {'uimenu', 'uicontrol'}
	theEvent = get(h, 'Tag');
end

theHandler = handler(self, theEvent);

okay = logical(0);

if ~isempty(theHandler)
	try
		result = builtin('feval', theHandler, self, theEvent, theMessage);
		okay = logical(1);
	catch
	end
end

if ~okay
	theEvent = translate(self, theEvent);
	if isempty(theEvent), theEvent = '(none)'; end
	theType = get(gcbo, 'Type');
	disp([' ## No event-handler: ' theEvent ' (' theType ' = ' num2str(gcbo) ')'])
end

if nargout > 0, theResult = self; end
