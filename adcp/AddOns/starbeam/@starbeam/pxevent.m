function theResult = PXEvent(self, theEvent, theMessage)

% StarBeam/PXEvent -- Process an event.
%  PXEvent(self, theEvent, theMessage) processes theEvent
%   and theMessage on behalf of self, a "starbeam" object.


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
 
% Updated (MM) fix a bug that caused spewing
% Updated    12-Jul-1999 14:53:42.
% Updated    05-Oct-1999 13:10:41.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = ''; end
if nargin < 3, theMessage = []; end

result = [];
if nargout > 0, theResult = result; end

theData = pxget(self, 'itsData');
theTimeName = pxget(self, 'itsTimeName');
theTimeUnits = pxget(self, 'itsTimeUnits');
theVariables = pxget(self, 'itsVariables');

% MM letData is never used and this causes problems
if ~isempty(theTimeName)
    lenData = prod(size(theData{theTimeName}));
end

if (0), disp(theEvent), disp(theMessage), end

switch lower(theEvent)
case 'done'
   close(theData)
   pxdelete(self)
   return
case 'closerequestfcn'
   close(theData)
   pxdelete(self)
   return
case 'resizefcn'
   pxevent(super(self), theEvent, theMessage);
	return
case 'callback'
	switch lower(theMessage)
	case 'gcbo'
		switch lower(get(gcbo, 'Tag'))
		case 'xscroll'
			p = px(gcbo);
			pxset(self, 'itsEnsembleStart', round(p.Value))
			pxevent(self, 'update', [])
			return
		case 'yscroll'
			p = px(gcbo);
			pxset(self, 'itsBinStart', round(p.Value))
			pxevent(self, 'update', [])
			return
		otherwise
		end
	end
otherwise
end

switch lower(theEvent)
case 'initialize'
	busy
	initialize(self)
	update(self)
	findpt
	zoomsafe on all
	idle
	return
case 'update'
	busy
	update(self)
	findpt
	zoomsafe on all
	idle
	return
case 'setup'
	busy
	if setup(self)
		update(self)
		findpt
		zoomsafe on all
	end
	idle
	return
case {'aboutstarbeam', 'help'}
	help(class(self))
	return
otherwise
end

if strcmp(theMessage, 'gcbo')
   switch get(gcbo, 'Type')
   case 'figure'
   case 'uimenu'
   otherwise
      result = pxevent(super(self), theEvent, theMessage);
      if nargout > 0, theResult = result; end
      return
   end
end

theMenu = gcbo;
while (1)
   theParent = get(theMenu, 'Parent');
   if strcmp(get(theParent, 'Type'), 'figure')
      break
   end
   theMenu = theParent;
end
theMenuLabel = get(theMenu, 'Label');

theData = pxget(self, 'itsData');
theTimeName = pxget(self, 'itsTimeName');

switch lower(theMenuLabel)
case '<starbeam>'
	switch lower(theEvent)
	case 'velocity'
		switch theTimeName
		case 'time'
			theVariables = {'u_1205', 'v_1206', 'w_1204', 'Werr_1201'};
		otherwise
			theVariables = {'vel1', 'vel2', 'vel3', 'vel4'};
		end
	case 'horizontalvelocity'
		theVariables = {'vel1', 'vel2'};
	case 'verticalvelocity'
		theVariables = {'vel3', 'vel4'};
	case 'correlation'
		theVariables = {'cor1', 'cor2', 'cor3', 'cor4'};
	case {'agc', 'gain', 'intensity'}
		theVariables = {'AGC1', 'AGC2', 'AGC3', 'AGC4'};
	case 'percentgood'
		theVariables = {'PGd1', 'PGd2', 'PGd3', 'PGd4'};
	case 'tilt'
		theVariables = {'Hdg', 'Ptch', 'Roll', 'Tx'};
	case 'voltage'
		theVariables = {'dac', 'VDD3', 'VDD1', 'VDC'};
	case 'beam1'
		theVariables = {'vel1', 'cor1', 'AGC1', 'PGd1'};
	case 'beam2'
		theVariables = {'vel2', 'cor2', 'AGC2', 'PGd2'};
	case 'beam3'
		theVariables = {'vel3', 'cor3', 'AGC3', 'PGd3'};
	case 'beam4'
		theVariables = {'vel4', 'cor4', 'AGC4', 'PGd4'};
	otherwise
		theVariables = [];
		switch lower(theEvent)
		case {'rec', 'record'}
			theTimeName = 'Rec';
		case {'tim', 'time', 'date'}
			theTimeName = theEvent;
		otherwise
			theTimeName = [];
		end
		if ~isempty(theTimeName)
			pxset(self, 'itsTimeName', theTimeName);
			timeaxis(self)
		end
		switch lower(theEvent)
		case {'depth', 'd'}
			theDepthName = 'D';
		case 'bin'
			theDepthName = 'bin';
		otherwise
			theDepthName = [];
		end
		if ~isempty(theDepthName)
			pxset(self, 'itsDepthName', theDepthName);
			depthaxis(self)
			return
		end
	end
	if ~isempty(theVariables)
		for i = 1:length(theVariables)
			v{i} = theData{theVariables{i}};
		end
		pxset(self, 'itsVariables', {theVariables});
		update(self)
		return
	end
otherwise
   result = pxevent(super(self), theEvent, theMessage);
   if nargout > 0, theResult = result; end
   return
end

theParentMenu = get(gcbo, 'Parent');
theParentMenuLabel = get(theParentMenu, 'Label');

busy

switch lower(theParentMenuLabel)
case 'graph'
   okay = 1;
   switch lower(theEvent)
   case 'line'
		pxset(self, 'itsLineStyle', '-')
		pxset(self, 'itsMarker', 'none')
   case 'circles'
		pxset(self, 'itsLineStyle', 'none')
		pxset(self, 'itsMarker', 'o')
   case 'dots'
		pxset(self, 'itsLineStyle', 'none')
		pxset(self, 'itsMarker', '.')
   case 'averagingon'
		pxset(self, 'itIsEnsembleAveraging', 1)
		update(self)
		okay = 0;
   case 'averagingoff'
		pxset(self, 'itIsEnsembleAveraging', 0)
		update(self)
		okay = 0;
   case 'wigglesx'
		pxset(self, 'itsPlotStyle', 'wigglesx')
		update(self)
		okay = 0;
   case 'wigglesy'
		pxset(self, 'itsPlotStyle', 'wigglesy')
		update(self)
		okay = 0;
   case 'image'
		pxset(self, 'itsPlotStyle', 'image')
		update(self)
		okay = 0;
   case 'contour'
		pxset(self, 'itsPlotStyle', 'contour')
		update(self)
		okay = 0;
   case {'progressive', 'progressivevector'}
		pxset(self, 'itsPlotStyle', 'progressive')
		pxset(self, 'itsLineStyle', '-')
		pxset(self, 'itsMarker', 'none')
		update(self)
		okay = 0;
   case {'scatter', 'scatterplot'}
		pxset(self, 'itsPlotStyle', 'scatter')
		pxset(self, 'itsLineStyle', 'none')
		pxset(self, 'itsMarker', '.')
		update(self)
		okay = 0;
   case 'colorbarson'
		pxset(self, 'itsColorBars', 'on')
		update(self)
		okay = 0;
   case 'colorbarsoff'
		pxset(self, 'itsColorBars', 'off')
		update(self)
		okay = 0;
   case 'pagesetup'
		print -v
		okay = 0;
   case 'print'
		printfig(gcf)
		okay = 0;
   case 'update'
		update(self)
		okay = 0;
   otherwise
		okay = 0;
      result = pxevent(super(self), theEvent, theMessage);
   end
	if okay
		h = findobj(gcf, 'Type', 'line', 'Tag', 'StarBeam');
		theLineStyle = pxget(self, 'itsLineStyle');
		theMarker = pxget(self, 'itsMarker');
		if any(h)
			set(h, 'LineStyle', theLineStyle, 'Marker', theMarker)
		end
	end
otherwise
   result = pxevent(super(self), theEvent, theMessage);
   if nargout > 0, theResult = result; end
end

if nargout > 0, theResult = result; end

idle
