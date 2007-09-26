function theResult = AddMenus(self)

% StarBeam/AddMenus -- Add menus to "starbeam" window.
%  AddMenus(self) adds menus to the window associated
%   with self, a "starbeam" object.


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
% Updated    12-Jul-1999 14:57:42.

if nargin < 1, help(mfilename), return, end

set(gcf, 'MenuBar', 'figure')

h = findobj(gcf, 'Type', 'uimenu');
if any(h), delete(h), end

% New menus.

theVarnames = [ ...
{'-Beam';
'>>Beam 1';
'>>Beam 2';
'>>Beam 3';
'>>Beam 4';
'-Beams';
'>>Velocity';
'>>Horizontal Velocity';
'>>Vertical Velocity';
'->Correlation';
'>>Intensity';
'>>Percent Good';
'-Instrument';
'>>Tilt';
'->Voltage'};
];

theLabels = [ ...
{'<StarBeam>'; ...
'>About StarBeam...';
'-Setup...';
'-Graph'; ...
'>>Line'; ...
'>>Circles'; ...
'>>Dots'; ...
'->Contour'; ...
'>>Image'; ...
'->Progressive Vector'; ...
'>>Scatter Plot'; ...
'->Wiggles X'; ...
'>>Wiggles Y'; ...
'->Averaging On';
'>>Averaging Off';
'->Colorbars On'; ...
'>>Colorbars Off'; ...
'->Page Setup...'; ...
'>>Print'; ...
'->Update'; ...
'-Time Axis'; ...
'>>Time'; ...
'->Record'; ...
'-Depth Axis'; ...
'>>Depth'; ...
'->Bin'; ...
}; ...
theVarnames;  ...
{
'-Done'; ...
}
];

s = setstr([abs('a'):abs('z') abs('0123456789')]);

theMenus = [];
theCalls = cell(size(theLabels));
theTags = cell(size(theLabels));
for i = 1:length(theLabels)
   theCalls{i} = 'pxevent';
   theTag = lower(theLabels{i});
   for j = length(theTag):-1:1
      if ~any(theTag(j) == s)
         theTag(j) = '';
      end
   end
   theTags{i} = theTag;
end
		
theMenus = [theMenus; pxmenu(gcf, theLabels)];

if nargout > 0, theResult = theMenus; end
