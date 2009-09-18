function [xdist, elev, sstrn]= linfrm_rawimg(ncr, tidx)
% LINFRMIMG uses the first increasing return in each scan to define a line
% approximating the seafloor
%
%  This is a work in progress aimed at resolving ripples
%
%  inputs: the open netdcf object for the raw file
%  outputs: xdist position along the sweep
%	    elevation = height of the seafloor for that xdist
%	    sstrn = value of the maximum for the elevantion

% this uses the maximum of each scan
% I don't think this is as good as using the beginning of the upswing
%zz=max(imi);
%  for ik=1:length(zz)
%   if ~isnan(zz(ik))
%    nn=find(imi(:,ik)==zz(ik),1,'first');
%   else
%    nn=1;
%   end
%  ly(ik)=nn;
%  end
 
%contains: (time, number_rotations, npoints, nscans)
 szs = ncsize(ncr{'raw_image'})

% alternate method trying to get the first part of the peak 
for hh=1:szs(2)
    for jj=1:szs(4)
        first_hi_val=find(diff(ncr{'raw_image'}(tidx,hh,50:end,jj) > 5),1,'first');
        if (isempty(first_hi_val))
            newly(hh,jj)=1;
        else
            newly(hh,jj)=first_hi_val+50;
        end
    end
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
   % plot(xx(strt_idx:end_idx),ly(strt_idx:end_idx))
 %
 % do we keep this the same length for each by nan-ing the ends that are bad?
 % autonan_on allows these nan's to be converted to fillValue on write.
 % so should end up as 1e35 in the data file.
  xdist=xx;
  xdist(1:strt_idx-1)=NaN;
  xdist(end_idx+1:end)=NaN;
  %elev=-yy(ly);
  elev=-yy(newly);
  elev(1:strt_idx-1)=NaN;
  elev(end_idx+1:end)=NaN;
  %sstrn=zz(ly);
  sstrn=zz(newly);
  sstrn(1:strt_idx-1)=NaN;
  sstrn(end_idx+1:end)=NaN;
    
    %now remove everything greater than 3 std_devs of the mean
    %mn_el=gmean(elev);
    std_el=gstd(elev);
    med_el=gmedian(elev);
    %gdvals=[mn_el-(std_el) mn_el+(std_el)];
    gdvals=[med_el-(1.5*std_el) med_el+(1.5*std_el)];

    ng_idx=find(elev < gdvals(1) | elev > gdvals(2));
    if ~isempty(ng_idx)
     elev(ng_idx)=NaN; 
    end
     %figure
      hold on  %overplot on original
      plot(xdist,elev,'r.')
       title(['seafloor extracted from image: range setting= ' num2str(range_config)])
       xlabel('horizontal distance along seafloor(m)')
       ylabel('depth(m)')
       hold off