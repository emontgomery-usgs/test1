function theResult = initialize(self)

% starbare/initialize -- Initialize "StarBare".
%  initialize(self) initializes self, a "starbare" object,
%   then calls "starbare/update'.


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
 
% Version of 03-Apr-1998 14:19:26.

if nargin < 1, help(mfilename), return, end

theData = pxget(self, 'itsData');
theMask = pxget(self, 'itsMask');

theTimeName = pxget(self, 'itsTimeName');
theTimeUnits = pxget(self, 'itsTimeUnits');
theDepthName = pxget(self, 'itsDepthName');
theDepthUnits = pxget(self, 'itsDepthUnits');

ensemble = theData('ensemble');
bin = theData('bin');

theEnsembleMax = prod(size(ensemble));
theBinMax = prod(size(bin));

pxset(self, 'itIsEnsembleAveraging', 0);
pxset(self, 'itsEnsembleStart', 1);
pxset(self, 'itsEnsembleCount', min(theEnsembleMax, 50));
pxset(self, 'itsEnsembleStep', 1);
pxset(self, 'itsEnsembleMax', theEnsembleMax);

pxset(self, 'itsBinStart', 1);
pxset(self, 'itsBinCount', theBinMax);
pxset(self, 'itsBinStep', 1);
pxset(self, 'itsBinMax', theBinMax);

pxset(self, 'itsPlotStyle', 'image')
pxset(self, 'itsLineStyle', '-')
pxset(self, 'itsMarker', 'none')
pxset(self, 'itsColor', [1 0 1])

pxset(self, 'itsColorBars', 'on')   % 'off' or 'on'.

pxset(self, 'itsRotationAngle', 0)

pxset(self, 'itsColorFactor', 1)   % For vertical velocity.

setup(self)

% Adjust the scrollbars.
	
s{1} = px(findobj(gcf, 'Style', 'slider', 'Tag', 'XScroll'));
s{2} = px(findobj(gcf, 'Style', 'slider', 'Tag', 'YScroll'));
theMax(1) = theEnsembleMax;
theMax(2) = theBinMax;
theSliderStep(1, :) = [50 1000] ./ theMax(1);
theSliderStep(2, :) = [1 10] ./ theMax(2);
for i = 1:2
	s{i}.Max = theMax(i);
	s{i}.Value = theMax(i);
	s{i}.Min = 1;
	s{i}.Value = 1;
	s{i}.SliderStep = theSliderStep(i, :);
end

theVariables = {'vel1', 'vel2', 'vel3', 'vel4'};
pxset(self, 'itsVariables', {theVariables});   % Note {}.

update(self)

if nargout > 0, theResult = self; end
