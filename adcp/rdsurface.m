function [MSL,Dstd,Dout] = rdsurface(numRawFile,rawdata1,rawdata2,ADCP_offset,ensembles,progPath,DepthFile);

%function [MSL,Dstd,Dout] = rdsurface(numRawFile,rawdata1,rawdata2,ADCP_offset,ensembles,progPath,DepthFile);


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

 
%This function will run the RDI surface program to obtain an approximate
%water depth.  If file names are not given, they will be requested.
%
%INPUTS:
%	numRawFile = the number of Raw Binary ADCP files that make up the dataset, usually only one
%	rawdata1 = the first ADCP Binary data file
%	rawdata2 = the second ADCP Binary data file
%	ADCP_offset = the height of the ADCP above the bottom in meters!
%						if not give will be pulled from netcdf file.
%	ensembles = the index number for the good ensembles,
%				  is likely to be different than the ensemble numbers in rawdata 	
%	progPath = the full path for the RDI surface program on your computer
%	DepthFile = the output depth data file name, this is created based on the 
%					rawdata file name if not given
%
%Outputs:
%	MSL = the mean sea level
%	Dstd = the standard of deviation of the depth which should 
%			 be an approximate tidal fluctuation
%	Dout = the surface depth at each ensemble as distinguished by 
%			 RDI's surface program

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

% updated 1-jan-2006 (MM) - prevent multiple appending
% version 1.1
% add use of a settings struct to pass arguements
%version 1.0
% update 01-sep-2005 (SDR) Allows user to browse to directory where SURFACE.EXE is
%                           located 
% update 12-aug-2005 (SDR) Automatically sets directory to look for
%                       SURFACE.EXE to the current directory
% update 06-aug-2001 - Use fappend.m to automatically concatenate ADCP data binary files (if needed) 
%		to run SURFACE.exe (ALR)
% update 09-Jul-2001 - automatically concatonates ADCP data binary files if needed 
%		to run SURFACE.exe (ALR)
% update 03-Jan-2001 14:18:52 - need to account for place holders for missing ens numbers 
%     created by fixEns.m
% update 27-Dec-2000 15:29:06 - to read long and short ADCP data file names (ALR)
% updated 06-sep-2000 - to read long ADCP data file names
% updated 17-Feb-2000 14:32:50
% updated 02-Feb-2000 09:34:12
%	- if run with batch, will be prompted to look at depth limits unless
%	a depth is explicitly defined
%updated 10-Aug-1999 16:20:42

if nargin==1 && isstruct(numRawFile),
    settings = numRawFile;
    if isfield(settings,'numRawFile'), numRawFile = settings.numRawFile;
    else numRawFile = ''; end
    if isfield(settings,'rawdata1'), rawdata1 = settings.rawdata1;
    else rawdata1 = ''; end
    if isfield(settings,'rawdata2'), rawdata2 = settings.rawdata2;
    else rawdata2 = ''; end
    if isfield(settings, 'ADCP_offset'), ADCP_offset = settings.ADCP_offset;
    else ADCP_offset = ''; end
    if isfield(settings, 'progPath'), progPath = settings.progPath;
    else progPath = ''; end
    if isfield(settings, 'ensembles') ensembles = settings.ensembles;
    else ensembles = ''; end
    if isfield(settings, 'DepthFile') DepthFile = settings.DepthFile;
    else DepthFile = ''; end
else
    if nargin < 1, numRawFile = ''; end
    if nargin < 2, rawdata1 = ''; end
    if nargin < 3, rawdata2 = ''; end
    if nargin < 4, ADCP_offset = ''; end
    if nargin < 5, ensembles='';end
    if nargin < 6, progPath='';end
    if nargin < 7, DepthFile =''; end
end

if isempty(numRawFile)
   numRawFile = menu('How many bianry files used?','1','2');
end
if isempty(rawdata1), rawdata1 ='*'; end
if isempty(rawdata2), rawdata2 = '*'; end
if isempty(ADCP_offset), ADCP_offset = NaN; end
if isempty(DepthFile), DepthFile = '*'; end

%where are we currently
s=pwd;


%Get binary ADCP data file(s)
switch numRawFile
case 1
   rawdata = rawdata1; clear rawdata1 rawdata2
   if any(rawdata == '*')
   [dataFile, dataPath] = uigetfile(rawdata, 'Select Binary ADCP File:');
   if ~any (dataFile), return, end
   if dataPath(end) ~= filesep, dataPath(end+1) = filesep; end
   rawdata = [dataPath dataFile];
   [dataPath, dataname, ext] = fileparts(rawdata);
else
   [dataPath, dataname, ext]=fileparts(rawdata);
   dataFile=[dataname ext];
end
end


%Get second binary ADCP data if needed
switch numRawFile
case 2
   if any(rawdata1 == '*')
   [dataFile1, dataPath1] = uigetfile(rawdata1, 'Select 1st Binary ADCP File:');
   if ~any(dataFile1), return, end
   if dataPath1(end) ~= filesep, dataPath1(end+1) = filesep; end
   rawdata1 = [dataPath1 dataFile1];
else
   [dataPath1, dataname1, ext]=fileparts(rawdata1);
   dataFile1=[dataname1 ext];
end
   if any(rawdata2 == '*')
   [dataFile2, dataPath2] = uigetfile(rawdata2, 'Select 2nd Binary ADCP File:');
      if dataPath2(end) ~= filesep, dataPath2(end+1) = filesep; end
      rawdata2 = [dataPath2 dataFile2];  
      else
         [dataPath2, dataname2, ext]=fileparts(rawdata2);
         dataFile2=[dataname2 ext];
      end
  %If there are two binary files that make up the dataset, concatonate them now
  if exist(dataFile2)
     dataFile = [dataFile1(1:5) 'all.000'];
     if exist(dataFile,'file'), delete(dataFile); end
     fappend(dataFile,rawdata1,rawdata2);
     dataPath = dataPath1;
     if isempty(dataPath)
        dataPath = s;
     end
     if dataPath(end) ~= filesep, dataPath(end+1) = filesep; end
     rawdata = [dataPath dataFile];
     [dataPath, dataname, ext] = fileparts(rawdata);
     clear rawdata1 rawdata2 dataFile1 dataPath1 dataFile2 dataPath2 ss w
  end
end


%get the ADCP trasnducer offset out of *.cdf file
if isnan(ADCP_offset)
   [theFile, thePath] = uigetfile('*.cdf', 'Select Netcdf ADCP File to find ADCP offset:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	cdfFile = [thePath theFile];
   f=netcdf(cdfFile);
   ADCP_offset=f{'D'}.xducer_offset_from_bottom(:);
   close(f)
end


%where is the program located
if isempty(progPath) | ~exist(fullfile(progPath,'surface.exe'),'file')
    disp(['RDI Surface.exe not in ' cd '.  Need to locate file.']); 
        [RDSurfaceFile, RDSurfacePath] = uigetfile(progPath, 'Select RDI Surface Program:');
        if ~any(RDSurfaceFile), return, end
        if RDSurfacePath(end) ~= filesep, RDSurfacePath(end+1) = filesep; end
        progPath = RDSurfacePath;  
end

if progPath(end) ~= filesep, progPath(end+1) = filesep; end

   
%Create output file for depths
if any(DepthFile == '*')
   [thePath,theFile,ext] = fileparts(rawdata);
   if length(theFile) < 7
      DepthFile = fullfile(thePath, [theFile,'.dat']);
   else
      DepthFile = fullfile(thePath, [theFile(1:7) '.dat']);
   end
end

[Dpath, Dname, dext]=fileparts(DepthFile);
Dfile=([Dname dext]);

%SURFACE InFile OutFile [Ensembles Skip Bin1 LastBin]
% Copy the ADCP file to a the RDI directory.
if length(dataname) < 7
   surfFile = [dataname ext];
else
   surfFile = [dataname(1:7) ext];
end
cpfile = fullfile(progPath,surfFile)

if isunix
		eval(['!cp ' rawdata ' ' cpfile])
	elseif any(findstr(lower(computer), 'pcwin')) | isVMS
		eval(['!copy ' rawdata ' ' cpfile])
	elseif any(findstr(lower(computer), 'mac')) & ...
			exist('aduplicate') == 2
		feval('aduplicate', rawdata, cpfile)
	else
		fcopy(rawdata, cpfile)
      
   end
   
%this all has to happen in the same directory as the surface program
	try
		eval(['cd ' progPath])
    catch
        disp(['RDI Surface.exe not in ' cd '.  Need to locate file.']); 
        [RDSurfaceFile, RDSurfacePath] = uigetfile(progPath, 'Select RDI Surface Program:');
        if ~any(RDSurfaceFile), return, end
        if RDSurfacePath(end) ~= filesep, RDSurfacePath(end+1) = filesep; end
        progPath = RDSurfacePath ;
 
      if progPath(end) ~= filesep, progPath(end+1) = filesep; end
      eval(['cd ' progPath]);
   end
   
disp('Running RDI surface program')   
eval(['!surface ' surfFile ' ' Dfile])
delete(cpfile)

datfile = ([Dname '.out']);
datfile = mfriend(Dfile,datfile);
surfdat=load(datfile);

%move some stuff around
%if ~isequal(Dpath,progPath)
	if isunix
		eval(['!mv ' Dfile ' ' DepthFile])
	elseif any(findstr(lower(computer), 'pcwin')) | isVMS
		eval(['!move ' Dfile ' ' DepthFile])
	elseif any(findstr(lower(computer), 'mac')) & ...
			exist('aduplicate') == 2
      feval('aduplicate', Dfile, DepthFile)
      delete(Dfile)
	else
		fcopy(Dfile,DepthFile)
      delete(Dfile)
   end
%end

%go back to where we were before
cd(s)

%these are 2 ways of finding the good data,
%the first is by the data quality given by rdi
[m,n] = size(surfdat);
qual = surfdat(:,7) > 2;
Dall = surfdat(:,6);

%if the records are not numbered sequentially or 
% the first ensemble in the raw data record does not start with 1 there
% will be problems.  Also problems when the fill values have been
% added to the rawcdf file for missing ensemble numbers
%To remedy this:
datrec = surfdat(:,1);

%First, check and fill missing ens if necessary
dr=diff(datrec);
ii=length(datrec);
if max(dr)>1
   iFill=find(dr>1);
   missEns=datrec(iFill)+1;
   
   [m,n]=size(surfdat);  %size of original file
   l=length(missEns); %number of missing ensembles
   newEns=1:m+l;  %number of original ens plus missing ens
   newTemp=ones(m+l,n)*nan;  %set size of new file 
 
   good_count=1;
   miss_count=1;
   
   for k=1:l+m
      % loop to fill in missing data columns
      if miss_count <= l % only do while we have records
         if newEns(k)==missEns(miss_count)  
           % newTemp(:,k)=fillV;
            newTemp(k,1)=newEns(k); % added to give ensemble number at head of column
            miss_count=miss_count+1;    
         end
      end
      % loop to fill in good data columns
      if good_count <= ii % only do while we have records
         if newEns(k)==datrec(good_count)
            newTemp(k,:)=surfdat(good_count,:);
            good_count=good_count+1; 
         end  
      end
   end
   
   surfdat = newTemp;
   qual = surfdat(:,7) > 2;
   Dall = surfdat(:,6);
   datrec = surfdat(:,1);
   
end %(if loop, filling in missing ens numbers)

%Now check to see what ens number the data starts and ends on
if ~isempty(ensembles)
	ens1 = find(datrec == ensembles(1));
	ens2 = find(datrec == ensembles(end));
else
   ens1 = datrec(1);
   ens2 = length(datrec);
end

idgood = ens1(1):ens2(end);
  
%Use just the depths for the ensembles we consider to be good
if ~isempty(idgood)
   qual = qual(idgood);
   Dall = Dall(idgood);
end

%need to preserve the depth in the same length variable for output
%However, also need the depth variable to operate on
Dout = Dall.*qual;
Dm = Dall(qual);

Davg=mean(Dm);
Dmin=min(Dm);
Dmax=max(Dm);
Dstd=std(Dm);
disp(['RDI surface program found the following depth constraints in meters: min = '...
   num2str(Dmin) ' max = ' num2str(Dmax) ' Mean = ' num2str(Davg)])
%are we really getting only the good data?
p=figure;, plot(Dm,'r.'), hold

%Depth_constraints.Are_these_depths_reasonable={'radiobutton',0}
%Depth_constraints.Minimum_depth_in_meters={num2str(Dmin)};
%Depth_constraints.Maximum_depth={num2str(Dmax)};
%Depth_constraints=uigetinfo(Depth_constraints);

prompt={'Minimum depth in meters:',...
   'Maximum depth in meters:','Are these depths reasonable?'};
title='Check surface program output';
lineNo=1;
DefAns={num2str(Dmin),num2str(Dmax),'N'};
dlgresult=inputdlg(prompt,title,lineNo,DefAns);
   
if ~isequal(Dmin,str2num(dlgresult{1})) | ~isequal(Dmax,str2num(dlgresult{2})) 
   Dmin=str2num(dlgresult{1});
   Dmax=str2num(dlgresult{2});
	idgood=find(Dm >= Dmin & Dm <= Dmax);
	clf, plot(Dm(idgood),'r.');,hold;
   
elseif upper(char(dlgresult{3}))=='N';       
      prompt={'Minimum depth allowed:',...
   'Maximum depth allowed:'};
   title='Input valid range for depth';
   lineNo=1;
   DefAns={num2str(Dmin),num2str(Dmax)};
   dlgresult=inputdlg(prompt,title,lineNo,DefAns);
   
   Dmin=str2num(dlgresult{1});
   Dmax=str2num(dlgresult{2});
	idgood=find(Dm >= Dmin & Dm <= Dmax);
   clf, plot(Dm(idgood),'r.');
   pause %added by SDR 6/27/05
else
   Dmin=str2num(dlgresult{1});
   Dmax=str2num(dlgresult{2});
   idgood=find(Dm >= Dmin & Dm <= Dmax);
end

if exist('idgood')
   Davg=mean(Dm(idgood));
	Dstd=std(Dm(idgood));
	Dm=Dm(idgood);
	disp(['User modified depth constraints in meters: min = '...
   	num2str(Dmin) ' max = ' num2str(Dmax) ' Mean = ' num2str(Davg)])
end

MSL=Davg+ADCP_offset;
disp(['ADCP measured ' num2str(MSL) ' m from surface to the seabed (mean sea level)']);
disp(['The tidal range is approximately ' num2str(Dstd) ' m']);
disp([' '])

pause(3)
close(p);
