function theResult = doscroll(self, theEvent, theMessage)

% ps/doscroll -- Handler for "ps" scrollbars.
%  doscroll(self, theEvent, theMessage) pans the axes
%   in keeping with the active scrollbars, on behalf
%   of self, a "ps" object.


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

  
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 05-Nov-1999 21:34:53.
% Updated    05-Nov-1999 21:34:53.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

theXLim = get(gca, 'XLim');   % bottom scrollbar.
theYLim = get(gca, 'YLim');   % right scrollbar.
theZLim = get(gca, 'ZLim');   % left scrollbar.
theCLim = get(gca, 'CLim');   % top scrollbar.

axis tight
set(gca, 'CLimMode', 'auto')

theEvent = translate(self, theEvent);

switch theEvent
case 'bottom'
	theXLim = get(gca, 'XLim');
	smin = get(gcbo, 'Min');
	smax = get(gcbo, 'Max');
	value = get(gco, 'Value');
	frac = value / (smax - smin);
	theXLim = theXLim + (frac - 0.5)*diff(theXLim);
case 'right'
	theYLim = get(gca, 'YLim');
	smin = get(gcbo, 'Min');
	smax = get(gcbo, 'Max');
	value = get(gco, 'Value');
	frac = value / (smax - smin);
	theYLim = theYLim + (frac - 0.5)*diff(theYLim);
case 'left'
	theZLim = get(gca, 'ZLim');
	smin = get(gcbo, 'Min');
	smax = get(gcbo, 'Max');
	value = get(gco, 'Value');
	frac = value / (smax - smin);
	theZLim = theZLim + (frac - 0.5)*diff(theZLim);
case 'top'
	theCLim = get(gca, 'CLim');
	smin = get(gcbo, 'Min');
	smax = get(gcbo, 'Max');
	value = get(gco, 'Value');
	frac = value / (smax - smin);
	theCLim = theCLim + (frac - 0.5)*diff(theCLim);
end

set(gca, 'XLim', theXLim, 'YLim', theYLim, 'ZLim', theZLim, 'CLim', theCLim)

if nargout > 0
	theResult = self;
else
	assignin('caller', 'ans', self)
end
