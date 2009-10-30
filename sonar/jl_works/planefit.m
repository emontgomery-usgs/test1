function p = planefit(x,y,z)
% planefit - Fit a plane to x, y, z data
% data (x(i),y(i),z(i))
% model a*x+b*y+c*z+d=0, a^2+b^2+c^2=1

% Grabbed from the Matlab Central forum
A=[x,y,z,ones(length(x),1)];
[U,S,V]=svd(A);
ss=diag(S);
i=find(ss==min(ss)); % find position of minimal singular value
coeff=V(:,min(i)); % this may be multiple
coeff=coeff/norm(coeff(1:3),2);
p.coeff = coeff;
p.zp = -(coeff(1)*x+coeff(2)*y+coeff(4))./coeff(3);
p.zr = z-[p.zp];
return