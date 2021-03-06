function theMenu = ViewMenu(theMenuName)

% ViewMenu -- Install the standard View menu.
%  ViewMenu(theMenuName) installs the standard View menu
%   in the current window.  TheMenuName defaults to '<View>'.


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
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

  
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1, help ViewMenu, theMenuName = ''; end

if isempty(theMenuName), theMenuName = '<View>'; end

h = pxmenu(gcf, {theMenuName, ...
                 '>Home', ...
                 '-Refresh', ...
                 '>Resize', ...
                 '-View 2-d', '>View 3-d', ...
                 '-Zoom', ...
                 '>>Zoom In', '>>Zoom Out', ...
                 '--Zoom In X', '>>Zoom In Y', ...
                 '--Zoom Out X', '>>Zoom Out Y', ...
                 '-Auto Zoom', '>>Auto Zoom On', ...
                 '->Auto Zoom Out', '->Auto Zoom Off', ...
                 '-Orientation', ...
                 '>>Landscape', '>>Portrait', '>>Tall', ...
                 '-Toggle', ...
                 '>>Controls', ...
                 '>>Menu Bar', ...
                 '>>Resizable'});

if nargout > 0, theMenu = h(:); end
