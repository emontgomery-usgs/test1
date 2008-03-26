function omat = do_fan_rots(metaFile, fname)
% do_fan_rots.m  A function to process Imagenex fan  sonar data 
%
% usage:
%
%       where:  metaFile is the name of your text file containing metadata,
%                        surrounded by single quotes WITHOUT the file
%                        extension .txt. An example metadata file,
%                        sonarmetaexample.txt, is provided in this package of
%                        mfiles.
%                        ** currently assumes fan and pencil are processed 
%                           as separate steps
%               fanme is the netcdf file containintg the raw data.  The
%                         rootname will be used to create the name of the 
%                         processed file
%
% based on procsonar_07
% USGS Woods Hole Field Center
% emontgomery@usgs.gov
%
% Dependencies:
%   USGS NetCDF Toolbox (C. Denham)
%   plotfan07.m, plotpen07.m (E. Montgomery)
%   (6/07 the above files replaced showfan.m and showpen.m)
%   defineDonarNcFile.m  (E. Montgomery)
%
% 3/25/08 at CRS request, splitting procsonar into two parts: 1) make the
%         raw.cdf file and 2) apply rotations and what-have-you
% 11/1/07 fan and pencil do multiple sweeps, so plot* programs returns a matrix 
%         of images; subsequent processing and netcdf output modified to accommodate
% 11/1/07 added R for range for azimuth drive data to WhichSonar
%         possibilities
% 6/21/07 netcdf output for both fan and pencil, _raw & _proc works 
% 6/13/07 (readpencil & plotpencil07) to replace showpencil
% 6/1/07 creation of raw and processed netcdf files is implemented, but not perfect yet
% 5/31/07  (readfan & plotfan07) replace showfan07.  (showfan07 is still
%  there but commented out for validation purposes
% 5/23/07  modified to fun readfan- showfan07 will have to be modified to 
%    just plot, not read and plot
% 5/18/07 split out defineSonarNcFile so it would be easier to tweak
%  showpencilMM returns 3 arguments, so changed the call
% 5/7/07 modified to read showpencilMM
% etm 04/07
% This program just processes the fan and pencil data to images
% procsonar_apr07 must be run with ('penxxxmeta') to create the
% processed pencilbeam data then run with ('fanxxxmeta').  This creates
% fan_data.mat and pen_data.mat.
%
close all
more off

version = '1.0'; % Version updated by etm 3/08

% Check for metadata file
metaPath = pwd;
meta = dir([metaFile,'.txt']);
if isempty(meta)
   fprintf('\n')
   fprintf('The metadata file %s.txt does not exist in this directory\n',metaFile)
   metaPath = input('Please enter the full path to the directory with your metadata file:  ','s');
   meta = dir(fullfile(metaPath,[metaFile,'.txt']));
   if isempty(meta)
      error('Still cannot find the metadata file ',fullfile(metaPath,[metaFile,'.txt']))
   end
end
metaFile = fullfile(metaPath,meta.name);

% Get user's metadata structure
settings = readSonarMeta(metaFile);

% Check that the metadata contains required fields.  If a required field
% is missing, ask the user for it.
reqFields = {'RootDataDir',...
   'ADCPbin','SectorSweep','datayear',...
   'AngleSweepAround','StepSize','Height',...
   'SonartoAnimate','FillVal','dxy'};
for f = 1:length(reqFields)
   if ~isfield(settings,reqFields{f})
      disp(['The field ''',reqFields{f},''' is not specified in ',metaFile,'.txt'])
      missingFields(f) = 1;
   else
      missingFields(f) = 0;
   end
end
if any(missingFields)
   disp('Required fields missing from the metadata');
   % Default settings for Eurostrat first deployment 2002-2003
   settings.ADCPbin = '6';
   settings.FirstSonarDay = julian(2002,11,7,0);
   settings.LastSonarDay = julian(2002,12,8,0);
   settings.RootDataDir = 'C:\home\data\eutostrat\original_images\';
   settings.SonartoAnimate = 'Pencil';
   settings.SectorSweep = '132';
   settings.AngleSweepAround = '0';
   settings.StepSize = '1';
   settings.DataPoints = '500';  % number of 'ranges' recorded in each ping
   settings.Height = '1.06'; 
   settings.datayear = '2002';
   settings.FillVal = 1e35;
   settings.fanadcp_off = 0;
   settings.rot = '0';
   % fan beam specific things - this should be read from someplace!!!
    settings.dxy = 0.01;    % Key setting...determines image resolution at cost of
                            % speed (reasonable range 0.02 to 0.005)

   defaultSonarSettings = {settings.ADCPbin,...
      settings.FirstSonarDay,...
      settings.LastSonarDay,...
      settings.RootDataDir,...
      settings.SonartoAnimate,...
      settings.SectorSweep,...
      settings.AngleSweepAround,...
      settings.StepSize,...
      settings.DataPoints,...
      settings.Height,...
      settings.datayear,...
      settings.rot};
   prompt  = {'Enter the complete path to the currents netcdf file:',...
      'Enter the ADCP bin to use:',...
      'Enter the complete path to the waves netcdf file:',...
      'Enter the date of the first sonar image:',...
      'Enter the date of the last sonar image:',...
      'Enter the complete path to the sonar data directories:',...
      'Enter the sonar you would like to animate:',...
      'Enter the sector that was swept:',...
      'Enter the center to sweep around:',...
      'Enter the Step size used:',...
      'Enter the data points setting (points/10):',...
      'Enter the sonar''s height off the bottom, m:',...
      'Enter the year the instrument was deployed:',...
      'Enter the rotation angle to rotate the image to true N, deg:'};
   dlgtitle   = 'Sonar input metadata for the setup';
   lineNo  = 1;
   dlgresult  = inputdlg(prompt,dlgtitle,lineNo,defaultSonarSettings);
   settings.ADCPbin = str2num(dlgresult{2});
   settings.FirstSonarDay = str2num(dlgresult{4});  % number of 'ranges' recorded in each ping
   settings.LastSonarDay = str2num(dlgresult{5});
   settings.RootDataDir = str2num(dlgresult{6});
   settings.SonartoAnimate = str2num(dlgresult{7});
   settings.SectorSweep = str2num(dlgresult{8});
   settings.AngleSweepAround = str2num(dlgresult{9});
   settings.StepSize = str2num(dlgresult{10});
   settings.DataPoints = str2num(dlgresult{11});
   settings.Height = str2num(dlgresult{12});
   settings.datayear = str2num(dlgresult{13});
   settings.rot = str2num(dlgresult{14});
end
clear reqFields missingFields


clear FanTime PencilTime AzmTime
Fanidx = 1;
Pencilidx = 1;
Azmidx=1;
save settings settings;
    nc=netcdf(fname);
         omat=plotfan08(nc,'polar', settings);
            [timtim, npts, nscans]=size(nc{'imagedata'});
            %   
            % create the netcdf file      
            if Fanidx==1
               % now repeat for processed
               ofproc=[outFileRoot '_proc'];
               ncp = defineSonarNcFile(ofproc, settings, ncdims, 'p');
                 ncp.start_time = datestr(gregorian(FanTime(1)));
                    ncp=addHeaderMeta(ncp,FanHeader, FanSwitches);
                     ncp.NOTE =['radial data interpolated onto x-y grid to make image;',...
                         'image rotated so that +y (up) is N'];
                     ncp.NOTE1 = ['To view images in Matlab type the following at the command ',...
                      'prompt:  nc=netdcf(''sonarxxx.nc'');',...
                      'imagesc(nc{''x''}(:),nc{''y''}(:),squeeze(nc{''sonar_image''}(n,p,:,:)));',...
                      'set(gca,''ydir'',''rev''); **where n & p are the time and sweep indexes'];
                     ncp = write2procNcFile(ncp, Fanidx, FanTime(Fanidx), Xplot, Yplot, Zi);
            else
                ncr = write2rawNcFile(ncr, Fanidx, FanTime(Fanidx), FanData, FanHeader);
                ncp = write2procNcFile(ncp, Fanidx, FanTime(Fanidx), Xplot, Yplot, Zi);
            end

            Fanidx=Fanidx+1;
               % save fan_data.mat FanData FanTime 

            clear imagedata Xplot Yplot Zi
         elseif WhichSonar == 'P' && validFile == 1 && strcmpi(settings.SonartoAnimate,'pencil'),
            % first, display the sonar image
            PencilTime(Pencilidx) = julian([settings.datayear mon day hr mn 0]);
            settings.PencilTime = PencilTime(Pencilidx);
              fname=fullfile(settings.RootDataDir,SubDataDir(d).name,DataFiles(f).name)

           % replaced showpencil07 with (readpencil and plotPencil07
           [PenData, PenHeader, PenSwitches] = readpencil(fname);
           [cnv_img,hgt,max_retn, rval]=plotpen07(PenData,PenHeader,'polar', settings);
           % [PencilData(Pencilidx),FileSwitches]=showpen07(fname,settings);

             p=size(cnv_img.imi); 
           %figure(2);
            imfig = 2;
            imfile = sprintf('%s.png',outfile);
            %imfile = sprintf('p%03d.png',Pencilidx);
            
          % only need this if changing range settings around-
          % that only happens real-time, so ignoring at the moment
            % for pencil, X can be different lengths (if range setting changes, and y and z are
            % dependent on x, but we're going to make all the same length
          if (isempty(find(diff(PenHeader.Range)) ~= 0))
              xdst=cnv_img.x;
              ncnv=cnv_img;
              yelev=hgt;
              zss=max_retn;
          else
            xx=[-5.0:.0125:5.0];         % largest it could be
                 xdst=ones(1,length(xx))*settings.FillVal;
                 yelev=ones(length(xx),1)*settings.FillVal;
                 zss=ones(length(xx),1)*settings.FillVal;
                 ncnv.x=ones(length(xx),1)*settings.FillVal;
                 ncnv.y=ones(length(xx),1)*settings.FillVal;
                 ncnv.imi=ones(p(1),p(2),p(3))*settings.FillVal;
                 % intersect doesn't get all the points
                 % [st,ia,ib]=intersect(xx*,xint*);  
                 ixx=(1:length(xx))';
                 ia=fix(interp1(xx,ixx,cnv_img.x,'nearest'));
                 xdst(ia)=cnv_img.x;
                 %xdst=xx;
                 yelev(ia)=hgt;
                 zss(ia)=max_retn;
                 ib=fix(interp1(xx,ixx,cnv_img.x,'nearest'));                
                 ncnv.x(ib)=cnv_img.x;
                 ncnv.y=cnv_img.y;
                 ncnv.imi(:,ib)=cnv_img.imi;    %surrounding with 1e35 may not work well            
          end
          % create the netcdf file
             if Pencilidx==1
              %  initiaize NetCDF attributes 
            % now the processed
               %[q,p]=size(ncnv.imi);   % use the BIG size
               %ncdims.npoints=p; ncdims.nscans=q;
               p=size(ncnv.imi); 
               if (size(p)==2)
                    ncdims.npoints=p(2); ncdims.nscans=p(1);
               else
                    ncdims.npoints=p(3); ncdims.nscans=p(2);,ncdims.sweep=p(1);
               end
               ncp = defineSonarNcFile(ofproc, settings, ncdims,'p');
               ncp.start_time = datestr(gregorian(PencilTime(1)));
               ncp.vert_offset=settings.Pencil_tilt;
               hist = ncp.history(:);
               hist_new = ['Sonar data written to NetCDF by procsonar07.m V ',version,...
                '; ',hist];
               ncp.history = hist_new;
               %  don't know why, but the flipud is needed here
               ncp.NOTE = ['Pencil data has the extracted x and y data, with',...
                        'zi containing the strength of the max reflection defining yelev'];
                % ncp = write2procNcFile(ncp, Pencilidx, PencilTime(Pencilidx), xint, hgt, max_retn, cnv_img);
               ncp = write2procNcFile(ncp, Pencilidx, PencilTime(Pencilidx), xdst, yelev, zss, ncnv, rval);
             else
                ncr = write2rawNcFile(ncr, Pencilidx, PencilTime(Pencilidx),PenData, PenHeader);
                ncp = write2procNcFile(ncp, Pencilidx, PencilTime(Pencilidx), xdst, yelev, zss, ncnv, rval);
            end
            Pencilidx = Pencilidx+1;
            clear outfile imfile
         % now add a section to do the Azimut drive data
         elseif WhichSonar == 'A' && validFile == 1 && strcmpi(settings.SonartoAnimate,'azm'),
            % first, display the sonar image
            AzmTime(Azmidx) = julian([settings.datayear mon day hr mn 0]);
            settings.AzmTime = AzmTime(Azmidx);
              fname=fullfile(settings.RootDataDir,SubDataDir(d).name,DataFiles(f).name)

           % replaced showpencil07 with (readpencil and plotPencil07
           mkplt='n';
           [AzmData, AzmHeader, AzmSwitches] = readrangeall(fname, mkplt);
           %[cnv_img,xint,hgt,max_retn, rval]=plotrange(AzmData,AzmHeader,'polar', settings);

       %      p=size(cnv_img.imi); 
       %     imfig = 2;
       %     imfile = sprintf('%s.png',outfile);
            
       %   % only need this if changing range settings around-
       %   % that only happens real-time, so ignoring at the moment
       %     % for pencil, X can be different lengths (if range setting changes, and y and z are
       %     % dependent on x, but we're going to make all the same length
       %   if (isempty(find(diff(AzmHeader.Range)) ~= 0))
       %       xdst=xint;
       %       ncnv=cnv_img;
       %       yelev=hgt;
       %       zss=max_retn;
       %   else
       %     xx=[-5.0:.0125:5.0];         % largest it could be
       %          xdst=ones(1,length(xx))*settings.FillVal;
       %          yelev=ones(length(xx),1)*settings.FillVal;
       %          zss=ones(length(xx),1)*settings.FillVal;
       %          ncnv.x=ones(length(xx),1)*settings.FillVal;
       %         ncnv.y=ones(length(xx),1)*settings.FillVal;
       %          ncnv.imi=ones(p(1),p(2),p(3))*settings.FillVal;
       %          % intersect doesn't get all the points
       %          % [st,ia,ib]=intersect(xx*,xint*);  
       %          ixx=(1:length(xx))';
       %          ia=fix(interp1(xx,ixx,xint,'nearest'));
       %          xdst(ia)=xint;
       %          %xdst=xx;
       %          yelev(ia)=hgt;
       %          zss(ia)=max_retn;
       %          ib=fix(interp1(xx,ixx,cnv_img.x,'nearest'));                
       %          ncnv.x(ib)=cnv_img.x;
       %          ncnv.y=cnv_img.y;
       %          ncnv.imi(:,ib)=cnv_img.imi;    %surrounding with 1e35 may not work well            
       %   end
          % create the netcdf file
             if Azmidx==1
              %  initiaize NetCDF attributes 
              [nrts,npts,nscans]=size(AzmData.imagedata);   % doesn't change size
               ncdims.rots=nrts; ncdims.npoints=npts; ncdims.nscans=nscans;
               ofraw=[outFileRoot '_raw'];
      %         ofproc=[outFileRoot '_proc'];
               % first do the raw
               ncr = defineSonarNcFile(ofraw, settings, ncdims,'r');
               ncr.start_time = datestr(gregorian(AzmTime(1)));
               hist = ncr.history(:);
               hist_new = ['Sonar data written to NetCDF by procsonar07.m V ',version,...
                '; ',hist];
               ncr.history = hist_new;
               %  don't know why, but the flipud is needed here
               ncr.NOTE = ['Azm data']
                ncr = write2rawNcFile(ncr, Azmidx, AzmTime(Azmidx), AzmData, AzmHeader);
               old_sonardate=datenum_sonar;
      %      % now the processed
      %         %[q,p]=size(ncnv.imi);   % use the BIG size
      %         %ncdims.npoints=p; ncdims.nscans=q;
      %         p=size(ncnv.imi); 
      %         if (size(p)==2)
      %              ncdims.npoints=p(2); ncdims.nscans=p(1);
      %         else
      %              ncdims.npoints=p(3); ncdims.nscans=p(2);,ncdims.sweep=p(1);
      %         end
      %         ncp = defineSonarNcFile(ofproc, settings, ncdims,'p');
      %         ncp.start_time = datestr(gregorian(AzmTime(1)));
      %         ncp.vert_offset=settings.Azm_tilt;
      %         hist = ncp.history(:);
      %        hist_new = ['Sonar data written to NetCDF by procsonar07.m V ',version,...
      %          '; ',hist];
      %         ncp.history = hist_new;
      %         %  don't know why, but the flipud is needed here
      %         ncp.NOTE = ['Azm data has the extracted x and y data, with',...
      %                  'zi containing the strength of the max reflection defining yelev'];
      %          % ncp = write2procNcFile(ncp, Azmidx, AzmTime(Azmidx), xint, hgt, max_retn, cnv_img);
      %         ncp = write2procNcFile(ncp, Azmidx, AzmTime(Azmidx), xdst, yelev, zss, ncnv, rval);
             else
                ncr = write2rawNcFile(ncr, Azmidx, AzmTime(Azmidx),AzmData, AzmHeader);
      %          ncp = write2procNcFile(ncp, Azmidx, AzmTime(Azmidx), xdst, yelev, zss, ncnv, rval);
             end
            if floor(datenum_sonar)==floor(old_sonardate);
              %these files bomb if get too big, so forcing to be smaller.            clear outfile AzmData AzmHeader AzmSwitches
              clear outfile AzmData AzmHeader AzmSwitches
              Azmidx=Azmidx+1
            else
                %close existing .ncfile
                ncr.stop_time = datestr(gregorian(AzmTime(end)))
                ncr.DELTA_T = [num2str(gmean(diff(AzmTime*1000))*60),' sec'];
                close(ncr);
                % make it so there'll be a new file with date as part of it
                  outFileRoot = ['az',datestr(datenum_sonar,29)];
                  Azmidx=1;
            end                
                old_sonardate = datenum_sonar;
       end
       end
   end
end

% this is where the data is saved
%  writing to netCDF doesn't work, but you get a .mat file for each fan and
%  Pencil run
if strcmpi(settings.SonartoAnimate,'fan'),
    save fan_data.mat FanData FanTime FanHeader
       ncr.stop_time = datestr(gregorian(FanTime(end)))
       ncr.DELTA_T = [num2str(gmean(diff(FanTime*1000))*60),' sec'];
        close(ncr);
       ncp.stop_time = datestr(gregorian(FanTime(end)))
       ncp.DELTA_T = [num2str(gmean(diff(FanTime*1000))*60),' sec'];
        close(ncp);
       ncclose;
elseif strcmpi(settings.SonartoAnimate,'pencil'),
   % KLUDGE Alert - should write a netCDF file here
   save pen_data.mat PencilTime PenData PenHeader
       ncr.stop_time = datestr(gregorian(PencilTime(end)))
       ncr.DELTA_T = [num2str(gmean(diff(PencilTime*1000))*60),' sec'];
        close(ncr);
       ncp.stop_time = datestr(gregorian(PencilTime(end)))
       ncp.DELTA_T = [num2str(gmean(diff(PencilTime*1000))*60),' sec'];
        close(ncp);
       ncclose;
elseif strcmpi(settings.SonartoAnimate,'Azm'),
   save azm_data.mat AzmTime AzmData AzmHeader
       ncr.stop_time = datestr(gregorian(AzmTime(end)))
       ncr.DELTA_T = [num2str(gmean(diff(AzmTime*1000))*60),' sec'];
        close(ncr);
      % ncp.stop_time = datestr(gregorian(AzmTime(end)))
      % ncp.DELTA_T = [num2str(gmean(diff(AzmTime*1000))*60),' sec'];
      %  close(ncp);
       ncclose;
end

% ---------------- Subfunction: readSonarMeta.m ------------------------- %
function userMeta = readSonarMeta(metaFile);
[atts, defs] = textread(metaFile,'%s %63c','commentstyle','shell');
defs = cellstr(defs);
for i = 1:length(atts)
   theAtt = atts{i}(:)';
   theDef = defs{i}(:)';
   % deblank removes trailing whitespace
   theAtt = deblank(theAtt);
   theDef = deblank(theDef);
   % check for and replace spaces in
   % the attributes with underscores
   f1 = find(isspace(theAtt));
   f2 = strfind(theAtt,'-');
   f = union(f1,f2);
   if ~isempty(f)
      theAtt(f) = '_';
   end
   % attribute definitions read in as characters; convert to
   % numbers where appropriate
   theDefNum = str2double(theDef);
   if ~isnan(theDefNum)
      theDef = theDefNum;
   end
   eval(['userMeta.',theAtt,'= theDef;'])
end

% ---------------- Subfunction:  getSonarYear.m ------------------------- %
function [yyyy] = getSonarYear(DirName, FirstSonarDay, LastSonarDay);

first = datevec(FirstSonarDay);
first_yyyy = first(1);
first_mm = first(2);
first_dd = first(3);

last = datevec(LastSonarDay);
last_yyyy = last(1);
last_mm = last(2);
last_dd = last(3);

mm = str2num(DirName(2:3));
dd = str2num(DirName(4:5));

if (mm >= first_mm)
   yyyy = num2str(first_yyyy);
else
   yyyy = num2str(last_yyyy);
end

% ---------------- Subfunction:  checkSonarFile.m ----------------- %
function [WhichSonar, validFile] = checkSonarFile(sonarFileName);

F = dir(sonarFileName); % FAN files only!
filesize = F.bytes;
if strcmp(F.name(10),'F') && filesize <= 5000
   disp(['### The Fan file ',sonarFileName, ' is a dud file and will not be used in animations'])
   WhichSonar = 'F';
   validFile = 0;
elseif strcmp(F.name(10),'F') && filesize > 5000
   WhichSonar = 'F';
   validFile = 1;
elseif strcmp(F.name(10),'P') && filesize > 100
   WhichSonar = 'P';
   validFile = 1;
elseif strcmp(F.name(10),'R') && filesize > 100
   WhichSonar = 'A';
   validFile = 1;
else
   validFile = 0;
end
% ---------------- Subfunction:  addHeaderMeta.m -------------------- %
function nc =addHeaderMeta(nc, header, switches);
     % update the history
     hist = nc.history(:);
     hist_new = ['Sonar data written to NetCDF by procsonarMM.m V ',version,...
     '; ',hist];
     nc.history = hist_new;
     % add everythin from the switches to the global attributs
     nc.HeadID=switches.HeadID;
     nc.Range=switches.Range;
     nc.RangeOffset=switches.RangeOffset;
     nc.RevHold=ncchar(switches.RevHold);
     nc.MasterSlave=ncchar(switches.MasterSlave);
     nc.StartGain=switches.StartGain;
     nc.LOGF=switches.LOGF;
     nc.Absorption=switches.Absorption;
     nc.TrainAngle=switches.TrainAngle;
     nc.SectorWidth=switches.SectorWidth;
     nc.StepSize=switches.StepSize;
     nc.PulseLength=switches.PulseLength;
     nc.StepDirection=switches.StepDirection;
     nc.MoveRelative=switches.MoveRelative;
     nc.StepSize=header.StepSize;
     nc.DataPoints=switches.DataPoints;
     nc.DataBits=switches.DataBits;
     nc.UpBaud=switches.UpBaud;
     nc.Profile=ncchar(switches.Profile);
     nc.Calibrate=ncchar(switches.Calibrate);
     nc.SwitchDelay=switches.SwitchDelay;
     % and some from the first scan header that don't change
     cc=char(header.ReturnDataHeaderType{1});
     nc.HeadType=ncchar(cc);
     nc.NDataBytes=header.NDataBytes(1);
     nc.NReturnBytes=header.NReturnBytes(1);
     
% ---------------- Subfunction:  write2rawNcFile.m -------------------- %
function nc = write2rawNcFile(nc, idx, timeWrd, data, header);
 % treat fan and pencil the same.

 % timeWrd is in decimal days, so have to convert .604 days to msecs
   nc{'time'}(idx) = floor(timeWrd);
   nc{'time2'}(idx) = mod(timeWrd,floor(timeWrd))*1000*3600*24;
   nn=size(data.imagedata);
   if length(nn)==2
      [npoints,nscans]=size(data.imagedata);
   else
       [nrot,npoints,nscans]=size(data.imagedata);
   end
   if idx ==1
       nc{'points'}(1:npoints)=[1:1:npoints];
       nc{'scan'}(1:nscans)=[1:1:nscans];
       if length(nn) == 3
          nc{'rots'}(1:nrot)=[1:1:nrot];
       end  
   end
   if length(nn) == 2
     nc{'headangle'}(idx,1:nscans) = header.HeadAngle;
     nc{'head_pos'}(idx,1:nscans) = header.HeadPosition;
     nc{'profile_range'}(idx,1:nscans) = header.ProfileRange;
     nc{'nDataBytes'}(idx,1:nscans) = header.NDataBytes;
     nc{'raw_image'}(idx,1:npoints,1:nscans) = data.imagedata;
   elseif length(nn) == 3
     nc{'headangle'}(idx,1:nrot,1:npoints-1) = header.HeadAngle;
     nc{'profile_range'}(idx,1:nrot,1:npoints-1) = header.ProfileRange;
     nc{'azangle'}(idx,1:nrot) = header.AAngle;
     nc{'raw_image'}(idx,1:nrot,1:npoints,1:nscans) = data.imagedata;
   end
   
  clear alltime timeWrd

% ---------------- Subfunction:  write2procNcFile.m -------------------- %
function nc = write2procNcFile(nc, idx, timeWrd, Xplot, Yplot, Zi, img, rawV);

 [f,g]=size(Zi)
% timeWrd is in decimal days, so have to convert .604 days to msecs
   nc{'time'}(idx) = floor(timeWrd);
   nc{'time2'}(idx) = mod(timeWrd,floor(timeWrd))*1000*3600*24;
   
if (nargin ==6)
    nx=length(Xplot);  ny=length(Yplot);
    ns=length(Zi);
 if idx == 1 
   nc{'y'}(1:ny) = Yplot;
   nc{'x'}(1:nx) = Xplot;
   nc{'sweep'}(1:ns) = [1:1:length(Zi)];
 end
   for ii=1:length(Zi)  % ii is the number of sweeps 
       tmp=Zi{ii};
       nc{'sonar_image'}(idx,ii,1:ny,1:nx) = round(tmp.*1000); %apply scale factor
   end
else     % pencil
    nr=length(img.x);  nq=length(img.y);
  if idx == 1 
   % x and y are for scaling the sonar_image
   nc{'x'}(1:nr) = img.x;    
   nc{'z'}(1:nq) = img.y;
   nc{'sweep'}(1:f) = [1:1:f];
  end
   nl=length(Xplot); nm=length(Yplot);
   % hdst is "x" for elev, and max_retn
   %nc{'hdst'}(idx,1:nl) = Xplot;
   %nc{'elev'}(idx,1:nl) = Yplot;
   %nc{'max_ret'}(idx,1:nl) = Zi;
      nc{'hdst'}(idx,1,1:nl) = Xplot(1,:);
   for ii=1:f  % ii is the number of sweeps 
      nc{'elev'}(idx,ii,1:nm) = Yplot(ii,:);
      nc{'max_ret'}(idx,ii,1:nq,1:nr) = Zi(ii,:); %apply scale factor
      nc{'sonar_image'}(idx,ii,1:nq,1:nr)=img.imi(ii,:,:);
   end
   nc{'rdst'}(idx,1:length(rawV.dist)) = rawV.dist;
   nc{'relev'}(idx,1:length(rawV.dist)) = rawV.elev;
end
  clear alltime timeWrd
% this command works to plot fan beam imaged:
%  pcolor(nc{'xcoord'}(:),nc{'ycoord'}(:),nc{'sonar_image'}(1,:,:));
%  shading flat
% or
%  imagesc(nc{'xcoord'}(:),nc{'ycoord'}(:),rot90(nc{'sonar_image'}(1,:,:)'));
%  shading flat
% not sure why you HAVE to rot90, but you do.  Or when opening the .nc file
% directly, it looks like flipud is necessary.


