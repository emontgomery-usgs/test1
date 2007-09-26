function theResult = doinitialize(self)

% starbuck/doinitialize -- Initialize "StarBuck".
%  doinitialize(self) initializes self, a "starbuck" object,
%   then calls "starbuck/update'.


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
% Updated    18-Dec-1999 00:01:41.
% Revised   05-Nov-2004 for MATLAB 7.0

if nargin < 1, help(mfilename), return, end

theData = psget(self, 'itsData');
theDataVars = var(theData);
theDataNames = ncnames(theDataVars);

theMenus = doaddmenus(self);

psset(self, 'itsBinStart', []);
psset(self, 'itsBinCount', []);
psset(self, 'itsBinStep', []);
psset(self, 'itsEnsembleStart', []);
psset(self, 'itsEnsembleCount', []);
psset(self, 'itsEnsembleStep', []);
psset(self, 'itsVariables', []);
psset(self, 'itsPlotStyle', []);   % 'plot', 'image', or 'contour'.

psset(self, 'MenuBar', 'none')

% colormenu does not exist in version 7 and higher
v = ver('MATLAB');
if str2num(strtok(v.Version,'.')) < 7,
    colormenu;
    h = findobj(gcf, 'Type', 'uimenu', 'Label', 'colormaps');
    if any(h), set(h, 'Label', '<ColorMaps>'), end
end

theTimeName = 'time';
theTimeUnits = theData{theTimeName}.units(:);

theTime2Name = 'time2';
theTime2Units = theData{theTime2Name}.units(:);

t = round(theData{theTimeName}(1:2) * 86400);   % seconds.
t2 = round(theData{theTime2Name}(1:2) / 1000);   % seconds.
theTimeSampling = dhms(diff(t+t2) / 86400);   % dhms.

theDepthName = 'depth';
theDepthUnits = theData{theDepthName}.units(:);
theDepthSampling = theData{theDepthName}.bin_size(:);
theDepthSampling = [num2str(theDepthSampling) ' ' theDepthUnits];

psset(self, 'itsTimeName', theTimeName);
psset(self, 'itsTimeAxisName', theTimeName);
psset(self, 'itsTimeUnits', theTimeUnits);
psset(self, 'itsTime2Name', theTime2Name);
psset(self, 'itsTime2Units', theTime2Units);
psset(self, 'itsTimeSampling', theTimeSampling);

psset(self, 'itsDepthName', theDepthName);
psset(self, 'itsDepthAxisName', theDepthName);
psset(self, 'itsDepthUnits', theDepthUnits);
psset(self, 'itsDepthSampling', theDepthSampling);

theTimeName = psget(self, 'itsTimeName');
theTimeUnits = psget(self, 'itsTimeUnits');
theDepthName = psget(self, 'itsDepthName');
theDepthUnits = psget(self, 'itsDepthUnits');

ensemble = theData('time');   % Formerly "ensemble".
bin = theData('depth');   % Formerly "bin".

theEnsembleMax = prod(size(ensemble));
theBinMax = prod(size(bin));

psset(self, 'itIsEnsembleAveraging', 0);
psset(self, 'itsEnsembleStart', 1);
psset(self, 'itsEnsembleStop', NaN);
psset(self, 'itsEnsembleCount', min(theEnsembleMax, 50));
psset(self, 'itsEnsembleStep', 1);
psset(self, 'itsEnsembleMax', theEnsembleMax);

psset(self, 'itsBinStart', 1);
psset(self, 'itsBinStop', NaN);
psset(self, 'itsBinCount', theBinMax);
psset(self, 'itsBinStep', 1);
psset(self, 'itsBinMax', theBinMax);

psset(self, 'itsPlotStyle', 'image')
psset(self, 'itsLineStyle', '-')
psset(self, 'itsMarker', 'none')
psset(self, 'itsColor', [1 0 1])

psset(self, 'itsColorBars', 'on')   % 'off' or 'on'.

psset(self, 'itsRotationAngle', 0)

psset(self, 'itsColorFactor', 1)   % For vertical velocity.

dosetup(self)

% Adjust the scrollbars.

s{1} = findobjs(gcf, 'Style', 'slider', 'Tag', 'bottom');
s{2} = findobjs(gcf, 'Style', 'slider', 'Tag', 'right');

theEnsembleMax = psget(self, 'itsEnsembleMax');
theEnsembleCount = psget(self, 'itsEnsembleCount');
theEnsembleStep = psget(self, 'itsEnsembleStep');

theBinMax = psget(self, 'itsBinMax');
theBinCount = psget(self, 'itsBinCount');
theBinStep = psget(self, 'itsBinStep');

theMax(1) = theEnsembleMax;
theMax(2) = theBinMax;
theSliderStep(1, :) = [0.25 1] * theEnsembleStep*theEnsembleCount/theEnsembleMax;
theSliderStep(2, :) = [theBinStep theBinStep*theBinCount]/theBinMax;
for i = 1:2
	set(s{i}, 'Min', 1, 'Max', theMax(i), 'Value', theMax(i), ...
					'SliderStep', theSliderStep(i, :))
end

theVariables = {'u_1205', 'v_1206', 'w_1204', 'Werr_1201'};
psset(self, 'itsVariables', theVariables);

doupdate(self)

if nargout > 0, theResult = self; end
