function [dirsmax,spd_est,gt12]=findwdir(u,v)  

% you'll have wanted to ncload a file with u & v
%  ncload('7751whall2.cdf')
%     diratsmaz=findwdir(u_1205,v_1206)

% first get the direction and spped
  [spd,vdir]=pcoord(u,v); 
%The direction & speed returned by pcoord are (5180x16)

%Then we want to find the indices of maximum speed :
  [val,indx]=max(spd');  % have to transpose to get indices right
   %Then we want to use only those where the bin is greater than 12
   gt12=find(indx > 12);
   % for speed, find the speed in the bin below max(speed)
   indxw=indx(gt12)-1;
   nspd=spd(gt12,indxw);

  % this should be doable in one step, but I can't figure out how:
  aa=(vdir(gt12,indx(gt12)));  
  % what we want is on the diagonal of aa & nspd, so use an identity
    ebb=eye(size(aa));
     new=ebb.*aa;
     nn=find(new>0);
      dirsmax=new(nn);
       spd2=nspd(nn);
       spd_est=val(gt12)'-spd2;
      
  %    plot(gt12,dirsmax,'x')
      
      
