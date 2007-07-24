function pct=find_good_pr(PenHdr)
%
%  Takes andy PenHeader variable and finds where the good Profile ranges
%  are.  etm 07/10/07
%    usage:
%    [PenDat123, PenH123, PSw123] = readpencil('t123m.81a');
%       find_good_pr(PenH123)
%
ang_bnds=[-80 -60 -40 -20 0 20 40 60 80];
for ik=1:length(ang_bnds)-1
    tha=PenHdr.HeadAngle;
    lx=find(tha >ang_bnds(ik) & tha < ang_bnds(ik+1));
    nhi=find( PenHdr.ProfileRange(lx)>60);
    pct_gd(ik)=length(nhi)/length(lx);
end
  
  pltlev=[-70 -50 -30 -10 10 30 50 70];
  bar(pltlev,pct_gd*100)
  axis([-80 80 0 80])
  xlabel('20 degree headAngle bins')
  ylabel('% ProfileRange > 50')
  title(PenHdr.FileName)
  text(-75,75,['number of points analysed ' num2str(length(tha))])
  pct=[pltlev' pct_gd'];

  