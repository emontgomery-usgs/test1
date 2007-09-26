function theResult = PXHist(theXData, theYData, theBins, theChunkSize)

% PXHist -- THisto analog.
%  PXHist(theXData, theYData, theBins, theChunkSize) returns a "pxhist"
%   object whose counts are computed from the given data and parameters.
%   TheBins defaults to 10 equally-spaced bins.  TheChunkSize defaults
%   to 1/20 the length of the data.


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
 
% Version of 22-Jul-1997 15:04:42.

if nargin < 1, help(mfilename), theXData = 'demo'; end

if strcmp(theXData, 'demo'), theXData = 1000; end

if length(theXData) == 1
   theFigureName = 'Thist Demo';
   f = findobj('Type', 'figure', 'Name', theFigureName);
   if ~any(f)
      f = figure('Name', theFigureName);
   end
   figure(f(1))
   delete(get(gcf, 'Children'))
   nPoints = theXData;
   theChunkSize = 20;
   if nargin > 1, theChunkSize = theYData(1); end
   theXData = (0:nPoints-1) ./ (nPoints-1);
   theYData = cumsum(rand(size(theXData)) - 0.5);
   ymin = min(min(theYData));
   ymax = max(max(theYData));
   theBins = ymin + (0:10) .* (ymax - ymin) ./ 10;
   subplot(2, 1, 1)
   thePXLine = pxline(theXData, theYData);
   axis tight
   subplot(2, 1, 2)
   result = pxhist(theXData, theYData, theBins, theChunkSize);
   axis tight
   zoomsafe all
   if nargout > 0, theResult = result; end
   return
end

if nargin < 3, theBins = 10; end
if nargin < 4, theChunkSize = 0; end

if theChunkSize < 1
   theChunkSize = fix((length(theXData) + 19) ./ 20);
end

m = min(theChunkSize, length(theXData));
n = fix((length(theXData) + theChunkSize - 1) ./ theChunkSize);

x = zeros(m, n) + NaN;
y = zeros(m, n) + NaN;
x(1:length(theXData)) = theXData(:);
y(1:length(theYData)) = theYData(:);
[theCounts, theRanges, theBins] = counts(y, theBins);
x = min(min(x)) + (0:n) .* (max(max(x)) - min(min(x))) ./ n;
x(length(x)) = max(max(x));
y = theBins(2:length(theBins)-2);
y = theBins(1:length(theBins)-0);
y(1) = 2*y(2) - y(3);
y(length(y)-1) = 2*y(length(y)-2) - y(length(y)-3);
y(length(y)) = 2*y(length(y)-1) - y(length(y)-2);
[x, y] = meshgrid(x, y);
z = zeros(size(x));
[m, n] = size(theCounts);
c = theCounts(2:m-2, :);
c = theCounts(1:m-0, :);
[m, n] = size(c);
c(m+1, n+1) = 0;   % Extra row and column of color.

% Create the object.

theStruct.itSelf = [];
self = class(theStruct, 'pxhist', pxsurface(x, y, z, c));
self.itSelf = px(self);

pxenable(self)   % Generic enable.

% Save the original data and parameters.

pxset(self, 'itsXData', theXData)
pxset(self, 'itsYData', theYData)
pxset(self, 'itsBins', theBins)
pxset(self, 'itsChunkSize', theChunkSize)

% Set the colormap.

theColorMap = zeros(10, 3);
theColorMap(:, 1) = ((19:-2:1)./20).';
theColorMap(:, 2) = theColorMap(:, 1);
theColorMap(:, 3) = 1;   % Mostly blue.
theColorMap = [[1 1 1]; theColorMap; [1 0 0]];
colormap(theColorMap)

if nargout > 0
   theResult = self;
  else
   assignin('base', 'ans', self)
end
