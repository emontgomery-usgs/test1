function createArchiveTable(outputName, dataArchiveStruct, varargin);
%
%   createArchiveTable(outputName, dataArchiveStruct);
%
%   Function to create an HTML page of select files based on a data 
%   structure (as output from archiveDirectory).  Also needed is the 
%   output name of the html file to write to. 
%
%   If none is given, the program prompts for
%   the output name for the HTML.  Addition options to give the program
%   after the two primary inputs are:
%   'web title' : Goes at the top of the page; if none is given, it uses the
%   first experiment name in the archive structure.
%   'subtitle' :  Goes at the top of the page below the title;
%   Useful if a sub-sampling of the data has been taken.

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

%Set the default string to print if data is unavailable
defString = '*';

%Get the html output name
if ~exist('outputName', 'var')
    [outputName, outputPath] = uiputfile({'*.html'; '*.htm'}, ...
        'Select an output file name for the html page', 'WebPage.html');
    if isequal(outputName,0) | isequal(outputPath,0)
        error('User selected cancel, terminating program.')
    end
    outputName = [outputPath outputName];
end    

if exist('varargin', 'var')
    subtitleInd = find(strcmp('subtitle', varargin));
    if ~isempty(subtitleInd)
        subtitle = varargin{subtitleInd+1};
    end
end

if exist('varargin', 'var')
    titleInd = find(strcmp('web title', varargin));
    if ~isempty(titleInd)
        webTitle = varargin{titleInd+1};
    end
end

%Get the list of interesting files
if isempty(dataArchiveStruct)
    disp('No files in file list!  No html page created.');
    return
end

theDirectory = dataArchiveStruct(1).targetDirectory;
%Making the path names relative
theStart = strfind(theDirectory, 'DATAFILES');
theDirectory = [theDirectory(theStart:end)];
theExperiment = dataArchiveStruct(1).theExperiment;

%Put in the file header
fileID = fopen(outputName,'w');

%Put in the HTML style sheet
fwrite(fileID, '<html>'); fprintf(fileID, '\n');
fwrite(fileID, '<head>'); fprintf(fileID, '\n');
fwrite(fileID, ['<title>' webTitle '</title>']); fprintf(fileID, '\n\n');

%Input the style sheet
fwrite(fileID, '<LINK rel="STYLESHEET" type="text/css" href="/include/whfc_pub.css">');
fprintf(fileID, '\n');

%Use the include to put in the header
fprintf(fileID, '\n');
fwrite(fileID, '</head>'); fprintf(fileID, '\n');
fwrite(fileID, '<body>'); fprintf(fileID, '\n');
fwrite(fileID, '<!--#include virtual="/include/head_pub.txt" -->');
fprintf(fileID, '\n\n');

if exist('webTitle', 'var')
    fwrite(fileID, ['<h1>' webTitle '</h1>']); fprintf(fileID, '\n\n');
end
if exist('subtitle', 'var')
    fwrite(fileID, ['<h2>' subtitle '</h2>']); fprintf(fileID, '\n');
end
fwrite(fileID, '<hr><br>'); fprintf(fileID, '\n');
fprintf(fileID, '\n');

%Set up the table
fwrite(fileID, '<table cellspacing=0 cellpadding=0 border=1 summary="This table contains the data files and relevant information">');
fprintf(fileID, '\n');
fwrite(fileID, '<tr valign="top" align="center">'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="120">File Name</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="64">Start<br>Time</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="64">End<br>Time</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="67">Latitude</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="67">Longitude</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="43">Inst. Depth</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="43">Water Depth</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="80">Instrument Type</td>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="141">Variables</td>'); fprintf(fileID, '\n');
fwrite(fileID, '</tr>'); fprintf(fileID, '\n');

%Now that the data has been extracted, it needs to be ?sorted and put into the output table
for index = 1:length(dataArchiveStruct)
    fwrite(fileID, '<tr valign="top">'); fprintf(fileID, '\n');
    theFileName = [theDirectory dataArchiveStruct(index).fileList];
    theSlash = strfind(theFileName, '\');
    theFileName(theSlash) = '/';
    fwrite(fileID, ['<td scope="row"><a href="' theFileName '">' dataArchiveStruct(index).fileList '</a></td> ']); fprintf(fileID, '\n');
    if ~isnan(dataArchiveStruct(index).startTime)
        fwrite(fileID, ['<td align="right">' datestr(julian2datenum(dataArchiveStruct(index).startTime(1)), 2) '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end
    if ~isnan(dataArchiveStruct(index).endTime)
        fwrite(fileID, ['<td align="right">' datestr(julian2datenum(dataArchiveStruct(index).endTime(1)), 2) '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end
    if ~isnan(dataArchiveStruct(index).theLat)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).theLat(1), '%0.4f') '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end    
    if ~isnan(dataArchiveStruct(index).theLon)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).theLon(1), '%0.4f') '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end   
    if ~isnan(dataArchiveStruct(index).instDepth)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).instDepth(1), '%0.1f') '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end     
    if ~isnan(dataArchiveStruct(index).waterDepth)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).waterDepth(1), '%0.1f') '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end    
    theInstType = dataArchiveStruct(index).instType;
    fwrite(fileID, ['<td>']); 
    for index2 = 1:length(theInstType)-1
        if ~isnan(theInstType{index2})
            fwrite(fileID, [theInstType{index2} ', ']);
        else
            fwrite(fileID, [defString ', </td>']); fprintf(fileID, '\n');
        end    
    end 
    if ~isnan(theInstType{length(theInstType)})
        fwrite(fileID, [theInstType{length(theInstType)} '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, [defString '</td>']); fprintf(fileID, '\n');
    end 
    fwrite(fileID, '<td>');
    theFileVars = dataArchiveStruct(index).dataTypes;
    for index2 = 1:length(theFileVars)-1
        fprintf(fileID, [theFileVars{index2} ', ']);
    end
    fwrite(fileID, [theFileVars{length(theFileVars)} '</td']); fprintf(fileID, '\n');
    fwrite(fileID, '</tr>'); fprintf(fileID, '\n');
end

fwrite(fileID, '</table>'); fprintf(fileID, '\n');

%Finish off the HTML page
[thePath, actName, theExt] = fileParts(outputName);
theDash = findstr('-', actName);
actName = actName(1:theDash-1);
fwrite(fileID, ['<br> <a href="' actName '.html"><h3><i>BACK TO EXPERIMENT</i></h3></a>']);
fprintf(fileID, '\n');
fwrite(fileID, ['<br> <a href="mainpage.html"><h3><i>BACK TO EXPERIMENT LIST</i></h3></a>']);

fprintf(fileID, '\n');
fwrite(fileID, '<!--#include virtual="footer.html" -->');
fprintf(fileID, '\n');
fwrite(fileID, '</body>'); fprintf(fileID, '\n');
fwrite(fileID, '</html>'); fprintf(fileID, '\n');

fclose(fileID);
