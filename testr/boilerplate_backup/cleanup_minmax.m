function cleanup_minmax(adv_name, threshold, plt)
%
% assumes this is for adv data 
%  usage cleanup_minmax('adv7481vp-cal.nc',100,'y')
%  emontgomery 6/16/06
figure
vnames=['u_1205min'; 'v_1206min'; 'w_1204min'; 'u_1205max'; 'v_1206max'; 'w_1204max'];

for ik=1:6
    if ik==3 | ik==6
        thold=thold/5;
    else
        thold=threshold;
    end
  ncload(adv_name,vnames(ik,:))
  eval(['xx=find(abs(' vnames(ik,:) ') > thold);'])
  eval(['tmp = ' vnames(ik,:) '/10;'])
  tmp(xx)=ones(length(xx),1)*NaN;
  yy=find(abs(diff(tmp)) > thold/2);
  tmp(yy+1)=ones(length(yy),1)*NaN;
 
  if (strcmp(plt,'y'))
      clf
      subplot(2,1,1)
      eval(['plot(' vnames(ik,:) ')'])
      subplot(2,1,2)
      plot(tmp,'r')
      pause (2)
  end
  
end
  
