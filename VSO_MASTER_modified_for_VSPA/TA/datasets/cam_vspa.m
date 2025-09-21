function cam_vspa(dat, perc)
if perc == 50
    BW = 78.4;
elseif perc == 99
    BW = 111.2;
end
BW50 = 78.4; %50th perc
BW99 = 111.2;
BW1 = 45.6;
mom_mean_norm = dat.mom.values(:,end);
mom_mean_50pt = mom_mean_norm*BW50;
mom_mean_99pt = mom_mean_norm*BW99;
mom_mean_1pt = mom_mean_norm*BW1;
mom_mean_BW = mom_mean_norm*BW;

pos_mean_deg = dat.pos.values(:,end);
pos_mean_rad = deg2rad(pos_mean_deg);
%Define RoM and discretization
max_dorsiflexion = 40;      %degrees
max_plantarflexion = 40;    %degrees
theta = pi/180*(-max_plantarflexion:0.005:max_dorsiflexion);  %radians. 
equilibrium_angle = 0;

%PROFILE
thetapoints = [-0.65,-0.5,-0.2,0,0.125,0.21,0.24,0.4,0.5,0.65]; %(rad) User-Defined Points to define the desired Torque-Angle curve
Mpoints = [-25,-25,-17,0,25,60,76,100,100,100]; %(Nm)  User-Defined Torques to define the desired Torque-Angle curve

M = interp1(thetapoints, Mpoints, theta,'makima');
%Plot moment profile
figure(1); hold on
plot(theta*180/pi,M)
plot(thetapoints*180/pi,Mpoints,'x')
xlabel('Angle (deg)')
ylabel('Torque (Nm)')
title('Desired Torque-Angle Curve')
set(gcf,'color','w');
save('TA/datasets/cam_vspa')

end