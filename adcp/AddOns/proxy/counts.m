function [theCounts, theRanges, theBins] = Counts(theData, theBins)

% Counts -- Frequency counts of values in an array.
%  Counts(theData, theBins) returns the columnwise frequency
%   distribution of theData array, using theBins, a vector
%   of increasing bounding values for the bins to be tallied.
%   Bins for -Inf, +Inf, and NaN are added gratuitously to
%   capture the out-of-range and non-finite values in theData.
%   If theBins is a scalar, it refers to the number of bins to
%   use for the finite data range.  Finite-values equal to the
%   smallest and largest finite-boundaries are placed in the
%   lowest and highest finite bins, respectively.  The lower
%   boundary of each bin is otherwise exclusive, whereas the
%   upper boundary is inclusive.  If no output argument is
%   provided, the counts are displayed with the corresponding
%   ranges appended to the rightside of the array.
%  [theCounts, theRanges, theBins] = Counts(...) also returns
%   two-column array of theRanges represented by theBins, plus
%   theBins vector itself.
%  Counts (no argument) demonstrates itself with random
%   integers and two equally-spaced bins.


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
 
% Version of 16-Jul-1997 11:25:33.

if nargin < 1, help(mfilename), theData = 'demo'; end
if nargin < 2, theBins = 2; end

if strcmp(theData, 'demo'), theData = [4 5]; end
if length(theData) == 1, theData = [theData theData]; end

if length(theData) == 2
   theOriginalData = fix(rand(theData) .* 100) + 1;
   theOriginalData(1) = 0; theOriginalData(2) = 100;
   theBins = [10 50 90];
   [result, theRanges, theBins] = counts(theOriginalData, theBins);
   if nargout < 1
      theOriginalData
      theCounts_and_theRanges = [result theRanges]
     else
      theCounts = result;
   end
   return
end

if length(theBins) == 1
   nBins = theBins;
   k = finite(theData);
   mn = min(min(theData(k)));
   mx = max(max(theData(k)));
   delta = (mx - mn) ./ nBins;
   theBins = [mn:delta:mx-delta./2 mx];
end

theBins = theBins(:);
theBins = sort([-inf; theBins; +inf; nan]);

[m, n] = size(theData);
result = zeros(length(theBins), n);

for i = 1:length(theBins)-1
   if i ~= 2
      result(i, :) = ones(1, m) * (theData <= theBins(i));
     else
      result(i, :) = ones(1, m) * (theData < theBins(i));
   end
end
result(2:length(theBins), :) = diff(result);
result(length(theBins), :) = ones(1, m) * isnan(theData);
result(1, :) = [];

m = length(theBins)-1;
theRanges = zeros(m, 2);
theRanges(1, :) = -Inf;
theRanges(1:m-2, 1) = theBins(1:m-2);
theRanges(2:m-2, 2) = theBins(3:m-1);
theRanges(m-1, :) = inf;
theRanges(m, :) = nan;
theRanges(1, 2) = theRanges(2, 1);
theRanges(m-1, 1) = theRanges(m-2, 2);

if nargout < 1
   disp([result theRanges])
  else
   theCounts = result;
end
