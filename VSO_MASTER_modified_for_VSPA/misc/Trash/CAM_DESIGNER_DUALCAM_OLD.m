%% NEUROBIONICS LAB

%Dual Cam VSO Orthosis Cam Profile Derivation
%Nikko Van Crey (nikkovc@umich.edu) and Hashim Quaraishi

clear
%close all
%close all hidden
addpath('IMPORTS')
addpath('IMPORTS/nurbs_toolbox')

%% DESIGN PARAMETERS
%MISC
ROM_thresh = deg2rad(27); %nikkROM that Cam forces are evaluated at
preload = 0.0030; %to prevent backlash, the smaller the better, as it also places pressure on the slider below the spring
kdelt = 600; % [Nm/rad] Fixed, stiffness of frame, FOR BOTH PLANTAR & DORSAL CURVE
primary_percentage = 0.5;

%Geometric Parameters
y_center = -0.008;% 0.008(m) Distance between top of simple support and cam roller axis
x_center_max = 89;
x_center_min = 32.5;
r0 = 0.03529;
% cam_radius = 0.008; %small separable rollers
cam_radius = 0.0095;
x_off = 0;

%% To Do
%PRELOAD IS 1 DEG RN!!!
%update cam force calculation
%doubel check that geometry is up to date
%format like other cam designer script

%% CONFIGURABLES

message_box = 1;
%Inverse Model
primary = 1;
misc = 0;
max_min_primary = 1;
extreme = 0;
plot_all = 0;
%Device
VSPA = 0;
VSO = 1;

%% PLOTTING OPTIONS

transition_mark = 0;
plantar_cam = 1;
dorsi_cam = 1;

%% IMPORT STUFF

load('IMPORTS/Conversions.mat')

%% Initialize
transition = [];
%----
F_cam = [];
F_cam_2 = [];
s_lin = [];
%----
ES_array = [];
ER_array = [];
midstance_energy_array = [];
dorsi_energy_array = [];
pushoff_energy_array = [];
ExpectedAdditionalEnergy_Percent_array = [];



%% Initial variables
max_dorsiflexion = 10;     %degrees
max_plantarflexion = 5;    %degrees
res = 0.005;               %resolution, step size between data points
theta = pi/180*(-max_plantarflexion:res:max_dorsiflexion);  %angles in energy recycling range, in radians
theta_total = pi/180*(-40:res:40);  %radians.

pf_transition = find (theta_total==-max_plantarflexion*pi/180);
df_transition = find (theta_total==max_dorsiflexion*pi/180);



%% Design Parameters
if(VSO)
    %scalefactor = 0.34; %C1 will break at 0.4
    scalefactor = 0.2; %C2
end

%SLOPE Parameters
slope_scaling = 450; %This is the desired dorsi slope in Nm/rad
slope_deg = slope_scaling/rad2deg(1);
slope_end_dorsi = 0.5*slope_deg;
plantar_scaling = 0.5;
slope_end_plantar = 1.0*plantar_scaling*slope_deg;
angle_leveling = 25; %Dorsiflexion Angle that leveling begins

%% SPRING SELECTION
x_FEA = flip([36.2580000000000,41.9960000000000,47.7340000000000,53.4720000000000,59.2100000000000,64.9480000000000,70.6860000000000,76.4240000000000,82.1620000000000]);
k_FEA = [0.432465001702156,0.616126941919261,0.792258272479587,1.01274888074353,1.30070171341660,1.66157226218556,2.08664716371367,2.60261456478173,3.26999324785601]*10^6;
titanium = polyfit(x_FEA,k_FEA,3);
x_titan = x_center_max:-1:x_center_min;
k_titan = polyval(titanium,x_titan);

%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
figure
hold on
plot(x_FEA,k_FEA,'Linewidth',5)
plot(x_titan,k_titan)
legend('FEA','Fit')


%% Using NURBS to determine the desired Torque-Angle (TA) curves]
% % %THESE LINES DEFINE CONTROL POINTS FOR THE NURBS. THE FIRST COLUMN IS
% % %DEFINED IN DEGREES WITH WHOLE NUMBERS AND THEN CONVERTED TO RADIANS. THE
% % %SECOND COLUMN ASSUMES A SLOPE OF 1 NM/rad FOR DORSIFLEXION, AND THEN IS
% % %SCALED BY THE SLOPE SCALING FACTOR. THE LAST TWO POINTS ON EACH SIDE OF
% % %EACH CURVE HAVE TO DEFINE A LINE THAT GOES THROUGH ZERO (THIS MAKES IT
% % %TANGENT TO THE LINE ADDED LATER)

%%%The control points of the plantar curve are assigned a variable, as
%%%these will change later on in an iteration. 
if(VSPA)
    scalefactor = 1;
    xp1 = -5; xp2 = -4.5; xp3 = 0; xp4 = 1.8;  xp5 = 5.7;  xp6 = 9.5;  xp7 = 10;
    yp1 = -2.5; yp2 = -2.25; yp3 = -1.7; yp4 = 0; yp5 = 5; yp6 = 9.5;  yp7 = 10;
    dorsal_control_points = [pi/180*[-5, -4.5, -3, 0, 6.3, 9.5, 10]; slope_scaling*pi/180*[-2.5, -2.25, 0.7, 1.3, 3, 9.5, 10]]';
end
if(VSO)  
       xp1 = -5; xp2 = -4.5; xp3 = 0.3; xp4 = 2.1;  xp5 = 5.7;  xp6 = 9.5;  xp7 = 10;
       yp1 = -2.5; yp2 = -2.25; yp3 = -2.0; yp4 = -0.8; yp5 = 5.5; yp6 = 9.5;  yp7 = 10;
       dorsal_control_points = [pi/180*[-5, -4.5, -2.5, 0, 6.4, 9.5, 10]; slope_scaling*pi/180*[-2.5, -2.25, 0, 0.2, 1.5, 9.5, 10]]';
end

%%%The control points of the drosal curve are filled in directly, as the
%%%are no loger changed hereafter
plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, yp5, yp6, yp7]]';

plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]); %equally spaced knots, but doesn't have to be
plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv object
dorsal_crv = nrbmak(dorsal_control_points',[0 0 0 0.2, 0.4 0.6, 0.8 1 1 1]);  %equally spaced knots, but doesn't have to be
dorsal_pts = nrbeval(dorsal_crv,linspace(0.0,1.0,100))'; %evaluate the crv object

%% Plotting TA curves, using the NURBS control points
figure(1); hold on; grid on
plot(plantar_pts(:,1)*180/pi, plantar_pts(:,2),'b:','Linewidth',5)
plot(dorsal_pts(:,1)*180/pi, dorsal_pts(:,2),'Linewidth',5,'Color', [255 136 0]/255)
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
        plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, knob, yp6, yp7]]';
        plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        PlantarMoment = interp1(plantar_pts(:,1),plantar_pts(:,2),theta);
        [~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled
    end

    while ER<ES*0.9999
        knob = knob+0.001;
        plantar_control_points = [pi/180*[xp1, xp2, xp3, xp4, xp5, xp6, xp7]; slope_scaling*pi/180*[yp1, yp2, yp3, yp4, knob, yp6, yp7]]';
        plantar_crv = nrbmak(plantar_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        plantar_pts = nrbeval(plantar_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        PlantarMoment = interp1(plantar_pts(:,1),plantar_pts(:,2),theta);
        [~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled
    end
    
% % %THIS PLOTS THE NEW CURVE, AFTER ENERGY HAS BEEN EQUALIZED
figure(1)
plot(theta*180/pi, PlantarMoment,'Linewidth',5,'Color', [88 164 176]/255)
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


%% -----------------------------------------------------------ENERGY2-----------------------------------------------------
%THESE LINES FIND THE ENERGY STORED AND RETURNED
DorsalMoment = scalefactor*DorsalMoment;
PlantarMoment = scalefactor*PlantarMoment;
[~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,DorsalIndex] = min(abs(DorsalMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:PlantarIndex),PlantarMoment(1:PlantarIndex)))) - max(abs(cumtrapz(theta(1:DorsalIndex),DorsalMoment(1:DorsalIndex)))); %Energy captured between the curves, when dorsal curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane
midstance_energy = ES; %Energy stored at midstance (J)
dorsi_energy = max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end))));%Energy stored over dorsiflexion (J)
pushoff_energy = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))); %Energy returned during pushoff (J)
ExpectedAdditionalEnergy_Percent = 100+(pushoff_energy-dorsi_energy)/dorsi_energy*100; %Energy returned (%)

figure
hold on
plot(theta(1:PlantarIndex),PlantarMoment(1:PlantarIndex),'Linewidth',4) %1
plot(theta(1:DorsalIndex),DorsalMoment(1:DorsalIndex),'Linewidth',4) %2
plot(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end),'Linewidth',4) %3
plot(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end),'Linewidth',4) %4
legend('1','2','3','4')
DorsalMoment = (1/scalefactor)*DorsalMoment;
PlantarMoment = (1/scalefactor)*PlantarMoment;
%------------------------------------------------------------------------------------------

%% Plotting the final TA curves
%%% Defining the ideal TA curves for plantarflexion and dorsi flexion
th_plantar = pi/180*[-40 -30 -20 -10]';
%M_plantar = [-65 -55 -45 -10/180*pi*slope_scaling/2]';
M_plantar = [(slope_end_plantar*([-40 -30 -20]+10)+plantar_scaling*slope_deg*(-10)) plantar_scaling*slope_deg*(-10)]';
th_dorsi = pi/180*[12.5 15 22 25 28 34 40]';
M_dorsi = [slope_deg*[12.5 15 22 angle_leveling] (slope_end_dorsi*([28 34 40]-angle_leveling)+slope_deg*angle_leveling)]';
M_points = [M_plantar; PlantarMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
PlantarMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
DorsalMomentIdeal = [PlantarMomentIdeal(1:pf_transition-1) DorsalMoment PlantarMomentIdeal(df_transition+1:end)];
%Scaling------(Nikko)
PlantarMomentIdeal = scalefactor*PlantarMomentIdeal;
DorsalMomentIdeal = scalefactor*DorsalMomentIdeal;

figure
hold on 
plot(theta_total*180/pi,PlantarMomentIdeal,'linewidth',4,'Color', [88 164 176]/255)
plot(theta_total*180/pi,DorsalMomentIdeal,'linewidth',4,'Color', [255 136 0]/255)
%plot(rad2deg(theta_points),scalefactor*M_points,'x','Linewidth',2,'markers',10,'Color',[1 0 0])

%%%%LINEAR STRIPED LINES FOR THE LINEAR STIFFNESS
%%%%The desired TA curves are build around linear stiffness values
%%%Linear steps in angles
theta_plantar = pi/180*(-40:res:0-res);
theta_dorsal = pi/180*(0:res:40);

%%%Stiffness ration between linear plantar flexion and dorsiflexion slope is 1:2
PlantarLin = theta_plantar*plantar_scaling*slope_scaling; %linear torques in plantar flexion region
DorsalLin = theta_dorsal*slope_scaling; %linear torques in dorsiflexion region

%%%%Plotting
plot(theta_plantar*180/pi, scalefactor*PlantarLin, '--', 'Linewidth',5, 'Color', [60 100 176]/255)
plot(theta_dorsal*180/pi, scalefactor*DorsalLin, '--', 'Linewidth',5, 'Color', [120 164 120]/255)
%plot(2.51,0.00638,'g*','linewidth',5) %ankle center of rotation
legend boxoff

%axis([-25 40 -50 145])
axis([-15 15 -30 65])
set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
set(gca, 'box', 'off')
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
legend('Final Plantar', 'Final Dorsal', 'Linear Plantar', 'Linear Dorsal', 'Equilibrium Point','FontSize',16,'Location','northwest')
title('Torque angle curves')


%%%%%%%%%used later?
[~,PlantarMomentIdealIndex] = min(abs(PlantarMomentIdeal)); %FIND INDEX FOR WHEN PlantarMomentIdeal == 0(OR CLOSE)
[~,DorsalMomentIdealIndex] = min(abs(DorsalMomentIdeal)); %FIND INDEX FOR WHEN DorsalMomentIdeal == 0 (OR CLOSE)



%% Check to see if the cam slope is postive
slope_plantar_error = [];
slope_dorsal_error = [];

for i = 2:length(PlantarMomentIdeal)
    if((PlantarMomentIdeal(i)-PlantarMomentIdeal(i-1))<=0)
        slope_plantar_error = [PlantarMomentIdeal(i); theta_total(i)*180/pi];
    end
end
for i = 2:length(DorsalMomentIdeal)
    if ((DorsalMomentIdeal(i)-DorsalMomentIdeal(i-1))<=0)
        slope_dorsal_error = [DorsalMomentIdeal(i); theta_total(i)];
    end
end
slope_plantar_error
slope_dorsal_error


%% Calculating the shape of the cam profile, FORWARD MODEL

stroke = x_center_max-x_center_min;
x_center = -(x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = -x_center*m2mm;


%Forward model, torque angle curve to cam profile shape
%additional parameters
L = sqrt(x_center^2+y_center^2); %absolute distance between top of pivot point and center of follower
d = sqrt((-r0+y_center)^2+x_center^2); %absolute distance between top of pivot point and ankle center of rotation
sigma = atan((-r0+y_center)/x_center) - atan(y_center/x_center); %angle between l_spring and d

%torque angle curve work plantar curve
work_P_fw = cumtrapz(theta_total,PlantarMomentIdeal); %taking the area under the torque angle curve, energy in system
work_P_fw = work_P_fw - work_P_fw(PlantarMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%torque angle curve work dorsal curve
work_D_fw = cumtrapz(theta_total,DorsalMomentIdeal); %taking the area under the torque angle curve, energy in system
work_D_fw = work_D_fw - work_D_fw(DorsalMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%%Plantar cam profile
%frame work plantar
k_series_linear = (kdelt*2*pi()/360); %Linear stiffness
delta = PlantarMomentIdeal./kdelt; %Amount of deflection of the series compliance
work_delta_fw = 1/2*kdelt*delta.^2; %Mechanical energy stored in the series compliance

%frame work dorsal
delta_fw2 = DorsalMomentIdeal./kdelt;
work_delta_fw2 = 1/2*kdelt.*delta_fw2.^2;

theta_cam_fw = theta_total-delta;
theta_cam_fw2 = theta_total-delta_fw2;

gammao = preload; %fixed\
k = polyval(titanium,primary_slider)*(x_center)^2; %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L
% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a = k./2;
b = k.*gammao;
c = work_delta_fw-(work_P_fw); 

% Here is the solution to the quadratic equation:
gamma_fw = (-b+sqrt(b.^2-4.*a.*c))./(2*a);
r = sqrt(L^2 + d^2 - 2*L*d*cos(gamma_fw+sigma)); %law of cosines

% Find psi, which is what r needs to be a function of. Basically because the
% roller does not go straight down, we can't use theta as our angle for the
% polar coordinates in the cam's reference frame

angle_constant_fw = atan((y_center-r0)/x_center); %This is the angle between d and the bottom of the spring
omega_fw = asin(L./r.*sin(gamma_fw+sigma)); %This is the angle between r and d (law of sines)
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
%%%Energy = 0.5*k*delta_gamma, where krotary is the spring
%%%stiffnes, and delta_gamma = gamma2o - gammao
gamma2o = sqrt((ES+0.5*k*gammao.^2)/(0.5*k))-gammao; 
sigma_fw2 = sigma + gamma2o;

% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a2 = k./2;
b2 = k.*(gamma2o+gammao); %gamma2o depends on the amount of caputered energy and the spring stiffness value
c2 = work_delta_fw2-(work_D_fw); 

% Here is the solution to the quadratic equation:
gamma_fw2 = (-b2+sqrt(b2.^2-4.*a2.*c2))./(2*a2);
r2 = sqrt(L^2 + d^2 - 2*L*d*cos(gamma_fw2+sigma_fw2)); %law of cosines

angle_constant_fw2 = angle_constant_fw + gamma2o;
omega_fw2 = asin(L./r2.*sin(gamma_fw2+sigma_fw2)); %This is the angle between r and d (law of sines)
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

%% Transition Angles
%dt: dorsiflexion transition
%pt: plantarflexion transition
transition_dorsi = max_dorsiflexion;
transition_plantar = -1*max_plantarflexion;
M_dt = DorsalMomentIdeal(find(theta_total==deg2rad(transition_dorsi)))
M_pt = PlantarMomentIdeal(find(theta_total==deg2rad(transition_plantar)))
thd_adjust = rad2deg(M_dt/kdelt)
thp_adjust = rad2deg(M_pt/kdelt)
thd_magnet = transition_dorsi-thd_adjust
thp_magnet = transition_plantar-thp_adjust
index_dt = find(theta_total==deg2rad(transition_dorsi));
index_pt = find(theta_total==deg2rad(transition_plantar));
rad2deg(theta_cam_fw(index_dt))
rad2deg(delta(index_dt))
x_dt = curve_x(index_dt)
y_dt = curve_y(index_dt)
x_pt = curve_x(index_pt)
y_pt = curve_y(index_pt)
ang_dt = atand(y_dt/x_dt)
ang_pt = atand(y_pt/x_pt)


%% Check to see if cam curve intersects itself
intersections_left = [];
intersections_right = [];
for i = 2:length(curve_y2)
    if((curve_y(i)-curve_y(i-1))<0) 
        intersections_right = [intersections_right; curve_y(i)];
    end
    if((curve_y2(i)-curve_y2(i-1))<0) 
        intersections_left = [intersections_left; curve_y(i)];
    end
end
intersections_left
intersections_right
%% Plotting the cam profiles
figure(9); hold on;

%%%%The figures plotted have a layout of (-y,x) to illustrate the cam
%%%%in a more intuitive manner. In an orientation, as it will be placed in
%%%%the physical device

%%%%Offset curves after applying the parallel theorem
%%%Plantar
plot(curve_y,-curve_x, 'Color', [88 164 176]/255,'Linewidth',1)
%%%Dorsal
plot(curve_y2,-curve_x2, '--','Color', [255 136 0]/255,'Linewidth',1)

%%%Non-offset curves
%%%Plantar
%plot(y,-x, '--', 'Color', [88 164 176]/255,'Linewidth',5)
%%%Dorsal
%plot(y2,-x2, '--', 'Color', [255 136 0]/255,'Linewidth',5)

%plot(0,0,'g*','linewidth',8) %ankle center of rotation

set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
set(gca, 'box', 'off')
axis equal
xlabel('(m)')
ylabel('(m)')
%legend('Offset Plantar Cam', 'Offset Dorsal Cam', 'Non Offset Plantar Cam', 'Non Offset Dorsal Cam', 'Ankle Center of Rotation', 'FontSize',20,'Location','northwest')
legend('Plantarflexion Cam', 'Dorsiflexion Cam','Ankle Center of Rotation')
legend box off
title('Forward Model')

% Export to Solidworks
new_x = curve_x(2:10:length(curve_x)); 
new_y = interp1(curve_x,curve_y,new_x);
new_x2 = curve_x2(2:10:length(curve_x2)); 
new_y2 = interp1(curve_x2,curve_y2,new_x2);
curve_points_plantar = 1000*[new_x', new_y', 0.*new_x'];
curve_points_dorsal = 1000*[new_x2', new_y2', 0.*new_x2'];
%curve_points = sortrows(curve_points, 2);
dlmwrite('cam_curve_plantar.txt', curve_points_plantar, '\t')   
dlmwrite('cam_curve_dorsal.txt', curve_points_dorsal, '\t') 




%% Inverse model, determining the torque angle curve at different spring stiffness values, for a pre-set cam profile

%%%lowest, mid and highest. So the comparison plot is more clear
% x_center_inv_vec = -[x_center_max, primary_slider, x_center_min]*mm2m; 
% ktranslational_inv = [polyval(titanium,x_center_max) polyval(titanium,primary_slider) polyval(titanium,x_center_min)];

if(primary)
    x_center_inv_vec = -[primary_slider]*mm2m;
    ktranslational_inv = [polyval(titanium,primary_slider)];
end

if(misc)
    x_center_inv_vec = -[x_center_max, (x_center_max+primary_slider)/2, primary_slider, (primary_slider+x_center_min)/2, x_center_min]*mm2m; %same as [0, 33, 45]-33;
    ktranslational_inv = [polyval(titanium,x_center_max) polyval(titanium,(x_center_max+primary_slider)/2) polyval(titanium,primary_slider) polyval(titanium,(primary_slider+x_center_min)/2) polyval(titanium,x_center_min)];
end

if(max_min_primary)
    x_center_inv_vec = -[x_center_max, primary_slider, x_center_min]*mm2m; %same as [0, 33, 45]-33;
    ktranslational_inv = [polyval(titanium,x_center_max) polyval(titanium,primary_slider) polyval(titanium,x_center_min)];
end

if(extreme)
    extreme_scale = 0.9;
    x_center_inv_vec = -[x_center_max, (x_center_max+primary_slider)/2, primary_slider, primary_slider-extreme_scale*(primary_slider-x_center_min), x_center_min]*mm2m; %same as [0, 33, 45]-33;
    ktranslational_inv = [polyval(titanium,x_center_max) polyval(titanium,(x_center_max+primary_slider)/2) polyval(titanium,primary_slider) polyval(titanium,primary_slider-extreme_scale*(primary_slider-x_center_min)) polyval(titanium,x_center_min)];
end

if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = [floor(x_center_max):-1:ceil(x_center_min)];
    k_VSO_all = polyval(titanium,x_VSO_all);
    x_center_inv_vec = -x_VSO_all*mm2m;
    ktranslational_inv = k_VSO_all;
end

%x_center_inv = (96*mm2m-primary_slider - x_center_inv_vec); %Hashim
x_center_inv = x_center_inv_vec;
%% change MS, PlantarMomentAnkle, PlantarMomentAnkle, Mi, yM, yL

vert_preload_inv = x_center.*tan(preload); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./x_center_inv);  %This allows the preload to update as the slider moves

vert_preload_inv2 = x_center.*tan(gamma2o + preload); %This is the translational equivalent to the rotational preload for the second torque angle curve
spring_preload_inv2 = atan(vert_preload_inv2./x_center_inv);

COL = [0.99 0.878 0.8235; 0.937 0.231 0.172;0.403 0 0.0509];
z = [0.08,0.2,0.3,0.45,0.72,0.85];
TRUECOL = interp1(linspace(0,1,3),COL,z,'pchip');

figure(5)
hold on
set(gcf,'DefaultAxesColorOrder',TRUECOL);

for i = 1:length(x_center_inv)
    transition = [];
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

    delta_inv = PlantarMomentAnkle./kdelt;    
    
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

    delta_inv2 = DorsalMomentAnkle./kdelt;

    theta_inv2 = theta_cam_inv2 + delta_inv2;

    %%%Naming legend items, so repetitive legend enteries can be avoided in
    %%%the final plot
    if(plantar_cam)
        leg1(i) = plot(theta_inv/pi*180,PlantarMomentAnkle,'-','Linewidth',6,'Color', [88 164 176]/255); %legend item 1, inverse plantar flexion curve per iteration of slider position
    end
    if(dorsi_cam)
        leg2(i) =  plot(theta_inv2/pi*180,DorsalMomentAnkle,'-','Linewidth',6,'Color', [255 136 0]/255); %legend item 1, inverse dorsiflexion curve per iteration of slider position
    end
    %Cam Forces---------------------
%     d_lin = x_center_inv(i)*(gamma_inv2(end)+delta_inv2(end));
%     F_cam = [F_cam (1/ktranslational_inv(i)+1/(kdelt./(x_center_inv(i))^2))^(-1).*d_lin];
    
    %Cam Forces---------------------
    %r_test = (40+(100-primary_slider));
    ROM_index = find(abs(theta_inv2-ROM_thresh)<0.0001);
    s_tot = x_center_inv(i)*(gamma_inv2(ROM_index(1))+delta_inv2(ROM_index(1)));
%     s_lin = [s_lin L(i)*(gamma_new(ROM_index(1))+ preload_new(i))];
    F_cam = [F_cam (1/ktranslational_inv(i)+1/(kdelt./(x_center_inv(i))^2))^(-1).*s_tot];
    F_cam_2 = [F_cam_2 DorsalMomentAnkle(ROM_index(1))./l_spring_inv(i)];
    s_lin = [s_lin F_cam_2(i)/ktranslational_inv(i)*10^6];
    
    %Energy
    difference = abs(DorsalMomentAnkle-PlantarMomentAnkle);
    transition_tolerance = 0.005; %0.005
    check = difference<transition_tolerance;
    for j=2:length(check)
        if(((theta_total(j)/pi*180)<-1) | ((theta_total(j)/pi*180)>5))%(((DorsalMomentAnkle(j)<-2) | (DorsalMomentAnkle(j)>8))&(abs(rad2deg(theta_inv(j)))<20))
            if(check(j)~=check(j-1))
                transition = [transition;j];
            end
        end
    end
    transition = [transition(1:2)];
    if(length(transition)~=2)
        disp('Transition Incorrect:')
        x_center_inv(i)
    else
            transition;
    end
    if(transition_mark)
        plot(rad2deg(theta_inv(transition)),DorsalMomentAnkle(transition),'x','Linewidth',5,'markers',15,'Color',[1 0 0])
    end
    [~,PlantarIndex_new] = min(abs(PlantarMomentAnkle)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
    [~,DorsalIndex_new] = min(abs(DorsalMomentAnkle)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
    ES_new = max(abs(cumtrapz(theta_inv(1:PlantarIndex_new),PlantarMomentAnkle(1:PlantarIndex_new)))) - max(abs(cumtrapz(theta_inv(1:DorsalIndex_new),DorsalMomentAnkle(1:DorsalIndex_new)))); %Energy captured between the curves, when dorsal curve reaches zero-torque. In the bottom left quadrant of the TA plane
    ER_new = max(abs(cumtrapz(theta_inv(PlantarIndex_new:end),PlantarMomentAnkle(PlantarIndex_new:end)))) - max(abs(cumtrapz(theta_inv(DorsalIndex_new:end),DorsalMomentAnkle(DorsalIndex_new:end)))); %Energy recycled, in the top right quadrant of the TA plane
    midstance_energy_new = ES; %Energy stored at midstance (J)
    dorsi_energy_new = max(abs(cumtrapz(theta_inv(DorsalIndex_new:transition(2)),DorsalMomentAnkle(DorsalIndex_new:transition(2)))));%Energy stored over dorsiflexion (J)
    pushoff_energy_new = max(abs(cumtrapz(theta_inv(PlantarIndex_new:transition(2)),PlantarMomentAnkle(PlantarIndex_new:transition(2))))); %Energy returned during pushoff (J)
    ExpectedAdditionalEnergy_Percent_new = 100+(pushoff_energy_new-dorsi_energy_new)/dorsi_energy_new*100; %Energy returned (%)
    ES_array = [ES_array ES_new];
    ER_array = [ER_array ER_new];
    midstance_energy_array = [midstance_energy_array midstance_energy_new];
    dorsi_energy_array = [dorsi_energy_array dorsi_energy_new];
    pushoff_energy_array = [pushoff_energy_array pushoff_energy_new];
    ExpectedAdditionalEnergy_Percent_array = [ExpectedAdditionalEnergy_Percent_array ExpectedAdditionalEnergy_Percent_new];
end

%INVERSE MODEL PLOTTING
if(plantar_cam)
    leg3 = plot(theta_total/pi*180,PlantarMomentIdeal,'Linewidth',6,'Color','k','LineStyle','--'); %legend item 3, forward plantar flexion curve per iteration of slider position
end
if(dorsi_cam)
    leg4 = plot(theta_total/pi*180,DorsalMomentIdeal,'Linewidth',6,'Color',[195,195,195]/255,'LineStyle','--'); %legend item 1, forward dorsiflexion curve per iteration of slider position
end
set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
legend([leg1(1) leg2(1) leg3 leg4],{'Inverse model plantar','Inverse model dorsal', 'Primary curve plantar', 'Primary curve dorsal'},'Location','northwest')
legend boxoff

xlim([-10 15])
ylim([-40 70])
title('Inverse Model')


%% Cam Forces---------------------
figure
hold on
plot(-x_center_inv,-F_cam,'Linewidth',5)
xlabel('Slider Position'); ylabel('Cam Force [kN]'); title('Cam Contact Force at Peak Torque');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
%---------------------------------
%% Energy---------------------
% figure
% hold on
% plot(-x_center_inv,ER_array,'Linewidth',5)
% xlabel('Slider Position'); ylabel('ES_array [J]'); title('-----');
% set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
figure
hold on
plot(-x_center_inv,ES_array,'Linewidth',5)
plot(-x_center_inv,dorsi_energy_array,'Linewidth',5)
plot(-x_center_inv,pushoff_energy_array,'Linewidth',5)
xlabel('Slider Position [mm]'); ylabel('Energy [J]'); title('Dual Cam Energy vs Slider Position');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('Energy stored at midstance','Energy stored over dorsiflexion','Energy returned during pushoff')
legend boxoff
%-----------------------------------
figure
hold on
plot(-x_center_inv,ExpectedAdditionalEnergy_Percent_array,'Linewidth',5)
xlabel('Slider Position'); ylabel('Energy Returned [%]'); title('Pushoff Energy as [%] of Dorsiflexion Energy');
set(gcf,'color','w'); set(gca,'FontSize',16); set(gca,'linewidth',2)
%---------------------------------

%% Message Box
if(message_box)
    output = {["Transition Angles (D,P): " + string(max_dorsiflexion)+","+string(max_plantarflexion)],...
            ["Energy Stored at midstance: " + string(midstance_energy)],...
            ["Energy Stored during Dorsiflexion: " + string(dorsi_energy)],...
            ["Energy Returned Compared to Single Cam: " + string(ExpectedAdditionalEnergy_Percent)],...
            ["Energy Returned During Push Off: "+string(pushoff_energy)]}; 
    msgbox(output,"Simulation Results");
end

%% Automate Figure Placement
figs =  findobj('type','figure');
fig_autoplace(figs)
