clear
close all
dorsi_max = 50;
equalibrium_angle = 0; %Degrees
plantar_max = -65; 
theta_deg = [plantar_max:1:dorsi_max]';
M_data = ones(length(theta_deg),1)*40;
save('TA/constant_stiffness')
plot(theta_deg,M_data)