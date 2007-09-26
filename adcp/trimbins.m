function [MSL, Dstd] = trimbins(numRawFile,rawdata1,rawdata2,trimFile,MSL,Dstd,ADCP_offset,progPath,Dout,percentwc)

% function [MSL, Dstd] = trimbins(numRawFile,rawdata1,rawdata2,trimFile,MSL,
%       Dstd,ADCP_offset,progPath,Dout,percentwc)
% Modifies the data file so the bins all fall below mean sea level(MSL) plus
% the tidal range using a MSL provided by the pressure sensor, RDsurface.m,
% a Matlab function that runs the Dos version of the RDI surface program,
% or user input.
% If no imput values are given it will prompt the user for method of
% trimming the bins by using a pressure sensor, RDsurface.m, or user input.
% User can fudge the amount trimmed by specifying the percentage of water
% depth to trim to.  The default is 105%
%
%   NOTE:  If user suspects that the pressure sensor did not work properly
%   as to biofouling or other reasons, it is recommended that the user use
%   SURFACE.EXE or input MSL and Dst manually when using trimbins.
%
%   NOTE:  Because data within 6% of the surface is contaminated, the user
%   may wish to keep only 94% of the water column.  However, there is some
%   reason to beleive that useful information can be obtained from bins
%   above the surface.  This is for the user to decide.
%   Reference: Principles of Operation: A Practical Primer (for ADCPs) pg. 38
%
%INPUTS:
%   numRawFile = number of raw ADCP data files
%	rawdata1 =  RDI ADCP binary output file (*.000)
%	rawdata2 =  RDI ADCP binary output file (*.000)
%	trimFile =  use the file create by trimming the bad ensembles in goodends.m if
%               going through runADCP prcessing steps OR any ADCP file that is in netcdf
%   MSL = mean sea level.  Computed from surface.exe, if surface.exe is available
%   Dstd = mean sea level.  Computed from surface.exe, if surface.exe is available
%	ADCP_offset = is the an attribute of the depth variable,
%		called xducer_offset_from_bottom in the Netcdf files
%		If not given, the rdsurface requests a Netcdf file to find it.
%	progPath = the full path for the RDI surface program on your computer
%   Dout = depth information from, say, a pressure sensor
%   percentwc = amount to trim, as a percentage of water column%
%
%OUTPUTS:
%	MSL = mean sea level based on RDI surface output
%	Dstd = standard of deviation to give an approximate tidal variation
%
% Example calls
% Run in non-interacive mode, supplyins a structure of settings:
% [MSL, Dstd] = trimbins(settings.trimbins)
% where settings = 
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
%     % if progPath is not available, one may include
%     settings.trimbins.MSL mean sea level, m
%     settings.trimbins.Dstd tidal variation, m
%     % or
%     settings.Dout if pressure data is available.
% examples can be found in runadcp.m


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

 


%sub-functions:
%	Netcdf toolbox
%	RDsurface.m
%	DOS version of surface.exe


% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

% updated 2-feb-2007 (MM) replace getinfo with inputdlg
% updated 31-jan-2007 (MM) remove batch calls
% updated 30-jan-2007 (MM) make trimming to surface more flexible, improve docs
% updates 25-jan-2007 (MM) abort if ADCP is not uplooking
% updated 01-jan-2007 (MM) - move starbeam call to runadcp
% version 2.0
% 29-dec-2006 (MM) change to allow struct of arguements to be passed
% version 1.0
% updated 20-Dec-2004 (SDR) runs all revisions with batch
% updated 17-Dec-2004 (SDR) can now be run independently and prompt user
%   for method of depth calculation
% updated 29-Nov-2004 (SDR) added comment in history for depth sensor
%   input, if available
% updated 03-Apr-2003 (ALR) clarified note for Height variable
% updated 16-Aug-2001 If using surface.exe, uses 94% of MSL + 1/2 tidal range
%		to trim surface bins (ALR)
% updated 10-Jul-2001 added ability to use one OR two binary raw ADCP files (ALR)
% updated 28-Dec-2000 09:28:32 - added linefeeds to comment/history attribute (ALR)
% updated 12-Jan-2000 11:07:35
%	-runs with batch and has all revisions
% updated 22-Oct-1999 14:40:41
% updated 15-Oct-1999 16:49:45

%tell us what function is running
Mname=mfilename;
disp(' ')
disp([ Mname ' is currently running']);

if nargin==1 && isstruct(numRawFile),
    settings = numRawFile;
    if isfield(settings,'numRawFile'), numRawFile = settings.numRawFile;
    else numRawFile = ''; end
    if isfield(settings,'rawdata1'), rawdata1 = settings.rawdata1;
    else rawdata1 = ''; end
    if isfield(settings,'rawdata2'), rawdata2 = settings.rawdata2;
    else rawdata2 = ''; end
    if isfield(settings,'trimFile'), trimFile = settings.trimFile;
    else trimFile = ''; end
    if isfield(settings,'percentwc'), percentwc = settings.percentwc;
    else percentwc = 1.05; end
    if isfield(settings,'MSL'), MSL = settings.MSL;
    else MSL = ''; end
    if isfield(settings,'Dstd'), Dstd = settings.Dstd;
    else Dstd = ''; end
    if isfield(settings, 'ADCP_offset'), ADCP_offset = settings.ADCP_offset;
    else ADCP_offset = ''; end
    if isfield(settings, 'progPath'), progPath = settings.progPath;
    else progPath = ''; end
    if isfield(settings,'Dout'), Dout = settings.Dout;
    else Dout = ''; end
end

if ~exist('numRawFile','var'), numRawFile = ''; end
if ~exist('rawdata1','var'), rawdata1 = ''; end
if ~exist('rawdata2','var'), rawdata2 = ''; end
if ~exist('trimFile','var'), trimFile = ''; end
if ~exist('ADCP_offset','var'), ADCP_offset = ''; end
if ~exist('progPath','var'), progPath = ''; end
if ~exist('MSL','var'), MSL = ''; end
if ~exist('percentwc','var'), percentwc = []; end

if isempty(numRawFile)
    numRawFile = menu('How many binary files used?','1','2');
end
if isempty(rawdata1), rawdata1 = '*'; end
if isempty(rawdata2), rawdata2 = '*'; end
if isempty(trimFile), trimFile = '*'; end
%ADCP_offset will be taken care of in the RDsurface program if isempty.

%Get the files in case the inputs are empty
% Get ADCP raw data filename.
if any(rawdata1 == '*')
    [theFile1, thePath1] = uigetfile(rawdata1, 'Select Binary ADCP File:');
    if ~any(theFile1), return, end
    rawdata1 = fullfile(thePath1, theFile1);
end
if numRawFile == 2,
    if any(rawdata2 == '*')
        [theFile2, thePath2] = uigetfile(rawdata2, 'Select 2nd Binary ADCP File:');
        if ~any(theFile2), return, end
        rawdata2 = fullfile(thePath2, theFile2);
    end
end

% Get Ensemble trimmed ADCP data file.
if any(trimFile == '*')
    [theFile, thePath] = uigetfile(trimFile, 'Select Ensemble trimmed ADCP File:');
    if ~any(theFile), return, end
    trimFile = fullfile(thePath, theFile);
end

%open the netcdf file to trim and get some info
f=netcdf(trimFile,'write');
if isempty(f), return, end;

% we can't do anything in this function with downlooking data...
if ~strcmp(f.orientation(:),'UP'),
    disp('trimbins: ADCP is not uplooking, aborting.')
    close(f)
    return
end

ADCP_offset = f{'D'}.xducer_offset_from_bottom(:);
depth=f{'D'};
theVars=var(f);
bad_num = fillval(depth);
pressuresensor=f.depth_sensor(:);
pitch = f{'Ptch'}(:);
roll = f{'Roll'}(:);

B = f('bin');
theBinNum = B(:);
ensembles = f{'Rec'}(:);
EnsNum = length(ensembles);

if isempty(theBinNum)
    disp(' ## the number of bins not found.')
    close(f)
    return
end

%get the mean sea level and tidal range for the given ensemble numbers
if isempty(MSL),
    if exist('settings','var') && isfield(settings,'method'),
        buttonname = settings.method; 
    else
        buttonname = questdlg('What method to trim the bins?','trimbins','Pressure Sensor','RDI Surface Program','User Input','RDI Surface Program')
    end 
    switch buttonname
        case 'Pressure Sensor'
            [MSL,Dstd,Dsurf]=pressurecalcs(trimFile);
            %to append to history later
            thecomment=sprintf('%s\n','Bins were trimed by trimbins.m based on depth sensor input information.');
            hnote = 'height based on depth sensor information';
        case 'RDI Surface Program'
            %progPath = 'C:\mfiles\m_cmg\adcp_tbx\trunk\Demo';
            %[MSL,Dstd,Dsurf] = rdsurface(numRawFile,rawdata1,rawdata2,ADCP_offset,ensembles,progPath);
            settings.ensembles = ensembles;
            [MSL,Dstd,Dsurf] = rdsurface(settings);
            %to append history later
            thecomment=sprintf('%s\n','Bins were trimmed by trimBins.m using 94% of the RDI surface output.');
            hnote = 'height based on surface.exe output';
        case 'User Input'
            % get the deployment dates
            prompt  = {'Enter the mean sea level value, m:',...
                'Enter the half_the_tidal_range, m:'};
            def     = {'0','0'};
            title   = 'User must input the water depth information';
            lineNo  = 1;
            dlgresult  = inputdlg(prompt,title,lineNo,def);
            Mooring_number = dlgresult{1};
            Deployment_date = dlgresult{2};
            Recovery_date = dlgresult{3};
            MSL = str2num(dlgresult{1});
            Dstd = str2num(dlgresult{2});
            Dsurf=[ ];
            %to append history later
            thecomment=sprintf('%s\n','Bins were trimmed by trimBins.m based on user input depth information.');
    end %button switch
else
    %if MSL and Dstd are already provided, check to see if they came from
    %   the pressure sensor or user input
    switch pressuresensor
        case 'YES'
            disp('Depth sensor input water_depth and tidal variation')
            Dsurf=Dout;
            %to append to history later
            thecomment=sprintf('%s\n','Bins were trimed by trimbins.m based on depth sensor input information.');
            hnote = 'height based on depth sensor information';
        case 'NO'
            disp('User input water_depth and tidal variation')
            Dsurf=[ ];
            %to append history later
            thecomment=sprintf('%s\n','Bins were trimmed by trimBins.m based on user input depth information.');
    end %pressuresensor switch
end


%for files with _FillValue
if ~isempty(bad_num)
    D = autonan(depth,1);
    depth=D(:);

else
    bad_num=f.VAR_FILL

    if ischar(bad_num)==1;
        bad_num=str2num(bad_num);
    end

    depth=depth(:);
    idgood=find(depth < bad_num & depth > 0);
    depth=depth(idgood);
    clear idgood

end


%find the bins1 that fall below the given sea level including tidal fluctuation
if isempty(percentwc),
	prompt  = {'Trim percentage of water column:'};
    def     = {'105'};
	title   = sprintf('MSL = %f with a variation of %f m',MSL,Dstd);
	lineNo  = 1;
	dlgresult  = inputdlg(prompt,title,lineNo,def);
    percentwc = str2num(dlgresult{1})./100;
end

disp(' ')
disp('Finding the good bins');
% goodBins = find(depth <= MSL+Dstd); Only trims bins out of water
goodBins=find(depth <= (percentwc*(MSL+(Dstd))));
disp(sprintf('Trimming to %6.3f percent of the mean seal level + Dstd',percentwc*100))

if isempty(goodBins)
    disp('## No bins were found within the specified depth range');
    close(f)
    return
elseif isequal(goodBins,length(depth));
    disp('No bad bins were found, file is unmodified');
    f{'D'}.water_depth(:) =MSL;
    close(f)
    return

end

%Check to make sure that everything is on order
%The goodbins should run from 1(closets to the ADCP) to the depth.
goodBins=sort(goodBins);
%make sure indices are unique
Bd = find(diff(goodBins) == 0);
if any(Bd)
    goodBins(Bd) = [];
    disp('Warning: Empty bins were found')
end


% compute bin locations
offset=f{'D'}.xducer_offset_from_bottom(:);
bin1=f{'D'}.center_first_bin(:);
binsize=f{'D'}.bin_size(:);
bincnt=length(goodBins);
EndD = (((bincnt-1)*binsize)+bin1) + offset;


%resize the dimension bins if all ok
if depth(goodBins(end)) - EndD > binsize
    disp(' ')
    disp('**Depths are not incremental.')
    disp('**Bad bins were not trimmed.')
    close(f);
    return
else
    disp('Redefining the "Bin" dimension')
    disp('May take a few minutes...')
    B=resize(B,length(goodBins));
end



%Record some information
f{'D'}.water_depth(:) = MSL;

disp(['# in Dsurf ' num2str(length(Dsurf))])
disp(['# in ensemble ' num2str(EnsNum)])

% only generate height if there is meaningful height information
if ~isempty(Dsurf)
    f{'height'} = ncfloat('ensemble')
    f{'height'}.long_name = ncchar('height of sea surface from transducer head');
    f{'height'}.units = ncchar('m');
    f{'height'}.FillValue_ = 1.0e35;
    f{'height'}.NOTE = ncchar(hnote);
    endef(f)
    
    f{'height'}(1:EnsNum) = Dsurf;
end
disp(sprintf('Data is from bin 1 at %7.2f to last bin at %7.2f meters',f{'D'}(1),f{'D'}(end)))

% add minimums and maximums
add_minmaxvalues(f);

close(f)

%Done
disp(' ')
disp(['File ' trimFile ' has been modified'])
disp(['## ' num2str(theBinNum-bincnt) ' bins were removed from the top of the water column'])

history(trimFile,thecomment);
