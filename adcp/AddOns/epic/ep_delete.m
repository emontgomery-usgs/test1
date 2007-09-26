function theResult = EP_Delete(theSource, theDestination, theVariables)

% EP_Delete -- Delete EPIC variables from file to file.
%  EP_Delete('theSource', 'theDestination', {'theVariables', ...})
%   copies 'theSource' file to 'theDestination' file, except those
%   variables named in {'theVariables', ...}.


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
 
% Version of 13-May-1997 14:19:34.

result = [];
if nargout > 0, theResult = result; end

if nargin < 2, help(mfilename), return, end
if nargin < 3, return; end

switch class(theVariables)
case 'cell'
otherwise
   theVariables = {theVariables};
end

% Variable names from source file.

src = epic(theSource, 'nowrite')
if isempty(src)
   if nargout > 0, theResult = -1; end
   return
end
v = ncnames(var(src))
close(src);

% List of variables to be copied.

for k = length(v):-1:1
   for i = 1:length(theVariables)
      if strcmp(v{k}, theVariables{i})
         v(k) = [];
         break
      end
   end
end

% Copy the variable definitions and attributes.

if ~strcmp(theSource, theDestination)
   result = ep_copy(theSource, theDestination, v);
else
   theClipboard = 'ep_clipboard.nc';
   delete(theClipboard)
   result = ep_copy(theSource, theClipboard, v);
   fcopy(theClipboard, theDestination)
   delete(theClipboard)
end

if nargout > 0, theResult = result; end
