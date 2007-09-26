function [theResult, settings] = runadcp(settings);
% RUNADCP - one of two main calling functions in the ADCP toolbox
%           converts raw binary TRDI ADCP data to netcdf, does editing and
%           trimming.
%           Runs the important ADCP functions in the following order:
%           rdi2cdf.m
%           fixEns.m
%           runmask.m
%           goodends.m
%           trimbins.m
% See the Acoustic Doppler Current Processing System Manual 
% U.S. Geological Survey Open File Report 00-458
%
% Useage, interactive:
%       runadcp with no arguments.  User will be prompted for everything.
%       Occasionally the program will display some results in figures and
%         stops to ask if it is ok to continue. If the program seems to be waiting
%         and you are unsure what to do, check the matlab command window for
%         a message!
% 
% Useage, automated:
%       [theResult, settings] = runadcp(settings);
%       best run from a script file where the structure settings is
%       initialized.  See below for settings values.  See also
%       scriptexample.m
%
% OUTPUTS:
%	  theResult = is the trimFile, the last file created
%     settings = the setting structure used as input.  A way to pass out
%        information, if needed one day
%
% INPUTS: settings struct
%     settings.numRawFile = 1; % number of raw binary ADCP files (*.000 or *.PD0), max = 2
%     settings.rawdata1 = '8221WHpart1.000'; % raw file #1
%     settings.rawdata2 = ''; % raw file #2, if any
%     settings.rawcdf = '8221wh.cdf'; % output file name for the raw data in netCDF format
%     settings.theFilledFile = '8221whF.cdf'; % the name of the fill file
%     settings.theMaskFile = '8221wh.msk'; % the name of the mask file
%     settings.theNewADCPFile = '8221whM.cdf'; % the name of the new file with the mask applied
%     settings.trimFile = '8221whT.cdf'; % the name of the file trimmed by time out of water and by bin
%     settings.rdi2cdf.run = 1; % force runadcp to run rdi2cdf (future implementation)
%     settings.rdi2cdf.Mooring_number = '8221'; % mooring number (USGS) or other identifier
%     settings.rdi2cdf.Deployment_date = '28-jun-2006';  % date the ADCP entered the water
%     settings.rdi2cdf.Recovery_date = '19-sep-2006'; % date the ADCP exited the water
%     settings.water_depth = 20.5; % in meters
%     settings.rdi2cdf.ADCP_serial_number = 2054; 
%     settings.rdi2cdf.xducer_offset = 1.235; % ADCP transducer offset from the sea bed
%     settings.rdi2cdf.pred_accuracy = 0.79; % from TRDI PLAN in cm/s
%     settings.rdi2cdf.slow_by = 3*60+9; % clock drift
%     settings.rdi2cdf.magnetic = 12.9; % declination in degrees, west is negative
%     settings.fixens.run = 1; % force runadcp to run fixens (future implementation)
%     settings.runmask.noninteractive = 1; % don't bring up starbare in runmask
%     % use this to override goodends' search for tripod tilt, etc.
%     % use it if you are really running in batch and don't want goodends to prompt you
%     settings.goodends.stop_date = settings.rdi2cdf.Recovery_date; % set to [] to disable
%     settings.trimbins.numRawFile = settings.numRawFile; % leave this alone
%     settings.trimbins.rawdata1 = settings.rawdata1; % leave this alone
%     settings.trimbins.rawdata2 = settings.rawdata2; % leave this alone
%     settings.trimbins.trimFile = settings.trimFile; % leave this alone
%     % method to remove bins above the surface (see trimbins documentation
%     settings.trimbins.method = 'Pressure Sensor'; %'RDI Surface Program' | 'User Input'
%     % percent of water column to make sure is preserved when trimming (1 = 100%)
%     settings.trimbins.percentwc = 1.12; % to capture full range of tide
%     settings.trimbins.ADCP_offset = settings.rdi2cdf.xducer_offset; % leave this alone
%     % path to the TRDI surface program, if you are on a PC
%     % we have permission to distribute TRDI's surface.exe with the toolbox
%     % so this should be your toolbox path, Demo directory
%     settings.trimbins.progPath = 'C:\mfiles\m_cmg\adcp_tbx\trunk\Demo'; % or ''
%     settings.adcp2ep.epDataFile = '8221wh.nc'; % final output file name
%     settings.adcp2ep.experiment = 'Huntington Beach, summer 2006'; % your metadata
%     settings.adcp2ep.project = 'Coastal and Marine Geology Program, Circulation and Sediment transport'; % your metadata
%     settings.adcp2ep.descript = 'HB06'; % your metadata, station or site number, for example
%     settings.adcp2ep.SciPi = 'Noble'; % your metadata, principal investigator
%     settings.adcp2ep.cmnt = 'HB06 Site MF Micropod Deployment 1';  % your metadata
%     settings.adcp2ep.water_mass = ' '; % an EPIC requirement
%     settings.adcp2ep.long = 117.977474; % always positive degrees
%     settings.adcp2ep.lonUnits = 'degrees_west';
%     settings.adcp2ep.latit = 33.629065; % always positive degrees
%     settings.adcp2ep.latUnits = 'degrees_north';
%     % the dialog file for your ADCP, there is one in the Demo directory.
%     % the toolbox use the instrument elevation and azimuth specific to each ADCP
%     settings.adcp2ep.dlgFile = '822wh.dlg'; % generated by the ADCP using the PS3 command
%     settings.adcp2ep.ADCPtype = 'WH'; % workhorse or BB for broadband
%
%     If file names are not given, they will be requested.
%
%


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

 
% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov
%
%Sub-programs
%	Rdi2cdf.m
%   fixEns.m
%   fappend.m
%	Starbeam directory
%	runmask.m (incorporates all masking functions)
%   pressurecalcs.m
%
% updated 3-may-2007 (MM) - add an auto override option for stop date in goodends
% updated 31-jan-2007 (MM) - add the option of using a structure to provide
% inputs for automated processing, rather than "batch mode"
% updated 1-jan-2006 (MM) - prevent multiple appending
% changed 22-dec-2006 (MM) - to structure input
% updated 19-dec-2006 (MM) - force user to verify orientation
% updated 20-Dec-2004 (SDR) - runs all revisions with batch
% updated 19-Nov-2004 (SDR) - now uses pressure sensor, if available, to
%       calculate mean sea level and tidal fluctuation
% updated 02-Apr-2003 - WIll not run Trimbins if data is orientated downward (ALR)
% updated 08-Aug-2001 - uses fappend.m to concatenate multiple binary files (ALR)
% updated 10-Jul-2001  -added ability to use one or two binary ADCP files (ALR)
% updated 09-Jul-2001 - fixed getinfo field bug for Matlab 6.0 R.12 (ALR)
% updated 09-Jul-2001 - fixed capitalization problems so UNIX won't crash (ALR)
% updated 19-Dec-2000 15:28:48 (ALR)  added fixEns.m function
% updated 15-Oct-1999 09:31:48   

if nargin < 1, help(mfilename), end

%% set up metadata and file names
if exist('settings','var')
   numRawFile = settings.numRawFile;
   rawdata1 = settings.rawdata1;
   %theFile1 = rawdata1;
   rawdata2 = settings.rawdata2;
   %theFile2 = rawdata2;
   rawcdf = settings.rawcdf;
   theFilledFile = settings.theFilledFile;
   theMaskFile = settings.theMaskFile;
   theNewADCPFile = settings.theNewADCPFile;
   trimFile = settings.trimFile;
end

if ~exist('numRawFile','var') || isempty(numRawFile),
    numRawFile = menu('How many binary files used?',{'1','2'}); 
end
if ~exist('rawdata1','var') || isempty(rawdata1), rawdata1 = '*'; end
if ~exist('rawdata2','var') || isempty(rawdata2), rawdata2 = '*'; end
if ~exist('theNewADCPFile','var') || isempty(theNewADCPFile), theNewADCPFile = '*'; end
if ~exist('trimFile','var') || isempty(trimFile), trimFile = '*'; end
if ~exist('theMaskFile','var'), theMaskFile = '*', end

% Get ADCP raw data filename.
switch numRawFile
    case 1
        if any(rawdata1 == '*')
            [theFile, thePath] = uigetfile({'*.000','*.000, ADCP ensembles direct from ADCP or wavesmon 2.x';...
                '*.PD0','*.PD0, ADCP ensembles from wavesmon 3.x'}, 'Select Binary ADCP File:');
            if ~any(theFile), return, end
            if thePath(end) ~= filesep, thePath(end+1) = filesep; end
            rawdata1 = [thePath theFile];
            rawdata = rawdata1; clear rawdata1 rawdata2
        end
        if exist('settings','var'),
            rawdata = rawdata1;
            clear rawdata1 rawdata2
        end
    case 2
        if any(rawdata1 == '*')
            [theFile1, thePath1] = uigetfile({'*.000','*.000, ADCP ensembles direct from ADCP or wavesmon 2.x';...
                '*.PD0','*.PD0, ADCP ensembles from wavesmon 3.x'}, 'Select Binary ADCP File:');
            if ~any(theFile1), return, end
            if thePath1(end) ~= filesep, thePath1(end+1) = filesep; end
            %rawdata1 = [thePath1 theFile1];
        end
        if any(rawdata2 == '*')
            [theFile2, thePath2] = uigetfile({'*.000','*.000, ADCP ensembles direct from ADCP or wavesmon 2.x';...
                '*.PD0','*.PD0, ADCP ensembles from wavesmon 3.x'}, 'Select Binary ADCP File:');
            if ~any(theFile2), return, end
            if thePath2(end) ~= filesep, thePath2(end+1) = filesep; end
            %rawdata2 = [thePath2 theFile2];
        end
        if exist('settings','var'),
            theFile1 = rawdata1;
            theFile2 = rawdata2;
            thePath1 = pwd;
        end
        if exist('settings','var'), thePath1 = pwd; end
        %If there are two binary files that make up the dataset, concatonate them now
        if exist(theFile2)
            theFile = [theFile1(1:5) 'all.000'];
            if exist(theFile,'file'), delete(theFile); end
            fappend(theFile,theFile1,theFile2);
            thePath = thePath1;
            if thePath(end) ~= filesep, thePath(end+1) = filesep; end
            rawdata = [thePath theFile];
            settings.rawdata = rawdata;
            clear rawdata1 rawdata2 theFile1 thePath1 theFile2 thePath2 ss w
        end
end

% Get ADCP netcdf filename if not given
if ~exist('rawcdf','var') || isempty(rawcdf)
   [PATH,NAME,EXT,VER] = fileparts(rawdata);
   [theFile, thePath] = uiputfile([NAME '.cdf'],...
      'Save Netcdf ADCP File As (or press cancel to use an existing file):');
   if ~any(theFile), 
      [theFile, thePath] = uigetfile([NAME '.cdf'], 'Use the Existing Netcdf ADCP File:');
   end
   if ~any(theFile), return, end
   if thePath(end) ~= filesep, thePath(end+1) = filesep; end
   rawcdf = [thePath theFile];
end

[rootPath,rootName,EXT,VER] = fileparts(rawcdf);

%% convert to raw netCDF
if ~exist('settings','var') || settings.rdi2cdf.run,
    if ~isempty(rawcdf) && isequal(exist(rawcdf),0)
        disp(['Converting RDI data file to netcdf'])
        disp(' ')
        if exist('settings','var') & isfield(settings,'rdi2cdf'),
            status = rdi2cdf(rawdata,rawcdf,[],[],settings.rdi2cdf); % user's provideing metadata
        else
            disp('You will be asked for some inputs from the mooring log')
            status = rdi2cdf(rawdata,rawcdf); % user will be prompted
        end
        if status < 0,
            disp('runadcp: There was a problem with the raw data')
            return
        end
        if ~exist('settings','var')
            disp('In the following figure quickly review the data');
            disp('Then click "Done" on the Starbeam menu, and hit enter');
            pause(5)
            starbeam(rawcdf);
            pause
        end
    elseif isequal(exist(rawcdf),2)
        disp(' ')
        disp('Rdi2cdf.m was skipped.')
        disp(['Use existing netcdf file ' rawcdf ]);
        disp(' ')
    else
        return
    end
else
    disp('rdi2cdf execution suppressed by settings')
end

%% Check for missing ensemble numbers 
if ~exist('settings','var') || settings.fixens.run,
    if ~exist('theFilledFile','var') || isempty(theFilledFile)
        %[PATH,NAME,EXT,VER] = fileparts(theFilledFile);
        [theFile, thePath] = uiputfile([rootName 'F.cdf'],...
            'Save Netcdf ADCP Fill File As:');
        if ~any(theFile), return, end
        if thePath(end) ~= filesep, thePath(end+1) = filesep; end
        theFilledFile = [thePath theFile];
    end
    disp(sprintf('[missEnsNo] = fixEns(''%s'',''%s'');',rawcdf,theFilledFile))
    [missEnsNo] = fixEns(rawcdf,theFilledFile);
else
    disp('fixens execustion suppressed by settings, no missing ensembles')
    missEnsNo = 0; % override
end

%% masking
if missEnsNo ~= 0
   rawcdf = theFilledFile;
   disp('')
   disp(['Using new filled file ' theFilledFile])
end

%find out if beam or earth
F = netcdf(rawcdf,'nowrite');   
coord = F.transform(:);

%Give mask file a name
switch coord
   
case 'BEAM'
	if any(theMaskFile == '*') 
  	 	mask='*.msk';
  		[theFile, thePath] = uiputfile(mask, 'Create Mask File As:');
		if ~any(theFile), return, end
		if thePath(end) ~= filesep, thePath(end+1) = filesep; end
		theMaskFile = [thePath theFile];
	end

	% Get ADCP filename.
	if any(theNewADCPFile == '*')
		[theFile, thePath] = uiputfile([rootName,'M.cdf'],...
            'Save masked ADCP File As:');
		if ~any(theFile), return, end
		if thePath(end) ~= filesep, thePath(end+1) = filesep; end
		theNewADCPFile = [thePath theFile];
	end

	%Mask the data file based on RDI criteria
	disp('')
	disp('Running mask functions to remove bad data points')
   disp('')
   
   if exist('settings','var') && isfield(settings,'runmask') && ...
           isfield(settings.runmask,'noninteractive') 
            noninteractive = settings.runmask.noninteractive;
   else
       noninteractive = 0;
   end
   [theNewADCPFile, theMaskFile] = runmask(rawcdf,theMaskFile,theNewADCPFile,...
       noninteractive);
   
case 'EARTH'
   disp('')
	disp('Data in Earth coordinates, Masking was not performed')
	disp('')
   theNewADCPFile = rawcdf; 
end

%% trimming the bins
%Find the first and last good ensemble and trim the data record
if ~isfield(settings, 'goodends'),
    settings.goodends.stop_date = [];
end
[minens, maxens, nens, trimFile] = goodends(theNewADCPFile,theMaskFile,trimFile,settings.goodends);   

if isempty(minens) || isempty(maxens), %  user cancelled
    theResult = [];
    return
end

%find out if up or down
F = netcdf(rawcdf,'nowrite');   
orientation = F.orientation(:);

switch orientation   
    case 'UP'
        % close(F)
        F = netcdf(rawcdf,'nowrite');
        pressuresensor = F.depth_sensor(:);   %upload sensor information
        close(F);
        switch pressuresensor           %check for pressure sensor
            case 'YES'  %if pressure sensor installed
                disp('using pressure sensor data to trim bins')
                [MSL, Dstd, Dout] = pressurecalcs(trimFile); %derives mean and standard
                %deviation from pressure sensor
                %[MSL, Dstd] = trimbins(1,rawdata,'',trimFile,MSL,Dstd,'','',Dout); % trim the bins
                settings.trimbins.MSL = MSL;
                settings.trimbins.Dstd = Dstd;
                settings.trimbins.Dout = Dout;
                [MSL, Dstd] = trimbins(settings.trimbins); % trim the bins
            case 'NO' %if no pressure sensor installed
                if ~exist('settings','var') || ~isfield(settings','trimbins'), % need info, go interactive 
                    [MSL, Dstd] = trimbins(1,rawdata,'',trimFile); % trim the bins
                else
                    [MSL, Dstd] = trimbins(settings.trimbins); % trim the bins
                end
        end %pressuresensor switch
    case 'DOWN'
        close(F);
        disp('Data is orientated downward. Trimbins.m was not run')
end

%Scan data for bins out of water based on depth+tidal variation

theResult = trimFile;
