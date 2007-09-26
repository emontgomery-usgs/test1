function theResult  = tilttrim(trimFile, MSL, Dstd, ADCPtype, dlgFile, theElevations, ...
    theAzimuths, thePitch, theRoll, theOrientation)

% function theResult  = tilttrim(trimFile, MSL, Dstd, ADCPtype, dlgFile, theElevations, ...
%    theAzimuths, thePitch, theRoll, theOrientation)
%
%Modifies the data file so the bins all fall below mean sea level(MSL) plus 
%the tidal range using a MSL provided by the pressure sensor, RDsurface.m, 
%a Matlab function that runs the Dos version of the RDI surface program,
%or user input.
%If no iput values are given it will prompt the user for method of
%trimming the bins by using a pressure sensor, RDsurface.m, or user input.
%
%   NOTE:  This should only be used if instrument is recorded in BEAM
%   coordinates, and was severely tilted during the deployment.
%
%   Program determines which bins are above (MSL + Dstd) for each beam in
%   each ensemble by performing a series of rotations to the beam file.  It
%   then fills the vel(x) vector of the netCDF file with the FillValue_ if
%   the above is statement is true.  Then checks for last good bin where
%   any three beams do not have a FillValue_ and removes the bins above
%   that from the data file.
% 
% Inputs:
%     trimFile = the ADCP data file in beam coordinates
%         (note: if running routines in sequence it should be the trimFile)
%     MSL = Mean sea level of the ADCP in meters; if not provided user will be ...
%           prompted for information
%     Dstd = half the tidal range, or the stadard deviation of the MSL, if
%           not provided, user will be prompted for information
%     ADCPtype = WH or BB; will default to WH if not specified
%     dlgFile = the deployment log file that was created when the ADCP was "deployed"
%         If the names of the files are not given, they will be requested
%         
%
%
% Written by Stephen Ruane
% for the U.S. Geological Survey
% Coastal and Marine Geology Program
% Woods Hole, MA
% http://woodshole.er.usgs.gov/
% Please report bugs to sruane@usgs.gov
% March 17, 2005


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

 


%% Variable Definitions
%tell us what function is running
Mname=mfilename;
disp('')
disp([ Mname ' is currently running']);

if nargin < 1, help(mfilename), trimFile='';, end


if nargin < 2, MSL='';, end
if nargin < 3, Dstd='';, end

if isempty(MSL), MSL = '*';, end
if isempty(Dstd), Dstd = '*';, end

    
    
if nargin < 4, ADCPtype='';, end
if nargin < 5, dlgFile='';, end

if isempty(trimFile), trimFile = '*';, end
if isempty(ADCPtype), ADCPtype = 'WH';, end
if isempty(dlgFile), dlgFile = '*';, end

% Open ADCP beam file
if any(trimFile == '*')
    [theFile, thePath] = uigetfile(trimFile, 'Select ADCP File in Beam coordinates:');
    if ~any(theFile), return, end
    if thePath(end) ~= filesep, thePath(end+1) = filesep; end
    trimFile = [thePath theFile];
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
    
    %Pull the elevations and azimuths out of the *.dlg file
    if nargin <6
        theBeams=zeros(4,1);
        theElevations=zeros(4,1);
        theAzimuths=zeros(4,1);
        
        dlg=fopen(dlgFile);
        disp(['Obtaining Beam configuration information from ' dlgFile])
        while 1
            line = fgetl(dlg);
            s=findstr(line,'Beam Width:');
            if ~isempty(s)
                width=line;
                disp(line)
            end
            
            names=findstr(line,'Elevation');
            if ~isempty(names)
                for ii=1:4
                    line=fgetl(dlg);
                    theBeams(ii)=str2num(line(3));
                    theElevations(ii)=str2num(line(13:20));
                    theAzimuths(ii)=str2num(line(23:30));
                end
             break,end
        end
        fclose(dlg);
    end
else
    %for BB has a perfect beam configuration
    theElevations = [-70 -70 -70 -70]
    theAzimuths = [290 90 0 180]
end %if ADCPtype



if nargin < 8
    B=netcdf(trimFile,'write');   
    if isempty(B), return, end
    thePitch=B{'Ptch'}(:);
    theRoll=B{'Roll'}(:);
    theOrientation = lower(B.orientation(:));
        if (isempty(B.orientation(:)))
            theOrientation = 'up'
        end
end

if nargin < 10
    theOrientation = lower(B.orientation(:));
        if (isempty(B.orientation(:)))
            theOrientation = 'up'
        end
end

if any(MSL == '*')
    
    buttonname = questdlg('What method to trim the bins?','trimbins','Pressure Sensor','RDI Surface Program','User Input','RDI Surface Program')
   
    switch buttonname
    
    case 'Pressure Sensor'
        
        [MSL,Dstd,Dsurf]=pressurecalcs(trimFile);
        %to append to history later
        thecomment=sprintf('%s\n','Bins were trimed by tilttrim.m based on depth sensor input information.');
        
    case 'RDI Surface Program'
                
        [MSL,Dstd,Dsurf] = rdsurface(numRawFile,rawdata1,rawdata2,ADCP_offset,ensembles,progPath);
		%to append history later
        thecomment=sprintf('%s\n','Bins were trimmed by tilttrim.m using 94% of the RDI surface output.');
    
    case 'User Input'
        
        disp('User must input the water depth information')
	           Depth_Information.mean_sea_level.value = {0};
   	        Depth_Information.mean_sea_level.units = {'meters'};
      	     Depth_Information.half_the_tidal_range.value = {0};
         	  Depth_Information.half_the_tidal_range.units = {'meters'};
	           Depth_Information = uigetinfo(Depth_Information');	
           
   	        %check units
      	     infoD = getinfo(Depth_Information,'mean_sea_level');
              unitD = getinfo(infoD,'units');
         	  infoT = getinfo(Depth_Information,'half_the_tidal_range');
              unitT = getinfo(infoT,'units');
              
           
	           	if ~isequal(unitD,'meters') | ~isequal(unitT,'meters')
            	  	disp('User error!! Depth Information must be in meters')
              		pause(3)
                    Depth_Information = uigetinfo(Depth_Information)
               end
           
         	  	infoMSL = getinfo(Depth_Information,'mean_sea_level');
                MSL = getinfo(infoMSL,'value');
           		infoDstd = getinfo(Depth_Information,'half_the_tidal_range');
                Dstd = getinfo(infoDstd,'value');
        Dsurf=[ ];
        %to append history later
         thecomment=sprintf('%s\n','Bins were trimmed by tilttrim.m based on user input depth information.');

end %button switch

 %if MSL and Dstd are already provided, check to see if they came from
    %   the pressure sensor or user input
%     else 
%         switch pressuresensor
%         case 'YES'
%             disp('Depth sensor input water_depth and tidal variation')
%             Dsurf=Dout;
%             %to append to history later
%             thecomment=sprintf('%s\n','Bins were trimed by trimbins.m based on depth sensor input information.');
%         case 'NO'  
%             
%             disp('User input water_depth and tidal variation')
%             Dsurf=[ ];
%             %to append history later
%             thecomment=sprintf('%s\n','Bins were trimmed by trimBins.m based on user input depth information.');
%     end %pressuresensor switch
end

% Gather some information
bins = B('bin');
binend = bins(:);
ensembleend = size(B('ensemble'),1);
offset=B{'D'}.xducer_offset_from_bottom(:);
bin1=B{'D'}.center_first_bin(:);
binsize=B{'D'}.bin_size(:);
fillvalue = B{'vel1'}.FillValue_(:);



%% Depth Cell Determination
% determines which bins are above the water depth and fills them with the
% fill_value in each beam for each ensemble
h = waitbar(0,'Modifying trimFile(this may take a while)...');
begin = datestr(now, 0);
for enscnt = 2:ensembleend 
    
    thePitch=B{'Ptch'}(enscnt);
    theRoll=B{'Roll'}(enscnt);

% Modify the pitch measurement for actual RDI scheme.
% See reference page 14.

RCF = 180/pi;
k_factor = sqrt(1 - (sin(thePitch/RCF)*sin(theRoll/RCF))^2);
thePitch=asin(sin(thePitch/RCF)*cos(theRoll/RCF)/k_factor)*RCF;

% Adjustments for down/up orientation

switch lower(theOrientation)
    case 'down'
        %theRoll = -theRoll;
        disp('Bins cannot be trimmed because of ADCP orientation');
    case 'up'
        theElevations = -theElevations;
        theAzimuths = -theAzimuths;
 end

theBeamDirections = zeros(4,3);

for i = 1:4
    x = 0;
    y = 1;
    z = 0;
    [y, z] = rot1(y, z, theElevations(i));
    [y, x] = rot1(y, x, theAzimuths(i));
    [z, x] = rot1(z, x, theRoll);
    [y, z] = rot1(y, z, thePitch);
    theBeamDirections(i,:) = [x y z];
end


% Depth-bins scaled for 20 or 30 degree nominal beam-angle,
% based on the z-component of the beam-direction matrix.
% See reference page 8.
if mean(abs(theElevations)) < 65
    s = sin(70 ./ RCF);
else
    s = sin(60 ./ RCF);
end

depth_scale = (theBeamDirections(:, 3) ./ s).';  %z-component
depth_bins = (1:binsize:(binend*binsize)+binsize).'*abs(depth_scale);  
real_depth_bins = depth_bins+offset;  %adjust for transduser height

% Compare bin depths with determined water depth and input fillvalue for bin
% depths that exceed calculated water depth

for beam = 1:4
     for bincount = 1:binend-1
        if real_depth_bins(bincount, beam) > (1/abs(depth_scale(beam)))*(MSL+Dstd)
             B{['vel' int2str(beam)]}(enscnt, bincount) = fillvalue;
        end
    end   %bincount loop
    
end %beam loop

% if ~rem(enscnt,100),
%     disp(sprintf('%d ensembles formatted in %d sec',enscnt,toc)),
% end
waitbar(enscnt/ensembleend,h,[num2str(enscnt),' ensembles formatted...'])
end % ensemble loop


%% Last Good Bin Analysis

% Determine which bins to trim based on last good bin with 3-beam solution
% Start count from top bin and then mark which is the last bin to be
% removed
for bincount = binend:-1:1 
    beam1bins = any(B{'vel1'}(:,bincount) == fillvalue);
    beam2bins = any(B{'vel2'}(:,bincount) == fillvalue);
    beam3bins = any(B{'vel3'}(:,bincount) == fillvalue);
    beam4bins = any(B{'vel4'}(:,bincount) == fillvalue);
    
    if (sum(beam1bins) & sum(beam2bins) & sum(beam3bins))|(sum(beam1bins)...
            & sum(beam2bins) & sum(beam4bins))|(sum(beam1bins) & ...
            sum(beam3bins) & sum(beam4bins)) | (sum(beam2bins) & ...
            sum(beam3bins) & sum(beam4bins)) > .9*ensembleend
        last_good_bin = bincount;
    end
        
end %bincount loop




% Now we have to determine the good bins

goodBins = 1:last_good_bin;
bins = resize(bins,length(goodBins));

%and define a new variables
if ~isempty(Dsurf)
	B{'height'} = ncfloat('ensemble') 
	B{'height'}.long_name = ncchar('height of sea surface from transducer head');
	B{'height'}.units = ncchar('m');
	B{'height'}.FillValue_ = 1.0e35;
	endef(B)

	B{'height'}(1:ensembleend) = Dsurf;
end

close(B)
finish = datestr(now,0);    
%Done
disp(' ')
disp(['File ' trimFile ' has been modified'])
disp(['## ' num2str(binend-last_good_bin) ' bins were removed from the top of the water column'])
disp(['Program started: ' begin])
disp(['Progam finished: ' finish])
history(trimFile,thecomment);

theResult = trimFile;



