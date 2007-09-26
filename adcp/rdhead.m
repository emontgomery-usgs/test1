function [nb, nt, off] = rdhead(fid, verbose);
% rdhead.m reads the header data from an RDI ADCP binary file
%
%function [nb, nt, off] = rdhead(fid, verbose);
%
%	fid = file handle returned by a previous fopen call
%	nb = number of bytes in the ensemble
%	nt = number of data types
%	off = offset to the data for each type
%	Set verbose = 1 for a text output.


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

 
% Written by Marinna Martini
% for the U.S. Geological Survey
% Atlantic Marine Geology, Woods Hole, MA
% 1/7/95
% 1/16/07 (MM) add a trap to give clear instructions when waves packets data is detected

data = zeros(1,2);
fld=1;
if exist('verbose') ~= 1,
	verbose = 0;
end
nb=[]; nt=[]; off=[];

% make sure we're looking at the beginning of
% the header record by testing for it's ID
% junk(1) is the header ID
% junk(2) is the data source ID
%   this should be 7f for ensemble only data
%   it will be 79 for data from an ADCP configured to record waves packets
junk=fread(fid,2,'uchar');
if((length(junk)~=2) | (ftell(fid)<0)),
	disp('End of file found in rdhead.');
	return;
end
if ((junk(1)~=127) | (junk(2)~=127)),
	disp('ADCP Ensemble Header ID not found');
    if junk(2) == 121,
        disp('Waves packets data found')
        disp('Data must be split using wavesmon to output raw binary ensembles for currents')
        disp('Read the documentation about applying declination in wavesmon and using this toolbox')
    end
	return;
end
% get the number of bytes this ensemble
nb = fread(fid,1,'int16');
if verbose, disp(sprintf('Number of bytes per ensemble %d',nb)); end;
% get the number of data types
fseek(fid,1,'cof');	% skip spare byte position
nt=fread(fid,1,'uchar');
if verbose, disp(sprintf('Number of data types %d',nt)); end;
% get the type offset
off=zeros(nt,1);
for j=1:nt, off(j)=fread(fid,1,'int16'); end

