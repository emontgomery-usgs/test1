function theResult = EP_Copy(theSource, theDestination, theVariables)

% EP_Copy -- Copy EPIC variables from file to file.
%  EP_Copy('theSource', 'theDestination', {'theVariables'}) copies
%   {'theVariables'} (names) from 'theSource' file to 'theDestination'
%   file.


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
if strcmp(theSource, theDestination)
   disp(' ## Source and destination files must be different.')
   return
end

if nargin < 3
   src = epic(theSource, 'nowrite');
   if isempty(src), return, end
   theVariables = ncnames(var(src));
   close(src)
end

switch class(theVariables)
case 'cell'
otherwise
   theVariables = {theVariables};
end

% Open files.

if exist(theDestination) == 2
   dst = epic(theDestination, 'write');
  else
   dst = epic(theDestination, 'noclobber');
end

if isempty(dst)
   if nargout > 0, theResult = -1; end
   return
end

src = epic(theSource, 'nowrite');
if isempty(src)
   if ~isempty(dst), close(dst), end
   if nargout > 0, theResult = -1; end
   return
end

% Copy global attributes.

theGlobalAttributes = att(src);
for i = 1:length(theGlobalAttributes)
   copy(theGlobalAttributes{i}, dst)
end

% Copy dimensions.

theDimensions = dim(src);
for i = 1:length(theDimensions)
   copy(theDimensions{i}, dst)
end

% Dereference the variable names.

for k = 1:length(theVariables)
   theVars = src{theVariables{k}};
end

% Copy variable definitions and attributes.

for k = 1:length(theVariables)
   copy(theVars{k}, dst, 0, 1)
end

% Copy variable data.

for k = 1:length(theVariables)
   copy(theVars{k}, dst, 1, 0)
end

close(dst)
close(src)
