load THETA_mat_245-8-1
%load LAM_mat_245-8-1  % equivalent wavelengths

figure
subplot(4,1,1)
plot(THETA_mat(:,3),'r')
xlabel('image number')
ylabel('ripple orientation (deg)')
ylabel('box3')
title('Hatteras-09: all images, ripple orientation from boxes 3,4,7,8 from THETA\_mat\_245-8-1')
subplot(4,1,2)
plot(THETA_mat(:,4),'b')
xlabel('image number')
ylabel('box4')
subplot(4,1,3)
plot(THETA_mat(:,7),'g')
xlabel('image number')
ylabel('box7')
subplot(4,1,4)
plot(THETA_mat(:,8),'m')
xlabel('image number')
ylabel('box8')
