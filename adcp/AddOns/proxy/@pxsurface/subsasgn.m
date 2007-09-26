function theResult = subsasgn(self, theStruct, theValue)

% pxsurface/subsasgn -- Assignment of x, y, z, c, and s data.


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

if nargin < 3, help(mfilename), return, end

theType = theStruct(1).type;
theSubs = theStruct(1).subs;
if ~iscell(theSubs), theSubs = {theSubs}; end

inherit = 'result = subsasgn(super(self), theStruct, theValue);';

switch theType
case '.'
   switch theSubs{1}
   case {'x', 'y', 'z', 'c'}
      theTarget = [upper(theSubs{1}) 'Data'];
      if length(theStruct) < 2
         temp = pxget(self, theTarget);
         temp(:) = theValue;
        else
         temp = pxget(self, theTarget);
         switch theStruct(2).type
         case '()'
            switch length(theStruct(2).subs)
            case 1
               i = theStruct(2).subs{1};
               if strcmp(i, ':')
                  temp(:) = theValue;
                 else
                  temp(i) = theValue;
               end
            case 2
               i = theStruct(2).subs{1};
               if strcmp(i, ':'), i = 1:size(temp, 1); end
               j = theStruct(2).subs{2};
               if strcmp(j, ':'), j = 1:size(temp, 2); end
               temp(i, j) = theValue;
            otherwise
               eval(inherit)
            end
         otherwise
         end
      end
      theValue = temp;
      result = pxset(self, theTarget, theValue);
      result = pxevent(self, 'refresh', 'all');
   case 's'
      result = pxvalue(self, theValue);
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

if nargout > 0, theResult = self; end
