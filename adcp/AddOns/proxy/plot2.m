function theResult = Plot2(varargin)

% Plot2 -- Plot in second set of axes.
%  Plot2(...) plots in the second set of axes,
%   using the syntax of plot().  The axes are
%   superimposed on the first set of axes, and
%   the 'YAxisLocation' is set to 'right'.
%  Plot2 (no argument) switches to the
%   second axes.


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
 
% Version of 24-Apr-1997 10:59:23.

theAxes = sort(findobj(gcf, 'Type', 'axes'));
while length(theAxes) < 2
   theAxes = [theAxes axes];
end
axes(theAxes(2))

set(theAxes(2), 'Units', get(theAxes(1), 'Units'));
set(theAxes(2), 'Position', get(theAxes(1), 'Position'));

if nargin > 0
   varargout = cell(1, nargout);
   v = vargstr('plot', length(varargin), length(varargout));
   eval(v)
end

theDefaultColor = get(0, 'DefaultAxesColor');
set(theAxes(1), 'Color', theDefaultColor)
set(theAxes(2), 'Color', 'none')
theXAxisLocation = get(theAxes(1), 'XAxisLocation');
theYAxisLocation = get(theAxes(1), 'YAxisLocation');
if ~isequal(get(theAxes(1), 'XLim'), get(theAxes(2), 'XLim'))
   switch theXAxisLocation
   case 'bottom';
      theXAxisLocation = 'top';
   case 'top'
      theXAxisLocation = 'bottom';
   otherwise
   end
end
switch theYAxisLocation
case 'left';
   theYAxisLocation = 'right';
case 'right'
   theYAxisLocation = 'left';
otherwise
end
set(theAxes(2), 'XAxisLocation', theXAxisLocation)
set(theAxes(2), 'YAxisLocation', theYAxisLocation')

if nargout > 0, theResult = varargout{1}; end
