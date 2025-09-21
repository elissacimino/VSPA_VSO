%% NEUROBIONICS LAB

%Dual Cam VSO Orthosis Cam Profile Derivation
%Nikko Van Crey (nikkovc@umich.edu) and Hashim Quaraishi

clear
close all
close all hidden
addpath('IMPORTS')
addpath('DUAL_CAMS')
% addpath('DUAL_CAMS/Cams_7_13_21')
addpath('IMPORTS/nurbs_toolbox')

%% TO DO

%% CONFIGURABLES
emily_filter = 1;
stiff = 0;
final = 1;
different_cam = 0;
kdelt_nonlinear = 1; %series compliance can be a user-defined nonlinear function
blend = 0; %blends the two discrete series compliance values into eachother near neutral angle
angle_blend = deg2rad(0);
cam_forces = 0;
ramtech_wrong_geometry = 0;
characterization_parameter_testing = 0;

%% DESIGN PARAMETERS
ROM_thresh = deg2rad(27); %nikkROM that Cam forces are evaluated at
preload = 0.003; %to prevent backlash, the featherer the better, as it also places pressure on the slider below the spring
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
if(final)
    cam_radius = 0.0085;
end
x_off = 0;

%% PLOTTING OPTIONS
message_box = 1;
transition_mark = 1;
blue_cam = 1;
orange_cam = 1;

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
transition_angles = [];
equilibrium_blue_array = [];
equilibrium_orange_array = [];
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
    %load('dual_cams_ramtech.mat') %kdelt 600 for manufactured cams
    load('dual_cams_equilibrium.mat') %kdelt 600 for manufactured cams
end
if(final)
    %load('dual_cams_equilibrium.mat') %kdelt 600 for manufactured cams
    load('dual_cams_emily.mat') %kdelt 600 for manufactured cams
end

%% Initial variables
res = 0.005;               %resolution, step size between data points
theta = pi/180*(-switching_angle_plantar:res:switching_angle_dorsi);  %angles in energy recycling range, in radians
theta_total = pi/180*(-40:res:40);  %radians.


% pf_transition = find (rad2deg(theta_total)==-switching_angle_plantar)
% df_transition = find (rad2deg(theta_total)==switching_angle_dorsi)
[~,pf_transition] = min(abs(-switching_angle_plantar-rad2deg(theta_total)));
[~,df_transition] = min(abs(switching_angle_dorsi-rad2deg(theta_total)));

%% ToDo have Emily comment this
if(emily_filter)
    if theta(end) > blue_pts(end, 1) || theta(end) > orange_pts(end, 1)
        if round(theta(end), 4) < blue_pts(end, 1)
            theta(end) = round(theta(end), 4);
        elseif round(blue_pts(end, 1), 4) > theta(end)
            blue_pts(end, 1) = round(blue_pts(end, 1), 4);
        end
        if round(theta(end), 4) < orange_pts(end, 1)
            theta(end) = round(theta(end), 4);
        elseif round(orange_pts(end, 1), 4) > theta(end)
            orange_pts(end, 1) = round(orange_pts(end, 1), 4);
        end
    end
    if theta(1) < orange_pts(1, 1) 
        theta(1) = orange_pts(1, 1);
    elseif theta(1) < blue_pts(1, 1)
        theta(1) = blue_pts(1, 1);
    end
end



%% SPRING SELECTION
% x_spring = flip([36.2580000000000,41.9960000000000,47.7340000000000,53.4720000000000,59.2100000000000,64.9480000000000,70.6860000000000,76.4240000000000,82.1620000000000]);
% k_spring = [0.432465001702156,0.616126941919261,0.792258272479587,1.01274888074353,1.30070171341660,1.66157226218556,2.08664716371367,2.60261456478173,3.26999324785601]*10^6;
if(stiff)
    x_spring = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
    k_spring = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
end
if(final)
    %Measured on Instron
    x_spring = perc2mm([0,10.01,19.97,29.97,39.95,49.95,59.97,70.07,80.04,90.01,96.98],x_center_max,x_center_min);
    k_spring = [0.166318991334212,0.208391576135634,0.282351259287986,0.374190624007133,0.489817440908308,0.631742113520826,0.796116260994716,1.01916697238319,1.34705270360385,1.70337140522367,2.13270292544089]*10^6;
end
x_spring = perc2mm([0,10,20,30,40,50,60,70,80,90,99.5],x_center_max,x_center_min);
k_spring = [0.201402497683459,0.255563789663588,0.320737966921485,0.407993734082152,0.511685038850492,0.611758740381679,0.775498110913596,0.983751805764104,1.25531488175216,1.63060376036695,2.10105189535740]*10^6;

titanium = polyfit(x_spring,k_spring,5);
x_titan = x_center_max:-1:x_center_min;
k_titan = polyval(titanium,x_titan);
test = polyval(titanium,perc2mm([0],x_center_max,x_center_min))


%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
figure(3)
hold on
plot(x_spring,k_spring,'Linewidth',5)
plot(x_titan,k_titan)
legend('FEA','Fit')

%% ToDo have Emily comment this

% if theta(end) > blue_pts(end, 1) || theta(end) > orange_pts(end, 1)
%     if round(theta(end), 4) < blue_pts(end, 1)
%         theta(end) = round(theta(end), 4);
%     elseif round(blue_pts(end, 1), 4) > theta(end)
%         blue_pts(end, 1) = round(blue_pts(end, 1), 4);
%     end
%     if round(theta(end), 4) < orange_pts(end, 1)
%         theta(end) = round(theta(end), 4);
%     elseif round(orange_pts(end, 1), 4) > theta(end)
%         orange_pts(end, 1) = round(orange_pts(end, 1), 4);
%     end
% end
% if theta(1) < orange_pts(1, 1)
%     theta(1) = orange_pts(1, 1);
% elseif theta(1) < blue_pts(1, 1)
%     theta(1) = blue_pts(1, 1);
% end


%% Plotting TA curves, using the NURBS control points
figure(10); hold on; grid on
plot(blue_pts(:,1)*180/pi, blue_pts(:,2),'b:','Linewidth',5)
plot(orange_pts(:,1)*180/pi, orange_pts(:,2),'Linewidth',5,'Color', [255 136 0]/255)
plot(blue_control_points(:,1)*180/pi, blue_control_points(:,2),'k.-')
plot(orange_control_points(:,1)*180/pi, orange_control_points(:,2), '.-','Color', [176 99 60]/255)

%THESE LINES SPLINE THE BLUE AND RED CURVE
BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta); %blue curve
OrangeMoment = interp1(orange_pts(:,1),orange_pts(:,2),theta); %orange curve

%THESE LINES FIND THE ENERGY STORED AND RETURNED
[~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,OrangeIndex] = min(abs(OrangeMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex)))); %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane

%THESE LINES MOVE THE BLUE CONTROL POINT #5 IN THE Y-DIRECTION UNTIL ENERGY IS EQUAL
knob = blue_control_points(5,2)/(slope_dorsi_rad*pi/180);

    while ER>ES*1.0001
        knob = knob-0.001;
        blue_control_points(5,2) = knob;
        blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
        [~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled
    end

    while ER<ES*0.9999
        knob = knob+0.001;
        blue_control_points(5,2) = knob;
        blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))'; %evaluate the crv objectM = interp1(b_pts(:,1),b_pts(:,2),theta);
        BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
        [~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
        ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled
    end
    
% % %THIS PLOTS THE NEW CURVE, AFTER ENERGY HAS BEEN EQUALIZED
plot(theta*180/pi, BlueMoment,'Linewidth',5,'Color', [88 164 176]/255)
plot(blue_control_points(:,1)*180/pi, blue_control_points(:,2),'k.-')

%%%figure(3) plot settings
set(gcf,'color','w');
set(gca,'FontSize',25)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
xlim([-8 15])
ylim([-30 50])
legend('Initial Blue', 'Final Orange', 'Blue Control Points', 'Orange Control Points', 'Final Blue', 'FontSize',20,'Location','northwest')
title('NURBS TA Curves')


%% -----------------------------------------------------------ENERGY2-----------------------------------------------------
%THESE LINES FIND THE ENERGY STORED AND RETURNED
OrangeMoment = scalefactor*OrangeMoment;
BlueMoment = scalefactor*BlueMoment;
[~,BlueIndex] = min(abs(BlueMoment)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
[~,OrangeIndex] = min(abs(OrangeMoment)); %FIND INDEX FOR WHEN L == 0 (OR CLOSE)
ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex)))); %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end)))); %Energy recycled, in the top right quadrant of the TA plane
midstance_energy = ES; %Energy stored at midstance (J);
dorsi_energy = max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));%Energy stored over dorsiflexion (J)
pushoff_energy = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))); %Energy returned during pushoff (J)
ExpectedAdditionalEnergy_Percent = 100+(pushoff_energy-dorsi_energy)/dorsi_energy*100; %Energy returned (%)

figure(12)
hold on
plot(theta(1:BlueIndex),BlueMoment(1:BlueIndex),'Linewidth',4) %1
plot(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex),'Linewidth',4) %2
plot(theta(BlueIndex:end),BlueMoment(BlueIndex:end),'Linewidth',4) %3
plot(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end),'Linewidth',4) %4
legend('1','2','3','4')
OrangeMoment = (1/scalefactor)*OrangeMoment;
BlueMoment = (1/scalefactor)*BlueMoment;
%------------------------------------------------------------------------------------------

%% Plotting the final TA curves
%%% Defining the ideal TA curves for plantarflexion and dorsi flexion
%%% Code below makes the linear portions of the TA curve past the switching
th_plantar = deg2rad([-40 -30 -20]');
%M_plantar = slope_plantar_rad*th_plantar+deg2rad(equilibrium_blue);
M_plantar = slope_plantar_rad*th_plantar;
th_dorsi = deg2rad([12.5 15 22 angle_leveling 28 34 40]');
% M_dorsi = [slope_dorsi_deg*[rad2deg(th_dorsi(1:4))-equilibrium_orange]; (slope_end_dorsi*(rad2deg(th_dorsi(5:end))-equilibrium_orange-angle_leveling)+slope_dorsi_deg*angle_leveling)];
M_dorsi = [slope_dorsi_deg*[rad2deg(th_dorsi(1:4))]; (slope_end_dorsi*(rad2deg(th_dorsi(5:end))-angle_leveling)+slope_dorsi_deg*angle_leveling)];
M_points = [M_plantar; BlueMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
BlueMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
%BlueMomentIdeal = interp1(unique(theta_points),unique(M_points),theta_total,'spline'); %ToDo have Emily comment this
OrangeMomentIdeal = [BlueMomentIdeal(1:pf_transition-1) OrangeMoment BlueMomentIdeal(df_transition+1:end)];
%Scaling------(Nikko)
BlueMomentIdeal = scalefactor*BlueMomentIdeal;
OrangeMomentIdeal = scalefactor*OrangeMomentIdeal;
save('BlueMomentIdeal', 'BlueMomentIdeal');
save('OrangeMomentIdeal', 'OrangeMomentIdeal');
save('theta_total', 'theta_total');

figure(5)
hold on 
plot(theta_total*180/pi,BlueMomentIdeal,'linewidth',4,'Color', [88 164 176]/255)
plot(theta_total*180/pi,OrangeMomentIdeal,'linewidth',4,'Color', [255 136 0]/255)
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


%%%%%%%%%used later?
[~,BlueMomentIdealIndex] = min(abs(BlueMomentIdeal)); %FIND INDEX FOR WHEN BlueMomentIdeal == 0(OR CLOSE)
[~,OrangeMomentIdealIndex] = min(abs(OrangeMomentIdeal)); %FIND INDEX FOR WHEN OrangeMomentIdeal == 0 (OR CLOSE)



%% Check to see if the cam slope is postive
% slope_blue_error = [];
% slope_orange_error = [];
% 
% for p = 2:length(BlueMomentIdeal)
%     if((BlueMomentIdeal(p)-BlueMomentIdeal(p-1))<=0)
%         slope_blue_error = [BlueMomentIdeal(p); theta_total(p)*180/pi];
%     end
% end
% for q = 2:length(OrangeMomentIdeal)
%     if ((OrangeMomentIdeal(q)-OrangeMomentIdeal(q-1))<=0)
%         slope_orange_error = [OrangeMomentIdeal(q); theta_total(q)];
%     end
% end
% if((isempty(slope_blue_error)==0)||(isempty(slope_orange_error)==0))
%     disp('Error: slope of TA curve is negative (Error logs are [Moment, Angle]')
%     slope_orange_error
%     slope_blue_error
%     return
% end


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
work_P_fw = cumtrapz(theta_total,BlueMomentIdeal); %taking the area under the torque angle curve, energy in system
work_P_fw = work_P_fw - work_P_fw(BlueMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%torque angle curve work orange curve
work_D_fw = cumtrapz(theta_total,OrangeMomentIdeal); %taking the area under the torque angle curve, energy in system
work_D_fw = work_D_fw - work_D_fw(OrangeMomentIdealIndex); %energy stored at every entry/element/point is relative to the equilibrium position

%Series Compliance
if(kdelt_nonlinear)
    equilibrium_orange_actual = theta(OrangeIndex)
    kdelt_orange = kdelt_dorsi*(theta_total>equilibrium_orange_actual)+kdelt_plantar*~(theta_total>equilibrium_orange_actual);
    equilibrium_blue_actual = theta(BlueIndex);
    kdelt_blue = kdelt_dorsi*(theta_total>equilibrium_blue_actual)+kdelt_plantar*~(theta_total>equilibrium_blue_actual);

%     if(blend)
%         kdelt = kdelt_dorsi*(theta_total>angle_blend)+kdelt_plantar*(theta_total<-angle_blend);%+kdelt_blend.*theta_total(blend_index);
%         blend_index = find(kdelt==0);
%         kdelt_blend = kdelt_plantar:(kdelt_dorsi-kdelt_plantar)/(length(blend_index)-1):kdelt_dorsi;
%         kdelt(blend_index)=kdelt_blend;
%     end
else
    %kdelt = 700; % [Nm/rad] Fixed, stiffness of frame, FOR BOTH PLANTAR & Orange CURVE
    kdelt_orange = 600;
    kdelt_blue = 600;
    %kdelt = 100000000;
end

k = polyval(titanium,primary_slider)*(x_center)^2; %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L

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

%%Orange cam profile spring
%additional parameters
%%%gamma2o is the preload calculation of the spring at midstance, where the
%%%orange curve is at zero-torque. It is assumed that the energy stored in
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

%% Magnet Mount Transition Angles
%dt: dorsiflexion transition
%pt: plantarflexion transition
transition_dorsi = switching_angle_dorsi;
transition_plantar = -1*switching_angle_plantar;
% M_dt = OrangeMomentIdeal(find(theta_total==deg2rad(transition_dorsi)))
% M_pt = BlueMomentIdeal(find(theta_total==deg2rad(transition_plantar)))
M_dt = OrangeMomentIdeal(df_transition)
M_pt = BlueMomentIdeal(pf_transition)
thd_adjust = rad2deg(M_dt./kdelt_orange);
thp_adjust = rad2deg(M_pt./kdelt_blue);
thd_magnet = transition_dorsi-thd_adjust;
thp_magnet = transition_plantar-thp_adjust;
index_dt = find(theta_total==deg2rad(transition_dorsi));
index_pt = find(theta_total==deg2rad(transition_plantar));
rad2deg(theta_cam_fw(index_dt));
rad2deg(delta(index_dt));
x_dt = curve_x(index_dt);
y_dt = curve_y(index_dt);
x_pt = curve_x(index_pt);
y_pt = curve_y(index_pt);
ang_dt = atand(y_dt/x_dt); %angles needed in solidworks model
ang_pt = atand(y_pt/x_pt); %angles needed in solidworks model

%% EXPORT CAM TO SOLIDWORKS

% new_x = curve_x(2:10:length(curve_x)); 
% new_y = interp1(curve_x,curve_y,new_x);
% new_x2 = curve_x2(2:10:length(curve_x2)); 
% new_y2 = interp1(curve_x2,curve_y2,new_x2);
% curve_points_blue = 1000*[new_x', new_y', 0.*new_x'];
% curve_points_orange = 1000*[new_x2', new_y2', 0.*new_x2'];
% %curve_points = sortrows(curve_points, 2);
% dlmwrite('cam_curve_blue.txt', curve_points_blue, '\t')   
% dlmwrite('cam_curve_orange.txt', curve_points_orange, '\t') 

%% CAM CURVE SELF INTERSECTIONS? (Is it possible to manufacture cam)

intersections_blue = [];
intersections_orange = [];
for i = 2:length(curve_y2)
    if((curve_y(i)-curve_y(i-1))<0) 
        %intersections_blue = [intersections_blue; curve_y(i)];
        intersections_blue = [intersections_blue ;[i rad2deg(theta_total(i)) curve_y(i)]];
    end
    if((curve_y2(i)-curve_y2(i-1))<0) 
        %intersections_orange = [intersections_orange; curve_y2(i)];
        intersections_orange = [intersections_orange ;[i rad2deg(theta_total(i)) curve_y2(i)]];
    end
end
if(isempty(intersections_blue)==0 || isempty(intersections_orange)==0)
%     figure(25)
%     hold on
%     %%%%Offset curves after applying the parallel theorem
%     %%%Blue
%     plot(-curve_x,curve_y, 'Color', [88 164 176]/255,'Linewidth',1)
%     %%%Orange
%     plot(-curve_x2,curve_y2,'Color', [255 136 0]/255,'Linewidth',1)
%     axis equal
    disp('Error: intersections in cam. Check intersections_blue and intersections_orange in the command window')
    %return
end


%% CHECK IF MATH EXPLOITS NONMONOTONIC THETA_CAM TO BYPASS STIFFNESS STIFFNESS LIMITS(Second check for nonrealizable geometry)
for i = 2:length(theta_cam_fw)
    if((theta_cam_fw(i)-theta_cam_fw(i-1))<0) 
        disp('Error: blue cam has unfeasable geometry in theta_cam')
        return
    end
    if((theta_cam_fw2(i)-theta_cam_fw2(i-1))<0) 
        disp('Error: orange cam has unfeasable geometry in theta_cam')
        return
    end
end
figure(21)
hold on
plot(theta_total,theta_cam_fw)

%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE

if(different_cam)
    %Blue Cam
    SolidworksImport = readtable('cam_curve_plantar_C2.txt');
    x_import = table2array(SolidworksImport(:,2)).*0.001;
    y_import = -table2array(SolidworksImport(:,1)).*0.001;
    %x_import = smooth(x_import);
    %y_import = smooth(y_import);
    [x_import_offset, y_import_offset] = offsetCurve(x_import,y_import,-0.0095);
    

    %psi = acot(x_import_offset./y_import_offset);
    %r = y_import_offset./sin(psi);
    
     %Orange Cam
    SolidworksImport = readtable('cam_curve_orange_C2.txt');
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
    x_center_new = [primary_slider]*mm2m;
    ktranslational = [polyval(titanium,primary_slider)];

end

if(plot_select)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.5 1]);
    ktranslational = [polyval(titanium,x_center_new)];
    x_center_new = x_center_new*mm2m;
end

if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = [floor(x_center_max):-1:ceil(x_center_min)];
    k_VSO_all = polyval(titanium,x_VSO_all);
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end


%% change MS, BlueMomentAnkle, BlueMomentAnkle, Mi, yM, yL

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

    delta_inv = BlueMomentAnkle./kdelt_blue;    
    
    theta_inv = theta_cam_inv + delta_inv;

    %orange curve
    sigma_inv2 = sigma_inv + spring_preload_inv2(i) - spring_preload_inv(i);
    angle_constant_inv2(i) = angle_constant_inv(i) + spring_preload_inv2(i) - spring_preload_inv(i);
    
    omega_inv2 = acos((l_spring_inv(i).^2 - r2.^2 - d_inv(i).^2)./(-2*r2.*d_inv(i))); %law of cosines
    alpha_inv2 = -(atan(-x_center_new(i)/(-r0-y_center)) - omega_inv2);
    theta_cam_inv2 = alpha_inv2 + psi2;
    gamma_inv2 = acos((r2.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv2(i);

    OrangeMomentSpring = k(i)*(gamma_inv2 + spring_preload_inv2(i));  
    work_spring_inv2 = cumtrapz(gamma_inv2 ,OrangeMomentSpring); 

    OrangeMomentAnkle = diff(work_spring_inv2)./diff(theta_cam_inv2); 

    OrangeMomentAnkle(end+1) = OrangeMomentAnkle(end);

    delta_inv2 = OrangeMomentAnkle./kdelt_orange;

    theta_inv2 = theta_cam_inv2 + delta_inv2;

    %%%Naming legend items, so repetitive legend enteries can be avoided in
    %%%the final plot
    if(blue_cam)
        leg1(i) = plot(theta_inv/pi*180,BlueMomentAnkle,'-','Linewidth',4,'Color', [88 164 176]/255); %legend item 1, inverse blue curve per iteration of slider position
    end
    if(orange_cam)
        leg2(i) =  plot(theta_inv2/pi*180,OrangeMomentAnkle,'-','Linewidth',4,'Color', [255 136 0]/255); %legend item 1, inverse orange curve per iteration of slider position
    end

    %Cam Forces---------------------
    ROM_index = find(abs(theta_inv2-ROM_thresh)<deg2rad(1));%0.006
    if(cam_forces)
        F_cam = [F_cam OrangeMomentSpring(ROM_index(1))./l_spring_inv(i)];
        F_cam_2 = [F_cam_2 OrangeMomentAnkle(ROM_index(1))./r2(ROM_index(1))];
        F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];
    end
    %Energy
    difference = abs(OrangeMomentAnkle-BlueMomentAnkle);
    transition_tolerance = 0.005; % [Nm]
    check = difference<transition_tolerance;
    for j=2:length(check)
        if((rad2deg(theta_total(j))<(-switching_angle_plantar+3)) | (rad2deg(theta_total(j))>(switching_angle_dorsi-3)))%(((OrangeMomentAnkle(j)<-2) | (OrangeMomentAnkle(j)>8))&(abs(rad2deg(theta_inv(j)))<20))
            if(check(j)~=check(j-1))
                transition = [transition;j];
            end
        end
    end
    transition_angles = [transition_angles; rad2deg(theta_inv(transition(1:2)))];
    if(length(transition)~=2)
        disp('Transition Incorrect:')
        x_center_new(i)
    else
            transition;
    end
    if(transition_mark)
        plot(rad2deg(theta_inv(transition)),OrangeMomentAnkle(transition),'x','Linewidth',5,'markers',15,'Color',[1 0 0])
    end
    [~,BlueIndex_new] = min(abs(BlueMomentAnkle)); %FIND INDEX FOR WHEN M == 0(OR CLOSE)
    [~,OrangeIndex_new] = min(abs(OrangeMomentAnkle)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
    ES_new = max(abs(cumtrapz(theta_inv(1:BlueIndex_new),BlueMomentAnkle(1:BlueIndex_new)))) - max(abs(cumtrapz(theta_inv(1:OrangeIndex_new),OrangeMomentAnkle(1:OrangeIndex_new)))); %Energy captured between the curves, when orange curve reaches zero-torque. In the bottom left quadrant of the TA plane
    ER_new = max(abs(cumtrapz(theta_inv(BlueIndex_new:end),BlueMomentAnkle(BlueIndex_new:end)))) - max(abs(cumtrapz(theta_inv(OrangeIndex_new:end),OrangeMomentAnkle(OrangeIndex_new:end)))); %Energy recycled, in the top right quadrant of the TA plane
    midstance_energy_new = ES; %Energy stored at midstance (J)
    dorsi_energy_new = max(abs(cumtrapz(theta_inv(OrangeIndex_new:transition(2)),OrangeMomentAnkle(OrangeIndex_new:transition(2)))));%Energy stored over dorsiflexion (J)
    pushoff_energy_new = max(abs(cumtrapz(theta_inv(BlueIndex_new:transition(2)),BlueMomentAnkle(BlueIndex_new:transition(2))))); %Energy returned during pushoff (J)
    ExpectedAdditionalEnergy_Percent_new = 100+(pushoff_energy_new-dorsi_energy_new)/dorsi_energy_new*100; %Energy returned (%)
    ES_array = [ES_array ES_new];
    ER_array = [ER_array ER_new];
    midstance_energy_array = [midstance_energy_array midstance_energy_new];
    dorsi_energy_array = [dorsi_energy_array dorsi_energy_new];
    pushoff_energy_array = [pushoff_energy_array pushoff_energy_new];
    ExpectedAdditionalEnergy_Percent_array = [ExpectedAdditionalEnergy_Percent_array ExpectedAdditionalEnergy_Percent_new];
    %Equilibrium
    equilibrium_blue_array = [equilibrium_blue_array;rad2deg(theta_inv(BlueIndex_new))];
    equilibrium_orange_array = [equilibrium_orange_array;rad2deg(theta_inv2(OrangeIndex_new))];

end














%% ------------------------------PLOTTING------------------------------------
%INVERSE MODEL PLOTTING
if(blue_cam)
    %leg3 = plot(theta_total/pi*180,BlueMomentIdeal,'Linewidth',6,'Color','k','LineStyle','--'); %legend item 3, forward blue curve per iteration of slider position
end
if(orange_cam)
    %leg4 = plot(theta_total/pi*180,OrangeMomentIdeal,'Linewidth',6,'Color',[195,195,195]/255,'LineStyle','--'); %legend item 1, forward orange curve per iteration of slider position
end
set(gcf,'color','w');
set(gca,'FontSize',18)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
%legend([leg1(1) leg2(1) leg3 leg4],{'Inverse model blue','Inverse model orange', 'Primary curve blue', 'Primary curve orange'},'Location','northwest')
legend([leg1(1) leg2(1)],{'Inverse model blue','Inverse model orange', 'Primary curve blue', 'Primary curve orange'},'Location','northwest')
legend boxoff

xlim([-15 15])
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
figure(1); hold on;

%%%%The figures plotted have a layout of (-y,x) to illustrate the cam
%%%%in a more intuitive manner. In an orientation, as it will be placed in
%%%%the physical device

%%%%Offset curves after applying the parallel theorem
%%%Blue
plot(curve_x,curve_y,'-', 'Color', [88 164 176]/255,'Linewidth',2)
%%%Orange
plot(curve_x2,curve_y2,'-','Color', [255 136 0]/255,'Linewidth',2)

%%%Non-offset curves
%%%Blue
%plot(y,-x, '--', 'Color', [88 164 176]/255,'Linewidth',5)
%%%Orange
%plot(y2,-x2, '--', 'Color', [255 136 0]/255,'Linewidth',5)

%plot(0,0,'g*','linewidth',8) %ankle center of rotation

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

%% Plotting Series Compliance

figure(13)
hold on
plot(theta_inv/pi*180, kdelt_blue)
plot(theta_inv/pi*180, kdelt_orange)

%% Automate Figure Placement

% figs =  findobj('type','figure');
% fig_autoplace(figs)

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
            ["Equilibrium Angles Orange: " + string(mean(equilibrium_orange_array))],...
            ["Equilibrium Angles Blue: " + string(mean(equilibrium_blue_array))],...
            ["Transition Angles Dorsi (min,max): " + string(min(transition_angles(:,2)))+" to "+string(max(transition_angles(:,2)))],...
            ["Transition Angles Plantar (min,max): " + "-" + string(min(abs(transition_angles(:,1))))+" to -"+string(max(abs(transition_angles(:,1))))],...
            ["Energy Stored at midstance: " + string(midstance_energy)],...
            ["Energy Stored during Dorsiflexion: " + string(dorsi_energy)],...
            ["Energy Returned(%) Compared to Single Cam: " + string(ExpectedAdditionalEnergy_Percent)],...
            ["Energy Returned During Push Off: "+string(pushoff_energy)],...
            ["Magnet Mount Angles (D,P): " + string(ang_dt)+","+string(ang_pt)]};
    msgbox(output,"Simulation Results");
end


%% Functions

function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end

