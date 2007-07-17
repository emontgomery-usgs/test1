% script pk_avr.m
%  for data with gain too high- picks the mean of the peak.
 %load work % (to get raw and pict structure)
[fx,fy]=gradient(raw);
[p,q]=size(fy);
for(ik=1:q);
 % one or the other of these two seems to work on most, though there
 % may still be a better way to get the numbers
 % nn=find(fy(30:end,ik)==0);
   nn=find(diff(fx(30:249,ik))== max(diff(fx(30:249,ik))))

  if length(nn) > 1
      % now test for contiguous-ness
      lx=find(diff(nn)==1);
      if (length(lx)==1)
        % nm(ik)=ceil(mean(nn(loc:loc+2)))+30 ; OK for some, but BAD for
        % others
        %nm(ik)=nn(lx);  % this adds spikes up
      else
        nm(ik)=ceil(mean(nn(lx(1:end-1))))+30;
      end
  else
      nm(ik)=nn+30;
  end
end
pcolor(raw);shading flat
hold on
plot([1:1:length(nm)],nm,'r.')