function self = PXMenu(theHandle, theMenuLabel)

% PXMenu -- No help available.
% PXMenu -- Constructor.
%  PXMenu(theHandle, theMenuLabel) adds a menu item with
%   theMenuLabel to theHandle, either a figure or a menu.
%   The menu level is specified by prepending one '>'
%   to the label for each level.  If the first special
%   character is '-', a separator will preceed the menu.
%   When selected, the menu label is sent to the "pxevent"
%   method of the "pxwindow" that owns the menu.  (Embedded
%   blanks, '.', and '-' are first removed.)
%
%   If just one menu item is requested, the "pxmenu" object
%   is returned.  If more than one is requested with a cell-
%   array of labels, the corresponding handles of the menus
%   are returned.


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
 
% Version of 15-Apr-1997 15:57:36.

if nargin < 1 & nargout < 1, setdef(mfilename), return, end

if isa(theHandle, 'pxmenu'), theHandle = px(theHandle); end

if nargin < 2
   theMenuLabel = theHandle;
   theHandle = gcf;
end

if isstr(theMenuLabel)
   theMenuLabel = {theMenuLabel};
end

if length(theMenuLabel) > 1
   self = zeros(size(theMenuLabel));
   h = theHandle;
   for i = 1:length(theMenuLabel)
      h = px(pxmenu(h, theMenuLabel{i}));
      self(i) = h;
   end
   return
end

theMenu = pxmkmenu(theHandle, theMenuLabel{1});

theStruct.itSelf = theMenu;
self = class(theStruct, 'pxmenu', px(theMenu));
pxset(self, 'itsObject', self)

h = px(self);
pxenable(h, h)
