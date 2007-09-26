function depthaxis(self)

% starbuck/depthaxis -- Set depth-axis labels.
%  depthaxis(self) adjusts the labels ot the depth-axis
%   of self, a "starbuck" object.


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
% Updated    18-Dec-1999 00:16:18.

if nargin < 1, help(mfilename), return, end

theData = psget(self, 'itsData');
theDepthName = psget(self, 'itsDepthName');
theDepthAxisName = psget(self, 'itsDepthAxisName');
theVariables = psget(self, 'itsVariables');
theTransform = theData.transform(:);

% Get variable names.

len = length(theVariables);
for k = 1:len
	if ischar(theVariables{k})
		theVariables{k} = theData{theVariables{k}};
	end
	theVarNames{k} = name(theVariables{k});
end

% Change names if earth-coordinates.

if any(findstr(lower(theTransform), 'eart'))
	for k = 1:len
		switch theVarNames{k}
		case 'vel1'
			theVarNames{k} = 'East';
		case 'vel2'
			theVarNames{k} = 'North';
		case 'vel3'
			theVarNames{k} = 'Up';
		case 'vel4'
			theVarNames{k} = 'Error';
		end
	end
end

% Compute depth-axis.

if isequal(theDepthAxisName, 'depth')
	theDepth = theData{theDepthAxisName};
	y = theDepth(:);
	y(y == -999999) = nan;
	if any(isnan(y))
		% Compute the depths from attributes.
		wd = theDepth.water_depth(:);
		xo = theDepth.xducer_offset_from_bottom(:);
		bc = theDepth.bin_count(:);
		bs = theDepth.bin_size(:);
		cf = theDepth.center_first_bin(:);
		dz = (0:bc-1) * bs + cf;
		ot = theData.orientation(:);
		up = isequal(lower(ot), 'up');
		if up
			y = wd - xo - dz;
		else
			y = wd - xo + dz;
		end
	end
	theYTick = get(gca, 'YTick');
	indices = round(theYTick);
	indices = indices(indices >= 1 & indices <= length(y));
	y = y(indices);
end

% Modify ticks and labels.

for k = 1:len
	subplot(len, 1, k)
	set(gca, 'YTickMode', 'auto', 'YTickLabelMode', 'auto')
	if isequal(theDepthAxisName, 'depth')
		if all(isfinite(y))
			for i = 1:length(y)
				theYTickLabel{i} = num2str(round(y(i)));
			end
			if length(y) > 6
				for i = length(y):-2:1
					theYTickLabel{i} = '';
				end
			end
			set(gca, 'YTick', theYTick, 'YTickLabel', theYTickLabel)
			theUnits = theData{theDepthName}.units(:);
			s = theVarNames{k};
			f = find(s == '_');
			if any(f), s(f(end):end) = ''; end
			theYLabel = [s ' (depth'];
			if any(theUnits)
				theYLabel = [theYLabel ' ' theUnits];
			end
			theYLabel = [theYLabel ')'];
		end
	else
		s = theVarNames{k};
		f = find(s == '_');
		if any(f), s(f(end):end) = ''; end
		theYLabel = [s ' (bin #)'];
	end
	ylabel(labelsafe(theYLabel))
end

if isunix | any(findstr(lower(computer), 'pcwin')), drawnow, end
