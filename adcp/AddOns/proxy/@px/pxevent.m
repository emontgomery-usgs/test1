function theResult = PXEvent(self, thePXEvent, theMessage)

% PXEvent -- Process an event.
%  PXEvent(self, thePXEvent, theMessage) processes thePXEvent
%   and theMessage that have been sent to self, a "px" object.
%   Menu selections and non-scrollbar callbacks cause thePXEvent
%   to be displayed with no further action.


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
 
% Version of 08-Apr-1997 10:37:15.

if nargin < 1, help(mfilename), return, end

if nargin < 2, thePXEvent = ''; end
if nargin < 3, theMessage = []; end

result = [];

switch lower(thePXEvent)
case 'buttondownfcn'
case 'callback'
   switch lower(get(gcbo, 'Tag'))
   case {'xscroll', 'yscroll', 'zscroll', 'cscroll'}
      pxscroll(gcbo)
   otherwise
      disp(thePXEvent)
   end
case 'closerequestfcn'
case 'resizefcn'
   pxresize(self)
case 'windowbuttondownfcn'
   if strcmp(get(px(self), 'SelectionType'), 'open')
      thePXEvent = 'DoubleClickFcn';
      pxhome
   end
   pxenable(px(self), 'WindowButtonMotionFcn')
case 'windowbuttonmotionfcn'
case 'windowbuttonupfcn'
   set(px(self), 'WindowButtonMotionFcn', '')
otherwise
   disp(thePXEvent)
end

if nargout > 0
   theResult = result;
end
