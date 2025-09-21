function [x,y,r,psi,theta_cam,x_center,epsilon,mu,y_off,gamma,kdelt,stroke,work_M] = forwared_model_rotaryNew(theta_total,M,equilibrium_angle,titanium_data,dual_test)
    load('inputs/Rotary_VSPA_configuration.mat')
    load('inputs/conversions.mat')
    stroke = x_center_max-x_center_min;
    x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
    primary_slider = x_center_max - x_center*m2mm; % #######
    mu = asin(x_off/r0); % mu = atan(x_off/y_off);
    y_off = r0*cos(mu);
    tau = atan(y_center/x_center);
    epsilon = pi/2+mu;
    zeta = -tau+pi-epsilon; %Angle in between line along length of r0 and L
    L = sqrt(x_center^2+y_center^2); %absolute distance between top of pivot point and center of follower
    d = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center)^2); %%absolute distance between top of pivot point and ankle center of rotation | distance between virtual spring centers
    
    %Both sigma calculations give same results
    sigma = acos((r0^2-d^2-L^2)/(-2*d*L)); %angle between L and d
    %sigma = atan(x_center/y_center)-atan(-x_center/(-r0-y_center)) %angle between L and d
    work_M = cumtrapz(theta_total,M); %Energy in the torque-angle curve
%     figure(23)
%     hold on
%     subplot(2,1,1)
%     A = [theta_total',M'];
%     area(A(:,1), A(:,2));
%     subplot(2,1,2)
%     plot(theta_total, work_M), hold on
%     plot(theta_total, work_M)
%     legend
    if(~dual_test)
        work_M = work_M - work_M(theta_total==deg2rad(equilibrium_angle)); %center it so int_M = 0 when theta is at equilibrium
    else
        work_M = work_M - work_M(equilibrium_index); %same thing but the equilibrium angle is calculated because it will change depending on dual cam file
    end
    
    %Series Compliance
    kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
%     figure(10)
%     plot(rad2deg(theta_total),kdelt)
    
    %Spring Stiffnesses
    k = polyval(titanium_data,primary_slider)*(x_center)^2; %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L
    k = titanium_data*x_center^2;
    k_VSPA = 0.5*10^6*0.0607^2;
    
    %Series Compliance
    delta = M./kdelt; %Amount of deflection of the series compliance
    work_delta = 1/2.*kdelt.*delta.^2; %Mechanical energy stored in the series compliance
    theta_cam = theta_total-delta;
    
    beta = atan((y_center+y_off)/(x_center+x_off)); %This is the angle between horizontal and the line between spring centers
    omega = pi-beta-epsilon;
    
    % Solving via the principle of virtual work (see publication)and quadratic equation with:
    a = k./2;
    b = k.*preload;
    c = work_delta - (work_M);
    % Here is the solution to the quadratic equation:
    gamma = (-b+sqrt(b.^2-4.*a.*c))./(2*a);
    r = sqrt(L^2 + d^2 - 2*L*d*cos(gamma+sigma));
    
    % Find psi, which is what r needs to be a function of. 
    %The roller does not go straight down, so we can't use theta as our angle for the polar coordinates in the cam's reference frame
    w_new = asin(L./r.*sin(gamma+sigma)); %This is the angle between r and the line between spring centers (law of sines)
    alpha = w_new-omega; %This is the deviation from vertical that the spring has gone, in terms of angle from ankle center
    
    %Alternative math to w_new and alpha lines above (Confirmed working)
    %angle_constant_fw = atan((-y_center-r0)/-x_center); %This is the angle between d and the bottom of the spring
    %omega_fw = asin(L./r.*sin(gamma+sigma)); %This is the angle between r and d (law of sines)
    %alpha = omega_fw + angle_constant_fw-pi/2; %This is the deviation from vertical that the spring has gone, in terms of angle from ankle center
    
    
    psi = theta_cam-alpha; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r
     figure
     polarplot(psi,r)

    y = r.*sin(psi);
    x = r.*cos(psi);
end