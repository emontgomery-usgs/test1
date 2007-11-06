function [dataArchiveStruct] = archiveDirectory(theDirectory, theExperimentName, archiveName);
%
%   [dataArchiveStruct] = archiveDirectory(theDirectory, theExperimentName, archiveName);
%
%   Function to take a directory of .nc data files and create a structure
%   containing relevent information about those m-files.  THE PROGRAM SAVES
%   THE STRUCTURE IN ARCHIVENAME. The data
%   taken from each file are: fileName, startTime, endTime, theLat, theLon,
%   instDepth, waterDepth, instType, theVars, timeStep (minutes), and dataTypes.
%
%   Program can be run in gui format (manually select a directory), by
%   giving the m-file a directory in the command line, or via batch mode.


%   This program is provided with no promises, warrenties, or guaranties.
%   User support is not actively provided by its creator or USGS; however,
%   questions/bugs may be reported and will be addressed where possible.
%
% Written by Soupy Alexander
% for the U.S. Geological Survey
% Marine and Coastal Program
% Woods Hole Center, Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to palexander@usgs.gov
%
%   Additional information about the .nc format may be obtained at 
%   http://www.met.tamu.edu/personnel/students/barnaby/netcdf/guide.txn_toc.hmtl
%
%   Version 1.0  20-Mar-2003

%Set up the categories of variables (new variables can be added to a
%category without additional changes to the m-file; if a new category is
%set up, it must have a name added (see below) and it must be added to the
%cell array of variables (see below)
Pressure = {'P_1'; 'P_4020'; 'P_4023'; 'SDP_850'};
Temperature = {'T_20'; 'T_28'; 'temp'; 'temperature'};
AirTemperature = {'AT_21'};
SST = {'T_25'};
Salinity = {'S_40';'S_41'; 'salinity'};
Conductivity = {'C_50'; 'C_51'; 'conductivity'};
Attenuation = {'ATTN_55'; 'TRN_107'; 'tran_4010'};
Backscatter = {'NEP_56'};
Oxygen = {'O_60'; 'OST_62'};
SigmaTheta = {'ST_70'; 'STH_71'; 'sigma_theta'};
BaroPressure = {'BP_915'};
Current = {'w_1204'; 'u_1205'; 'v_1206'; 'CS_300'; 'CD_310'; 'east'; 'north'};
CurrentVar = {'UVAR_4050'; 'UVCOV_4051'; 'VVAR_4052'; 'UWCOV_4053'; 'VWCOV_4054'; 'WVAR_4055'};
SoundVel = {'SV_80'};
Heat = {'QH_137'; 'QB_138'};
Wind = {'WS_400'; 'WD_410'; 'WU_422'; 'WV_423'; 'TX_440'; 'TY_441'; 'Txy_448'};
Waves = {'wp_4060'; 'wh_4061'; 'wd_4062'};

%Set up the variable names (can modify them here); if new variable types
%are added above a new name needs to be inserted.
PressureName(1:length(Pressure)) = {'pressure'}; 
TemperatureName(1:length(Temperature)) = {'temperature'}; 
AirTemperatureName(1:length(AirTemperature)) = {'air temperature'}; 
SSTName(1:length(SST)) = {'sst'}; 
SalinityName(1:length(Salinity)) = {'salinity'}; 
ConductivityName(1:length(Conductivity)) = {'conductivity'}; 
AttenuationName(1:length(Attenuation)) = {'attenuation'}; 
BackscatterName(1:length(Backscatter)) = {'backscatter'}; 
OxygenName(1:length(Oxygen)) = {'oxygen'}; 
SigmaThetaName(1:length(SigmaTheta)) = {'sigma theta'}; 
BaroPressureName(1:length(BaroPressure)) = {'barometric pressure'}; 
CurrentName(1:length(Current)) = {'current'}; 
SoundVelName(1:length(SoundVel)) = {'sound velocity'}; 
HeatName(1:length(Heat)) = {'heat'}; 
WindName(1:length(Wind)) = {'wind'}; 
CurrentVarName(1:length(CurrentVar)) = {'current variance'}; 
WavesName(1:length(Waves)) = {'waves'}; 

%Create the variable cell array (add any new variable types)
[allVariables(:, 1)] = {Pressure{:} Temperature{:} AirTemperature{:} ...
        SST{:} Salinity{:} Conductivity{:} Attenuation{:} Backscatter{:} ...
        Oxygen{:} SigmaTheta{:} BaroPressure{:} Current{:} CurrentVar{:} ...
        SoundVel{:} Heat{:} Wind{:} Waves{:}};
[allVariables(:, 2)] = {PressureName{:} TemperatureName{:} AirTemperatureName{:} ...
        SSTName{:} SalinityName{:} ConductivityName{:} AttenuationName{:} ...
        BackscatterName{:} OxygenName{:} SigmaThetaName{:} BaroPressureName{:} ...
        CurrentName{:} CurrentVarName{:} SoundVelName{:} HeatName{:} ...
        WindName{:} WavesName{:}};

%Directory can either be given, chosen via gui, or run as a batch job
if ~exist('theDirectory', 'var')
    thePrompt = 'Choose a directory to archive';
    theDirectory = uigetdir(pwd, thePrompt);
    if theDirectory == 0
        error('User has selected cancel.  Terminating program.');
    end
end

if ~exist('theExperimentName', 'var') 
    theExperimentName = inputdlg('Select a name for this experiment.');
    if isempty(theExperimentName)
        error('User has selected cancel.  Terminating program.');
    end
end

if ~exist('archiveName', 'var') 
    [archiveName archivePath] = uiputfile('*.mat', 'Select save name for archive file.');
    if isequal(archiveName, 0) | isequal(archivePath, 0)
        error('User selected cancel.')
    end
    archiveName = fullfile(archivePath, archiveName);
end

%Check to see if the user put in the final slash
if ~strcmp(theDirectory(end), '\') | ~strcmp(theDirectory(end), '/')
    %Make it Unix compliant
    if ispc
        theDirectory = [theDirectory '\'];
    elseif isunix
        theDirectory = [theDirectory '/'];
    end
end

%Get a list of the files in the chosen directory; omit subdirectories.
theDirStruct = dir(theDirectory);
if isempty(theDirStruct)
    error('Chosen directory does not exist.  Check format of input.  Terminating program.');
end
checkIsDir = [theDirStruct.isdir];
[theDirList{1:length(theDirStruct)}] = deal(theDirStruct.name);
theFiles = theDirList(find(checkIsDir == 0));

%Create the empties for the data.
fileList = cell(0,0);
startTime = cell(0,0);
endTime = cell(0,0);
theLat = cell(0,0);
theLon = cell(0,0);
instDepth = cell(0,0);
waterDepth = cell(0,0);
instType = cell(0,0);
theVars = cell(0,0);
timeStep = cell(0,0);
dataTypes = cell(0,0);

%Run through the files
for indexFile = 1:length(theFiles)
    if rem(indexFile, 10) == 0
        disp(['On file number ' num2str(indexFile) ' of ' num2str(length(theFiles))]);
    end
    %Check if the file is a NetCDF file (only process these)
    theHit = theFiles{indexFile};
    if ~strncmp(fliplr(theHit), 'cn.', 3) & ~strncmp(fliplr(theHit), 'fdc.', 4)
        continue
    else
        fileList{length(fileList)+1} = theHit;
        ncID = netcdf([theDirectory theHit], 'nowrite');
        %Check to see if the netCDF file opened
        if isempty(ncID)
            warning(['The file ' [theDirectory theHit] ' could not be opened.  Skipping it.'])
            continue
        end
        %Take care of the times
        time = singleJD(ncID{'time'}(:), ncID{'time2'}(:));
        if ~isempty(time)
            startTime{length(startTime) + 1} = min(time);
            endTime{length(endTime) + 1} = max(time);
            timeStep{length(timeStep) + 1} = median(diff(time)) * 24 * 60; %Convert to minutes
        else
            startTime{length(startTime) + 1} = NaN;
            endTime{length(endTime) + 1} = NaN;
            timeStep{length(timeStep) + 1} = NaN;
        end
        %Take care of the location
        lat = ncID{'lat'}(:);
        if ~isempty(lat)
            theLat{length(theLat) + 1} = lat;
        else
            theLat{length(theLat) + 1} = NaN;
        end
        lon = ncID{'lon'}(:);
        if ~isempty(lon)
            theLon{length(theLon) + 1} = lon;
        else
            theLon{length(theLon) + 1} = NaN;
        end
        %Take care of the depths; using maximum depth for ADCP
        theFileDepth = ncID{'depth'}(:);
        if ~isempty(theFileDepth)
            instDepth{length(instDepth) + 1} = max(theFileDepth);
        else
            instDepth{length(instDepth) + 1} = NaN;
        end
        %Take care of the water depth
        theFileWaterDepth = ncID.WATER_DEPTH(:);
        if ~isempty(theFileWaterDepth)
            waterDepth{length(waterDepth) + 1} = max(theFileWaterDepth);
        else
            waterDepth{length(waterDepth) + 1} = NaN;
        end
        %Take care of instrument type; split based on colons/eliminate "/0"
        theFileInstType = ncID.INST_TYPE(:);
        if ~isempty(theFileInstType)
            theInstList = cell(0,0);
            %Get rid of junk
            theReps = findstr('::', theFileInstType);
            while ~isempty(theReps)
                theFileInstType(theReps) = [];
                theReps = findstr('::', theFileInstType);
            end
            while strcmp(theFileInstType(1), ':')
                theFileInstType(1) = [];
            end
            while strcmp(theFileInstType(end), ':')
                theFileInstType(end) = [];
            end
            theDivisions = findstr(':', theFileInstType);
            theDivisions = [0 theDivisions length(theFileInstType)+1];
            for indexInst = 1:length(theDivisions)-1
                theInst = theFileInstType(theDivisions(indexInst)+1:theDivisions(indexInst+1)-1);
                while findstr('\0', theInst)
                    startProb = findstr('\0', theInst);
                    theInst(startProb:startProb+1) = []; 
                end
                if isempty(theInst)
                    clear theInst
                    theInst = NaN;
                end
                theInstList{indexInst} = theInst;
            end
            instType{length(instType)+1} = theInstList;
        else
            instType{length(instType)+1} = {NaN};
        end
        %Do the file variables & pull out the variable type
        theFileVars = var(ncID);
        if ~isempty(theFileVars)
            theFileVarNames = cell(0,0);
            theFileVarTypes = cell(0,0);
            for index2 = 1:length(theFileVars);
                theName = name(theFileVars{index2});
                theFileVarNames{length(theFileVarNames)+1} = theName;
                foundVariable = strmatch(theName, allVariables(:,1),'exact');
                if ~isempty(foundVariable)
                    theFileVarTypes{length(theFileVarTypes)+1} = allVariables{foundVariable, 2};
                end    
            end
            if isempty(theFileVarTypes)
                theFileVarTypes{1} = 'other';
            end
            theVars{length(theVars)+1} = theFileVarNames;
            dataTypes{length(dataTypes)+1} = unique(theFileVarTypes);
        else
            dataTypes{length(dataTypes)+1} = defString;
        end
    end
    ncclose('all')
end

%Set up some other parameters
creationDate = datestr(now, 0);
targetDirectory = theDirectory;
numberFiles = length(fileList);


dataArchiveStruct = struct('fileList', fileList, 'startTime', startTime, 'endTime', endTime, ...
    'theLat', theLat, 'theLon', theLon, 'instDepth', instDepth, 'waterDepth', waterDepth, ...
    'instType', instType, 'theVars', theVars, 'timeStep', timeStep, 'dataTypes', dataTypes, ...
    'creationDate', creationDate, 'targetDirectory', targetDirectory, 'numberFiles', numberFiles, ...
    'theExperiment', theExperimentName);

%Save to the a dataArchive file in the target directory (netCDF doesn't
%support arrays, unfortunately)
save(archiveName, 'dataArchiveStruct')