function [newStruct] = findFiles(archiveStructs, varargin);
%
%   [newStruct] = findFiles(archiveStructs, varargin);
%
%   Function to look through all given data archive structures (given as a
%   cell array of structures or a single structure) for files meeting certain criterion.  
%   
%   Current options include:
%
%   'time':  given as a 1 x 2 matrix of the julian
%   date to start/stop looking for files
%
%   'lat' and 'lon': given as a 1 x 2 matrix of the latitude and/or longitude
%   to include (+ = north/east, - =  south/west)
%   
%   'data type':  given as a cell array of strings of the data types to
%   look for.
%
%   'time step':  a time step to look for (given as a 1 x 2 matrix of minimum
%   and maximum time step to look for)
%
%   'experiment':  a cell array of experiment names to include (must match
%   recorded value in archive exactly)
%
%
%!!!!With no options, it will pull ALL of the files!

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

%This warning get annoying
warning off MATLAB:mat2cell:ObsoleteSingleInput

%Get the files
if ~exist('archiveStructs', 'var')
    error('Program must be given a cell array of structures!')
elseif ~iscell(archiveStructs) & isstruct(archiveStructs)
    interim = archiveStructs;
    clear archiveStructs
    archiveStructs{1} = interim;
else
    error('Program must be given a cell array of structures!')
end

%Check what the search is looking for
if exist('varargin', 'var')
    
    timeInd = find(strcmp('time', varargin));
    if ~isempty(timeInd)
        timeLimit = varargin{timeInd+1};
        if ~isnumeric(timeLimit) | find(timeLimit < 0) | prod(size(timeLimit)) ~= 2 | ...
                timeLimit(1) > timeLimit(2)
            error('The input time must be a 1 x 2 matrix of julian dates, with the first input less than the second!')
        end
    end
    
    latInd = find(strcmp('lat', varargin));
    if ~isempty(latInd)
        latLimit = varargin{latInd+1};
        if ~isnumeric(latLimit) | prod(size(latLimit)) ~= 2 | latLimit(1) > latLimit(2)
            error('The input latitude must be a 1 x 2 matrix of latitudes, with the first input less than the second!')
        end
    end
    
    lonInd = find(strcmp('lon', varargin));
    if ~isempty(lonInd)
        lonLimit = varargin{lonInd+1};
        if ~isnumeric(lonLimit) | prod(size(lonLimit)) ~=2 | lonLimit(1) > lonLimit(2)
            error('The input longitude must be a 1 x 2 matrix of latitudes, with the first input less than the second!')    
        end
    end
    
    
    dataInd = find(strcmp('data type', varargin));
    if ~isempty(dataInd)
        dataLimit = varargin{dataInd+1};
        if ~iscell(dataLimit) & ischar(dataLimit)
            dataLimit = mat2cell(dataLimit);
        elseif (~iscell(dataLimit) & ~ischar(dataLimit))
            error('The file list must be a cell array of strings.')
        end
    end
    
    experimentInd = find(strcmp('experiment', varargin));
    if ~isempty(experimentInd)
        experimentLimit = varargin{experimentInd+1};
        if ~iscell(experimentLimit) & ischar(experimentLimit);
            experimentLimit = mat2cell(experimentLimit);
        elseif (~iscell(experimentLimit) & ~ischar(experimentLimit))
            error('The experiment list must be a cell array of strings.')
        end
    end
    
    timeStepInd = find(strcmp('time step', varargin));
    if ~isempty(timeStepInd)
        timeStepLimit = varargin{timeStepInd+1};    
        if ~isnumeric(timeStepLimit) | prod(size(timeStepLimit)) ~=2 | timeStepLimit(1) > timeStepLimit(2)
            error('The input time step must be a 1 x 2 matrix, with the first input less than the second!')    
        end
    end
end

%Go through the list of archives to search, and add the data to the
%building structure
for indexArchive = 1:length(archiveStructs)
    dataArchiveStruct = archiveStructs{indexArchive};
    
    if ~exist('runningArchive', 'var')
        runningArchive = dataArchiveStruct;
    else
        try
            runningArchive = [runningArchive dataArchiveStruct];
        catch
            error('The archive files have different recorded fields (i.e., the archiving program has been changed and the files have not been updated).  Run the current archiving program to recreate the archive files.');
        end
    end      
end

%Now do the other searches
if exist('timeLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theStartTimes{1:length(runningArchive)}] = deal(runningArchive.startTime);
    theStartTimes = cell2mat(theStartTimes);
    [theEndTimes{1:length(runningArchive)}] = deal(runningArchive.endTime);
    theEndTimes = cell2mat(theEndTimes);
    theStartMat = ([theStartTimes(:) repmat(timeLimit(1), length(theStartTimes), 1)])';
    maxStarts = max(theStartMat);
    theEndMat = ([theEndTimes(:) repmat(timeLimit(2), length(theEndTimes), 1)])';
    minEnds = min(theEndMat);
    bads = find(maxStarts > minEnds);
    runningArchive(bads) = [];
end

if exist('latLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theLats{1:length(runningArchive)}] = deal(runningArchive.theLat);
    theLats = cell2mat(theLats);
    bads = find(theLats > latLimit(2) | theLats < latLimit(1));
    runningArchive(bads) = [];
end

if exist('lonLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theLons{1:length(runningArchive)}] = deal(runningArchive.theLon);
    theLons = cell2mat(theLons);
    bads = find(theLons > lonLimit(2) | theLons < lonLimit(1));
    runningArchive(bads) = [];
end     

if exist('timeStepLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theTimeSteps{1:length(runningArchive)}] = deal(runningArchive.timeStep);
    theTimeSteps = cell2mat(theTimeSteps);
    bads = find(theTimeSteps > timeStepLimit(2) | theTimeSteps < timeStepLimit(1) | isnan(theTimeSteps));
    runningArchive(bads) = [];
end  

if exist('experimentLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theExperiments{1:length(runningArchive)}] = deal(runningArchive.theExperiment);
    experimentLimit = deblank(lower(experimentLimit));
    theExperiments = deblank(lower(theExperiments));
    for index = 1:length(experimentLimit)
        goods = strmatch(experimentLimit{index}, theExperiments);
        if ~exist('expCheck', 'var') & goods
            expCheck = runningArchive(goods);
        elseif goods
            expCheck = [expCheck runningArchive(goods)];
        elseif index == length(experimentLimit) & ~exist('expCheck', 'var')
            expCheck = [];
        end
    end
    runningArchive = expCheck;
end


%This one potentially takes the longest, run it *last*
if exist('dataLimit', 'var')
    if isempty(runningArchive)
        newStruct = [];
        return
    end
    [theDataTypes{1:length(runningArchive)}] = deal(runningArchive.dataTypes);
    dataLimit = deblank(lower(dataLimit));
    bads = [];
    for index = 1:length(theDataTypes)
        zeCheck = [dataLimit(:)' deblank(lower(theDataTypes{index}))];
        if length(unique(zeCheck)) == length(dataLimit) + length(theDataTypes{index})
            bads = [bads index];
        end
    end
    runningArchive(bads) = [];
end


newStruct = runningArchive;