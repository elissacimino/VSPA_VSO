%% NEUROBIONICS LAB

%Dual Cam VSO Orthosis Cam Profile Derivation
%Nikko Van Crey (nikkovc@umich.edu) and Hashim Quaraishi

clear
close all
close all hidden
addpath('IMPORTS')
addpath('DUAL_CAMS')
addpath('DUAL_CAMS/Cams_7_13_21')
addpath('IMPORTS/nurbs_toolbox')

%% TO DO
%add ability to import and simulate a different cam
%add nonlinear series compliance to the model
%PRELOAD IS 1 DEG RN!!!
%format like other cam designer script

%% CONFIGURABLES
stiff = 1;
feather = 0;
different_cam = 1;
kdelt_nonlinear = 0; %series compliance can be a user-defined nonlinear function
cam_forces = 0;
ramtech_wrong_geometry = 1;
characterization_parameter_testing =1;

%% DESIGN PARAMETERS
%MISC
ROM_thresh = deg2rad(27); %nikkROM that Cam forces are evaluated at
preload = 0.0030; %to prevent backlash, the featherer the better, as it also places pressure on the slider below the spring
primary_percentage = 0.5;

%Geometric Parameters
y_center = 0.008;% 0.008(m) Distance between top of simple support and cam roller axis
if(ramtech_wrong_geometry)
    y_center = 0.03529;
end
x_center_max = 88;
x_center_min = 32.5;
r0 = 0.03529;
% cam_radius = 0.008; %feather separable rollers
if(stiff)
    cam_radius = 0.0095;
end
if(feather)
    cam_radius = 0.0085;
end
x_off = 0;

%% PLOTTING OPTIONS
message_box = 1;


transition_mark = 0;
plantar_cam = 1;
dorsi_cam = 1;

%(only choose one)
plot_all = 0;
plot_one = 0;
plot_select = 1;
extreme = 0;


%% IMPORT STUFF

load('IMPORTS/Conversions.mat')

%% AUTO-CONFIGURATION
if(different_cam)
    cam_forces = 0;
end

%% CHECKING FOR USER ERROR (NOT BULLET PROOF)

if(plot_all+plot_one+plot_select>1)
    disp('Only choose 1 plotting method')
    return
end
%% Initialize
transition = [];
%----
F_cam = [];
F_cam_2 = [];
F_cam_3 = [];
s_lin = [];
%----
ES_array = [];
ER_array = [];
midstance_energy_array = [];
dorsi_energy_array = [];
pushoff_energy_array = [];
ExpectedAdditionalEnergy_Percent_array = [];

%% TORQUE-ANGLE CURVES | SERIES COMPLIANCE | CAM ROLLER RADIUS
if(stiff)
    load('dual_cams_ramtech.mat') %kdelt 600 for manufactured cams
end
if(feather)
    load('dual_cams_neil.mat') %kdelt 600 for manufactured cams
end

%% Initial variables
res = 0.005;               %resolution, step size between data points
theta = pi/180*(-max_plantarflexion:res:max_dorsiflexion);  %angles in energy recycling range, in radians
theta_total = pi/180*(-40:res:40);  %radians.

pf_transition = find (theta_total==-max_plantarflexion*pi/180);
df_transition = find (theta_total==max_dorsiflexion*pi/180);


%% SPRING SELECTION
% x_spring = flip([36.2580000000000,41.9960000000000,47.7340000000000,53.4720000000000,59.2100000000000,64.9480000000000,70.6860000000000,76.4240000000000,82.1620000000000]);
% k_spring = [0.432465001702156,0.616126941919261,0.792258272479587,1.01274888074353,1.30070171341660,1.66157226218556,2.08664716371367,2.60261456478173,3.26999324785601]*10^6;
if(stiff)
    x_spring = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
    k_spring = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
end
if(feather)
    %Measured on Instron
    x_spring = perc2mm([0,10.01,19.97,29.97,39.95,49.95,59.97,70.07,80.04,90.01,96.98],x_center_max,x_center_min);
    k_spring = [0.166318991334212,0.208391576135634,0.282351259287986,0.374190624007133,0.489817440908308,0.631742113520826,0.796116260994716,1.01916697238319,1.34705270360385,1.70337140522367,2.13270292544089]*10^6;
end

titanium = polyfit(x_spring,k_spring,3);
x_titan = x_center_max:-1:x_center_min;
k_titan = polyval(titanium,x_titan);

%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
figure(1)
hold on
plot(x_spring,k_spring,'Linewidth',5)
plot(x_titan,k_titan)
legend('FEA','Fit')


%% Plotting TA curves, using the NURBS control points
figure(5); hold on; grid on
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
plot(theta*180/pi, PlantarMoment,'Linewidth',5,'Color', [88 164 176]/255)
plot(plantar_control_points(:,1)*180/pi, plantar_control_points(:,2),'k.-')

%%%figure(1) plot settings
set(gcf,'color','w');
set(gca,'FontSize',25)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
xlim([-8 15])
ylim([-30 50])
legend('Initial Plantar', 'Final Dorsal', 'Plantar Control Points', 'Dorsal Control Points', 'Final Plantar', 'FontSize',20,'Location','northwest')
title('NURBS TA Curves')


%% -----------------------------------------------------------ENERGY2-----------------------------------------------------
%THESE LINES FIND THE ENERGY STORED AND RETURNED
DorsalMoment = scalefactor*DorsalMoment;
PlantarMoment = scalefactor*PlantarMoment;
[~,PlantarIndex] = min(abs(PlantarMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,DorsalIndex] = min(abs(DorsalMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:PlantarIndex),PlantarMoment(1:PlantarIndex)))) - max(abs(cumtrapz(theta(1:DorsalIndex),DorsalMoment(1:DorsalIndex)))) %Energy captured between the curves, when dorsal curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) - max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end)))) %Energy recycled, in the top right quadrant of the TA plane
midstance_energy = ES %Energy stored at midstance (J)
dorsi_energy = max(abs(cumtrapz(theta(DorsalIndex:end),DorsalMoment(DorsalIndex:end))))%Energy stored over dorsiflexion (J)
pushoff_energy = max(abs(cumtrapz(theta(PlantarIndex:end),PlantarMoment(PlantarIndex:end)))) %Energy returned during pushoff (J)
ExpectedAdditionalEnergy_Percent = 100+(pushoff_energy-dorsi_energy)/dorsi_energy*100 %Energy returned (%)

figure(3)
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
th_plantar = pi/180*[-40 -30 -20 -max_dorsiflexion]';
%M_plantar = [-65 -55 -45 -10/180*pi*slope_scaling/2]';
M_plantar = [(slope_end_plantar*([-40 -30 -20]+10)+plantar_scaling*slope_deg*(-10)) plantar_scaling*slope_deg*(-10)]';
th_dorsi = deg2rad([12.5 15 22 angle_leveling 28 34 40]');
M_dorsi = [slope_deg*[rad2deg(th_dorsi(1:4))-equilibrium_blue]; (slope_end_dorsi*(rad2deg(th_dorsi(5:end))-equilibrium_blue-angle_leveling)+slope_deg*angle_leveling)];
M_points = [M_plantar; PlantarMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
PlantarMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
DorsalMomentIdeal = [PlantarMomentIdeal(1:pf_transition-1) DorsalMoment PlantarMomentIdeal(df_transition+1:end)];
%Scaling------(Nikko)
PlantarMomentIdeal = scalefactor*PlantarMomentIdeal;
DorsalMomentIdeal = scalefactor*DorsalMomentIdeal;

figure(4)
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
DorsalLin = (theta_dorsal)*slope_scaling; %linear torques in dorsiflexion region

%%%%Plotting
plot(theta_plantar*180/pi+equilibrium_blue, scalefactor*PlantarLin, '--', 'Linewidth',5, 'Color', [60 100 176]/255)
plot(rad2deg(theta_dorsal)+equilibrium_blue, scalefactor*DorsalLin, '--', 'Linewidth',5, 'Color', [120 164 120]/255)
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
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = x_center*m2mm;


%Additional Parameters
L = sqrt(x_center^2+y_center^2); %absolute distance between top of pivot point and center of follower
d = sqrt((r0+y_center)^2+x_center^2); %absolute distance between top of pivot point and ankle center of rotation
%Both sigma calculations give same results
%sigma = acos((r0^2-d^2-L^2)/(-2*d*L));
sigma = atan(x_center/y_center)-atan(-x_center/(-r0-y_center));

%torque angle curve work plantar curve
work_P_fw = cumtrapz(theta_total,PlantarMomentIdeal); %taking the area under the torque angle curve, energy in system
work_P_fw = work_P_fw - work_P_fw(PlantarMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%torque angle curve work dorsal curve
work_D_fw = cumtrapz(theta_total,DorsalMomentIdeal); %taking the area under the torque angle curve, energy in system
work_D_fw = work_D_fw - work_D_fw(DorsalMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%Series Compliance
if(kdelt_nonlinear)
    kdelt_dorsi = 1000;
    kdelt_plantar = 1000;
    kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
else
    kdelt = 600; % [Nm/rad] Fixed, stiffness of frame, FOR BOTH PLANTAR & DORSAL CURVE
end

%%Plantar cam profile
%frame work plantar
k_series_linear = (kdelt*2*pi()/360); %Linear stiffness
delta = PlantarMomentIdeal./kdelt; %Amount of deflection of the series compliance
work_delta_fw = 1/2.*kdelt.*delta.^2; %Mechanical energy stored in the series compliance

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

angle_constant_fw = atan((-y_center-r0)/-x_center); %This is the angle between d and the bottom of the spring
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


%USING MATH TO OFFSET
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
M_dt = DorsalMomentIdeal(find(theta_total==deg2rad(transition_dorsi)));
M_pt = PlantarMomentIdeal(find(theta_total==deg2rad(transition_plantar)));
thd_adjust = rad2deg(M_dt./kdelt);
thp_adjust = rad2deg(M_pt./kdelt);
thd_magnet = transition_dorsi-thd_adjust;
thp_magnet = transition_plantar-thp_adjust;
index_dt = find(theta_total==deg2rad(transition_dorsi));
index_pt = find(theta_total==deg2rad(transition_plantar));
rad2deg(theta_cam_fw(index_dt))
rad2deg(delta(index_dt))
x_dt = curve_x(index_dt);
y_dt = curve_y(index_dt);
x_pt = curve_x(index_pt);
y_pt = curve_y(index_pt);
ang_dt = atand(y_dt/x_dt); %angles needed in solidworks model
ang_pt = atand(y_pt/x_pt); %angles needed in solidworks model

%% EXPORT CAM TO SOLIDWORKS

new_x = curve_x(2:10:length(curve_x)); 
new_y = interp1(curve_x,curve_y,new_x);
new_x2 = curve_x2(2:10:length(curve_x2)); 
new_y2 = interp1(curve_x2,curve_y2,new_x2);
curve_points_plantar = 1000*[new_x', new_y', 0.*new_x'];
curve_points_dorsal = 1000*[new_x2', new_y2', 0.*new_x2'];
%curve_points = sortrows(curve_points, 2);
dlmwrite('cam_curve_plantar.txt', curve_points_plantar, '\t')   
dlmwrite('cam_curve_dorsal.txt', curve_points_dorsal, '\t') 

%% CAM CURVE SELF INTERSECTIONS? (Is it possible to manufacture cam)

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
if(isempty(intersections_left)==0 | isempty(intersections_right)==0)
    disp('Error: intersections in cam')
    return
end


%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE

if(different_cam)
    %Plantarflexion Cam
    SolidworksImport = readtable('cam_curve_plantar_C1.txt');
    x_import = table2array(SolidworksImport(:,2)).*0.001;
    y_import = -table2array(SolidworksImport(:,1)).*0.001;
    %x_import = smooth(x_import);
    %y_import = smooth(y_import);
    [x_import_offset, y_import_offset] = offsetCurve(x_import,y_import,-0.0095);
    

    %psi = acot(x_import_offset./y_import_offset);
    %r = y_import_offset./sin(psi);
    
     %Dorsiflexion Cam
    SolidworksImport = readtable('cam_curve_dorsal_C1.txt');
    x2_import = table2array(SolidworksImport(:,2)).*0.001;
    y2_import = -table2array(SolidworksImport(:,1)).*0.001;
    %x2_import = smooth(x2_import);
    %y2_import = smooth(y2_import);
    [x2_import_offset, y2_import_offset] = offsetCurve(x2_import,y2_import,-0.0095);
    
    
    %psi2 = acot(x2_import_offset./y2_import_offset);
    %r2 = y2_import_offset./sin(psi2);
    
    %INTERPOLATE
%     spacing = (psi2(1)-psi2(end))/(length(psi2)-2)
%     psi2_new = psi2(1):spacing:psi2(end);
%     r2 = interp1(psi2,r2,psi2_new);
%     psi2=psi2_new;
%     
    %PLOTTING
%     figure(79)
%     polarplot(psi,r)
%     hold on
%     polarplot(psi2,r2)
%     hold off
end
%% UPDATING MODEL TO CORRELATE WITH TESTING DATA

if(ramtech_wrong_geometry)
    y_center = 0.008; %This updates the incorrect geometry used to make the first round of cams to the correct value for use in the inverse model. This allows us to generate (r,psi) for the old cam and use them with the corrected inverse model for simulation and comparisoin with JIM results.
end

if(characterization_parameter_testing)
    preload = 1*preload;
    kdelt_dorsi = 1600; % 500 used for ramtech cams 4, 5, and 6 (450)
    kdelt_plantar = 1100; %300 used for ramtech cams 4, 5, and 6 (200)
    kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
end

%% Inverse model, determining the torque angle curve at different spring stiffness values, for a pre-set cam profile

if(plot_one)
%     x_center_new = [x_center_max]*mm2m;
%     ktranslational = [polyval(titanium,x_center_max)];
%     x_center_new = [primary_slider]*mm2m;
%     ktranslational = [polyval(titanium,primary_slider)];
    x_center_new = [x_center_max]*mm2m;
    ktranslational = [polyval(titanium,x_center_max)];
end

if(plot_select)
%     x_center_new = [x_center_max, primary_slider, x_center_min]*mm2m; %same as [0, 33, 45]-33;
%     ktranslational = [polyval(titanium,x_center_max) polyval(titanium,primary_slider) polyval(titanium,x_center_min)];
    x_center_new = perc2mm([60],x_center_max,x_center_min); %same as [0, 33, 45]-33;
    ktranslational = [polyval(titanium,x_center_new)];
end

if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = [floor(x_center_max):-1:ceil(x_center_min)];
    k_VSO_all = polyval(titanium,x_VSO_all);
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end


%% change MS, PlantarMomentAnkle, PlantarMomentAnkle, Mi, yM, yL

vert_preload_inv = -x_center.*tan(preload); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./-x_center_new);  %This allows the preload to update as the slider moves

vert_preload_inv2 = -x_center.*tan(gamma2o + preload); %This is the translational equivalent to the rotational preload for the second torque angle curve
spring_preload_inv2 = atan(vert_preload_inv2./-x_center_new);

COL = [0.99 0.878 0.8235; 0.937 0.231 0.172;0.403 0 0.0509];
z = [0.08,0.2,0.3,0.45,0.72,0.85];
TRUECOL = interp1(linspace(0,1,3),COL,z,'pchip');

figure(2)
hold on
set(gcf,'DefaultAxesColorOrder',TRUECOL);

for i = 1:length(x_center_new)
    transition = [];
    %%%constant variables that are equal for the plantar and dorsal curves
    %%%for a given slider position e.g. they don't change throughout the gait
    l_spring_inv(i) = sqrt(x_center_new(i).^2+y_center^2);
    d_inv(i) = sqrt((r0+y_center)^2+x_center_new(i).^2);
    sigma_inv(i) = atan(x_center_new(i)/y_center)-atan(-x_center_new(i)/(-r0-y_center)); %This is the angle between virtual spring and line through spring centers
    angle_constant_inv(i) = atan((-y_center-r0)/-x_center_new(i));
    
    %%Plantar curve
    omega_inv = acos((l_spring_inv(i).^2 - r.^2 - d_inv(i).^2)./(-2*r.*d_inv(i)));
    alpha_inv = omega_inv+angle_constant_inv(i)-pi/2;
    theta_cam_inv = alpha_inv + psi; 
    gamma_inv = acos((r.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv(i);
    
    k(i) = ktranslational(i).*x_center_new(i)^2;
    PlantarMomentSpring = k(i)*(gamma_inv + spring_preload_inv(i)); 
    work_spring_inv = cumtrapz(gamma_inv,PlantarMomentSpring);

    PlantarMomentAnkle = diff(work_spring_inv)./diff(theta_cam_inv);
    PlantarMomentAnkle(end+1) = PlantarMomentAnkle(end);

    delta_inv = PlantarMomentAnkle./kdelt;    
    
    theta_inv = theta_cam_inv + delta_inv;

    %Dorsal curve
    sigma_inv2 = sigma_inv + spring_preload_inv2(i) - spring_preload_inv(i);
    angle_constant_inv2(i) = angle_constant_inv(i) + spring_preload_inv2(i) - spring_preload_inv(i);
    
    omega_inv2 = acos((l_spring_inv(i).^2 - r2.^2 - d_inv(i).^2)./(-2*r2.*d_inv(i))); %law of cosines
    alpha_inv2 = -(atan(-x_center_new(i)/(-r0-y_center)) - omega_inv2);
    theta_cam_inv2 = alpha_inv2 + psi2;
    gamma_inv2 = acos((r2.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv2(i);

    DorsalMomentSpring = k(i)*(gamma_inv2 + spring_preload_inv2(i));  
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
    ROM_index = find(abs(theta_inv2-ROM_thresh)<deg2rad(1));%0.006
    if(cam_forces)
        F_cam = [F_cam DorsalMomentSpring(ROM_index(1))./l_spring_inv(i)];
        F_cam_2 = [F_cam_2 DorsalMomentAnkle(ROM_index(1))./r2(ROM_index(1))];
        F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];
    end
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
        x_center_new(i)
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














%% ------------------------------PLOTTING------------------------------------
%INVERSE MODEL PLOTTING
if(plantar_cam)
    %leg3 = plot(theta_total/pi*180,PlantarMomentIdeal,'Linewidth',6,'Color','k','LineStyle','--'); %legend item 3, forward plantar flexion curve per iteration of slider position
end
if(dorsi_cam)
    %leg4 = plot(theta_total/pi*180,DorsalMomentIdeal,'Linewidth',6,'Color',[195,195,195]/255,'LineStyle','--'); %legend item 1, forward dorsiflexion curve per iteration of slider position
end
set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
%legend([leg1(1) leg2(1) leg3 leg4],{'Inverse model plantar','Inverse model dorsal', 'Primary curve plantar', 'Primary curve dorsal'},'Location','northwest')
legend([leg1(1) leg2(1)],{'Inverse model plantar','Inverse model dorsal', 'Primary curve plantar', 'Primary curve dorsal'},'Location','northwest')
legend boxoff

xlim([-10 15])
ylim([-40 70])
title('Inverse Model')


%% Cam Forces---------------------
if(cam_forces)
    figure(6)
    hold on
    plot(x_center_new,F_cam,'Linewidth',5)
    xlabel('Slider Position'); ylabel('Cam Force [kN]'); title('Cam Contact Force at Peak Torque');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
end
%---------------------------------
%% Energy---------------------
% figure
% hold on
% plot(-x_center_new,ER_array,'Linewidth',5)
% xlabel('Slider Position'); ylabel('ES_array [J]'); title('-----');
% set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
figure(7)
hold on
plot(x_center_new,ES_array,'Linewidth',5)
plot(x_center_new,dorsi_energy_array,'Linewidth',5)
plot(x_center_new,pushoff_energy_array,'Linewidth',5)
xlabel('Slider Position [mm]'); ylabel('Energy [J]'); title('Dual Cam Energy vs Slider Position');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('Energy stored at midstance','Energy stored over dorsiflexion','Energy returned during pushoff')
legend boxoff
%-----------------------------------
figure(8)
hold on
plot(x_center_new,ExpectedAdditionalEnergy_Percent_array,'Linewidth',5)
xlabel('Slider Position'); ylabel('Energy Returned [%]'); title('Pushoff Energy as [%] of Dorsiflexion Energy');
set(gcf,'color','w'); set(gca,'FontSize',16); set(gca,'linewidth',2)
%---------------------------------


%% PLOT CAM IMPORTED FROM TXT

if(different_cam)
    figure(9)
    hold on
    plot(x_import,y_import,'k','Linewidth',1);
    %plot(x_import_offset,y_import_offset,'k','Linewidth',1);
    plot(x2_import,y2_import,'k','Linewidth',1);
    %plot(x2_import_offset,y2_import_offset,'k','Linewidth',1);
    legend('Original', 'Offset')
    axis equal
    hold off
end

%% Plotting the cam profiles
figure(9); hold on;

%%%%The figures plotted have a layout of (-y,x) to illustrate the cam
%%%%in a more intuitive manner. In an orientation, as it will be placed in
%%%%the physical device

%%%%Offset curves after applying the parallel theorem
%%%Plantar
plot(curve_y,-curve_x,'--', 'Color', [88 164 176]/255,'Linewidth',1)
%%%Dorsal
plot(curve_y2,-curve_x2,'--','Color', [255 136 0]/255,'Linewidth',1)

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
title('Cam Profiles')

%% Automate Figure Placement

figs =  findobj('type','figure');
fig_autoplace(figs)

%% Message Box

if((different_cam+ramtech_wrong_geometry)>0)
    distortion = 1;
else
    distortion = 0;
end
if(distortion==1)
    message = 'yes';
else
    message = 'no';
end


if(message_box)
    output = {["Cam Distortion: " + string(message)],...
            ["Transition Angles (D,P): " + string(max_dorsiflexion)+","+string(max_plantarflexion)],...
            ["Energy Stored at midstance: " + string(midstance_energy)],...
            ["Energy Stored during Dorsiflexion: " + string(dorsi_energy)],...
            ["Energy Returned Compared to Single Cam: " + string(ExpectedAdditionalEnergy_Percent)],...
            ["Energy Returned During Push Off: "+string(pushoff_energy)]}; 
    msgbox(output,"Simulation Results");
end


%% Functions

function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end

function out = dydx(y, x)
% INPUTS:
    % y: 1-D vector of dependent variable
    % x: 1-D vector of independent variable
% OUTPUT:
    % out: y differentiated with respect to x

    dy = filter22([-2 -1 0 1 2], y, 2);
    dx = filter22([-2 -1 0 1 2], x, 2);
    
    dy(1) = -21*y(1) + 13*y(2) + 17*y(3) - 9*y(4);
    dx(1) = -21*x(1) + 13*x(2) + 17*x(3) - 9*x(4);
    
    dy(2) = -11*y(1) + 3*y(2) + 7*y(3) + y(4);
    dx(2) = -11*x(1) + 3*x(2) + 7*x(3) + x(4);
    
    dy(end-1) = 11*y(end) - 3*y(end-1) - 7*y(end-2) - y(end-3);
    dx(end-1) = 11*x(end) - 3*x(end-1) - 7*x(end-2) - x(end-3);
    
    dy(end) = 21*y(end) - 13*y(end-1) - 17*y(end-2) + 9*y(end-3);
    dx(end) = 21*x(end) - 13*x(end-1) - 17*x(end-2) + 9*x(end-3);
    
    out = dy./dx;

end

function y = filter22(fil,x,numsides)
%
%	THIS FUNCTION PERFORMS 2-SIDED AS WELL AS ONE SIDED
% 	FILTERING.  NOTE THAT FOR A ONE-SIDED FILTER, THE 
%	FIRST length(fil) POINTS ARE GARBAGE, AND FOR A TWO
%	SIDED FILTER, THE FIRST AND LAST length(fil)/2 
%	POINTS ARE USELESS.
%
%	USAGE	: y = filter22(fil,x,numsides)
%
% EJP Jan 1991
%
[ri,ci]= size(x);
if (ci > 1)
     	x = x';
end
numpts = length(x);
halflen = ceil(length(fil)/2);
if numsides == 2
	x = [x ; zeros(size(1:halflen))'];
	y = filter(fil,1,x);
	y = y(halflen:numpts + halflen - 1);
else 
	y=filter(fil,1,x);
end
if (ci > 1)
     	y = y';
end
return


