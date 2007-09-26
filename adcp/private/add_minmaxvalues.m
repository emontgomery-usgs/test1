% ADD_MINMAXVALUES calculate min and max for variables in a netCDF file and
% add as an attribute.


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

 
function add_minmaxvalues(nc)
theVars = var(nc);
for i = 1:length(theVars),
    if ~strcmp(ncnames(theVars{i}),'time') && ...
            ~strcmp(ncnames(theVars{i}),'time2') && ...
            ~strcmp(ncnames(theVars{i}),'TIM'),
        data = theVars{i}(:);
        [row, col] = size(data);
        if col == 1,
            theVars{i}.minimum = ncfloat(gmin(data));
            theVars{i}.maximum = ncfloat(gmax(data));
        elseif col == 2,
            theVars{i}.minimum = ncfloat(gmin(gmin(data)));
            theVars{i}.maximum = ncfloat(gmax(gmax(data)));
        elseif col > 2, % then these are amp and cor or some other 3d var
            for icol = 1:col,
                mins(icol) = gmin(data(:,icol));
                maxs(icol) = gmax(data(:,icol));
            end
            theVars{i}.minimum = ncfloat(mins);
            theVars{i}.maximum = ncfloat(maxs);
        end
    end
end
return


