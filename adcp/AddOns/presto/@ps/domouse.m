function theResult = domouse(self, theEvent, varargin)

% ps/domouse -- Process "ps" mouse events.
%  domouse(self, 'theEvent') handles mouse events
%   on behalf of self, a "ps" object.


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
 
% Version of 05-Nov-1999 08:43:30.
% Updated    14-Dec-1999 16:39:22.

persistent OLD_NAME
persistent OLD_NUMBER_TITLE
persistent OLD_POINTER
persistent SELECTION_TYPE

switch lower(theEvent)

% Mouse play.
	
case 'windowbuttonmotionfcn'
	pt = get(gca, 'CurrentPoint');
	pt = mean(pt);
	NEW_NAME = ['[' num2str(pt(1)) ', ' num2str(pt(2)) ', ' num2str(pt(3)) ']'];
	set(gcbf, 'Name', NEW_NAME)
case 'windowbuttondownfcn'
	pt = get(gca, 'CurrentPoint');
	pt = mean(pt);
	SELECTION_TYPE = get(gcbf, 'SelectionType');
	NEW_NAME = ['[' num2str(pt(1)) ', ' num2str(pt(2)) ', ' num2str(pt(3)) ']'];
	NEW_NUMBER_TITLE = 'off';
	NEW_POINTER = 'circle';
	OLD_NAME = get(gcbf, 'Name');
	OLD_NUMBER_TITLE = get(gcbf, 'NumberTitle');
	OLD_POINTER = get(gcbf, 'Pointer');
	set(gcbf, ...
			'WindowButtonDownFcn', '', ...
			'WindowButtonMotionFcn', ['psevent WindowButtonMotionFcn'], ...
			'WindowButtonUpFcn', ['psevent WindowButtonUpFcn'], ...
			'Name', NEW_NAME, 'NumberTitle', NEW_NUMBER_TITLE, ...
			'Pointer', NEW_POINTER);
case 'windowbuttonupfcn'
	set(gcbf, ...
			'WindowButtonMotionFcn', '', ...
			'WindowButtonUpFcn', '', ...
			'WindowButtonDownFcn', ['psevent WindowButtonDownFcn'], ...
			'Name', OLD_NAME, 'NumberTitle', OLD_NUMBER_TITLE, ...
			'Pointer', OLD_POINTER);
	OLD_NAME = [];
	OLD_POINTER = [];
end

if nargout > 0
	theResult = self;
end
