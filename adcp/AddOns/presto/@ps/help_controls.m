function theResult = help_controls(self, varargin)

%    The "ps/control" method adds controls to the
% "ps" window.  Standard scrollbars are indicated
% by the names: 'bottom', 'right', 'top,' or 'left'.
% Other controls are denoted by their "Style" property,
% as in 'pushbutton'.
%    Each control requires a "layout", consisting of a
% normalized-position and a pixel-offset.  The "layout"
% information is used by "ps/doresize" to adjust
% each control whenever the window is resized.
%    The "ps/control" method returns the handle of
% the new control, so that further embellishments can
% be made.
%    See "help ps/control".


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
helpdlg(h, 'PS Controls')

if nargout > 0, theResult = self; end
