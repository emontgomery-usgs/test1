function checkheading(ncFile, cdfFile, theta, matFile)

% matFile is a winADCP MAT file export of U,V,W,Mag, Dir heading, pitch, roll, Temp
%   set matFile = [] if no MATLAB export is available


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

 
% Written by Marinna Martini, USGS Woods Hole Science Center
% 29-jan-2006

if ~exist('ncFile','var') || ~exist(ncFile,'file'),
    [theFile, thePath] = uigetfile('*.nc','*.nc, ADCP netCDF data',...
        'Select ADCP File:');
    ncFile = fullfile(thePath, theFile);
    if isempty(ncFile), return, end
end

if ~exist('cdfFile','var') || ~exist(cdfFile,'file'),
    [theFile, thePath] = uigetfile('*.cdf','*.cdf', 'ADCP netCDF data',...
        'Select ADCP File:');
    cdfFile = fullfile(thePath, theFile);
    if isempty(cdfFile), return, end
end

if ~exist('matFile','var') && ~exist(matFile,'file'),
    [theFile, thePath] = uigetfile('*.mat','*.mat', 'ADCP netCDF data',...
        'Select ADCP File:');
    cdfFile = fullfile(thePath, theFile);
    if isempty(cdfFile), return, end
elseif ~isempty(matFile)
    % load up mat data
    load(matFile,'AnH100thDeg');
    load(matFile,'SerDir10thDeg'); 
end

[nens, nbins] = size(SerDir10thDeg);

if ~exist('theta'), theta = 0; end


nc = netcdf(ncFile);
if isempty(nc), return, end

cdf = netcdf(cdfFile);
if isempty(cdf), return, end

heading_bias = cdf{'Hdg'}.heading_bias(:);

u = nc{'u_1205'}(:,1);
v = nc{'v_1206'}(:,1);
h = cdf{'Hdg'}(:);

[dir1,spd1] = uv2polar(u,v);

[ur,vr] = uv_rotate(u,v,theta);

[dir2,spd2] = uv2polar(ur,vr);

disp(sprintf('heading bias in cdf = %f',heading_bias))
disp(sprintf('Theta = %f',theta));
disp(sprintf('Mean velocity dir before %5.2f', gmean(dir1)))
disp(sprintf('Mean velocity dir after %5.2f', gmean(dir2)))
disp(sprintf('Difference before-after %5.2f', gmean(dir1-dir2)))

[theta,maj,min,wr]=princax(u+i*v);
[thetar,majr,minr,wrr]=princax(ur+i*vr);

%     Output: theta = angle of maximum variance, math notation (east == 0, north=90)
%             maj   = major axis of principal ellipse
%             min   = minor axis of principal ellipse
%             wr    = rotated time series, where real(wr) is aligned with 
%                     the major axis.
disp(sprintf('Max variance angle before %5.2f', theta))
disp(sprintf('Max variance angle after %5.2f', thetar))
disp(sprintf('Difference before-after %5.2f', (theta-thetar)))

% cmgpca(u,v,0);
% pause
% cmgpca(ur,vr,0);

% track heading
disp('Headings and Directions')
disp(sprintf('heading bias in cdf = %f',heading_bias))
disp(sprintf('Mean heading in %s = %5.2f',matFile,gmean(AnH100thDeg./100)))
disp(sprintf('Mean heading in %s = %5.2f',cdfFile,gmean(h)))
for ibin = 1,
disp(sprintf('Mean Dir for bin %d in %s = %5.2f',ibin, matFile,gmean(SerDir10thDeg(:,ibin)./10)))
disp(sprintf('Mean Dir for bin %d in %s = %5.2f',ibin, ncFile,gmean(dir1)))
end



close(nc)
close(cdf)

% AnDepthmm
% AnH100thDeg
% AnOrienUP
% AnP100thDeg
% AnR100thDeg
% AnT100thDeg
% RDIBin1Mid
% RDIBinSize
% RDIEnsDate
% RDIEnsInterval
% RDIEnsTime
% RDIFileName
% RDIPingsPerEns
% RDISecPerPing
% RDISystem
% SerBins
% SerDay
% SerDir10thDeg
% SerEmmpersec
% SerEnsembles
% SerErmmpersec
% SerHour
% SerHund
% SerMagmmpersec
% SerMin
% SerMon
% SerNmmpersec
% SerSec
% SerVmmpersec
% SerYear
