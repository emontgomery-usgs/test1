function theResult = PXResize(self)

% PXLayout/PXResize -- Resize a "pxlayout" graphical entity.
%  PXResize(self) resizes the graphic associated with
%   self, a "pxlayout" object.


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
 
% Version of 09-Apr-1997 15:33:56.

theUI = px(self);

theNormalizedPos = pxget(self, 'itsNormalizedPos');
thePixelOffset = pxget(self, 'itsPixelOffset');

if ~all(size(theNormalizedPos) == [1 4]) | ...
   ~all(size(theNormalizedPos) == [1 4])
   return
end

theFigure = get(self.itSelf, 'Parent');

oldUnits = get(theFigure, 'Units');
set(theFigure, 'Units', 'pixels')
theFigurePos = get(theFigure, 'Position');
set(theFigure, 'Units', oldUnits)

theUIPos = theFigurePos([3:4 3:4]) .* theNormalizedPos + thePixelOffset;

oldUnits = get(theUI, 'Units');
set(theUI, 'Units', 'pixels')
set(theUI, 'Position', theUIPos)
set(theUI, 'Units', oldUnits)
