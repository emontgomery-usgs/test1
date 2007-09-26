function timeaxis(self)

% starbare/timeaxis -- Set time-axis labels.
%  timeaxis(self) adjusts the labels ot the time-axis
%   of self, a "starbare" object.


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
 
% Version of 25-Sep-1998 11:46:32.

if nargin < 1, help(mfilename), return, end

t0 = datenum(1968, 5, 23) - 2440000;   % May 23, 1968.

theData = pxget(self, 'itsData');
theTimeName = pxget(self, 'itsTimeName');
theVariables = pxget(self, 'itsVariables');

len = length(theVariables);

for k = 1:len
	subplot(len, 1, k)
	set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
	theXTick = get(gca, 'XTick');
	x = theData{theTimeName}(round(theXTick));
	theXTickLabel = [];
	for i = 1:length(x)
		if isequal(lower(theTimeName), 'tim')
			if i == 1 | i == length(x)
				theDateCode = 1;   % yymmdd.
			else
				theDateCode = 15;   % hhmm.
			end
			theDateStr = datestr(x(i) + t0, theDateCode);
			if i == 1 | i == length(x)
				theDateStr(theDateStr == '-') = '';
				theDateStr = strrep(theDateStr, '199', '9');
			else
				theDateStr(theDateStr == ':') = '';
			end
			theXTickLabel{i} = theDateStr;
		else
			theXTickLabel{i} = int2str(x(i));
		end
	end
	set(gca, 'XTick', theXTick, 'XTickLabel', theXTickLabel)
end
