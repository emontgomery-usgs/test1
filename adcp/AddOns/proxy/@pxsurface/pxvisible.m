function theResult = PXVisible(self, theVisible)

% PXSurface/PXVisible -- Show or hide.
%  PXVisible(self, 'theVisible') shows or hides self, a "pxsurface"
%   object, according to 'theVisible' ('on' [default] or 'off'),
%   which may be input optionally as 1 or 0.


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
 
% Version of 30-Jul-1997 09:24:26.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theVisible = 'on'; end

if ~isstr(theVisible)
   switch theVisible
   case 0
      theVisible = 'off';
   otherwise
      theVisible = 'on';
   end
end

h = [pxget(self, 'itsMask') px(self)];
set(h, 'Visible', theVisible)

if nargout > 0, theResult = self; end
