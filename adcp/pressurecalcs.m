function [MSL, Dstd, Dout] = pressurecalcs(adcpFile)

%   function [MSL, Dstd, Dout] = pressurecalcs(adcpFile)
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

% Written by Stephen Ruane
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to sruane@usgs.gov

% Update 23-jan-2008 (MM) adjust by sensor height so that MSL really is
% mean sea level as measured by the pressure sensor
disp(sprintf('%s is currently running',mfilename))

P = netcdf(adcpFile);
if isempty(P), return, end
ADCP_offset=P{'D'}.transducer_offset_from_bottom(:);
if isempty(ADCP_offset) || (ADCP_offset <= 0),
    disp(sprintf('%s: bad or missing transducer_offset_from_bottom in %s',...
        mfilename, adcpFile))
    disp(sprintf('%s: ADCP offset applied to pressure data is %6.2f m',...
        mfilename,ADCP_offset))
end

%Create output file for depths
[thePath,theFile] = fileparts(adcpFile);
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
MSL = MSL+ADCP_offset;      % correct for ADCP height above bed
Dstd = std(MSL);            % tidal range in meters
Dout = Press./9806.65;      % depth at each ensemble assuming 9806.65 Pascals per meter
csvwrite(Dfile,Dout);       %write data to file

close(P)
% Done

    