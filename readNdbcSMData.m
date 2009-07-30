function out = readNdbcSMData(buoy,dates,opt)

%READNDBCSMDATA  Reads NDBC Standard Meterological data.
%   OUT = readNdbcSMData(BUOY,DATES) reads the Standard
%   Metorological data in file BUOY from (or between and including)
%   DATE(S).
%
%   OUT = readNdbcSMData(BUOY,DATES,OPT) if OPT=1 will only return the wave
%   data.
%
%   Input:
%     BUOY = num or 'text'; (ex. buoy=42001 | buoy='42001h.dat' |
%     buoy='../ndbc/42001q')
%     DATE(S) = yyyymmddHH | [yyyymmddHH yyyymmddHH];
%     OPT = 0 | 1
%   Output:
%     OUT = [datenum WD WSPD GST WVHT DPD APD MWD BAR ATMP WTMP DEWP VIS TIDE]
%         = [datenum WVHT(Hs) DPD(Tp) APD(Ta) MWD(Dm)];
%   NOTE: MWD is in Nautical convention: direction from measured cw from 
%   North.
%
%   out = readNdbcSMData(buoy,dates,{opt});
%
% Dave Thompson (dthompson@usgs.gov)

%% Check inputs
if ~exist('opt','var')
   opt = 0;
end

%% Check for data file.
fname = num2str(buoy);
direc = char(regexp(fname,'.+\/|.+\\','match'));
ext = regexp(fname(length(direc)+1:end),'.+\..+');
if isempty(ext)
   tmp = strtrim(evalc(['dir ',fname,'h*']));
else
   tmp = strtrim(evalc(['dir ',fname]));
end
if ~isempty(findstr(tmp,'not found'))
   disp([' ',tmp,' !!'])
   out = [];
   return
end
fname = [direc,tmp];

if ~exist('dates','var')
   dates = [0 inf];
end
%% Read in the data.
dat = [];

% Open the file, get the correct dateform and adjust incoming dates
% accordingly.
fid = fopen(fname,'r');
line = fgetl(fid);
% set dnum=16 by default
dnum=16;
      dform = 'yyyymmddHHMM';

if regexp(line,'^\D')
   if ~isempty(regexp(line,'^YY '))
      tmp = num2str(dates);
      %dates = str2num(tmp(:,3:end));
      dnum = 11;
      dform = 'yymmddHH';
   elseif sum(line(15:16)=='mm')==2
      dates = dates*100;
      dnum = 16;
      dform = 'yyyymmddHHMM';
   else
      dnum = 13;
      dform = 'yyyymmddHH';
   end
end

% Read file line-by-line.
while 1
   line = fgetl(fid);
   
   % Break if we've reached the end of the file.
   if ~ischar(line)
      break
   end

   % Find the data of interest 
   fdate = str2num(line(isspace(line(1:dnum))==0));
   while fdate>=dates(1) && fdate<=dates(end)
      tmp = sscanf(line(dnum+1:end),'%f');
      % Replace 99, 999, 9999, etc. with NaNs
      tmp1 = tmp(2:6); tmp1(tmp1==99) = nan; tmp(2:6) = tmp1;
      tmp1 = tmp(12:end); tmp1(tmp1==99) = nan; tmp(12:end) = tmp1;
      tmp(tmp==999) = nan;
      tmp(tmp==9999) = nan;
      if opt~=0 % Only return wave data.
         tmp = tmp(4:7);
      end
      dat = [dat;[datenum(num2str(fdate),dform) tmp(1:12)']];
      line = fgetl(fid);
      % Break if we've reached the end of the file.
      if ~ischar(line)
         disp([' Reached EOF before finding last date requested in ',...
            fname,' !!'])
         break
      end
      fdate = str2num(line(isspace(line(1:dnum))==0));
   end
end
fclose(fid);

if isempty(dat)
   disp(' Requested data not found in data file!')
   out = [];
   return
end
if setdiff(diff(str2num(datestr(dat(:,1),'HH'))),[1 -23])
   disp(' Did not find all dates requested !!')
end
  
out = dat;