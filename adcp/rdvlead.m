function data = rdvlead(fid, verbose, select);
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

 
% Updated 26-Jul-2005 (SDR) now reads 4 byte pressure sensor data
% Updated 11-Nov-2004 (SDR) to read pressure data correctly
% Updated 27-Feb-2003 (ALR) for output of pressure data and changed fields in record to 39
% Written by Marinna Martini
% for the U.S. Geological Survey
% Atlantic Marine Geology, Woods Hole, MA
% 1/7/95

NFIELDS = 39;
data=zeros(1,NFIELDS);
fld=1;  

if exist('verbose') ~= 1,
	verbose = 0;
end
if exist('select') ~= 1,
	select = [];
end

% make sure we're looking at the beginning of
% the variable leader record by testing for it's ID
data(fld)=fread(fid,1,'int16');
if(data(fld)~=128),
	disp('Variable Leader ID not found');
	data=[];
	return;
end
fld=fld+1;
% ensemble number
data(fld)=fread(fid,1,'ushort');
fld=fld+1;
% Time of ensemble
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Time of ensemble %d/%d/%d %d:%d:%d.%d',...
	data(fld-5), data(fld-4), data(fld-6), data(fld-3), data(fld-2),...
	data(fld-1), data(fld))); end;
fld=fld+1;
% ensemble number rollover
data(fld)=fread(fid,1,'uchar');
if verbose, disp(sprintf('Ensemble %d',data(fld-8)+(65536.*(data(fld))))); end;
fld=fld+1;
% built in test results
data(fld)=fread(fid,1,'ushort');
fld=fld+1;
% speed of sound (EC)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Speed of sound %d m/s',data(fld))); end;
fld=fld+1;
% depth of transducer (ED) in decimeters
data(fld)=fread(fid,1,'ushort');
fld=fld+1;
% Heading (EH)
data(fld)=fread(fid,1,'uint16');
if verbose, disp(sprintf('Heading %4.2f deg.',data(fld).*0.01)); end;
fld=fld+1;
% Pitch (EP)
data(fld)=fread(fid,1,'int16');
if verbose, disp(sprintf('Pitch %4.2f deg.',data(fld).*0.01)); end;
fld=fld+1;
% Roll (ER)
data(fld)=fread(fid,1,'int16');
if verbose, disp(sprintf('Roll %4.2f deg.',data(fld).*0.01)); end
fld=fld+1;
% Salinity (ES)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Salinity %d ppt',data(fld))); end
fld=fld+1;
% Temperature (ET)
data(fld)=fread(fid,1,'ushort');
if verbose, disp(sprintf('Temperature %4.2f deg.',data(fld).*0.01)); end
fld=fld+1;
% Maximum ping time
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% Accuracy (STD) of heading, pitch and roll
% heading (1 deg/count), pitch and roll (0.1 deg/count)
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
% ADC channels
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
fld=fld+1;
data(fld)=fread(fid,1,'uchar');
%fld=fld+1;                      % added by SDR
%data(fld)=fread(fid,1,'uchar'); % added by SDR 
%Pressure Data added 27-Feb-03
fld=fld+1;
data(fld)=fread(fid,1,'uchar');  %For error word status
%b=dec2bin(data(fld));
fld=fld+1;
data(fld)=fread(fid,1,'uchar');  %For error word status
%b=dec2bin(data(fld));
fld=fld+1;
data(fld)=fread(fid,1,'uchar');  %For error word status
%b=dec2bin(data(fld));
fld=fld+1;
data(fld)=fread(fid,1,'uchar');  %For error word status
%b=dec2bin(data(fld));
fld=fld+1;
data(fld)=fread(fid,1,'uchar');  %reserved
%b=dec2bin(data(fld));
fld=fld+1;
data(fld)=fread(fid,1,'uint16');  %pressure in decapascals  updated 11-Nov-04 SDR
if verbose, disp(sprintf('Pressure %d pascals',data(fld)*10)); end;
fld=fld+1;
data(fld)=fread(fid,1,'uint16');  %pressure variance in DecaPascals  updated 11-Nov-04 SDR
if verbose, disp(sprintf('Pressure Variance %d pascals',data(fld)*10)); end;

%part of original
if length(select) == length(data),
	data(find(select==0))=[];
end
