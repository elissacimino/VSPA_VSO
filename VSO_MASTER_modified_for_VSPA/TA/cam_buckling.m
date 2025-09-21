    clear 
    %close all

    scalefactor = 1; %0.15
    dorsi_max = 40;
    plantar_max = -20;
    equilibrium_angle = 0;
    theta_deg = [plantar_max -15 -10 -5 equilibrium_angle 10 17.5 25 32.5 40];
    M_data = scalefactor*[-20;-15;-10;-5;0;30;0;-30;0;30];
    save('TA/cam_buckling')
    
    
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