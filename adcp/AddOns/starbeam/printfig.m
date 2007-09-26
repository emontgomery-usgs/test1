function printfig(varargin)

% printfig -- Print a figure with controls invisible.
%  printfig(f1, f2, ...) prints each of the figures
%   whose handles are given by f1, f2, ...  Existing
%   controls are made invisible during the printing.


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
 
% Version of 02-Oct-1998 13:22:43.

if nargin < 1, varargin{1} = gcf; end

theFigures = get(0, 'Children');

theFigureHandle = varargin;

for k = 1:length(theFigureHandle)
	f = theFigureHandle{k};
	if ischar(f), f = eval(f); end
	figure(f)
	h = findobj(f, 'Type', 'uicontrol');
	vis = zeros(size(h));
	for i = length(h):-1:1
		if isequal(get(h(i), 'Visible'), 'off')
			h(i) = [];
		end
	end
	if any(h), set(h, 'Visible', 'off'), end
	drawnow
	thePrintCommand = ['print -v -f' num2str(f, 16)];
	oldWarning = warning;
	warning('off')
	eval(thePrintCommand)
	warning('on')
	if any(h), set(h, 'Visible', 'on'); end
	drawnow
end
