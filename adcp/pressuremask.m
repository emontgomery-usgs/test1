function [theNewADCPFile, theMaskFile] = pressuremask (theDataFile,theMaskFile,theNewADCPFile, thePad, heightData)
% pressuremask: mask ADCP data that is above a detected surface boundary
% function [theNewADCPFile, theMaskFile] = pressuremask (theDataFile,theMaskFile,theNewADCPFile, thePad, heightData)
% mask the top bins according to pressure sensor measurements
% for cdf files with raw netCDF ADCP data (TIM time variable) only
% Where:
%   theDataFile = the netCDF data file
%   theMaskFile = the corresponding mask file *.msk, 
%           if it doesn't exist, it will be created
%           don't use the same .msk file that precedes the goodends process in runadcp,
%           the file length will not match the data file length and will crash this function
%   theNewADCPFile = a new copy of the data to which the mask is applied
%           theNewADCPFile will be returned as [] if this function fails
%   thePad = a factor, in meters, that will be added or subtracted to the 
%           pressure or height data to allow custom trimming
%   heightData = a range from the ADCP transducer, in meters, to use for
%           trimming.  If provided, this overrides everything else.
%   
% Apply this mask after the trimming procedure especially on ADCP data without
% pressure sensor data because trimbins adds the height variable based on either
% pressure or surface.exe output that is used by this function to mask the surface bins.
%
% TODO test on a file without pressure data


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

% Updated 11-feb-2008 (MM) to accommodate new name for height, now brange.
% Written by Marinna Martini, USGS Woods Hole Science Center
% 18-Jan-2006

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords which is set to "Revision"
rev_info = 'SVN $Revision: 1051 $';
disp(sprintf('%s %s running',mfilename,rev_info))

if ~exist('theDataFile','var'), theDataFile = ''; end
if ~exist('theMaskFile','var'), theMaskFile = ''; end
if ~exist('theNewADCPFile','var'), theNewADCPFile = ''; end
if ~exist('thePad','var'), thePad = 0; end
if length(thePad) > 1, 
    disp('pressuremask: thePad must be a scalar')
    return
end

if isempty(theDataFile) || ~exist(theDataFile,'file'),
   [theFile, thePath] = uigetfile('*.cdf', 'Select ADCP Data File');
   if ~any(theFile), return, end; % user pressed cancel
   theDataFile = fullfile(thePath, theFile);
end

cdf = netcdf(theDataFile);
if isempty(cdf), disp(['pressuremask: Unable to open ',theDataFile]); return; end
depths = cdf{'D'}(:);
binsize = cdf{'D'}.bin_size(1);
nbins = length(depths);
disp(sprintf('there are %d depth bins that vary from %f to %f m', nbins, depths(1), depths(end)))
% make sure we have the right reference point.
% if this is an uplooking bottom mounted ADCP, then there will be a note present
% NOTE_2 = "bin depths are relative to the seabed"
anames = ncnames(att(cdf{'D'}));
for iname = 1:length(anames),
    if findstr(char(anames{iname}),'NOTE'),
        eval(sprintf('buf = cdf{''D''}.%s(:);',char(anames{iname})));
        if ~findstr(buf,'relative to the seabed'),
            disp('Warning, depths are not relative to the seabed, pressure masking may be off')
            disp(buf)
        end
    end
end
% figure out which data we have that we want to use for trimming
if exist('heightData','var'), % user has an override
    if length(heightData) ~= length(cdf{'TIM'}),
        disp('pressuremask: supplied height data does not match length of data in file')
        close(cdf); return
    end
    pdata = heightData;
else % use data from in the file
    % first, make sure there is valid pressure data in the netCDF file
    % check the global variable to see if pressure sensor is present
    if strcmp(upper(cdf.depth_sensor(:)),'YES') && ~isempty(cdf{'Pressure'}),
        if ~strcmp(upper(cdf.orientation(:)),'UP'), % make sure we are looking up at the surface...
            disp(sprintf('Orientation is %s, above surface depths cannot be automatically masked', cdf.orientation(:)))
            close(cdf); theNewADCPFile = []; return
        else % pressure is OK populate based on pressure
            pdata = cdf{'Pressure'}(:)./10000; %convert pascals to db
            disp(sprintf('mean pressure is %f db', gmean(pdata)))
            disp(sprintf('minimum pressure is %f db', gmin(pdata)))
            disp(sprintf('maximum pressure is %f db', gmax(pdata)))
        end
    elseif ~isempty(cdf{'height'}) || ~isempty(cdf{'brange'}), % no pressure, try for height
        pdata = cdf{'height'}(:); %already in m
        if isempty(pdata), pdata = cdf{'brange'}(:); end
        % do some smart massage
        % first remove the zeros
        idx = find(pdata == 0);
        pdata(idx) = ones(size(idx)).*NaN;
        % fill these gaps
        [pdata,gaps_filled,gaps_unfilled]=fillgap(pdata,100);
        disp(sprintf('mean height is %f db', gmean(pdata)))
        disp(sprintf('minimum height is %f db', gmin(pdata)))
        disp(sprintf('maximum height is %f db', gmax(pdata)))
        disp(sprintf('gaps filled %d, unfilled %d',gaps_filled,gaps_unfilled))
    else
        disp('pressuremask, No pressure or height data available, aborting')
        close(cdf); theNewADCPFile = []; return
    end
end
close(cdf);

% set up the mask file
if isempty(theMaskFile),
    [thePath, theFile] = fileparts(theDataFile);
    theMaskFile = fullfile(thePath, [theFile,'.msk']);
end
if ~exist('theNewADCPFile','var') || isempty(theNewADCPFile),
    [thePath, theFile, theExt] = fileparts(theDataFile);
    theNewADCPFile = fullfile(thePath, [theFile,'M',theExt]);
end
if exist(theMaskFile,'file'),
    disp(['pressuremask: using existing mask file ',theMaskFile])
else
    mkadcpmask(theDataFile,theMaskFile);
    disp(['The Mask file ' theMaskFile ' was created'])
end

% mask according to depth
msk = netcdf(theMaskFile,'write');
% make sure the mask lengths match the data file
if length(msk{'TIM'}(:)) ~= length(pdata),
    disp('pressuremask: mask file length does not matchd ata file length, aborting')
    close(msk); theNewADCPFile = []; return
end
% determine a min range for each bin with the value of D and 1/2 the binsize
% for each depth bin, flag ensembles where pressure is smaller than the
% minimum range of the bin
vnames = {'vel','cor','AGC','PGd'};
flags = zeros(length(pdata),1); 
for ibin = 1:nbins,
    idx = find(pdata+thePad < (depths(ibin) - binsize/2)); % index out of water ensembles
    flags(idx) = ones(length(idx),1);
    disp(sprintf('%d above water ensembles found at %f m for bin %d', length(idx), depths(ibin), ibin))
    for ivar = 1:4,
        for ibeam = 1:4,
            thename = sprintf('%s%1d',vnames{ivar},ibeam);
            msk{thename}(:,ibin) = flags;
        end
    end
    flags = zeros(length(pdata),1); % resert flags
end
close(msk)
disp(['The mask file ', theMaskFile, 'is filled '])

% apply mask to the data, writing a new file
% Write the masked data file(still in beam coordinates)
postmask(theDataFile,theMaskFile,theNewADCPFile);

% update the mins and maxes
nc = netcdf(theNewADCPFile,'write');
add_minmaxvalues(nc)
close(nc)

%Add in history comment
thecomment = sprintf('data above the surface were masked by %s\n',mfilename);
history(theNewADCPFile,thecomment);

disp('Masking is complete based on the read mask file'); 
disp(['The new masked file is ', theNewADCPFile])
