    clear 
    close all
    scalefactor = 0.24; %0.32 stiffest 0.24 middle 0.16 softest
    torque_max = 160;
    dorsi_max = 50; 
    plantar_max = -65; 
    equalibrium_angle = 0; %Degrees
    angle_leveling = 30+equalibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/4;
    %------------------------
    stiffness_dorsi_lin = 275/rad2deg(1); %Nm/deg
    stiffness_dorsi = 1.75*stiffness_dorsi_lin; %Nm/rad
    stiffness_plantar = 0.33*1.75*stiffness_dorsi_lin; %Nm/deg

    %--------------------------------
    theta_plantar = [plantar_max;-30; -15; -7.5; -2];
    theta_dorsi = [10; 16; angle_leveling];
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar;equalibrium_angle;theta_dorsi;theta_leveling];
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_dorsi_1 = (theta_dorsi(1)-equalibrium_angle)*stiffness_dorsi;
    M_dorsi = [M_dorsi_1; (theta_dorsi(2)-theta_dorsi(1))*stiffness_dorsi_lin+M_dorsi_1; 135];
    stiffness_leveling = (torque_max-M_dorsi(end))/(dorsi_max-theta_dorsi(end));
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar;0;M_dorsi;M_level];
    save('TA/cam_nonlin')