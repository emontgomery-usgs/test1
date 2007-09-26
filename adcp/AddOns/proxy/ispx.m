function theResult = IsPX(theItem)

% IsPX -- Is the item a PXObject or PXReference?
%  IsPX(x) returns 1 if theItem is a PXObject,
%   2 if it is a PXReference, and 3 if it is
%   a PXStruct.  Otherwise, a value of 0 is
%   returned.


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
 
% Version of 09-Apr-1997 10:56:16.

if nargin < 1, help(mfilename), return, end

theClass = class(theItem);
switch theClass
case 'struct'
   result = 0;
   theObject = eval('theItem.itsObject', '[]');
   if ispx(theObject), result = 3; end
case 'double'
   result = 0;
   if ishandle(theItem)
      if ispx(get(theItem, 'UserData'))
         result = 2;
      end
   end
otherwise
   result = isa(theItem, 'px');
end

if nargout > 0
   theResult = result;
  else
   disp(result)
end
