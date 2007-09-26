function [theResult, theMenuHandles] = menu(self, theLabels)

% ps/menu -- Add a menu to a "ps" window.
%  menu(self, {theLabels}) adds menus using {theLabels},
%   a cell-array of strings, to the "ps" figure.
%   If an entry is itself a cell, the first element
%   is the label, the second (if any) is the accelerator
%   key, and the third (if any) is the "on/off" "Checked"
%   property.  (Note: Matlab's own menu accelerators
%   take precedence.)  Self is returned.
%  [self, theMenuHandles] also returns the menu handles.


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
 
% Version of 28-Oct-1999 14:35:15.
% Updated    26-Nov-1999 15:02:35.

if nargout > 0, theResult = []; end
if nargin < 1, help(mfilename), return, end
if ~iscell(theLabels), theLabels = {theLabels}; end

theHandle = handle(self);
while ~isequal(get(theHandle, 'Type'), 'figure')
	theHandle = get(theHandle, 'Parent');
end

theHandles = [theHandle];
theMenuHandles = [];

for i = 1:length(theLabels)
	theLabel = theLabels{i};
	theAccelerator = get(0, 'DefaultUIMenuAccelerator');
	theChecked = get(0, 'DefaultUIMenuChecked');
	if iscell(theLabel)
		if length(theLabel) > 2, theChecked = theLabel{3}; end
		if length(theLabel) > 1, theAccelerator = theLabel{2}; end
		if length(theLabel) > 0, theLabel = theLabel{1}; end
	end
	theTag = theLabel;
	theSeparator = 'off';
	theLevel = 0;
	while any(theLabel(1) == '>-')
		if theLabel(1) == '-'
			theSeparator = 'on';
		end
		theLevel = theLevel+1;
		theLabel(1) = [];
	end
	theMenu = uimenu(theHandles(theLevel+1), ...
						'Label', theLabel, ...
						'Tag', theTag, ...
						'Accelerator',theAccelerator, ...
						'Checked',theChecked, ...
						'Separator', theSeparator);
	theHandles(theLevel+2) = theMenu;
	theMenuHandles(end+1) = theMenu;
end

if nargout > 0
	theResult = self;
	theMenuHandles = theMenuHandles(:);   % Column-vector.
else
	assignin('caller', 'ans', self)
end
