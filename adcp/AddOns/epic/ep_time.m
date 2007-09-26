function theEpicTime = EP_Time(y, m, d, h, mi, s)

% EP_Time -- Epic-time from Matlab date.
%  EP_Time(theDate) returns the epic-time in two-columns,
%   [time time2], corresponding to theDate, a Matlab date-string,
%   date-number, or date-vector [y m d] or [y m d h mi s].  See
%   the Matlab "datestr()", "datenum()", and "datevec()" functions
%   for syntax and restrictions.
%  EP_Time(y, m, d) and EP_Time(y, m, d, h, mi, s) provide
%   alternatives for date-vector input.
%  EP_Time('demo') demonstrates itself.
%  EP_Time (no argument) shows "help" and demonstrates itself.


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
% Updated    08-Nov-1999 09:26:35.

% Note: May 23, 1968 = Julian Day 2,440,000.

if nargin < 1, help(mfilename), y = 'demo'; end

if strcmp(y, 'demo')
   y = '23-May-1968';
   if exist('begets')
      begets('EP_Time', 1, y, ep_time(y))
     else
      disp([' ## EP_Time(''' y ''') ==> ' ep_time(y)])
   end
   return
end

switch nargin
case 1
   [m, n] = size(y);
   if isstr(y) | n == 1
      theDate = datenum(y);
     elseif n == 3
      d = y(3); m = y(2); y = y(1);
      theDate = datenum(y, m, d);
     elseif n == 6
      s = y(6); mi = y(5); h = y(4);
      d = y(3); m = y(2); y = y(1);
      theDate = datenum(y, m, d, h, mi, s);
  	else
	  theDate = y;
   end
case 3
   theDate = datenum(y, m, d);
case 6
   theDate = datenum(y, m, d, h, mi, s);
otherwise
	help(mfilename)
	error(' ## Incorrect number of arguments')
end

t0 = datenum(1968, 5, 23) - 2440000;   % May 23, 1968.

MSEC_PER_DAY = 24*60*60*1000;

t = theDate - t0;
t = [fix(t) rem(t, 1)*MSEC_PER_DAY];

if nargout > 0
   theEpicTime = t;
  else
   disp(t)
end
