function [y, m, d, h, mi, s] = EP_DateVec(theEpicTime)

% EP_DateVec -- Matlab fate-vector from epic-time.
%  EP_DateVec(theEpicTime) returns the Matlab date-vector
%   that corresponds to theEpicTime [time time2].  See
%   the Matlab "datevec()" function.
%  EP_DateVec('demo') demonstrates itself.
%  EP_DateVec (no argument) shows "help" and demonstrates itself.


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
 
% Version of 01-Jul-1997 15:54:18.

% Note: May 23, 1968 = Julian Day 2,440,000.

if nargin < 1, help(mfilename), theEpicTime = 'demo'; end

if strcmp(theEpicTime, 'demo')
   theEpicTime = ep_time('23-May-1968');
   if exist('begets')
      begets('EP_DateVec', 1, theEpicTime, ep_datevec(theEpicTime))
     else
      disp([' ## EP_DateVec(''' theEpicTime ''') ==> ' ep_datevec(theEpicTime)])
   end
   return
end

t = datevec(ep_datenum(theEpicTime));

switch nargout
case 1
   y = t;
case {3, 6}
   y = t(1); m = t(2); d = t(3); h = t(4); mi = t(5); s = t(6);
otherwise
   disp(t)
end
