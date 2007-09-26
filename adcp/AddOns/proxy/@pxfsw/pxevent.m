function theResult = PXEvent(self, theEvent, theMessage)

% PXEvent -- Process events for a "pxfsw" object.
%  PXEvent(self, theEvent, theMessage) processes
%   events associated with self, a "pxfsw" object.
%   The returned status is non-zero if theEvent
%   was not handled.


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
 
% Version of 16-Apr-1997 09:23:16.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = ''; end
if nargin < 3, theMessage = []; end

if pxverbose
	pxbegets(' ## PXEvent', 3, self, theEvent, theMessage)
end

status = 0;

switch lower(theEvent)
case 'home'
   pxhome
case {'refresh'}
   refresh(px(self));
case {'resize'}
   status = pxevent(super(self), 'ResizeFcn', theMessage);
case 'view2d'
   theGca = gca;
   f = findobj('Parent', gcf, 'Type', 'axes');
   for i = 1:length(f)
      axes(f(i))
      view(2)
   end
   axes(theGca)
case 'view3d'
   theGca = gca;
   f = findobj('Parent', gcf, 'Type', 'axes');
   for i = 1:length(f)
      axes(f(i))
      view(3)
   end
   axes(theGca)
case 'zoomin'
   pxzoom(2)
case 'zoomout'
   pxzoom(0.5)
case 'zoominx'
   pxzoom(2, 'x')
case 'zoominy'
   pxzoom(2, 'y')
case 'zoomoutx'
   pxzoom(0.5, 'x')
case 'zoomouty'
   pxzoom(0.5, 'y')
case 'autozoomon'
   zoomsafe on
case 'autozoomout'
   zoomsafe out
case 'autozoomoff'
   zoomsafe off
case 'landscape'
   orient landscape
case 'portrait'
   orient portrait
case 'tall'
   orient tall
case 'controls'
   f = findobj(gcf, 'Type', 'uicontrol');
   theVisible = 'on';
   for i = 1:length(f)
      theVisible = get(f(i), 'Visible');
      if strcmp(theVisible, 'off')
         break
      end
   end
   switch theVisible
   case 'on'
      set(f, 'Visible', 'off')
   case 'off'
      set(f, 'Visible', 'on')
   end
case 'menubar'
   switch get(gcf, 'MenuBar')
   case 'figure'
      set(gcf, 'MenuBar', 'none')
   case 'none'
      set(gcf, 'MenuBar', 'figure')
   otherwise
      status = -1;
   end
case 'resizable'
   switch get(gcf, 'Resize')
   case 'on'
      set(gcf, 'Resize', 'off')
   case 'off'
      set(gcf, 'Resize', 'on')
   otherwise
      status = -1;
   end
otherwise   % Inherit.
   status = pxevent(super(self), theEvent, theMessage);
end

if nargout > 0, theResult = status; end
