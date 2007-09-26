function theResult = PXScrollbar(theLocation, theSettings)

% PXScrollbar -- Constructor for a scrollbar control.
%  PXScrollbar(theLocation, theSettings) returns a PXObject
%   for a new scrollbar control, whose location is given by
%   a string: '{XYZC}Scroll'.  The slider responds to mouse
%   actions through its 'Callback' to 'PXScroll()'.


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
 
% Version of 09-Apr-1997 14:49:48.

if nargin < 1, theLocation = 'XScroll'; end
if nargin < 2, theSettings = [0.5 0 1]; end

if nargout > 0, theResult = []; end

if isstr(theLocation)
   switch upper(theLocation(1))
     case {'X', 'H', 'B'}   % XScroll, HScroll, or Bottom.
      theLocation = 'XScroll';
      theNormalizedPos = [0 0 1 0];
      thePixelOffset = [16 0 -32 16];
     case {'Y', 'V', 'R'}   % YScroll, VScroll, or Right.
      theLocation = 'YScroll';
      theNormalizedPos = [1 0 0 1];
      thePixelOffset = [-16 16 16 -32];
     case {'Z', 'L'}        % ZScroll or Left.
      theLocation = 'ZScroll';
      theNormalizedPos = [0 0 0 1];
      thePixelOffset = [0 16 16 -32];
     case {'C', 'T'}        % CScroll or Top.
      theLocation = 'CScroll';
      theNormalizedPos = [0 1 1 0];
      thePixelOffset = [16 -16 -32 16];
     otherwise
      theNormalizedPos = [0.25 0.25 0.5 0.5];   % Huge.
      thePixelOffset = [0 0 0 0];
   end
  elseif all(size(theLocation) == [2 4])
   theNormalizedPos = theLocation(1, :);
   thePixelOffset = theLocation(2, :);
  else
   return
end

theScrollbar = uicontrol('Style', 'slider', ...
                         'String', theLocation, ...
                         'Tag', theLocation, ...
                         'Min', theSettings(2), ...
                         'Max', theSettings(3), ...
                         'Value', theSettings(1), ...
                         'Callback', 'pxscroll');

theClass = 'pxscrollbar';
theSuperClass = 'px';
theUI = theScrollbar;

theStruct.itSelf = theUI;
self = class(theStruct, 'pxscrollbar', ...
                pxlayout(theUI, theNormalizedPos, thePixelOffset));
pxset(self, 'itsObject', self)   % Bind to itself.

% Initialization via the PXReference.

h = px(self);
pxenable(h, h)
pxset(h, 'itsSettings', theSettings);
pxresize(h)

if nargout > 0,  theResult = self; end
