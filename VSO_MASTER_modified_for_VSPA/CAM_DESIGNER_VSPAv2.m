%% NEUROBIONICS LAB
% ELISSA WORKSPACE
% VSO Orthosis Cam Profile Derivation
% Nikko Van Crey | nikkovc@umich.edu | 847-917-9990
clear
close all
close all hidden
% addpath('C:\Users\nikkovc\Documents\CODE\MATLABFunctions');
addpath('TA');addpath('TA/ottobock');addpath('TA/wearable_tech');addpath('TA/old');addpath('IMPORTS');addpath('IMPORTS/VSO_functions');addpath('IMPORTS/data');addpath('inputs')
addpath('IMPORTS/MATLABFunctions/');
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
% load('inputs/VSO_configuration.mat')

VSPA_configuration();  % what configuration?? rotary
% load('inputs/VSPA_configuration.mat');     % what do i do here?? create linear function??
load('inputs/Rotary_VSPA_configuration.mat');
% from TA_function.mat (VSO) -- moment data and theta data are both 16x1
% doubles

grey = 1;
% VSO had blue = 1 but when I set blue = 1, then there is no
% 'x_spring_data' in spring_selection because spring = 'nadella'
blue = 0;
black = 1;
% theta_query = [8.7 10]; %marks corresponding ankle angles on cam profile and TA function
theta_query = [];

%Misc
characterization_parameter_testing = 1; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
different_cam = 0; %allows testing cams from pre'viously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_inv in plot select, maybe change gamma==0 line for work calculation in inverse model
dual_test = 0; % no dual cam

%% CHOOSE TA FUNCTION
TA_function() %torque-angle function?
load('inputs/TA_function_RotaryVSPA.mat')   % which one?

% Create linear T-A function (with stiffness 15.8 Nm/deg)
angle_linear = ((-1*(max_plantarflexion)):0.005:max_dorsiflexion); % based off of Figure 4 in Clites paper -- ROM of ankle in deg is around -15 to 20deg
theta_linear = deg2rad(angle_linear);
preferred_stiffness = 15.8; % Nm/deg;  going based off of Figure 3 in Clites paper -- preferred stiffness for 70kg person was ~17 Nm/deg
TA_linear = preferred_stiffness * angle_linear; % assume linear T-A relationship for now with stiffness of 17 Nm/deg
fileName = fullfile('inputs', 'TA_linear.mat');
save(fileName, 'TA_linear');

if(~dual_test) % when dual_test = 0, use spline interpolation using the dataset of moments and ankle angles for torque-angle curve
    theta_total = deg2rad((-1*max_plantarflexion):0.005:max_dorsiflexion);  % ankle ROM range
    theta = deg2rad(angle_linear); % convert angles to rad
    % spline interpolation of torque (M) across cont. angle range (theta_total)
    M = interp1(theta, TA_linear, theta_total,'spline'); % using linear T-A relationship instead
end

%% PLOTTING OPTIONS
primary_curve_notscaled = 0; %plots primary curve designed by hand with a scale factor of 1
primary_curve_scaled = 0; %plots scaled primary curve
HUMAN = 0;
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
%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat
%walking -- not sure if I'll want this initially
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
% this is used when we want torque-angle curves to come from precomputed
% idealized datasets instead of the previously interpolated spline curves
% used for dual-cam setup -- IGNORE
if(dual_test)
    roller_radius = 0.0085; %(meters) %Cam roller radius
    load('outputs/BlueMomentIdeal.mat')
    load('outputs/OrangeMomentIdeal.mat')
    load('outputs/theta_total.mat')
    theta_total = theta_total;
    M = OrangeMomentIdeal;
    %plot(theta_total,M)
    plantar_max = 40;
    dorsi_max = 40;
    equilibrium_angle = 0.02; % rad?
    scalefactor = 1;
    [~,equilibrium_index] = min(abs(M)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE); min finds the value and index of minimum and we only want the index
end

%% SPRING SELECTION
[titanium_data] = spring_selection(spring,x_center_min,x_center_max,1);  % select spring using VSPA configuration metrics

%% CAM GENERATION FROM FORWARD MODEL
[x,y,r,psi,theta_cam,x_center,epsilon,mu,y_off,gamma,kdelt,stroke,work_M] = forwared_model(theta_total,M,equilibrium_angle,titanium_data,dual_test);
%USING MATH TO OFFSET
[curve_x curve_y] = offsetCamCurve(x,y,r,psi,roller_radius,'offset','diff');

%% EXPORT CAM TO SOLIDWORKS
if(~dual_test) % when spline interpolation is being used (no dual cam)
    length(curve_x)
    % [curve_points] = Matlab2Solidworks(curve_x,curve_y);
    [curve_points] = Matlab2Solidworks(curve_y,curve_x);
    %length(curve_points)
    dlmwrite('outputs/cam_curve.txt', curve_points, '\t')   
    dlmwrite('outputs/moment_profile.txt', M, '\t')
end

%% CAM CURVE SELF INTERSECTIONS?
[intersections] = check_intersections(curve_x,curve_y,theta_total);
if(isempty(intersections)==0)  % if there are intersections, an error message will occur
    return
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

%% UPDATING MODEL TO CORRELATE WITH TESTING DATA
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
        kdelt_dorsi = 100000000000000000000000000000000000000000000000;
        kdelt_plantar = 100000000000000000000000000000000000000000000000;

        %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);%ToDo
        kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
        %kdelt = 10000000000000000000000000;
        spring = 'nadella';
        [titanium_data] = spring_selection(spring,x_center_min,x_center_max,1);
    end
    if(black)
        kdelt_dorsi = 600;  
        kdelt_plantar = 600;
        %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0); %ToDo
        kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
        figure(11)
        plot(rad2deg(theta_total),kdelt)
    end
else
    preload_inv = preload;
end

%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERSE MODEL)
if(plot_select)
    % xc_perc = [0.4 0.5 0.60];
    % xc_perc = [0.5];
    xc_perc = [0 0.5 1];
    % xc_perc = [0 1];
    % xc_perc = [0:0.1:1];
    % xc_perc = [1];
end

if(plot_all)
    xc_perc = [0:0.01:1];
end
x_center_inv = x_center_max-((x_center_max-x_center_min).*xc_perc);
ktranslational = polyval(titanium_data,x_center_inv);
x_center_inv = x_center_inv*mm2m; %ToDo (maybe didn't do this for previously generated cams)

%% Inverse Model
[theta_inv,delta_inv,M_ankle,theta_cam_inv,Angles,Moments,F_cam_3,ROM_index,cam_angles] = inverse_model(preload_inv,kdelt,x_center,x_center_inv,ktranslational,epsilon,mu,y_off,r,psi,gamma,dual_test);

%% Plot Inverse Model
figure(1); hold on
for i=1:length(theta_inv(:,1))
    if(abs((x_center_inv(i)-mm2m*(stroke*primary_percentage+x_center_min)))<0.0002)
        i_primary = i;
    end
    v = plot(rad2deg(theta_inv(i,:)),M_ankle(i,:),'Linewidth',1);
    %Line Color Selection
    if(blue) v.Color = [0, 0, 255]./255; end
    if(black) v.Color = [0, 0, 0]./255; end
    if(grey) v.Color = [225, 225, 225]./255; end
    % if(grey) v.Color = [158, 158, 158]./255; end
end

% axis([-40,45,-50,100])
axis([-20,20,-30,45])
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

%% SAVE INVERSE MODEL
% save('data/JIM/Cam_Moments', 'Moments');
% save('data/JIM/Cam_angles', 'Angles');

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


 %% Investigating unreasonable slope
TA_slope_orange_forward = dydx(M,theta_total);
TA_slope_orange_inverse = dydx(M_ankle(1,:),theta_inv(1,:));
figure(8)
hold on
plot(rad2deg(theta_total),TA_slope_orange_forward)
plot(rad2deg(theta_inv(1,:)),TA_slope_orange_inverse)





















%% ------------------------------PLOTTING------------------------------------
figure(4)
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
    figure(2)
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

figure(5); hold on
plot(rad2deg(theta_total),M,'k','Linewidth',1)
if(~dual_test)
plot(rad2deg(theta),TA_linear,'x','Linewidth',2,'markers',10,'Color',[1 0 0])       % replaced M_data with TA_linear
end
%plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[229,154,161]./255,'Linewidth',5)
fig_format('Angle (\circ)','Torque (Nm)','Desired Torque-Angle Curve')
legend('Primary Curve','Spline Points','Able-Bodied')

%% Plot Cam Forces
figure(11)
hold on
plot(x_center_inv*1000,F_cam_3./1000,'Linewidth',5)
fig_format('Slider Position [0-100%]','Cam Force [kN]','Cam Contact Force @'+string(rad2deg(ROM_thresh))+'deg Dorsiflexion')

%% Plot Spring Displacement

    %Change math to use difference in r value
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

figure(1); hold on;
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
    plot(rad2deg(theta_total), Energy_PrimaryCurve,'Linewidth',5)
    plot(rad2deg(theta_total),work_delta,'Linewidth',5)
    plot(rad2deg(theta_total),spring_work,'Linewidth',5)
    % plot(rad2deg(theta_total), work_M,'Linewidth',5)
    legend('Energy Stored by Primary Curve','Energy Stored by Shell','Energy Stored in Spring')
    fig_format('Ankle Angle ({\circ})','Work (Joules)','Energy Storage in VSPA')
    hold off
end

%% PLOT RADIUS OF CURVATURE
R = radofcurv(r, psi);
figure(7)
hold on
% plot(radian2deg*psi,R*m2mm,'linewidth',3)
% fig_format('Psi','Radius of Curvature','')
plot(radian2deg*theta_cam,R*m2mm,'linewidth',3)
fig_format('theta_cam','Radius of Curvature','')
axis([(-1*(max_plantarflexion)) max_dorsiflexion -50 0])  % ---> this seems wrong

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
    plot(rad2deg(theta_total),stiffness_instant,'linewidth',2)
    fig_format('Ankle Angle','Stiffness [Nm/rad]','Instananeous Stiffness of TA Relationship')

%% Automate Figure Placement
figs =  findobj('type','figure');
fig_autoplace(figs)


%% Message Box

if(message_box)
    output = {["Torque at ROM_index: " + string(M_ankle(end,ROM_index))],...
            ["Dorsi Stiffness [Nm/rad]: [" + string(min(k_all_d))+" | "+string(max(k_all_d))+']'],...
            ["Plantar Stiffness [Nm/rad]: [" + string(min(k_all_p))+" | "+string(max(k_all_p))+']'],...
            ["Cam ROM of Stiffest Position [Dorsi, Plantar]: [" + string(cam_angles(end,:))+" | "+string(cam_angles(:,end))+']'],...
            ["Ankle ROM [Dorsi, Plantar]: [" + string(max_dorsiflexion+","+string(max_plantarflexion))+']']}; 
    msgbox(output,"Simulation Results");
end
toc







