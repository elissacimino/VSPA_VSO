%% DESR Dual Cam Profile code
% % % % Prerequisites to have in this folder:
% % % % 1. 'titanium_spring.mat' %this contains the linear spring stiffness information of the titanium spring
% % % % 2. 'DESR_Characterization.mat' %this contains the tests results performed with the dual cam based transmission, using a dynamometer
% % % % 3. (optional) 'Stiffness vs slider.fig' %this provides the visual representation of 'titanium_spring.mat'

%% Clean up
clear
close all
close all hidden

%% Loading the necessary toolbox
addpath('nurbs_toolbox')
load('IMPORTS/Conversions.mat')

%% TORQUE-ANGLE CURVES | SERIES COMPLIANCE | CAM ROLLER RADIUS

load('dual_cams_equilibrium.mat')
plantar_pts = blue_pts;
plantar_control_points = blue_control_points;
dorsal_pts = orange_pts;
dorsal_control_points = orange_control_points;
slope_scaling = slope_dorsi_rad;
%% Initial variables
% max_dorsiflexion = 10;     %degrees
% max_plantarflexion = 5;    %degrees
res = 0.005;               %resolution, step size between data points
theta = pi/180*(-max_plantarflexion:res:max_dorsiflexion);  %angles in energy recycling range, in radians
theta_total = pi/180*(-40:res:40);  %radians.

% TminEnd = -22;
% TmaxEnd = 90;

pf_transition = find (theta_total==-max_plantarflexion*pi/180);
df_transition = find (theta_total==max_dorsiflexion*pi/180);

% DF_angle = 2;


%% Using NURBS to determine the desired Torque-Angle (TA) curves]
% % %THESE LINES DEFINE CONTROL POINTS FOR THE NURBS. THE FIRST COLUMN IS
% % %DEFINED IN DEGREES WITH WHOLE NUMBERS AND THEN CONVERTED TO RADIANS. THE
% % %SECOND COLUMN ASSUMES A SLOPE OF 1 NM/rad FOR DORSIFLEXION, AND THEN IS
% % %SCALED BY THE SLOPE SCALING FACTOR. THE LAST TWO POINTS ON EACH SIDE OF
% % %EACH CURVE HAVE TO DEFINE A LINE THAT GOES THROUGH ZERO (THIS MAKES IT
% % %TANGENT TO THE LINE ADDED LATER)

% slope_scaling = 450; %This is the desired dorsi slope in Nm/deg
% 
% %%%The control points of the plantar curve are assigned a variable, as
% %%%these will change later on in an iteration. 
% xp1 = -5; xp2 = -4.5; xp3 = 0; xp4 = 1.8;  xp5 = 5.7;  xp6 = 9.5;  xp7 = 10;
% yp1 = -2.5; yp2 = -2.25; yp3 = -1.7; yp4 = 0; yp5 = 5; yp6 = 9.5;  yp7 = 10;
% 
% %%%The control points of the drosal curve are filled in directly, as the
% %%%are no loger changed hereafter
% plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, yp5, yp6, yp7]]';
% dorsal_control_points = [pi/180*[-5, -4.5, -3, 0, 6.3, 9.5, 10]; slope_scaling*pi/180*[-2.5, -2.25, 0.7, 1.3, 3, 9.5, 10]]';
% 
% plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]); %equally spaced knots, but doesn't have to be
% plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv object
% dorsal_crv = nrbmak(dorsal_control_points',[0 0 0 0.2, 0.4 0.6, 0.8 1 1 1]);  %equally spaced knots, but doesn't have to be
% dorsal_pts = nrbeval(dorsal_crv,linspace(0.0,1.0,100))'; %evaluate the crv object

%% Plotting TA curves, using the NURBS control points
figure(1); hold on; grid on
plot(plantar_pts(:,1)*180/pi, plantar_pts(:,2),'b:','linewidth',2)
plot(dorsal_pts(:,1)*180/pi, dorsal_pts(:,2),'linewidth',3,'Color', [255 136 0]/255)
plot(plantar_control_points(:,1)*180/pi, plantar_control_points(:,2),'k.-')
plot(dorsal_control_points(:,1)*180/pi, dorsal_control_points(:,2), '.-','Color', [176 99 60]/255)

%THESE LINES SPLINE THE BLUE AND RED CURVE
PlantarMoment = interp1(plantar_pts(:,1),plantar_pts(:,2),theta); %plantar curve, engaged during plantar flexion
DorsalMoment = interp1(dorsal_pts(:,1),dorsal_pts(:,2),theta); %dorsal curve, engaged during dorsiflexion

%THESE LINES FIND THE ENERGY STORED AND RETURNED
[~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,DorsalIndex] = min(abs(DorsalMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:PlantarIndex),PlantarMoment(1:PlantarIndex)))) - max(abs(cumtrapz(theta(1:DorsalIndex),DorsalMoment(1:DorsalIndex)))); %Energy captured between the curves, when dorsal curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane

%THESE LINES MOVE THE PLANTAR CONTROL POINT #5 IN THE Y-DIRECTION UNTIL ENERGY IS EQUAL
knob = plantar_control_points(5,2)/(slope_scaling*pi/180);

    while ER>ES*1.0001
        knob = knob-0.001;
        %plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, knob, yp6, yp7]]';
        plantar_control_points(5,2) = knob;
        plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        PlantarMoment = interp1(plantar_pts(:,1),plantar_pts(:,2),theta);
        [~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled
    end

    while ER<ES*0.9999
        knob = knob+0.001;
        %plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, knob, yp6, yp7]]';
        plantar_control_points(5,2) = knob;
        plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        PlantarMoment = interp1(plantar_pts(:,1),plantar_pts(:,2),theta);
        [~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled
    end
    
% % %THIS PLOTS THE NEW CURVE, AFTER ENERGY HAS BEEN EQUALIZED
figure(1)
plot(theta*180/pi, PlantarMoment,'linewidth',3,'Color', [88 164 176]/255)
plot(plantar_control_points(:,1)*180/pi, plantar_control_points(:,2),'k.-')

%%%figure(1) plot settings
set(gcf,'color','w');
set(gca,'FontSize',25)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
xlim([-8 15])
ylim([-60 120])
legend('Initial Plantar', 'Final Dorsal', 'Plantar Control Points', 'Dorsal Control Points', 'Final Plantar', 'FontSize',20,'Location','northwest')
title('NURBS TA Curves')

%% Plotting the final TA curves
%%% Defining the ideal TA curves for plantarflexion and dorsi flexion
% PlantarMomentIdeal = interp1([pi/180*[-40 -30 -20 -10]' ; theta' ;pi/180*[12.5 15 22 30 40]'],[[-45 -45 -45 -10/180*pi*slope_scaling/2]' ; PlantarMoment';[12.5/180*pi*slope_scaling 15/180*pi*slope_scaling 120 120 120]'],theta_total,'spline');
% DorsalMomentIdeal = [PlantarMomentIdeal(1:pf_transition-1) DorsalMoment PlantarMomentIdeal(df_transition+1:end)];
DorsalMoment = scalefactor*DorsalMoment;
PlantarMoment = scalefactor*PlantarMoment;
th_plantar = deg2rad([-40 -30 -20]');
M_plantar = slope_plantar_rad*th_plantar;
th_dorsi = deg2rad([12.5 15 22 angle_leveling 28 34 40]');
M_dorsi = [slope_dorsi_deg*[rad2deg(th_dorsi(1:4))]; (slope_end_dorsi*(rad2deg(th_dorsi(5:end))-angle_leveling)+slope_dorsi_deg*angle_leveling)];
M_points = [M_plantar; PlantarMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
PlantarMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
DorsalMomentIdeal = [PlantarMomentIdeal(1:pf_transition-1) DorsalMoment PlantarMomentIdeal(df_transition+1:end)];

figure(2)
hold on 
% plot(theta_total*180/pi,PlantarMomentIdeal,'linewidth',3,'Color', [88 164 176]/255)
% plot(theta_total*180/pi,DorsalMomentIdeal,'linewidth',3,'Color', [255 136 0]/255)
plot(theta_total*180/pi,PlantarMomentIdeal,'k','linewidth',3)
plot(theta_total*180/pi,DorsalMomentIdeal,'k','linewidth',3)

%%%%LINEAR STRIPED LINES FOR THE LINEAR STIFFNESS
%%%%The desired TA curves are build around linear stiffness values
%%%Linear steps in angles
theta_plantar = pi/180*(-40:res:0-res);
theta_dorsal = pi/180*(0:res:40);

%%%Stiffness ration between linear plantar flexion and dorsiflexion slope is 1:2
PlantarLin = theta_plantar*slope_scaling/2; %linear torques in plantar flexion region
DorsalLin = theta_dorsal*slope_scaling; %linear torques in dorsiflexion region

%%%%Plotting
figure(2)
plot(theta_plantar*180/pi, PlantarLin, '--', 'linewidth',3, 'Color', [60 100 176]/255)
plot(theta_dorsal*180/pi, DorsalLin, '--', 'linewidth',3, 'Color', [120 164 120]/255)

% axis([-20 25 -60 150])
axis([-15 15 -30 65])
set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
set(gca, 'box', 'off')
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
legend('Final Plantar', 'Final Dorsal', 'Linear Plantar', 'Linear Dorsal', 'FontSize',20,'Location','northwest')
title('Torque angle curves')


%%%%%%%%%used later?
[~,PlantarMomentIdealIndex] = min(abs(PlantarMomentIdeal)); %FIND INDEX FOR WHEN PlantarMomentIdeal == 0(OR CLOSE)
[~,DorsalMomentIdealIndex] = min(abs(DorsalMomentIdeal)); %FIND INDEX FOR WHEN DorsalMomentIdeal == 0 (OR CLOSE)

%% Calculating the shape of the cam profile, FORWARD MODEL
%% MAKE DIFFERENCE BETWEEN FRONT AND BACK HARDSTOP!!!
x_center_max = 88;
x_center_min = 32.5;
%%%%initial requirements
x_spring = perc2mm([0,10.01,19.97,29.97,39.95,49.95,59.97,70.07,80.04,90.01,96.98],x_center_max,x_center_min);
k_spring = [0.166318991334212,0.208391576135634,0.282351259287986,0.374190624007133,0.489817440908308,0.631742113520826,0.796116260994716,1.01916697238319,1.34705270360385,1.70337140522367,2.13270292544089]*10^6;
titanium = polyfit(x_spring,k_spring,3);

x_titan = -x_center_max:1:x_center_min;
k_titan = polyval(titanium,-x_titan);
front_hardstop = 7.6; %front hardstop of the new ankle is 7.6mm posterior to the old ankle, front hardstop is further from the toes

%%%Choose a primary slider position
x_center_fw = -0.06025; %slider position, recalculated re lative to the follower center of rotation
primary_slider = x_center_fw*m2mm;

y_center = -0.008; %fixed, vertical distance between the bottom of the spring and the follower center of rotation
r0 = 0.03529;
cam_radius = 0.0085;
spring_preload = 0.0030; %to prevent backlash, the smaller the better, as it also places pressure on the slider below the spring

% % %spring properties
%The Stiffness vs Slider.Fig displays the stiffness values of the old and
%new ankle. For the new ankle, the new front hardstop should be taken into
%account.
%Data contains range of motion for both feet, where front and back hardstops differ
%adding a constant front hardstop 'shift' allows for zero/homing with blue ankle
%where home is 0mm
k_titanium_translational_fw = polyval(titanium,-primary_slider); 
krotary_fw = k_titanium_translational_fw*(x_center_fw)^2; %Translational stiffness to rotational stiffness

%% Forward model, torque angle curve to cam profile shape
%additional parameters
l_spring_fw = sqrt(x_center_fw^2+y_center^2) %absolute distance between top of pivot point and center of follower
d_fw = sqrt((-r0+y_center)^2+x_center_fw^2) %absolute distance between top of pivot point and ankle center of rotation
sigma_fw = atan((-r0+y_center)/x_center_fw) - atan(y_center/x_center_fw) %angle between l_spring and d

%torque angle curve work plantar curve
work_P_fw = cumtrapz(theta_total,PlantarMomentIdeal); %taking the area under the torque angle curve, energy in system
work_P_fw = work_P_fw - work_P_fw(PlantarMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%torque angle curve work dorsal curve
work_D_fw = cumtrapz(theta_total,DorsalMomentIdeal); %taking the area under the torque angle curve, energy in system
work_D_fw = work_D_fw - work_D_fw(DorsalMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%%Plantar cam profile
%frame work plantar
krotary_delta = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
%krotary_delta = 2000*1; %Fixed, stiffness of frame, FOR BOTH PLANTAR & DORSAL CURVE
delta_fw = PlantarMomentIdeal./krotary_delta; %Amount of deflection of the series compliance
work_delta_fw = 1/2.*krotary_delta.*delta_fw.^2; %Mechanical energy stored in the series compliance

%frame work dorsal
delta_fw2 = DorsalMomentIdeal./krotary_delta;
work_delta_fw2 = 1/2.*krotary_delta.*delta_fw2.^2;

theta_cam_fw = theta_total-delta_fw;
theta_cam_fw2 = theta_total-delta_fw2;

gammao = spring_preload; %fixed
% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a = krotary_fw./2;
b = krotary_fw.*gammao;
c = work_delta_fw-(work_P_fw); 

% Here is the solution to the quadratic equation:
gamma_fw = (-b+sqrt(b.^2-4.*a.*c))./(2*a);
r = sqrt(l_spring_fw^2 + d_fw^2 - 2*l_spring_fw*d_fw*cos(gamma_fw+sigma_fw)); %law of cosines

% Find psi, which is what r needs to be a function of. Basically because the
% roller does not go straight down, we can't use theta as our angle for the
% polar coordinates in the cam's reference frame

angle_constant_fw = atan((y_center-r0)/x_center_fw); %This is the angle between d and the bottom of the spring
omega_fw = asin(l_spring_fw./r.*sin(gamma_fw+sigma_fw)); %This is the angle between r and d (law of sines)
alpha_fw = omega_fw + angle_constant_fw-pi/2; %This is the deviation from vertical that the spring has gone, in terms of angle from ankle center
%%%%i.e omega-alpha gives ankle with vertical, angle_constant is angle with
%%%%horizontal. triangle is 180 degrees. the angle between horizontal and
%%%%vertical line is pi/2
psi = theta_cam_fw-alpha_fw; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r

% Make Offset 
y = r.*sin(psi);
x = r.*cos(psi);

%calculations are done for the deflection of the follower center of rotation
%Use parallel theorem as the follower outer radius is in contact with the
%cam profile 

% % %useful link
% % % https://en.wikipedia.org/wiki/Parallel_curve 
% % % Follow equations under: "Parallel curve of a parametricaly given curve"
% % % x(t) becomes x(psi), x changes due to psi
% % % x'(t) becomes diff(x)./diff(psi)
% % % d = -cam_radius, as cam follower center is lower, more negative, than x

xprime = diff(x)./diff(psi);
    xprime(end+1) = xprime(end);
yprime = diff(y)./diff(psi);
    yprime(end+1) = yprime(end);
curve_x = x + -cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
curve_y = y + -cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);

%%Dorsal cam profile spring
%additional parameters
%%%gamma2o is the preload calculation of the spring at midstance, where the
%%%dorsal curve is at zero-torque. It is assumed that the energy stored in
%%%the spring can be dictated by the following equation:
%%%Energy = 0.5*krotary_fw*delta_gamma, where krotary is the spring
%%%stiffnes, and delta_gamma = gamma2o - gammao
gamma2o = sqrt((ES+0.5*krotary_fw*gammao.^2)/(0.5*krotary_fw))-gammao; 
sigma_fw2 = sigma_fw + gamma2o;

% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a2 = krotary_fw./2;
b2 = krotary_fw.*(gamma2o+gammao); %gamma2o depends on the amount of caputered energy and the spring stiffness value
c2 = work_delta_fw2-(work_D_fw); 

% Here is the solution to the quadratic equation:
gamma_fw2 = (-b2+sqrt(b2.^2-4.*a2.*c2))./(2*a2);
r2 = sqrt(l_spring_fw^2 + d_fw^2 - 2*l_spring_fw*d_fw*cos(gamma_fw2+sigma_fw2)); %law of cosines

angle_constant_fw2 = angle_constant_fw + gamma2o;
omega_fw2 = asin(l_spring_fw./r2.*sin(gamma_fw2+sigma_fw2)); %This is the angle between r and d (law of sines)
alpha_fw2 = omega_fw2 + angle_constant_fw-pi/2; %angle between d and vertical minus omega_fw2
psi2 = theta_cam_fw2-alpha_fw2; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r

% Make Offset 
y2 = r2.*sin(psi2);
x2 = r2.*cos(psi2);

xprime2 = diff(x2)./diff(psi2);
    xprime2(end+1) = xprime2(end);
yprime2 = diff(y2)./diff(psi2);
    yprime2(end+1) = yprime2(end);
curve_x2 = x2 + -cam_radius.*yprime2./sqrt(xprime2.^2 + yprime2.^2);
curve_y2 = y2 + -cam_radius.*-xprime2./sqrt(xprime2.^2 + yprime2.^2);

%% Plotting the cam profiles
figure(3); hold on;

%%%%The figures plotted have a layout of (-y,x) to illustrate the cam
%%%%in a more intuitive manner. In an orientation, as it will be placed in
%%%%the physical device

%%%%Offset curves after applying the parallel theorem
%%%Plantar
plot(curve_y,-curve_x, 'Color', [88 164 176]/255,'linewidth',2)
%%%Dorsal
plot(curve_y2,-curve_x2, 'Color', [255 136 0]/255,'linewidth',2)

%%%Non-offset curves
%%%Plantar
plot(y,-x, '--', 'Color', [88 164 176]/255,'linewidth',2)
%%%Dorsal
plot(y2,-x2, '--', 'Color', [255 136 0]/255,'linewidth',2)

plot(0,0,'g*','linewidth',8) %ankle center of rotation

set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
set(gca, 'box', 'off')
axis equal
xlabel('(m)')
ylabel('(m)')
legend('Offset Plantar Cam', 'Offset Dorsal Cam', 'Non Offset Plantar Cam', 'Non Offset Dorsal Cam', 'Ankle Center of Rotation', 'FontSize',20,'Location','northwest')
title('Shape of the cam profile')

%% Inverse model, determining the torque angle curve at different spring stiffness values, for a pre-set cam profile

x_center_inv = -perc2mm([50],x_center_max,x_center_min);
ktranslational_inv = [polyval(titanium,-x_center_inv)];
x_center_inv = x_center_inv*mm2m;


%% change MS, PlantarMomentAnkle, PlantarMomentAnkle, Mi, yM, yL
vert_preload_inv = x_center_fw.*tan(spring_preload); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./x_center_inv);  %This allows the preload to update as the slider moves

vert_preload_inv2 = x_center_fw.*tan(gamma2o + spring_preload); %This is the translational equivalent to the rotational preload for the second torque angle curve
spring_preload_inv2 = atan(vert_preload_inv2./x_center_inv);

COL = [0.99 0.878 0.8235; 0.937 0.231 0.172;0.403 0 0.0509];
z = [0.08,0.2,0.3,0.45,0.72,0.85];
TRUECOL = interp1(linspace(0,1,3),COL,z,'pchip');

figure(2)
hold on
set(gcf,'DefaultAxesColorOrder',TRUECOL);

for i = 1:length(x_center_inv)
    %%%constant variables that are equal for the plantar and dorsal curves
    %%%for a given slider position e.g. they don't change throughout the gait
    l_spring_inv(i) = sqrt(x_center_inv(i).^2+y_center^2);
    d_inv(i) = sqrt((-r0+y_center)^2+x_center_inv(i).^2);
    sigma_inv(i) = atan(x_center_inv(i)/y_center)-atan(x_center_inv(i)/(-r0+y_center)); %This is the angle between virtual spring and line through spring centers
    angle_constant_inv(i) = atan((y_center-r0)/x_center_inv(i));
    
    %%Plantar curve
    omega_inv = acos((l_spring_inv(i).^2 - r.^2 - d_inv(i).^2)./(-2*r.*d_inv(i)));
    alpha_inv = omega_inv+angle_constant_inv(i)-pi/2;
    theta_cam_inv = alpha_inv + psi; 
    gamma_inv = acos((r.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv(i);
    
    krotary_inv(i) = ktranslational_inv(i).*x_center_inv(i)^2;
    PlantarMomentSpring = krotary_inv(i)*(gamma_inv + spring_preload_inv(i)); 
    work_spring_inv = cumtrapz(gamma_inv,PlantarMomentSpring);

    PlantarMomentAnkle = diff(work_spring_inv)./diff(theta_cam_inv);
    PlantarMomentAnkle(end+1) = PlantarMomentAnkle(end);

    delta_inv = PlantarMomentAnkle./krotary_delta;    
    
    theta_inv = theta_cam_inv + delta_inv;

    %Dorsal curve
    sigma_inv2 = sigma_inv + spring_preload_inv2(i) - spring_preload_inv(i);
    angle_constant_inv2(i) = angle_constant_inv(i) + spring_preload_inv2(i) - spring_preload_inv(i);
    
    omega_inv2 = acos((l_spring_inv(i).^2 - r2.^2 - d_inv(i).^2)./(-2*r2.*d_inv(i))); %law of cosines
    alpha_inv2 = -(atan(x_center_inv(i)/(-r0+y_center)) - omega_inv2);
    theta_cam_inv2 = alpha_inv2 + psi2;
    gamma_inv2 = acos((r2.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv2(i);

    DorsalMomentSpring = krotary_inv(i)*(gamma_inv2 + spring_preload_inv2(i));  
    work_spring_inv2 = cumtrapz(gamma_inv2 ,DorsalMomentSpring); 

    DorsalMomentAnkle = diff(work_spring_inv2)./diff(theta_cam_inv2); 

    DorsalMomentAnkle(end+1) = DorsalMomentAnkle(end);

    delta_inv2 = DorsalMomentAnkle./krotary_delta;

    theta_inv2 = theta_cam_inv2 + delta_inv2;

    %%%Namig legend items, so repetitive legend enteries can be avoided in
    %%%the final plot
%     leg1(i) = plot(theta_inv/pi*180,PlantarMomentAnkle,'-','Linewidth',6,'Color', [88 164 176]/255); %legend item 1, inverse plantar flexion curve per iteration of slider position
% 	leg2(i) =  plot(theta_inv2/pi*180,DorsalMomentAnkle,'-','Linewidth',6,'Color', [255 136 0]/255); %legend item 1, inverse dorsiflexion curve per iteration of slider position
    leg1(i) = plot(theta_inv/pi*180,PlantarMomentAnkle,'-','Linewidth',4,'Color', 'k'); %legend item 1, inverse plantar flexion curve per iteration of slider position
	leg2(i) =  plot(theta_inv2/pi*180,DorsalMomentAnkle,'-','Linewidth',4,'Color', 'k'); %legend item 1, inverse dorsiflexion curve per iteration of slider position
end

figure(4)
leg3 = plot(theta_total/pi*180,PlantarMomentIdeal,'Linewidth',12,'Color','k','LineStyle','--'); %legend item 3, forward plantar flexion curve per iteration of slider position
leg4 = plot(theta_total/pi*180,DorsalMomentIdeal,'Linewidth',12,'Color',[195,195,195]/255,'LineStyle','--'); %legend item 1, forward dorsiflexion curve per iteration of slider position
set(gcf,'color','w');
set(gca,'FontSize',35)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
legend([leg1(1) leg2(1) leg3 leg4],{'Inverse model plantar','Inverse model dorsal', 'Desired curve plantar', 'Desired curve dorsal'},'Location','northwest')

xlim([-8 15])
% ylim([-60 150])
ylim([-30 50])
title('Inverse model at different slider positions')

%% Functions

function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end