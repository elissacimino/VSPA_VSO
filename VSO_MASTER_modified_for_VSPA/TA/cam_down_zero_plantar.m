function cam_down_zero_plantar()
    clear 
    %close all
    scalefactor = 0.35; % Ottobock 0.5 and 1.0
    dorsi_max = 60; 
    plantar_max = -65; 
    equilibrium_angle = 0; %Degrees
    angle_leveling = 25+equilibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/4;
    %------------------------
    %135 2 1.25 0.15 0.66
    %90 2 1.25 0.45 0.66
    stiffness_dorsi = 135/rad2deg(1); %Nm/deg
    stiffness_trans_1 = 2*stiffness_dorsi;
    stiffness_trans_2 = 1.25*stiffness_dorsi;
    stiffness_leveling = 0.15*stiffness_dorsi;
    stiffness_plantar = 0*stiffness_dorsi; %Nm/deg
    stiffness_leveling_plantar = 0*stiffness_leveling

    %--------------------------------
    theta_plantar = [-angle_leveling; -15; -7.5; -2];
    plantar_level = (plantar_max+angle_leveling)/4;
    theta_plantar_leveling = [plantar_max ; -angle_leveling+plantar_level*3; -angle_leveling+plantar_level*2; -angle_leveling+plantar_level];
    theta_dorsi = [5; 13.5; angle_leveling]; %3,8
    %theta_leveling = [angle_leveling+level; angle_leveling+2*level; dorsi_max];
    theta_leveling = [angle_leveling+level; angle_leveling+level*2; angle_leveling+level*3; dorsi_max];
    theta_deg = [theta_plantar_leveling; theta_plantar;equilibrium_angle;theta_dorsi;theta_leveling];
    M_plantar = [(theta_plantar_leveling+angle_leveling)*stiffness_leveling_plantar-angle_leveling*stiffness_plantar; (theta_plantar-equilibrium_angle)*stiffness_plantar];
    M_dorsi_1 = (theta_dorsi(1)-equilibrium_angle)*stiffness_trans_1;
    M_dorsi_2 = (theta_dorsi(2)-theta_dorsi(1))*stiffness_trans_2+M_dorsi_1;
    M_dorsi = [M_dorsi_1; M_dorsi_2; (theta_dorsi(3)-equilibrium_angle)*stiffness_dorsi];
    %M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_transition = (theta_leveling(1)-theta_dorsi(end))*(stiffness_leveling+0.15*(stiffness_dorsi-stiffness_leveling))+M_dorsi(end);
    M_level = [M_transition; (theta_leveling(2:end)-theta_leveling(1))*stiffness_leveling+M_transition];
    M_data = scalefactor*[M_plantar;0;M_dorsi;M_level];
    save('TA/ottobock/cam_down_zero_plantar')
    
    
    %%
    human = 0;
    %Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking 
    load('Human_ankle_moment')
    load('IMPORTS/Human_ankle_rot')
    figure(1)
    hold on
    weight = 70; %kg
    AbleBodiedAnkleMoment=xlsread('IMPORTS/Data from Bovi.xls','Joint Moments','AN407:AN470');%AQ507');
    AbleBodiedAnkleMoment = weight*AbleBodiedAnkleMoment;
    AbleBodiedAnkleAngle = xlsread('IMPORTS/Data from Bovi.xls','Joint Rotations','AN710:AN773');%:AQ810');
    AbleBodiedAnkleAngle=AbleBodiedAnkleAngle+22.5;
    if(human)
        plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[32,178,170]./255,'Linewidth',5)
    end
    theta_total = deg2rad(plantar_max:0.005:dorsi_max);
    theta = deg2rad(theta_deg);
    M = interp1(theta, M_data, theta_total,'spline');
    plot(rad2deg(theta_total),M ,'k','Linewidth',5)
    plot(rad2deg(theta),M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
end
