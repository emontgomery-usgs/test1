function theResult = dosetup(self)

% starbuck/dosetup -- Set "starbuck" display style.
%  dosetup(self) invokes a dialog to set the display
%   style of self, a "starbuck" object.  The result
%   is zero (0) if the dialog is cancelled; otherwise
%   non-zero.


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
% Updated    17-Dec-1999 23:46:47.

LF = char(10);
CR = char(13);
CRLF = [CR LF];

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

theHelp = help('starbuck');
f = findstr(theHelp, 'STARBUCK');
if any(f), theHelp(1:f(1)-1) = ''; end
s.help = theHelp;
s.Ensemble.Averaging = {'checkbox', psget(self, 'itIsEnsembleAveraging')};
s.Ensemble.Start = psget(self, 'itsEnsembleStart');
s.Ensemble.Stop = psget(self, 'itsEnsembleStop');
s.Ensemble.Count = psget(self, 'itsEnsembleCount');
s.Ensemble.Step = psget(self, 'itsEnsembleStep');
s.Ensemble.Max = psget(self, 'itsEnsembleMax');
s.Ensemble.TimeSampling = psget(self, 'itsTimeSampling');
s.Bin.Start = psget(self, 'itsBinStart');
s.Bin.Stop = psget(self, 'itsBinStop');
s.Bin.Count = psget(self, 'itsBinCount');
s.Bin.Step = psget(self, 'itsBinStep');
s.Bin.Max = psget(self, 'itsBinMax');

theTimeAxisName = psget(self, 'itsTimeAxisName');
if isequal(theTimeAxisName, 'time')
	s.TimeAxis = {{'time', 'ensemble'}, 1};
else
	s.TimeAxis = {{'time', 'ensemble'}, 2};
end

theDepthAxisName = psget(self, 'itsDepthAxisName');
if isequal(theDepthAxisName, 'depth')
	s.DepthAxis = {{'depth', 'bin'}, 1};
else
	s.DepthAxis = {{'depth', 'bin'}, 2};
end

thePlotStyle = psget(self, 'itsPlotStyle');
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

s.RotationAngle = psget(self, 'itsRotationAngle');
s.ColorFactor = psget(self, 'itsColorFactor');

result = 0;
StarBuck_Setup = s;

if (0)    % uigetinfo is obsolete.
	s = uigetinfo(StarBuck_Setup, 'StarBuck.mat', 'StarBuck_Setup');
else
    StarBuck_Setup
    which guido
	s = guido(StarBuck_Setup, '', 0);
    s
    s.Ensemble(:)
    are_equal = isequal(StarBuck_Setup, s)
end

if ~isempty(s)
	isEnsembleAveraging = getinfo(s, 'Ensemble.Averaging');
	
	theTimeSampling = dhms(psget(self, 'itsTimeSampling'));
	
	theEnsembleStart = getinfo(s, 'Ensemble.Start')
	
	if ischar(theEnsembleStart)
		ms2day = 1/(86400*1000);
		theData = psget(self, 'itsData');
		t0 = datenum(1968, 5, 23) - 2440000;   % May 23, 1968.
		d1 = theData{'time'}(1) + theData{'time2'}(1)*ms2day + t0;
		d2 = datenum(theEnsembleStart);
		dd = d2 - d1;
		theEnsembleStart = round(dd/theTimeSampling) + 1;
	end
	
	theEnsembleStop = getinfo(s, 'Ensemble.Stop');   % Not used.
	
	theEnsembleStep = getinfo(s, 'Ensemble.Step')
	
	if ischar(theEnsembleStep)
		st = dhms(theEnsembleStep);
		theEnsembleStep = round(st/theTimeSampling);
	end
	
	theEnsembleCount = getinfo(s, 'Ensemble.Count')
	
	if ischar(theEnsembleCount)
		ct = dhms(theEnsembleCount);
		theEnsembleCount = round(ct/(theTimeSampling*theEnsembleStep));
	end
	
	theBinStart = getinfo(s, 'Bin.Start');
	theBinStop = getinfo(s, 'Bin.Stop');   % Not used.
	theBinCount = getinfo(s, 'Bin.Count');
	theBinStep = getinfo(s, 'Bin.Step');
	
	theRotationAngle = getinfo(s, 'RotationAngle');
	theColorFactor = getinfo(s, 'ColorFactor');
	
	if ~isempty(isEnsembleAveraging)
		psset(self, 'itIsEnsembleAveraging', isEnsembleAveraging);
	end
	if ~isempty(theEnsembleStart)
		psset(self, 'itsEnsembleStart', theEnsembleStart);
	end
	if ~isempty(theEnsembleStop)
		psset(self, 'itsEnsembleStop', theEnsembleStop);
	end
	if ~isempty(theEnsembleCount)
		psset(self, 'itsEnsembleCount', theEnsembleCount);
	end
	if ~isempty(theEnsembleStep)
		psset(self, 'itsEnsembleStep', theEnsembleStep);
	end
	if ~isempty(theBinStart)
		psset(self, 'itsBinStart', theBinStart);
	end
	if ~isempty(theBinStop)
		psset(self, 'itsBinStop', theBinStop);
	end
	if ~isempty(theBinCount)
		psset(self, 'itsBinCount', theBinCount);
	end
	if ~isempty(theBinStep)
		psset(self, 'itsBinStep', theBinStep);
	end
	psset(self, 'itsTimeAxisName', getinfo(s, 'TimeAxis'));
	psset(self, 'itsDepthAxisName', getinfo(s, 'DepthAxis'));
	psset(self, 'itsPlotStyle', getinfo(s, 'PlotStyle'));
	if ~isempty(theRotationAngle)
		psset(self, 'itsRotationAngle', theRotationAngle);
	end
	if ~isempty(theColorFactor)
		psset(self, 'itsColorFactor', theColorFactor);
	end
	result = 1;
end

if nargout > 0, theResult = result; end
