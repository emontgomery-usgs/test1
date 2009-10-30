function n=nearest(jd,jdo)
%function n=nearest(jd,jdo)
%
% purpose: return element numbers in jd of specified times jdo
%
% inputs: jd=julian day row vector
%         jdo=julian day row vector at which element number is unknown
%
% outputs: n=element numbers of nearest times in array jd
%
% by David Schoellhamer 11/3/95
%
if any(diff(jd)<0)
  disp([7,'First arguement must increase monotonically'])
  return
end
if any(diff(jdo)<0)
  disp([7,'Second arguement must increase monotonically'])
  return
end
n=nan*ones(size(jdo));
njd=length(jd);
for i=1:length(jdo)
  if i>1
    zi=n(i-1):njd;
  else
    zi=1:njd;
  end
  [z,zn]=min(abs(jd(zi)-jdo(i)));
  n(i)=zn+zi(1)-1;
end
%[z,n]=min(abs(jd*ones(1,size(jdo,1))-ones(size(jd,1),1)*jdo'));
