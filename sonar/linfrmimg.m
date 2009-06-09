function [xdist, elev, sstrn]= linfrmimg(xx, yy, imi, range_config)
% LINFRMIMG uses the strongest return in each scan to define a line
% approximating the seafloor

zz=max(imi);
  for ik=1:length(zz)
   if ~isnan(zz(ik))
    nn=find(imi(:,ik)==zz(ik),1,'first');
   else
    nn=1;
   end
  ly(ik)=nn;
  end
  
% use the contiguous middle of the plot to select the x range
  % figure(2); plot(diff(yy(ly)))
  % divede the data into 10 point chunks
  nyy=reshape(ly(1:500),10,50);
  % then get the std of each chunk
  nystd=std(nyy);
  %then find the ones with low std
  dd_std=find(abs(diff(diff(nystd))) < 5)
  % we know the first and last are NG, so look for the first with low diff
  % in a bin greater than 5
  strt_idx=(dd_std(2)-3)*10;
  end_idx=(dd_std(end)+2)*10;
  plot(xx(strt_idx:end_idx),ly(strt_idx:end_idx))
 %
 % do we keep this the same length for each by nan-ing the ends that are bad?
  xdist=xx;
  xdist(1:strt_idx-1)=1e35;
  xdist(end_idx+1:end)=1e35;
  elev=-yy(ly);
  elev(1:strt_idx-1)=1e35;
  elev(end_idx+1:end)=1e35;
  sstrn=zz(ly);
  sstrn(1:strt_idx-1)=1e35;
  sstrn(end_idx+1:end)=1e35;
    
    %now remove everything greater than 3 std_devs of the mean
    mn_el=mean(elev);
    std_el=std(elev);
    gdvals=[mn_el-(3*std_el) mn_el+(3*std_el)];
    ng_idx=find(elev < gdvals(1) | elev > gdvals(2));
    elev(ng_idx)=NaN; 
     figure
      plot(xdist,elec,'.')
       title([fname(end-11:end) '; range setting= ' num2str(range_config)])
       xlabel('horizontal distance along seafloor(m)')
       ylabel('depth(m)')