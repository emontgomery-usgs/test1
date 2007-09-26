function cur = runbm2g(BeamFile, ADCPtype, dlgFile, theElevations, ...
   theAzimuths, theHeading, thePitch, theRoll, ...
   theOrientation, theBlankingDistance)

%function cur = runbm2g(BeamFile, ADCPtype, dlgFile, theElevations, ...
%   theAzimuths, theHeading, thePitch, theRoll, ...
%   theOrientation, theBlankingDistance)
%This program gathers the information and reformats the structure of 
%the data to prepare for the transformation from beam to earth coordinates.
%After gathering this information the runbm2g.m calls bm2geo.m to 
%convert the data into geographic coordinates ensemble by ensemble.  
%
%Inputs:
%	BeamFile = the ADcp data file in beam coordinates 
%		(Note:if running routines in sequence it should be the trimFile.)%	ADCPtype = WH or BB; will default to WH if not specified
%	ADCPtype = WH or BB; will default to WH if not specified
%		WH = workhorse, BB = broad band
%		note: if BB, do not need a dlgFile
%	dlgFile = the deployment log file that was created when the ADCP was "deployed"
%If the names of the files are not given, they will be requested.
%
%The following inputs are optional and if not given, they will be 
%obtained from the data files provided
%		theElevations, theAzimuths = the beam configuration
%		theHeading, thePitch, theRoll = are from collected data
%		theOrientation = 'up' or 'down' (looks for 'orientation' global 
%			attribute then assumes 'up' if empty)
%		theBlankingDistance = WF from the command file
%
% Output:
%	 cur = velocities transformed into earth coordinates
%
% This is work in progress and since this operation is time intensive
% cur.mat is also saved to the desktop in the current directory.  
% cur.mat can be loaded into adcp2ep.m if something happens.


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
%	bm2geo.m

% Written by Jessica M. Cote
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to jcote@usgs.gov

% version 1.0
% updated 12-feb-2007 check for dialog file rather than just bombing
% updated 28-Dec-2000 added line feeds to comment/history attribute (ALR)
% updated 10-Dec-1999 10:52:22
% updated 18-Oct-1999 16:35:41

%tell us what function is running
Mname=mfilename;
disp('')
disp([ Mname ' is currently running']);


if nargin < 1, help(mfilename), BeamFile='';, end
if nargin < 2, ADCPtype ='';, end
if nargin < 3, dlgFile='';, end

if isempty(BeamFile), BeamFile = '*';, end
if isempty(ADCPtype), ADCPtype = 'WH';, end
if isempty(dlgFile), dlgFile = '*';, end

if ~exist(dlgFile,'file'), dlgFile = '*'; end

% Open ADCP beam file.
if any(BeamFile == '*')
	[theFile, thePath] = uigetfile(BeamFile, 'Select ADCP File in Beam coordinates:');
	if ~any(theFile), return, end
	if thePath(end) ~= filesep, thePath(end+1) = filesep; end
	BeamFile = [thePath theFile];
end

ADCPtype = upper(ADCPtype);
if isequal(ADCPtype, 'WH')
	% Find *.dlg file.
	if any(dlgFile == '*')
		[theFile, thePath] = uigetfile('*.dlg', 'Select ADCP Deployment Log File:');
		if ~any(theFile), return, end
		if thePath(end) ~= filesep, thePath(end+1) = filesep; end
		dlgFile = [thePath theFile];
	end

	%Let's pull the Elevations and azimuths out of the *.dlg file
	if nargin < 4
		theBeams=zeros(4,1);
		theElevations=zeros(4,1);
		theAzimuths=zeros(4,1);

		dlg=fopen(dlgFile);
		disp(['Obtaining Beam configuration information from ' dlgFile])
	while 1
		line=fgetl(dlg);
      s=findstr(line,'Beam Width:');
      if ~isempty(s)
         width=line;
         disp(line)
      end
      
      names=findstr(line,'Elevation');
      if ~isempty(names)
         for ii=1:4;
            line=fgetl(dlg);
            theBeams(ii)=str2num(line(3));
         	theElevations(ii)=str2num(line(13:20));
   			theAzimuths(ii)=str2num(line(23:30));
         end
      break, end  
   end
	fclose(dlg);
	end
else
   %for broad band (BB) has a perfect beam configuration
   theElevations = [-70 -70 -70 -70]
	theAzimuths = [270 90 0 180]
end %if ADCPtype


if nargin < 6
   B=netcdf(BeamFile)
   if isempty(B), return, end
   theHeading=B{'Hdg'}(:);
   thePitch=B{'Ptch'}(:);
   theRoll=B{'Roll'}(:);  
   theOrientation = lower(B.orientation(:));
      %trap for empty orientation by FSH, 3 Nov 1999
   if (isempty(B.orientation(:)))
      theOrientation = 'up'
   end

end

if nargin < 9   
   %theOrientation = '';
   theBlankingDistance = B{'D'}.blanking_distance(:);
end

%get some information
theFillValue = fillval(B{'vel1'});
bin = size(B('bin'),1);
ensemble = size(B('ensemble'),1);


%get the velocity data and set the new velocity variable
for ii = 1:4;
   vel{ii} = B{['vel' int2str(ii)]};   % Input ADCP velocities.
end

cur = cell(size(vel));   % Output currents and error.
q = zeros(4, bin);

tic
for ii=1:ensemble
	for k = 1:4
  	 p(k, :) = vel{k}(ii, :);	
	end
	p(p == theFillValue) = nan;
   
%convert from beam to geo, note the transposes!
q = bm2geo(p.', theElevations, theAzimuths, theHeading(ii), thePitch(ii), theRoll(ii), theOrientation, theBlankingDistance).';
   if ~rem(ii,100), 
      disp(sprintf('%d ensembles converted in %d min',ii,toc/60)), 
   end

q(isnan(q)) = theFillValue;
   for k = 1:4
			cur{k}(ii, :) = q(k, :);
   end
   
end

save cur.mat cur

close(B)

thecomment = sprintf('%s\n','Transformed to earth coordinates by runbm2g.m');
history(BeamFile,thecomment);
