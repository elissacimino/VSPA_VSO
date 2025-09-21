    clear 
    %close all
    scalefactor = 0.15;
    dorsi_max = 50; 
    plantar_max = -65; 
    equalibrium_angle = -3; %Degrees
    angle_leveling = 25+equalibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/4;
    %------------------------
    stiffness_dorsi = 200/rad2deg(1); %Nm/rad
    stiffness_trans = 1.5*stiffness_dorsi;
    stiffness_trans_2 = 0.2*stiffness_trans;
    stiffness_leveling = 0.1*stiffness_trans_2; %Nm/deg;
    stiffness_plantar = -0.5*stiffness_dorsi; %Nm/deg

    %--------------------------------
    theta_plantar = [plantar_max;-30; -15; -7.5; -5];
    theta_dorsi = [5; 13.5; angle_leveling];
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar;equalibrium_angle;theta_dorsi;theta_leveling];
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_dorsi_1 = (theta_dorsi(1)-equalibrium_angle)*stiffness_dorsi;
    M_dorsi_2 = (theta_dorsi(2)-theta_dorsi(1))*stiffness_trans+M_dorsi_1;
    M_dorsi = [M_dorsi_1; M_dorsi_2; (theta_dorsi(3)-theta_dorsi(2))*stiffness_trans_2+M_dorsi_2];
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar;0;M_dorsi;M_level];
    save('TA/chris_test')
    
    
    %%
    human = 1;
    if(human)
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
        plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[32,178,170]./255,'Linewidth',5)
        theta_total = deg2rad(plantar_max:0.005:dorsi_max);
        theta = deg2rad(theta_deg);
        M = interp1(theta, M_data, theta_total,'spline');
        plot(rad2deg(theta_total),M ,'k','Linewidth',5)
    end