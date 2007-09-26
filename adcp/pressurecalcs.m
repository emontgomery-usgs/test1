function [MSL, Dstd, Dout] = pressurecalcs(adcpFile)

%   function [MSL, Dstd] = pressurecalcs(adcpFile)


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

 
%   This function will determine the mean sea level and the tidal
%   fluctuation dervived from the raw pressure sensor data.  It will
%   write a csv file with *.dat extention containing the depth at each ensemble for additional
%   quality checks and reference.

%   INPUTS:
%      rawcdf = converted raw data into netcdf file
%      
%    OUTPUTS:
%      MSL = mean sea level in meters based on pressure sensor data
%      Dstd = standard of deviation in meters to give an approximate tidal range
%      Dout = the surface depth at each ensemble as distinguished by the 
%            pressure sensor


% Written by Stephen Ruane
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to sruane@usgs.gov

P = netcdf(adcpFile);
if isempty(P), return, end

%Create output file for depths
[thePath,theFile,ext] = fileparts(adcpFile);
   if length(theFile) < 7
      DepthFile = fullfile(thePath, [theFile,'.dat']);
   else
      DepthFile = fullfile(thePath, [theFile(1:7) '.dat']);
   end

[Dpath, Dname, dext]=fileparts(DepthFile);
Dfile=([Dname dext]);


%make some calculations

Press = P{'Pressure'}(:);   % Pressure at transducer head in pascals
mnPress = mean(Press);      % average of pressure
MSL = mnPress/9806.65;      % mean sea level in meters assuming 9806.65 Pascals per meter
Dstd = std(MSL);            % tidal range in meters
Dout = Press./9806.65;      % depth at each ensemble assuming 9806.65 Pascals per meter
csvwrite(Dfile,Dout);       %write data to file

close(P)
% Done

    