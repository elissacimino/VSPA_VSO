function cam_final_linear()
    clear
    %close all
    scalefactor = 0.30;%0.15
    dorsi_max = 50; 
    plantar_max = -65; 
    equilibrium_angle = 0; %Degrees
    angle_leveling = 25+equilibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/3;
    %------------------------
    stiffness_dorsi = 310/rad2deg(1); %Nm/deg
    stiffness_leveling_transition = 0.33*stiffness_dorsi;%*(200/rad2deg(1)/stiffness_dorsi); %Nm/deg;
    stiffness_leveling = 0.11*stiffness_dorsi;%*(200/rad2deg(1)/stiffness_dorsi); %Nm/deg;
    stiffness_plantar = 0.4355*stiffness_dorsi; %Nm/deg
    %--------------------------------
    theta_plantar = [plantar_max;-30; -15; -7.5; -2];
    pt_dorsi = 2; %how many points do you want on linear line?
    first_offset = 2; %what offset from equilbrium should the first linear line point be (important so that spline is constrainted to be more linear near zero)
    pt1_dorsi = equilibrium_angle+first_offset;
    dorsi_spacing = (angle_leveling-pt1_dorsi)/(pt_dorsi+1);
    theta_dorsi = [equilibrium_angle; pt1_dorsi; dorsi_spacing+pt1_dorsi; 2*dorsi_spacing+pt1_dorsi; angle_leveling; angle_leveling+level];
    theta_leveling = [angle_leveling+2*level; dorsi_max];
    theta_deg = [theta_plantar; theta_dorsi; theta_leveling];
    M_dorsi = (theta_dorsi(1:end-1)-equilibrium_angle)*stiffness_dorsi
    M_dorsi = [M_dorsi; M_dorsi(end)+level*stiffness_leveling_transition]
    M_plantar = (theta_plantar-equilibrium_angle)*stiffness_plantar;
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar; M_dorsi; M_level];
    save('TA/cam_final_linear')

    
    
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