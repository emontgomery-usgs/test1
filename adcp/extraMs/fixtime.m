function[newj] = fixtime(filename, fastslow)  

%function[newj] = fixtime(filename, fastslow)  
%fixes the time for any netcdf file that has julian time called "TIM"
%filename = name of netcdf file
%fastslow = desired adjustment to time in seconds


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

 
% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

h = netcdf(filename,'write')
if isempty(h),return, end

ftime = h{'TIM'};
jtime = ftime(:);
if nargin < 2
   fastslow = h{'TIM'}.slow_by(:); %in sec
end
%needs to be in fraction of a day
tadj = (fastslow/3600)/24;

newj = jtime + tadj;

ftime(:) = newj(:);
close(h)