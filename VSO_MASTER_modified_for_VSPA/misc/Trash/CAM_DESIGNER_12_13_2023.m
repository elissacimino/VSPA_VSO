%% NEUROBIONICS LAB
%function CAM_DESIGNER()
%tic
% VSO Orthosis Cam Profile Derivation
% Nikko Van Crey | nikkovc@umich.edyu | 8479179990
clear
close all
close all hidden
addpath('C:\Users\nikkovc\Documents\CODE\MATLABFunctions')
addpath('IMPORTS')
addpath('TA')
addpath('TA/ottobock')
addpath('TA/old')

%% TO DO
%decide whether series stiffness should be in TA files and make DUAL CAM consistent
%make files consistent in where they put cam roller radius
%make variable initialization consistent

%% CONFIGURABLES
%Which Prototype
blue = 1;
black = 0;
grey = 0;

%Misc
camDisturbance = 0; %allows code to modify position/orientation of cam for debugging more characterization results
characterization_parameter_testing = 0; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
different_cam = 0; %allows testing cams from pre'viously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_new in plot select, maybe change gamma==0 line for work calculation in inverse model
ottobock_cam = 0;
kdelt_nonlinear = 1; %series compliance can be a user-defined nonlinear function

%Cam (only choose one)
cam_lin = 0;
cam_nonlin = 0;
cam_feather = 0;
dual_test = 0;
  
%Spring (only choose one)
if(black)
    spring_stiff = 1;
    spring_feather = 0;
    %load('old/can_lin_cam4_cam5_cam6_RAMTECH')
    %load('ottobock/cam_tango_lin')
    %load('ottobock/cam_tango_up')
    load('ottobock/cam_tango_down')
    cam_radius = 0.0095; %(meters) %Cam roller radius of black prototype
end

if(blue)
    spring_stiff = 0;
    spring_feather = 1;
    cam_final = 1;
    cam_radius = 0.0085; %(meters) %Cam roller radius
    load('cam_final')
    %load('cam_weird')
    %load('cam_final_stiffeq')
    %load('cam_final_linear')
    %load('stiffness_limit')
    %load('cam_buckling')
    %load('psi_curvey_fuction_investigation')
    %Line below used for cam generation and changed for inverse model
    %titanium_data = polyfit(x_spring_data,k_spring_data,3);
end

%% DESIGN PARAMETERS
%MISC
Torque_DropFoot = -2.3; %Nm
ROM_thresh = deg2rad(25); %(deg) dorsiflexion angle that cam forces will be evaluated at
preload = 0.003; %(rad) Should be very small, the closer to 0 the better.
primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

%Geometric Parameters
y_center = 0.008;% (meters) Distance between top of simpgurele support (contact point under the spring) and cam roller axis
x_center_max = 88; %(mm) least stiff position in spring support stroke
x_center_min = 32.5; %(mm) most stiff position in spring support stroke
r0 = 0.03529; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)


%% PLOTTING OPTIONS

primary_curve_notscaled = 0; %plots primary curve designed by hand with a scale factor of 1
primary_curve_scaled = 0; %plots scaled primary curve
HUMAN = 0;
Nexgear_Tango = 1;
Collins = 0;
scale_Collins = 0.6;
AFO = 0;
cam_forces = 0;
zoom  = 1; %zooms plot to a smaller angle range
dashed = 0; %adds vertical dashed lines to indicate 25 degrees
energy_storage = 0;
message_box = 0;

%(only choose one)
plot_all = 0; %perc_max is applied to this 
perc_max = 0.99; %maximum percentage testing on JIM
plot_one = 0;
plot_select = 1;
ICORR_paper = 0;


%% IMPORT STUFF

%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking 
load('Human_ankle_moment')
load('IMPORTS/Human_ankle_rot')
%Import Plantarflexioin data from VSPA Prosthetic
load('IMPORTS/Primary_data.mat')
%Import Spring Data
load('IMPORTS/leafspring_fit.mat') %Fiberglass Translational Data
%Import TA for a Plastic AFO
load('IMPORTS/PlasticAFO')
load('IMPORTS/Conversions.mat')
load('IMPORTS/titanium_Max') %Titanium Translational Data


%% AUTO-CONFIGURATION

if(plot_all)
    springProperties = 1;
else
    springProperties = 0;
end
if(different_cam)
    cam_forces = 0;
    zoom = 0;
    message_box = 0;
end


%% CHECKING FOR USER ERROR (NOT BULLET PROOF)
if(blue)
    if((cam_lin+cam_nonlin+cam_feather+cam_final)>1)
        disp('Only choose 1 cam')
        return
    end
end
if((spring_stiff+spring_feather)>1)
    disp('Only choose 1 spring')
    return
end

if(plot_all+plot_one+plot_select>1)
    disp('Only choose 1 plotting method')
    return
end

%% INITIALIZE
F_cam = [];
F_cam_2 = [];
F_cam_3 = [];
s_lin = [];


%% TORQUE-ANGLE CURVES | SERIES COMPLIANCE | CAM ROLLER RADIUS

if(cam_nonlin)
    load('cam_nonlin')
    kdelt = 1200; %1200 (600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius = 0.0095; %(meters) %Cam roller radius
end

if(cam_lin)
    load('can_lin_cam4_cam5_cam6_RAMTECH')
    kdelt = 600; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius = 0.0095; %(meters) %Cam roller radius
end

if(cam_feather)
    load('cam_nonlin_feather')
    %load('cam_nonlin_feather_stiffequilibrium')
    %kdelt = 650; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius = 0.008; %(meters) %Cam roller radius
end

if(~dual_test)
    theta_total = deg2rad(plantar_max:0.005:dorsi_max);
    theta = deg2rad(theta_deg);
    M = interp1(theta, M_data, theta_total,'spline');
end

if(dual_test)
    cam_radius = 0.0085; %(meters) %Cam roller radius
    load('BlueMomentIdeal.mat')
    load('OrangeMomentIdeal.mat')
    load('theta_total.mat')
    theta_total = theta_total;
    M = OrangeMomentIdeal;
    %plot(theta_total,M)
    plantar_max = 40;
    dorsi_max = 40;
    equilibrium_angle = 0.02;
    scalefactor = 1;
    [~,equilibrium_index] = min(abs(M)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
end

%% Checks to make sure slope of torque angle curve doesn't become negative
% for p=2:length(M)
%     if((M(p)-M(p-1))<=0)
%         disp('Error: slope of TA curve is negative')
%         error_angle = rad2deg(theta(p))
%         return
%     end
% end



%% SPRING SELECTION

if(spring_stiff)
    %Measured on Instron
    x_spring_data = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
    k_spring_data = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
end

if(spring_feather)  
    %Measured on Instron
    %Thin Ball Bearing
    x_spring_data = perc2mm([0,10,20,30,40,50,60,70,80,90,99.5],x_center_max,x_center_min);
    k_spring_data = [0.201402497683459,0.255563789663588,0.320737966921485,0.407993734082152,0.511685038850492,0.611758740381679,0.775498110913596,0.983751805764104,1.25531488175216,1.63060376036695,2.10105189535740]*10^6;
end

titanium_data = polyfit(x_spring_data,k_spring_data,5);
%titanium_data = polyfit(x_spring_data,k_spring_data,3); %ToDo


%% CAM GENERATION FROM FORWARD MODEL

stroke = x_center_max-x_center_min;
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = x_center*m2mm;
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
if(~dual_test)
    work_M = work_M - work_M(theta_total==deg2rad(equilibrium_angle)); %center it so int_M = 0 when theta is at equilibrium
else
    work_M = work_M - work_M(equilibrium_index); %same thing but the equilibrium angle is calculated because it will change depending on dual cam file
end

% figure(17)
% hold on
% plot(work_M)

%Series Compliance
if(kdelt_nonlinear)
    if(blue)
        kdelt_dorsi = 650;
        kdelt_plantar = 350;
        %kdelt_dorsi = 650; % measured on Ottobock Prototype and used for final cams
        %kdelt_plantar = 350; % measured on Ottobock Prototype and used for final cams
        %kdelt_dorsi = 350; %used for feather cams
        %kdelt_plantar = 175; %used for feather cams
    end
    if(black)
%         kdelt_dorsi = 1450; % measured on Ottobock Prototype and used for final cams
%         kdelt_plantar = 350; % measured on Ottobock Prototype and used for final cams
        kdelt_dorsi = 600;
        kdelt_plantar = 600;
    end
    %kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*~(deg2rad(equilibrium_angle)>0); %ToDo
    kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
    figure(10)
    plot(rad2deg(theta_total),kdelt)
else
    kdelt = 600;
    disp('Make sure to use nonlinear kdelt for final order because the device stiffness changes depending on torque direction')
end

%Spring Stiffnesses
k = polyval(titanium_data,primary_slider)*(x_center)^2; %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L
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


% plot(rad2deg(theta_total),rad2deg(theta_cam),'linewidth',5)
% plot(rad2deg(theta_total),rad2deg(delta),'linewidth',5)
%plot(rad2deg(theta_cam),rad2deg(gamma),'linewidth',5)
M_spring = k.*(gamma+preload);
M_frame = kdelt.*delta;
spwork = cumtrapz(gamma,M_spring);
figure(17)
hold on
subplot(2,2,1)
hold on
plot(rad2deg(theta_total),spwork)
subplot(2,2,2)
hold on
plot(rad2deg(theta_total(1:end-1)),diff(spwork))
subplot(2,2,3)
hold on
plot(rad2deg(theta_total),rad2deg(theta_cam))
subplot(2,2,4)
hold on
plot(rad2deg(theta_total(1:end-1)),diff(rad2deg(theta_cam)))

figure(14)
hold on
subplot(2,2,1)
hold on
plot(rad2deg(gamma),M_spring,'linewidth',5)
plot(rad2deg(delta),M_frame,'linewidth',5)
%axis([-7,-6,-10,15])
subplot(2,2,2)
hold on
plot(rad2deg(theta_total),rad2deg(delta),'linewidth',5)
plot(rad2deg(theta_total),rad2deg(gamma),'linewidth',5)
plot(rad2deg(theta_total),rad2deg(theta_cam),'linewidth',5)
%axis([-7,-6,-2,0.5])
subplot(2,2,3)
hold on
plot(rad2deg(theta_total),M,'k','Linewidth',1)
%axis([-7,-6,-10,0])
subplot(2,2,4)
hold on
plot(rad2deg(theta_total),rad2deg(theta_cam),'linewidth',5)
%axis([-7,-6,-7,-5])
hold off


% Find psi, which is what r needs to be a function of. 
%The roller does not go straight down, so we can't use theta as our angle for the polar coordinates in the cam's reference frame
w_new = asin(L./r.*sin(gamma+sigma)); %This is the angle between r and the line between spring centers (law of sines)
alpha = w_new-omega; %This is the deviation from vertical that the spring has gone, in terms of angle from ankle center

%Alternative math to w_new and alpha lines above (Confirmed working)
%angle_constant_fw = atan((-y_center-r0)/-x_center); %This is the angle between d and the bottom of the spring
%omega_fw = asin(L./r.*sin(gamma+sigma)); %This is the angle between r and d (law of sines)
%alpha = omega_fw + angle_constant_fw-pi/2; %This is the deviation from vertical that the spring has gone, in terms of angle from ankle center


psi = theta_cam-alpha; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r

y = r.*sin(psi);
x = r.*cos(psi);

% figure(15)
% hold on
%plot(psi,r)
%plot(theta_cam,dydx((r-r0).^2,theta_cam))
Elin = polyval(titanium_data,primary_slider).*(r-r0).^2;
Erot = k.*gamma.^2;
%plot(theta_cam,(gamma-preload).^2)
figure(13)
plot(rad2deg(theta_total),16-M)
set(gcf,'color','w');
set(gca,'FontSize',12)
set(gca,'linewidth',2)
xlabel('Ankle Angle ({\circ})')
ylabel('Net Torque (16Nm - VSO Torque)')
% stiffness_instant = dydx(M,theta_total);
% plot(rad2deg(theta_total),stiffness_instant)
%plot(theta_cam,(r-r0).^2)
%plot(theta_cam,polyval(titanium_data,primary_slider).*(r-r0).^2)
%plot(theta_cam,k.*gamma.^2)
%plot(theta_cam,dydx(Erot,theta_cam))

%USING MATH TO OFFSET
[curve_x curve_y] = offsetCamCurve(x,y,r,psi,cam_radius,1,0);
% xprime = diff(x)./diff(psi);
%     xprime(end+1) = xprime(end);
% yprime = diff(y)./diff(psi);
%     yprime(end+1) = yprime(end);
% curve_x = x + -cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
% curve_y = y + -cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);

%% REPORTS FAULTY CAM INDEXES TO THE COMMAND LINE
i=1;
bad = [];
 while i<length(curve_x)
        if isinf(curve_x(i)) == 1 || isnan(curve_y(i))
            bad = [bad;i]; 
            i;
        end
        if isinf(curve_y(i)) == 1 || isnan(curve_y(i)) 
            bad = [bad;i]; 
            i;
        end
        i = i+1;
 end
 if(isempty(bad)==0)
    disp('Error: cam is returning NaN')
    return
 end
 
 %LINES BELOW ARE SKETCHY (only uncomment for debugging purposes, this gets rid of the faulty cam indexes without fixing the core issue)
%curve_x(bad) = []; 
%curve_y(bad) = [];




%% EXPORT CAM TO SOLIDWORKS

% if(~dual_test)
%     new_x = curve_x(2:10:length(curve_x));
%     new_y = interp1(curve_x,curve_y,new_x);
%     curve_points = 1000*[new_y', new_x', 0.*new_x'];
%     %curve_points = sortrows(curve_points, 2);
%     dlmwrite('cam_curve.txt', curve_points, '\t')   
%     dlmwrite('moment_profile.txt', M, '\t')
% end

%% Debugging whether y can be not a function when psi is a function
figure(18)
hold on
subplot(2,2,1)
hold on
plot(rad2deg(psi),r,'linewidth',5)
%axis([-7,-6,-10,15])
subplot(2,2,2)
hold on
plot(curve_y,curve_x,'linewidth',5)
axis equal
hold off


%% CAM CURVE SELF INTERSECTIONS?

intersections = [];
for i = 2:length(curve_y)
    if((curve_y(i)-curve_y(i-1))<=0) 
        intersections = [intersections; [i rad2deg(theta_total(i)) curve_y(i)]];
    end
end
if(isempty(intersections)==0)
    disp('Error: intersections in cam')
    %return
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
    kdelt = 650; %ToDO
    if(ottobock_cam)
        %data = xlsread('ViktorCam.csv');
        data = xlsread('MathDebugCam.csv');
        x_otto = data(:,1).*0.001;
        y_otto = data(:,2).*0.001;
        y_import = [min(y_otto):(max(y_otto)-min(y_otto))/9999:max(y_otto)];
        CamOttobock = polyfit(y_otto,x_otto,8);
        x_import = polyval(CamOttobock,y_import);
        figure(1)
        hold on
        plot(x_otto,y_otto,'o')
        plot(x_import,y_import)
        axis equal
    else
        data = xlsread('MathDebugCam.csv');
        x_import_offset = data(:,1)'.*0.001+6.5*mm2m;
        y_import_offset = data(:,2)'.*0.001;
        % res_mag = 10;
        % for i=1:(length(y_file)-1)
        %     inc_y = (y_file(i+1) - y_file(i))/res_mag;
        %     inc_x = (x_file(i+1) - x_file(i))/res_mag;
        %     for j=0:1:res_mag
        %         x_import(i+j) = x_file(i)+j*inc_x;
        %         y_import(i+j) = y_file(i)+j*inc_x;
        %     end
        % end

        %y_import = [min(y_file):(max(y_file)-min(y_file))/9999:max(y_file)];
        %Cam = polyfit(y_file,x_file,8);
        %x_import = polyval(Cam,y_import);
        %SolidworksImport = readtable('cam_feather_nonlin_0dot15.txt');
        %SolidworksImport = readtable('cam_3_final.txt');
        %SolidworksImport_Offset = readtable('CamTesting3.txt');
        % x_import = table2array(SolidworksImport(:,2)).*0.001;
        % y_import = table2array(SolidworksImport(:,1)).*0.001;
        % x_import = smooth(x_import);
        % y_import = smooth(y_import);
    end

    %USING MATH TO OFFSET TO PROGENITOR CURVE
    % psi_import = atan(y_import./x_import);
    % r_import = x_import./cos(psi_import);
    % [x_import_offset y_import_offset] = offsetCamCurve(x_import, y_import, r_import, psi_import, cam_radius, -1, 0);

    

    %Invert to get (r,psi)
    psi = acot(x_import_offset./y_import_offset);
    r = y_import_offset./sin(psi);

    %Plot Psi
    figure(12)
    hold on
    plot(psi,r,'linewidth',5)

    %USING MATH TO OFFSET TO OFFSET CURVE
    % psi_import_offset = atan(y_import_offset./x_import_offset);
    % r_import_offset = x_import./cos(psi_import_offset);
    [x_import_offset_back y_import_offset_back] = offsetCamCurve(x_import_offset, y_import_offset, r, psi, cam_radius, 1, 1);
    

    %PLOTTING CAM PROFILES
    figure(11)
    hold on
    plot(x_import_offset,y_import_offset,'linewidth',3)
    %plot(x_import_offset,y_import_offset)
    plot(x_import_offset_back,y_import_offset_back,'linewidth',2)
    axis equal
%     polarplot(psi,r)
%     polarplot(psi2,r2)
    hold off
end


%% TESTING DIFFERENT POSITIONS AND ORIENTATIONS OF THE CAM (MECHANICALLY DEBUGGING ONLY)

if(camDisturbance)
    %Position
    x = x;
    y = y;
    curve_new = [x;y];
    
    %Rotation
    degreesOfRotation = 0;
    rotationMatrix = [cosd(degreesOfRotation) -sind(degreesOfRotation);
                      sind(degreesOfRotation) cosd(degreesOfRotation)];
    transform = rotationMatrix*curve_new;
    x = transform(1,:)+0; %maybe add x post transform?
    y = transform(2,:)+0; %maybe add y post transform?
    
end


%% UPDATING MODEL TO CORRELATE WITH TESTING DATA

if(characterization_parameter_testing)
    %Preload
    preload = 0.00000000000001*preload; %2.75*preload used for ICORR
    %Series Compliance
    if(kdelt_nonlinear && blue)
        %750 and 362 used for ICORR
        kdelt_dorsi = 650;
        kdelt_plantar = 362;
        %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);%ToDo
        kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
        %kdelt = 10000000000000000000000000;
    end
    if(kdelt_nonlinear && black)
        kdelt_dorsi = 600;
        kdelt_plantar = 600;
        %kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0); %ToDo
        kdelt = kdelt_dorsi*(theta_total>=deg2rad(equilibrium_angle))+kdelt_plantar*(theta_total<deg2rad(equilibrium_angle));
        figure(12)
        plot(rad2deg(theta_total),kdelt)
    end
end


%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERSE MODEL)

%MATH BACKWARDS(Everything gets backed out by new geometry + psi and r from primary curve)

% x_center_new = [x_center_max,75,primary_slider,50,45,40,x_center_min];
% ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3)), polyval(titanium,x_center_new(4)),polyval(titanium,x_center_new(5)), polyval(titanium,x_center_new(6)), polyval(titanium,x_center_new(7))];
% x_center_new = x_center_new*mm2m;

if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = x_center_max:-(x_center_max-x_center_min)*perc_max/56:(x_center_max-(x_center_max-x_center_min)*perc_max);
    k_VSO_all = polyval(titanium_data,x_VSO_all);
    %x_center_new = x_VSO_all;
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end

if(plot_one)
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0.5]); %0.675 0.55
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0.4]);
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0.58]);
    if(blue)
        x_center_new = x_center_max-((x_center_max-x_center_min)*[0.5]);
    else
        x_center_new = x_center_max-((x_center_max-x_center_min)*[0.5]);
    end
    ktranslational = polyval(titanium_data,x_center_new);
    x_center_new = x_center_new*mm2m;

end

if(plot_select)
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.99]);
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.5 1]);
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0.85 0.875 0.90 0.925 0.95 0.975 1]);
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[1]);
    ktranslational = polyval(titanium_data,x_center_new);
    x_center_new = x_center_new*mm2m;
end


vert_preload_inv = -x_center.*tan(preload); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./-x_center_new);  %This allows the preload to update as the slider moves

figure(2); hold on

%% Preallocation
num_slider_positions = length(x_center_new);
L = NaN(1,num_slider_positions);
tau = NaN(1,num_slider_positions);
zeta = NaN(1,num_slider_positions);
d = NaN(1,num_slider_positions);
beta = NaN(1,num_slider_positions);
omega = NaN(1,num_slider_positions);
sigma = NaN(1,num_slider_positions);
omega_new = NaN(num_slider_positions,length(r));
alpha_new = NaN(num_slider_positions,length(r));
theta_cam = NaN(num_slider_positions,length(r));
gamma_new = NaN(num_slider_positions,length(r));
k = NaN(1,num_slider_positions);
M_spring = NaN(num_slider_positions,length(r));
work_spring = NaN(num_slider_positions,length(r));
M_ankle = NaN(num_slider_positions,length(r));
delta = NaN(num_slider_positions,length(r));
theta_new = NaN(num_slider_positions,length(r));
Moments = NaN(length(r),num_slider_positions);
Angles = NaN(length(r),num_slider_positions);

%% Inverse Model
tic
for i = 1:length(x_center_new)
    tau(i) = atan(y_center/x_center_new(i));
    zeta(i) = -tau(i)+pi-epsilon;
    L(i) = sqrt(x_center_new(i).^2+y_center^2); 
    d(i) = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center_new(i))^2); %This is the distance between virtual spring centers
    beta(i) = atan((y_center+y_off)/(x_center_new(i)+x_off)); %This is the angle between horizontal and the line between spring centers
    omega(i) = pi-beta(i)-epsilon;
    sigma(i) =zeta(i)-omega(i); %This is the angle between virtual spring and line through spring centers

    %I need to reverse out gamma and delta from psi and r:
    omega_new(i,:) = acos((L(i).^2 - r.^2 - d(i).^2)./(-2*r.*d(i))); %math in notebook (Law of Cosines)
    alpha_new(i,:) = omega_new(i,:)-omega(i);
    theta_cam(i,:) = alpha_new(i,:) + psi; 
    gamma_new(i,:) = acos((r.^2 - L(i)^2 - d(i)^2)./(-2*L(i)*d(i)))-sigma(i); %math in notebook (Just do r calculation in reverse)
    k(i) = ktranslational(i).*x_center_new(i)^2; %rotary stiffness
    %k(i) = ktranslational(i).*L(i)^2;
    M_spring(i,:) = k(i)*(gamma_new(i,:) + spring_preload_inv(i));

    work_spring(i,:) = cumtrapz(gamma_new(i,:),M_spring(i,:));
    if(~dual_test & ~different_cam)%ToDo
        work_spring(i,:) = work_spring(i,:) - work_spring(i,gamma==0);
    end

    %Differientiate to get ankle torque
    if(different_cam)
        M_ankle = dydx(work_spring(i,:),theta_cam(i,:));
    else
        M_ankle(i,1:end-1) = diff(work_spring(i,:))./diff(theta_cam(i,:)); %diff takes differences change in Moment/change in theta_cam
        M_ankle(i,end) = M_ankle(i,end-1); %diff() function decreases the length of the vector by one
    end

    delta(i,:) = M_ankle(i,:)./kdelt;
    theta_new(i,:) = theta_cam(i,:) + delta(i,:);
    Moments(:,i) = M_ankle(i,:);
    save('Cam_Moments', 'Moments');
    Angles(:,i) = rad2deg(theta_new(i,:));
    save('Cam_angles', 'Angles');
    if(abs((x_center_new(i)-mm2m*(stroke*primary_percentage+x_center_min)))<0.0002)
        i_primary = i;
    end
    v = plot(rad2deg(theta_new(i,:)),M_ankle(i,:),'Linewidth',5);
    %v.Color = [224, 224, 224]./255; %shaded grey
    if(blue)
        v.Color = [0, 0, 255]./255;
    end
    if(black)
        v.Color = [0, 0, 0]./255;
        %v.Color = [175, 175, 175]./255;
    end
    if(grey)  
        v.Color = [175, 175, 175]./255; %[96,96,96]/255
    end
    %v.Color = [0, 192, 192]./255;
    %v.Color = [224, 224, 224]./255;
    %v.Color = [204, 153, 205]./255;

    %Cam Forces---------------------
    ROM_index = find(abs(theta_new(i,:)-ROM_thresh)<deg2rad(0.02));
    if(x_center_new(i)==x_center)
        DropFoot_index = find(abs(M_ankle(i,:)-Torque_DropFoot)<0.02);
        if(isempty(DropFoot_index))
            Angle_DropFoot_blue = plantar_max
        else
            Angle_DropFoot = rad2deg(theta_new(i,DropFoot_index(1)))
        end
    end
    if(cam_forces)
        F_cam = [F_cam M_spring(i,ROM_index(1))./L(i)];
        F_cam_2 = [F_cam_2 M_ankle(i,ROM_index(1))./r(ROM_index(1))];
        F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];
    end
end
toc
axis([-40,45,-50,100])
if(dashed)
    plot([-25 -25],[110 -50],'--k','Linewidth',2)
    plot([25 25],[110 -50],'--k','Linewidth',2)
end
 
%DASHED LINE
b = plot(rad2deg(theta_total),M);
b.LineWidth = 2; b.Color = [0,0,0]/255;
%figure(23); hold on
if(primary_curve_scaled)
    h = plot(Angles(:,i_primary),Moments(:,i_primary),'Linewidth',5);
    %h = plot(radtodeg(theta_total),M,'Linewidth',5);
    h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
end
% plot(radtodeg(theta),M,'Linewidth',2,'Color','k','LineStyle','--')
% scatter(radtodeg(theta),M)
set(gcf,'color','w');
set(gca,'FontSize',12)
set(gca,'linewidth',2)
xlabel('Ankle Angle ({\circ})')
ylabel('Torque (Nm)')
if(zoom)
%     torque_axis = M_ankle(ROM_index(1))+20;
%     axis([-rad2deg(ROM_thresh)-5 rad2deg(ROM_thresh)+5 -0.33*torque_axis M_ankle(ROM_index(1))+20])
    %axis([-19 19 -20 100])
    axis([-30 30 -100 140])
end
%title('Expected Range of Stiffnesses Available')
%% Angle Conversion
for c = 1:length(x_center_new)
    figure(9)
    hold on
    device_angle_fit = polyfit(theta_cam(c,:),theta_new(c,:),10);
    device_angle = polyval(device_angle_fit,theta_cam(c,:));
    plot(theta_cam(c,:),device_angle)
    plot(theta_cam(c,:),theta_new(c,:))
    save('device_angle_fit','device_angle_fit')
end


%% Theoretical Maximum Stiffness
kdelt_shoe = 650;
kdelt_rigidshoe = 1100;
kdelt_rigid = 9999999999999999999999999999999;
kdelt_query = [kdelt_shoe kdelt_rigidshoe kdelt_rigid];
for s = 1:length(kdelt_query)
    ktranslational_max = polyval(titanium_data,x_center_min);
    k_spring_rot_max = ktranslational_max.*(x_center_min*mm2m)^2; %rotary stiffness
    k_VSO_max = (k_spring_rot_max^(-1)+kdelt_query(s)^(-1))^(-1);
end

%% Variable Stiffness Performance
k_all_d = [];
k_all_p = [];
for i = 1:length(Angles(1,:))
    i_all_d = min(find(abs(Angles(:,i)-15.5)<0.01));
    i_all_p = min(find(abs(Angles(:,i)-(-15.5))<0.01));
    k_all_d = [k_all_d Moments(i_all_d,i)./deg2rad(Angles(i_all_d,i))];
    k_all_p = [k_all_p abs(Moments(i_all_p,i))./(abs(deg2rad(Angles(i_all_p,i))))];
end

tested_slider = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.97]*100;
k_nominal_dorsi = [20.5977055808294,27.5082776030924,31.9382457223319,41.2460644603543,52.9328108372973,69.6584916294172,89.9475320136406,112.258373429061,139.873250822126,176.657486877708,194.142594443256];
k_nominal_plantar = [12.6197712757929,10.8145659171265,14.7832578273618,14.1709308429494,16.3364810488719,18.4838772511418,24.8186988002824,27.4211856262180,34.6933570859923,41.3673542727861,45.7576370849639];
k_stiff_dorsi = [43.0309831124755,58.3112702765042,73.5122131140735,86.9494387880790,103.519571539201,131.058093440493,159.515709966599,197.590165328076,239.123149783251,291.313610377622,330.029741350539];
k_stiff_plantar = [8.47659024670832,12.3722816891514,14.3044892730993,17.8098890999164,19.4138112040509,22.4025124320306,27.0062631088588,30.6521081074033,37.5281286766378,47.3981350570011,50.6222098401101];

if(ICORR_paper)
    if(plot_select)
        %Nominal Stiffness
        figure(9)
        subplot(1,2,1)
        hold on
        plot(tested_slider, k_all_d,'Color',[175, 175, 175]./255 ,'Linewidth',5)
        plot(tested_slider, k_all_p,'Color',[175, 175, 175]./255 ,'Linewidth',5,'HandleVisibility','off')
        plot(tested_slider, k_nominal_dorsi,'Color',[0.7386, 0, 0] ,'LineStyle','--', 'Linewidth',5)
        plot(tested_slider, k_nominal_plantar, 'Color',[0.7386, 0, 0] ,'LineStyle','--', 'Linewidth',5)
        xlabel('Slider Position (%)')
        ylabel('Ankle Stiffness (Nm/rad)')
        legend('Model','Measured')
        legend boxoff
        ylim([0 340])
        set(gcf,'color','w'); set(gca,'FontSize',10); set(gca,'linewidth',2);

        %Stiff Stiffness
        k_all_d_stiff = [40.9172820403504,58.5931893836053,76.3110167782409,95.2561113660114,117.227551724771,140.926495934271,172.057935272270,202.498940511661,243.951941750324,284.697703715067,314.497094506474];
        k_all_p_stiff = [7.45458898107429,10.7064268474889,13.7893994693623,17.0331649839024,20.4835526056582,24.7063819381083,29.6426849676964,35.0548546204595,41.2725661991959,47.2768945668147,51.7037078271082];
        subplot(1,2,2)
        hold on
        plot(tested_slider, k_all_d_stiff,'Color',[175, 175, 175]./255 ,'Linewidth',5)
        plot(tested_slider, k_all_p_stiff,'Color',[175, 175, 175]./255 ,'Linewidth',5,'HandleVisibility','off')
        plot(tested_slider, k_stiff_dorsi,'Color',[0.0863    0.3333    0.8118] ,'LineStyle','--', 'Linewidth',5)
        plot(tested_slider, k_stiff_plantar, 'Color',[0.0863    0.3333    0.8118] ,'LineStyle','--', 'Linewidth',5)
        xlabel('Slider Position (%)')
        %ylabel('Ankle Stiffness (Nm/rad)')
        legend('Model','Measured')
        legend boxoff
        ylim([0 340])
        set(gcf,'color','w'); set(gca,'FontSize',10); set(gca,'linewidth',2);

    end
end

figure(6)
perc = mm2perc(x_center_new*m2mm,x_center_max,x_center_min);
subplot(1,2,1)
hold on
x_spring_nominal = [0,10.01,19.97,29.97,39.95,49.95,59.97,70.07,80.04,90.01,96.98];
k_spring_nominal = [0.166318991334212,0.208391576135634,0.282351259287986,0.374190624007133,0.489817440908308,0.631742113520826,0.796116260994716,1.01916697238319,1.34705270360385,1.70337140522367,2.13270292544089];
titanium_nominal = polyfit(x_spring_nominal,k_spring_nominal,3);
plot(perc,flip(polyval(titanium_nominal,x_center_new*m2mm)),'Color', [0.7386, 0, 0]  , 'Linewidth',5)
ylabel('Beam Stiffness (kN/mm)')
xlabel('Slider Position (%)')
ylim([0 3.5])
set(gcf,'color','w'); set(gca,'FontSize',12); set(gca,'linewidth',2);

subplot(1,2,2)
hold on
x_spring_stiff = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
k_spring_stiff = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065];
titanium_stiff = polyfit(x_spring_stiff,k_spring_stiff,3);
plot(perc,polyval(titanium_stiff,x_center_new*m2mm),'Color', [0.0863    0.3333    0.8118] , 'Linewidth',5)
xlabel('Slider Position (%)')
ylim([0 3.5])
set(gcf,'color','w'); set(gca,'FontSize',12); set(gca,'linewidth',2);
    

%---------------------------------------------------------------
i_min = min(find(abs(Angles(:,1)-rad2deg(deg2rad(15.5)))<0.01));
k_min = Moments(i_min,1)./deg2rad(Angles(i_min,1));
i_max = min(find(abs(Angles(:,end)-rad2deg(deg2rad(15.5)))<0.01));
k_max = Moments(i_max,end)./deg2rad(Angles(i_max,end));
%-----------------------------
i_min_p = min(find(abs(Angles(:,1)-(-15.5))<0.01)); %
k_min_plantar = Moments(i_min_p,1)./deg2rad(Angles(i_min_p,1));
i_max_p = min(find(abs(Angles(:,end)-(-15.5))<0.01)); %15.5
k_max_plantar = abs(Moments(i_max_p,end))./(abs(deg2rad(Angles(i_max_p,end)-deg2rad(equilibrium_angle))));
performance = k_max/k_min;
filter1 = theta_new(i,:)>0;
filter2 = theta_new(i,:)<ROM_thresh;
filter12 = logical(filter1.*filter2);
specific_energy = cumtrapz(theta_new(i,filter12),M_ankle(i,filter12))/0.098;
























 %% Investigating unreasonable slope
TA_slope_orange_forward = dydx(M,theta_total);
TA_slope_orange_inverse = dydx(M_ankle(1,:),theta_new(1,:));
figure(16)
hold on
plot(rad2deg(theta_total),TA_slope_orange_forward)
plot(rad2deg(theta_new(1,:)),TA_slope_orange_inverse)







%% ------------------------------PLOTTING------------------------------------
figure(4)
hold on
for c = 1:length(delta(:,1))
    pplot(rad2deg(delta(c,:)),rad2deg(theta_cam(c,:)),'Device Angle (\circ)','Joint Angle (\circ)','',3)
    ROM = max(rad2deg(delta(c,:)))+max(rad2deg(theta_cam(c,:)))
end

%% PLOT SPRING DATA AND FITS

figure(3)
hold on
perc = mm2perc(x_spring_data,x_center_max,x_center_min);
plot(perc,k_spring_data./10^6)
x_titan = (x_center_max:-1:x_center_min);
k_titan = polyval(titanium_data,x_titan);
%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
plot(x_spring_data,k_spring_data,'Linewidth',5)
plot(x_titan,k_titan)
legend('Spring Data','Fit used in Code')
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',15); set(gca,'linewidth',2);


%% Collins and Plastic AFO

if(Collins)
    ROM_collins = [0 0.3]; %rad
    stiffness_collins = scale_Collins*[130 180 240 310 400]*ROM_collins(end); %Nm/rad 130 180 240 310 400
    colors = {[148,0,211]./255; [0,206,209]./255; [0,255,127]./255; [255,140,0]./255; [220,20,60]./255};
    figure(2)
    hold on
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(end)],'Color',colors{1},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(4)],'Color',colors{2},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(3)],'Color',colors{3},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(2)],'Color',colors{4},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equilibrium_angle, [0 stiffness_collins(1)],'Color',colors{5},'Linewidth',5)
       
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
    figure(2)
    hold on
    theta_yellow_measured = [-20.51 0 20.51];
    theta_gray_measured = [-17.24 0 17.24];
    moment_yellow_measured = [-40 0 40];
    moment_gray_measured = [-80 0 80];
    thetaD_tango(1,:) = linspace(0,20.51,100);
    thetaP_tango(1,:) = linspace(-20.51,0,100);
    thetaD_tango(2,:) = linspace(0,17.24,100);
    thetaP_tango(2,:) = linspace(-17.24,0,100);
    lever_arm_tango(1,:) = linspace(0.02066,0.02276,100);
    lever_arm_tango(2,:) = linspace(0.02066,0.0222,100);
    x_tango(1,:) = linspace(0,8,100)*mm2m; %yellow
    x_tango(2,:) = linspace(0,6.6,100)*mm2m; %gray
    k_tango = [223,452]./mm2m; %N/m
    phi_tango(1,:)  = linspace(4.72,25.23,100);
    phi_tango(2,:)  = linspace(4.72,21.96,100);
    for t=1:length(k_tango)
        if(t==1)
            color = [204,204,0]./255;
        else
            color = [224,224,224]./255;
        end
        force_spring_tango = k_tango(t).*x_tango(t,:);
        moment_tango = force_spring_tango.*cosd(phi_tango(t,:)).*lever_arm_tango(t,:);
        plot([thetaP_tango(t,:) thetaD_tango(t,:)]+equilibrium_angle,[-flip(moment_tango) moment_tango],'Color', color, 'Linewidth',4)
        stiffness_tango = moment_tango(end)/deg2rad(17.24)
    end
    %plot(theta_yellow_measured,moment_yellow_measured, 'Color', [255,255,102]./255, 'Linewidth',4)
    %plot(theta_gray_measured,moment_gray_measured, 'Color', [160,160,160]./255, 'Linewidth',4)
    %legend('Plastic Cam', 'Yellow Tango', 'Gray Tango')
    legend('VSO', 'Yellow Tango', 'Gray Tango')
    legend box off
end

%% PLOT PRIMARY CURVE SPLINE POINTS

figure(5); hold on
plot(rad2deg(theta_total),M,'k','Linewidth',1)
if(~dual_test)
plot(rad2deg(theta),M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
end
%plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[229,154,161]./255,'Linewidth',5)
xlabel('Angle (\circ)')
ylabel('Torque (Nm)')
title('Desired Torque-Angle Curve')
set(gcf,'color','w');
legend('Primary Curve','Spline Points','Able-Bodied')
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
hold off
%% Unscaled Primary Curve
if(primary_curve_notscaled)
    figure(7)
    hold on
    plot(rad2deg(theta_total),M/scalefactor,'Linewidth',5)
    if(dashed)
        xline(25,'--','linewidth',4)
        xline(-25,'--','linewidth',4)
    end
    set(gcf,'color','w');
    set(gca,'FontSize',20)
    set(gca,'linewidth',2)
    xlabel('Ankle Angle ({\circ})')
    ylabel('Ankle Torque (Nm)')
    if(zoom)
        axis([-19 19 -30 100])
    end
end

%% Plot Cam Forces

if(cam_forces)
    figure(5)
    hold on
    plot(x_center_new*1000,F_cam_3./1000,'--','Linewidth',5)
    xlabel('Slider Position [32.5-89mm]'); ylabel('Cam Force [kN]'); title('Cam Contact Force @'+string(rad2deg(ROM_thresh))+'deg Dorsiflexion');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
end
%% Plot Spring Displacement

if(cam_forces)
    %Change math to use difference in r value
%     figure
%     hold on
%     plot(x_center_new,s_lin,'Linewidth',5)
%     xlabel('Slider Position'); ylabel('Spring Vertical Displacement [mm]'); title('Spring Vertical Displacement at @30 deg');
%     set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
end
% 
%% PLOT THE SPRING DATA

if(springProperties)
    %PLOT FIBERGLASS SPRING DATA
    figure(6)
    hold on 
    plot(titan_percent,k_titan_percent,'Color','k','Linewidth',5)
    legend boxoff 
    xlabel('Spring Support Position [%]'); ylabel('Spring Stiffness [kN/mm]'); %title('Spring Stiffness');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    hold off
    
    figure(6)
    hold on
    plot(x_VSO_all,k_VSO_all./10^6,'Color','k','Linewidth',5)
    legend boxoff 
    xlabel('X Center [mm]'); ylabel('Spring Stiffness [kN/mm]'); title('Spring Stiffness');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    hold off
end


%% PLOT THE CAM PROFILES
%theta_query = [10 17.5 25 32.5 40];
theta_query = [];
query_indices = [];
for i=1:length(theta_query)
    query_index = find(abs(theta_new(1,:)-deg2rad(theta_query(i)))<deg2rad(0.02));
    query_indices = [query_indices;query_index(1)];
end

[x_circle y_circle] = plotCircle(r0,0, cam_radius);

figure(1); hold on;
plot(curve_x,curve_y,'k','LineStyle','-','Linewidth',5)%[0, 0.75, 0.75] [229,154,161]./255
%plot(x,y, 'Color',[229,154,161]./255 ,'LineStyle','--','Linewidth',2)%[0, 0.75, 0.75] [229,154,161]./255
plot(x_circle,y_circle)
plot(curve_x(query_indices),curve_y(query_indices),'x','Linewidth',5,'markers',15,'Color',[0 1 0])
axis equal
xlabel('(meters)'); ylabel('(meters)'); title('Cam Profile')
legend('Offset','Surface')
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',1);
%PLOT SOLIDWORKS CURVE
% hold on
% figure(22)
% plot(new_x,new_y)
% axis equal 
figure(2)
hold on
plot(rad2deg(theta_new(1,query_indices)),M_ankle(1,query_indices),'x','Linewidth',5,'markers',15,'Color',[0 1 0])



%% PLOT THE ENERGY STORAGE

if(energy_storage)
    %work_M
    Energy_PrimaryCurve = cumtrapz(theta_new(1,:),M_ankle(1,:));
    difference = max(work_M-Energy_PrimaryCurve)
    work_delta = 1/2.*kdelt.*delta(1,:).^2;
    spring_work = Energy_PrimaryCurve-work_delta;
    figure
    hold on
    %plot(rad2deg(theta_total), Energy_PrimaryCurve,'Linewidth',5)
    plot(rad2deg(theta_total), work_M,'Linewidth',5)
    %plot(rad2deg(theta_total),work_delta,'Linewidth',5)
    %plot(rad2deg(theta_total),spring_work,'Linewidth',5)
    legend('Energy Stored by Primary Curve','Energy Stored by Shell','Energy Stored in Spring')
    title('Energy Storage in VSO'); xlabel('Ankle Angle ({\circ})'); ylabel('Work (Joules)');
    legend boxoff
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
    hold off
end

%% PLOT CAM IMPORTED FROM TXT

if(different_cam)
    figure(1)
    hold on
    %plot(x_import,y_import,'Linewidth',1);
    plot(x_import_offset_back,y_import_offset_back,'Linewidth',1);
    legend('Original', 'Offset')
    axis equal
    hold off
end

%% PLOTS GENERATED AND IMPORTED CAM IN POLAR COORDINATES

if(camDisturbance)
    figure(64)
    polarplot(psi,r,'linewidth',3)
    hold on
    psi = acot(x./y);
    r = y./sin(psi);
    polarplot(psi,r,'linewidth',3)
    hold off
end



%% Automate Figure Placement

% figs =  findobj('type','figure');
% fig_autoplace(figs)


%% Message Box

if(camDisturbance==1 | different_cam==1)
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
            ["Torque at ROM_index: " + string(M_ankle(i,ROM_index(1)))],...
            ["Dorsi Stiffness [Nm/rad]: [" + string(k_min)+" | "+string(k_max)+']'],...
            ["Plantar Stiffness [Nm/rad]: [" + string(k_min_plantar)+" | "+string(k_max_plantar)+']'],...
            ["ROM [Dorsi, Plantar]: [" + string(dorsi_max)+","+string(plantar_max)+']']}; 
    msgbox(output,"Simulation Results");
end
%toc
%end

max(M_ankle(1,:))/max(theta_new(1,:))

%% Functions

function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end

function [x_circle y_circle] = plotCircle(h, k, r)
    % Generate values for theta
    theta = linspace(0, 2*pi, 100);
    % Parametric equations for the circle
    x_circle = h + r * cos(theta);
    y_circle = k + r * sin(theta);
end

function [curve_x curve_y] = offsetCamCurve(x,y,r,psi,cam_radius,dir,filter)
    if(filter)
            xprime = dydx(x,psi);
            yprime = dydx(y,psi);
        else
            xprime = diff(x)./diff(psi);
            xprime(end+1) = xprime(end);
            yprime = diff(y)./diff(psi);
            yprime(end+1) = yprime(end);
    end
    if(dir==1)
        curve_x = x + -cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
        curve_y = y + -cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);
    end
    if(dir==-1)
        %r = x./cos(psi);
        curve_x = x + cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
        curve_y = y + cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);
    end
end

function pplot(x,y,x_label,y_label,fig_title, line_width)
    plot(x,y,'Linewidth',line_width)
    xlabel(x_label)
    ylabel(y_label)
    title(fig_title)
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
end






