function theDateStr = EP_DateStr(theEpicTime, theDateFormat)

% EP_DateStr -- Matlab date-string from epic-time.
%  EP_DateStr(theEpicTime, theDateFormat) returns the date-string
%   for theEpicTime (given as the vector [time time2]), formatted
%   according to theDateFormat.  The "time2" component defaults to 0.
%   See the Matlab "datestr()" function.
%  EP_DateStr('demo') demonstrates itself.
%  EP_DateStr (no argument) shows "help" and demonstrates itself.


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
   theEpicTime = [2440000 0];
   if exist('begets')
      begets('EP_DateStr', 1, theEpicTime, ep_datestr(theEpicTime))
     else
      disp([' ## EP_DateStr(' mat2str(theEpicTime) ') ==> ''' ep_datestr(theEpicTime) ''''])
   end
   return
end

if length(theEpicTime) < 2, theEpicTime(2) = 0; end

theEpicTime = theEpicTime(1:2);
theEpicTime = [1.0 1.0/(24*60*60*1000)] * theEpicTime(:);

theDateNum = theEpicTime - 2440000 + datenum(1968, 5, 23);

if nargin < 2
   d = datestr(theDateNum);
  else
   d = datestr(theDateNum, theDateFormat);
end

if nargout > 0
   theDateStr = d;
  else
   disp(d)
end
