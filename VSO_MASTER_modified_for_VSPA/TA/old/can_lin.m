    clear
    close all
    scalefactor = 0.5; %0.35 0.5 0.65
    dorsi_max = 50; 
    plantar_max = -50; 
    %D:40, P:-40
    stiffness_dorsi = 275; %Nm/rad 
    stiffness_dorsi = stiffness_dorsi/rad2deg(1); %Nm/deg
    stiffness_leveling = 0.5*stiffness_dorsi;
    stiffness_plantar = 0.33*stiffness_dorsi;
    equalibrium_angle = 2; %Degrees 
    angle_leveling = 25+equalibrium_angle;
    pt_dorsi = 2;
    first_offset = 2;
    pt1_dorsi = equalibrium_angle+first_offset;
    dorsi_spacing = (angle_leveling-pt1_dorsi)/(pt_dorsi+1);
    theta_plantar = [plantar_max;-30; -15; -7.5; 0];
    theta_dorsi = [equalibrium_angle; pt1_dorsi; dorsi_spacing+pt1_dorsi; 2*dorsi_spacing+pt1_dorsi; angle_leveling];
    level = (dorsi_max-angle_leveling)/4;
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar; theta_dorsi; theta_leveling];
    M_dorsi = (theta_dorsi-equalibrium_angle)*stiffness_dorsi;
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar; M_dorsi; M_level];