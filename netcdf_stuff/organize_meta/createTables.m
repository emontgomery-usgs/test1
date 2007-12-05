function createTables(outputNameRoot, dataArchiveStruct, varargin);
%
%   createTables(outputNameRoot, dataArchiveStruct);
%
%   Function to create an HTML page of select files based on a data 
%   structure (as output from archiveDirectory).  Also needed is the 
%   output name of the html file to write to. 
%
%   If none is given, the program prompts for
%   the output name for the HTML.  Addition options to give the program
%   after the two primary inputs are:
%   'webTitle' : Goes at the top of the page; if none is given, it uses the
%   first experiment name in the archive structure.
%   'subtitle' :  Goes at the top of the page below the title;
%   Useful if a sub-sampling of the data has been taken.


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

 
%  etm mods 8/29/07
%  will split the -a, -a1h and other suffixes into separate files
%  outputs a csv list as well to use in other discovery apps.

% GM mods 9/4 to point to the proper .css and add more descriptive keywords

%   This program is provided with no promises, warrenties, or guaranties.
%   User support is not actively provided by its creator or USGS; however,
%   questions/bugs may be reported and will be addressed where possible.
%
% Written by Soupy Alexander
% for the U.S. Geological Survey
% Marine and Coastal Program
% Woods Hole Center, Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to emontgomery@usgs.gov
%
%   Additional information about the .nc format may be obtained at 
%   http://www.met.tamu.edu/personnel/students/barnaby/netcdf/guide.txn_toc.hmtl
%
%   Version 2.0  29-Aug-2007

%Set the default string to print if data is unavailable
defString = '*';

%Get the html output name
if ~exist('outputNameRoot', 'var')
    [outputNameRoot, outputPath] = uiputfile({'*.html'; '*.htm'}, ...
        'Select an output file name for the html page', 'WebPage.html');
    if isequal(outputNameRoot,0) | isequal(outputPath,0)
        error('User selected cancel, terminating program.')
    end
    outputNameRoot = [outputPath outputNameRoot];
end    

if exist('varargin', 'var')
    subtitleInd = find(strcmp('subtitle', varargin));
    if ~isempty(subtitleInd)
        subtitle = varargin{subtitleInd+1};
    end
end

if exist('varargin', 'var')
    titleInd = find(strcmp('web_title', varargin));
    if ~isempty(titleInd)
        webTitle = varargin{titleInd+1};
    else
        webTitle=dataArchiveStruct(1).theExperiment;
    end
end
% this part may only have to be used for mbay_ltb
if exist('varargin', 'var')
   bidx = find(strcmp('expname', varargin));
    if ~isempty(bidx)
        basename = varargin{bidx+1};
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
theDir = [theDirectory(theStart:end)];
% for doing this after the fact, we want theDirectory to always point to
% stellwagen
theDirectory = ['http://stellwagen.er.usgs.gov/' theDir];
theExperiment = dataArchiveStruct(1).theExperiment;

% first we split the directory up to get -a -a1h and -alp
lpcnt=1; acnt=1; a1hcnt=1; lpidx=[];a1hidx=[];aidx=[];
for kk=1:length(dataArchiveStruct)
  if strfind(lower(dataArchiveStruct(kk).fileList),'lp')
    lpidx(lpcnt)=kk;
    lpcnt=lpcnt+1;
  elseif strfind(lower(dataArchiveStruct(kk).fileList),'1h')
      a1hidx(a1hcnt)=kk;
      a1hcnt=a1hcnt+1;
  elseif strfind(lower(dataArchiveStruct(kk).fileList),'-a')   
      aidx(acnt)=kk;
      acnt=acnt+1;
  elseif strfind(lower(dataArchiveStruct(kk).fileList),'-cal')
      aidx(acnt)=kk;
      acnt=acnt+1;
  elseif strfind(lower(dataArchiveStruct(kk).fileList),'junk') 
      disp([dataArchiveStruct(kk).fileList ' is not included'])
  elseif  strncmp(lower(dataArchiveStruct(kk).fileList),'ep_st',5)
      disp([dataArchiveStruct(kk).fileList ' is not included'])
  else    % consider anything else not our data
      % these are available via the dods link, but not our index
  end
end


%make one html file for each type- raw, hourly, lowpassed
%Put in the file header
for ik=1:3
    if ik==1
      outputName=[outputNameRoot '-lp.html'];
      subtitle=['Lowpass filtered ed Data (6 hour interval)']
      if ~isempty(lpidx)
        ci=lpidx;
      else
        ci=0;
      end
    elseif ik==2
      outputName=[outputNameRoot '-a1h.html'];
      subtitle=['Hourly Averaged Data']
      if ~isempty(a1hidx)
        ci=a1hidx;
      else
        ci=0;
      end
    else
      outputName=[outputNameRoot '-a.html'];
      subtitle=['Basic Sampling Interval'];
      if ~isempty(aidx)
        ci=aidx;
      else
        ci=0;
      end
    end
   csvname=[outputNameRoot '.csv'];
if ci ~= 0
   
  fileID = fopen(outputName,'w');
  csvID = fopen(csvname, 'w');

%Put in the HTML style sheet
fwrite(fileID, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ');fprintf(fileID, '\n');
fwrite(fileID, '<html>'); fprintf(fileID, '\n');
fwrite(fileID, '<head>'); fprintf(fileID, '\n');
fwrite(fileID, ['<title>' webTitle '</title>']); fprintf(fileID, '\n\n');
fwrite(fileID, ['<meta name="keywords" content="oceanography, sediment transport, research, currents, hydrography, time series data, nearshore oceanographic research, Georges Bank, Gulf of Maine, Atlantic, Massachusetts Bay, OpenDAP, DODS, marine geology, earthscience, USGS, Coastal Marine Geology Program"/>']); fprintf(fileID, '\n');
fwrite(fileID, '<script type="text/javascript" language="JavaScript1.2" src="/js/menu.js"></script>');fprintf(fileID, '\n');
%Input the style sheet
fwrite(fileID, '<link rel="STYLESHEET" type="text/css" href="/css/common.css"/>');fprintf(fileID, '\n');
fwrite(fileID, '<link rel="STYLESHEET" type="text/css" href="/css/whsc_custom.css"/>');fprintf(fileID, '\n');
fwrite(fileID, '<link rel="STYLESHEET" type="text/css" href="/css/stellwagen.css"/>');
fprintf(fileID, '\n');

%Use the include to put in the header
fprintf(fileID, '\n');
fwrite(fileID, '</head>'); fprintf(fileID, '\n');
fwrite(fileID, '<body>'); fprintf(fileID, '\n');
fwrite(fileID, ' <!--#include virtual="/inc/header.txt" -->');fprintf(fileID, '\n');
fwrite(fileID, ' <!--#include virtual="/inc/top_menu.txt" -->');
fprintf(fileID, '\n\n');

if exist('webTitle', 'var')
    fwrite(fileID, ['<h1>' webTitle '</h1>']); fprintf(fileID, '\n\n');
end
if exist('subtitle', 'var')
    fwrite(fileID, ['<h2>' subtitle '</h2>']); fprintf(fileID, '\n');
end
fwrite(fileID, '<hr/><br/>'); fprintf(fileID, '\n');
fprintf(fileID, '\n');

%Set up the table
fwrite(fileID, '<div id="exp_table">'); fprintf(fileID, '\n');
fwrite(fileID, '<table cellspacing=0 cellpadding=0 border=1 summary="This table contains the data files and relevant information">');
fprintf(fileID, '\n');
fwrite(fileID, '<tr valign="top" align="center">'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="120">File Name</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="64">Start<br/>Time</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="64">End<br/>Time</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="67">Latitude</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="67">Longitude</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="43">Inst. Depth</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="43">Water Depth</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="80">Instrument Type</th>'); fprintf(fileID, '\n');
fwrite(fileID, '<th scope="col" width="141">Variables</th>'); fprintf(fileID, '\n');
fwrite(fileID, '</tr>'); fprintf(fileID, '\n');

%Now that the data has been extracted, it needs to be sorted and put into
%the output table
 for index=ci
    fwrite(fileID, '<tr valign="top">'); fprintf(fileID, '\n');
    theFileName = [theDirectory dataArchiveStruct(index).fileList];
    theSlash = strfind(theFileName, '\');
    theFileName(theSlash) = '/';
    fwrite(fileID, ['<td scope="row"><a href="' theFileName '">' dataArchiveStruct(index).fileList '</a></td> ']); fprintf(fileID, '\n');
    fwrite(csvID, [dataArchiveStruct(index).fileList ', ']);
      % if strfind(dataArchiveStruct(index).fileList,'cal'); keyboard; end
    if ~isnan(dataArchiveStruct(index).startTime)
        fwrite(fileID, ['<td align="right">' datestr(julian2datenum(dataArchiveStruct(index).startTime(1)), 2) '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [datestr(julian2datenum(dataArchiveStruct(index).startTime(1)), 2) ', ']); 
    else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end
    if ~isnan(dataArchiveStruct(index).endTime)
        fwrite(fileID, ['<td align="right">' datestr(julian2datenum(dataArchiveStruct(index).endTime(1)), 2) '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [datestr(julian2datenum(dataArchiveStruct(index).endTime(1)), 2) ', ']);
   else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end
    if ~isnan(dataArchiveStruct(index).theLat)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).theLat, '%0.4f') '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [num2str(dataArchiveStruct(index).theLat, '%0.4f') ', ']);
  else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end    
    if ~isnan(dataArchiveStruct(index).theLon)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).theLon, '%0.4f') '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [num2str(dataArchiveStruct(index).theLon, '%0.4f') ', ']);
   else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end   
    if ~isnan(dataArchiveStruct(index).instDepth)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).instDepth, '%0.1f') '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [num2str(dataArchiveStruct(index).instDepth, '%0.1f') ', ']);
   else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end     
    if ~isnan(dataArchiveStruct(index).waterDepth)
        fwrite(fileID, ['<td align="right">' num2str(dataArchiveStruct(index).waterDepth, '%0.1f') '</td>']); fprintf(fileID, '\n');
         fwrite(csvID, [num2str(dataArchiveStruct(index).waterDepth, '%0.1f') ', ']);
   else
        fwrite(fileID, ['<td align="right">' defString '</td>']); fprintf(fileID, '\n');
    end    
    theInstType = dataArchiveStruct(index).instType;
    fwrite(fileID, ['<td>']); 
    fwrite(csvID,['[']);
    for index2 = 1:length(theInstType)-1
        if ~isnan(theInstType{index2})
            fwrite(fileID, [theInstType{index2} ', ']);
              fwrite(csvID, [theInstType{index2} ': ']);
      else
            fwrite(fileID, [defString ', </td>']); fprintf(fileID, '\n');
        end    
    end 
      %terminate the potentially long list
      fwrite(csvID,['],']);
      
    if ~isnan(theInstType{length(theInstType)})
        fwrite(fileID, [theInstType{length(theInstType)} '</td>']); fprintf(fileID, '\n');
    else
        fwrite(fileID, [defString '</td>']); fprintf(fileID, '\n');
    end 
    fwrite(fileID, '<td>');
    theFileVars = dataArchiveStruct(index).dataTypes;
       fwrite(csvID,['[']);
    for index2 = 1:length(theFileVars)-1
         fprintf(fileID, [theFileVars{index2} ', ']);
           fprintf(csvID, [theFileVars{index2} ': ']);
    end
        fwrite(csvID,[']']); fprintf(csvID, '\n');  % newline for csv

    fwrite(fileID, [theFileVars{length(theFileVars)} '</td']); fprintf(fileID, '\n');
    fwrite(fileID, '</tr>'); fprintf(fileID, '\n');
end
fwrite(fileID, '</table>'); fprintf(fileID, '\n');
fwrite(fileID, '</div>'); fprintf(fileID, '\n');

%Finish off the HTML page
% this part assumes the names follow this convention: mbay_lt.html is the
% main page for the experiment, and mbay_lt-a.html, and mbay_lt-a1h.html
% are the index htmls listing the contents of the netcdf files
%
% but MassBay also has ltb-a and ltp-a1h which are under mbay_lt.html
[thePath, actName, theExt] = fileparts(outputName);
theDash = findstr('-', actName);
actName = actName(1:theDash-1);
 if exist('basename')
       actName=basename;
 else
    if (isempty (actName))
      actName='mainpage';
        disp ('could not find the name of the experiment page- Fix before updating!')
    end
  end
fwrite(fileID, ['<br/> <a href="' actName '.html"><strong><i>BACK TO EXPERIMENT</i></strong></a>']);
fprintf(fileID, '\n');
fwrite(fileID, ['<br/> <a href="mainpage.html"><strong><i>BACK TO EXPERIMENT LIST</i></strong></a>']);

fprintf(fileID, '\n');
fwrite(fileID, '<!--#include virtual="/inc/footer.txt" -->');
fprintf(fileID, '\n');
fwrite(fileID, '</body>'); fprintf(fileID, '\n');
fwrite(fileID, '</html>'); fprintf(fileID, '\n');

   fclose(fileID);
  end
end
fclose(csvID)
