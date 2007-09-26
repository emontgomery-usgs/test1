function theResult = LabelSafe(theLabel)

% LabelSafe -- Safe label for axes.
%  LabelSafe('theLabel') modifies 'theLabel' by
%   "escaping" instances of '\', '_', and '\^',
%   after removing all instances of char(0) and '\0'.
%   Existing escapes remain intact.   The result is
%   suitable as a title or axis label on a graph.
%  LabelSafe (no argument) demonstrates itself.


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
 
% Version of 01-Aug-1997 14:37:55.
% Version of 17-Nov-1997 13:35:12.

if nargin < 1
   help(mfilename)
   label = '\0_hello\world^';
   result = labelsafe(label);
   begets(mfilename, 1, label, result)
   return
end

result = theLabel;

if ~isempty(result)
   result = strrep(result, char(0), '');
   result = strrep(result, '\0', '');

   result = strrep(result, '\\', char(1));
   result = strrep(result, '\_', char(2));
   result = strrep(result, '\^', char(3));

   result = strrep(result, '\', '\\');
   result = strrep(result, '_', '\_');
   result = strrep(result, '^', '\^');

   result = strrep(result, char(1), '\\');
   result = strrep(result, char(2), '\_');
   result = strrep(result, char(3), '\^');
end

if ~isempty(result)
   f = find(result ~= ' ');
   if any(f)
      result = result(f(1):f(length(f)));
   end
end

if nargout > 0
   theResult = result;
   else
   disp(result)
end
