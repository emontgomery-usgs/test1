function [xdist, elev, sstrn]= linfrmimg(xx, yy, imi, range_config)
% LINFRMIMG uses the strongest return in each scan to define a line
% approximating the seafloor
%
%  This is a work in progress, but is currently used to find the angle 
%  the transducer is tilted by.
%
%  inputs: xx,yy, imi may be obtained from the _proc.cdf file, 
%          imi=squeeze(nc{'sonar_image'}(1,1,:,:))
%          range_config has been 3 for all our deployments to date
%  outputs: xdist position along the sweep
%	    elevation = height of the seafloor for that xdist
%	    sstrn = value of the maximum for the elevantion

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
  dd_std=find(abs(diff(diff(nystd))) < 5);
  % we know the first and last are NG, so look for the first with low diff
  % in a bin greater than 5
  strt_idx=(dd_std(2)-3)*10;
  end_idx=(dd_std(end)+2)*10;
  plot(xx(strt_idx:end_idx),ly(strt_idx:end_idx))
 %
 % do we keep this the same length for each by nan-ing the ends that are bad?
 % autonan_on allows these nan's to be converted to fillValue on write.
 % so should end up as 1e35 in the data file.
  xdist=xx;
  xdist(1:strt_idx-1)=NaN;
  xdist(end_idx+1:end)=NaN;
  elev=-yy(ly);
  elev(1:strt_idx-1)=NaN;
  elev(end_idx+1:end)=NaN;
  sstrn=zz(ly);
  sstrn(1:strt_idx-1)=NaN;
  sstrn(end_idx+1:end)=NaN;
    
    %now remove everything greater than 3 std_devs of the mean
    mn_el=gmean(elev);
    std_el=gstd(elev);
    gdvals=[mn_el-(3*std_el) mn_el+(3*std_el)];
    ng_idx=find(elev < gdvals(1) | elev > gdvals(2));
    if ~isempty(ng_idx)
     elev(ng_idx)=NaN; 
    end
     figure
      plot(xdist,elev,'.')
       title(['seafloor extracted from image: range setting= ' num2str(range_config)])
       xlabel('horizontal distance along seafloor(m)')
       ylabel('depth(m)')