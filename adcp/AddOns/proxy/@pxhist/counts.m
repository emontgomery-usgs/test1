function theResult = Counts(self, theBins, theChunkSize)

% Counts -- Update histogram counts.
%  Counts(self, theBins, theChunkSize) updates self,
%   a "pxhist" object, with the new parameters.


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
 
% Version of 29-Jul-1997 14:58:12.

theXData = pxget(self, 'itsXData');
theYData = pxget(self, 'itsYData');
theOldBins = pxget(self, 'itsBins');
theOldChunkSize = pxget(self, 'itsChunkSize');

if nargin < 2, theBins = 10; end
if nargin < 3, theChunkSize = fix((length(theXData) + 19) ./ 20); end

pxdelete(self)

self = pxhist(theXData, theYData, theBins, theChunkSize);

if nargout > 0, theResult = self; end
