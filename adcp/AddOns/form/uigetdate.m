function theResult = uigetdate(theName)

% uigetdate -- Dialog to get a date.
%  uigetdate('theName') invokes a dialog to get a date.
%   Use 'theName' to designate a certain name for the
%   date, such as 'start_date' or 'end_date'.  The
%   routine returns a struct with fields of 'year',
%   'month', 'day', 'hour', 'minute', 'second', plus
%   'other_formats', 'datenum', 'datestr', and 'datevec'.
%   The latter three values correspond to Matlab functions
%   of the same name, using the 'year', 'month', ...
%   information.  Changes in the other_formats' field
%   must be detected and processed separately.


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
 
% Version of 23-Jan-1998 11:15:27.

if nargin < 1, theName = 'Set The Date'; end

if isequal(theName, 'demo')
    uigetdate('Now')
    return
end

for i = 0:100, x.year{i+1} = 1950 + i; end

theMonths = { ...
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', ...
            };
            
x.month = theMonths;

for i = 1:31, x.day{i} = i; end
for i = 0:23, x.hour{i+1} = i; end
for i = 0:59, x.minute{i+1} = i; end
for i = 0:59, x.second{i+1} = i; end

% Initial settings.

thePresent = now;

v = fix(datevec(thePresent));
v = v + [-1949 0 0 1 1 1];

x.year = {x.year, v(1)};
x.month = {x.month, v(2)};
x.day = {x.day, v(3)};
x.hour = {x.hour, v(4)};
x.minute = {x.minute, v(5)};
x.second = {x.second, v(6)};

x.other_formats.datenum = datenum(thePresent);
x.other_formats.use_datenum = {0, 1};
x.other_formats.datestr = datestr(thePresent);
x.other_formats.use_datestr = {0, 1};
x.other_formats.datevec = fix(datevec(thePresent));
x.other_formats.use_datevec = {0, 1};

theName(theName == ' ') = '_';
eval([theName ' = x;'])
y = uigetparm(eval(theName));

% Strip out the results.

y.year = y.year{1};
y.month = y.month{1};
y.day = y.day{1};
y.hour = y.hour{1};
y.minute = y.minute{1};
y.second = y.second{1};
y.other_formats.use_datenum = y.other_formats.use_datenum{1};
y.other_formats.use_datestr = y.other_formats.use_datestr{1};
y.other_formats.use_datevec = y.other_formats.use_datevec{1};

% Compute date-vector and date-number.

theDateVec = [y.year NaN y.day y.hour y.minute y.second];

for i = 1:length(theMonths)
    if isequal(y.month, theMonths{i})
        theDateVec(2) = i;
        break;
    end
end

v = [];
for i = 1:6, v{i} = theDateVec(i); end
theDateNum = datenum(v{:});
theDateStr = datestr(theDateNum);

y.datenum = theDateNum;
y.datestr = theDateStr;
y.datevec = theDateVec;

result = y;

if nargout > 0
    theResult = result;
else
    disp(result)
end
