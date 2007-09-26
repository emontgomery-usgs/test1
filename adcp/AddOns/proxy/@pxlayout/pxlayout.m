function self = PXLayout(theUI, theNormalizedPos, thePixelOffset)

% PXLayout -- Layout geometry for a "px" UI object.
%  PXLayout(theUI, theNormalizedPos, thePixelOffset) creates
%   a PXLayout object for the UI, a uicontrol.  The given geometry
%   refers to the normalized and pixel dimensions of the figure in
%   which the UI control is embedded.


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
 
% Version of 16-Apr-1997 14:08:44.

if nargin < 1, help(mfilename), setdef(mfilename), return, end

if nargin < 2, thePixelOffset = [0 0 0 0]; end

theStruct.itSelf = theUI;
self = class(theStruct, 'pxlayout', px(theUI));
pxset(self, 'itsObject', self)

h = px(self);
pxenable(h, h);
pxenable(h, 'Callback')

pxset(h, 'itsNormalizedPos', theNormalizedPos)
pxset(h, 'itsPixelOffset', thePixelOffset)
