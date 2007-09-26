function theResult = setup(self)

% starbare/setup -- Set "starbare" display style.
%  setup(self) invokes a dialog to set the
%   display style of self, a "starbare"
%   object.  The result is zero (0) if the
%   dialog is cancelled; otherwise non-zero.


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
 
% Version of 03-Apr-1998 15:38:44.

s.Ensemble.Averaging = {'checkbox', pxget(self, 'itIsEnsembleAveraging')};
s.Ensemble.Start = pxget(self, 'itsEnsembleStart');
s.Ensemble.Count = pxget(self, 'itsEnsembleCount');
s.Ensemble.Step = pxget(self, 'itsEnsembleStep');
s.Ensemble.Max = pxget(self, 'itsEnsembleMax');
s.Ensemble.TimeSampling = pxget(self, 'itsTimeSampling');
s.Bin.Start = pxget(self, 'itsBinStart');
s.Bin.Count = pxget(self, 'itsBinCount');
s.Bin.Step = pxget(self, 'itsBinStep');
s.Bin.Max = pxget(self, 'itsBinMax');

theTimeName = pxget(self, 'itsTimeName');
if isequal(theTimeName, 'TIM')
	s.TimeAxis = {{'TIM', 'Rec'}, 1};
else
	s.TimeAxis = {{'TIM', 'Rec'}, 2};
end

theDepthName = pxget(self, 'itsDepthName');
if isequal(theDepthName, 'D')
	s.DepthAxis = {{'D', 'bin'}, 1};
else
	s.DepthAxis = {{'D', 'bin'}, 2};
end

thePlotStyle = pxget(self, 'itsPlotStyle');
switch thePlotStyle
case 'contour'
	code = 1;
case 'image'
	code = 2;
case 'progressive'
	code = 3;
case 'scatter'
	code = 4;
case 'wigglesx'
	code = 5;
case 'wigglesy'
	code = 6;
otherwise
	code = 2;
end
s.PlotStyle = {{'contour', 'image', 'progressive', 'scatter', ...
					'wigglesx', 'wigglesy'}, code};

s.RotationAngle = pxget(self, 'itsRotationAngle');
s.ColorFactor = pxget(self, 'itsColorFactor');

result = 0;
StarBare_Setup = s;
s = uigetinfo(StarBare_Setup, 'StarBare.mat', 'StarBare_Setup');

if ~isempty(s)
	isEnsembleAveraging = getinfo(s, 'Ensemble.Averaging');
	
	theTimeSampling = dhms(pxget(self, 'itsTimeSampling'));
	
	theEnsembleStart = getinfo(s, 'Ensemble.Start');
	
	if ischar(theEnsembleStart)
		theData = pxget(self, 'itsData');
		t0 = datenum(1968, 5, 23) - 2440000;   % May 23, 1968.
		d1 = theData{'TIM'}(1) + t0;
		d2 = datenum(theEnsembleStart);
		dd = d2 - d1;
		theEnsembleStart = round(dd/theTimeSampling) + 1;
	end
	
	theEnsembleStep = getinfo(s, 'Ensemble.Step');
	
	if ischar(theEnsembleStep)
		st = dhms(theEnsembleStep);
		theEnsembleStep = round(st/theTimeSampling);
	end
	
	theEnsembleCount = getinfo(s, 'Ensemble.Count');
	
	if ischar(theEnsembleCount)
		ct = dhms(theEnsembleCount);
		theEnsembleCount = round(ct/(theTimeSampling*theEnsembleStep));
	end
	
	theBinStart = getinfo(s, 'Bin.Start');
	theBinCount = getinfo(s, 'Bin.Count');
	theBinStep = getinfo(s, 'Bin.Step');
	
	theRotationAngle = getinfo(s, 'RotationAngle');
	theColorFactor = getinfo(s, 'ColorFactor');
	
	if ~isempty(isEnsembleAveraging)
		pxset(self, 'itIsEnsembleAveraging', isEnsembleAveraging);
	end
	if ~isempty(theEnsembleStart)
		pxset(self, 'itsEnsembleStart', theEnsembleStart);
	end
	if ~isempty(theEnsembleCount)
		pxset(self, 'itsEnsembleCount', theEnsembleCount);
	end
	if ~isempty(theEnsembleStep)
		pxset(self, 'itsEnsembleStep', theEnsembleStep);
	end
	if ~isempty(theBinStart)
		pxset(self, 'itsBinStart', theBinStart);
	end
	if ~isempty(theBinCount)
		pxset(self, 'itsBinCount', theBinCount);
	end
	if ~isempty(theBinStep)
		pxset(self, 'itsBinStep', theBinStep);
	end
	pxset(self, 'itsTimeName', getinfo(s, 'TimeAxis'));
	pxset(self, 'itsDepthName', getinfo(s, 'DepthAxis'));
	pxset(self, 'itsPlotStyle', getinfo(s, 'PlotStyle'));
	if ~isempty(theRotationAngle)
		pxset(self, 'itsRotationAngle', theRotationAngle);
	end
	if ~isempty(theColorFactor)
		pxset(self, 'itsColorFactor', theColorFactor);
	end
	result = 1;
end

if nargout > 0, theResult = result; end
