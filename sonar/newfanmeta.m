% script newazmetatsts.m
% metaSonarExample - an example script for processing a single ADV data file.
% This program sets up metadata and runs the sonar processing appropriate
% to the kind of sonar employwd.
%
% you should run this script from the directory in which the data
% files reside
%

%%% START USGS BOILERPLATE -------------
% These programs are intened for us in adjusting metadata terms in
% netCDF files from the USGS CMGP Oceanographic time-series data
% archive
%
% Program written Matlab 7.6.0.342 (R2008a)
% Program ran on Linux PC with RHEL4 and on Windows XP PC.
%
% "Although this program has been used by the USGS, no warranty,
% expressed or implied, is made by the USGS or the United States
% Government as to the accuracy and functioning of the program
% and related program material nor shall the fact of distribution
% constitute any such warranty, and no responsibility is assumed
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

% fname must contain a file of Global attributes
fname='glob_att_tests.txt';
userMeta=read_globalatts(fname);  % provides values to insert below

% Written by Marinna Martini for the U.S. Geological Survey
% Coastal & Marine Program Woods Hole Field Center, Woods Hole, MA
% http://woodshole.er.usgs.gov/ Please report bugs to mmartini@usgs.gov

% add more EPIC fields
userMeta.INST_TYPE='Imagenex Model 881 fan sonar';
userMeta.history='Sonar data downloaded from instrument';
userMeta.DATA_TYPE='TIME';
userMeta.DELTA_T='variable';
userMeta.metadata_author='Ellyn Montgomery, USGS';
% these are specific to the sonar
% this one is key- says which kind of sonar to process, and may affect which 
% additional fields are available choose from: 'fan' | 'pen' | 'azm'
userMeta.SonartoAnimate='fan';
% these are configuration items not found in the instrument file - most of the 
%  instrument set-up is obtained from header or switches 
userMeta.Height=0.31;     %  mab at deployment
userMeta.FirstSonarDay='09-Nov-2009';
userMeta.LastSonarDay='10-Nov-2009';    % make sure there's more than 1 day
userMeta.RootDataDir='C:\home\data\sonar_tst\nov09\';
userMeta.sweeps=2;  % there's nothing in the header that has this info
%
% the ones below come into play if processing is to take place
% the adcp related ones help determine how much to rotate the fan sonar image
procMeta.SonartoAnimate='fan';
procMeta.tidx=1;
% pencil tilt is used to flatten the profile of the pencil sweeps
procMeta.fanadcp_off=0.0;
% dxy is the grid size images are interpolated onto
% .01 maintains resolution, but takes a long time and makes large files
% .05 is faster and makes smaller files, so is useful for quick-looks to verify rotaion
procMeta.dxy=0.005;
%
% save the output information
diary(sprintf('run%s',datestr(now,30))) 
% now set up the outfile name root
outFile=['test' userMeta.SonartoAnimate '1109'];

% create the raw cdf- repeat once for each type
if 1
    mkrawcdf(userMeta, outFile);
end
%
% make processed images
if 0
    if strcmp(userMeta.SonartoAnimate,'fan')
        % default is to do all, so no additional arguments needed
        do_fan_rots(procMeta,[outFile '_raw.cdf'])
    else
        disp ('could not interpret command- try again')
    end
end
diary off
