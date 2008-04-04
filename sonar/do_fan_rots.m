function ncp = do_fan_rots(metaFile, fname)
% do_fan_rots.m  A function to process Imagenex fan sonar data from the raw
% netCDF file.  Replaces sexond part of procsonar_07 where showfan is
% called
%
% usage:
%   where:  metaFile is the name of your text file containing metadata,
%                    surrounded by single quotes WITHOUT the file
%                    extension .txt. An example metadata file,
%                    sonarmetaexample.txt, is provided in this package of
%                    mfiles.
%                    ** currently assumes fan and pencil are processed 
%                       as separate steps
%           fname is the netcdf file containintg the raw data.  The
%                     rootname will be used to create the name of the 
%                     processed file
%           ncp is the netcdf file containing the processed images 
%
% based on procsonar_07
% USGS Woods Hole Field Center
% emontgomery@usgs.gov
%
% Dependencies:
%   USGS NetCDF Toolbox (C. Denham)
%   plotfan07.m (E. Montgomery)
%   (6/07 the above files replaced showfan.m and showpen.m)
%   defineRawSonarNcFile.m  (E. Montgomery)
%
% 3/25/08 at CRS request, splitting procsonar into two parts: 1) make the
%         raw.cdf file and 2) apply rotations and what-have-you
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
reqFields = {'SonartoAnimate','sweep'};
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
   settings.SonartoAnimate = 'Fan';
   settings.fanadcp_off = 0;
   settings.sweep = 1;
    settings.dxy = 0.01;    % Key setting...determines image resolution at cost of
                            % speed (reasonable range 0.02 to 0.005)
end
clear reqFields missingFields

clear FanTime 
Fanidx = 1;
Pencilidx = 1;
Azmidx=1;
save settings settings;
    % open existing cdf file of raw fan data
     ncr=netcdf(fname);
     % set up output file name
      uidx=strfind(fname,'_');
      outFileRoot=fname(1:uidx-1);
      ofproc=[outFileRoot '_proc'];
      x=[-ncr.Range(:):ncr.dxy(:):ncr.Range(:)];
      ncdims.x=length(x);
      ncdims.y=length(x);
      ncdims.sweep=settings.sweep;
    % instantiate the output ncfile
      ncp = definefanprocNc(ofproc, settings, ncdims);
      
     % copy attributes from raw file
     rawAtts=ncnames(att(ncr));
       for ik=1:length(rawAtts)
        eval(['ncp.' char(rawAtts(ik)) '= ncr.' char(rawAtts(ik)) '(:);'])
       end
       % if there's information in settings, replace the ncp attributes
       % with the values in settings
       nn=fieldnames(settings);
       for ik = 1:length(nn)
           eval(['ncp.' nn{ik} '(:)=settings.' nn{ik} ';'])
       end
       % since StepSize is wrong in header, add degreesPerStep here
       ncp.DegPerStep=ncr.StepSize(:);
       ncp.DegPerStep(:)= ncr{'headangle'}(5)-ncr{'headangle'}(4);
       
       %reset creation date to now
       ncp.CREATION_DATE = ncchar(datestr(now));

      % process the images and put into output netcdf file
         [Xplot,Yplot, thi, ri, Zs]=procfan08(ncr,'polar', settings);
         save tst.mat Xplot Yplot thi ri Zs 

      % put the outputs into processed netcdf file
        ncp{'time'}(1:length(ncr{'time'}))=ncr{'time'}(:);
        ncp{'time2'}(1:length(ncr{'time2'}))=ncr{'time2'}(:);   
        % this is the last we need ncr...
          close(ncr); 
        ncp{'x'}(1:length(Xplot))=Xplot;
         ncp{'y'}(1:length(Yplot))=Yplot;
          ncp{'sweep'}(1)=1;
          ncp{'sweep'}(2)=2;
        % Zs is float- needs to be multiplied by 10000 to store as short
        for jj = 1:length(Zs)
          tmp1=floor(Zs{jj,1}*10000);
          tmp2=floor(Zs{jj,2}*10000);
           ncp{'sonar_image'}(jj,1,1:length(Xplot),1:length(Yplot))=tmp1;
           ncp{'sonar_image'}(jj,2,1:length(Xplot),1:length(Yplot))=tmp2;
          clear tmp1 tmp2
        end
       ncp{'sonar_image'}.scale_factor(:)=10000;
       
       % add some notes to the netcdf file      
           ncp.NOTE =['radial data interpolated onto x-y grid to make image;',...
                      'image rotated so that +y (up) is N'];
           ncp.NOTE1 = ['To view images in Matlab type the following at the command ',...
                   'prompt:  nc=netdcf(''sonarxxx.nc'');',...
                   'imagesc(nc{''x''}(:),nc{''y''}(:),squeeze(nc{''sonar_image''}(n,p,:,:)));',...
                    'set(gca,''ydir'',''normal''); **where n & p are the time and sweep indexes'];

% this is where the data is saved
%  writing to netCDF doesn't work, but you get a .mat file for each fan and
%  Pencil run
if strcmpi(settings.SonartoAnimate,'fan'),
      tt= ncp{'time'}(end)+ncp{'time2'}(end)./86400000;
       ncp.stop_time = datestr(gregorian(tt));
      t_all= ncp{'time'}(:)+ncp{'time2'}(:)./86400000;
       ncp.DELTA_T = [num2str(gmean(diff(t_all))*24*60),' sec'];
        close(ncp);
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


