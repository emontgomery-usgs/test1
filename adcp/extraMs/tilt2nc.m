function [ncout]=tilt2nc(calfile,ncout,ADCP_serial_number,Mooring_number);

%function ncout = tilt2nc(calfile,ncout,ADCP_serial_number,Mooring_number);
%tilt2nc is currently being used to put the tilt calibration 
%data that is obtained from the RD Instruments ouput "pc2"
%into a useable matlab format, and then save as a netcdf file
%
%	calfile = the file that contains the RDI recorded output
%		If this file is not provided you will be asked to select
%
%	ncout = the resulting netcdf file to be created, and again you 
%		be asked if not provided.
%	ADCP_serial_number = no explanation needed
%	Mooring_number = 3 or 4 digit USGS mooring number associated with the 
%							deployment


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

 
%This code requires:		the perl script "rdi2mat"
%								the m file "mfriend"
%								the complete netcdf toolbox
%created by Jessica M. Cote
%				April 1999

%Need to get the initial ADCP file that details the measurements 
if nargin < 1, calfile = ''; end
if nargin < 2, ncout = ''; end
if nargin < 3, ADCP_serial_number = ''; end
if nargin < 4, Mooring_number = ''; end

if isempty(calfile), calfile = '*'; end
if isempty(ncout), ncout = '*'; end

if any(calfile == '*')
	[theFile, thePath] = uigetfile('*.log','Select Tilt measurement log file');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	calfile = [thePath theFile];
end
[thePath,fname,ext] = fileparts(calfile);

%this will create a netcdf file and prompt the user for the name
if any(ncout == '*');
   [theFile, thePath] = uiputfile([fname '.nc'],'Save netcdf file as');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	ncout = [thePath theFile];
end

%Use this function to get rid of matlab-unfriendly text and symbols 
%cd d:\matlabr11\work\workingcode
eval(['!perl rdi2mat<' calfile ' >outfile']);

tempcal = [fname '.out'];
tempcal = mfriend('outfile',tempcal);


%Global attributes
if isempty(ADCP_serial_number) | isempty(Mooring_number)
   prompt={'Enter the ADCP serial number','Enter the Mooring number'};
	title='Input metadata not found in file'
   lineNo=1;
   DefAns={'0','0'};
   dlgresult=inputdlg(prompt,title,lineNo,DefAns);
   ADCP_serial_number=str2num(dlgresult{1});   
   Mooring_number=str2num(dlgresult{2});
 end  

%Now get the right data 
disp(['Sorting through and parsing data'])
fld=0;
rc=0;
H = zeros(50,1);
P = zeros(50,1);
R = zeros(50,1);

f = fopen(tempcal, 'r');

if f < 0, return; end

while (1)
   s = fgets(f);
   fld=fld+1;
   s=1;
  	if isequal(s, -1), break; end
     if isequal(s(1:3),'% H');
        
        for cnt=1:50;
           H(cnt)=fscanf(f,'%f %s',1);
           fscanf(f,'%c %f %s',1);
           P(cnt)= fscanf(f,'%f %s',1);
           fscanf(f,'%c %f %s',1);
           R(cnt)=fscanf(f,'%f %s',1);
           fscanf(f,'%c %f %s',1);
   		end %for
      
      rc=rc+1;
	   head(1:50,rc) = H;
   	pit(1:50,rc) = P;
	   rol(1:50,rc) = R;

		end %if H
 end %while (1)
 disp(['records for ' num2str(rc) ' angles were found'])
 fclose(f);
%******************************************************************
%create netcdf file
cdf = netcdf(ncout,'clobber')

%Define some dimensions
cdf('record')=0;
cdf('angle')=32; %0-15deg and 0--15deg

%define some global attributes
cdf.Inst_type='RD Instruments Workhorse ADCP';
cdf.ADCP_serial_number=nclong(ADCP_serial_number);
cdf.Mooring_number=nclong(Mooring_number);
cdf.Creation_date=date;

%Variables and Attributes
cdf{'head'}=ncfloat('record','angle');
cdf{'head'}.long_name='Compass Direction heading';
cdf{'head'}.units =ncchar('degrees N');

cdf{'pitch'}=ncfloat('record','angle');
cdf{'pitch'}.units=ncchar('degrees');

cdf{'roll'}=ncfloat('record','angle');
cdf{'roll'}.units=ncchar('degrees');

endef(cdf)

%put in the data
[n,m] = size(head);
cdf{'head'}(1:n,1:32)=head;
cdf{'pitch'}(1:n,1:32)=pit;
cdf{'roll'}(1:n,1:32)=rol;

ncclose
