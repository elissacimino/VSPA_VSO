%% NEUROBIONICS LAB

% VSO Orthosis Cam Profile Derivation
% Nikko Van Crey | nikkovc@umich.edyu | 8479179990
clear
close all
close all hidden
addpath('IMPORTS')
addpath('TA')


%Which Dynamometer Test
children2 = 0; %Size 2 shoe
children5 = 1; %Size 5 shoe
childrenrigid = 0; %Metal Plate (No shoe)


%% DESIGN PARAMETERS
%MISC

ROM_thresh = deg2rad(15); %(deg) dorsiflexion angle that cam forces will be evaluated at
preload = 0.003; %(rad) Should be very small, the closer to 0 the better.
primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

%Geometric Parameters
y_center = 0.008;% (meters) Distance between top of simpgurele support (contact point under the spring) and cam roller axis
x_center_max = 89; %(mm) least stiff position in spring support stroke
x_center_min = 32.5; %(mm) most stiff position in spring support stroke
r0 = 0.03529; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)


%% CONFIGURABLES
camDisturbance = 0; %allows code to modify position/orientation of cam for debugging more characterization results
characterization_parameter_testing = 1; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
different_cam = 0; %allows testing cams from previously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_new in plot select, maybe change gamma==0 line for work calculation in inverse model
kdelt_nonlinear = 0; %series compliance can be a user-defined nonlinear function
%Cam (only choose one)
cam_children = 1;

  
%Spring (only choose one)
spring_children = 1;


%% PLOTTING OPTIONS
perc_max = 1;
primary_curve_notscaled = 0; %plots primary curve designed by hand with a scale factor of 1
primary_curve_scaled = 0; %plots scaled primary curve
HUMAN = 0;
Collins = 0;
scale_Collins = 0.6;
AFO = 0;
cam_forces = 0;
zoom  = 1; %zooms plot to a smaller angle range
dashed = 0; %adds vertical dashed lines to indicate 25 degrees
energy_storage = 0;
message_box = 1;

%plot all?
plot_all = 1; %perc_max is applied to this
num_points = 100;


%% IMPORT STUFF

%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking 
load('Human_ankle_moment')
load('IMPORTS/Human_ankle_rot')
%Import Plantarflexioin data from VSPA Prosthetic
load('IMPORTS/Primary_data.mat')
%Import TA for a Plastic AFO
load('IMPORTS/PlasticAFO')
load('IMPORTS/Conversions.mat')


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

if(children2+children5+childrenrigid>1)
    disp('Only choose 1 plotting method')
    return
end

%% INITIALIZE
F_cam = [];
F_cam_2 = [];
F_cam_3 = [];
s_lin = [];


%% TORQUE-ANGLE CURVES | SERIES COMPLIANCE | CAM ROLLER RADIUS

if(cam_children)
    kdelt = 250; %Series stiffness of frame
    cam_radius = 0.008; %(meters) %Cam roller radius
    scalefactor = 1;
    dorsi_max = 50; 
    plantar_max = -50; 
    %D:40, P:-40
    stiffness_dorsi = 70; %Nm/rad 
    stiffness_dorsi = stiffness_dorsi/rad2deg(1); %Nm/deg
    stiffness_leveling = 0.5*stiffness_dorsi;
    stiffness_plantar = 0.33*stiffness_dorsi;
    equalibrium_angle = 0; %Degrees 
    angle_leveling = 15+equalibrium_angle;
    pt_dorsi = 2;
    first_offset = 2;
    pt1_dorsi = equalibrium_angle+first_offset;
    dorsi_spacing = (angle_leveling-pt1_dorsi)/(pt_dorsi+1);
%     theta_deg = [plantar_max;-25;-8;equalibrium_angle;8;15;22.5;dorsi_max];
%     M_data = scalefactor*[-45;-35;-25;0;25;65;95;125];
    theta_plantar = [plantar_max;-30; -15; -7.5; -2];
    theta_dorsi = [equalibrium_angle; pt1_dorsi; dorsi_spacing+pt1_dorsi; 2*dorsi_spacing+pt1_dorsi; angle_leveling];
    level = (dorsi_max-angle_leveling)/4;
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar; theta_dorsi; theta_leveling];
    M_dorsi = (theta_dorsi-equalibrium_angle)*stiffness_dorsi;
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = [M_plantar; M_dorsi; M_level];
end


theta_total = deg2rad(plantar_max:0.005:dorsi_max);
theta = deg2rad(theta_deg);
M = interp1(theta, M_data, theta_total,'spline');


%% Checks to make sure slope of torque angle curve doesn't become negative
for p=2:length(M)
    if((M(p)-M(p-1))<=0)
        disp('Error: slope of TA curve is negative')
        error_angle = rad2deg(theta(p))
        return
    end
end


%% SPRING SELECTION

if(spring_children)
    %Simulated Data from Model
    x_spring_model = [89,80,70,60,50,40,32.5];
    k_spring_model = [152374.040172580,275323.661873207,539793.941634225,923726.560777320,1442862.19764685,2183387.52857618,3114158.96488139];
end

titanium_model = polyfit(x_spring_model,k_spring_model,3);
%titanium_data = polyfit(x_spring_data,k_spring_data,3);
x_spring_data = x_spring_model;
k_spring_data = k_spring_model;
titanium_data = titanium_model;


%% CAM GENERATION FROM FORWARD MODEL

stroke = x_center_max-x_center_min;
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = x_center*m2mm;

%Geometry need for Nikko math
mu = asin(x_off/r0); % mu = atan(x_off/y_off);
y_off = r0*cos(mu);
tau = atan(y_center/x_center);
epsilon = pi/2+mu;
zeta = -tau+pi-epsilon; %Angle in between line along length of r0 and L

%Additional Parameters
L = sqrt(x_center^2+y_center^2); %Length of spring
d = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center)^2); %This is the distance between virtual spring centers
%Both sigma calculations give same results
sigma = acos((r0^2-d^2-L^2)/(-2*d*L)); %angle between L and d
%sigma = atan(x_center/y_center)-atan(-x_center/(-r0-y_center)) %angle between L and d


%Calculate gamma as a function of theta, as needed for M.
work_M = cumtrapz(theta_total,M);
work_M = work_M - work_M(theta_total==deg2rad(equalibrium_angle));    %center it so int_M = 0 when theta = 0



%Series Compliance
if(kdelt_nonlinear)
%     kdelt_dorsi = 700;
%     kdelt_plantar = 300;
    kdelt_dorsi = 650; % measured on Ottobock Prototype and used for final cams
    kdelt_plantar = 350; % measured on Ottobock Prototype and used for final cams
%     kdelt_dorsi = 350; %used for feather cams
%     kdelt_plantar = 175; %used for feather cams
    kdelt = kdelt_dorsi*(theta_total>=0)+kdelt_plantar*~(theta_total>0);
end

%Spring Stiffnesses
k = polyval(titanium_data,primary_slider)*(x_center)^2 %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L
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


%USING MATH TO OFFSET
xprime = diff(x)./diff(psi);
    xprime(end+1) = xprime(end);
yprime = diff(y)./diff(psi);
    yprime(end+1) = yprime(end);
curve_x = x + -cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
curve_y = y + -cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);

%% REPORTS FAULTY CAM INDEXES TO THE COMMAND LINE
i=1;
bad = [];
 while i<length(curve_x)
        if isinf(curve_x(i)) == 1 || isnan(curve_y(i))
            bad = [bad;i]; 
            i
        end
        if isinf(curve_y(i)) == 1 || isnan(curve_y(i)) 
            bad = [bad;i]; 
            i
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

new_x = curve_x(2:10:length(curve_x));
new_y = interp1(curve_x,curve_y,new_x);
curve_points = 1000*[new_y', new_x', 0.*new_x'];
%curve_points = sortrows(curve_points, 2);
dlmwrite('cam_curve.txt', curve_points, '\t')   
dlmwrite('moment_profile.txt', M, '\t')




%% CAM CURVE SELF INTERSECTIONS?

intersections = [];
for i = 2:length(curve_y)
    if((curve_y(i)-curve_y(i-1))<0) 
        intersections = [intersections; [i rad2deg(theta_total(i)) curve_y(i)]];
    end
end
if(isempty(intersections)==0)
    disp('Error: intersections in cam')
    %return
end

 
%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE

if(different_cam)
    SolidworksImport = readtable('cam_feather_nonlin_0dot15.txt');
    %SolidworksImport = readtable('cam_3_final.txt');
    %SolidworksImport_Offset = readtable('CamTesting3.txt');
    x_import = table2array(SolidworksImport(:,2)).*0.001;
    y_import = table2array(SolidworksImport(:,1)).*0.001;
    x_import = smooth(x_import);
    y_import = smooth(y_import);
    [x_import_offset, y_import_offset] = offsetCurve(x_import,y_import,-cam_radius);
    
    %Invert to get (r,psi)
    psi = acot(x_import_offset./y_import_offset);
    r = y_import_offset./sin(psi);
    figure(15)
    polarplot(psi,r)
    hold on
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
    preload = 1.75*preload;
    if(children2)
        if(kdelt_nonlinear)
            kdelt_dorsi = 570;
            kdelt_plantar = 320;
            kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
        end
    end
    if(children5)
        if(kdelt_nonlinear)
            kdelt_dorsi = 644;
            kdelt_plantar = 440;
            kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
        end
    end
    if(childrenrigid)
        if(kdelt_nonlinear)
            kdelt_dorsi = 1000;
            kdelt_plantar = 300;
            kdelt = kdelt_dorsi*(theta_total>0)+kdelt_plantar*~(theta_total>0);
        end
    end
end


%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERSE MODEL)

%MATH BACKWARDS(Everything gets backed out by new geometry + psi and r from primary curve)

% x_center_new = [x_center_max,75,primary_slider,50,45,40,x_center_min];
% ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3)), polyval(titanium,x_center_new(4)),polyval(titanium,x_center_new(5)), polyval(titanium,x_center_new(6)), polyval(titanium,x_center_new(7))];
% x_center_new = x_center_new*mm2m;

if(children2 | childrenrigid)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0.01 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 perc_max]);
    ktranslational = polyval(titanium_data,x_center_new);
    x_center_new = x_center_new*mm2m;
end

if(children5)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 perc_max]);
    ktranslational = polyval(titanium_data,x_center_new);
    x_center_new = x_center_new*mm2m;
end

if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = [x_center_max:-(x_center_max-x_center_min)*perc_max/(num_points-1):(x_center_max-(x_center_max-x_center_min)*perc_max)];
    k_VSO_all = polyval(titanium_data,x_VSO_all);
    %x_center_new = x_VSO_all;
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end


vert_preload_inv = -x_center.*tan(preload); %This is the translational equivalent to the rotational preload
spring_preload_inv = atan(vert_preload_inv./-x_center_new);  %This allows the preload to update as the slider moves

figure(2); hold on

%% Preallocation
num_slider_positions = length(x_center_new);
theta_cam = NaN(num_slider_positions,length(r));
M_ankle = NaN(num_slider_positions,length(r));
delta = NaN(num_slider_positions,length(r));

%% Inverse Model
tic
for i = 1:length(x_center_new)
    tau = atan(y_center/x_center_new(i));
    zeta = -tau+pi-epsilon;
    L(i) = sqrt(x_center_new(i).^2+y_center^2); 
    d(i) = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center_new(i))^2); %This is the distance between virtual spring centers
    beta = atan((y_center+y_off)/(x_center_new(i)+x_off)); %This is the angle between horizontal and the line between spring centers
    omega = pi-beta-epsilon;
    sigma =zeta-omega; %This is the angle between virtual spring and line through spring centers

    %I need to reverse out gamma and delta from psi and r:
    omega_new = acos((L(i).^2 - r.^2 - d(i).^2)./(-2*r.*d(i))); %math in notebook (Law of Cosines)
    alpha_new = omega_new-omega;
    theta_cam(i,:) = alpha_new + psi; 
    gamma_new = acos((r.^2 - L(i)^2 - d(i)^2)./(-2*L(i)*d(i)))-sigma; %math in notebook (Just do r calculation in reverse)

    k(i) = ktranslational(i).*x_center_new(i)^2; %rotary stiffness
    %k(i) = ktranslational(i).*L(i)^2;
    M_spring = k(i)*(gamma_new + spring_preload_inv(i));

    work_spring = cumtrapz(gamma_new,M_spring);
    work_spring = work_spring - work_spring(gamma==0);


    %Differientiate to get ankle torque
    M_ankle(i,1:end-1) = diff(work_spring)./diff(theta_cam(i,:)); %diff takes differences change in Moment/change in theta_cam 
    M_ankle(i,end) = M_ankle(i,end-1); %diff() function decreases the length of the vector by one
    delta(i,:) = M_ankle(i,:)./kdelt;
    theta_new = theta_cam(i,:) + delta(i,:);
    Moments(:,i) = M_ankle(i,:);
    save('Cam_Moments', 'Moments');
    Angles(:,i) = rad2deg(theta_new);
    save('Cam_angles', 'Angles');
    if(abs((x_center_new(i)-mm2m*(stroke*primary_percentage+x_center_min)))<0.0002)
        i_primary = i;
    end
    v = plot(rad2deg(theta_new),M_ankle(i,:),'Linewidth',5);
    %v.Color = [224, 224, 224]./255; %shaded grey
    v.Color = [175, 175, 175]./255; %[96,96,96]/255
   
    %v.Color = [0, 192, 192]./255;
    %v.Color = [224, 224, 224]./255;
    %v.Color = [204, 153, 205]./255;

    %Cam Forces---------------------
    ROM_index = find(abs(theta_new-ROM_thresh)<deg2rad(0.02));
    if(cam_forces)
        F_cam = [F_cam M_spring(ROM_index(1))./L(i)];
        F_cam_2 = [F_cam_2 M_ankle(ROM_index(1))./r(ROM_index(1))];
        F_cam_3 = [F_cam_3 sqrt(F_cam(i).^2+F_cam_2(i).^2)];
    end
    
end
axis([-40,45,-50,100])
if(dashed)
    plot([-25 -25],[110 -50],'--k','Linewidth',2)
    plot([25 25],[110 -50],'--k','Linewidth',2)
end
 
%DASHED LINE
%     b = plot(radtodeg(theta_total),M);
%     b.LineWidth = 5; b.Color = [0,0,0]/255;
%figure(23); hold on
if(primary_curve_scaled)
    h = plot(Angles(:,i_primary),Moments(:,i_primary),'Linewidth',5);
    %h = plot(radtodeg(theta_total),M,'Linewidth',5);
    h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
end
%plot(radtodeg(theta),M,'Linewidth',2,'Color','k','LineStyle','--')
%scatter(radtodeg(theta),M)
% set(gcf,'color','w');
% set(gca,'FontSize',12)
% set(gca,'linewidth',2)
% xlabel('Ankle Angle ({\circ})')
% ylabel('Torque (Nm)')
if(zoom)
%     torque_axis = M_ankle(ROM_index(1))+20;
%     axis([-rad2deg(ROM_thresh)-5 rad2deg(ROM_thresh)+5 -0.33*torque_axis M_ankle(ROM_index(1))+20])
    %axis([-19 19 -20 100])
    axis([-25 25 -30 65])
end
%title('Expected Range of Stiffnesses Available')


%% Variable Stiffness Performance
k_all_d = [];
k_all_p = [];
for i = 1:length(Angles(1,:))
    i_all_d = min(find(abs(Angles(:,i)-15.5)<0.01));
    i_all_p = min(find(abs(Angles(:,i)-(-15.5))<0.01));
    k_all_d = [k_all_d Moments(i_all_d,i)./deg2rad(Angles(i_all_d,i))];
    k_all_p = [k_all_p abs(Moments(i_all_p,i))./(abs(deg2rad(Angles(i_all_p,i))))];
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
i_min = min(find(abs(Angles(:,1)-rad2deg(deg2rad(10)))<0.01));
k_min = Moments(i_min,1)./deg2rad(Angles(i_min,1));
i_max = min(find(abs(Angles(:,end)-rad2deg(deg2rad(10)))<0.01));
k_max = Moments(i_max,end)./deg2rad(Angles(i_max,end));
%-----------------------------
i_min_p = min(find(abs(Angles(:,1)-(-15))<0.01));
k_min_plantar = Moments(i_min_p,1)./deg2rad(Angles(i_min_p,1))
i_max_p = min(find(abs(Angles(:,end)-(-15))<0.01));
k_max_plantar = abs(Moments(i_max_p,end))./(abs(deg2rad(Angles(i_max_p,end)))+abs(deg2rad(equalibrium_angle)))
performance = k_max/k_min
filter1 = theta_new>0;
filter2 = theta_new<ROM_thresh;
filter12 = logical(filter1.*filter2);
specific_energy = cumtrapz(M_ankle(filter12),theta_new(filter12))/0.098;




%% ------------------------------PLOTTING------------------------------------

%% Plots for angle conversion

figure(8)
hold on
qPoints = [1 5 10]; %slider position as percent of total stroke
for q=1:length(qPoints)
    plot(rad2deg(theta_cam(qPoints(q),:)),rad2deg(delta(qPoints(q),:)))
end
legend(string(qPoints))
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',15); set(gca,'linewidth',2);
xlabel('Encoder Angle (\circ)')
ylabel('Compliance Angle (\circ)')

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
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(end)],'Color',colors{1},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(4)],'Color',colors{2},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(3)],'Color',colors{3},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(2)],'Color',colors{4},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(1)],'Color',colors{5},'Linewidth',5)
       
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

%% PLOT PRIMARY CURVE SPLINE POINTS

figure(5); hold on
plot(rad2deg(theta_total),M,'k','Linewidth',1)

plot(rad2deg(theta),M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])

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

figure(1); hold on;
plot(curve_x,curve_y,'k','LineStyle','-','Linewidth',4)%[0, 0.75, 0.75] [229,154,161]./255
plot(x,y, 'Color',[229,154,161]./255 ,'LineStyle','--','Linewidth',5)%[0, 0.75, 0.75] [229,154,161]./255
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


%% PLOT THE ENERGY STORAGE

if(energy_storage)
    spring_work = work_M-work_delta;
    figure
    hold on
    plot(rad2deg(theta_total), work_M,'Linewidth',5)
    plot(rad2deg(theta_total),work_delta,'Linewidth',5)
    plot(rad2deg(theta_total),spring_work,'Linewidth',5)
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
    plot(x_import,y_import,'Linewidth',1);
    plot(x_import_offset,y_import_offset,'Linewidth',1);
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

figs =  findobj('type','figure');
fig_autoplace(figs)


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
            ["Torque at ROM_index: " + string(M_ankle(ROM_index(1)))],...
            ["Dorsi Stiffness [Nm/rad]: [" + string(k_min)+" | "+string(k_max)+']'],...
            ["Plantar Stiffness [Nm/rad]: [" + string(k_min_plantar)+" | "+string(k_max_plantar)+']'],...
            ["ROM [Dorsi, Plantar]: [" + string(dorsi_max)+","+string(plantar_max)+']']}; 
    msgbox(output,"Simulation Results");
end

%% Functions

function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end





