function fixdate(filename)  

%function fixdate(filename)  
%fixes the date for any netcdf file that has julian time called "TIM"
%filename = name of netcdf file
%startdate = the date of the first ensemble


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

 
% Written by Andree L. Ramsey
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to aramsey@usgs.gov

% updated 28-Dec-2000 added line feeds to history attribute (ALR)

h = netcdf(filename,'write')
if isempty(h),return, end

%Get the correct dates and time intervals to create correct dates
prompt  = {'Enter the deployment date:', 'Enter the recovery date:'...
   'Enter time interval between ens in minutes:'};
def     = {'12/24/1984, 00:00:00','12/24/1984, 00:00:00','60'};
title   = 'Input correct dates for ADCP [MM/DD/YY, HH:MM:SS]';
lineNo  = 1;
dlgresult  = inputdlg(prompt,title,lineNo,def);
Deployment_date = dlgresult{1};
Recovery_date = dlgresult{2};
Time_interval = dlgresult{3};

dd = datevec(Deployment_date);
rd = datevec(Recovery_date);
Time_int = num2str(Time_interval); Tim_int = str2num(Time_int);
T_int = Tim_int/60;
dd2 = dd; 	dd2(4) = dd(4)+T_int;
Jdd = julian(dd);
Jdd2 = julian(dd2);
J_int = Jdd2-Jdd;
Jrd = julian(rd);

%Replace existing times with correct times
fdate = h{'TIM'};
jdate = fdate(:);
%gdate=gregorian(jdate);
l = length(jdate);
Good_date = ones(l,1);	Good_date(1) = Jdd;

for i=2:l
   Good_date(i) = Jdd + (i-1)*J_int;
end

gg = gregorian (Good_date);

if gg(end,:) ~= rd
   disp('Invalid output! Check input and try again')
   return
end

fdate(:)=Good_date(:);

ncclose

thecomment=sprintf('%s\n',' The dates of deployment were corrected by fixdate.m');
history(filename,thecomment);




