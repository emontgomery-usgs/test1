function theResult = doabout(self, varargin)

%    The "ps" class provides a framework for
% processing interactive graphical events.  It
% features "dot" syntax for the setting/getting
% of graphical and user-defined properties.  All
% events are trapped by calls to "psevent", whose
% sole argument is the name of Matlab callback
% (e.g. "ButtonDownFcn").  Use "menu" to add
% menu items, "control" to add controls, and
% "enable" to automatically enable the relevant
% callbacks.  The file "ps_test.m" gives a
% demonstration.
%    The "ps" class should be super-classed,
% and the "event" method should be overloaded.


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

 
% ps/doabout -- Post "About PS" message.
%  doabout(self) posts the "About PS" message,
%  as seen in the block of text shown above.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 01-Nov-1999 13:53:56.
% Updated    04-Nov-1999 15:56:44.

helpdlg(help(mfilename), 'About PS')

if nargout > 0, theResult = self; end
