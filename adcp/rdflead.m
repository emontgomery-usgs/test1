function data = rdflead(fid, verbose, select)
% rdflead.m reads the fixed leader data from an RDI ADCP binary data file
%
% function data = rdflead(fid, verbose, select);
%
%	fid = file handle returned by fopen.
%	Returns the contents of the fixed leader
%	as 31 elements of the vector 'data' or an
%	empty matrix if the fixed leader ID is not
%	identified (error condition)
%	If the variable select is provided as a vector
%	of zeros and ones, the function will return
%	only the elements of data which correspond to
%	a one in the vector select.  Select must be the
%	the same length as the number of fields in the
%	record, currently 32.
%	Set verbose=1 for a text output.


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
% Atlantic Marine Geology, Woods Hole, MA
% 1/7/95
% 10/11/97 change dec2bin calls to dec2base

NFIELDS = 32;
data=zeros(1,NFIELDS);
fld=1;  

if exist('verbose','var') ~= 1,
	verbose = 0;
end
if exist('select','var') ~= 1,
	select = [];
end

% make sure we're looking at the beginning of
% the fixed leader record by testing for it's ID
data(fld)=fread(fid,1,'ushort');
if(data(fld)~=0),
	disp('Fixed Leader ID not found');
	data=[];
	return;
end
fld=fld+1;
% version number of CPU firmware
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% revision number of CPU firmware
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('CPU Version %d.%d',data(fld-1),data(fld))); end;
fld=fld+1;
% configuration, uninterpreted
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Hardware Configuration for LSB %d',data(fld))); 
	b=dec2base(data(fld),2,8);
	freqs=[75 150 300 600 1200 2400];
	junk=bin2dec(b(6:8));
	disp(sprintf('	System Frequency = %d kHz',freqs(junk+1))); 
	if b(5) == '0', disp('	Concave Beam'); end		
	if b(5) == '1', disp('	Convex Beam'); end		
	junk=bin2dec(b(3:4));
	disp(sprintf('Sensor Configuration #%d',junk+1)); 
	if b(2) == '0', disp('	Transducer head not attached'); end		
	if b(2) == '1', disp('	Transducer head attached'); end		
	if b(1) == '0', disp('	Downward facing beam orientation'); end		
	if b(1) == '1', disp('	Upward facing beam orientation'); end		
end;
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Hardware Configuration MSB %d',data(fld))); 
	b=dec2base(data(fld),2,8);
	angles = [15 20 30 0];
	junk=bin2dec(b(7:8));
	disp(sprintf('	Beam angle = %d degrees',angles(junk+1))); 
	junk=bin2dec(b(1:4));
	if junk == 4, disp('	4-beam janus configuration'); end
	if junk == 5, disp('	5-beam janus configuration, 3 demodulators'); end
	if junk == 15, disp('	4-beam janus configuration, 2 demodulators'); end
end;
fld=fld+1;
% real (0) or simulated (1) data flag
data(fld)=fread(fid,1,'uchar');	fld=fld+1;
% undefined
data(fld)=fread(fid,1,'uchar');	fld=fld+1;
% number of beams
data(fld)=fread(fid,1,'uchar');	fld=fld+1;
% number of depth cells
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Number of depth cells %d',data(fld))); end;
fld=fld+1;
% pings per ensemble
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Pings per ensemble %d',data(fld))); end;
fld=fld+1;
% depth cell length in cm
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Depth cell size %d cm',data(fld))); end
fld=fld+1;
% blanking distance (WF)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Blank after xmit distance %d cm',data(fld))); end
fld=fld+1;
% Profiling mode (WM)
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Profiling mode %d',data(fld))); end
fld=fld+1;
% Minimum correlation threshold (WC)
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Correlation threshold %d',data(fld))); end
fld=fld+1;
% number of code repetitions
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% Minimum percent good to output data (WG)
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% Error velocity threshold (WE)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Error Velocity Threshold %d mm/s',data(fld))); end
fld=fld+1;
% time between ping groups (TP)
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Time between ping groups %d:%d.%d',...
	data(fld-2), data(fld-1), data(fld))); end
fld=fld+1;
% coordinate transformation (EX)
data(fld)=fread(fid,1,'uchar');
if verbose, 
	disp(sprintf('Coordinate Transformation = %d',data(fld))); 
	b=dec2base(data(fld),2,8);
	junk=bin2dec(b(4:5));
	if junk == 0, disp('	Data stored coordinates = Beam'); end
	if junk == 1, disp('	Data stored coordinates = Instrument'); end
	if junk == 2, disp('	Data stored coordinates = Ship'); end
	if junk == 3, disp('	Data stored coordinates = Earth'); end
	if b(6) == '1', disp('	Tilts used in transformation'); end
	if b(7) == '1', disp('	3-beam solution used, this ensemble'); end
end
fld=fld+1;
% Heading Alignment (EA)
data(fld)=fread(fid,1,'int16');
fld=fld+1;
% Heading Bias (EB)
data(fld)=fread(fid,1,'int16');
if verbose, disp(sprintf('Heading Bias: %d deg',data(fld)./100)); end
fld=fld+1;
% Sensor source (EZ)
data(fld)=fread(fid,1,'uchar');
if verbose,
	disp(sprintf('Sensor Source = %d',data(fld))); 
	b=dec2base(data(fld),2,8);
	if b(2) == '1', disp('	Sound speed computed from ED, ES, ET'); end
	if b(3) == '1', disp('	ED taken from depth sensor'); end	
	if b(4) == '1', disp('	EH taken from transducer heading sensor'); end	
	if b(5) == '1', disp('	EP taken from transducer pitch sensor'); end	
	if b(6) == '1', disp('	ER taken from transducer roll sensor'); end	
	if b(7) == '1', disp('	ES derived from conductivity sensor'); end	
	if b(8) == '1', disp('	ET taken from temperature sensor'); end	
end
fld=fld+1;
% Sensors available
data(fld)=fread(fid,1,'uchar');
if verbose,
	disp(sprintf('Sensor Availability = %d',data(fld))); 
	b=dec2base(data(fld),2,8);
	if b(3) == '1', disp('	depth sensor'); end	
	if b(4) == '1', disp('	heading sensor'); end	
	if b(5) == '1', disp('	pitch sensor'); end	
	if b(6) == '1', disp('	roll sensor'); end	
	if b(7) == '1', disp('	conductivity sensor'); end	
	if b(8) == '1', disp('	temperature sensor'); end	
end
fld=fld+1;
% Bin 1 distance
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Distance to center of bin 1: %d cm',data(fld))); end
fld=fld+1;
% xmit pulse length
data(fld)=fread(fid,1,'ushort');
fld=fld+1;
% starting depth cell
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% ending depth cell
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% false target reject threshold
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% spare
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% transmit lag distance
data(fld)=fread(fid,1,'ushort');

if length(select) == length(data),
	data(find(select==0))=[];
end
