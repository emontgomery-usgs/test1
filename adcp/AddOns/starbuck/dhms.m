function theResult = dhms(theArg)

% dhms -- Convert to/from dhms time-string format.
%  dhms('theTimeString') converts 'theTimeString' of
%   the form '1d2h3m4s' to decimal days.  Multiply
%   the result by 86400 to get decimal seconds.
%  dhms(theDecimalDays) converts theDecimalDays into a
%   time-string of the format '1d2h3m4s', rounded to the
%   nearest second.
%  dhms (no argument) demonstrates itself.


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

  
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 16-Oct-1998 18:09:35.

if nargin < 1, theArg = 'demo'; end

if isequal(theArg, 'demo')
	help(mfilename)
	format long
	theTimeString = '9d23h59m59s'
	theDecimalDays = dhms2d(theTimeString)
	theTimeString = d2dhms(theDecimalDays)
	format short
	return
end

switch class(theArg)
case 'double'
	result = d2dhms(theArg);
case 'char'
	result = dhms2d(theArg);
otherwise
	help(mfilename)
	warning([' ## Invalid argument type: ' class(theArg)])
	result = [];
end

if nargout > 0
	theResult = result;
else
	disp(result)
end


function theResult = d2dhms(theDecimalDays)

% d2dhms -- Convert decimal days to '1d2h3m4s' time-string.
%  d2dhms(theDecimalDays) converts theDecimalDays into a
%   time-string of the format '1d2h3m4s', rounded to the
%   nearest second.
%  d2dhms (no argument) demonstrates itself.
%
% Also see: dhms2d.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Oct-1998 08:16:05.

if nargin < 1
	help(mfilename)
	theDecimalDays = 'demo';
end

if isequal(theDecimalDays, 'demo')
	theDecimalDays = dhms2d('9d23h59m59s')
	theTimeString = d2dhms(theDecimalDays)
	return
end

t = theDecimalDays;

d = fix(t);
t = rem(t, 1) * 24;
h = fix(t);
t = rem(t, 1) * 60;
m = fix(t);
t = rem(t, 1) * 60;
s = round(t);

result = '';
if any(d), result = [result int2str(d) 'd']; end
if any(h), result = [result int2str(h) 'h']; end
if any(m), result = [result int2str(m) 'm']; end
if any(s), result = [result int2str(s) 's']; end

if isempty(result), result = '0s'; end

if nargout > 0
	theResult = result;
else
	disp(result)
end


function theResult = dhms2d(theTimeString)

% dhms2d -- Convert dhms time-string to decimal days.
%  dhms('theTimeString') converts 'theTimeString' of
%   the form '1d2h3m4s' to decimal days.  Multiply
%   the result by 86400 to get decimal seconds.
%  dhms2d (no argument) demonstrates itself.
%
% Also see: d2dhms.
 
% Copyright (C) 1998 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Oct-1998 21:19:25.

if nargin < 1
	help(mfilename)
	theTimeString = 'demo';
end

if isequal(theTimeString, 'demo')
	theTimeString = '9d23h59m60s'
	theDecimalDays = dhms2d(theTimeString)
	return
end

t = lower(theTimeString);

flag = 0;

if any(t == 's')
	t = strrep(t, 's', '*1');
	flag = 1;
end

if any(t == 'm')
	if flag
		t = strrep(t, 'm', '*60+');
	else
		t = strrep(t, 'm', '*60');
	end
	flag = 1;
end

if any(t == 'h')
	if flag
		t = strrep(t, 'h', '*3600+');
	else
		t = strrep(t, 'h', '*3600');
	end
	flag = 1;
end

if any(t == 'd')
	if flag
		t = strrep(t, 'd', '*86400+');
	else
		t = strrep(t, 'd', '*86400');
	end
end

result = eval(t) / 86400;

if nargout > 0
	theResult = result;
else
	disp(result)
end

