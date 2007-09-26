function [theCounts, theRanges, theBins] = BitHist(theData, theChunkSize)

% BitHist -- Bit-wise histograms.
%  [theCounts, theRanges, theBins] = bithist(theData, theChunkSize)
%   deconstructs theData (array of integers) into bits, then constructs
%   histograms of the on-bits in the manner of the "counts(...)" function.
%   Bit positions are numbered from 1 (low-order) to nBits (high-order).
%   The chunk-size defaults to one-twentieth of the data length.
%  BitHist('demo') demonstrates itself.


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
 
% Version of 30-Jul-1997 13:45:11.

if nargin < 1, help(mfilename), theData = 'demo'; end

if strcmp(theData, 'demo'), theData = 1000; end

if length(theData) == 1
   nData = theData;
   nBits = 8;
   data = fix(rand(1, nData) .* 2^nBits);
   chunksize = length(data) ./ 20;
   [c, ranges, bins] = bithist(data, chunksize);
   [m, n] = size(c);
   image((1:n), (0:m-1).', c), colorbar
   xlabel('Chunk'), ylabel(['Bits 1..' int2str(nBits)]), title('BitHist Demo')
   figure(gcf)
   return
end

if nargin < 2, theChunkSize = length(theData) ./ 20; end

theData = fix(theData(:).');   % Row data.
nBits = fix(log2(max(theData))) + 1;

x = (1:nBits).' * ones(1, length(theData));

d = theData;
for i = 1:nBits
   r = rem(d, 2);
   x(i, :) = x(i, :) .* r;
   d = (d - r) ./ 2;
end

[m, n] = size(x);
y = zeros(m .* theChunkSize, fix((n + theChunkSize - 1) ./ theChunkSize));
y(:) = x;

theBins = [0.5:1:nBits+1];
[theCounts, theRanges, theBins] = counts(y, theBins);
