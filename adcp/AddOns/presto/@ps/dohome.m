function theResult = dohome(self, varargin)

% ps/dohome -- Set controls to "home" values.
%  dohome(self) sets the controls associated with
%   self, a "ps" object, to their "home" value.
%   For sliders, this "Value" is midway between
%   the "Min" and "Max" properties.
%
% Note: this routine also needs to force the figure
%  to update itself.


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
 
% Version of 10-Dec-1999 01:08:11.
% Updated    10-Dec-1999 14:27:28.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end

theSliders = findobj(handle(self), 'Type', 'uicontrol', ...
							'Style', 'slider');
					
for i = 1:length(theSliders)
	theMin = get(theSliders(i), 'Min');
	theMax = get(theSliders(i), 'Max');
	set(theSliders(i), 'Value', mean([theMin theMax]))
end

axis tight
set(gca, 'CLimMode', 'auto')

if nargout > 0
	theResult = self;
else
	assignin('caller', 'ans', self)
end
