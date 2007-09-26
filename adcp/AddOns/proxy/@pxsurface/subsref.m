function theResult = subsref(self, theStruct)

% pxsurface/subsref -- Reference of x, y, z, c, and s data.


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
 
% Version of 18-Jun-1997 09:00:18.

if nargin < 2, help(mfilename), return, end

theType = theStruct(1).type;
theSubs = theStruct(1).subs;
if ~iscell(theSubs), theSubs = {theSubs}; end

inherit = 'result = subsref(super(self), theStruct);';

switch theType
case '.'
   switch theSubs{1}
   case {'x', 'y', 'z', 'c'}
      theTarget = [upper(theSubs{1}) 'Data'];
      result = pxget(self, theTarget);
      [m, n] = size(result);
      if length(theStruct) > 1
         switch theStruct(2).type
         case '()'
            switch length(theStruct(2).subs)
            case 1
               i = theStruct(2).subs{1};
               switch class(i)
               case 'char'
                  switch i
                  case ':'
                     result = result(:);
                  otherwise
                     eval(inherit)
                  end
               case 'double'
                  result = result(i);
               case 'pxsurface'
                  result = result(i);
               otherwise
                  eval(inherit)
               end
            case 2
               i = theStruct(2).subs{1};
               switch class(i)
               case 'char'
                  switch i
                  case ':'
                     i = 1:size(result, 1);
                  otherwise
                  end
               end
               j = theStruct(2).subs{2};
               switch class(j)
               case 'char'
                  switch j
                  case ':'
                     j = 1:size(result, 2);
                  otherwise
                     eval(inherit)
                  end
               otherwise
                  eval(inherit)
               end
               result = result(i, j);
            otherwise
               eval(inherit)
            end
         otherwise
            eval(inherit)
         end
      end
   case 's'
      result = pxvalue(self);
   otherwise
      eval(inherit)
   end
otherwise
   eval(inherit)
end

switch theSubs{1}
case 's'
   result = logical(result);
otherwise
end
   
if nargout > 0, theResult = result; end
