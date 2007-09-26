function [theResult, theEvent] = handler(self, varargin)

% ps/handler -- Register a "ps" event-handler.
%  handler(self, 'theEvent', 'theHandler') registers 'theEvent'
%   and 'theHandler' on behalf of self, a "ps" object.
%   Additional event/handler pairs can be given in the
%   argument-list.
%  handler(self, 'theEvent') returns the handler for theEvent,
%   or [] is no such handler has been registered.


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
 
% Version of 05-Nov-1999 00:21:39.
% Updated    05-Nov-1999 00:21:39.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

theHandlers = psget(self, 'itsHandlers');

% Get all the handlers.

if nargin < 2
	if nargout > 0
		theResult = theHandlers;
	else
		assignin('caller', 'ans', theHandlers)
		disp(theHandlers)
	end
	return
end

% Clean-up the event string.

for k = 1:2:length(varargin)
	varargin{k} = translate(self, varargin{k});
end

% Return the handler for the event.

if nargin < 3
	theEvent = varargin{1};
	theHandler = [];
	if ~isempty(theHandlers)
		if isfield(theHandlers, theEvent)
			theHandler = getfield(theHandlers, theEvent);
		end
	end
	if nargout > 0
		theResult = theHandler;
	else
		assignin('caller', 'ans', theHandler)
		disp(theHandler)
	end
	return
end

% Register the events and handlers.

for k = 1:2:length(varargin)
	theEvent = varargin{k};
	theHandler = varargin{k+1};
	theHandlers = setfield(theHandlers, theEvent, theHandler);
end

self = psset(self, 'itsHandlers',  theHandlers);

if nargout > 0
	theResult = self;
else
	assignin('caller', 'ans', self)
end
