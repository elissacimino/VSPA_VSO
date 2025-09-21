function cam_no_plant(dat, perc, zero_origin)
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
stride = 0:100;
fontsize = 12;
[maxPosrad, maxXIndex] = max(pos_mean_rad);
[minPosrad, minXIndex] = min(pos_mean_rad);
if zero_origin == 1
    orgn = 0;
    equilibrium_angle = rad2deg(orgn); 
    idx_emp = 5; % to do it smoother, increase idx_emp from 4 
else
    orgn = -0.026;%0;
    equilibrium_angle = rad2deg(orgn); 
    idx_emp = 8;
end
% intersection with T == 0 is at angle = -0.026
pos_angles =  find(pos_mean_rad > orgn);
pos_torque =  find(mom_mean_BW > 0);
x1 = pos_angles(idx_emp); %change to 4 if I want to start from the origin
y1 = pos_torque(1);
if zero_origin == 1
    low_bound_idx = x1;
else
    low_bound_idx = y1;
end
theta = [ orgn ;pos_mean_rad(low_bound_idx:maxXIndex) ;0.3 ;0.32; 0.35;0.38;  0.4; 0.45;0.5;0.55;0.6;0.65;0.7];
mom_des = [ 0; mom_mean_BW(low_bound_idx:maxXIndex); mom_mean_BW(maxXIndex)*1.08;mom_mean_BW(maxXIndex)*1.15;  mom_mean_BW(maxXIndex)*1.23;mom_mean_BW(maxXIndex)*1.4; mom_mean_BW(maxXIndex)*1.4;mom_mean_BW(maxXIndex)*1.46;mom_mean_BW(maxXIndex)*1.49;mom_mean_BW(maxXIndex)*1.51;mom_mean_BW(maxXIndex)*1.54;mom_mean_BW(maxXIndex)*1.57;mom_mean_BW(maxXIndex)*1.6];

% figure
% plot(pos_mean_rad,mom_mean_BW)
% hold on
% plot(theta,mom_des)

%primary curve does exactly the profile
%
% Build the primary curve that does exactly the profile we want
%Define RoM and discretization
max_dorsiflexion = 40;   %23   %degrees
max_plantarflexion = rad2deg(-orgn);    %degrees
thetapoints = pi/180*(-max_plantarflexion:0.005:max_dorsiflexion);  %radians. p = polyfit(pos_mean_rad(x1:maxXIndex),mom_mean_50pt(x1:maxXIndex),7);
n = 9;
p = polyfit(theta,mom_des,n);
new_m = polyval(p, thetapoints);
new_m(1)
% new_m(1) = 0;
% hold on
% plot(thetapoints,new_m)
%%
% Loop until conditions are satisfied
max_iterations = 10;  % Maximum number of iterations
current_iteration = 1;
max_slope_limit = 2000;%2000;  % Maximum allowable slope

theta2 = thetapoints;
while true
    % Evaluate the polynomial
    new_m = polyval(p, thetapoints);
    
    % Check the slope at the first point (new_m(1))
    % Calculate the slope (derivative) using finite differences
    slope_at_first_point = (new_m(2) - new_m(1)) / (thetapoints(2) - thetapoints(1));
    
    % Adjust if the slope exceeds a certain limit
    if abs(slope_at_first_point) > max_slope_limit
        % Adjust the polynomial coefficients to control the slope
        p(end) = p(end) * max_slope_limit / abs(slope_at_first_point);
    end
    
    % Ensure the first element passes over 0
    if new_m(1) >= 0
        % Shift the entire curve down if necessary
        new_m = new_m - new_m(1);
    end
    
    % Check if all conditions are met or maximum iterations reached
    if abs(slope_at_first_point) <= max_slope_limit && new_m(1) < 0
        break;  % Exit the loop if conditions are satisfied
    end
    
    % Update polynomial fit
    p = polyfit(theta2, new_m, n);% n
    
    % Increment iteration counter
    current_iteration = current_iteration + 1;
    
    % Check if maximum iterations reached
    if current_iteration > max_iterations
        warning('Maximum iterations reached without satisfying conditions.');
        break;
    end
end
% figure;
% plot(thetapoints, new_m, 'LineWidth', 2), hold on
% scatter(theta,mom_des,"filled"), hold on
% % plot(thetapoints, new_m)
% xlabel('\theta (radians)');
% ylabel('Moment');
% title('Polynomial Curve Satisfying Conditions');
% grid on;

new_m(1) = 0;



%%
M_data = mom_mean_BW(1:60);
theta_data = pos_mean_deg(1:60);

% add no plantar
thetapoints = [-deg2rad(max_dorsiflexion):0.01:(orgn-0.01) thetapoints];
new_m = [0.*ones(1,length(-deg2rad(max_dorsiflexion):0.01:(orgn-0.01))) new_m];

figure
subplot(2,3,1)
plot(0:100,pos_mean_rad , 'LineWidth',2), hold on
plot(x1-1:maxXIndex-1,pos_mean_rad(x1:maxXIndex) , 'LineWidth',2), hold on
grid on
set(gca,'FontSize',fontsize)
xlabel(' stride [%]','FontSize',fontsize)
ylabel('Ankle angle [rad]','FontSize',fontsize)
subplot(2,3,4)
plot(0:100,mom_mean_BW,'LineWidth',2 ), hold on
plot(x1-1:maxXIndex-1,mom_mean_BW(x1:maxXIndex) , 'LineWidth',2), hold on
grid on
set(gca,'FontSize',fontsize)
xlabel(' stride [%]','FontSize',fontsize)
ylabel('Ankle moment [Nm]','FontSize',fontsize)
subplot(2,3,[3 5 6])
plot(pos_mean_rad,mom_mean_BW,'LineWidth',2)
hold on
plot(thetapoints, new_m,'LineWidth',3)
grid on
scatter(theta,mom_des,'filled')
set(gca,'FontSize',fontsize)
xlabel('Ankle angle [rad]','FontSize',fontsize)
ylabel('Ankle Torque [Nm]','FontSize',fontsize)
sgt = title([num2str(perc) '^{th} percentile man'])
sgt.FontSize = 20;
axis([-deg2rad(30) deg2rad(30) -10 mom_mean_BW(maxXIndex)*1.6]) 
M = new_m;

clear theta
theta = thetapoints;

save('TA/datasets/cam_no_plant')

end