function theJulian = datenum2julian(theDateNum)

% datenum2julian -- Convert Julian Day to Matlab datenum.
%  datenum2julian(theDateNum) converts theDayNum (Matlab
%   datenum) to its equivalent Julian day.  The Julian
%   day is referenced to midnight, not noon.


%%% START USGS BOILERPLATE -------------% Program written in Matlab v6x
% Program works in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
% program ran on Redhat Enterprise Linux 4
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

  
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 26-Oct-1998 15:49:22.

if nargin < 1, help(mfilename), return, end

t0 = datenum(1968, 5, 23) - 2440000;   % May 23, 1968.

result = theDateNum - t0;

if nargout > 0
	theJulian = result;
else
	disp(result)
end
