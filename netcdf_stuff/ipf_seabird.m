% function stat=ipf_seabird(moor_id,pos_order)
% ipf_seabird- creates netcdf file from seacat .cnv or microcat .asc files
%
%  usage: status = ipf_seabird('837','3')
%	where status is 1 if everything worked
%	2 input arguments are required-
%	  mooring_id, and the position of the seacat or microcat.  If the raw file 
%       name is 8172mc.asc, the arguments would be ('817','2') 

% The user still has to hand-edit this file to assure the fields are correct
%   instru, sdepth  always need changing
%   varnum, epcode, varin, varunit and the fscanf need modification if the seacat has
%   variables other than those we expect.
% This Input Parameter File (IPF) is the argument for asc2epic.m
% etm mods 6/3/08 From Fran's template 

if nargin ~=2; help mfilename; return; 
end
% modified to use the universal metadata file : globatt_805.txt
% change the line below to fit your system path for the location of m_cmg
mfRoot='C:\home\ellyn\mtl\m_cmg\trunk\meta_tools';
if (ischar(moor_id))
mid=moor_id;
else
mid=num2str(moor_id);
end

 attfile_name=['..\globatt_' mid '.txt'];
   gatt=read_globalatts(attfile_name)

rootName=[num2str(gatt.MOORING) ];

% opening input and output files
if(ischar(pos_order)
porder=pos_order;
else
proder=num2str(pos_order);
end

ascfile = [rootName porder 'mc.asc'];			% input data name including search path

if strcmp(ascfile,'mc')
% for c data with format : t, c, date_string, time_string
  [a,b,c]=textread(ascfile,'%f, %f, %s%*[^\n]','headerlines',42);
   perloc=findstr('.',ascfile);
   eval(['X' ascfile(1:perloc-1) '= [a b];'])
   % populate the variables that asc2epic expects
%   dolly will be used later to compute salt and dens ('S_40'; 'SV_80')
varnum=[1 2 ];                      %column numbers of input variables
epcode=[28 ; 51];                   % epic code values
sdepth=[6; 6];      % sensor depth if different from instrument depth
% creating cell array {} so one doesn;t have to worry about length of variable
varin={'T_28'; 'C_51'};
varunit={'C'; 'S/m'};
instru={'MC-465'; 'MC-465'};    % instrument and sensor identifiers
else
% for sc data with format : t, s, c, date_string, time_string
ascfile = [rootName '1sc.asc'];			% input data name including search path
 fid=fopen(ascfile);
     l1=fgets(fid);
   while (strcmp(l1(1),'*') | strcmp(l1(1),'#'))
    l1=fgets(fid);
   end
   dat=str2num(l1);
   ddat=fscanf(fid,'%f %f %f %f %f %f %f\n');
    dd = reshape(ddat,7,length(ddat)/7);
     ddd=[dat; dd'];
     ddd(:,6)=ddd(:,6)*60*60;  %convert hours to seconds
  fclose(fid)
   perloc=findstr('.',ascfile);
   eval(['X' ascfile(1:perloc-1) '= ddd(:,1:6);'])
   % populate the variables that asc2epic expects
varnum=[1 2 3 4 5 6];						%column numbers of input variables
epcode=[28; 51; 41; 71; 4010; 625];					% epic code values
sdepth=[63.11; 63.11; 63.11; 63.11; 63.11; 63.11];		% sensor depth if different from instrument depth
% creating cell array {} so one doesn;t have to worry about length of variable
varin={'T_28'; 'C_51'; 'S_41'; 'STH_71'; 'tran_4010'; 'TIM_625'};
varunit={'C'; 'S/m'; 'PSU'; 'KG/M**3'; 'Volts'; 'seconds'};
instru={'SC-2555'; 'SC-255'; 'SC-255';'SC-255'; 'TR-414'; 'SC-255'};	% instrument and sensor identifiers
%end of IPF 

end

netnam = [ascfile(1:end-4) '.cdf';			% output name including search path
% open netCDF file
f=netcdf(netnam,'clobber');				

f=fatnames(f,100);					% for program purposes

% specifying global information
f.inlat      =ncchar(gatt.longitude);		%can be either deg and minutes
f.inlon      =ncchar(gatt.latitude);		%or in decimal degrees
f.tstart   =ncfloat([2006 04 05 23 59 50]);		% yyyy mm dd hh mm ss 
f.samp_rate     =ncfloat(290);						% in seconds
f.DELTA_T     =ncchar('290');						% in seconds
f.water_depth   =ncfloat(gatt.WATER_DEPTH);			% in meters
f.inst_depth   =ncfloat(63.11);					% in meters
f.DATA_CMNT      =' ';		% any comment
f.magnetic_variation       =ncfloat(0);		% magnetic variation, negative is west
f.scipi    ='Brad Butman';		% responsible scientist
f.EXPERIMENT    ='Boston';				% experiment designation
f.moortype ='tripod';				% mooring type
% other f.xxx may be included, but the above are required
f.MOORING = ncchar('8182');
f.INST_TYPE = ncchar('Seabird MicroCat);
f.VAR_DESC = ncchar('T:C:S:SGTH:TRN:time');

% specifying variable information for data with just T & C
%   dolly should be used later to compute salt and dens ('S_40'; '')

