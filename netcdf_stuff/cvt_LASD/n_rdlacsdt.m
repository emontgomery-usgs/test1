function n_rdlacsdt(fname)
% N_RDLACSDT - Read LACSD temperature ASCII files
%   expects the names to end in csv
%   takes one argument- the root name of the files to process
%      n_rdlacsdt('t1PVFSF.csv');
%
%   there are all 22 depths of data in one file for temperature- 1
%   temperature per file is usually stored, but Marlene said we didn't need
%   to separate these.
%   outputs a root_name.mat file with the data and some header information
%   called by do_cvt_lacsdt.m

% Time corrected by CRS 5/9/2007

%% Read the file 
% when unpacked, a .csv is made, so I guessed it came from excel
% using importdata works well and fast.  two elements are created: 
% .data  which has the matrix of temperatures in columns by depth
% .textdata which has the headers, and the times (starting at row 5)
%   depths to go with the columns are in row 1 of .data.
all = importdata(fname);

%extract some stuff from the header
tmp_mn=all.textdata{2};
mrid=tmp_mn(5:23);

% delpoyment position is not in the file, so have to read a separate file
% made by extracting mooring id, waterdepth, dlon and dlat from the .cdfs
load posdep             % loads moor_id, wd lon and lat
   idx=strmatch(fname(2),moor_id);
   dlat=lat(idx);
   dlon=lon(idx);
   wdep=wd(idx);
clear moor_id wd lon lat

% nr is number of records, t is time, tempd is temperature,
nr = length(all.data)-1;
 dpths=all.data(1,:);
 t=str2num(char(all.textdata(7:end,1)));
 tempd=all.data(2:end,:);
 
% convention has adcp data with bin 1 deepest, following that convention
% here too- columns are the depth bins, so fliplr NOT Flipud!
 dpths=fliplr(dpths);
 tempd=fliplr(tempd);

% This should probably occur after the time is converted to Julian % CRS
% make time even 15 min increments
m15=15/(24*60);  %minutes/day
mins=mod(t(1),floor(t(1)));
strt_mins=round(mins/m15);
mins=mod(t(end),floor(t(end)));
end_mins=round(mins/m15);
tnew=[floor(t(1))+strt_mins*m15:m15:floor(t(end))+end_mins*m15]';

% LACSD time is PST, starting at Jan. 1 2000.  
% From PVSF2006.pdf, page 14 time word (julian day)
%   305.01 (October 31 2000 00:15 a.m. PST)
%   325.521 == Nov. 20, 2000 at 12:30PM PST
%   719.354 == Dec 19, 2001 at 0830 PST
%  we validated this code based on these known conversions, 
%  then converted to GMT 

% starts with 1/1/2000 as day 0 and corrects for GMT.
  jd = julian(1999,12,31,0)+tnew(:)+(8/24); 
fprintf(1,'First time (GMT) is: \n')
gregorian(jd(1))
fprintf(1,'Last time (GMT)is: \n')
gregorian(jd(end))
time = fix(jd-2440000);
time2 = 1000*24*3600*rem(jd-time,1);

clear t tnew all jd m15 mins strt_mins end_mins nr tmp_mn 

%% replace LACSD missing values with 1e35
tempd(find(tempd<-900))=1e35;

%% Save data
sta=fname(1:4);
eval(['save ',sta,'.mat'])

