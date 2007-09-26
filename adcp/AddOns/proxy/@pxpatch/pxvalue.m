function theResult = PXValue(self, theValue)

% PXValue -- Set/get the value.
%  PXValue(self, theValue) sets the value of self,
%   a "pxpatch".  Use a value of 0 or [] to de-select
%   the patch, and 1 to select it.
%  PXValue(self) returns 1 for if the patch associated
%   with self is selected; otherwise, 0.


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
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
 
% Version of 06-Jun-1997 11:00:55.

if nargin < 1, help(mfilename), return, end

h = px(self);

if nargin > 1
   set(h, 'SelectionHighlight', 'on')
   if isempty(theValue), theValue = 0; end
   selected = any(theValue);
   switch theValue
   case 0
      set(h, 'Selected', 'off')
   otherwise
      set(h, 'Selected', 'on')
   end
end

selected = get(h, 'Selected');
switch lower(selected)
case 'off'
   selected = 0;
case 'on'
   selected = 1;
end

if nargout > 0, theResult = selected; end
