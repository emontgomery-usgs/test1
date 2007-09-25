function rd_mlog_mno_hgt(mno)
% script to get mooring number and height from mooring log
%
%  emontgomery@usgs.gov  June 2006

if ispc
      [a,b,c,d,e,f,g,h,ii,j,k,l]=textread('/home/data/Mooring_log.csv',...
      '%s%s%s%s%s%s%s%s%s%s%s%s%*[^\n]','headerlines',4,'delimiter',',');
else
  [a,b,c,d,e,f,g,h,ii,j,k,l]=textread('/home/data/Mooring_log.csv',...
      '%s%s%s%s%s%s%s%s%s%s%s%s%*[^\n]','headerlines',4,'delimiter',',');
end
  j=1;
for ik=1:length(a)
 if(findstr(char(a{ik}),mno))
  xx(j)=ik;
  j=j+1;
 end
end
pos_mno=char(a{xx});
pos_hgt=char(l{xx});
hdr='mooring_id  height  ';
[p1,q1]=size(pos_mno);
[p2,q2]=size(pos_hgt);
lendat=q1+q2;
lenspc=length(hdr)-lendat;
spcs=ones(length(xx),lenspc)*' ';
ltab=[pos_mno spcs pos_hgt];
 ltab=[hdr;ltab]
return
