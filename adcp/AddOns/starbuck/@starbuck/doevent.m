function theResult = doevent(self, theEvent, theMessage)

% starbuck/doevent -- Process an event.
%  doevent(self, theEvent, theMessage) processes theEvent
%   and theMessage on behalf of self, a "starbuck" object.


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

  
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Updated    12-Jul-1999 14:53:42.
% Updated    21-Dec-1999 10:11:04.

if nargout > 0, theResult = result; end
if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = ''; end
if nargin < 3, theMessage = []; end

result = [];

switch lower(theEvent)
case 'callback'
	if ~isempty(gcbo)
		switch get(gcbo, 'Type')
		case {'uimenu', 'uicontrol'}
			theEvent = get(gcbo, 'Tag');
		end
	end
otherwise
end

theEvent = translate(self, theEvent);

theData = psget(self, 'itsData');

if (0)
	theTimeName = psget(self, 'itsTimeName');
	theTimeUnits = psget(self, 'itsTimeUnits');
	theTime2Name = psget(self, 'itsTime2Name');
	theTime2Units = psget(self, 'itsTime2Units');
	theVariables = psget(self, 'itsVariables');
	lenData = prod(size(theData{theTimeName}));
end

theVariables = [];
needsUpdate = 1;

busy

switch lower(theEvent)
	
case 'update'
	
case {'done', 'closerequestfcn'}
	close(theData)
	doquit(self)
	needsUpdate = 0;
	
case 'resizefcn'
	doresize(self)
	needsUpdate = 0;
	
case 'bottom'
	psset(self, 'itsEnsembleStart', round(get(gcbo, 'Value')))
	
case 'right'
	psset(self, 'itsBinStart', round(get(gcbo, 'Value')))
	
case 'about'
	version(self)
	needsUpdate = 0;
	
case 'setup'
	if ~dosetup(self)
		needsUpdate = 0;
	end
	
case 'uv'
	theVariables = {'u_1205', 'v_1206'};
	
case 'uvw'
	theVariables = {'u_1205', 'v_1206', 'w_1204'};
	
case 'uvwerr'
	theVariables = {'u_1205', 'v_1206', 'w_1204', 'Werr_1201'};
	
case 'uverr'
	theVariables = {'u_1205', 'v_1206', 'Werr_1201'};
	
case 'werr'
	theVariables = {'w_1204', 'Werr_1201'};
	
case 'quality'
	theVariables = {'AGC_1202', 'PGd_1203', 'Werr_1201'};
	
case 'time'
	theTimeAxisName = 'time';
	psset(self, 'itsTimeAxisName', theTimeAxisName);
	dotimeaxis(self)
	needsUpdate = 0;
	
case 'ensemble'
	theTimeAxisName = 'ensemble';
	psset(self, 'itsTimeAxisName', theTimeAxisName);
	dotimeaxis(self)
	needsUpdate = 0;
	
case 'depth'
	theDepthAxisName = 'depth';
	psset(self, 'itsDepthAxisName', theDepthAxisName);
	dodepthaxis(self)
	needsUpdate = 0;
	
case 'bin'
	theDepthAxisName = 'bin';
	psset(self, 'itsDepthAxisName', theDepthAxisName);
	dodepthaxis(self)
	needsUpdate = 0;
	
case 'averagingon'
	psset(self, 'itIsEnsembleAveraging', 1)
	
case 'averagingoff'
	psset(self, 'itIsEnsembleAveraging', 0)
	
case 'wigglesx'
	psset(self, 'itsPlotStyle', 'wigglesx')
	
case 'wigglesy'
	psset(self, 'itsPlotStyle', 'wigglesy')
	
case 'image'
	psset(self, 'itsPlotStyle', 'image')
	
case 'contour'
	psset(self, 'itsPlotStyle', 'contour')
	
case 'progressivevector'
	psset(self, 'itsPlotStyle', 'progressive')
	psset(self, 'itsLineStyle', '-')
	psset(self, 'itsMarker', 'none')
	
case 'scatterplot'
	psset(self, 'itsPlotStyle', 'scatter')
	psset(self, 'itsLineStyle', 'none')
	psset(self, 'itsMarker', '.')
	
case 'colorbarson'
	psset(self, 'itsColorBars', 'on')
	
case 'colorbarsoff'
	psset(self, 'itsColorBars', 'off')
	
case 'pagesetup'
	print -v
	
case 'print'
	printsafe(gcf)
	
case {'line', 'circles', 'dots'}
	switch lower(theEvent)
	case 'line'
		psset(self, 'itsLineStyle', '-')
		psset(self, 'itsMarker', 'none')
	case 'circles'
		psset(self, 'itsLineStyle', 'none')
		psset(self, 'itsMarker', 'o')
	case 'dots'
		psset(self, 'itsLineStyle', 'none')
		psset(self, 'itsMarker', '.')
	end
	h = findobj(gcf, 'Type', 'line', 'Tag', class(self));
	theLineStyle = psget(self, 'itsLineStyle');
	theMarker = psget(self, 'itsMarker');
	if any(h)
		set(h, 'LineStyle', theLineStyle, 'Marker', theMarker)
	end
	needsUpdate = 0;
otherwise
	result = doevent(super(self), theEvent, theMessage);
end

if needsUpdate
	if ~isempty(theVariables)
		psset(self, 'itsVariables', theVariables)
	end
	doupdate(self)
end

if nargout > 0, theResult = result; end

idle
