function ncp = do_pen_proc(metaFile, fname, img_nums)
% do_pen_proc - Processes Imagenex pencil sonar data from the raw netCDF file.
%   this program uses code from Imagenex to convert the raw data into an
%   image approximating the 
% usage:  ncp = do_fan_rots('836procpmeta', '855tst_raw.cdf', [1:10])
%   where:  metaFile is the name of your text file containing metadata,
%                    surrounded by single quotes WITHOUT the file
%                    extension .txt. An example metadata file,
%                    procfanexample.txt, is provided in this package of
%                    mfiles.
%                    ** currently assumes fan and pencil are processed
%                       as separate steps
%                   The file name is derived from the raw, unless
%                   a new onameRoot is supplied in the metaFile.
%
%           fname is the netcdf file containing the raw data.  The
%                     rootname will be used to create the name of the
%                     processed file
%           img_nums is the array of image indices to process
%                     can use [1 10 25] or [132:181],
%                     default is to process all
%              ** nb: if you choose discontinuous elements, they will be
%                     put into sequential elements in the output file, so
%                     the timebase is likely to be irregular.
%           ncp is the processed output netcdf object
%
% USGS Woods Hole Field Center
% emontgomery@usgs.gov
%
% Dependencies:
%   USGS NetCDF Toolbox (C. Denham)
%   -dap enabled mexnc doesn't work! ==> mexnc_win_2006a\mexnc.mexw32 works
%   procpen.m (E. Montgomery)
%   definepenprocNcFile.m  (E. Montgomery)
%
% 3/25/08 at CRS request, splitting procsonar into two parts: 1) make the
%         raw.cdf file and 2) apply rotations and what-have-you
%
close all
more off

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords is set to "Revision"
rev_info= 'SVN $Revision: $';

% Check for metadata file
metaPath = pwd;
meta = dir([metaFile,'.txt']);
if isempty(meta)
    fprintf('\n')
    fprintf('The metadata file %s.txt does not exist in this directory\n',metaFile)
    metaPath = input('Please enter the full path to the directory with your metadata file:  ','s');
    meta = dir(fullfile(metaPath,[metaFile,'.txt']));
    if isempty(meta)
        error(['Still cannot find this metadata file ', fullfile(metaPath,[metaFile,'.txt'])])
    end
end
metaFile = fullfile(metaPath,meta.name);

% Get user's metadata structure
settings = readSonarMeta(metaFile);

% Check that the metadata contains required fields.
reqFields = {'SonartoAnimate','sweep'};
for f = 1:length(reqFields)
    if ~isfield(settings,reqFields{f})
        disp(['The field ''',reqFields{f},''' is not specified in ',metaFile,'.txt'])
        missingFields(f) = 1;
    else
        missingFields(f) = 0;
    end
end
%If a required field is missing, ask the user for it.
if any(missingFields)
    disp('Required fields missing from the metadata');
    settings.fanpen_off = 0;
    settings.sweep = 1;
    settings.dxy = 0.02;    % Key setting...determines image resolution at cost of
    % speed (reasonable range 0.02 to 0.005)
end
clear reqFields missingFields

clear PenTime
Penidx = 1;

save settings settings;
% open existing cdf file of raw pen data
ncr=netcdf(fname);
% set up output file name
if isfield(settings,'onameRoot')
    ofproc=[settings.onameRoot '_proc.cdf'];
else
    uidx=strfind(fname,'_');
    outFileRoot=fname(1:uidx-1);
    ofproc=[outFileRoot '_proc.cdf'];
end
% xx & yy are the arrays used for pencil image interpolation in showpen, 
%  To be sure we all agree what they are, passing them as arguments.
    xx=[-3.16:.0125:3.16]; 
    yy=[.2:.0025:1.4]';
    dim_nc.x=length(xx);
    dim_nc.y=length(yy);
    dim_nc.sweep=settings.sweep;
    intrp_vec.x=xx;
    intrp_vec.y=yy
        % run showpen once to get the dimension of the other data
    rtndat=showpen09(ncr,1,intrp_vec);
    dim_nc.xdist=length(rtndat(1).intrpx);

% instantiate the output ncfile
ncp = definepenprocNc(ofproc, settings, dim_nc);

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
% set up how many images to process
if nargin == 3
    nimg_nums=img_nums;
else
    nimg_nums=[1:1:length(ncr{'time'})];
end
% do the right number of time elements
ncp{'time'}(1:length(nimg_nums))=ncr{'time'}(nimg_nums);
ncp{'time2'}(1:length(nimg_nums))=ncr{'time2'}(nimg_nums);
% put the outputs into processed netcdf file
for kj=1:settings.sweep
    ncp{'sweep'}(kj)=kj;
end

for jj=(nimg_nums(1):nimg_nums(end))
    % process the images and put into output netcdf file
    if jj > 1
       rtndat=showpen09(ncr,jj,intrp_vec);
    end
    % and put what's returned in the output file and object
    if Penidx==1
        ncp{'x'}(1:length(xx))=xx;
        ncp{'y'}(1:length(yy))=yy;
        ncp{'xdist'}(1:length(rtnda1(1).intrpx))=rtnda1(1).intrpx;
    end
    % Zs is float- needs to be multiplied by 10000 to store as short
    for kk=1:settings.sweep
        % images may have nan's or small negative values
        tmp1=rtndat(kk).proc_im;
        ltz=find(tmp1 <0);
        tmp1(ltz)=ncp{'sonar_image'}.FillValue_(:);
        % next multiply by the scale factor
        tmp1=tmp1*1000;
        % now replace Nan's
        lnan=find(isnan(tmp1));
        tmp1(lnan)=ncp{'sonar_image'}.FillValue_(:);
        %have to force it to uint16 since sonar_image is nc_short
        tmp1=uint16(tmp1);
        ncp{'sonar_image'}(Penidx,kk,1:length(xx),1:length(yy))=tmp1;
        clear tmp1 ltx lnan
        %the signal strength comes from the image so has the same issues
         tmp1=rtndat(kk).intrpz;
                 ltz=find(tmp1 <0);
        tmp1(ltz)=ncp{'ssterngth'}.FillValue_(:);
        % next multiply by the scale factor
        tmp1=tmp1*100;
        % now replace Nan's
        lnan=find(isnan(tmp1));
        tmp1(lnan)=ncp{'sstrength'}.FillValue_(:);
        %have to force it to uint16 since sonar_image is nc_short
        tmp1=uint16(tmp1);
         ncp{'sstrength'}(Penidx,kk,1:length(tmp1))=tmp1;
       clear tmp1 lnan ltz

%        ncp{'xdist'}(Penidx,kk,1:length(rtndat(kk).intrpx))=rtndat(kk).intrpx;
        ncp{'brange'}(Penidx,kk,1:length(rtndat(kk).intrpy))=rtndat(kk).intrpy;
    end
    Penidx=Penidx+1;
end
ncp{'sonar_image'}.scale_factor(:)=10000;
ncp{'sstrength'}.scale_factor(:)=100;

% this is the last we need ncr...
close(ncr);

% add to history & make some notes to the netcdf file
hist = ncp.history(:);
hist_new = ['Sonar processed with ' ,mfilename, ', ', rev_info, ', using Matlab ' ,...
    version, '; ',hist];
ncp.history = hist_new;

ncp.NOTE =['radial data interpolated onto x-y grid to make image;',...
    'image rotated so that +y (up) is N'];
ncp.NOTE1 = ['To view images in Matlab type the following at the command ',...
    'prompt:  nc=netdcf(''sonarxxx.nc'');',...
    'imagesc(nc{''x''}(:),nc{''y''}(:),squeeze(nc{''sonar_image''}(n,p,:,:)));',...
    'set(gca,''ydir'',''normal''); **where n & p are the time and sweep indexes'];

% this is where the data is saved
%  writing to netCDF doesn't work, but you get a .mat file for each pen and
%  Pencil run
if strcmpi(settings.SonartoAnimate,'pen'),
    t1= ncp{'time'}(1)+ncp{'time2'}(1)./86400000;
    ncp.start_time = datestr(gregorian(t1));
    tt= ncp{'time'}(end)+ncp{'time2'}(end)./86400000;
    ncp.stop_time = datestr(gregorian(tt));
    t_all= ncp{'time'}(:)+ncp{'time2'}(:)./86400000;
    % if time data is evenly spaced
    if length(t_all) > 1 & isempty(find(diff(diff(t_all))) ~= 0) 
        ncp.DELTA_T = [num2str(gmean(diff(t_all))*24*60),' sec'];
        % time and time2 are EVEN by default
    else
        ncp{'time'}.type(:)='UNEVEN';
        ncp{'time2'}.type(:)='UNEVEN';
        ncp.DELTA_T = ['? sec'];
    end
    % close the writeable version
    close(ncp);
    ncclose;
    % re-open it read-only to return to matlab
    eval(['ncp=netcdf(''' ofproc ''');'])
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


