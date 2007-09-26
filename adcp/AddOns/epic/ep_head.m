function theResult = EP_Head(theSource, theDestination, theCount, theStride)

% EP_Head -- First part of an EPIC file.
%  EP_Head('theSource', 'theDestination', theCount, theStride) places
%   the given range of data from the head of 'theSource' file into
%   'theDestination' file.


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
 
% Version of 13-May-1997 14:36:03.

result = [];
if nargout > 0, theResult = result; end

if nargin < 2, help(mfilename), return, end

if nargin < 4, theStride = 1; end

dst = epic(theDestination, 'nowrite');
if isempty(dst), return, end
theSize = size(dst('time'));
close(dst)

theIndices = 1:theStride:theSize;
if theCount == -1, theCount = length(theIndices); end
if length(theInices) > theCount
   theIndices = theIndices(1:theCount);
end

result = ep_trim(theSource, theDestination, theIndices);

if nargout > 0, theResult = result; end
