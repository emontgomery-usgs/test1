function data = rdvlead(fid, verbose)
% rdvlead.m reads the variable leader data from a raw ADCP
%
% function data = rdvlead(fid, verbose, select);
%	Read the variable leader data from a raw ADCP
%	data file opened for binary reading
%	Returns the contents of the variable leader
%	as elements of the vector 'data' or an
%	empty matrix if the fixed leader ID is not
%	identified (error condition).
%	If the variable select is provided as a vector
%	of zeros and ones, the function will return
%	only the elements of data which correspond to
%	a one in the vector select.  Select must be the
%       same length as the number of fields in the
%	record, currently 32. (Changed to 39 27-Feb-03)
%	Set verbose=1 for a text output.


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

% Updated 25-sep-2007 (MM) remove the field select, it was driving me nuts 
% Updated 26-Jul-2005 (SDR) now reads 4 byte pressure sensor data
% Updated 11-Nov-2004 (SDR) to read pressure data correctly
% Updated 27-Feb-2003 (ALR) for output of pressure data and changed fields in record to 39
% Written by Marinna Martini
% for the U.S. Geological Survey
% Atlantic Marine Geology, Woods Hole, MA
% 1/7/95

NFIELDS = 50; % base on Workhorse Commands and Output Data March 2005
data=zeros(1,NFIELDS);

if exist('verbose','var') ~= 1,
	verbose = 0;
end

% make sure we're looking at the beginning of
% the variable leader record by testing for it's ID
data(1)=fread(fid,1,'int16'); % field 1
if(data(1)~=128),
	disp('Variable Leader ID not found');
	data=[];
	return;
end
% ensemble number field 2
data(2)=fread(fid,1,'ushort');
% Time of ensemble fields 3-9, bytes 5-11
data(3)=fread(fid,1,'uchar'); 
data(4)=fread(fid,1,'uchar');
data(5)=fread(fid,1,'uchar');
data(6)=fread(fid,1,'uchar');
data(7)=fread(fid,1,'uchar');
data(8)=fread(fid,1,'uchar');
data(9)=fread(fid,1,'uchar'); % hsec
if verbose, disp(sprintf('Time of ensemble %d/%d/%d %d:%d:%d.%d',...
	data(3), data(4), data(5), data(6), data(7),...
	data(8), data(9))); 
end;
% ensemble number rollover field 10
data(10)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Ensemble %d',data(2)+(65536.*(data(10))))); end;
% built in test results field 11, byte 13-14
data(11)=fread(fid,1,'ushort');
% speed of sound (EC)
data(12)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Speed of sound %d m/s',data(12))); end;
% depth of transducer (ED) in decimeters
data(13)=fread(fid,1,'ushort');
% Heading (EH)
data(14)=fread(fid,1,'uint16');
if verbose, disp(sprintf('Heading %4.2f deg.',data(14).*0.01)); end;
% Pitch (EP)
data(15)=fread(fid,1,'int16');
if verbose, disp(sprintf('Pitch %4.2f deg.',data(15).*0.01)); end;
% Roll (ER)
data(16)=fread(fid,1,'int16');
if verbose, disp(sprintf('Roll %4.2f deg.',data(16).*0.01)); end
% Salinity (ES), byte 25,26
data(17)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Salinity %d ppt',data(17))); end
% Temperature (ET) field 18
data(18)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Temperature %4.2f deg.',data(18).*0.01)); end
% Maximum ping time fields 19-21
data(19)=fread(fid,1,'uchar');
data(20)=fread(fid,1,'uchar');
data(21)=fread(fid,1,'uchar');
% Accuracy (STD) of heading, pitch and roll field 22-24, byte 32-34
% heading (1 deg/count), pitch and roll (0.1 deg/count)
data(22)=fread(fid,1,'uchar');
data(23)=fread(fid,1,'uchar');
data(24)=fread(fid,1,'uchar');
% ADC channels fields 25-32, bytes 35-42
data(25)=fread(fid,1,'uchar'); % xmit current
data(26)=fread(fid,1,'uchar'); % xmit voltage
data(27)=fread(fid,1,'uchar'); % ambient temp
data(28)=fread(fid,1,'uchar'); % pressure +
data(29)=fread(fid,1,'uchar'); % pressure -
data(30)=fread(fid,1,'uchar'); % attitude temp
data(31)=fread(fid,1,'uchar'); % attutude
% MM was missing 8th byte in ADC set, contamination sensor
                      % added by SDR
data(32)=fread(fid,1,'uchar'); % added by SDR 
% Error status word fields 33-36, bytes 43-46
data(33)=fread(fid,1,'uchar');  
%b=dec2bin(data(fld));
data(34)=fread(fid,1,'uchar'); 
%b=dec2bin(data(fld));
data(35)=fread(fid,1,'uchar');  
%b=dec2bin(data(fld));
data(36)=fread(fid,1,'uchar');  
%b=dec2bin(data(fld));
data(37)=fread(fid,1,'ushort');  %reserved field 37, bytes 47-48
%b=dec2bin(data(fld));
%pressure in decapascals, field 38, bytes 49-52  updated 11-Nov-04 SDR
data(38)=fread(fid,1,'uint16');  
data(39)=fread(fid,1,'uint16');  
if verbose, disp(sprintf('Pressure %d pascals',(data(39)*65536+data(38))*10)); end;
%pressure variance in DecaPascals  updated 11-Nov-04 SDR
% update 25-sep-07 MM
data(40)=fread(fid,1,'uint16');  
data(41)=fread(fid,1,'uint16');  
if verbose, disp(sprintf('Pressure Variance %d pascals',(data(41)*65536+data(40))*10)); end;
% spare
data(42)=fread(fid,1,'uchar'); 
% Y@K compliant Time of ensemble fields 43-50, bytes 58-65
data(43:50)=fread(fid,8,'uchar'); 
