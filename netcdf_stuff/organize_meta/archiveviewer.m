function varargout = archiveviewer(varargin)
% ARCHIVEVIEWER is a GUI interface to accesse NetCDF data archives
%
%   [varargout] = archiveviewer(varargin);
%
% GUI interface for a user to access archived file information (saved in
% .mat files) as output by ARCHIVEDIRECTORY.  Type ARCHIVEVIEWER at the
% command prompt to activiate the GUI.


%%% START USGS BOILERPLATE -------------% Program written in Matlab v6x
% Program works in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
% program ran on Redhat Enterprise Linux 4
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%%% END USGS BOILERPLATE --------------

 
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


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @archiveviewer_OpeningFcn, ...
                   'gui_OutputFcn',  @archiveviewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archiveviewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.

% Choose default command line output for archiveviewer
handles.output = hObject;
handles.fullArchive = [];
handles.runningArchive = [];

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = archiveviewer_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = handles.runningArchive;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archiveList_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function archiveList_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeArchive_Callback(hObject, eventdata, handles)

%Remove the selected archive from the list
theList = get(handles.archiveList, 'string');
theHits = get(handles.archiveList, 'value');
theList(theHits) = [];

if isempty(theList)
    theList = '';
end

%Reset the on screen values
set(handles.archiveList, 'string', theList)
set(handles.archiveList, 'value', 1)

%Update the location/time/etc. limits
updateVariables(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browseButton_Callback(hObject, eventdata, handles)

%Choose a file
[fileName, pathName] = uigetfile({'*.mat', 'MAT-files (*.mat)'}, 'Select an archive file');

%Bail out if the user selects cancel
if isequal(fileName, 0) | isequal(pathName, 0)
    return
end

%Add to the existing list of files
theList = get(handles.archiveList, 'string');
theList{length(theList)+1} = [pathName fileName];

%Remove duplicates
theList = unique(theList);
set(handles.archiveList, 'string', theList);

%Update the variables
updateVariables(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browseDir_Callback(hObject, eventdata, handles)

%Choose a directory
[pathName] = uigetdir(pwd, 'Select a directory of archive files (includes all .mat files therein)');

%Bail if the user selects cancel
if isequal(pathName, 0)
    return
end

%Check if the computer is unix or pc to add proper slash
if ispc
    pathName = [pathName '\'];
elseif isunix
    pathName = [pathName '/'];
end

%Get all of the .mat files in the directory
theFiles = what(pathName);
theMatFiles = theFiles.mat;

%Add the path to the file names
theMatFiles = cellstr([repmat(pathName, size(char(theMatFiles),1), 1) char(theMatFiles)]);

%Bail if no .mat files
if isempty(theMatFiles)
    warning('No mat files in selected directory!')
    return
else
    %Add to the existing files
    theList = get(handles.archiveList, 'string');
    if isempty(theList)
        theList = theMatFiles;
    else
        theList = ([(theList(:))' (theMatFiles(:))'])';
    end
    set(handles.archiveList, 'string', theList);
end

%Update the variables
updateVariables(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateVariables(hObject, eventdata, handles)

%Pull in the information from the archives
theFiles = get(handles.archiveList, 'String');

%If there are no files left, clear the viewer
if isempty(theFiles)
    clearViewer_Callback(hObject, eventdata, handles)
    return
end

%Enable the screen
set(handles.archiveList, 'enable', 'on')
set(handles.experimentCheck, 'enable', 'on')
set(handles.dataTypeCheck, 'enable', 'on')
set(handles.locationCheck, 'enable', 'on')
set(handles.timeCheck, 'enable', 'on')
set(handles.timeStepCheck, 'enable', 'on')
set(handles.updateToExperiment, 'enable', 'on')
set(handles.removeArchive, 'enable', 'on')
set(handles.goButton, 'enable', 'on')

%Some files may not be archive files
goodFiles = theFiles;
for index = 1:length(theFiles)
    hitFile = theFiles{index};
    %If there is no 'dataArchiveStruct', it is not an archive file
    try
        theFileArchive = load(hitFile, 'dataArchiveStruct');
    catch
        warning(['The file ' hitFile ' does not exist.']);
        goodFiles{index} = [];
        continue
    end
    theFileArchive = theFileArchive.dataArchiveStruct;
    if isempty(theFileArchive)
        warning(['The file ' theFiles{index} ' does not contain the "dataArchiveStruct" variable.']);
        goodFiles{index} = [];
        continue
    end
    if ~exist('fullArchive', 'var')
        fullArchive = theFileArchive;
    else
        %If the data archive program has been changed to add/remove stored
        %parameters and files exist which have not been updated, the
        %program will warn the user
        try
            fullArchive = [fullArchive theFileArchive];
        catch
            warning(['The file ' theFiles{index} ' has a different structure than other files.  Rerun the current archiving program on all directories and try again.']);
            goodFiles{index} = [];
            continue
        end
    end
end

%Bail if no archive files
if isempty(goodFiles)
    warning('No archive files in file list!')
    clearViewer_callback(hObject, eventdata, handles)
    return
end

set(handles.archiveList, 'String', goodFiles)
handles.fullArchive = fullArchive;
handles.runningArchive = fullArchive;
set(handles.updateToExperiment, 'enable', 'on')
guidata(hObject, handles)

%Update the variable list
%Experiment list
[theExperiments{(1:length(fullArchive))}] = deal(fullArchive.theExperiment);
[theExperiments, sort1, sort2] = unique(theExperiments);
[junk, theOrder] = sort(sort1);
theExperiments = theExperiments(theOrder);
set(handles.experimentList, 'String', theExperiments)
set(handles.experimentList, 'Value', 1)

%Location
[theLats{(1:length(fullArchive))}] = deal(fullArchive.theLat);
theLats = cell2mat(theLats);
[theLons{(1:length(fullArchive))}] = deal(fullArchive.theLon);
theLons = cell2mat(theLons);
set(handles.minLat, 'String', num2str(min(theLats), '%0.3f'))
set(handles.maxLat, 'String', num2str(max(theLats), '%0.3f'))
set(handles.minLon, 'String', num2str(min(theLons), '%0.3f'))
set(handles.maxLon, 'String', num2str(max(theLons), '%0.3f'))

%Data Types
[theDataTypes{(1:length(fullArchive))}] = deal(fullArchive.dataTypes);
dataTypeList = cell(0,0);
for index = 1:length(theDataTypes)
    dataTypeHit = theDataTypes{index};
    dataTypeList = [dataTypeList dataTypeHit(:)'];
end
allDataTypes = unique(dataTypeList);
set(handles.dataTypeList, 'String', allDataTypes)
set(handles.dataTypeList, 'Value', 1)

%Times
[theStartTimes{(1:length(fullArchive))}] = deal(fullArchive.startTime);
[theEndTimes{(1:length(fullArchive))}] = deal(fullArchive.endTime);
theStartTimes = cell2mat(theStartTimes);
theEndTimes = cell2mat(theEndTimes);
set(handles.minTime, 'String', datestr(julian2datenum(min(theStartTimes)),1))
set(handles.maxTime, 'String', datestr(julian2datenum(max(theEndTimes)),1))

%Time Step
[theTimeSteps{(1:length(fullArchive))}] = deal(fullArchive.timeStep);
theTimeSteps = cell2mat(theTimeSteps);
set(handles.minTimeStep, 'String', min(theTimeSteps))
set(handles.maxTimeStep, 'String', max(theTimeSteps))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function experimentCheck_Callback(hObject, eventdata, handles)

%Only see the experiment list if the box is checked
isChecked = get(hObject,'Value');

if isChecked
    set(handles.experimentList, 'Enable', 'on')
else
    set(handles.experimentList, 'Enable', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function experimentList_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function experimentList_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateToExperiment_Callback(hObject, eventdata, handles)

%See what experiments are checked
listedExperiments = get(handles.experimentList, 'string');
selectExperiments = get(handles.experimentList, 'Value');
[hitExperiments{1:length(selectExperiments)}] = deal(listedExperiments{selectExperiments});

fullArchive = handles.fullArchive;

%If the experiment box is not checked, the button will update to all
%experiments
if get(handles.experimentCheck, 'value')
    [runningArchive] = findfiles(fullArchive, 'experiment', hitExperiments);
else
    runningArchive = fullArchive;
end

%Location
[theLats{(1:length(runningArchive))}] = deal(runningArchive.theLat);
theLats = cell2mat(theLats);
[theLons{(1:length(runningArchive))}] = deal(runningArchive.theLon);
theLons = cell2mat(theLons);
set(handles.minLat, 'String', num2str(min(theLats), '%0.3f'))
set(handles.maxLat, 'String', num2str(max(theLats), '%0.3f'))
set(handles.minLon, 'String', num2str(min(theLons), '%0.3f'))
set(handles.maxLon, 'String', num2str(max(theLons), '%0.3f'))

%Data Types
[theDataTypes{(1:length(runningArchive))}] = deal(runningArchive.dataTypes);
dataTypeList = cell(0,0);
for index = 1:length(theDataTypes)
    dataTypeHit = theDataTypes{index};
    dataTypeList = [dataTypeList dataTypeHit(:)'];
end
allDataTypes = unique(dataTypeList);
set(handles.dataTypeList, 'String', allDataTypes)
set(handles.dataTypeList, 'Value', 1)

%Times
[theStartTimes{(1:length(runningArchive))}] = deal(runningArchive.startTime);
[theEndTimes{(1:length(runningArchive))}] = deal(runningArchive.endTime);
theStartTimes = cell2mat(theStartTimes);
theEndTimes = cell2mat(theEndTimes);
set(handles.minTime, 'String', datestr(julian2datenum(min(theStartTimes)),1))
set(handles.maxTime, 'String', datestr(julian2datenum(max(theEndTimes)),1))

%Time Step
[theTimeSteps{(1:length(runningArchive))}] = deal(runningArchive.timeStep);
theTimeSteps = cell2mat(theTimeSteps);
set(handles.minTimeStep, 'String', min(theTimeSteps))
set(handles.maxTimeStep, 'String', max(theTimeSteps))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locationCheck_Callback(hObject, eventdata, handles)

%If the location box is checked, turn on all associated location choices
isChecked = get(hObject,'Value');

if isChecked
    set(handles.minLat, 'Enable', 'on')
    set(handles.maxLat, 'Enable', 'on')
    set(handles.minLon, 'Enable', 'on')
    set(handles.maxLon, 'Enable', 'on')
    set(handles.latText, 'Enable', 'on')
    set(handles.lonText, 'Enable', 'on')
else
    set(handles.minLat, 'Enable', 'off')
    set(handles.maxLat, 'Enable', 'off')
    set(handles.minLon, 'Enable', 'off')
    set(handles.maxLon, 'Enable', 'off')     
    set(handles.latText, 'Enable', 'off')
    set(handles.lonText, 'Enable', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minLat_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minLat_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxLat_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxLat_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minLon_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minLon_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxLon_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxLon_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataTypeCheck_Callback(hObject, eventdata, handles)

%Turn on all data type options if the box is checked
isChecked = get(hObject,'Value');

if isChecked
    set(handles.dataTypeList, 'Enable', 'on')
else
    set(handles.dataTypeList, 'Enable', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataTypeList_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataTypeList_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeCheck_Callback(hObject, eventdata, handles)

%Turn on all time options if the box is checked
isChecked = get(hObject,'Value');

if isChecked
    set(handles.minTime, 'Enable', 'on')
    set(handles.maxTime, 'Enable', 'on')
    set(handles.timeTo, 'Enable', 'on')
else
    set(handles.minTime, 'Enable', 'off')
    set(handles.maxTime, 'Enable', 'off')
    set(handles.timeTo, 'Enable', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minTime_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minTime_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxTime_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxTime_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function timeStepCheck_Callback(hObject, eventdata, handles)

%Turn on all time step options if the box is checked
isChecked = get(hObject,'Value');

if isChecked
    set(handles.minTimeStep, 'Enable', 'on')
    set(handles.maxTimeStep, 'Enable', 'on')
    set(handles.timeStepTo, 'Enable', 'on')
    set(handles.minutesTag, 'Enable', 'on')
    set(handles.minutes2Tag, 'Enable', 'on')
else
    set(handles.minTimeStep, 'Enable', 'off')
    set(handles.maxTimeStep, 'Enable', 'off')
    set(handles.timeStepTo, 'Enable', 'off')
    set(handles.minutesTag, 'Enable', 'off')
    set(handles.minutes2Tag, 'Enable', 'off')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minTimeStep_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function minTimeStep_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxTimeStep_CreateFcn(hObject, eventdata, handles)

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxTimeStep_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [runningArchive] = checkUpdate(handles)

%This function updates the archive of values to include in the web page
%based on what options are checked onscreen.
fullArchive = handles.fullArchive;

theInputVar = [];

theExperimentList = get(handles.experimentList, 'String');
theExperimentNums = get(handles.experimentList, 'Value');
[theExperiments{(1:length(theExperimentNums))}] = deal(theExperimentList{theExperimentNums});
if isempty(theExperiments)
    warndlg('You must select 1 or more experiments!  Use Shift/CTRL to select multiple.', 'Warning', 'modal');
    return
end

%Experiment
if get(handles.experimentCheck, 'Value')
    theInputVar = [theInputVar ', ''experiment'''];
    theInputVar = [theInputVar, ', theExperiments'];
end

%Location
if get(handles.locationCheck, 'Value')
    theMinLat = str2num(get(handles.minLat, 'String'));
    theMaxLat = str2num(get(handles.maxLat, 'String'));
    Lats = [theMinLat theMaxLat];
    theMinLon = str2num(get(handles.minLon, 'String'));
    theMaxLon = str2num(get(handles.maxLon, 'String'));
    Lons = [theMinLon theMaxLon];
    if ~isnumeric(Lats) | ~isnumeric(Lons) | isnan(Lats) | isnan(Lons) | theMinLat > theMaxLat | ...
            theMinLon > theMaxLon
        warndlg('Latitudes and longitudes must be numeric values (min < max).', 'Warning', 'modal')
        return
    end
    theInputVar = [theInputVar, ', ''lat'''];
    theInputVar = [theInputVar, ', Lats'];
    theInputVar = [theInputVar, ', ''lon'''];
    theInputVar = [theInputVar, ', Lons'];
end

%Data type
if get(handles.dataTypeCheck, 'Value')
    theDataTypes = get(handles.dataTypeList, 'String');
    theDataTypes = theDataTypes{get(handles.dataTypeList, 'Value')};
    if isempty(theDataTypes)     
        warndlg('You must select 1 or more data types!  Use Shift/CTRL to select multiple.', 'Warning', 'modal');
        return
    end       
    theInputVar = [theInputVar, ', ''data type'''];
    theInputVar = [theInputVar, ', theDataTypes'];
end
        
%Time
if get(handles.timeCheck, 'Value')
    try
        theMinTime = datenum(get(handles.minTime, 'String'));
        theMaxTime = datenum(get(handles.maxTime, 'String'));
    catch
        warndlg('The times must be input in an acceptible format.  Type "help datestr.m" for details.', 'Warning', 'modal');
        return
    end
    theTimes = [datenum2julian(theMinTime) datenum2julian(theMaxTime)];
    theInputVar = [theInputVar, ', ''time'''];
    theInputVar = [theInputVar, ', theTimes'];
end

%Time step
if get(handles.timeStepCheck, 'Value')    
    theMinTimeStep = str2num(get(handles.minTimeStep, 'String'));
    theMaxTimeStep = str2num(get(handles.maxTimeStep, 'String'));
    TimeSteps = [theMinTimeStep theMaxTimeStep];
    if ~isnumeric(TimeSteps) | isnan(TimeSteps) | theMinTimeStep > theMaxTimeStep
        warndlg('Time steps must be numeric values (min < max).', 'Warning', 'modal')
        return
    end
    theInputVar = [theInputVar, ', ''time step'''];
    theInputVar = [theInputVar, ', TimeSteps'];
end

%If no boxes are checked, run the full archive; else, run with the options
%specified
if ~isempty(theInputVar)
    theCommand = ['runningArchive = findfiles(fullArchive, ' theInputVar(3:end) ');'];
else
    theCommand = ['runningArchive = findfiles(fullArchive);'];
end

eval(theCommand);

uiwait(msgbox(['The number of files meeting your criterion is ' num2str(length(runningArchive))], 'For your info. . .', ...
    'help', 'modal'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function goButton_Callback(hObject, eventdata, handles)

%Program to create the actual web page
if isempty(handles.fullArchive)
    warndlg('No files loaded!', 'Warning', 'modal')
    return
end

currentArchive = checkUpdate(handles);
handles.runningArchive = currentArchive;
guidata(hObject, handles)

if isempty(currentArchive)
    warndlg('No files meeting currently selected criterion!', 'Warning', 'modal')
    return
end

%Get the name of the output web file
if (length(get(handles.experimentList, 'Value')) == 1 & get(handles.experimentCheck, 'Value')) | ...
        (length(get(handles.experimentList, 'String')) == 1)
    theIndex = get(handles.experimentList, 'Value');
    theList = get(handles.experimentList, 'String');
    theDefault = {theList{theIndex}};
else
    theDefault = {'Your Selections'};
end
thePrompt = {'Input the title to be displayed on the output web page.'};
theTitle = 'Input web page title';
theWebTitle = inputdlg(thePrompt, theTitle, 1, theDefault);
if isempty(theWebTitle)
    return
end

%Prompt for the output file name
[fileName, pathName] = uiputfile({'*.html'; '*.htm'}, 'Save the web page as: ', 'C:\DATAARCHIVE\WEBPAGES\test.html');
if isequal(fileName, 0) | isequal(pathName, 0)
    return
end    

webPageFile = fullfile(pathName, fileName);

try
    createarchivetable(webPageFile, currentArchive, 'web title', theWebTitle{1});
catch
    warndlg('Web page could not be created.', 'Warning', 'modal')
    return
end

handles.output = currentArchive;
guidata(hObject, handles);

eval(['!' webPageFile])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clearViewer_Callback(hObject, eventdata, handles)

%Clear the viewer (reset to original settings)
theAnswer = questdlg('Do you really want to clear all files?', 'Question. . .');

if ~strcmp(theAnswer, 'Yes')
    return
end

set(handles.archiveList, 'String', {})
set(handles.archiveList, 'Value', 1)
set(handles.archiveList, 'Enable', 'off')
set(handles.experimentCheck, 'Value', 0)
set(handles.experimentCheck, 'enable', 'off')
set(handles.experimentList, 'enable', 'off')
set(handles.experimentList, 'String', {})
set(handles.experimentList, 'Value', 1)
set(handles.updateToExperiment, 'enable', 'off')
set(handles.dataTypeCheck, 'Value', 0)
set(handles.dataTypeCheck, 'enable', 'off')
set(handles.dataTypeList, 'enable', 'off')
set(handles.dataTypeList, 'String', {})
set(handles.dataTypeList, 'Value', 1)
set(handles.locationCheck, 'Value', 0)
set(handles.locationCheck, 'enable', 'off')
set(handles.latText, 'enable', 'off')
set(handles.lonText, 'enable', 'off')
set(handles.minLat, 'enable', 'off')
set(handles.minLat, 'string', '')
set(handles.maxLat, 'enable', 'off')
set(handles.maxLat, 'string', '')
set(handles.minLon, 'enable', 'off')
set(handles.minLon, 'string', '')
set(handles.maxLon, 'enable', 'off')
set(handles.maxLon, 'string', '')
set(handles.timeCheck, 'Value', 0)
set(handles.timeCheck, 'enable', 'off')
set(handles.minTime, 'enable', 'off')
set(handles.minTime, 'string', '')
set(handles.maxTime, 'enable', 'off')
set(handles.maxTime, 'string', '')
set(handles.timeTo, 'enable', 'off')
set(handles.timeStepCheck, 'Value', 0)
set(handles.timeStepCheck, 'Enable', 'off')
set(handles.minTimeStep, 'string', '')
set(handles.maxTimeStep, 'string', '')
set(handles.minutesTag, 'enable', 'off')
set(handles.minutes2Tag, 'enable', 'off')
set(handles.timeStepTo, 'enable', 'off')
set(handles.goButton, 'enable', 'off')
set(handles.removeArchive, 'enable', 'off')
handles.fullArchive = [];
handles.runningArchive = [];
guidata(hObject, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeButton_Callback(hObject, eventdata, handles)

theAnswer = questdlg('Do you really want to exit?', 'Question. . .');

if strcmp(theAnswer, 'Yes')
    closereq
end

