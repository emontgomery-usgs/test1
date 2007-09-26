function theResult = PXValue(self, theValue)

% PXValue -- Set/get the value.
%  PXValue(self, theValue) sets the value of self,
%   a "pxsurface", by selecting those points of self
%   indicated by the indices given in theValue.
%   Use a value of [] to de-select the whole surface.
%  PXValue(self) returns a logical array whose value
%   is 1 for each selected element of self.


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
 
% Version of 06-Jun-1997 11:00:55.

if nargin < 1, help(mfilename), return, end

g = pxget(self, 'itsCompanion');
gz = get(g, 'ZData');
[m, n] = size(gz);
i = 2:2:m; j = 2:2:n;
selected = ~isnan(gz(i, j));

if nargin > 1
   selected = theValue;
   if isempty(selected)
      gz(i, j) = NaN;
     else
      h = px(self);
      zz = get(h, 'ZData') + 1;
      zz(~selected) = NaN;
      gz(i,  j) = zz + 1;
   end
   set(g, 'ZData', gz)
end
  
result = selected;

if nargout > 0, theResult = result; end
