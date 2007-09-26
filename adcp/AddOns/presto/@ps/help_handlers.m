function theResult = help_handlers(self, varargin)

%    Event-handlers are registered with "ps" using the
% "handler" method, which requires the name of an event,
% such as 'Print', and the name of the corresponding method
% that will handle the event, such as 'doprint'.  Any number
% of event/handler pairs can be placed in the argument list,
% as in "self = handler(self, theEvent, theHandler, ...)".
%    Handlers are always called with three input arguments,
% as in "self = doprint(self, theEvent, theMessage)".
%    See "help ps/handler".


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
 
% Version of 04-Nov-1999 14:41:34.
% Updated    05-Nov-1999 20:08:50.

h = help(mfilename);
helpdlg(h, 'PS Handlers')

if nargout > 0, theResult = self; end
