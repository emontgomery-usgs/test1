function theResult = fcopy(theSource, theDestination, maxCharacters)

% fcopy -- Copy (duplicate) a file.
%  fcopy(theSource, theDestination, maxCharacters) copies the
%   contents of theSource file into theDestination file,
%   in increments of maxCharacters (default = 16K).  Each
%   file can be specified by its name or by an existing
%   file-pointer.
%  fcopy (no arguments) demonstrates itself by copying
%   "fcopy.m" to "junk.junk".


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

if nargin < 1
   help fcopy
   fcopy('fcopy.m', 'junk.junk');
   return
end
if nargin < 2, return, end
if nargin < 3, maxCharacters = 1024 .* 16; end

if isstr(theSource)
   src = fopen(theSource, 'r');
   if src < 0, error(' ## Source file not opened.'); end
  else
   src = theSource;
end

if isstr(theDestination)
   dst = fopen(theDestination, 'w');
   if dst < 0, error(' ## Destination file not opened.'); end
  else
   dst = theDestination;
end

while (1)
   [s, inputCount] = fread(src, [1 maxCharacters], 'char');
   if inputCount > 0, outputCount = fwrite(dst, s, 'char'); end
   if inputCount < maxCharacters | outputCount < inputCount, break, end
end

if isstr(theDestination), result = fclose(dst); end
if isstr(theSource), result = (fclose(src) | result); end

if nargout > 0, theResult = result; end
