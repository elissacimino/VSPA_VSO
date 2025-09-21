%% NEUROBIONICS LAB
%Dual Cam VSO Orthosis Cam Profile Derivation
%Nikko Van Crey (nikkovc@umich.edu) and Hashim Quaraishi

clear
close all
close all hidden
addpath('C:\Users\nikkovc\Documents\CODE\MATLABFunctions')
addpath('IMPORTS')
addpath('IMPORTS/functions')
addpath('IMPORTS/data')
addpath('DUAL_CAMS')
addpath('DUAL_CAMS/Cams_7_13_21')
addpath('IMPORTS/nurbs_toolbox')
tic

%% TO DO

%% CONFIGURABLES
%Which Prototype
load('VSO_prototype_data.mat')

%Running Optimization?
optimization = 0;

%Do you want to plot?
plotting = 1;

%Misc
characterization_parameter_testing = 1;
different_cam = 0;

%% CHOOSE TA FUNCTION
load('dual_cams_emily.mat') %kdelt 600 for manufactured cams

%% PLOTTING OPTIONS
message_box = 1;
transition_mark = 1;
blue_cam = 1;
orange_cam = 1;

%(only choose one)
plot_all = 0;
plot_select = 1;
zoom = 1;

if(optimization)
    plotting = 0;
    message_box = 0;
end

if(~plotting)
    transition_mark = 0;
    different_cam = 0;
    blue_cam = 0;
    orange_cam = 0;
end

%% IMPORT STUFF

load('IMPORTS/Conversions.mat')

%% AUTO-CONFIGURATION

%% CHECKING FOR USER ERROR (NOT BULLET PROOF)

if(plot_all+plot_select>1)
    disp('Only choose 1 plotting method')
    return
end
%% Initialize
transition = [];
transition_angles = [];
equilibrium_blue_array = [];
equilibrium_orange_array = [];
cam_angles = [];
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


%% Initial variables
%0.00001 works with dydx
res = 0.005;               %resolution, step size between data points
switching_angle_dorsi = round(switching_angle_dorsi,2) %rouding depends on res vector
switching_angle_plantar = round(switching_angle_plantar,2) %rouding depends on res vector
theta = degree2rad*(-switching_angle_plantar:res:switching_angle_dorsi);  %angles in energy recycling range, in radians
%theta_total = degree2rad*[plantar_max:res:switching_angle_plantar radian2deg*theta switching_angle_dorsi:dorsi_max];
theta_total = pi/180*(plantar_max:res:dorsi_max);  %radians. Emily


%pf_transition2 = find ((radian2deg*theta_total)==-switching_angle_plantar)
%df_transition2 = find ((radian2deg*theta_total)==switching_angle_dorsi)
[~,pf_transition] = min(abs(-switching_angle_plantar-(radian2deg*theta_total)))
[~,df_transition] = min(abs(switching_angle_dorsi-(radian2deg*theta_total)))

%% SPRING SELECTION
[titanium_data] = spring_selection(spring,x_center_min,x_center_max,plotting);

%% Plotting TA curves, using the NURBS control points
if(plotting)
    figure(10); hold on; grid on
    plot(blue_pts(:,1)*180/pi, blue_pts(:,2),'b:','Linewidth',5)
    plot(orange_pts(:,1)*180/pi, orange_pts(:,2),'Linewidth',5,'Color', [255 136 0]/255)
    plot(blue_control_points(:,1)*180/pi, blue_control_points(:,2),'k.-')
    plot(orange_control_points(:,1)*180/pi, orange_control_points(:,2), '.-','Color', [176 99 60]/255)
end

%THESE LINES SPLINE THE BLUE AND RED CURVE
BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta); %blue curve
OrangeMoment = interp1(orange_pts(:,1),orange_pts(:,2),theta); %orange curve
if(max(isnan(BlueMoment))||max(isnan(OrangeMoment)))
    disp('Error: NaNs in BlueMoment or OrangeMoment. Resolution of switching angles are probably finer than theta resolution')
    return
end


%THESE LINES FIND THE ENERGY STORED AND RETURNED
[~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,OrangeIndex] = min(abs(OrangeMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex)))) %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane

%% EQUATE ENERGY OF BOTH TA FUNCTIONS
%THESE LINES MOVE THE BLUE CONTROL POINT #5 IN THE Y-DIRECTION UNTIL ENERGY IS EQUAL
knob = blue_control_points(5,2);
ke = 10; %gain on energy error
error_energy = ER-ES;
while (abs(error_energy)>0.00000000000001)%0.9999 to 1.0001 (15 instead of 16 decimal place for time reasons)
    % knob = knob-sign(ER-ES)*0.001;
    knob_push = ke*error_energy;
    knob = knob-knob_push;
    blue_control_points(5,2) = knob;
    blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
    blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
    BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
    [~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
    ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled
    error_energy = ER-ES;
end

if(plotting)
    figure(10); hold on; grid on
    % % %THIS PLOTS THE NEW CURVE, AFTER ENERGY HAS BEEN EQUALIZED
    plot(theta*180/pi, BlueMoment,'Linewidth',5,'Color', [88 164 176]/255)
    plot(blue_control_points(:,1)*180/pi, blue_control_points(:,2),'k.-')
end

if(plotting)
    figure(3)
    set(gcf,'color','w');
    set(gca,'FontSize',25)
    set(gca,'linewidth',2)
    xlabel('Ankle Angle [deg]')
    ylabel('Ankle Torque [N.m]')
    xlim([-8 15])
    ylim([-30 50])
    legend('Initial Blue', 'Final Orange', 'Blue Control Points', 'Orange Control Points', 'Final Blue', 'FontSize',20,'Location','northwest')
    title('NURBS TA Curves')
end


%% -----------------------------------------------------------ENERGY2-----------------------------------------------------
%THESE LINES FIND THE ENERGY STORED AND RETURNED
OrangeMoment = scalefactor*OrangeMoment;
BlueMoment = scalefactor*BlueMoment;
if(plotting)
    figure(70)
    hold on
    plot(theta,BlueMoment)
    plot(theta,OrangeMoment)
end
[~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,OrangeIndex] = min(abs(OrangeMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
% ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex)))); %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
% ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane
midstance_energy = ES; %Energy stored at midstance (J);
dorsi_energy = max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));%Energy stored over dorsiflexion (J)
pushoff_energy = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))); %Energy returned during pushoff (J)
ExpectedAdditionalEnergy_Percent = 100+(pushoff_energy-dorsi_energy)/dorsi_energy*100; %Energy returned (%)

if(plotting)
    figure(12)
    hold on
    plot(rad2deg(theta(1:BlueIndex)),BlueMoment(1:BlueIndex),'Linewidth',1) %1
    plot(rad2deg(theta(1:OrangeIndex)),OrangeMoment(1:OrangeIndex),'Linewidth',1) %2
    plot(rad2deg(theta(BlueIndex:end)),BlueMoment(BlueIndex:end),'Linewidth',1) %3
    plot(rad2deg(theta(OrangeIndex:end)),OrangeMoment(OrangeIndex:end),'Linewidth',1) %4
    legend('1','2','3','4')
end
OrangeMoment = (1/scalefactor)*OrangeMoment;
BlueMoment = (1/scalefactor)*BlueMoment;
%------------------------------------------------------------------------------------------

%% Plotting the final TA curves
%% MAKES COMMON REGION ON EITHER SIDE OF SWITCHING CAMS AND COMBINES WITH SWITCHING PORTION
%Plantarflexion End
incp1 = (plantar_max+switching_angle_plantar)/3;
th_plantar = degree2rad*([plantar_max [2*incp1 incp1]-switching_angle_plantar]');
M_plantar = slope_plantar_rad*th_plantar;
%Dorsiflexion End
incd1 = (angle_leveling-switching_angle_dorsi)/4;
incd2 = (dorsi_max-angle_leveling)/3;
th_dorsi = degree2rad*([switching_angle_dorsi+[incd1 2*incd1 3*incd1] angle_leveling+[0 incd2 2*incd2] dorsi_max]');
M_dorsi = [slope_dorsi_deg*[radian2deg*(th_dorsi(1:4))]; (slope_end_dorsi*(radian2deg*(th_dorsi(5:end))-angle_leveling)+slope_dorsi_deg*angle_leveling)];
%Complete TA Function
M_points = [M_plantar; BlueMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
BlueMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
OrangeMomentIdeal = [BlueMomentIdeal(1:pf_transition-1) OrangeMoment BlueMomentIdeal(df_transition+1:end)];
%Scaling------(Nikko)
BlueMomentIdeal = scalefactor*BlueMomentIdeal;
OrangeMomentIdeal = scalefactor*OrangeMomentIdeal;

%% Check if the curves need to flip
if(ES<0)
    temp = BlueMomentIdeal;
    BlueMomentIdeal = OrangeMomentIdeal;
    OrangeMomentIdeal = temp;
    ES = -ES;
    disp('Switched Colors To Have Math Work')
end

%% Plotting the final TA curves
if(~optimization)
    save('BlueMomentIdeal', 'BlueMomentIdeal');
    save('OrangeMomentIdeal', 'OrangeMomentIdeal');
    save('theta_total', 'theta_total');
end
if(plotting)
    figure(3)
    hold on 
    % color_blue = [88 164 176]/255;
    % color_orange = [255 136 0]/255;
    color_black = [0 0 0]/255;
    plot(theta_total*180/pi,BlueMomentIdeal,'linewidth',5,'Color', color_black)
    plot(theta_total*180/pi,OrangeMomentIdeal,'linewidth',5,'Color', color_black)
    %plot(rad2deg(theta_points),scalefactor*M_points,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
    
    %%%%LINEAR STRIPED LINES FOR THE LINEAR STIFFNESS
    %%%%The desired TA curves are build around linear stiffness values
    %%%Linear steps in angles
    theta_blue = pi/180*(-40:res:0-res);
    theta_orange = pi/180*(0:res:40);
    
    %%%Stiffness ratio between linear plantar flexion and dorsiflexion slope
    BlueLin = theta_blue*plantar_scaling*slope_dorsi_rad; %linear torques in plantar flexion region
    OrangeLin = (theta_orange)*slope_dorsi_rad; %linear torques in dorsiflexion region
    
    %%%%Plotting
    % plot(theta_blue*180/pi+equilibrium_blue, scalefactor*BlueLin, '--', 'Linewidth',5, 'Color', [60 100 176]/255)
    % plot(rad2deg(theta_orange)+equilibrium_orange, scalefactor*OrangeLin, '--', 'Linewidth',5, 'Color', [120 164 120]/255)
    plot(theta_blue*180/pi, scalefactor*BlueLin, '--', 'Linewidth',5, 'Color', [60 100 176]/255)
    plot(rad2deg(theta_orange), scalefactor*OrangeLin, '--', 'Linewidth',5, 'Color', [120 164 120]/255)
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
    legend('Final Blue', 'Final Orange', 'Linear Blue', 'Linear Orange', 'Equilibrium Point','FontSize',16,'Location','northwest')
    title('Torque angle curves')
end

%%%%%%%%%used later?
[~,BlueMomentIdealIndex] = min(abs(BlueMomentIdeal)); %FIND INDEX FOR WHEN BlueMomentIdeal == 0(OR CLOSE)
[~,OrangeMomentIdealIndex] = min(abs(OrangeMomentIdeal)); %FIND INDEX FOR WHEN OrangeMomentIdeal == 0 (OR CLOSE)

%% Calculating the shape of the cam profile, FORWARD MODEL

stroke = x_center_max-x_center_min;
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = x_center*m2mm;


%Additional Parameters
L = sqrt(x_center^2+y_center^2); %absolute distance between top of pivot point and center of follower
d = sqrt((r0+y_center)^2+x_center^2); %absolute distance between top of pivot point and ankle center of rotation
%Both sigma calculations give same results
sigma = acos((r0^2-d^2-L^2)/(-2*d*L));
sigma_2 = atan(x_center/y_center)-atan(-x_center/(-r0-y_center));

%torque angle curve work blue curve
work_blue_fw = cumtrapz(theta_total,BlueMomentIdeal); %taking the area under the torque angle curve, energy in system
work_blue_fw = work_blue_fw - work_blue_fw(BlueMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%torque angle curve work orange curve
work_orange_fw = cumtrapz(theta_total,OrangeMomentIdeal); %taking the area under the torque angle curve, energy in system
work_orange_fw = work_orange_fw - work_orange_fw(OrangeMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position


%Series Compliance
equilibrium_orange_actual = theta(OrangeIndex);
kdelt_orange = kdelt_dorsi*(theta_total>equilibrium_orange_actual)+kdelt_plantar*~(theta_total>equilibrium_orange_actual);
equilibrium_blue_actual = theta(BlueIndex);
kdelt_blue = kdelt_dorsi*(theta_total>equilibrium_blue_actual)+kdelt_plantar*~(theta_total>equilibrium_blue_actual);
if(plotting)
    figure(7)
    hold on
    plot(theta_total,kdelt_orange)
    plot(theta_total,kdelt_blue)
end

k = polyval(titanium_data,primary_slider)*(x_center)^2; %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L

%%Blue cam profile
%frame work blue
k_series_linear = (kdelt_blue*2*pi()/360); %Linear stiffness
delta = BlueMomentIdeal./kdelt_blue; %Amount of deflection of the series compliance
work_delta_fw = 1/2.*kdelt_blue.*delta.^2; %Mechanical energy stored in the series compliance

%frame work orange
delta_fw2 = OrangeMomentIdeal./kdelt_orange;
work_delta_fw2 = 1/2.*kdelt_orange.*delta_fw2.^2;

theta_cam_fw = theta_total-delta;
theta_cam_fw2 = theta_total-delta_fw2;

gammao = preload; %fixed

% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a = k./2;
b = k.*gammao;
c = work_delta_fw-work_blue_fw; 

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


%USING MATH TO OFFSET
[curve_x curve_y] = offsetCamCurve(x,y,r,psi,roller_radius,'offset','diff');


%%Orange cam profile spring
%additional parameters
%%%gamma2o is the preload calculation of the spring at midstance, where the
%%%orange curve is at zero-torque. It is assumed that the energy stored in
%%%the spring can be dictated by the following equation:
%%%Energy = 0.5*k*delta_gamma, where krotary is the spring
%%%stiffnes, and delta_gamma = gamma2o - gammao
%gamma2o = gammao;
gamma2o = sqrt((ES+0.5*k*gammao.^2)/(0.5*k))-gammao;

%gamma2o2 = sqrt(2*ES/k+gammao.^2); %Nikko added
%gamma2o3 = sqrt(ES/k+gammao.^2); %Nikko added
sigma_fw2 = sigma + gamma2o;

% Solving via the principle of virtual work (see our publication). We have a quadratic equation with:
a2 = k./2;
b2 = k.*(gamma2o+gammao); %gamma2o depends on the amount of caputered energy and the spring stiffness value
c2 = work_delta_fw2-work_orange_fw;

% Here is the solution to the quadratic equation:
gamma_fw2 = (-b2+sqrt(b2.^2-4.*a2.*c2))./(2*a2);
r2 = sqrt(L^2 + d^2 - 2*L*d*cos(gamma_fw2+sigma_fw2)); %law of cosines

%angle_constant_fw2 = angle_constant_fw + gamma2o; %(Not used anywhere) equivalent to beta
omega_fw2 = asin(L./r2.*sin(gamma_fw2+sigma_fw2)); %This is the angle between r and d (law of sines)
alpha_fw2 = omega_fw2 + angle_constant_fw-pi/2; %angle between d and vertical minus omega_fw2
psi2 = theta_cam_fw2-alpha_fw2; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r

% Make Offset 
y2 = r2.*sin(psi2);
x2 = r2.*cos(psi2);
[curve_x2 curve_y2] = offsetCamCurve(x2,y2,r2,psi2,roller_radius,'offset','diff');


%% Magnet Mount Transition Angles
%dt: dorsiflexion transition
%pt: plantarflexion transition
M_dt = OrangeMomentIdeal(df_transition)
M_pt = BlueMomentIdeal(pf_transition)
thdt = rad2deg(theta_total(df_transition))
thpt = rad2deg(theta_total(pf_transition))
x_dt = curve_x(df_transition)
y_dt = curve_y(df_transition)
x_pt = curve_x(pf_transition)
y_pt = curve_y(pf_transition)
ang_dt = atand(y_dt/x_dt) %angles needed in solidworks model
ang_pt = atand(y_pt/x_pt) %angles needed in solidworks model

%% EXPORT CAM TO SOLIDWORKS (Need to downsample because otherwise solidworks will crash)
length(curve_x)
[curve_points_blue] = Matlab2Solidworks(curve_x,curve_y);
[curve_points_orange] = Matlab2Solidworks(curve_x2,curve_y2);
length(curve_points_blue)
dlmwrite('cam_curve_blue.txt', curve_points_blue, '\t')
dlmwrite('cam_curve_orange.txt', curve_points_orange, '\t') 


%% CHECKS
% intersections in cam profile? (First check for nonrealizable geometry)
[intersections_blue] = check_intersections(curve_x,curve_y,theta_total);
[intersections_orange] = check_intersections(curve_x2,curve_y2,theta_total);
% Check if psi is a function (Leading Hypothesis is that this is possible, but will lock spring and produce max stiffness)
[psi_violation_blue] = check_psi(curve_x,curve_y,theta_total);
[psi_violation_orange] = check_psi(curve_x2,curve_y2,theta_total);
if(plotting)
        figure(21)
        hold on
        plot(theta_total,theta_cam_fw)
end
% CHECK IF MATH EXPLOITS NONMONOTONIC THETA_CAM TO BYPASS STIFFNESS STIFFNESS LIMITS(Second check for nonrealizable geometry)
[theta_cam_violations_blue] = check_theta_cam(theta_cam_fw);
[theta_cam_violations_orange] = check_theta_cam(theta_cam_fw2);

%Kill Code if there are issues
% if(isempty(intersections_blue)==0)||(isempty(intersections_orange)==0)||isempty(theta_cam_violations_blue)==0)||isempty(theta_cam_violations_orange)==0))
%         return
% end

%% Plot Stiffness Of Torque-Angle Functions
if(plotting)
    figure(16)
    hold on
    stiffness_instant_blue = dydx(BlueMomentIdeal,theta_total);
    stiffness_instant_orange = dydx(OrangeMomentIdeal,theta_total);
    plot(rad2deg(theta_total),stiffness_instant_blue,'linewidth',2)
    plot(rad2deg(theta_total),stiffness_instant_orange,'linewidth',2)
    fig_format('Ankle Angle','Stiffness [Nm/rad]','Stiffness of Ideal Blue and Orange Moments')
end

%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE

%% UPDATING MODEL TO CORRELATE WITH TESTING DATA

if(characterization_parameter_testing)
    preload = 1*preload;
%     kdelt_dorsi = kdelt_dorsi; % 500 used for ramtech cams 4, 5, and 6 (450)
%     kdelt_plantar = kdelt_plantar; %300 used for ramtech cams 4, 5, and 6 (200)
    kdelt_dorsi = 1500;
    kdelt_plantar = 1500;
    %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0); %ToDo
    kdelt_orange = kdelt_dorsi*(theta_total>equilibrium_orange_actual)+kdelt_plantar*~(theta_total>equilibrium_orange_actual);
    kdelt_blue = kdelt_dorsi*(theta_total>equilibrium_blue_actual)+kdelt_plantar*~(theta_total>equilibrium_blue_actual);
end

%% Inverse model, determining the torque angle curve at different spring stiffness values, for a pre-set cam profile

if(plot_select)
    % xc_perc = [0.4 0.5 0.60];
    % xc_perc = [0.5];
    % xc_perc = [0 0.5 1];
    xc_perc = [0:0.1:1];
end

if(plot_all)
    xc_perc = [0:0.05:1];
end
x_center_new = x_center_max-((x_center_max-x_center_min).*xc_perc);
ktranslational = polyval(titanium_data,x_center_new);
x_center_new = x_center_new*mm2m;

%% Preallocation
num_slider_positions = length(x_center_new);
Moments = NaN(length(r)+length(r2),num_slider_positions);
Angles = NaN(length(r)+length(r2),num_slider_positions);

%% change MS, BlueMomentAnkle, BlueMomentAnkle, Mi, yM, yL

vert_preload_inv = -x_center.*tan(gammao); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./-x_center_new);  %This allows the preload to update as the slider moves

vert_preload_inv2 = -x_center.*tan(gamma2o + gammao); %This is the translational equivalent to the rotational preload for the second torque angle curve
spring_preload_inv2 = atan(vert_preload_inv2./-x_center_new);

COL = [0.99 0.878 0.8235; 0.937 0.231 0.172;0.403 0 0.0509];
z = [0.08,0.2,0.3,0.45,0.72,0.85];
TRUECOL = interp1(linspace(0,1,3),COL,z,'pchip');

if(plotting)
    figure(2)
    hold on
    set(gcf,'DefaultAxesColorOrder',TRUECOL);
end

for i = 1:length(x_center_new)
    transition = [];
    %%%constant variables that are equal for the plantar and orange curves
    %%%for a given slider position e.g. they don't change throughout the gait
    l_spring_inv(i) = sqrt(x_center_new(i).^2+y_center^2);
    d_inv(i) = sqrt((r0+y_center)^2+x_center_new(i).^2);
    sigma_inv(i) = atan(x_center_new(i)/y_center)-atan(-x_center_new(i)/(-r0-y_center)); %This is the angle between virtual spring and line through spring centers
    angle_constant_inv(i) = atan((-y_center-r0)/-x_center_new(i));
    
    %%Blue curve
    omega_inv = acos((l_spring_inv(i).^2 - r.^2 - d_inv(i).^2)./(-2*r.*d_inv(i)));
    alpha_inv = omega_inv+angle_constant_inv(i)-pi/2;
    theta_cam_inv = alpha_inv + psi; 
    gamma_inv = acos((r.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv(i);
    
    k(i) = ktranslational(i).*x_center_new(i)^2;
    BlueMomentSpring = k(i)*(gamma_inv + spring_preload_inv(i)); 
    work_spring_inv = cumtrapz(gamma_inv,BlueMomentSpring);

    BlueMomentAnkle = diff(work_spring_inv)./diff(theta_cam_inv);
    BlueMomentAnkle(end+1) = BlueMomentAnkle(end);
%     BlueMomentAnkle = dydx(work_spring_inv,theta_cam_inv);
    
    delta_inv = BlueMomentAnkle./kdelt_blue;    
    
    theta_inv = theta_cam_inv + delta_inv;

    %orange curve
    sigma_inv2 = sigma_inv + spring_preload_inv2(i) - spring_preload_inv(i);
    %angle_constant_inv2(i) = angle_constant_inv(i) + spring_preload_inv2(i) - spring_preload_inv(i);
    
    omega_inv2 = acos((l_spring_inv(i).^2 - r2.^2 - d_inv(i).^2)./(-2*r2.*d_inv(i))); %law of cosines
    alpha_inv2 = -(atan(-x_center_new(i)/(-r0-y_center)) - omega_inv2);
    theta_cam_inv2 = alpha_inv2 + psi2;
    gamma_inv2 = acos((r2.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv2(i);

    OrangeMomentSpring = k(i)*(gamma_inv2 + spring_preload_inv2(i));  
    work_spring_inv2 = cumtrapz(gamma_inv2 ,OrangeMomentSpring); 

    OrangeMomentAnkle = diff(work_spring_inv2)./diff(theta_cam_inv2); 
    OrangeMomentAnkle(end+1) = OrangeMomentAnkle(end);
%     OrangeMomentAnkle = dydx(work_spring_inv2,theta_cam_inv2);

    delta_inv2 = OrangeMomentAnkle./kdelt_orange;

    theta_inv2 = theta_cam_inv2 + delta_inv2;
    
    %Logging for RMSE calculation in JIM script
%     Moments(:,i) = [OrangeMomentAnkle BlueMomentAnkle];
%     Angles(:,i) = [rad2deg(theta_inv2) rad2deg(theta_inv2)];
    blue_plantar = BlueMomentAnkle<0;
    blue_dorsi = BlueMomentAnkle>=0;
%     orange_plantar = rad2deg(theta_inv)<0;
%     orange_dorsi = rad2deg(theta_inv)>=0;
    Moments(:,i) = [flip(BlueMomentAnkle(blue_plantar)) OrangeMomentAnkle flip(BlueMomentAnkle(blue_dorsi))];
    Angles(:,i) = [flip(rad2deg(theta_inv(blue_plantar))) rad2deg(theta_inv2) flip(rad2deg(theta_inv(blue_dorsi)))];

    %%%Naming legend items, so repetitive legend enteries can be avoided in
    %%%the final plot
    if(blue_cam)
        leg1(i) = plot(theta_inv/pi*180,BlueMomentAnkle,'-','Linewidth',4,'Color', [88 164 176]/255); %legend item 1, inverse blue curve per iteration of slider position
    end
    if(orange_cam)
        leg2(i) =  plot(theta_inv2/pi*180,OrangeMomentAnkle,'-','Linewidth',4,'Color', [255 136 0]/255); %legend item 1, inverse orange curve per iteration of slider position
    end

    %Cam Forces---------------------
    [~, ROM_index] = min(abs(theta_inv2-ROM_thresh));
    F_cam = [F_cam OrangeMomentSpring(ROM_index(1))./l_spring_inv(i)];
    F_cam_2 = [F_cam_2 OrangeMomentAnkle(ROM_index(1))./r2(ROM_index(1))];
    F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];

    %Energy
    difference = abs(OrangeMomentAnkle-BlueMomentAnkle);
    %Marks Transition and Calculates Energy Metrics
    [~,BlueIndex_new] = min(abs(BlueMomentAnkle)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
    [~,OrangeIndex_new] = min(abs(OrangeMomentAnkle)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
    if(transition_mark)
        transition_tolerance = 0.005; % [Nm]
        check = difference<transition_tolerance;
        for j=2:length(check)
            if((rad2deg(theta_total(j))<(-switching_angle_plantar+3)) | (rad2deg(theta_total(j))>(switching_angle_dorsi-3)))%(((OrangeMomentAnkle(j)<-2) | (OrangeMomentAnkle(j)>8))&(abs(rad2deg(theta_inv(j)))<20))
                if(check(j)~=check(j-1))
                    transition = [transition;j];
                end
            end
        end
        if(~isempty(transition))
            transition_angles = [transition_angles; rad2deg(theta_inv(transition(1:2)))]; %ToDo I just quickly added (1:2) because I was getting an error
            if(length(transition)~=2)
                disp('Transition Incorrect:')
                x_center_new(i)
            else
                    transition;
            end
            plot(rad2deg(theta_inv(transition)),OrangeMomentAnkle(transition),'x','Linewidth',5,'markers',15,'Color',[1 0 0])
    
            %Calculating Energy Based on Transition Points
            ES_new = max(abs(cumtrapz(theta_inv(1:BlueIndex_new),BlueMomentAnkle(1:BlueIndex_new)))) - max(abs(cumtrapz(theta_inv(1:OrangeIndex_new),OrangeMomentAnkle(1:OrangeIndex_new)))); %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
            ER_new = max(abs(cumtrapz(theta_inv(BlueIndex_new:end),BlueMomentAnkle(BlueIndex_new:end)))) - max(abs(cumtrapz(theta_inv(OrangeIndex_new:end),OrangeMomentAnkle(OrangeIndex_new:end)))); %Energy recycled, in the top right quadrant of the TA plane
            midstance_energy_new = ES_new; %Energy stored at midstance (J)
            dorsi_energy_new = max(abs(cumtrapz(theta_inv(OrangeIndex_new:transition(2)),OrangeMomentAnkle(OrangeIndex_new:transition(2)))));%Energy stored over dorsiflexion (J)
            pushoff_energy_new = max(abs(cumtrapz(theta_inv(BlueIndex_new:transition(2)),BlueMomentAnkle(BlueIndex_new:transition(2))))); %Energy returned during pushoff (J)
            ExpectedAdditionalEnergy_Percent_new = 100+(pushoff_energy_new-dorsi_energy_new)/dorsi_energy_new*100; %Energy returned (%)
            ES_array = [ES_array ES_new];
            ER_array = [ER_array ER_new];
            midstance_energy_array = [midstance_energy_array midstance_energy_new];
            dorsi_energy_array = [dorsi_energy_array dorsi_energy_new];
            pushoff_energy_array = [pushoff_energy_array pushoff_energy_new];
            ExpectedAdditionalEnergy_Percent_array = [ExpectedAdditionalEnergy_Percent_array ExpectedAdditionalEnergy_Percent_new];
       end
    end
    cam_angles = [cam_angles; radian2deg*min(theta_cam_inv) radian2deg*max(theta_cam_inv)]
    %Equilibrium
    equilibrium_blue_array = [equilibrium_blue_array;rad2deg(theta_inv(BlueIndex_new))];
    equilibrium_orange_array = [equilibrium_orange_array;rad2deg(theta_inv2(OrangeIndex_new))];
    [~,DropFoot_blue_index] = min(abs(BlueMomentAnkle-Torque_DropFoot))
    [~,DropFoot_orange_index] = min(abs(OrangeMomentAnkle-Torque_DropFoot));
    dropFoot_blue_vec(i) = rad2deg(theta_inv(DropFoot_blue_index(1)));

    if(x_center_new(i)==x_center)
        Angle_DropFoot_blue = rad2deg(theta_inv(DropFoot_blue_index(1)));
        Angle_DropFoot_orange = rad2deg(theta_inv(DropFoot_orange_index(1)));
    end
end
save('DATA/JIM/Cam_Moments', 'Moments');
save('DATA/JIM/Cam_angles', 'Angles');


%% ------------------------------PLOTTING------------------------------------
%INVERSE MODEL PLOTTING
if(blue_cam)
    %leg3 = plot(theta_total/pi*180,BlueMomentIdeal,'Linewidth',6,'Color','k','LineStyle','--'); %legend item 3, forward blue curve per iteration of slider position
end
if(orange_cam)
    %leg4 = plot(theta_total/pi*180,OrangeMomentIdeal,'Linewidth',6,'Color',[195,195,195]/255,'LineStyle','--'); %legend item 1, forward orange curve per iteration of slider position
end
if(plotting)
    fig_format('Ankle Angle [deg]','Ankle Torque [N.m]','Inverse Model')
    %legend([leg1(1) leg2(1) leg3 leg4],{'Inverse model blue','Inverse model orange', 'Primary curve blue', 'Primary curve orange'},'Location','northwest')
    legend([leg1(1) leg2(1)],{'Inverse model blue','Inverse model orange', 'Primary curve blue', 'Primary curve orange'},'Location','northwest')
    xlim([-15 15])
    ylim([-40 70])
    if(zoom)
        xlim([-15 15])
        ylim([-20 20])
    end
end


%% Cam Forces---------------------
if(plotting)
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
if(plotting)
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
end

%% Investigating unreasonable slope
TA_stiffness_orange_forward = dydx(OrangeMomentIdeal,theta_total);
TA_stiffness_orange_inverse = dydx(OrangeMomentAnkle,theta_inv2);
if(plotting)
    figure(18)
    hold on
    plot(rad2deg(theta_total),TA_stiffness_orange_forward,'linewidth',5)
    plot(rad2deg(theta_inv2),TA_stiffness_orange_inverse,'linewidth',2)
    fig_format('Ankle Angle','Stiffness [Nm/rad]','Stiffness of Forward and Inverse Models')
    legend('Forward','Inverse')
end

%% Debugging
figure(20)
hold on
% plot(delta)
% plot(theta_total)
plot(theta_cam_fw)
%plot(theta_cam_inv)

%% PLOT CAM IMPORTED FROM TXT

if(different_cam)
    figure(1)
    hold on
    plot(m2mm*x_import,m2mm*y_import,'k','Linewidth',2);
    %plot(x_import_offset,y_import_offset,'k','Linewidth',1);
    plot(m2mm*x2_import,m2mm*y2_import,'k','Linewidth',2);
    %plot(x2_import_offset,y2_import_offset,'k','Linewidth',1);
    legend('Original', 'Offset')
    axis equal
    hold off
end

%% Plotting the cam profiles
if(plotting)
    figure(1); hold on;
    
    %%%%The figures plotted have a layout of (-y,x) to illustrate the cam
    %%%%in a more intuitive manner. In an orientation, as it will be placed in
    %%%%the physical device
    
    %%%%Offset curves after applying the parallel theorem
    %%%Blue
    % plot(curve_x,curve_y,'-o', 'Color', [88 164 176]/255,'Linewidth',2)
    plot(curve_x,curve_y, 'Color', [88 164 176]/255,'Linewidth',2)
    %%%Orange
    % plot(curve_x2,curve_y2,'-o','Color', [255 136 0]/255,'Linewidth',2)
    plot(curve_x2,curve_y2,'Color', [255 136 0]/255,'Linewidth',2)
    
    %%%Non-offset curves
    %%%Blue
    %plot(y,-x, '--', 'Color', [88 164 176]/255,'Linewidth',5)
    %%%Orange
    %plot(y2,-x2, '--', 'Color', [255 136 0]/255,'Linewidth',5)
    
    %plot(0,0,'g*','linewidth',8) %ankle center of rotation
    
    %Plot points that solidworks will cut the transition between dual cam and single cam
    plot(x_dt,y_dt,".",'MarkerSize',20)
    plot(x_pt,y_pt,".",'MarkerSize',20)
    
    set(gcf,'color','w');
    set(gca,'FontSize',18)
    set(gca,'linewidth',2)
    set(gca, 'box', 'off')
    axis equal
    xlabel('(m)')
    ylabel('(m)')
    %legend('Offset Blue Cam', 'Offset Orange Cam', 'Non Offset Blue Cam', 'Non Offset Orange Cam', 'Ankle Center of Rotation', 'FontSize',20,'Location','northwest')
    legend('Blue Cam', 'Orange Cam','Ankle Center of Rotation')
    legend box off
    title('Cam Profiles')
end

%% Plotting Series Compliance
if(plotting)
    figure(13)
    hold on
    plot(theta_inv/pi*180, kdelt_blue)
    plot(theta_inv/pi*180, kdelt_orange)
end

%% Variable Stiffness Performance
k_all_d = [];
k_all_p = [];
for i = 1:length(Angles(1,:))
    theta_eval_dorsi = theta_eval_dorsi+equilibrium_blue_array(i);
    theta_eval_plantar = theta_eval_plantar+equilibrium_blue_array(i);
    i_all_d = min(find(abs(Angles(:,i)-theta_eval_dorsi)<0.01));
    i_all_p = min(find(abs(Angles(:,i)-(theta_eval_plantar))<0.01));
    dorsi_stroke(i) = Angles(i_all_d,i)-equilibrium_orange_array(i);
    k_all_d = [k_all_d Moments(i_all_d,i)./deg2rad(dorsi_stroke(i))];
    plantar_stroke(i) = abs(Angles(i_all_p,i))-equilibrium_blue_array(i);
    k_all_p = [k_all_p abs(Moments(i_all_p,i))./deg2rad(plantar_stroke(i))];
end
%% Automate Figure Placement
if(plotting)
    % figs =  findobj('type','figure');
    % fig_autoplace(figs)
end

%% Message Box

if((different_cam)>0)
    distortion = 1;
else
    distortion = 0;
end
if(distortion==1)
    message = 'yes';
else
    message = 'no';
end

            %["Equilibrium Angles Orange: " + string(equilibrium_orange_array)],...
            %["Equilibrium Angles Blue: " + string(equilibrium_blue_array)],...
            %["Magnet Mount Angles (D,P): " + string(ang_dt)+","+string(ang_pt)]}
if(message_box)
    output1 = {["Cam Distortion: " + string(message)],...
            ["Magnet Mount Angles (D,P): " + string(ang_dt)+","+string(ang_pt)],...
            ["Drop Foot Angle Blue: " + string(Angle_DropFoot_blue)],...
            ["Transition Angles Dorsi (min,max): " + string(min(transition_angles(:,2)))+" to "+string(max(transition_angles(:,2)))],...
            ["Transition Angles Plantar (min,max): " + "-" + string(min(abs(transition_angles(:,1))))+" to -"+string(max(abs(transition_angles(:,1))))],...
            ["Energy Stored at midstance: " + string(midstance_energy)],...
            ["Energy Stored during Dorsiflexion: " + string(dorsi_energy)],...
            ["Energy Returned During Push Off: "+string(pushoff_energy)],...
            ["Energy Returned(%) Compared to Single Cam: " + string(ExpectedAdditionalEnergy_Percent)]};
    box1 = msgbox(output1,"Staring and Ending Gait Cycle on Blue");
    posn = get(box1, 'Position');
    set(box1, 'Position', posn+[0 0 70 0])

    
    output2 = {["Drop Foot Angle Orange: " + string(Angle_DropFoot_orange)],...
            ["Transition Angles Dorsi (min,max): " + string(min(transition_angles(:,1)))+" to "+string(max(transition_angles(:,1)))],...
            ["Transition Angles Plantar (min,max): " + "-" + string(min(abs(transition_angles(:,2))))+" to -"+string(max(abs(transition_angles(:,2))))],...
            ["Energy Stored at midstance: " + string(-midstance_energy)],...
            ["Energy Stored during Dorsiflexion: " + string(pushoff_energy)],...
            ["Energy Returned During Push Off: "+string(dorsi_energy)],...
            ["Energy Returned(%) Compared to Single Cam: " + string(100-ExpectedAdditionalEnergy_Percent+100)]};
    box2 = msgbox(output2,"Starting  and Ending Gait Cycle on Orange");
    posn = get(box2, 'Position');
    set(box2, 'Position', posn+[0 0 70 0])
    
end

%% Vectors for Objective function

%Cam 1
dorsi = dorsi_energy;
push = pushoff_energy;
midstance = midstance_energy;
Angle_DropFoot = Angle_DropFoot_blue;
vec1 = [dorsi push midstance Angle_DropFoot]; %CAM 1

%CAM 2
dorsi = pushoff_energy;
push = dorsi_energy;
midstance = -midstance_energy;
Angle_DropFoot = Angle_DropFoot_orange;
vec2 = [dorsi push midstance Angle_DropFoot]; %CAM 2

toc

