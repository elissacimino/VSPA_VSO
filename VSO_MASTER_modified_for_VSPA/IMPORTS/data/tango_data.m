function stiffness_tango = tango_data(equilibrium_angle)
    conversions()
    load('inputs/conversions.mat')
    figure(2)
    hold on
    % theta_yellow_measured = [-20.51 0 20.51];
    % theta_gray_measured = [-17.24 0 17.24];
    % moment_yellow_measured = [-40 0 40];
    % moment_gray_measured = [-80 0 80];
    thetaD_tango(1,:) = linspace(0,20.51,100);
    thetaP_tango(1,:) = linspace(-20.51,0,100);
    thetaD_tango(2,:) = linspace(0,17.24,100);
    thetaP_tango(2,:) = linspace(-17.24,0,100);
    lever_arm_tango(1,:) = linspace(0.02066,0.02276,100);
    lever_arm_tango(2,:) = linspace(0.02066,0.0222,100);
    x_tango(1,:) = linspace(0,8,100)*mm2m; %yellow
    x_tango(2,:) = linspace(0,6.6,100)*mm2m; %gray
    k_tango = [224,452]./mm2m; %N/m
    phi_tango(1,:)  = linspace(4.72,25.23,100);
    phi_tango(2,:)  = linspace(4.72,21.96,100);
    for t=1:length(k_tango)
        if(t==1)
            color = [204,204,0]./255;
        else
            color = [224,224,224]./255;
        end
        force_spring_tango = k_tango(t).*x_tango(t,:);
        moment_tango = force_spring_tango.*cosd(phi_tango(t,:)).*lever_arm_tango(t,:);
        plot([thetaP_tango(t,:) thetaD_tango(t,:)]+equilibrium_angle,[-flip(moment_tango) moment_tango],'Color', color, 'Linewidth',4)
        stiffness_tango = moment_tango(end)/deg2rad(17.24)
    end
    %plot(theta_yellow_measured,moment_yellow_measured, 'Color', [255,255,102]./255, 'Linewidth',4)
    %plot(theta_gray_measured,moment_gray_measured, 'Color', [160,160,160]./255, 'Linewidth',4)
    %legend('Plastic Cam', 'Yellow Tango', 'Gray Tango')
    %legend('VSO', 'Yellow Tango', 'Gray Tango')
end