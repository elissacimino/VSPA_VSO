function [theta_inv,delta_inv,M_ankle,theta_cam_inv,Angles,Moments,F_cam, F_cam_2, F_cam_3,ROM_index,cam_angles,F_spring,F_ankle,F_spring_vert,F_ankle_vert,L,tau_inv,gamma_inv] = inverse_model(preload_inv,kdelt,x_center,x_center_inv,ktranslational,epsilon,mu,y_off,r,psi,gamma,dual_test)
    %% Setup
    load('inputs/VSPA_configuration.mat')
    load('inputs/conversions.mat')
    new_math = 1;
    F_cam = [];
    F_cam_2 = [];
    F_cam_3 = [];
    cam_angles = [];
    %% Preallocation
    num_slider_positions = length(x_center_inv);
    L = NaN(1,num_slider_positions);
    tau = NaN(1,num_slider_positions);
    zeta = NaN(1,num_slider_positions);
    d = NaN(1,num_slider_positions);
    beta = NaN(1,num_slider_positions);
    omega = NaN(1,num_slider_positions);
    sigma = NaN(1,num_slider_positions);
    omega_inv = NaN(num_slider_positions,length(r));
    alpha_inv = NaN(num_slider_positions,length(r));
    theta_cam_inv = NaN(num_slider_positions,length(r));
    gamma_inv = NaN(num_slider_positions,length(r));
    k = NaN(1,num_slider_positions);
    M_spring = NaN(num_slider_positions,length(r));
    work_spring = NaN(num_slider_positions,length(r));
    M_ankle = NaN(num_slider_positions,length(r));
    delta_inv = NaN(num_slider_positions,length(r));
    theta_inv = NaN(num_slider_positions,length(r));
    % tau_inv = NaN(num_slider_positions,length(r));
    % lambda_inv = NaN(num_slider_positions,length(r));
    % F_spring = NaN(num_slider_positions,length(r));
    % F_ankle = NaN(num_slider_positions,length(r)); 
    % F_spring_vert = NaN(num_slider_positions,length(r)); 
    % F_spring_or = NaN(num_slider_positions,length(r)); 
    % F_ankle_vert = NaN(num_slider_positions,length(r)); 
    % F_ankle_or = NaN(num_slider_positions,length(r)); 
    Moments = NaN(2*length(r),num_slider_positions);
    Angles = NaN(2*length(r),num_slider_positions);
    %% Inverse Model
    vert_preload_inv = -x_center.*tan(preload_inv); %This is the translational equivalent to the rotational preload
    spring_preload_inv = atan(vert_preload_inv./-x_center_inv);  %This allows the preload to update as the slider moves

    for i = 1:length(x_center_inv)
        tau(i) = atan(y_center/x_center_inv(i));
        zeta(i) = -tau(i)+pi-epsilon;
        L(i) = sqrt(x_center_inv(i).^2+y_center^2); 
        d(i) = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center_inv(i))^2); %This is the distance between virtual spring centers
        beta(i) = atan((y_center+y_off)/(x_center_inv(i)+x_off)); %This is the angle between horizontal and the line between spring centers
        omega(i) = pi-beta(i)-epsilon;
        sigma(i) =zeta(i)-omega(i); %This is the angle between virtual spring and line through spring centers
    
        %I need to reverse out gamma and delta from psi and r:
        omega_inv(i,:) = acos((L(i).^2 - r.^2 - d(i).^2)./(-2*r.*d(i))); %math in notebook (Law of Cosines)
        alpha_inv(i,:) = omega_inv(i,:)-omega(i);
        theta_cam_inv(i,:) = alpha_inv(i,:) + psi;
        cam_angles = [cam_angles; radian2deg*min(theta_cam_inv(i,:)) radian2deg*max(theta_cam_inv(i,:))]; %ROM of the cam (make sure this is above 40 in either direction or follower will roll of cam)
        gamma_inv(i,:) = acos((r.^2 - L(i)^2 - d(i)^2)./(-2*L(i)*d(i)))-sigma(i); %math in notebook (Just do r calculation in reverse)
        k(i) = ktranslational(i).*x_center_inv(i)^2; %rotary stiffness
        %k(i) = ktranslational(i).*L(i)^2;
        if(new_math)
            M_spring(i,:) = k(i)*(gamma_inv(i,:)); %new math as of 8/5/2025 preload is already included in gamma because the new math references to the unpreloaded position
        else
            M_spring(i,:) = k(i)*(gamma_inv(i,:) + spring_preload_inv(i));
        end
        
        %M_spring(i,:) = k(i)*(gamma_inv(i,:) + spring_preload_inv(i));
    
        work_spring(i,:) = cumtrapz(gamma_inv(i,:),M_spring(i,:));
%         if(~dual_test)%ToDo
% %             work_spring(i,:) = work_spring(i,:) - work_spring(i,gamma==0);
%         end
    
        %Differientiate to get ankle torque
        M_ankle(i,1:end-1) = diff(work_spring(i,:))./diff(theta_cam_inv(i,:)); %diff takes differences change in Moment/change in theta_cam
        M_ankle(i,end) = M_ankle(i,end-1); %diff() function decreases the length of the vector by one
    
        delta_inv(i,:) = M_ankle(i,:)./kdelt;
        theta_inv(i,:) = theta_cam_inv(i,:) + delta_inv(i,:);
    
        %Save Model for RMSE calculation in JIM scrip
        [~,rmse_midstance] = min(abs(theta_inv(i,:)));
        Moments(:,i) = [flip(M_ankle(i,1:rmse_midstance)) M_ankle(i,:) flip(M_ankle(i,rmse_midstance+1:end))]';
        Angles(:,i) = rad2deg([flip(theta_inv(i,1:rmse_midstance)) theta_inv(i,:) flip(theta_inv(i,rmse_midstance+1:end))]');
        
        %Cam Forces---------------------
        [~, ROM_index] = min(abs(theta_inv(i,:)-ROM_thresh));
        if(x_center_inv(i)==x_center)
            [~,DropFoot_index] = min(abs(M_ankle(i,:)-Torque_DropFoot));
            Angle_DropFoot = rad2deg(theta_inv(i,DropFoot_index(1)));
        end
        F_cam = [F_cam M_spring(i,ROM_index(1))./L(i)]; % y component, it is the one that I want to use in my CAD simulation
        F_cam_2 = [F_cam_2 M_ankle(i,ROM_index(1))./r(ROM_index(1))];
        F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];

        %Cam Forces ANDREA
        % tau_inv(i,:) = tau(i) - gamma_inv(i,:);
        % lambda_inv(i,:) = beta(i) + omega(i) + alpha_inv(i,:) - pi/2; 
        % F_spring(i,:) = M_spring(i,:)./L(i);
        % F_ankle(i,:) = M_ankle(i,:)./r;
        % F_spring_vert(i,:) = F_spring(i,:).*cos(tau_inv(i,:));
        % F_spring_or(i,:) = F_spring(i,:).*sin(tau_inv(i,:));
        % F_ankle_vert(i,:) = F_ankle(i,:).*sin(lambda_inv(i,:));
        % F_ankle_or(i,:) = F_ankle(i,:).*cos(lambda_inv(i,:));
% 
%         figure
%         subplot(2,1,1)
%         plot(theta_inv(1,:),F_spring_vert)
%         subplot(2,1,2)
%         plot(theta_inv(1,:),F_ankle_vert)
    end
end