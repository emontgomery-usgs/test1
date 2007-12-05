function doAllArchiveByTime(archiveName, htmlSaveStart);

%   Function to do all of the time step options (-a, -a1h, and -alp) for a
%   given directory and create suitably named html pages accordingly.  Page
%   names start with htmlSaveStart, and end with -a, -a1h, and -alp.
%
%   With no inputs, it runs as a gui based program.


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
%   Version 1.0  01-Apr-2003

%Check to see if information given in the command line
if ~exist('archiveName', 'var') 
    [dataArchiveFile, archivePath] = uigetfile({'*.mat', 'MAT-files (*.mat)';}, ...
        'Select the data archive file', 'dataArchive.mat');
    if isequal(dataArchiveFile,0) | isequal(archivePath,0)
        error('User selected cancel, terminating program.')
    end
    archiveName = [archivePath dataArchiveFile];
elseif ~strncmp('tam.', fliplr(archiveName), 4)
    archiveName = [archiveName '.mat'];
end

%Check for the existance of the given file
if ~exist(archiveName, 'file')
    error('Given data archive file does not exist or is not in the Matlab path.')
else
    load(archiveName, 'dataArchiveStruct')
    if ~exist('dataArchiveStruct', 'var')
        error('Selected file does not contain a "dataArchiveStruct" structure.')
    end
end

[theDirectory, theFile] = fileparts(archiveName);
if isempty(theDirectory)
    archiveName = fullfile(pwd, archiveName);
end


[bestVersion] = findfiles(dataArchiveStruct, 'project', theFile, 'time step', [0 58]);
[hourVersion] = findfiles(dataArchiveStruct, 'project', theFile, 'time step', [59 61]);
[lowpassVersion] = findfiles(dataArchiveStruct, 'project', theFile, 'time step', [359 361]);

load(archiveName)
totalFiles = length(dataArchiveStruct);

fprintf(['Best version is ' num2str(length(bestVersion)) ' of ' num2str(totalFiles) '.\n'])
fprintf(['Hour version is ' num2str(length(hourVersion)) ' of ' num2str(totalFiles) '.\n'])
fprintf(['Lowpass version is ' num2str(length(lowpassVersion)) ' of ' num2str(totalFiles) '.\n'])

if (totalFiles - length(bestVersion) - length(hourVersion) - length(lowpassVersion))
    fprintf(['Warning! ' num2str(totalFiles - length(bestVersion) - length(hourVersion) - ...
        length(lowpassVersion)) ' were not classified as -a, -a1h, or -alp!\n']);
end

createarchivetable([htmlSaveStart '-a.html'], bestVersion, 'web title', ...
    dataArchiveStruct(1).theExperiment, 'subtitle', 'Basic Sampling Interval');
createarchivetable([htmlSaveStart '-a1h.html'], hourVersion, 'web title', ...
    dataArchiveStruct(1).theExperiment, 'subtitle', 'Hourly Averaged Data');
createarchivetable([htmlSaveStart '-alp.html'], lowpassVersion, 'web title', ...
    dataArchiveStruct(1).theExperiment, 'subtitle', 'Lowpassed Data (6 hour interval)');