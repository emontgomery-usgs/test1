function theResult = addmenus(self)

% starbuck/addmenus -- Add menus to "starbuck" window.
%  addmenus(self) adds menus to the window associated
%   with self, a "starbuck" object.


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
 
% Version of 21-Jul-1997 16:30:13.
% Updated    21-Dec-1999 09:34:44.

if nargin < 1, help(mfilename), return, end

set(gcf, 'MenuBar', 'figure')

h = findobj(gcf, 'Type', 'uimenu');
if any(h), delete(h), end

h = findobj(gcf, 'Type', 'uicontrol');
if any(h), delete(h), end

% New menus.

theMenuLabels = {
	'<StarBuck>'
		'>About...'
		'>Setup...'
		'-Velocity'
			'>>U-V'
			'>>U-V-W'
			'>>U-V-W-Err'
			'>>U-V-Err'
			'>>W-Err'
		'-Quality'
		'-Graph'
			'>>Line'
			'>>Circles'
			'>>Dots'
			'->Contour'
			'>>Image'
			'->Progressive Vector'
			'>>Scatter Plot'
			'->Wiggles X'
			'>>Wiggles Y'
			'->Averaging On'
			'>>Averaging Off'
			'->Colorbars On'
			'>>Colorbars Off'
			'->Page Setup...'
			'>>Print'
			'->Update'
		'-Time Axis'
			'>>Time'
			'->Ensemble'
		'>Depth Axis'
			'>>Depth'
			'->Bin'
		'-Done'
};

[self, theMenuHandles] = menu(self, theMenuLabels);

% New controls.

theControls(1) = control(self, 'bottom');
theControls(2) = control(self, 'right');

% Event-handlers.
%
%  Note: these are not being used presently; instead,
%   everything is being passed to "starbuck/doevent".

theEventHandlers = {
	'about', 'doabout', ...
	'update', 'doupdate', ...
	'setup', 'dosetup', ...
	'uv', 'dovelocity', ...
	'uvw', 'dovelocity', ...
	'uvwerr', 'dovelocity', ...
	'uverr', 'dovelocity', ...
	'werr', 'dovelocity', ...
	'quality', 'doquality', ...
	'time', 'dotimeaxis', ...
	'ensemble', 'dotimeaxis', ...
	'depth', 'dodepthaxis', ...
	'bin', 'dodepthaxis', ...
	'done', 'doquit', ...
	'resizefcn', 'doresize', ...
	'closerequestfcn', 'doquit', ...
	'bottom', 'doscroll', ...
	'right', 'doscroll', ...
};

self = handler(self, theEventHandlers{:});

enable(self)

if nargout > 0, theResult = self; end
