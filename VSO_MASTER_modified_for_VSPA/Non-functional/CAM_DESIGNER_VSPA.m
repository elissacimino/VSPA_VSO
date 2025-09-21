%% NEUROBIONICS LAB
% Powered VSPA Cam Profile Derivation, files derived from VSO Orthosis
% Andrea Berettoni | andrebe@umich.edu | 
% Nikko Van Crey | nikkovc@umich.edu | 847-917-9990
clear
close all
clc
close all hidden
% addpath('C:\Users\nikkovc\Documents\CODE\MATLABFunctions'); %don t need

% this
addpath('TA');
addpath('TA/datasets/');
addpath('TA/ottobock');
addpath('TA/wearable_tech');
addpath('TA/old');
addpath('IMPORTS');
addpath('IMPORTS/VSO_functions');
addpath('IMPORTS/data');
addpath('IMPORTS/MATLABFunctions/');
addpath('inputs')
tic

%% TO DO
%Line below used for cam generation and changed for inverse model
%titanium_data = polyfit(x_spring_data,k_spring_data,3);

%fix cam ROM from printing a ton of values
%make legend entries of inverse model and other places ignored
%make all cam checks functions
%update dual with fig_format()
%update deg2rad everywhere and manual calcs (ie 180/pi)
%make forward and inverse models functions
%write theta_cam check in a way where it doesn't ping a million times
%write a function that takes a vector for optimizer and puts it in the form of dual_cam_emily

%% CONFIGURABLES
%Which Prototype
% VSO_configuration()
blue = 1;
black = 0;
% in the following function insert geometric parameters and choose the
% torque angle input profile
Powered_VSPA_configuration(blue, black)
load('inputs/Rotary_VSPA_configuration.mat')

% theta_query = [8.7 10]; %marks corresponding ankle angles on cam profile and TA function
theta_query = [];

%Misc
characterization_parameter_testing = 0; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
different_cam = 0; %allows testing cams from pre'viously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_inv in plot select, maybe change gamma==0 line for work calculation in inverse model
dual_test = 0;

%% CONFIGURABLES
%Which Prototype
VSPA_configuration()
load('inputs/VSPA_configuration.mat')
grey = 1;
% theta_query = [8.7 10]; %marks corresponding ankle angles on cam profile and TA function
theta_query = [];

%Misc
characterization_parameter_testing = 1; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
different_cam = 0; %allows testing cams from pre'viously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_inv in plot select, maybe change gamma==0 line for work calculation in inverse model
dual_test = 0;
%% CHOOSE Torque-Angle FUNCTION
perc = 50; % insert if you wanna do it with 50 or 99 percentile %spostare da qui
TA_function_poweredVSPA(perc,ta_input, zero_origin)
load('inputs/TA_function_RotaryVSPA')
% theta_total = deg2rad(-max_plantarflexion:0.005:max_dorsiflexion);

if strcmp(ta_input, 'poweredVSPA')
    theta_total = thetapoints;
    %theta_total = theta;
elseif strcmp(ta_input, 'RotaryVSPA')
    theta_total = theta;
end
% theta = 
% theta_total = deg2rad(max_plantarflexion:0.005:max_dorsiflexion);
% theta = deg2rad(theta_deg);
% M = interp1(theta, M_data, theta_total,'spline');
%% CHOOSE TA FUNCTION
load('TA/datasets/CP_Trustep_TT01.mat')
max_dorsiflexion = 40;
max_plantarflexion = 40;
theta_total = pi/180*(-max_plantarflexion:0.005:max_dorsiflexion);
equilibrium_angle = 0;

Mpoints = [-25,-25,grid_torque,175,180];
thetapoints = deg2rad([-max_plantarflexion,-max_plantarflexion+20,grid_angle,max_dorsiflexion-20,max_dorsiflexion]);
M = interp1(thetapoints, Mpoints, theta_total,'makima');

figure(1); hold on
plot(theta_total*180/pi,M)
plot(thetapoints*180/pi,Mpoints,'x')
xlabel('Angle (deg)')
ylabel('Torque (Nm)')
title('Desired Torque-Angle Curve')
set(gcf,'color','w');
% TA_function()
% load('inputs/TA_function')
% if(~dual_test)
%     theta_total = deg2rad(plantar_max:0.005:dorsi_max);
%     theta = deg2rad(theta_deg);
%     M = interp1(theta, M_data, theta_total,'spline');
% end

%% PLOTTING OPTIONS
primary_curve_notscaled = 0; %plots primary curve designed by hand with a scale factor of 1
primary_curve_scaled = 0; %plots scaled primary curve
HUMAN = 1;
Nexgear_Tango = 0;
Collins = 0;
AFO = 0;
dashed = 0; %adds vertical dashed lines to indicate 20 degrees
energy_storage = 1;
message_box = 1;
shade = 0;

%(only choose one)
plot_all = 0;
plot_select = 1;

%% IMPORT STUFF
%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking 
load('Human_ankle_moment')
load('IMPORTS/Human_ankle_rot')
%Import Plantarflexioin data from VSPA Prosthetic
load('IMPORTS/Primary_data.mat')
%Import TA for a Plastic AFO
load('IMPORTS/PlasticAFO')
conversions()
load('inputs/conversions.mat')

%% CHECKING FOR USER ERROR (NOT BULLET PROOF)
if((plot_all+plot_select)>1)
    disp('Only choose 1 plotting method')
    return
end

%% INITIALIZE
s_lin = [];

%% SIMULATE DUAL CAM
% if(dual_test)
%     roller_radius = 0.0085; %(meters) %Cam roller radius
%     load('outputs/BlueMomentIdeal.mat')
%     load('outputs/OrangeMomentIdeal.mat')
%     load('outputs/theta_total.mat')
%     theta_total = theta_total;
%     M = OrangeMomentIdeal;
%     %plot(theta_total,M)
%     plantar_max = 40;
%     dorsi_max = 40;
%     equilibrium_angle = 0.02;
%     scalefactor = 1;
%     [~,equilibrium_index] = min(abs(M)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
% end

%% SPRING SELECTION
% I have only one possibility that is the max spring already characterized
% Inside spring selection I have to modify it with FEA2reality and not 
[titanium_data] = spring_selection_VSPA(spring,x_center_min,x_center_max,1, max_spring, max_FEA_only,spring_change);

%% CAM GENERATION FROM FORWARD MODEL
% [x,y,r,psi,theta_cam,x_center,epsilon,mu,y_off,gamma,kdelt,stroke,work_M] = forwared_model(theta_total,M,equilibrium_angle,titanium_data,dual_test);
% since i have interesctions with plantarflexion at zero torque I want to
% calculate only for dorsiflexion
only_dorsi = 0;
if only_dorsi == 1
    theta_total2 = theta_total(theta_total>=deg2rad(equilibrium_angle));
    M2 = M(theta_total>=deg2rad(equilibrium_angle));
elseif only_dorsi == 0
    theta_total2 = theta_total;
    M2 = M;
end
% stop plantarflexion at 30 deg!!
theta_total3 = theta_total2(theta_total2<=deg2rad(30));
M3 = M2(theta_total2<=deg2rad(30));
[x,y,r,psi,theta_cam,x_center,epsilon,mu,y_off,gamma,kdelt,stroke,work_M] = forwared_model_VSPA(theta_total3,M3,equilibrium_angle,titanium_data,dual_test);

%USING MATH TO OFFSET
[curve_x curve_y] = offsetCamCurve(x,y,r,psi,theta_total3,roller_radius,'offset','diff');

angle_roller = 0:0.001:2*pi;
x_roller = r0 + roller_radius*cos(angle_roller);
y_roller = roller_radius*sin(angle_roller);
drawCircle = @(x, y, roller_radius) rectangle('Position', [x-roller_radius, y-roller_radius, 2*roller_radius, 2*roller_radius],'Curvature', [1, 1],  'FaceColor', [.5, .5, .5]); %, 'FaceAlpha', 0.5
figure(3), hold on
% axis([-0.01 0.05 -0.02 0.025])
axis equal
grid on
plot(x,y,'--','LineWidth',2)
plot(curve_x,curve_y, 'r-','LineWidth',2)
plot(0,0)
plot(x,y,'--','LineWidth',2)
plot(curve_x,curve_y, 'r-','LineWidth',2)
% plot(x_roller,y_roller)
h = drawCircle(x(1), y(1), roller_radius);
% for k = 1:1000:length(x)
%     pause(0.5);
%     % Update the position of the circle
%     set(h, 'Position', [x(k)-roller_radius, y(k)-roller_radius, 2*roller_radius, 2*roller_radius]);
%     
%     % Pause for a short duration to create the animation effect
%     pause(0.00000000000005);
% end
xlabel('(m)')
ylabel('(m)')
t = title('shape of the cam profile')
t.FontSize = 18;
set(gcf,'color','w');
% legend
set(gca,'FontSize',10)

%% EXPORT CAM TO SOLIDWORKS
% if(~dual_test)
%     length(curve_x)
% [curve_points] = Matlab2Solidworks(curve_x,curve_y);
% [curve_points] = Matlab2Solidworks(curve_y,curve_x);
% %length(curve_points)
% dlmwrite('outputs/cam_curve_powered1.txt', curve_points, '\t')
% dlmwrite('outputs/moment_profilepowered1.txt', M, '\t')
% end

%% CAM CURVE SELF INTERSECTIONS? ASK
[intersections] = check_intersections(curve_x,curve_y,theta_total);
if(isempty(intersections)==0)
%     return
end

%% Check if psi is a function (Leading Hypothesis is that this is possible, but will lock spring and produce max stiffness)
%Doesn't use psi because we are evalating for the offset curve and not the progenitor curve
psi_offset_err_ = atan(curve_y./curve_x);
if min(diff(psi_offset_err_))<=0
    disp('Warning: offset cam curve is not a function in psi which may lock spring and produce peak stiffness')
end

%% CHECK IF MATH EXPLOITS THETA_CAM TO PRODUCE INFINITE STIFFNESS
for i = 2:length(theta_cam)
    if((theta_cam(i)-theta_cam(i-1))<=0) 
        disp('Error: Cam has unfeasable geometry')
        return
    end
end
 
%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE
if(different_cam)
    %import_single_cam()
end

%% UPDATING MODEL TO CORRELATE WITH TESTING DATA ------ NEVER USED this for VSPA
if(characterization_parameter_testing)
    %Preload
    % preload_inv = 0.2*preload; %wave and neg cams
    preload_inv = 1*preload; %used for everything else
    % preload_inv = 0.5*preload; %2.75*preload used for ICORR
    % preload_inv = 1*preload;
    %Series Compliance
    if(blue)
        %750 and 362 used for ICORR
%         kdelt_dorsi = 650;
%         kdelt_plantar = 350;
        % kdelt_dorsi = 1500;
        % kdelt_plantar = 1500;
        % 
        % kdelt_dorsi = 338;
        % kdelt_plantar = 318;
        kdelt_dorsi = 2000;
        kdelt_plantar = 2000;
        if only_dorsi == 1
            kdelt = kdelt_dorsi*ones(1,length(theta_total(theta_total>=deg2rad(equilibrium_angle))));
        elseif only_dorsi == 0
            kdelt = kdelt_dorsi*(theta_total);
        end
        %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);%ToDo
%         kdelt = kdelt_dorsi*ones(1,length(theta_total(theta_total>=deg2rad(equilibrium_angle))));%+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
        %kdelt = 10000000000000000000000000;
        spring = 'stiff';
        [titanium_data] = spring_selection_VSPA(spring,x_center_min,x_center_max,1);
    end
%     if(black)
%         kdelt_dorsi = 600;
%         kdelt_plantar = 600;
%         %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0); %ToDo
%         kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
%         figure(11)
%         plot(rad2deg(theta_total),kdelt)
%     end
else
    preload_inv = preload; %###### why it is only a value and not a vector? ####
end


%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERSE MODEL)
if(plot_select)
    % xc_perc = [0.4 0.5 0.60];
%     xc_perc = [0.5];
%     xc_perc = [0 0.5 1];
    % xc_perc = [0 1];
%     xc_perc = [0 0.8 1];
    xc_perc = [0:0.1:1];
    % xc_perc = [1];
end

if(plot_all)
    xc_perc = [0:0.01:1];
end
x_center_inv = x_center_max-((x_center_max-x_center_min).*xc_perc); %check this
x_center_inv2 = ((x_center_min+stroke)-(x_center_min+(1-xc_perc)*stroke))*mm2m;
ktranslational = polyval(titanium_data,x_center_inv2*m2mm);
x_center_inv = x_center_inv*mm2m; %ToDo (maybe didn't do this for previously generated cams)
% x_center_inv = x_center_inv*mm2m;
%% Inverse Model
[theta_inv,delta_inv,M_ankle,theta_cam_inv,Angles,Moments,F_cam, F_cam_2, F_cam_3,ROM_index,cam_angles,F_spring,F_ankle,F_spring_vert,F_ankle_vert,L,tau_inv] = inverse_model_VSPA(preload_inv,kdelt,x_center,x_center_inv,ktranslational,epsilon,mu,y_off,r,psi,gamma,dual_test);

%% Plot Inverse Model
cmap = parula(length(xc_perc));
figure(10); hold on

for i=1:length(theta_inv(:,1))
    if(abs((x_center_inv(i)-mm2m*(stroke*primary_percentage+x_center_min)))<0.0002)
        i_primary = i;
    end
    v = plot(rad2deg(theta_inv(i,:)),M_ankle(i,:),'Linewidth',2,'Color',cmap(i,:)) %,'LineStyle','-.'
    %Line Color Selection
%     if(blue) v.Color = [0, 0, 255]./255; end
%     if(black) v.Color = [0, 0, 0]./255; end
%     if(grey) v.Color = [225, 225, 225]./255; end
    % if(grey) v.Color = [158, 158, 158]./255; end
end
plot(rad2deg(pos_mean_rad),mom_mean_50pt,'LineWidth',3 ), hold on
plot(rad2deg(pos_mean_rad),mom_mean_99pt,'LineWidth',3 )
plot(rad2deg(pos_mean_rad),mom_mean_1pt,'LineWidth',3 )
xline(rad2deg(ROM_thresh))
xlabel('Ankle Angle ({\circ})'),
ylabel('Torque (Nm)')
axis([-20,25,-10,180])
legend('','','','','','','','','','','','50^{th} perc','99^{th} perc','1^{st} perc')
legend('Location','northwest')
legend boxoff
title('0% - 100% VSPA spring')
% '0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'
% axis([-20,20,-30,45])
if(dashed)
    plot([-20 -20],[110 -50],'--k','Linewidth',2)
    plot([20 20],[110 -50],'--k','Linewidth',2)
end
%DASHED LINE
if(primary_curve_scaled)
    h = plot(Angles(:,i_primary),Moments(:,i_primary),'Linewidth',5);
    %h = plot(radtodeg(theta_total),M,'Linewidth',5);
    h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
    scatter(rad2deg(theta_total(intersections)), M(intersections), 'MarkerEdgeColor', 'red','MarkerFaceColor', 'none', 'Marker', 'o')
end
fig_format('Ankle Angle ({\circ})','Torque (Nm)','')
if(shade)
    x_shade = [rad2deg(theta_inv(1,:)), fliplr(rad2deg(theta_inv(end,:)))];
    inBetween = [M_ankle(1,:), fliplr(M_ankle(end,:))];
    fill(x_shade, inBetween,[0.8824 0.8824 0.8824],'EdgeColor','none');
end
F_cam
%% look vertical force 
F_tot_vert = F_spring_vert - F_ankle_vert;
figure, hold on
for i=1:length(theta_inv(:,1))
    subplot(3,1,1), hold on
    v = plot(rad2deg(theta_inv(i,:)),F_spring_vert(i,:),'Linewidth',2,'Color',cmap(i,:)) %,'LineStyle','-.'
    xline(rad2deg(ROM_thresh))
    xlabel('Ankle Angle ({\circ})'),
    ylabel('F spring y (N)')
    grid on
%     set(gcf,'color','w');
    set(gca,'FontSize',14);
    set(gca,'FontName','Times New Roman');
    subplot(3,1,2) ,hold on
    v = plot(rad2deg(theta_inv(i,:)),F_ankle_vert(i,:),'Linewidth',2,'Color',cmap(i,:)) %,'LineStyle','-.'
    xline(rad2deg(ROM_thresh))
    xlabel('Ankle Angle ({\circ})'),
    ylabel('F ankle y (N)')
    grid on
%     set(gcf,'color','w');
    set(gca,'FontSize',14);
    set(gca,'FontName','Times New Roman');
    subplot(3,1,3), hold on
    v = plot(rad2deg(theta_inv(i,:)),F_tot_vert(i,:),'Linewidth',2,'Color',cmap(i,:)) %,'LineStyle','-.'
    xline(rad2deg(ROM_thresh))
    grid on
    xlabel('Ankle Angle ({\circ})'),
    ylabel('F tot y(N)')
%     set(gcf,'color','w');
    set(gca,'FontSize',14);
    set(gca,'FontName','Times New Roman');
end

%% ANDREA
theta_inclination = deg2rad(6); %+ dorsiflexion
vert_preload_inv = -x_center.*tan(preload_inv);
[M,I] = min(abs(theta_inv(6,:)-theta_inclination));
tau_17 = tau_inv(6,I);
% figure,plot(rad2deg(tau_inv(6,:))), hold on, plot(I,rad2deg(tau_inv(6,I)),'x')
x_17 = L(6)*cos(tau_17);
y_17 = L(6)*sin(tau_17);
x_switch = curve_x(theta_total3 == theta_inclination);
y_switch = curve_y(theta_total3 == theta_inclination);
R = [cos(theta_inclination) -sin(theta_inclination); sin(theta_inclination) cos(theta_inclination)];
original_vectors = [curve_x ; -curve_y];
rotated_vectors = R * original_vectors;
[x_rol y_rol] = plotCircle(r0-vert_preload_inv, 0, roller_radius);
[x_cam_t y_cam_t] = plotCircle(r0+y_center, -x_center, L(6));%r0+y_center
[x_rol_17 y_rol_17] = plotCircle(r0+(y_center-y_17)-vert_preload_inv, -(x_center-x_17), roller_radius);
[x_proof y_proof] = plotCircle(0, -0, sqrt(curve_x(end)^2+curve_y(end)^2));

figure(99), hold on, axis equal
plot(curve_x,-curve_y, 'r-','LineWidth',4) % parallel curve
plot(rotated_vectors(1,:), rotated_vectors(2,:),'Color', [0, 0, 0.5],'LineWidth',3)
% plot(curve_x,curve_y)
plot(x,-y, '--','LineWidth',1)
plot([0 r0], [ 0 0],'k') % r0
plot([r0 r0+y_center], [ 0 0],'k') %y cent
plot([0 r0+y_center],[0 -x_center],'k') %d
plot([r0+y_center r0+y_center],[-x_center 0],'k') %x_cent
plot([r0+y_center r0 ], [ -x_center 0],'b','LineWidth',2) %L
plot(x_rol, y_rol,'Color', [1, 0.5, 0],  'LineWidth', 1.5)
plot(x_cam_t, y_cam_t,'k-.')
plot(x_rol_17, y_rol_17,'Color',[0.8, 0.8, 0.8],'LineWidth',1.5)
plot(r0+y_center,  -x_center,'ko')
plot([r0+y_center r0+(y_center-y_17)-vert_preload_inv ], [-x_center -(x_center-x_17)],'Color',[0.8, 0.8, 0.8],'LineWidth',2) %L at 17 deg
plot(x_switch,-y_switch,'x')
plot(rotated_vectors(1,(theta_total3 == theta_inclination)), rotated_vectors(2,(theta_total3 == theta_inclination)),'x')
plot(x_proof, y_proof,'k-.')
axis([-0.001 0.06 -0.055 0.03])

%%

% figure for shifting the system
h = plotCircle(0, r0, roller_radius);
x_switch = x(theta_total3 == theta_inclination);
x_equ =  x(theta_total3 == 0);
y_eq = y(theta_total3 == 0);
y_switch = y(theta_total3 == theta_inclination);
R = [cos(theta_inclination) -sin(theta_inclination); sin(theta_inclination) cos(theta_inclination)];
original_vectors = [-curve_y; -curve_x];

% Rotate the vectors using matrix multiplication
rotated_vectors = R * original_vectors;


figure(5), hold on
plot(-curve_y,-curve_x,'LineWidth',2)
% plot(original_vectors(1,50:500),original_vectors(2,50:500))
plot(rotated_vectors(1,:), rotated_vectors(2,:),'LineWidth',1.5)
[a,b] = plotCircle(0,-r0,roller_radius);
try1 = [a;b];
[a2,b2] = plotCircle(-y_switch,-x_switch,roller_radius);
orgnl_rol = [a2;b2];
plot(a,b)
plot(orgnl_rol(1,:),orgnl_rol(2,:),'--')
rtd_rol = R*orgnl_rol;

plot(rtd_rol(1,:),rtd_rol(2,:),'LineWidth',1.5)
plot(rotated_vectors(1,400:4000), rotated_vectors(2,400:4000),'LineWidth',5)
plot(rtd_rol(1,25:35), rtd_rol(2,25:35),'LineWidth',5)

axis equal
[x_tangent1, y_tangent1] = findTangentPointFromData(rotated_vectors(:,400:4000), rtd_rol(:,25:35))
[x_tangent2, y_tangent2] = findTangentPointFromData(original_vectors(:,50:500), try1(:,5:50))

plot(x_tangent1, y_tangent1,'o')
plot(x_tangent2, y_tangent2,'o')
% legend('0 deg',['dorsi ' num2str(rad2deg(theta_inclination)) ' deg'])
vertical_decouple = abs(y_tangent1) - abs(y_tangent2);
%manual off
vertical_decouple = vertical_decouple -0.0003686;
xlabel('m')
ylabel('m')
fprintf('To do swing without winning the spring we should decouple the system vertically by %.4f mm\n', vertical_decouple*1e3);
[a4,b4] = plotCircle(0,-r0-vertical_decouple,roller_radius);
plot(a4,b4)

figure(99)
[x_rol_dec y_rol_dec] = plotCircle(r0+vertical_decouple, 0, roller_radius);
plot(r0+y_center+vertical_decouple,-x_center,'ko')% new L after decoupling
plot([r0+y_center+vertical_decouple r0+vertical_decouple],[-x_center 0],'b-.','LineWidth',2)
plot(x_rol_dec, y_rol_dec,'Color',[0, 0, 0.5],'LineWidth',2)
h = legend('equilibrium angle','6 deg dorsiflexion');
hText = findobj(h, 'type', 'text');
set(hText, 'Rotation', 90);
set(hText, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
legend Box off
xlabel('m')
ylabel('m')








%% SAVE INVERSE MODEL, 
save('IMPORTS/data/JIM/Cam_Moments', 'Moments');
save('IMPORTS/data/JIM/Cam_angles', 'Angles');

%% Angle Conversion
for c = 1:length(x_center_inv)
    figure(9)
    hold on
    device_angle_fit = polyfit(theta_cam_inv(c,:),theta_inv(c,:),10);
    device_angle = polyval(device_angle_fit,theta_cam_inv(c,:));
    plot(theta_cam_inv(c,:),device_angle)
    plot(theta_cam_inv(c,:),theta_inv(c,:))
    save('outputs/device_angle_fit','device_angle_fit')
end


%% Variable Stiffness Performance
k_all_d = [];
k_all_p = [];
for i = 1:length(Angles(1,:))
    [~,i_all_d] = min(abs(Angles(:,i)-theta_eval_dorsi));
    [~,i_all_p] = min(abs(Angles(:,i)-theta_eval_plantar));
    k_all_d = [k_all_d Moments(i_all_d,i)./deg2rad(Angles(i_all_d,i))];
    k_all_p = [k_all_p abs(Moments(i_all_p,i))./(abs(deg2rad(Angles(i_all_p,i))))];
end
performance = max(k_all_d)/min(k_all_p);
filter1 = theta_inv(i,:)>0;
filter2 = theta_inv(i,:)<ROM_thresh;
filter12 = logical(filter1.*filter2);
specific_energy = cumtrapz(theta_inv(i,filter12),M_ankle(i,filter12))/0.098;


 %% Investigating unreasonable slope ##### ask function dydx
TA_slope_orange_forward = dydx(M,theta_total);
TA_slope_orange_inverse = dydx(M_ankle(1,:),theta_inv(1,:));
figure(8)
hold on
plot(rad2deg(theta_total),TA_slope_orange_forward)
plot(rad2deg(theta_inv(1,:)),TA_slope_orange_inverse)





















%% ------------------------------PLOTTING------------------------------------
figure(60)
hold on
for c = 1:length(delta_inv(:,1))
    plot(rad2deg(delta_inv(c,:)),rad2deg(theta_cam_inv(c,:)),'linewidth',3)
    fig_format('Frame Angle (\circ)','Cam Angle (\circ)','')
    frame_rom = max(rad2deg(delta_inv(c,:)));
    cam_rom = max(rad2deg(theta_cam_inv(c,:)));
    total_rom = frame_rom+cam_rom;
end

%% Collins and Plastic AFO

if(Collins)
    collins_data(equilibrium_angle)     
end
if(AFO)
    figure(2)
    hold on
    plot(PlasticAFO(:,1),PlasticAFO(:,1),'Color',[0,0,0]./255,'Linewidth',5)
end
if(primary_curve_notscaled)
    figure(2)
    hold on
    plot(rad2deg(theta_total),M/scalefactor,'k','Linewidth',5)
end
if(HUMAN)
    figure(70)
    hold on
    weight = 70; %kg
    AbleBodiedAnkleMoment=xlsread('IMPORTS/Data from Bovi.xls','Joint Moments','AN407:AN470');%AQ507');
    AbleBodiedAnkleMoment = weight*AbleBodiedAnkleMoment;
    AbleBodiedAnkleAngle = xlsread('IMPORTS/Data from Bovi.xls','Joint Rotations','AN710:AN773');%:AQ810');
    AbleBodiedAnkleAngle=AbleBodiedAnkleAngle+22.5;
    plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[32,178,170]./255,'Linewidth',5)
end

if(Nexgear_Tango)
    tango_data(equilibrium_angle)
end

%% PLOT PRIMARY CURVE SPLINE POINTS

figure(80); hold on
plot(rad2deg(theta_total),M,'k','Linewidth',1)
if(~dual_test)
plot(theta_data,M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
end
%plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[229,154,161]./255,'Linewidth',5)
fig_format('Angle (\circ)','Torque (Nm)','Desired Torque-Angle Curve')
legend('Primary Curve','Spline Points','Able-Bodied')

%% Plot Cam Forces ############ check this
figure(11)
hold on
plot(x_center_inv*1000,F_cam_3./1000,'Linewidth',5)
fig_format('Slider Position [0-100%]','Cam Force [kN]','Cam Contact Force @'+string(rad2deg(ROM_thresh))+'deg Dorsiflexion')

%% Plot Spring Displacement

%     %Change math to use difference in r value
%     figure
%     hold on
%     plot(x_center_inv,s_lin,'Linewidth',5)
%     xlabel('Slider Position'); ylabel('Spring Vertical Displacement [mm]'); title('Spring Vertical Displacement at @30 deg');
%     set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)

%% PLOT THE CAM PROFILES
query_indices = [];
for i=1:length(theta_query)
    query_index = find(abs(theta_inv(1,:)-deg2rad(theta_query(i)))<deg2rad(0.02));
    query_indices = [query_indices;query_index(1)];
end

[x_circle y_circle] = plotCircle(r0,0, roller_radius);

figure(90); hold on;
plot(curve_x,curve_y,'k','LineStyle','-','Linewidth',1)%[0, 0.75, 0.75] [229,154,161]./255
%plot(x,y, 'Color',[229,154,161]./255 ,'LineStyle','--','Linewidth',2)%[0, 0.75, 0.75] [229,154,161]./255
plot(x_circle,y_circle,'b')
scatter(curve_x(intersections), curve_y(intersections), 'MarkerEdgeColor', 'red','MarkerFaceColor', 'none', 'Marker', 'o')
plot(curve_x(query_indices),curve_y(query_indices),'x','Linewidth',5,'markers',15,'Color',[0 1 0])
axis equal
xlabel('(meters)'); ylabel('(meters)'); title('Cam Profile')
legend('Offset','Surface')
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',1);

%% Plots Query Points on Cam Profiles and TA Functions
figure(2)
hold on
plot(rad2deg(theta_inv(1,query_indices)),M_ankle(1,query_indices),'x','Linewidth',5,'markers',15,'Color',[0 1 0])

%% PLOT THE ENERGY STORAGE
if(energy_storage)
    work_M = work_M - work_M(theta_total==deg2rad(equilibrium_angle));
    Energy_PrimaryCurve = cumtrapz(theta_inv(1,:),M_ankle(1,:));
    [~,eq_index_inv] = min(abs(M_ankle(1,:))); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
    Energy_PrimaryCurve = Energy_PrimaryCurve - Energy_PrimaryCurve(eq_index_inv);
    difference = max(work_M-Energy_PrimaryCurve);
    work_delta = 1/2.*kdelt.*delta_inv(1,:).^2;
    spring_work = work_M-work_delta;
    % spring_work = Energy_PrimaryCurve-work_delta;
    figure(21)
    hold on
%     plot(rad2deg(theta_total(theta_total>=deg2rad(equilibrium_angle))), Energy_PrimaryCurve,'Linewidth',5)
%     plot(rad2deg(theta_total(theta_total>=deg2rad(equilibrium_angle))),work_delta,'Linewidth',5)
%     plot(rad2deg(theta_total(theta_total>=deg2rad(equilibrium_angle))),spring_work,'Linewidth',5)
    plot(rad2deg(theta_total2), Energy_PrimaryCurve,'Linewidth',5)
    plot(rad2deg(theta_total2),work_delta,'Linewidth',5)
    plot(rad2deg(theta_total2),spring_work,'Linewidth',5) 

% plot(rad2deg(theta_total), work_M,'Linewidth',5)
    legend('Energy Stored by Primary Curve','Energy Stored by Shell','Energy Stored in Spring')
    fig_format('Ankle Angle ({\circ})','Work (Joules)','Energy Storage')
    hold off
end

%% PLOT RADIUS OF CURVATURE % ASK FUNCTION
% R = radofcurv(r, psi);
% figure(7)
% hold on
% % plot(radian2deg*psi,R*m2mm,'linewidth',3)
% % fig_format('Psi','Radius of Curvature','')
% plot(radian2deg*theta_cam,R*m2mm,'linewidth',3)
% fig_format('theta_cam','Radius of Curvature','')
% axis([plantar_max dorsi_max -50 0])

%% Plott Stiffness
%Nominal Stiffness
figure(14)
hold on
perc_tested = mm2perc(x_center_inv,x_center_max,x_center_min);
plot(perc_tested, k_all_d,'Color',[102 255 178]./255 ,'Linewidth',5)
plot(perc_tested, k_all_p,'Color',[152, 51, 255]./255 ,'Linewidth',5)
legend('Dorsiflexion','Plantarflexion')
fig_format('Slider Position (%)','Ankle Stiffness (Nm/rad)','')

%% Instantaneous Stiffness
figure(16)
    hold on
    i=1;
    stiffness_instant = dydx(M_ankle(i,:),theta_inv(i,:));
    plot(rad2deg(theta_total2),stiffness_instant,'linewidth',2)
    fig_format('Ankle Angle','Stiffness [Nm/rad]','Instananeous Stiffness of TA Relationship')

%% Automate Figure Placement
figs =  findobj('type','figure');
fig_autoplace(figs)


%% Message Box
dorsi_max = 30;
plantar_max = -30;
if(message_box)
    output = {["Torque at ROM_index: " + string(M_ankle(end,ROM_index))],...
            ["Dorsi Stiffness [Nm/rad]: [" + string(min(k_all_d))+" | "+string(max(k_all_d))+']'],...
            ["Plantar Stiffness [Nm/rad]: [" + string(min(k_all_p))+" | "+string(max(k_all_p))+']'],...
            ["Cam ROM of Stiffest Position [Dorsi, Plantar]: [" + string(cam_angles(end,:))+" | "+string(cam_angles(:,end))+']'],...
            ["Ankle ROM [Dorsi, Plantar]: [" + string(dorsi_max)+","+string(plantar_max)+']']}; 
    msgbox(output,"Simulation Results");
end
toc







