function status = rdi2cdf(infile, outfile, minens, maxens, settings)
% rdi2cdf.m converts RDI ADCP files to netCDF format
%
% function status = rdi2cdf(infile, outfile, minens, maxens, settings);
%
% where:
%		infile	= the input file name in RDI broadband data format
%			  this includes the Workhorse family of ADCP's
%		outfile = the netCDF file name
%		minens = ensumble number at which to start converting or [] for all
%		maxens = ensemble number at which to stop converting or [] for all
%       settings = metadata settings input
%       status = -1 if there is a failure
%
% settings is used to run the function in batch mode within a script.
%         settings.rdi2cdf.Mooring_number = '8221'; % mooring number (USGS) or other identifier
%         settings.rdi2cdf.Deployment_date = '28-jun-2006';  % date the ADCP entered the water
%         settings.rdi2cdf.Recovery_date = '19-sep-2006'; % date the ADCP exited the water
%         settings.rdi2cdf.water_depth = 20.5; % in meters
%         settings.rdi2cdf.ADCP_serial_number = 2054; 
%         settings.rdi2cdf.transducer_offset = 1.235; % ADCP transducer offset from the sea bed
%         settings.rdi2cdf.pred_accuracy = 0.79; % from TRDI PLAN in cm/s
%         settings.rdi2cdf.slow_by = 3*60+9; % clock drift
%         settings.rdi2cdf.magnetic = 12.9; % declination in degrees, west is negative
%         settings.rdi2cdf.goodens = [1 Inf]; 
%     
% Example:  rdi2cdf(infile, outfile, [], [], settings);
%       to run rdi2cdf without interaction and convert all ensembles
%
% If no outfile is given, the header info for the file is displayed


%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
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

 

% Written by Marinna Martini
% for the U.S. Geological Survey
% Marine and Coastal Program
% Woods Hole Center, Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to mmartini@usgs.gov
%
% dependents:
%	rdhead.m	reads RDI header data format
%	rdflead.m	reads RDI fixed leader format
%	rdvlead.m	reads RDI variable leader format
%   rdbtadcp.m  read RDI bottom track data
%	mcnote.m	annotate netCDF data
%	mexcdf.mex	netCDF file I/O
%
% netCDF attributes and variable names follow EPIC conventions
%
% information on netCDF may be obtained at
% http://www.unidata.ucar.edu
% it's free!!
%
%
% Updated 18-jun-2008 (MM) change to SVN revision information
% Updated 24-feb-2008 (MM) add the coordinate variable ensemble so that the
% real ensemble numbers get displayed by ncbrowse
% Updated 15-jan-2008 (MM) fix a badly written if-then
% Updated 21-dec-2007 (MM) fix a bug where longnames was getting altered
% (cell referencing for varnames)
% Updated 25-sep-2007 (MM) add readout of Pressure Variance & Error Status Word
% Updated 19 sep 2007 (MM) add BT readout capability
% included using cell referencing for varnames
% checked 10-sep-2007 (MM) Verified that the dimension variables, 
% ensemble & bin do not have _FillValue defined
% Updated 3-may-2007 (MM) stop truncating metadata.  This was causing
% heartache when trimming in goodends because time was removed from the date string.
% Updated 12-feb-2007 (MM) improve how heading rotations are done
% Updated 31-jan-2007 (MM) allow any ADCP serial number, any transducer
% offset (these days there can be moored, uplooking ADCPs)
% remove batch calls
% Updated 26-jan-2007 (MM) add minimum and maximum values to variable atts.
% Updated 25-jan-2007 (MM) allow metadata for water_depth to be provided
% Updated 22-jan-2007 (MM) don't write pressure if there's no pressure
% sensor.  remove commented out netcdf toolbox calls, change version to 3.2
% Updated 16-jan-2007 (MM) exit gracefully id data can't be read
% Updated 22-de-2006 (MM) allow inputs to be provided as a struct
% Updated 12-Sep-2006 (SDR) changed inputdlg options so that user can now
%           resize the dialog box
% Updated 06-Sep-2005 (SDR) fixed fopen command so will now work with Mac
%                   OSx
% Updated 27-Jul-2005 (SDR) changed version from 3.0 to 3.1
% Updated 14-Dec-2004 (SDR) changed attributes for available sensors to
%       read 'yes' if sensor installed and 'no' if it is not
% Updated 22-Nov-2004 (SDR) default deployment dates now reflect year 2004
% Updated 11-Nov-2004 (SDR) NOTE_x in netcdf file now correctly reads
%       'heading sensor available'
% Updated 03-APr-2003 (ALR) Note numbers for depths
% Updated 27-Feb-2003 (ALR) added ADCP Transducer pressure variable to netcdf file
% Updated 05-Feb-2003 (ALR) adjusted heading_bias attribute so would accept decimals 
% Version 3.0 accomodates downward orientation 10-Jan-2003
% updated 10-Jan-2003 (ALR)  Adjusted NOTE in D so will reflect if bins are relative to seabed for upward facing
%   or relative to transducer for downward facing. And computed downward depths are negative.
% updated 02-Oct-2002 (ALR) Will now read downward facing orientation
% updated 29-Jun-2000 15:18:36
% updated 29-Oct-1999 09:20:26
% version 2.2c  by JMC
% updated 22-Oct-1999 15:00:37
% 7/22/99	Version 2.2b  edited by JMC
%				- request for deployment dates in the netcdf file for future checks
% 7/14/99	Version 2.2  edited by JMC
%				- space added in for some attributes that will be placed in the final
%				processed data file	
% 4/16/99	Version 2.1
%				- I am, in fact, reverting back to mexcdf because
%				  that access code is more than 50% faster.
% 3/19/99	Version 2.0
%				- convert netCDF file access from mexcdf to netcdf
%				  the old code is still contained within
% 8/14/98	Version 1.2b
%				- add the instrument serial number to global attributes
% 11/15/97  Version 1.2a
%				- fix some minor details for USGS data processing needs
% 10/28/97  Version 1.2
%           - fix the incorrect estimation of number of ensembles in the file
% 10/12/97  Version 1.1
%           - fix bin2dec & dec2bin to use MATLAB versions
%           - Add a dialog box to get metadata from user
% 5/2/97    Version 1.0
%           - fix time translation so that year is 1996 instead of '96
%           - include provision for turn of the century, assuming RDI's
%             dates will continue to be two digit year numbers
%
% 10/29/96  Version 0.0

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1495 $';
disp(sprintf('%s %s running',mfilename,rev_info))

mexcdf('SETOPTS',0);
status = 1;

% no netcdf equivalent
if nargin == 0,
	%error('I need an input file name');
    [filename, pathname] = uigetfile({'*.000';'*.PD0'},'Open a raw RDI current data file');
    if ~filename, status = -1; return; end
    infile = fullfile(pathname, filename);
end
% check the input file
if any(findstr(lower(computer), 'mac')) % added to work with mac OSx
    fid = fopen(infile,'r','ieee-le');  % actually, I think this works with mac and win
else
    fid = fopen(infile,'r');
end
if nargin < 2,	% assume the user only wants header info output    
    verbose = 1; % display the info
    disp(['Header information from RDI adcp file ',infile])
else verbose = 0;
end
if fid < 0, 
    disp(['rdi2cdf: could not open ',infile])
    status = -1;
    return
end
%[nbytes, nt, offsets] = rdhead(fid, verbose);
nbytes = rdhead(fid, verbose);
if isempty(nbytes),  % make sure this is readable
    disp('rdi2cdf: could not read raw data')
    status = -1;
    fclose(fid);
    return
end
if nargin < 2,	% assume the user only wants header info output    
    select=zeros(size(32,1));
    rdflead(fid,1,select); % output the leader data
    fclose(fid);
    return;
end
fclose(fid)
tic

% offset indicators
% if RD changes the order of their data types
% be sure to update these types and the other
% info defined below
VELOCITY = 3;
CORRELATION = 4;
INTENSITY = 5;
GOOD = 6;
% the first two read types have no meaning, they are holders
% so that the offset indicator can be used as a universal
% index for code readability
read_types=['int16';'int16';'int16';'uchar';'uchar';'uchar'];
% likewise, the first two rec ids are for the fixed and
% variable leader records
%rec_ids=[0 128 256 512 768 1024];
rec_ids=[0 128 256 512 768 1024 6];
longnames = {' ',' ','velocity','correlation','intensity','percent good',...
   'BT range','BT Error Velocity','BT Eastward Velocity','BT Northward Velocity','BT Vertical Velocity',...
   'BT correlation','BT evaluation','BT percent good',...
   'BT Ref. min','BT Ref. near','BT Ref. far','BT Ref. velocity','BT Ref. correlation',...
   'BT Ref. intensity','BT Ref. percent good','BT RSSI','BT Range MSB'};
VARNAMES={'   ';'   ';'vel';'cor';'AGC';'PGd';'BTR';'BTWe';'BTWu';'BTWv';'BTWd';...
      'BTc';'BTe';'BTp';...
      'BTRmin';'BTRnear';'BTRfar';'BTRv';'BTRc';'BTRi';'BTRp';'BTRSSI';'BTrMSB'};
BT_DATA = 0;	% default is ADCP without bottom tracking turned on
BT_MODE = 1;	% if 0, no water reference layer used

%
% ------ Open the files & write global attributes -----
%
% create the file
cdf = mexcdf('CREATE',outfile,'NC_CLOBBER');
if cdf == -1,
	error(['Problem opening netCDF output file: ',outfile]);
end

if exist('settings','var') && isfield(settings,'Deployment_date') && isfield(settings,'Recovery_date')
    Deployment_date = settings.Deployment_date;
    Recovery_date = settings.Recovery_date;
    if isfield(settings,'Mooring_number'),
        Mooring_number = settings.Mooring_number;
    else
        disp('No mooring number information provided')
        Mooring_number = 'uknown';
    end
    if isfield(settings, 'water_depth'),
        water_depth = settings.water_depth;
        water_depth_source = 'water_depth from user input by rdi2cdf';
    else
        disp('No nominal site water depth provided, using 0');
        water_depth = 0;
        water_depth_source = 'water_depth information not provided to rdi2cdf';
    end
else
    % get the deployment dates
    prompt  = {'Enter 4-digit mooring number:',...
      'Enter the deployment date (dd-mmm-yyyy):',...
      'Enter the recovery date (dd-mmm-yyyy):', ...
      'Enter the water depth (m):'};
	def     = {'0','01-jan-2004','01-jan-2004','0'};
	title   = 'Input mooring data for ADCP';
	lineNo  = 1;
	dlgresult  = inputdlg(prompt,title,lineNo,def);
	Mooring_number = dlgresult{1};
	Deployment_date = dlgresult{2};
	Recovery_date = dlgresult{3};
    water_depth = str2double(dlgresult{4});
    water_depth_source = 'water_depth from user input by rdi2cdf';
end 

% enter the global attributes   
mexcdf('ATTPUT',cdf,'GLOBAL','CREATION_DATE','CHAR',11,date);

mexcdf('ATTPUT',cdf,'GLOBAL','Mooring_number','CHAR',length(Mooring_number),Mooring_number);
mexcdf('ATTPUT',cdf,'GLOBAL','Deployment_date','CHAR',length(Deployment_date),Deployment_date);
mexcdf('ATTPUT',cdf,'GLOBAL','Recovery_date','CHAR',length(Recovery_date),Recovery_date);

mexcdf('ATTPUT',cdf,'GLOBAL','INST_TYPE','CHAR',19,'RD Instruments ADCP');
junk = sprintf('Converted to netCDF via MATLAB by %s %s\n', mfilename, rev_info);
mexcdf('ATTPUT',cdf,'GLOBAL','History','CHAR',length(junk),junk);

fid = fopen(infile,'r','ieee-le');
ens_start = ftell(fid);
%function [nb, nt, off] = rdhead(fid, verbose);
%	Read the header data from a raw ADCP
%	data file opened for binary reading.
%	fid = file handle returned by fopen
%	nb = number of bytes in the ensemble
%	nt = number of data types
%	off = offset to the data for each type
%	Set verbose = 1 in rdhead.m for a text output.
disp(['Header information from adcp file ',infile])
[nbytes, nt, offsets] = rdhead(fid, 1);
disp(sprintf('# bytes per ensemble = %d',nbytes))
disp(sprintf('# data types per ensemble = %d',nt))
disp(offsets)
if isempty(nbytes),
    disp('rdi2cdf: could not read raw data')
    return
end

notenum = 1;	% for general notes to file

% this is essentially the code from rdflead.m
% adapted for writing attributes to the netcdf file
%
% ------ Process Fixed Leader Data --------
%
%	Read the fixed leader data from a raw ADCP
%	data file opened for binary reading 
%	Returns the contents of the fixed leader
%	as 31 elements of the vector 'data' or an
%	empty matrix if the fixed leader ID is not
%	identified (error condition)
%	Set verbose=1 for a text output.
%	The names and meanings of these attibutes are taken
%	directly from Appendix B in the RDI Broadband 
%	Phase III technical manual.

if ~exist('verbose','var') || verbose == 0,
	verbose = 1;	% verbose must be = 1 to get all header info
end
NFIELDS = 32;
data=zeros(1,NFIELDS);
fld=1;  

if exist('settings','var')
    ADCP_serial_number = settings.ADCP_serial_number;
    transducer_offset = settings.transducer_offset;
    pred_accuracy = settings.pred_accuracy;
    slow_by = settings.slow_by;
%     if ischar(settings.magnetic),
%         magnetic = str2double(settings.magnetic);
%     else
%         magnetic = settings.magnetic;
%     end
else
	% get the distance of the ADCP head from the bottom
	% get the instrument serial number
	prompt  = {'Enter the ADCP''s serial number:',...
	'Enter the distance between the ADCP transducers and the sea bed in meters:',...
   'Enter the predicted accuracy given by PLAN in cm/s:',...
	'Enter the amount of time the ADCP clock was slow by in seconds:',...
	'Enter the magnetic variation at the mooring location in degrees'};
      
	def     = {'0','0','0','0','0'};
	title   = 'Input metadata from the mooring log';
	lineNo  = 1;
	dlgresult  = inputdlg(prompt,title,lineNo,def,'on');
	ADCP_serial_number = str2double(dlgresult{1});	
	transducer_offset = str2double(dlgresult{2});
    pred_accuracy = str2double(dlgresult{3});
    slow_by = str2double(dlgresult{4});
% 	magnetic = str2double(dlgresult{5}); 
end 

% make sure we're looking at the beginning of
% the fixed leader record by testing for it's ID
data(fld)=fread(fid,1,'ushort');
if(data(fld)~=0),
	disp('Fixed Leader ID not found');
	status=-1;
	return;
end
fld=fld+1;
% version number of CPU firmware
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% revision number of CPU firmware
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('CPU Version %d.%d',data(fld-1),data(fld))); end;
mexcdf('ATTPUT',cdf,'GLOBAL','firmware_version','FLOAT',1,data(fld-1)+data(fld)/100);
fld=fld+1;
% configuration, uninterpreted
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Hardware Configuration for LSB %d',data(fld))); 
   b=zeros(1,8); %dec2bin(data(fld));
   b(9-length(dec2bin(data(fld))):8)=dec2bin(data(fld));
   b=char(b);
   freqs=[75 150 300 600 1200 2400];
	junk=bin2dec(b(6:8));
	disp(sprintf('	System Frequency = %d kHz',freqs(junk+1))); 
   mexcdf('ATTPUT',cdf,'GLOBAL','frequency','LONG',1,freqs(junk+1));
	if b(5) == '0', 
		disp('	Concave Beam'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','beam_pattern','CHAR',7,'concave');
	end		
	if b(5) == '1', 
		disp('	Convex Beam'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','beam_pattern','CHAR',6,'convex');
	end		
	junk=bin2dec(b(3:4));
	disp(sprintf('Sensor Configuration #%d',junk+1)); 
   mexcdf('ATTPUT',cdf,'GLOBAL','sensor_configuration','LONG',1,junk+1);
	if b(2) == '0', disp('	Transducer head not attached'); end		
	if b(2) == '1', disp('	Transducer head attached'); end		
   mexcdf('ATTPUT',cdf,'GLOBAL','transducer_attached','LONG',1,b(2));
	if b(1) ~= '1', 
		disp('	Downward facing beam orientation'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','orientation','CHAR',4,'DOWN');
      orientation='down'; %added alr 01/10/03
	end		
	if b(1) == '1', 
		disp('	Upward facing beam orientation'); 
		mexcdf('ATTPUT',cdf,'GLOBAL','orientation','CHAR',2,'UP');
       orientation='up'; %added alr 01/10/03
	end		
end;
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Hardware Configuration MSB %d',data(fld))); 
    %b=dec2bin(data(fld));
    b=zeros(1,8); %dec2bin(data(fld));
    b(9-length(dec2bin(data(fld))):8)=dec2bin(data(fld));
    b=char(b);
	angles = [15 20 30 0];
	junk=bin2dec(b(7:8));
	disp(sprintf('	Beam angle = %d degrees',angles(junk+1)));
	% note that is beam angle = 0, it is some other than the above
   mexcdf('ATTPUT',cdf,'GLOBAL','beam_angle','LONG',1,angles(junk+1));
	junk=bin2dec(b(1:4));
	if junk == 4, 
		disp('	4-beam janus configuration'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','janus','CHAR',6,'4 Beam');
	end
	if junk == 5, 
		disp('	5-beam janus configuration, 3 demodulators'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','janus','CHAR',15,'5 Beam, 3 demod');
	end
	if junk == 15, 
		disp('	4-beam janus configuration, 2 demodulators'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','janus','CHAR',15,'4 Beam, 2 demod');
	end
end;
fld=fld+1;
% real (0) or simulated (1) data flag
data(fld)=fread(fid,1,'uchar');
if data(fld),
	if verbose, disp('The data is simulated'); end
else
	if verbose, disp('The data is real'); end
end
mexcdf('ATTPUT',cdf,'GLOBAL','simulated_data','LONG',1,data(fld));
fld=fld+1;
% undefined
data(fld)=fread(fid,1,'uchar');	
if verbose, disp(sprintf('time period between sound pulses.:  %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','lag_length','LONG',1,data(fld));
fld=fld+1;
% number of beams
data(fld)=fread(fid,1,'uchar');	
if verbose, disp(sprintf('Number of beams used to calculate velocity data:  %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','beams_in_velocity_calculation','LONG',1,data(fld));
fld=fld+1;
nbeams = 4;	%data(fld)
% number of depth cells
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Number of depth cells %d',data(fld))); end;
nbins = data(fld);
fld=fld+1;
% pings per ensemble
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Pings per ensemble %d',data(fld))); end;
mexcdf('ATTPUT',cdf,'GLOBAL','pings_per_ensemble','LONG',1,data(fld));
fld=fld+1;
% depth cell length in cm
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Depth cell size %d cm',data(fld))); end
% this attribute is tagged to the depth variable
fld=fld+1;
% blanking distance (WF)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Blank after xmit distance %d cm',data(fld))); end
% this attribute is tagged to the depth variable
fld=fld+1;
% Profiling mode (WM)
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Profiling mode %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','profiling_mode','LONG',1,data(fld));
fld=fld+1;

%Predicted Accuracy given in PLAN and entered by user
mexcdf('ATTPUT',cdf,'GLOBAL','pred_accuracy','FLOAT',1,pred_accuracy);

% Minimum correlation threshold (WC)
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Valid range for correlation %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','valid_correlation_range','LONG',2,[data(fld) 255]);
fld=fld+1;

% number of code repetitions
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Code repetitions %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','code_repetitions','LONG',1,data(fld));
fld=fld+1;

% Minimum percent good to output data (WG)
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Minimum and maximum percent good for output %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','minmax_percent_good','LONG',2,[data(fld) 100]);
fld=fld+1;

% Error velocity threshold (WE)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Minimum and Maximum Error Velocity values permitted %d mm s-1',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','error_velocity_threshold','LONG',1,data(fld));
fld=fld+1;

% time between ping groups (TP)
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
tp=[data(fld-2),data(fld-1),data(fld)];  %added by JMC
TP = str2double(sprintf('%d.%d',(tp(1)*60 + tp(2)),tp(3)));

if verbose, disp(sprintf('Time between ping groups %d', TP)); end
mexcdf('ATTPUT',cdf,'GLOBAL','time_between_ping_groups','FLOAT',1,...
	TP);

fld=fld+1;
% coordinate transformation (EX)
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Coordinate Transformation = %d',data(fld))); 
	%b=dec2bin(data(fld));
   %b=zeros(1,8); %dec2bin(data(fld));
   b=dec2bin(data(fld),8);
   %b(9-length(dec2bin(data(fld))):8)=dec2bin(data(fld));
   %b=char(b);
	transform=bin2dec(b(4:5));
	if transform == 0, 
		disp('	Data stored coordinates = Beam'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','transform','CHAR',4,'BEAM');
	end
	if transform == 1, 
		disp('	Data stored coordinates = Instrument'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','transform','CHAR',4,'INST');
	end
	if transform == 2, 
		disp('	Data stored coordinates = Ship'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','transform','CHAR',4,'SHIP');
	end
	if transform == 3, 
		disp('	Data stored coordinates = Earth'); 
      mexcdf('ATTPUT',cdf,'GLOBAL','transform','CHAR',5,'EARTH');
	end
%	if b(6) == '1', disp('	Tilts used in transformation'); end
%	if b(7) == '1', disp('	3-beam solution used, this ensemble'); end
end
fld=fld+1;
% Heading Alignment (EA)
data(fld)=fread(fid,1,'int16');
if verbose, disp(sprintf('Heading alignment %d',data(fld)./100)); end
hdg_alignment = data(fld)./100;

fld=fld+1;
% Heading Bias (EB)
data(fld)=fread(fid,1,'int16');
if verbose, disp(sprintf('Heading Bias: %d deg',data(fld)./100)); end
hdg_bias = data(fld)./100;

fld=fld+1;
% Sensor source (EZ)
data(fld)=fread(fid,1,'uchar');
if verbose,
	disp(sprintf('Sensor Source = %d',data(fld))); 
	%b=(data(fld));
   b=zeros(1,8); %dec2bin(data(fld));
   b(9-length(dec2bin(data(fld))):8)=dec2bin(data(fld));
   b=char(b);
	if b(2) == '1',disp('  Sound speed computed from ED, ES & ET');
		mexcdf('ATTPUT',cdf,'GLOBAL','Sound_speed_computed_from_ED_ES_ET','CHAR',3,'YES');
	end
	if b(3) == '1', disp('  ED taken from depth sensor');
		mexcdf('ATTPUT',cdf,'GLOBAL','ED_taken_from_depth_sensor','CHAR',3,'YES');
	end	
	if b(4) == '1', disp('  EH taken from transducer heading sensor');
		mexcdf('ATTPUT',cdf,'GLOBAL','EH_taken_from_transducer_heading_sensor','CHAR',3,'YES');
	end	
	if b(5) == '1', disp('  EP taken from transducer pitch sensor');	
		mexcdf('ATTPUT',cdf,'GLOBAL','EP_taken_from_transducer_pitch_sensor','CHAR',3,'YES');
	end	
	if b(6) == '1', disp('  ER taken from transducer roll sensor');	
		mexcdf('ATTPUT',cdf,'GLOBAL','ER_taken_from_transducer_roll_sensor','CHAR',3,'YES');
	end	
	if b(7) == '1', disp('  ES derived from conductivity sensor');	
		mexcdf('ATTPUT',cdf,'GLOBAL','ES_derived_from_conductivity_sensor','CHAR',3,'YES');
	end	
	if b(8) == '1', disp('  ET taken from temperature sensor');
		mexcdf('ATTPUT',cdf,'GLOBAL','ET_taken_from_temperature_sensor','CHAR',3,'YES');
	end	
end
fld=fld+1;
% Sensors available
data(fld)=fread(fid,1,'uchar');
if verbose,
	disp(sprintf('Sensor Availability = %d',data(fld))); 
	%b=dec2bin(data(fld));
   b=zeros(1,8); %dec2bin(data(fld));
   b(9-length(dec2bin(data(fld))):8)=dec2bin(data(fld));
   b=char(b);
	if b(3) == '1', disp('	depth sensor installed'); 
		mexcdf('ATTPUT',cdf,'GLOBAL','depth_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','depth_sensor','CHAR',2,'NO');
	end	
	if b(4) == '1', disp('	heading sensor installed');  
		mexcdf('ATTPUT',cdf,'GLOBAL','heading_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','heading_sensor','CHAR',2,'NO');
	end	
	if b(5) == '1', disp('	pitch sensor installed');  
		mexcdf('ATTPUT',cdf,'GLOBAL','pitch_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','pitch_sensor','CHAR',2,'NO');
	end	
	if b(6) == '1', disp('	roll sensor installed');  
		mexcdf('ATTPUT',cdf,'GLOBAL','roll_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','roll_sensor','CHAR',2,'NO');
	end	
	if b(7) == '1', disp('	conductivity sensor installed');  
		mexcdf('ATTPUT',cdf,'GLOBAL','conductivity_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','conductivity_sensor','CHAR',2,'NO');
	end	
	if b(8) == '1', disp('	temperature sensor installed');  
		mexcdf('ATTPUT',cdf,'GLOBAL','temperature_sensor','CHAR',3,'YES');
    else mexcdf('ATTPUT',cdf,'GLOBAL','temperature_sensor','CHAR',2,'NO');
	end	
end
fld=fld+1;
% Bin 1 distance
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Distance to center of bin 1: %d cm',data(fld))); end
% this is saved with the depth variable
fld=fld+1;
% xmit pulse length
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Transmit pulse length %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','transmit_pulse_length','LONG',1,data(fld));
mcnote(cdf,'GLOBAL','transmit_pulse_length units are cm',notenum);	
notenum=notenum+1;
fld=fld+1;
% starting depth cell
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Starting water layer %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','starting_water_layer','LONG',1,data(fld));
fld=fld+1;
% ending depth cell
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Ending water layer %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','ending_water_layer','LONG',1,data(fld));
fld=fld+1;
% false target reject threshold
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('False target reject range values %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','false_target_reject_values','LONG',2,[data(fld) 255]);
fld=fld+1;
% spare
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% transmit lag distance
% This field, determined mainly by the setting of the WMcommand,
% contains the distance between pulse repetitions.
% Scaling: LSD = 1 centimeter; Range = 0 to 65535 centimeters
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Transmit lag distance %d',data(fld))); end
mexcdf('ATTPUT',cdf,'GLOBAL','transmit_lag_distance','LONG',1,data(fld));
mcnote(cdf,'GLOBAL','transmit_lag_distance units are cm',notenum);	
notenum=notenum+1;
mexcdf('ATTPUT',cdf,'GLOBAL','ADCP_serial_number','LONG',1,ADCP_serial_number);

% save the rest of the data for later
fleader = data;

% now see if there is bottom tracking data in this file.
if nt>6,	% bottom tracking is usually data type 7
    % now we must put the bottom tracking settings into the netCDF file
    pos=ftell(fid);
    % skip to the location of the next data type,
    if fseek(fid, ens_start+offsets(7)-pos, 'cof') >= 0,
        % mark for desired data to get for netCDF GLOBAL aatributes
        flags = zeros(1,59);
        flags(2)=1;	% number of BT pings averaged together per ensemble
        flags(3)=1; % BT reaquire delay
        flags(4)=1; % min correlation magnitude
        flags(5)=1; % min evaluation amplitude
        flags(6)=1; % min percent good
        flags(7)=1; % BT mode
        flags(8)=1; % BT max error velocity
        flags(50)=1; % Maximum tracking depth
        flags(55)=1; % Shallow water gain level
        % get the data
        junk = rdbtadcp(fid, 0, flags);
        if ~isempty(junk),
            BT_DATA = 1;  % we do indeed have bottom track data!
            % write netCDF GLOBAL attributes
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_pings_per_ensemble','LONG',1,junk(1));
            if verbose, disp(sprintf('BT pings per ensemble %d',junk(1))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_reaquire_delay','LONG',1,junk(2));
            if verbose, disp(sprintf('BT reaqure delay %d',junk(2))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_min_corr_mag','LONG',1,junk(3));
            if verbose, disp(sprintf('BT min correlation delay %d',junk(3))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_min_eval_mag','LONG',1,junk(4));
            if verbose, disp(sprintf('BT min evaluation magnitude %d',junk(4))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_min_percent_good','LONG',1,junk(5));
            if verbose, disp(sprintf('BT min percent good %d',junk(5))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_mode','LONG',1,junk(6));
            if verbose, disp(sprintf('BT mode %d',junk(6))); end
            BT_MODE=junk(6); % water reference was used if BM (BT_MODE) is set to 0
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_max_err_vel','LONG',1,junk(7));
            if verbose, disp(sprintf('BT max error velocity %d',junk(7))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_max_tracking_depth','LONG',1,junk(8));
            if verbose, disp(sprintf('BT max tracking depth %d',junk(8))); end
            mexcdf('ATTPUT',cdf,'GLOBAL','BT_shallow_water_gain','LONG',1,junk(9));
            if verbose, disp(sprintf('BT shallow water gain %d',junk(9))); end
        end
    end

end

disp('-----------')
%
% ------ Set up the variables -----
%

% determine the number of ensembles from the file size
%	and number of bytes per ensemble
% there is an 8260 byte leader in every file
LEADERSIZE = 0; % original size 8260;
% the checksum at the end of every ensemble record is two bytes
CHECKSUMSIZE = 2;
fseek(fid,0,1);	% go to end of file
infilesize = ftell(fid);
disp(sprintf('Size of input file = %f kb',infilesize/1000))
nens = ceil((infilesize-LEADERSIZE)/(nbytes+CHECKSUMSIZE));
disp(sprintf('%d ensembles estimated from file size',nens))

% dimensions
mexcdf('DIMDEF',cdf,'ensemble','NC_UNLIMITED'); % record dim, ID = 0
binid=mexcdf('DIMDEF',cdf,'bin',nbins);

% variables
% 
mexcdf('VARDEF',cdf,'D','FLOAT',1,binid);
mexcdf('ATTPUT',cdf,'D','units','CHAR',1,'m');
mexcdf('ATTPUT',cdf,'D','long_name','CHAR',9,'DEPTH (m)');
mexcdf('ATTPUT',cdf,'D','_FillValue','FLOAT',1,1e35);
% note, netcdf will not handle leading _
mexcdf('ATTPUT',cdf,'D','epic_code','LONG',1,3);

mexcdf('VARDEF',cdf,'ensemble','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'ensemble','units','CHAR',5,'count');
mexcdf('ATTPUT',cdf,'ensemble','long_name','CHAR',16,'ensemble (count)');
mexcdf('ATTPUT',cdf,'ensemble','_FillValue','FLOAT',1,1e35);
% note, netcdf will not handle leading _
mexcdf('ATTPUT',cdf,'ensemble','epic_code','LONG',1,0);

bin1=fleader(26)/100;
mexcdf('ATTPUT',cdf,'D','center_first_bin','FLOAT',1,bin1);
blank=fleader(12)/100;
mexcdf('ATTPUT',cdf,'D','blanking_distance','FLOAT',1,blank);
binsize=fleader(11)/100;
mexcdf('ATTPUT',cdf,'D','bin_size','FLOAT',1,binsize);
bincnt=nbins;
mexcdf('ATTPUT',cdf,'D','bin_count','LONG',1,nbins);
if ~exist('water_depth','var'), 
    water_depth = 0; 
    water_depth_source = 'water_depth information not provided to rdi2cdf';
end
mexcdf('ATTPUT',cdf,'D','water_depth','FLOAT',1,water_depth);
mexcdf('ATTPUT',cdf,'D','water_depth_source','CHAR',length(water_depth_source),water_depth_source);
% water depth should get updated by trimbins' surface detect/pressure process
%transducer_offset = 0;
mexcdf('ATTPUT',cdf,'D','transducer_offset_from_bottom','FLOAT',1,transducer_offset);

% TODO - the name depths here really indicates a range relative to the head
% do we want to change this terminology?
switch orientation  %Added 10-Jan-2003
case 'up'
    mcnote(cdf,'D','bin depths are relative to the seabed',notenum);
    notenum=notenum+1;
    % compute bin locations
    depths = bin1:binsize:(((bincnt-1)*binsize)+bin1);
    % adjust for ADCP position and save depths for later
    depths = depths+transducer_offset;
case 'down'
     mcnote(cdf,'D','bin depths are relative to the transducer head',notenum);
     notenum=notenum+1;
    % compute bin locations
    depths = bin1:binsize:(((bincnt-1)*binsize)+bin1);
    depths = depths * -1;
end

mexcdf('VARDEF',cdf,'TIM','DOUBLE',1,0);
mexcdf('ATTPUT',cdf,'TIM','units','CHAR',12,'decimal days');
mexcdf('ATTPUT',cdf,'TIM','long_name','CHAR',11,'JULIAN DAYS');
mexcdf('ATTPUT',cdf,'TIM','_FillValue','DOUBLE',1,1e35);
mexcdf('ATTPUT',cdf,'TIM','epic_code','LONG',1,627);
mexcdf('ATTPUT',cdf,'TIM','valid_min','LONG',1,0);
mexcdf('ATTPUT',cdf,'TIM','slow_by','LONG',1,slow_by);
mcnote(cdf,'TIM','amount of time the ADCP clock was "slow_by" is in seconds',notenum);	
notenum=notenum+1;

mexcdf('VARDEF',cdf,'Rec','LONG',1,0);
mexcdf('ATTPUT',cdf,'Rec','units','CHAR',6,'counts');
mexcdf('ATTPUT',cdf,'Rec','long_name','CHAR',7,'Records');
mexcdf('ATTPUT',cdf,'Rec','_FillValue','LONG',1,1e35);
mexcdf('ATTPUT',cdf,'Rec','epic_code','LONG',1,1207);
mexcdf('ATTPUT',cdf,'Rec','valid_min','LONG',1,0);
%
mexcdf('VARDEF',cdf,'sv','LONG',1,0);
mexcdf('ATTPUT',cdf,'sv','units','CHAR',5,'m s-1');
mexcdf('ATTPUT',cdf,'sv','long_name','CHAR',20,'sound velocity (m s-1)');
mexcdf('ATTPUT',cdf,'sv','_FillValue','LONG',1,1e35);
mexcdf('ATTPUT',cdf,'sv','epic_code','LONG',1,80);
mexcdf('ATTPUT',cdf,'sv','valid_range','LONG',2,[1400 1600]);
%
for i=1:nbeams,
    %varname = [VARNAMES(VELOCITY,:),int2str(i)];
    varname = sprintf('%s%1d',VARNAMES{VELOCITY},i);
    mexcdf('VARDEF',cdf,varname,'FLOAT',2,[0 1]);
    mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'mm s-1');
    if ~transform,	% this EPIC code is for BEAM coordinates only
        buf=sprintf('Beam %1i velocity, mm s-1',i);
        mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
        mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1279+i);
    end
    mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
    mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[-32768 32767]);
end
%
for i=1:nbeams,
	%varname = [VARNAMES(CORRELATION,:),int2str(i)];
    varname = sprintf('%s%1d',VARNAMES{CORRELATION},i);
	mexcdf('VARDEF',cdf,varname,'FLOAT',2,[0 1]);
	mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
	buf=sprintf('Beam %1i correlation',i);
	mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
	mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1293+i);
	mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
	mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
end	
%
for i=1:nbeams,
	%varname = [VARNAMES(INTENSITY,:),int2str(i)];
    varname = sprintf('%s%1d',VARNAMES{INTENSITY},i);
	mexcdf('VARDEF',cdf,varname,'FLOAT',2,[0 1]);
	mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
	buf=sprintf('Echo Intensity (AGC) Beam %1i',i);
	mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
	mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1220+i);
    mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
	mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
	mexcdf('ATTPUT',cdf,varname,'norm_factor','FLOAT',1,0.45);
	mcnote(cdf,varname,'normalization to db',notenum);	
	notenum=notenum+1;
end	
%
for i=1:nbeams,
	%varname = [VARNAMES(GOOD,:),int2str(i)];
    varname = sprintf('%s%1d',VARNAMES{GOOD},i);
	mexcdf('VARDEF',cdf,varname,'FLOAT',2,[0 1]);
	mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
	buf=sprintf('Percent Good Beam %1i',i);
	mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
	mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1240+i);
	mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
	mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 100]);
end	

mexcdf('VARDEF',cdf,'Hdg','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'Hdg','units','CHAR',7,'degrees');
mexcdf('ATTPUT',cdf,'Hdg','long_name','CHAR',12,'INST Heading');
mexcdf('ATTPUT',cdf,'Hdg','epic_code','LONG',1,1215);
mexcdf('ATTPUT',cdf,'Hdg','_FillValue','FLOAT',1,1e35);
mexcdf('ATTPUT',cdf,'Hdg','valid_range','FLOAT',2,[0 359.99]);
mexcdf('ATTPUT',cdf,'Hdg','heading_alignment','DOUBLE',1,hdg_alignment);
c_hdg = 0;
mexcdf('ATTPUT',cdf,'Hdg','heading_bias','DOUBLE',1,hdg_bias);
% Change by MM 12-feb-2007 be very specific about heading rotation corrections
% now decide if the heading should be rotated 
% if the ADCP, or Wavesmon, was given an EB or magnetic variation value,
% then the ADCP heading data already got rotated by the EB value, DON'T DO IT HERE
if ~isequal(hdg_bias,0) % hdg_bias = EB command setting, magnetic = declination given by user
    mcnote(cdf,'Hdg','a heading bias was applied by EB during deployment or by wavesmon',notenum);
else
    mcnote(cdf,'Hdg','no heading bias was applied by EB during deployment or by wavesmon',notenum);
end
notenum=notenum+1;
if ~exist('magnetic','var'), magnetic = 0; end
mexcdf('ATTPUT',cdf,'Hdg','user_applied_heading_correction','DOUBLE',1,magnetic);
if ~isequal(magnetic,0), % user wants a correction, possibly in addition to that done earlier
    c_hdg = magnetic; % this will be added to the heading value later.
    mcnote(cdf,'Hdg','a heading correction was input by the user and applied to Hdg by rdi2cdf',notenum);
else
    mcnote(cdf,'Hdg','no heading correction was input by the user and applied to Hdg by rdi2cdf',notenum);
end
%notenum=notenum+1;

mexcdf('VARDEF',cdf,'Ptch','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'Ptch','units','CHAR',7,'degrees');
mexcdf('ATTPUT',cdf,'Ptch','long_name','CHAR',10,'INST Pitch');
mexcdf('ATTPUT',cdf,'Ptch','epic_code','LONG',1,1216);
mexcdf('ATTPUT',cdf,'Ptch','_FillValue','FLOAT',1,1e35);
mexcdf('ATTPUT',cdf,'Ptch','valid_range','FLOAT',2,[-20 20]);
%
mexcdf('VARDEF',cdf,'Roll','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'Roll','units','CHAR',7,'degrees');
mexcdf('ATTPUT',cdf,'Roll','long_name','CHAR',9,'INST Roll');
mexcdf('ATTPUT',cdf,'Roll','epic_code','LONG',1,1217);
mexcdf('ATTPUT',cdf,'Roll','_FillValue','FLOAT',1,1e35);
mexcdf('ATTPUT',cdf,'Roll','valid_range','FLOAT',2,[-20 20]);

for i=1:3,
    varnames = {'HdgSTD','PtchSTD','RollSTD'};
    Olongnames = {'Heading Standard Deviation','Pitch Standard Deviation','Roll Standard Deviation'};
    mexcdf('VARDEF',cdf,varnames{i},'FLOAT',1,0);
    mexcdf('ATTPUT',cdf,varnames{i},'units','CHAR',7,'degrees');
    mexcdf('ATTPUT',cdf,varnames{i},'long_name','CHAR',length(Olongnames{i}),Olongnames{i});
    mexcdf('ATTPUT',cdf,varnames{i},'_FillValue','FLOAT',1,1e35);
    if i==1,
        mexcdf('ATTPUT',cdf,varnames{i},'valid_range','FLOAT',2,[0 180]);
    else
        mexcdf('ATTPUT',cdf,varnames{i},'valid_range','FLOAT',2,[0 20]);
    end
end
%
mexcdf('VARDEF',cdf,'Tx','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'Tx','units','CHAR',7,'degrees');
mexcdf('ATTPUT',cdf,'Tx','long_name','CHAR',27,'ADCP Transducer Temperature');
mexcdf('ATTPUT',cdf,'Tx','epic_code','LONG',1,3017);
mexcdf('ATTPUT',cdf,'Tx','_FillValue','FLOAT',1,1e35);
mexcdf('ATTPUT',cdf,'Tx','valid_range','FLOAT',2,[-5 40]);
%
mexcdf('VARDEF',cdf,'xmitc','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'xmitc','units','CHAR',4,'amps');
mexcdf('ATTPUT',cdf,'xmitc','long_name','CHAR',16,'transmit current');
mexcdf('ATTPUT',cdf,'xmitc','_FillValue','FLOAT',1,1e35);
%
mexcdf('VARDEF',cdf,'xmitv','FLOAT',1,0);
mexcdf('ATTPUT',cdf,'xmitv','units','CHAR',5,'volts');
mexcdf('ATTPUT',cdf,'xmitv','long_name','CHAR',16,'transmit voltage');
mexcdf('ATTPUT',cdf,'xmitv','_FillValue','FLOAT',1,1e35);
%
mexcdf('VARDEF',cdf,'dac','LONG',1,0);
mexcdf('ATTPUT',cdf,'dac','units','CHAR',6,'counts');
mexcdf('ATTPUT',cdf,'dac','long_name','CHAR',10,'DAC output');
mexcdf('ATTPUT',cdf,'dac','_FillValue','LONG',1,1e35);
%
mexcdf('VARDEF',cdf,'VDD3','LONG',1,0);
mexcdf('ATTPUT',cdf,'VDD3','units','CHAR',5,'volts');
mexcdf('ATTPUT',cdf,'VDD3','long_name','CHAR',17,'battery voltage 3');
mexcdf('ATTPUT',cdf,'VDD3','_FillValue','LONG',1,1e35);
%
mexcdf('VARDEF',cdf,'VDD1','LONG',1,0);
mexcdf('ATTPUT',cdf,'VDD1','units','CHAR',5,'volts');
mexcdf('ATTPUT',cdf,'VDD1','long_name','CHAR',17,'battery voltage 1');
mexcdf('ATTPUT',cdf,'VDD1','_FillValue','LONG',1,1e35);

mexcdf('VARDEF',cdf,'VDC','LONG',1,0);
mexcdf('ATTPUT',cdf,'VDC','units','CHAR',5,'volts');
mexcdf('ATTPUT',cdf,'VDC','long_name','CHAR',3,'VDC');
mexcdf('ATTPUT',cdf,'VDC','_FillValue','LONG',1,1e35);

for i=1:4,
    varname = ['EWD',int2str(i)];
    mexcdf('VARDEF',cdf,varname,'LONG',1,0);
    mexcdf('ATTPUT',cdf,varname,'units','CHAR',11,'binary flag');
    mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',17,'Error Status Word');
    mexcdf('ATTPUT',cdf,varname,'_FillValue','LONG',1,1e35);
end

% make this conditional on presence of pressure sensor MM 1/22/07
val = mexcdf('ATTGET',cdf,'GLOBAL','depth_sensor');
if strcmp(val,'YES'),
    depth_sensor = 1;
    % Added 27-Feb-03
    %   4:P  :PRESSURE (PASCALS)       :depth:Pa: :
    mexcdf('VARDEF',cdf,'Pressure','FLOAT',1,0);
    mexcdf('ATTPUT',cdf,'Pressure','units','CHAR',7,'pascals');
    mexcdf('ATTPUT',cdf,'Pressure','long_name','CHAR',24,'ADCP Transducer Pressure');
    mexcdf('ATTPUT',cdf,'Pressure','epic_code','LONG',1,4);
    mexcdf('ATTPUT',cdf,'Pressure','_FillValue','FLOAT',1,1e35);
    mexcdf('ATTPUT',cdf,'Pressure','valid_range','FLOAT',2,[0 4294967295]);
    % added 25-sep-07 MM
    mexcdf('VARDEF',cdf,'PressVar','FLOAT',1,0);
    mexcdf('ATTPUT',cdf,'PressVar','units','CHAR',7,'pascals');
    mexcdf('ATTPUT',cdf,'PressVar','long_name','CHAR',33,'ADCP Transducer Pressure Variance');
    mexcdf('ATTPUT',cdf,'PressVar','epic_code','LONG',1,0);
    mexcdf('ATTPUT',cdf,'PressVar','_FillValue','FLOAT',1,1e35);
    mexcdf('ATTPUT',cdf,'PressVar','valid_range','FLOAT',2,[0 4294967295]);
else
    depth_sensor = 0;
end

% deal with the bottom track data
if BT_DATA,
   % BT range
   for i=1:nbeams,
      varname = [VARNAMES{7},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',1,'m');
      buf=sprintf('%s %1i',longnames{7},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 655.35]);
   end	
   % BT velocity
   for i=1:nbeams,
      if transform==3,	% this EPIC code is for EARTH coordinates in cm/s only
         varname = [VARNAMES{7+i}];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'mm s-1');
         % TODO the slash in mm/s is causing The argument for the %s format
         % specifier must be of type char (a string).
         buf=sprintf('%s%d, mm s-1',longnames{7+1},i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         %EPICcodes=[1260, 1261, 1262, 1263]; % err, east, north, vert
         % mm/s is not EPIC compliant
         %mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,EPICcodes(i));
      else
         varname = ['BTV',int2str(i)];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         buf=sprintf('BT velocity, mm s-1 %1i',i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'mm s-1');
      end
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,32768);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[-32768 32767]);
   end
   % BT correlation
   for i=1:nbeams,
      varname = [VARNAMES{12},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
      buf=sprintf('%s %1i',longnames{12},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
   end	
   % BT evaluation amplitude
   for i=1:nbeams,
      varname = [VARNAMES{13},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
      buf=sprintf('%s %1i',longnames{13},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
   end	
   % BT percent good
   for i=1:nbeams,
      varname = [VARNAMES{14},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',7,'percent');
      buf=sprintf('%s %1i',longnames{14},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1269+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 100]);
   end	
   if BT_MODE==0, % water reference layer was used
      % BT ref layer min
      varname = [VARNAMES{15},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',2,'dm');
      buf=sprintf('%s %1i',longnames{15},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 999]);
      % BT ref layer near
      varname = [VARNAMES{16},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',2,'dm');
      buf=sprintf('%s %1i',longnames{16},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 9999]);
      % BT ref layer far
      varname = [VARNAMES{17},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',2,'dm');
      buf=sprintf('%s %1i',longnames{17},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 9999]);
      % BT Ref. velocity
      for i=1:nbeams,
         varname = [VARNAMES{18},int2str(i)];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         buf=sprintf('%s %1i',longnames{18},i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'mm s-1');
         mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
         mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[-32768 32767]);
      end
      % BT Ref. Layer correlation
      for i=1:nbeams,
         varname = [VARNAMES{19},int2str(i)];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
         buf=sprintf('%s %1i',longnames{19},i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
         mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
         mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
      end	
      % BT Ref. Layer echo intensity
      for i=1:nbeams,
         varname = [VARNAMES{20},int2str(i)];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
         buf=sprintf('%s %1i',longnames{20},i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
         mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
         mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
      end	
      % BT Ref. Layer percent good
      for i=1:nbeams,
         varname = [VARNAMES{21},int2str(i)];
         mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
         mexcdf('ATTPUT',cdf,varname,'units','CHAR',7,'percent');
         buf=sprintf('%s %1i',longnames{21},i);
         mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
         mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1269+i);
         mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
         mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 100]);
      end	
   end
   % BT Receiver Signal Strength Indicator (RSSI)
   for i=1:nbeams,
      varname = [VARNAMES{22},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',6,'counts');
      buf=sprintf('%s %1i',longnames{22},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[0 255]);
   end	
   % BT Range MSB
   for i=1:nbeams,
      varname = [VARNAMES{23},int2str(i)];
      mexcdf('VARDEF',cdf,varname,'FLOAT',1,0);
      mexcdf('ATTPUT',cdf,varname,'units','CHAR',2,'cm');
      buf=sprintf('%s %1i',longnames{23},i);
      mexcdf('ATTPUT',cdf,varname,'long_name','CHAR',length(buf),buf);
      %no code yet mexcdf('ATTPUT',cdf,varname,'epic_code','LONG',1,1263+i);
      mexcdf('ATTPUT',cdf,varname,'_FillValue','FLOAT',1,1e35);
      mexcdf('ATTPUT',cdf,varname,'valid_range','FLOAT',2,[65536 16777215]);
   end	
end % end of if BT_DATA

mexcdf('ENDEF',cdf);  %line 848, no varputs before endef!!
fclose(fid);	% close file to force a rewind

%
% ------- load up the data ------
%
fid = fopen(infile,'r','ieee-le');

% load in the depths for each bin
%status = mexcdf('VARPUT', cdfid, varid, start, count, value, autoscale)
status=mexcdf('VARPUT',cdf,'D',0,nbins,depths);
idx=0;
readidx=1;
% define some more things
time_greg=zeros(nens,6);
if ~exist('minens','var') || isempty(minens),
   minens = 1;
elseif minens < 1,
   minens = 1;
end
if ~exist('maxens','var') || isempty(maxens) || maxens > nens,
   maxens = nens;
end

while 1,
    ens_start = ftell(fid);
    if ens_start < 0, break; end
    if (readidx >= minens) && (readidx <= maxens),
        % skip to the location of variable leader
        if fseek(fid, offsets(2), 'cof') < 0, break; end
        vldata = rdvlead(fid, 0);
        if ~isempty(vldata),
            % sort and store
            ensnum = vldata(2)+(65536.*(vldata(10)));
            mexcdf('VARPUT',cdf,'Rec',idx,1,ensnum);
            mexcdf('VARPUT',cdf,'ensemble',idx,1,ensnum); % make a coordinate dimension for ncbrowse
            % fix the year, should work for the next 90 years...
            if vldata(3) > 90,
                vldata(3)=vldata(3)+1900;
            else
                vldata(3)=vldata(3)+2000;
            end
            time_greg(idx+1,:) = [vldata(3:7) vldata(8)+vldata(9)/100];
            time_jul=julian([vldata(3:7) vldata(8)+vldata(9)/100]);
            mexcdf('VARPUT',cdf,'TIM',idx,1,time_jul);
            mexcdf('VARPUT',cdf,'sv',idx,1,vldata(12));

            %correct heading for magnetic declination
            heading = vldata(14)./100 + c_hdg;
            if heading < 0, heading=360+heading; end
            mexcdf('VARPUT',cdf,'Hdg',idx,1,heading);
            mexcdf('VARPUT',cdf,'Ptch',idx,1,vldata(15)./100);
            mexcdf('VARPUT',cdf,'Roll',idx,1,vldata(16)./100);
            mexcdf('VARPUT',cdf,'Tx',idx,1,vldata(18)./100);
            % skipping Minimum Pre-Pint Wait Time between ping groups
            mexcdf('VARPUT',cdf,'HdgSTD',idx,1,vldata(22));
            mexcdf('VARPUT',cdf,'PtchSTD',idx,1,vldata(23)./10);
            mexcdf('VARPUT',cdf,'RollSTD',idx,1,vldata(24)./100);
            mexcdf('VARPUT',cdf,'xmitc',idx,1,vldata(25).*0.019);
            mexcdf('VARPUT',cdf,'xmitv',idx,1,vldata(26).*0.556);
            mexcdf('VARPUT',cdf,'dac',idx,1,vldata(27));
            mexcdf('VARPUT',cdf,'VDD3',idx,1,vldata(28).*0.097);
            mexcdf('VARPUT',cdf,'VDD1',idx,1,vldata(29).*0.032);
            mexcdf('VARPUT',cdf,'VDC',idx,1,vldata(30).*0.307);
            % error status word
            mexcdf('VARPUT',cdf,'EWD1',idx,1,vldata(33));
            mexcdf('VARPUT',cdf,'EWD2',idx,1,vldata(34));
            mexcdf('VARPUT',cdf,'EWD3',idx,1,vldata(35));
            mexcdf('VARPUT',cdf,'EWD4',idx,1,vldata(36));
            
            
            if depth_sensor, 
                % raw RDI binary stored pressure in deca-pascals
                % EPIC code used calls for pascals
                % deca-pascal * 10 = pascal
                % checked 7-feb-2008 (MM)
                press = vldata(38)+vldata(39).*65536;
                mexcdf('VARPUT',cdf,'Pressure',idx,1,press.*10); 
                press = vldata(40)+vldata(41).*65536;
                mexcdf('VARPUT',cdf,'PressVar',idx,1,press.*10); 
            end %%added 27-Feb-03
        end

        % get the main data (vel, corr, etc)
        junk=zeros(nbins,nbeams);
        fill=ones(1,nbeams).*(1e35);
        for type=3:6,
            pos=ftell(fid);
            % skip to the location of the next data type,
            if fseek(fid, ens_start+offsets(type)-pos, 'cof') < 0,
                break;
            end
            if type > length(longnames), keyboard; end
            if fread(fid,1,'int16') ~= rec_ids(type),
                disp([longnames{type},' data ID not found'])
            else
                % read 'em
                for j=1:nbins,
                    [dummy, n] = fread(fid,nbeams,read_types(type,:));
                    if n == nbeams,
                        junk(j,:) = dummy';
                    else
                        junk(j,:) = fill;
                    end
                end
                % last minute massage
                if type == VELOCITY,
                    % change the fill flag to be consistent
                    dummy = find(junk == -32768);
                    junk(dummy) = ones(size(dummy)).*(1e35);
                end
                % write 'em
                for j=1:nbeams,
                    %varname = [VARNAMES(type,:),int2str(j)];
                    varname = [VARNAMES{type},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,[idx 0],[1 nbins],junk(:,j)');
                end
            end
        end

        if BT_DATA,
            % get the bottom track data
            %junk=zeros(nbins,nbeams);
            %fill=ones(1,nbeams).*(1e35);
            type=7; %Bottom track is data type 7
            pos=ftell(fid);
            % skip to the location of the next data type,
            if fseek(fid, ens_start+offsets(type)-pos, 'cof') < 0,
                break;
            end
            % select what we want
            btflags=ones(1,59); % just take it all, weed it out below
            data = rdbtadcp(fid, 0, btflags);
            if ~isempty(data),
                % sort and store
                % skipping to field #11 (1-10 are GLOBAL metadata)
                % BT range convert from RDI cm to EPIC m
                for j=1:nbeams,
                    varname = [VARNAMES{7},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,(data(10+j)./100));
                end
                % BT velocity
                for j=1:nbeams,
                    if transform==3,	% this EPIC code is for EARTH coordinates only
                        varname = [VARNAMES{7+j}];
                    else
                        varname = ['BTV',int2str(j)];
                    end
                    mexcdf('VARPUT',cdf,varname,idx,1,data(14+j));
                end
                % BT correlation
                for j=1:nbeams,
                    varname = [VARNAMES{12},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,data(18+j));
                end
                % BT evaluation
                for j=1:nbeams,
                    varname = [VARNAMES{13},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,data(22+j));
                end
                % BT percent good
                for j=1:nbeams,
                    varname = [VARNAMES{14},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,data(26+j));
                end
                if BT_MODE==0,	% handle the reference layer data
                    % BT Ref. Layer Min
                    mexcdf('VARPUT',cdf,VARNAMES{15},idx,1,data(31));
                    % BT Ref. Layer Near
                    mexcdf('VARPUT',cdf,VARNAMES{16},idx,1,data(32));
                    % BT Ref. Layer Far
                    mexcdf('VARPUT',cdf,VARNAMES{17},idx,1,data(33));
                    % BT Ref. Layer Velocity
                    for j=1:nbeams,
                        varname = [VARNAMES{18},int2str(j)];
                        mexcdf('VARPUT',cdf,varname,idx,1,data(33+j));
                    end
                    % BT Ref. Layer correlation
                    for j=1:nbeams,
                        varname = [VARNAMES{19},int2str(j)];
                        mexcdf('VARPUT',cdf,varname,idx,1,data(37+j));
                    end
                    % BT Ref. Layer Intensity
                    for j=1:nbeams,
                        varname = [VARNAMES{20},int2str(j)];
                        mexcdf('VARPUT',cdf,varname,idx,1,data(41+j));
                    end
                    % BT Ref. Layer percent good
                    for j=1:nbeams,
                        varname = [VARNAMES{21},int2str(j)];
                        mexcdf('VARPUT',cdf,varname,idx,1,data(45+j));
                    end
                end % if BT_MODE==0
                % skipping field #50 which is GLOBAL metadata (BX/BT max depth)
                % BT RSSI
                for j=1:nbeams,
                    varname = [VARNAMES{22},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,data(50+j));
                end
                % skipping field #55 which is GLOBAL metadata (GAIN)
                % BT Range MSB
                for j=1:nbeams,
                    varname = [VARNAMES{23},int2str(j)];
                    mexcdf('VARPUT',cdf,varname,idx,1,data(55+j));
                end
            end % end if ~ienmpty(data)
        end % end if BT_DATA

        idx=idx+1;
    end
    readidx=readidx+1;
    % jump to next ensemble
    pos=ftell(fid);
    nskip=nbytes-(pos-ens_start)+2;	% add 2 for checksum
    if fseek(fid,nskip,'cof') < 0; 
        break; 
    end
    if readidx<1000 && ~rem(readidx,100),
        disp(sprintf('%d ensembles read, %d converted in %d min',readidx-1,idx,toc/60)),
    end
    if readidx>1000 && ~rem(readidx,1000), 
        disp(sprintf('%d ensembles read, %d converted in %d sec',readidx-1,idx,toc)), 
    end
    if readidx>maxens, break; end
end

fclose(fid);

mexcdf('CLOSE',cdf);

% open using the new netCDF toolbox method
cdf = netcdf(outfile,'write');
% add minimums and maximums
add_minmaxvalues(cdf);
close(cdf)

disp('Conversion complete')
disp(sprintf('%d seconds elapsed while processing',toc))
disp(sprintf('%d was the number of the last ensemble read',ensnum))
