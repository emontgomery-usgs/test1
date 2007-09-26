function theResult = UnNest(theCellArray)

% UnNest -- Un-nest cells.
%  UnNest(theCellArray) un-nests theCellArray and
%   returns a column cell-array of the non-cell
%   contents of theCellArray.


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
 
% Version of 10-Apr-1997 11:05:13.

if nargin < 1, help(mfilename), return, end

if ~iscell(theCellArray)
   theCellArray = {theCellArray};
end

result = cell(1, 0);

for i = 1:prod(size(theCellArray))
   c = theCellArray{i};
   if iscell(c)
      c = unnest(c);
     else
      c = {c};
   end
   result = [result; c];
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
