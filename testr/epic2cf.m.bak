function []=epic2cf(infile, title_str, exp_name);
% Convert EPIC time series files to CF-1.0 compliant files
% Usage: epic2cf(infile, title_str, exp_name)
%        infile = EPIC file name (mandatory)
%        title_str = 'a descriptive sting to be the title' (mandatory)
%        exp_name = 'html name of experiment page on stellwagen')
% Example: epic2cf('4151-a1h.cdf','Gulf of Maine, hourly average data from 4151');
%          will create a CF-1.0 compliant file called '4151-a1h.nc' in the 
%          same directory

% Here we create new output files by first copying the
% file and then adding the 'time_cf' variable and attributes to 
% these new files, but we could also just modify the EPIC 
% time series files instead
%
% Ellyn Montgomery (emontgomery@usgs.gov)
% Rich Signell (rsignell@usgs.gov)
% July 26, 2007

% check we've got the mandatory arguments
  if (nargin < 2); help mfilename; return; end

indx=strfind(infile,'.');  % don't assume suffix- could be cdf or nc
outfile=[infile(1:indx-1) '_cf.nc']; 

copyfile(infile,outfile); % file copy is fast, and you get the attributes

% open the input file
nc=netcdf(infile);
% get the time in days
time=nc{'time'}(:);
time2=nc{'time2'}(:);
jd=time+time2/24/3600/1000; %julian days
%Modified Julian Day is convenient for CF
%  see http://tycho.usno.navy.mil/mjd.html for more on modified Julian Day
%  gregorian(244000000.5)=[1858 11 16 12 0 0]
time_cf=jd-julian([1858 11 17 0 0 0]);

% open the output file for writing 
% so we can add 'time_cf' variable and the 'coordinates' 
% attribute for each dependent variable
outc=netcdf(outfile,'w');

% now add the CF-compliant variable 'time_cf'
outc{'time_cf'}=ncdouble('time');    % this instantiates the variable
outc{'time_cf'}(1:length(time_cf))=time_cf;  %this puts data in
% now add attributes
outc{'time_cf'}.units='days since 1858-11-17 00:00';
outc{'time_cf'}.long_name='Modified Julian Day';
outc{'time_cf'}.axis='T';
outc{'time_cf'}.type='EVEN';
outc{'time_cf'}.calendar='julian';

% finally add these attributes to make 'depth' CF-compliant
outc{'depth'}.positive='down';
outc{'depth'}.axis='Z';

% add cf-required global attributes
outc.title = ncchar(title_str);
outc.institution=ncchar('United States Geological Survey, Woods Hole Science Center');
outc.institution_url=ncchar('http://woodshole.er.usgs.gov');
if (exist('exp_name') ==1)
    url_str=['http://stellwagen.er.usgs.gov/' exp_name '.html'];
else
    url_str='http://stellwagen.er.usgs.gov/';
end
  outc.source=ncchar(url_str);
outc.contact=ncchar('ots_datamgr@usgs.gov');
outc.time_zone=ncchar('UTC');
outc.Conventions='CF-1.0';
outc.note='tested for CF compliance with Unidata CDM validator';
hist=outc.history;
outc.history=ncchar(['made CF-1.0 compliant ' datestr(floor(now)) ': ' hist]);

% add the "coordinates" attribute to the dependent vars which 
% follow the dimensions, usally 'time','time2','depth','lat', and 'lon').
% dim(nc) doesn't count time2, so need to add 1, and you want to start at
% the first variable following the dimensions, so +2.
epname=ncnames(var(nc));
  nd=dim(nc);
  strt_idx=length(nd)+2;
for i=strt_idx:length(epname)
    disp (['adding coordinates attribute to output variable ' epname{i}]);
    outc{epname{i}}.coordinates='time_cf depth lat lon';
    % put conditional statement here to match standard_names with epic_names
    varname=char(epname(i));
    switch varname
        case ('u_1205')
            outc{epname{i}}.standard_name=ncchar('eastward_seawater_velocity');
        case ('v_1206')
            outc{epname{i}}.standard_name=ncchar('northward_seawater_velocity');
        case ('CD_310')
            outc{epname{i}}.standard_name=ncchar('direction_of_seawater_velocity');
        case ('CS_300')
            outc{epname{i}}.standard_name=ncchar('seawater_speed');
        case ('T_20')
            outc{epname{i}}.standard_name=ncchar('seawater_temperature');
        case ('C_51')
            outc{epname{i}}.standard_name=ncchar('seawater_electrical_conductivity');
        case {'S_40', 'S_41'}
            outc{epname{i}}.standard_name=ncchar('seawater_salinity');
        case ('STH_71')
            outc{epname{i}}.standard_name=ncchar('seawater_density');
        % add more cases...
        otherwise
            disp(['no standard_name for ' varname]);
    end
end

% close the files to tidy up before exiting
close (outc)
close (nc)