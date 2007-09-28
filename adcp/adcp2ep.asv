
function epDataFile = adcp2ep(adcpFile, epDataFile, ADCPtype, dlgFile, settings)

%function epDataFile = adcp2ep(adcpFile, epDataFile, ADCPtype, dlgFile, settings)
% This function is used to translate RDI ADCP data into variables that are
% in terms of earth coordinates and create an epic compatible data file.
% If the data is in Beam coordinates it will be transformed by runbm2g.m into
% Earth coordinates.  This transformation can be run on workhorse and broad
% band data, but the ADCP type must be specified.
%
% Magnetic Declination
%		If a magnetic declination was provided to the insturment prior to
%	deployment or to rdi2cdf in post-processing it will be applied at this
%	time for both Earth and Beam coordinat data
%
%Inputs:
%	adcpFile = the ADcp data file in beam coordinates
%		(Note:if running routines in sequence it should be the trimFile.)
%	epDataFile = the new Epic compatable file that will be created
%	ADCPtype = WH or BB; will default to WH if not specified
%		WH = workhorse, BB = broad band
%		note: if BB, do not need a dlgFile
%	dlgFile = the dialog file that was created when the ADCP was "deployed"
%   settings = a structure with the metadata inputs
%
%	Note: If the names of the files are not given, they will be requested.
%
% Output:
%	epDataFile = same as input


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

 

% sub-functions:
%	runbm2g.m
%	ep_time.m
%	gregorian.m

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

% Updated 10-sep-2007 (MM) Remove FillValue from dimension variables time,
% time2, depth, lat, lon
% version 1.2
% Updated 12-feb-2007 (MM) improve how rotations are handled
% Updated 31-jan-07 (MM) remove batch calls
% Updated 29-jan-07 (MM) tread Pgd for INST and SHIP same as EARTH.
% Updated 26-jan-07 (MM) update mins and maxes
% Updated 25-jan-07 (MM) clarify height
% Updated 22-jan-2007 (MM) don't write pressure if the ADCP has no pressure sensor
% Updated 16-jan-07 (MM) add SciPi, Conventions, inst_depth & inst_height meta attributes
% Updated 24-dec-2006 (MM) allow inputs to be provided as a struct
% version 1.1
%   updated 12-sep=05 (SDR) changed the method in which metadata is
%               collected by the user to a more friendly manner
%   fixed 01-sep-05 (SDR) valid range attribute for velocity data so that
%                   it is now [-1000 1000] as it was formally [1000 1000]
%   updated 12-aug-2005 (SDR) removed fill_value definition in time and
%               time2 EPIC dimensions
%   fixed 30-Apr- 2003 depth calculation for down but no pressure sensor
%   updated 9-Apr-2003  depth calculations to use prssure sensor if available and able to calculate downward looking
%   added note to pressure variable
%   updated so runbm2g history comment will be added to epic file history attributes
%   updated latitude variable so same as longitude variable
%
% updated 19-March-2003 (ALR) added pressure variable
% updated 10-Jan-2003 (ALR) added ';' to stop data stream...
% updated 06-aug-2002 (ALR) Added OCSD to Experiment and LA Shelf ADCP to Description
% updated 01-Jul-2002 (ALR) time conversion won't crash on very short files (line 143)
% updated 29-Apr-2002 (ALR) fixed time stamp error; when moving time stamp to middle of ens, need to add instead of subtract
%       (line 132 corrected)

% version 1.0
% updated 03-Jul-2001 fixed spelling of Buoy (ALR)
% updated 28-Jun-2001 will now work with Matlab 6.0, r.12; problem was with getinfo.m for latitude and
%       longitude values line 428 to 433. (ALR)
% updated 28-Dec-2000 added linefeeds to history/comment attribute (ALR)
% updated 20-Oct-2000 so when computing data in EARTH coordinates the fill values
%		remain the same even after the data is corrected for magnetic declination. ALR
% updated 05-Oct-2000 added additional experiment names and locations.  A. Ramsey
% updated 03-Aug-2000 so creation date will include time.  Fran Hotchkiss
% updated 15-Mar-2000 08:49:03,
%		fixed Pgd and AGC corruption
% updated 02-Feb-2000 09:34:12,
%		fixed temperature weirdness and added rotation for earth data
% updated 16-Dec-1999 12:10:41, put in some clears to help memory
% updated 10-Dec-1999 10:52:22, modified to handel BB
% updated 29-Oct-1999 09:20:26
% updated 19-Oct-1999 13:43:47

%tell us what function is running
Mname=mfilename;
disp('')
disp([ Mname ' is currently running']);

if nargin < 1, help(mfilename), adcpFile=''; end
if nargin < 2, epDataFile=''; end
if nargin < 3, ADCPtype = ''; end
if nargin < 4, dlgFile=''; end

if isempty(adcpFile), adcpFile = '*'; end
if isempty(epDataFile), epDataFile = '*'; end
if isempty(ADCPtype), ADCPtype = 'WH'; end
if isempty(dlgFile), dlgFile = '*'; end

% Open ADCP beam file.
if any(adcpFile == '*')
    [theFile, thePath] = uigetfile(adcpFile, 'Select ADCP File:');
    if ~any(theFile), return, end
    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    adcpFile = [thePath theFile];
end

[path,name]=fileparts(adcpFile);
suggest=[name(1:end-1) '.nc'];
%create ADCP Geographic coordinates File
if any(epDataFile == '*')
    [theFile, thePath] = uiputfile(suggest, 'Save Data in geographic coordinates as:');
    if ~any(theFile), return, end
    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    epDataFile = [thePath theFile];
end
%
B = netcdf(adcpFile );
if isempty(B), return, end

%let's deal with the time
ppens=B.pings_per_ensemble(:);
tp=B.time_between_ping_groups(:);
%in order to ping as fast as possible tp may be set to 0,
%but in reality it is approximately 0.288 sec per ping.
if isequal(tp,0);
    tp = 0.288;
end

tens=ppens*tp;

allTIM=B{'TIM'}(:);
% calculate time step for output file, in seconds (FH 10 May 2000)
timsecs=B{'TIM'}(:)*24*3600;
delta=mean(diff(timsecs));
clear timsecs

gtD=gregorian(allTIM);
start_time = datestr(datenum(gtD(1,1),gtD(1,2),gtD(1,3),gtD(1,4),gtD(1,5),gtD(1,6)),0);
stop_time = datestr(datenum(gtD(end,1),gtD(end,2),gtD(end,3),gtD(end,4),gtD(end,5),gtD(end,6)),0);

%Tim is the beginning of the ensemble, make it the middle
tsec=gtD(:,4)*3600 + gtD(:,5)*60 + gtD(:,6);
tmid=tsec+tens/2;
disp(['TIM was corrected by ' num2str(tens/2) ' sec = half the ensemble time']);
disp(' ')
sec=rem(tmid,60);
hmt=(tmid-sec)/60;
minu=rem(hmt,60);
hr=(hmt-minu)/60;
Mid_Ens_time=[gtD(:,1) gtD(:,2) gtD(:,3) hr minu sec];

disp('Converting "TIM" to "time" and "time2"');
[m,n] = size(Mid_Ens_time);
for ii=1:m;
    alltime(ii,:)=ep_time(Mid_Ens_time(ii,:));
end

Time=alltime(:,1);
Time2=alltime(:,2);

%get some information

theFillValue = fillval(B{'vel1'});
bin = size(B('bin'),1);
ensemble = size(B('ensemble'),1);
xducer_off = B{'D'}.xducer_offset_from_bottom (:);
wdepth = B{'D'}.water_depth (:);
serial = B.ADCP_serial_number(:);
coord = B.transform(:);
orientation = B.orientation(:);
%defined these 2 varibales earlier since getting screwed up!
TTX = B{'Tx'};
tempC = TTX(:);

%Depth Calculation: (added 04-Apr-2003)
%   1.  Use pressure sensor if available
%   2.  Use values from Surface.exe calculated using Trimbins.m (only for upward looking)
%   3.  Use user input values calculated using Trimbins.m for upward looking or user input values asked for now for downward looking
switch orientation
    case 'UP'
        %Is there a pressure variable?
        % trim bins will always produce height unless there is user input
        % for surface tracking
        if ~isempty(B{'Pressure'}), % pressure data is present
            Press = B{'Pressure'}(:);   % pressure at transducer head in pascals
            mnPress = mean(Press);      % average of pressure
            depth_head = mnPress/9806.65;   % depth at transducer head in meters
            center_first_bin = B{'D'}.center_first_bin(:);
            bin_size = B{'D'}.bin_size(:);

            depth_head_corrected = depth_head+xducer_off;
            depth = depth_head_corrected - B{'D'}(:);
            dnote = 'Depth values were calculated using the ADCP Pressure Sensor, assuming 9806.65 Pascals per meter.';
            wdepth = depth_head_corrected;
        else
            Press = theFillValue*ones(1,ensemble);
            depth = wdepth - B{'D'}(:);     %wdepth was calculated from surface using trimbins or was a user input value given to trimbins
            dnote = 'Depth values were calculated using surface.exe output.';
        end

    case 'DOWN'
        %Is there a pressure variable?
        if ~isempty(B{'Pressure'})
            Press = B{'Pressure'}(:);       % pressure at transducer head in pascals
            mnPress = mean(Press);      % average of pressure
            depth_head = mnPress/9806.65;   % depth at transducer head in meters
            center_first_bin = B{'D'}.center_first_bin(:);
            bin_size = B{'D'}.bin_size(:);

            bin1 = depth_head+center_first_bin;
            binEnd = ((bin-1)*bin_size)+bin1;
            depth = (bin1:bin_size:binEnd)';
            wdepth = depth_head + xducer_off; %water depth is depth at head plus transducer offset.
            dnote = 'Depth values were calculated using the ADCP Pressure Sensor, assuming 9806.65 Pascals per meter.';
        else
            % TODO replace these calls to getinfo
            disp('User must input the water depth information')
            Depth_Information.mean_sea_level.value = {0};
            Depth_Information.mean_sea_level.units = {'meters'};
            Depth_Information = uigetinfo(Depth_Information');

            %check units
            infoD = getinfo(Depth_Information,'mean_sea_level');
            unitD = getinfo(infoD,'units');

            if ~isequal(unitD,'meters')
                disp('User error!! Depth Information must be in meters')
                pause(3)
                Depth_Information = uigetinfo(Depth_Information);
            end

            infoMSL = getinfo(Depth_Information,'mean_sea_level');
            MSL = getinfo(infoMSL,'value');
            disp(['User input value for depth: ' (num2str(MSL)) ' meters' ])
            center_first_bin = B{'D'}.center_first_bin(:);
            bin_size = B{'D'}.bin_size(:);
            depth_head = MSL - xducer_off;

            bin1 = depth_head+center_first_bin;
            binEnd = ((bin-1)*bin_size)+bin1;
            depth = (bin1:bin_size:binEnd)';
            dnote = 'Depth values were calculated using user input values';
            Press = theFillValue*ones(1,ensemble);
            wdepth = MSL; %water depth equals user input mean sea level
        end %end if pressure/else
end %end switch

% height of sea surface information
% we want height above ADCP from surface.exe in uplooking situation only.
% we want height from pressure in either situation.
height = [];
hnote = [];
if ~isempty(B{'Pressure'}), % height from pressure sensor
    % is there a height variable?  If so, use it
    if ~isempty(B{'height'})
        height = B{'height'}(:);
        hnote = B{'height'}.NOTE(:);
    else
        height = B{'Pressure'}(:)/9806.65;   % depth at transducer head in meters
    end
    if isempty(hnote),  hnote = 'height based on depth sensor information'; end
else
    switch B.orientation(:)
        case 'UP'
            % is there a height variable?  Probably from surface.exe, use it
            if ~isempty(B{'height'})
                height = B{'height'}(:);
                hnote = B{'height'}.NOTE(:);
                if isempty(hnote),  hnote = 'height source unknown'; end
            else % otherwise, generate a mean height if we can
                % surface.exe is run by trimbins, not here, warn the user
                disp('No height information available in cdf file, trimbins may not have been run');
                % if 8181whT-n,cdf is input, the line below fails...
                %  B loaded has {'D'} not {'depth'}
                %height = ones(1,ensemble).*(B{'depth'}.water_depth(1)- B{'depth'}.xducer_offset_from_bottom(1));
                height = ones(1,ensemble).*(B{'D'}.water_depth(1)- B{'D'}.xducer_offset_from_bottom(1));
                hnote = 'height calculated from the mean water depth - instrument offset from bottom';
            end
        otherwise 
            if B{'depth'}.water_depth(1)- B{'depth'}.xducer_offset_from_bottom(1) > 0,
                height = ones(1,ensemble).*(B{'depth'}.water_depth(1)- B{'depth'}.xducer_offset_from_bottom(1));
                hnote = 'height calculated from the mean water depth - instrument offset from bottom';
            else
                %height = theFillValue*ones(1,ensemble);
                height = []; % opt not to write height
                hnote = 'note enough information available to compute a height of sea surface';
            end
    end
end
disp(hnote)

disp(['The file has ' num2str(ensemble) ' ensembles and ' num2str(bin) ' bins']);

disp(' ')
disp('Averaging echo intensity')
% Average echo intensity.
i1 = B{'AGC1'};
i1 = autonan(i1,1);
i2 = B{'AGC2'};
i2 = autonan(i2,1);
i3 = B{'AGC3'};
i3 = autonan(i3,1);
i4 = B{'AGC4'};
i4 = autonan(i4,1);
iall(:,:,1) = i1(:,:);
iall(:,:,2) = i2(:,:);
iall(:,:,3) = i3(:,:);
iall(:,:,4) = i4(:,:);
iavg = mean(iall,3);

%free up some memory
clear i1 i2 i3 i4 iall

disp(' ')
disp('Averaging percent good')

if strcmp(coord, 'BEAM')
    % Average percent good.
    p1 = B{'PGd1'};
    p1 = autonan(p1,1);
    p2 = B{'PGd2'};
    p2 = autonan(p2,1);
    p3 = B{'PGd3'};
    p3 = autonan(p3,1);
    p4 = B{'PGd4'};
    p4 = autonan(p4,1);
    pall(:,:,1) = p1(:,:);
    pall(:,:,2) = p2(:,:);
    pall(:,:,3) = p3(:,:);
    pall(:,:,4) = p4(:,:);
    pavg = mean(pall,3);
else % PGD has a different meaning for SHIP, INST and EARTH coordinates
    p4 = B{'PGd4'};
    p4 = autonan(p4,1);
    pavg = p4(:,:);
end

%free up some memory
clear p1 p2 p3 p4 pall


%check for fill values
TF = isnan(iavg);
MTF = max(max(TF));
if MTF
    fill_flag = 1;
end

TF = isnan(pavg);
MTF = max(max(TF));
if MTF
    fill_flag = 1;
end

%get the velocity data and set the new velocity variable
%dependent on being in Beam or Earth coordinates
disp(sprintf('Data is in %s coordinates',B.transform(:)))
switch coord
    case 'BEAM'
        disp('Data in Beam coordinates is being transformed to Earth')
        cur = runbm2g(adcpFile, ADCPtype, dlgFile);
        close(B)
        B = netcdf(adcpFile ); %added 09-Apr-2003. Now runbm2g history comment will be added to epic file.
    otherwise
        vel = cell(4,1);
        for ii = 1:4;
            vel{ii} = B{['vel' int2str(ii)]};
        end
        u = vel{1}(:);
        v = vel{2}(:);
        % Change by MM 12-feb-2007 prevent double rotation of EARTH data
        % ignore heading bias settings, as these come from the EB command
        % changes by the ADCP or by wavesmon and have already been applied
        % to the heading and thus will be in the vectors already
        % if user supplied a user_applied_heading_correction
        % heading was rotated in rdi2cdf, but since the beam transformation
        % was performed by the ADCP, the vectors are not rotated.  Do it here.
        % this correction will usually be declination, but as this is written,
        % SHIP or INST coordinates can be adjusted by a heading alignment
        magnetic = B{'Hdg'}.user_applied_heading_correction(:);
        if isempty(magnetic), magnetic = 0; 
        else
            disp(sprintf('velocities are being rotated by %f', magnetic))
            % is the sign correct for West = negative correction sense?
            % this is correct - F. Lightsom 9-feb-2007
            theta = -1*magnetic;
            [ur,vr] = uv_rotate(u,v,theta);
            %need to reset theFillValue
            urmax = max(max(ur));  vrmax = max(max(vr));
            ur(ur == urmax) = theFillValue;
            vr(vr == vrmax) = theFillValue;
            %fill in rotated velocity values
            [vel{1},vel{2}] = deal(ur,vr);
        end

        cur = cell(size(vel));   % Output currents and error.
        p = zeros(4, bin);
        for ii=1:ensemble
            for k = 1:4
                p(k, :) = vel{k}(ii, :);
                cur{k}(ii, :) = p(k, :);
            end
            if ~rem(ii,100),
                disp(sprintf('%d ensembles copied',ii)),
            end
        end
end

%scale as cm/sec
q = zeros(ensemble, bin);
for k =1:4;
    q(:, :) = cur{k}(:, :);
    q(q == theFillValue) = nan;
    q = q./10;
    q(isnan(q)) = theFillValue;
    cur{k}(:,:) = q;
end

%Get the mins and maxes for later
minsc = zeros(4,1);
maxsc = minsc;
for k=1:4
    good_cur=(cur{k}(:,:) ~= theFillValue);
    scur=cur{k}(logical(good_cur));
    minsc(k) = gmin(gmin(scur));
    maxsc(k) = gmax(gmax(scur));
end
clear p q good_cur scur

% Check for fill values.

for k=1:4;
    TF = isnan(cur{k}(:,:));
    MTF =(gmax(gmax(TF)));
    if MTF
        fill_flag = 1;
    else
        fill_flag = 0;
    end
end


%**********************************************************************
% Create the new output file.
G = netcdf(epDataFile,'clobber');

%Global Attributes
%copy the globals from the Beam File
%figure out what needs to be deleted, changed, or added to the final files
%delete the following variables
disp('Modifying the global attributes');
A=att(B);
Anames=ncnames(A);
AN=length(Anames);

for nn=1:AN-1
    if isequal(Anames{AN-nn},'sensor_configuration');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'transducer_attached');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'simulated_data');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'beams_in_velocity_calculation');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'profiling_mode');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'code_repetitions');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'transmit_lag_distance');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'transform');
        A(AN-nn) = [];
        %added 12/15/04 (SDR)
    elseif isequal(Anames{AN-nn},'Sound_speed_computed_from_ED_ES_ET');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'ED_taken_from_depth_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'EH_taken_from_xducer_heading_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'EP_taken_from_xducer_pitch_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'ER_taken_from_xducer_roll_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'ES_derived_from_conductivity_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'ET_taken_from_temperature_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'depth_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'heading_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'pitch_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'roll_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'conductivity_sensor');
        A(AN-nn) = [];
    elseif isequal(Anames{AN-nn},'temperature_sensor');
        A(AN-nn) = [];
    end
end


mm=1;

while mm < AN-1
    notenum = ['NOTE_',int2str(mm)];
    Anames=ncnames(A);
    AN=length(Anames);
    for nn=1:AN-1
        if isequal(Anames{AN-nn},notenum);
            A(AN-nn) = [];
        end
    end
    mm=mm+1;
end

%put the ones that are left into new file (G)
G < A;

%change and add the following attributes and variables
G.CREATION_DATE = datestr(now,0);
G.Conventions = 'PMEL/EPIC';
G.inst_height = G{'depth'}.xducer_offset_from_bottom(1);
G.inst_height_note = 'height in meters above bottom: accurate for tripod mounted instruments';
G.inst_depth = G.WATER_DEPTH(1) - G{'depth'}.xducer_offset_from_bottom(1);
G.inst_depth_note = 'inst_depth = (water_depth - inst_height); nominal depth below surface';

%RENAME A FEW
moor = G.Mooring_number;
rename(moor,'MOORING');
pulse = G.transmit_pulse_length;
rename(pulse,'transmit_pulse_length_cm');

%Define some new ones for Epic compatability
G.transform = 'EARTH';
G.DATA_TYPE = 'ADCP';
G.DATA_SUBTYPE = 'MOORED';
G.DATA_ORIGIN = 'USGS WHFS Sed Trans Group';
G.COORD_SYSTEM = 'GEOGRAPHIC';
G.WATER_MASS = ncchar('?');
G.POS_CONST = nclong(0);  %1 if consistent
G.DEPTH_CONST = nclong(0);  %1 if consistent
G.WATER_DEPTH = wdepth;
G.DRIFTER = nclong(0);
% Project, experiment and Descritption should already be there

G.VAR_FILL = theFillValue;

% Project, experiment and Descritption should already be there, but if
% not have it possible here
if exist('settings','var')
    experiment = settings.experiment;
    project = settings.project;
    descript = settings.descript;
    long = settings.long;
    lonUnits = settings.lonUnits;
    latit = settings.latit;
    latUnits = settings.latUnits;
    cmnt = settings.cmnt;
    if isempty(cmnt), cmnt = ' '; end
    scipi = settings.SciPi;
    if isempty(scipi), scipi = ' '; end
else
    %added for easier data entry
    prompt  = {...
        'Experiment:                                    ',...
        'Description:                                   ',...
        'Project:                                       ',...
        'Comments:                                      ',...
        'Longitude(decimal degrees):                    ',...
        'Units:                                         ',...
        'Latitude(decimal degrees):                     ',...
        'Units:                                         ',...
        'Principal Investigator:                        '};

    def     = {'','','','none','','degree_east','','degree_north',''};
    title   = ['Data Collection Information: ',G.MOORING(:)];
    lineNo  = 1;
    dlgresult  = inputdlg(prompt,title,lineNo,def,'on');
    experiment = dlgresult{1};
    project = dlgresult{2};
    descript = dlgresult{3};
    cmnt = dlgresult{4};
    long = str2num(dlgresult{5});
    lonUnits = dlgresult{6};
    latit = str2num(dlgresult{7});
    latUnits = dlgresult{8};
    scipi = dlgresult{9};

    if isempty(lonUnits), lonUnits = 'not specified'; end
    if isempty(latUnits), latUnits = 'not specified'; end
    if isempty(long), long = theFillValue; end
    if isempty(latit), latit = theFillValue; end
end

G.EXPERIMENT =experiment;
G.PROJECT = project;
G.DESCRIPT = descript;
G.longitude = long;
G.latitude = latit;
G.DATA_CMNT = cmnt;
G.SciPi = scipi;

%Need to calculate or derive the following
G.FILL_FLAG=nclong(fill_flag);
G.COMPOSITE=nclong(0);
G.VAR_DESC='u:v:w:Werr:AGC:PGd:Tx:Hdg:Ptch:Roll';

%calculate dt** this section removed FH 10 May 2000
%tim=B{'TIM'};
%gt=gregorian(tim(:));
%dt=diff(gt);
%delta=(dt(1,4).*60)+(dt(1,5))+(dt(1,6)./60);

G.DELTA_T=ncchar(num2str(delta));
G.start_time = start_time;
G.stop_time = stop_time;

magnetic = B{'Hdg'}.heading_bias(:);
if isempty(magnetic)
    magnetic = B.heading_bias(:)/100;
end
G.magnetic_variation = magnetic;

%define the dimensions
G('time') = 0;
G('depth') = length(B{'D'});
G('lon') = 1;
G('lat') = 1;


%Variables and Attributes
disp('Defining variables and their attributes')
disp('...Defining "time"')

G{'time'} = nclong('time');
G{'time'}.FORTRAN_format = ncchar('F10.2');
G{'time'}.units = ncchar('True Julian Day');
G{'time'}.type = ncchar('UNEVEN');
G{'time'}.epic_code = nclong(624);
%G{'time'}.FillValue_ = theFillValue;


disp('...Defining "time2"')
G{'time2'} = nclong('time') ;
G{'time2'}.FORTRAN_format = ncchar('F10.2');
G{'time2'}.units = ncchar('msec since 0:00 GMT');
G{'time2'}.type = ncchar('UNEVEN');
G{'time2'}.epic_code = nclong(624);
%G{'time2'}.FillValue_ = theFillValue;


disp('...Defining "depth"')
G{'depth'} = ncfloat('depth');
G{'depth'}.FORTRAN_format = ncchar('F10.2');
G{'depth'}.units = ncchar('m');
G{'depth'}.type = ncchar('EVEN');
G{'depth'}.epic_code = nclong(3);
G{'depth'}.long_name = ncchar('DEPTH (m)');
G{'depth'}.blanking_distance = B{'D'}.blanking_distance(:);
G{'depth'}.bin_size = B{'D'}.bin_size(:);
G{'depth'}.xducer_offset_from_bottom = B{'D'}.xducer_offset_from_bottom(:);
G{'depth'}.center_first_bin = B{'D'}.center_first_bin(:);
%G{'depth'}.FillValue_ = theFillValue;
G{'depth'}.NOTE = ncchar(dnote);

disp('...Defining "lon"')
G{'lon'} = ncfloat('lon'); %% 1 element.
G{'lon'}.FORTRAN_format = ncchar('f10.4');
G{'lon'}.units = ncchar(lonUnits);
G{'lon'}.type = ncchar('EVEN');
G{'lon'}.epic_code = nclong(502);
G{'lon'}.name = ncchar('LON');
G{'lon'}.long_name = ncchar('LONGITUDE');
G{'lon'}.generic_name = ncchar('lon');
%G{'lon'}.FillValue_ = theFillValue;

disp('...Defining "lat"')
G{'lat'} = ncfloat('lat'); %% 1 element.
G{'lat'}.FORTRAN_format = ncchar('F10.2');
G{'lat'}.units = ncchar(latUnits);
G{'lat'}.type = ncchar('EVEN');
G{'lat'}.epic_code = nclong(500);
G{'lat'}.name = ncchar('LAT');
G{'lat'}.long_name = ncchar('LATITUDE');
G{'lat'}.generic_name = ncchar('lat');
%G{'lat'}.FillValue_ = theFillValue;

disp('...Defining "u_1205"')
G{'u_1205'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'u_1205'}.name = ncchar('u');
G{'u_1205'}.long_name = ncchar('Eastward Velocity');
G{'u_1205'}.generic_name = ncchar('u');
G{'u_1205'}.FORTRAN_format = ncchar(' ');
G{'u_1205'}.units = ncchar('cm/s');
G{'u_1205'}.epic_code = nclong(1205);
G{'u_1205'}.sensor_type = B.INST_TYPE(:);
G{'u_1205'}.sensor_depth = wdepth - xducer_off;
G{'u_1205'}.serial_number = nclong(serial);
G{'u_1205'}.minimum = ncfloat(minsc(1));
G{'u_1205'}.maximum = ncfloat(maxsc(1));
%Not sure this is the right valid range, but what Fran had
G{'u_1205'}.valid_range = ncfloat([-1000 1000]);
G{'u_1205'}.FillValue_ = theFillValue;


disp('...Defining "v_1206"')
G{'v_1206'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'v_1206'}.name = ncchar('v');
G{'v_1206'}.long_name = ncchar('Northward Velocity');
G{'v_1206'}.generic_name = ncchar('v');
G{'v_1206'}.FORTRAN_format = ncchar(' ');
G{'v_1206'}.units = ncchar('cm/s');
G{'v_1206'}.epic_code = nclong(1206);
G{'v_1206'}.sensor_type = B.INST_TYPE(:);
G{'v_1206'}.sensor_depth = wdepth - xducer_off;
G{'v_1206'}.serial_number = nclong(serial);
G{'v_1206'}.minimum = ncfloat(minsc(2));
G{'v_1206'}.maximum = ncfloat(maxsc(2));
G{'v_1206'}.valid_range = ncfloat([-1000 1000]);
G{'v_1206'}.FillValue_ = theFillValue;


disp('...Defining "w_1204"')
G{'w_1204'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'w_1204'}.name = ncchar('w');
G{'w_1204'}.long_name = ncchar('Vertical Velocity');
G{'w_1204'}.generic_name = ncchar('w');
G{'w_1204'}.FORTRAN_format = ncchar(' ');
G{'w_1204'}.units = ncchar('cm/s');
G{'w_1204'}.epic_code = nclong(1204);
G{'w_1204'}.sensor_type = B.INST_TYPE(:);
G{'w_1204'}.sensor_depth = wdepth - xducer_off;
G{'w_1204'}.serial_number = nclong(serial);
G{'w_1204'}.minimum = ncfloat(minsc(3));
G{'w_1204'}.maximum = ncfloat(maxsc(3));
G{'w_1204'}.valid_range = ncfloat([-1000 1000]);
G{'w_1204'}.FillValue_ = theFillValue;

disp('...Defining "Werr_1201"')
G{'Werr_1201'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'Werr_1201'}.name = ncchar('Werr');
G{'Werr_1201'}.long_name = ncchar('Error Velocity');
G{'Werr_1201'}.generic_name = ncchar('w');
G{'Werr_1201'}.FORTRAN_format = ncchar('F8.1');
G{'Werr_1201'}.units = ncchar('cm/s');
G{'Werr_1201'}.epic_code = nclong(1201);
G{'Werr_1201'}.sensor_type = B.INST_TYPE(:);
G{'Werr_1201'}.sensor_depth = wdepth - xducer_off;
G{'Werr_1201'}.serial_number = nclong(serial);
G{'Werr_1201'}.minimum = ncfloat(minsc(4));
G{'Werr_1201'}.maximum = ncfloat(maxsc(4));
G{'Werr_1201'}.valid_range = B.error_velocity_threshold(:);
G{'Werr_1201'}.FillValue_ = theFillValue;


disp('...Defining "AGC_1202"')
G{'AGC_1202'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'AGC_1202'}.name = ncchar('AGC');
G{'AGC_1202'}.long_name = ncchar('Average Echo Intensity (AGC)');
G{'AGC_1202'}.generic_name = ncchar('AGC');
G{'AGC_1202'}.FORTRAN_format = ncchar('F5.1');
G{'AGC_1202'}.units = ncchar('counts');
G{'AGC_1202'}.epic_code = nclong(1202);
G{'AGC_1202'}.sensor_type = B.INST_TYPE(:);
G{'AGC_1202'}.sensor_depth = wdepth - xducer_off;
G{'AGC_1202'}.serial_number = nclong(serial);
G{'AGC_1202'}.norm_factor = B{'AGC1'}.norm_factor(:);
G{'AGC_1202'}.NOTE = ncchar('normalization to db');
G{'AGC_1202'}.minimum = ncfloat(min(min(iavg)));
G{'AGC_1202'}.maximum = ncfloat(max(max(iavg)));
G{'AGC_1202'}.valid_range = B.false_target_reject_values(:);
G{'AGC_1202'}.FillValue_ = theFillValue;


disp('...Defining "PGd_1203"')
G{'PGd_1203'} = ncfloat('time', 'depth', 'lat', 'lon');
G{'PGd_1203'}.name = ncchar('PGd');
G{'PGd_1203'}.long_name = ncchar('Percent Good Pings');
G{'PGd_1203'}.generic_name = ncchar('PGd');
G{'PGd_1203'}.FORTRAN_format = ncchar(' ');
G{'PGd_1203'}.units = ncchar('counts');
G{'PGd_1203'}.epic_code = nclong(1203);
G{'PGd_1203'}.sensor_type = B.INST_TYPE(:);
G{'PGd_1203'}.sensor_depth = wdepth - xducer_off;
G{'PGd_1203'}.serial_number = nclong(serial);
G{'PGd_1203'}.minimum = ncfloat(min(min(pavg)));
G{'PGd_1203'}.maximum = ncfloat(max(max(pavg)));
G{'PGd_1203'}.valid_range = B.minmax_percent_good(:);
G{'PGd_1203'}.FillValue_ = theFillValue;

if ~isempty(height),
    disp('...Defining "hght_18"')
    G{'hght_18'} = ncfloat('time', 'lat', 'lon');
    G{'hght_18'}.name = ncchar('hght');
    G{'hght_18'}.long_name = ncchar('height of sea surface');
    G{'hght_18'}.generic_name = ncchar('height');
    G{'hght_18'}.FORTRAN_format = ncchar('f10.2');
    G{'hght_18'}.units = ncchar('m');
    G{'hght_18'}.epic_code = nclong(18);
    G{'hght_18'}.sensor_depth = wdepth - xducer_off;
    G{'hght_18'}.minimum = ncfloat(min(height));
    G{'hght_18'}.maximum = ncfloat(max(height));
    G{'hght_18'}.serial_number = nclong(serial);
    G{'hght_18'}.valid_range = ncfloat([0 1000]);
    G{'hght_18'}.FillValue_ = theFillValue;
    G{'hght_18'}.NOTE = ncchar(hnote);
end

disp('...Defining "Tx_1211"')
G{'Tx_1211'} = ncfloat('time', 'lat', 'lon');
G{'Tx_1211'}.name = ncchar('Tx');
G{'Tx_1211'}.long_name = ncchar('ADCP Transducer Temp.');
G{'Tx_1211'}.generic_name = ncchar('temp');
G{'Tx_1211'}.units = ncchar('degrees.C');
G{'Tx_1211'}.epic_code = nclong(1211);
G{'Tx_1211'}.sensor_type = B.INST_TYPE(:);
G{'Tx_1211'}.sensor_depth = wdepth - xducer_off;
G{'Tx_1211'}.serial_number = nclong(serial);
G{'Tx_1211'}.minimum = ncfloat(min(tempC));
G{'Tx_1211'}.maximum = ncfloat(max(tempC));
G{'Tx_1211'}.valid_range = B{'Tx'}.valid_range(:);
G{'Tx_1211'}.FillValue_ = theFillValue;

if ~isempty(B{'Pressure'}),
    disp('...Defining "P_4"')
    G{'P_4'} = ncfloat('time', 'lat', 'lon');
    G{'P_4'}.name = ncchar('P');
    G{'P_4'}.long_name = ncchar('PRESSURE (PASCALS)');
    G{'P_4'}.generic_name = ncchar('depth');
    G{'P_4'}.units = ncchar('Pa');
    G{'P_4'}.epic_code = nclong(4);
    G{'P_4'}.sensor_type = B.INST_TYPE(:);
    G{'P_4'}.sensor_depth = wdepth - xducer_off;
    G{'P_4'}.serial_number = nclong(serial);
    G{'P_4'}.minimum = ncfloat(min(Press));
    G{'P_4'}.maximum = ncfloat(max(Press));
    G{'P_4'}.valid_range = B{'Pressure'}.valid_range(:);
    G{'P_4'}.FillValue_ = theFillValue;
    G{'P_4'}.NOTE = ncchar('Pressure of the water at the transducer head relative to one atmosphere (sea level)');
else
    disp('No pressure data...skipping "P_4"')
end
if ~isempty(B{'Hdg'}),
    disp('...Defining "Hdg_1215"')
    G{'Hdg_1215'} = ncfloat('time', 'lat', 'lon');
    G{'Hdg_1215'}.name = ncchar('Hdg');
    G{'Hdg_1215'}.long_name = ncchar('INST Heading (degrees)');
    G{'Hdg_1215'}.generic_name = ncchar('heading');
    G{'Hdg_1215'}.units = ncchar('Deg');
    G{'Hdg_1215'}.epic_code = nclong(1215);
    G{'Hdg_1215'}.sensor_type = B.INST_TYPE(:);
    G{'Hdg_1215'}.sensor_depth = wdepth - xducer_off;
    G{'Hdg_1215'}.serial_number = nclong(serial);
    G{'Hdg_1215'}.minimum = ncfloat(min(B{'Hdg'}(:)));
    G{'Hdg_1215'}.maximum = ncfloat(max(B{'Hdg'}(:)));
    G{'Hdg_1215'}.valid_range = B{'Hdg'}.valid_range(:);
    G{'Hdg_1215'}.heading_bias = B{'Hdg'}.heading_bias(:);
    G{'Hdg_1215'}.FillValue_ = theFillValue;
    if ~isempty(B{'Hdg'}.NOTE_8(:))
           G{'Hdg_1215'}.NOTE_8 = B{'Hdg'}.NOTE_8(:);
    end
    if ~isempty(B{'Hdg'}.NOTE_9(:))
           G{'Hdg_1215'}.NOTE_9 = B{'Hdg'}.NOTE_9(:);
    end
else
    disp('No heading data...skipping "Hdg_1215"')
end
if ~isempty(B{'Ptch'}),
    disp('...Defining "Ptch_1216"')
    G{'Ptch_1216'} = ncfloat('time', 'lat', 'lon');
    G{'Ptch_1216'}.name = ncchar('Ptch');
    G{'Ptch_1216'}.long_name = ncchar('INST Pitch (degrees)');
    G{'Ptch_1216'}.generic_name = ncchar('Pitch');
    G{'Ptch_1216'}.units = ncchar('Deg');
    G{'Ptch_1216'}.epic_code = nclong(1216);
    G{'Ptch_1216'}.sensor_type = B.INST_TYPE(:);
    G{'Ptch_1216'}.sensor_depth = wdepth - xducer_off;
    G{'Ptch_1216'}.serial_number = nclong(serial);
    G{'Ptch_1216'}.minimum = ncfloat(min(B{'Ptch'}(:)));
    G{'Ptch_1216'}.maximum = ncfloat(max(B{'Ptch'}(:)));
    G{'Ptch_1216'}.valid_range = B{'Ptch'}.valid_range(:);
    G{'Ptch_1216'}.FillValue_ = theFillValue;
    G{'Ptch_1216'}.NOTE = ncchar('Ptch from ADCP atitude sensor');
else
    disp('No Pitch data...skipping "Ptch_1216"')
end
if ~isempty(B{'Roll'}),
    disp('...Defining "Roll_1217"')
    G{'Roll_1217'} = ncfloat('time', 'lat', 'lon');
    G{'Roll_1217'}.name = ncchar('Roll');
    G{'Roll_1217'}.long_name = ncchar('INST Roll (degrees)');
    G{'Roll_1217'}.generic_name = ncchar('roll');
    G{'Roll_1217'}.units = ncchar('Deg');
    G{'Roll_1217'}.epic_code = nclong(1217);
    G{'Roll_1217'}.sensor_type = B.INST_TYPE(:);
    G{'Roll_1217'}.sensor_depth = wdepth - xducer_off;
    G{'Roll_1217'}.serial_number = nclong(serial);
    G{'Roll_1217'}.minimum = ncfloat(min(B{'Roll'}(:)));
    G{'Roll_1217'}.maximum = ncfloat(max(B{'Roll'}(:)));
    G{'Roll_1217'}.valid_range = B{'Roll'}.valid_range(:);
    G{'Roll_1217'}.FillValue_ = theFillValue;
    G{'Roll_1217'}.NOTE = ncchar('Roll from ADCP atitude sensor');
else
    disp('No Roll data...skipping "Roll_1217"')
end

endef(G)


%Put in the Data
m=ensemble;
n=bin;
disp(['Copying data to ' epDataFile]);
disp('... time')
G{'time'}(1:m)= Time;
disp('... time2')
G{'time2'}(1:m) = Time2;
disp('... lat')
G{'lat'}(1) = G.latitude(1);
disp('... lon')
G{'lon'}(1) = G.longitude(1);
disp('... depth')
G{'depth'}(1:n) = depth;
disp('... u_1205')
G{'u_1205'}(1:m, 1:n, 1, 1) = cur{1}(:,:);
disp('... v_1206')
G{'v_1206'}(1:m, 1:n, 1, 1) = cur{2}(:,:);
disp('... w_1204')
G{'w_1204'}(1:m, 1:n, 1, 1) = cur{3}(:,:);
disp('... Werr_1201')
G{'Werr_1201'}(1:m, 1:n, 1, 1) = cur{4}(:,:);
disp('... AGC_1202')
G{'AGC_1202'}(1:m, 1:n, 1, 1) = iavg;
disp('... PGd_1203')
G{'PGd_1203'}(1:m, 1:n, 1, 1) = pavg;
if ~isempty(height),
    disp('...hght_18')
    G{'hght_18' }(1:m, 1, 1) = height;
end
disp('... Tx_1211')
G{'Tx_1211'}(1:m, 1, 1) = tempC;
if ~isempty(B{'Pressure'}),
    disp('... P_4')
    G{'P_4'}(1:m, 1, 1) = Press;
end
if ~isempty(B{'Hdg'}),
    disp('... Hdg_1215')
     G{'Hdg_1215'}(1:m, 1, 1) = B{'Hdg'}(:);
end
if ~isempty(B{'Ptch'}),
    disp('... Ptch_1216')
    G{'Ptch_1216'}(1:m, 1, 1) = B{'Ptch'}(:);
end
if ~isempty(B{'Roll'}),
    disp('... Roll_1217')
    G{'Roll_1217'}(1:m, 1, 1) = B{'Roll'}(:);
end


% add minimums and maximums
add_minmaxvalues(G);

close(B)
close(G)

thecomment = sprintf('%s\n','Written to an EPIC standard data file by adcp2ep.m (version 1.1)');
history(epDataFile,thecomment);
