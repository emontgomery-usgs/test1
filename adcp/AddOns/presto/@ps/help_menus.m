function theResult = help_menus(self, varargin)

%    The "ps/menu" method adds menus to the PS
% menubar, using a cell-array of the desired menu labels,
% arranged in top-down fashion.  Prepended to each label
% is one ">" for each stage below the top-level menu.
% For a separator-line between menus, use "-" in place
% of one of the ">" symbols.
%    Menus call "event Callback" when selected.  Inside
% "ps/doevent", the event is translated into the menu
% label of the instigator, then processed in the "switch"
% ladder, as described in the "Help/Events" menu.
%    See "help ps/menu".


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
 
% Version of 04-Nov-1999 14:41:34.
% Updated    04-Nov-1999 14:54:02.

h = help(mfilename);
helpdlg(h, 'PS Menus')

if nargout < 1, theResult = self; end
