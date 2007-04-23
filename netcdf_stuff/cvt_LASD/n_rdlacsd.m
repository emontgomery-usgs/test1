function n_rdlacsd(sta)
% N_RDLACSD - Read LACSD ACDP ASCII files
%   expects the names to end in 305
%   takes one argument- the root name of the files to process
%      rdlacsd('LA00A5');
%   outputs a root_name.mat file with the data and some header information


%% Build file list
% the depth of the data is the two chars before the .305 in the filename
% and the depths aren't the same for each adcp, so compute them
[fnames]=ls ([sta ,'*305']);
   lcs=strfind(fnames,'.')';
   
  for ik=1:length(lcs);
   nbr=fnames(lcs(ik)-2:lcs(ik)-1);
   h(ik)=str2num(nbr);
  end
  % have to sort the depths sincw ls retruns a row that's out of order
  h=sort(h);
  
% h = [5:3:62]';
nh = length(h);
for i=1:length(h)
   fn(i) = {[sta,sprintf('%02d',h(i)),'.305']};
end

%% Read one file for dimensions
fid = fopen(fn{1});
  intext = textscan(fid,'%s',62,'delimiter','\n');
  C = textscan(fid,'%f %f %f %f %f %f');
fclose(fid);

%extract some stuff from the header
% delpoyment position
l1=char(intext{1}(1));
lt=str2num(l1(15:20));
ln=str2num(l1(22:28));
 dlat=floor(lt/10000) + (mod(lt/10000,floor(lt/10000))*100)/60;
 dlon=-(floor(ln/10000) + (mod(ln/10000,floor(ln/10000))*100)/60);
 wdep=(str2num(l1(32:34)));
 
 
 % config params - all saved as characters
 lns=[14:1:27 47 48 51 52 62];
   for ik = lns
       lx=char(intext{1}(ik));
       dshidx=find(lx=='-',1,'first');
       arindx=find(lx == '>',1,'first');
       if strmatch(sta,'LA00AE')
           stidx=1;
       else
           stidx=6;
       end
       
       if ik < 62
        vname= lx(stidx:dshidx-1);
       else
           vname= lx(stidx:dshidx-7);  % doesn't like the /
       end
       
       vval=lx(arindx+1:end); 
       if (ischar(vname))
           blnk=strfind(vname,' ');
           vname(blnk)=[];
       end
       eval([vname '=''' vval ''';'])
   end     
       
 
   % t is time, u is east, v is north, a is signal amplitude
   % s is signal to noise ratio and c is std/correlation
nr = length(C{1,1});
t = zeros(nr,nh);
t(:,1) = C{1,1};
u = zeros(nr,nh);
u(:,1) = C{1,2};
v = zeros(nr,nh);
v(:,1) = C{1,3};
a = zeros(nr,nh);
a(:,1) = C{1,4};
s = zeros(nr,nh);
s(:,1) = C{1,5};
c = zeros(nr,nh);
c(:,1) = C{1,6};
clear C;

%% Read the rest
for i=2:length(h)
   fid = fopen(fn{i});
   intext = textscan(fid,'%s',62,'delimiter','\n');
   C = textscan(fid,'%f %f %f %f %f %f');
   fclose(fid);
   
   nr = length(C{1,1});
   t(:,i) = C{1,1};
   u(:,i) = C{1,2};
   v(:,i) = C{1,3};
   a(:,i) = C{1,4};
   s(:,i) = C{1,5};
   c(:,i) = C{1,6};
   clear C;
end

% make time even 15 min increments
m15=15/(24*60);  %minutes/day
 mins=mod(t(1),floor(t(1)));
 strt_mins=round(mins/m15);
 mins=mod(t(end),floor(t(end)));
 end_mins=round(mins/m15);
 tnew=[floor(t(1))+strt_mins*m15:m15:floor(t(end))+end_mins*m15]';
 
%% Make sure times are synchronized
if(max(max(diff(t,1,2))))==0;
   fprintf(1,'Time is in synch.\n');
end
jd = julian(2000,1,1,0)+tnew(:);
fprintf(1,'First time is: \n')
gregorian(jd(1))
fprintf(1,'Last time is: \n')
gregorian(jd(end))
time = fix(jd-2440000);
time2 = 1000*24*3600*rem(jd-time,1);

clear t tnew
clear lcs nbr fnames ik nh nf intext C l1 lt ln lns lx stidx
clear dsnidx arindx vname vval blnk m15 mins strt_min end_min

%% NaN stuff
u(find(u<-900))=1e35; %fprintf(1,'Found %d NaNs in u.\n',sum(isnan(u(:))));
v(find(v<-900))=1e35; %fprintf(1,'Found %d NaNs in v.\n',sum(isnan(v(:))));
a(find(a<-900))=1e35; %fprintf(1,'Found %d NaNs in a.\n',sum(isnan(a(:))));
s(find(s<-900))=1e35; %fprintf(1,'Found %d NaNs in s.\n',sum(isnan(s(:))));
c(find(c<-900))=1e35; %fprintf(1,'Found %d NaNs in c.\n',sum(isnan(c(:))));

%% Save data
%z = repmat(-h,1,length(t))';
% put into a structure to return to calling program
%To make bin1 deepest, have to flip the vectors
h=flipud(h'); 
%h=flipud(z); 
u=fliplr(u);   % flipud is wrong!  flips the time deimension
v=fliplr(v);   % fliplr reverses the bins, which is what we want!!
s=fliplr(s); 
c=fliplr(c); 
a=fliplr(a); 

eval(['save ',sta,'.mat'])

