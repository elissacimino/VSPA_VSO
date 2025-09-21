% VSO Orthosis Cam Profile Derivation
% Nikko Van Crey
%nikkovc@umich.edyu
%8479179990
% Neurobionics Lab
clear
close all
%close all hidden
camDisturbance = 0;
characterization_parameter_testing = 1;
different_cam = 0; %txt for cam, y_center for cam, scaling and shape of cam, x_center_new in plot select, maybe change gamma==0 line for work calculation in inverse model
kdelt_nonlinear = 1;


%Cam (only choose one)
cam_lin = 0; %linear dorsi and plantar
cam_nonlin = 1;
cam_feather = 0;
cam_children = 0;
  
%Spring (only choose one)
spring_stiff = 1;
spring_soft = 0;
spring_soft_short = 0;


%% To Do

%% Plotting Options
primary_curve_notscaled = 0; %plots primary curve designed by hand with a scale factor of 1
primary_curve_scaled = 0; %plots scaled primary curve
HUMAN = 0;
Collins = 0;
AFO = 0;
cam_forces = 1;
zoom  = 1; %zooms plot to a smaller angle range
dashed = 0; %adds vertical dashed lines to indicate 25 degrees
energy_storage = 1;
message_box = 1;

%(only choose one)
plot_all = 0;
plot_one = 0;
plot_select = 1;
plot_tested = 0;


%% Incompatibilities
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



%% Checking to configurables for user error
if((cam_lin+cam_nonlin+cam_children)>1)
    disp('Only choose 1 cam')
    return
end
if(spring_stiff && spring_soft)
    disp('Only choose 1 spring')
    return
end

if(plot_all+plot_one+plot_select+plot_tested>1)
    disp('Only choose 1 plotting method')
    return
end

%% Design Parameters
%MISC
preload = 0.003; %(rad) Should be very small, the closer to 0 the better.
primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

%Geometric Parameters
y_center = 0.008;% (meters) Distance between top of simple support (contact point under the spring) and cam roller axis
x_center_max = 89; %(mm) least stiff position in spring support stroke
x_center_min = 32.5; %(mm) most stiff position in spring support stroke
r0 = 0.03529; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)

if(cam_lin)
    kdelt = 1600; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius_VSO = 0.0095; %(meters) %Cam roller radius
end

if(cam_nonlin) %cam4_5_6
    kdelt = 1200; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius_VSO = 0.0095; %(meters) %Cam roller radius
end

if(cam_feather)
    kdelt = 800; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius_VSO = 0.008; %(meters) %Cam roller radius
    %cam_radius_VSO = 0.0095; %(meters) %Cam roller radius
    different_cam = 0;
end


%% TA Curve Design Parameters
weight = 70; %kg


%% Load Data
%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking 
load('Human_ankle_moment')
load('Human_ankle_rot')
%Import Plantarflexioin data from VSPA Prosthetic
load('Primary_data.mat')
%Import Spring Data
load('leafspring_fit.mat') %Fiberglass Translational Data
%Import TA for a Plastic AFO
load('PlasticAFO')
load('Conversions.mat')
load('titanium_Max') %Titanium Translational Data
%Red VSPA
primary_span_fiber = 0:100/103:100;
k_lin_fib = 10^6*transpose(fiberglass(primary_span_fiber));
x_iter_fiberglass = (102.03:-(102.03-5.6)/(length(primary_span_fiber)-1):5.6)*.001;
%Blue VSPA
k_Blue_VSPA = titanium_Max(20:1:70)./10^6;
x_Blue_VSPA = 0:100/(length(k_Blue_VSPA)-1):100;

%% Nikko's Titanium Spring
if(spring_stiff)
    %Experimental Data from Instron
    x_spring = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
    k_spring = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
    figure(81)
    hold on
    perc = mm2perc(x_spring,x_center_max,x_center_min);
    plot(perc,k_spring./10^6)
end


if(spring_soft)
    x_spring = [89,80,70,60,50,40,32.5];
    k_spring = [0.2213,0.3100,0.4641,0.6876,1.0342,1.5851,2.3175]*10^6;
end

if(spring_soft_short)
    x_spring = [89,80,70,60,50,40,32.5];
    k_spring = [152374.040172580,275323.661873207,539793.941634225,923726.560777320,1442862.19764685,2183387.52857618,3114158.96488139];
end

titanium = polyfit(x_spring,k_spring,3);
x_titan = (x_center_max:-1:x_center_min);
k_titan = polyval(titanium,x_titan);
%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
% figure
% hold on
% plot(x_spring,k_spring,'Linewidth',5)
% plot(x_titan,k_titan)
% legend('FEA','Fit')

%% Design TA Curves

%Primary Curve

if(cam_nonlin)
    ROM_thresh = deg2rad(18); %(deg) dorsiflexion angle that cam forces will be evaluated at
    scalefactor = 0.24; %0.32 stiffest 0.24 middle 0.16 softest
    torque_max = 160;
    dorsi_max = 50; 
    plantar_max = -65; 
    equalibrium_angle = 0; %Degrees
    angle_leveling = 30+equalibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/4;
    %------------------------
    stiffness_dorsi_lin = 275/rad2deg(1); %Nm/deg
    stiffness_dorsi = 1.75*stiffness_dorsi_lin; %Nm/rad
    stiffness_plantar = 0.33*1.75*stiffness_dorsi_lin; %Nm/deg

    %--------------------------------
    theta_plantar = [plantar_max;-30; -15; -7.5; -2];
    theta_dorsi = [10; 16; angle_leveling];
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar;equalibrium_angle;theta_dorsi;theta_leveling];
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_dorsi_1 = (theta_dorsi(1)-equalibrium_angle)*stiffness_dorsi;
    M_dorsi = [M_dorsi_1; (theta_dorsi(2)-theta_dorsi(1))*stiffness_dorsi_lin+M_dorsi_1; 135];
    stiffness_leveling = (torque_max-M_dorsi(end))/(dorsi_max-theta_dorsi(end));
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar;0;M_dorsi;M_level];
end

if(cam_lin)
    ROM_thresh = deg2rad(18); %(deg) dorsiflexion angle that cam forces will be evaluated at
    scalefactor = 0.35; %0.35 0.5 0.65
    dorsi_max = 50; 
    plantar_max = -50; 
    %D:40, P:-40
    stiffness_dorsi = 275; %Nm/rad 
    stiffness_dorsi = stiffness_dorsi/rad2deg(1); %Nm/deg
    stiffness_leveling = 0.5*stiffness_dorsi;
    stiffness_plantar = 0.33*stiffness_dorsi;
    equalibrium_angle = 2; %Degrees 
    angle_leveling = 25+equalibrium_angle;
    pt_dorsi = 2;
    first_offset = 2;
    pt1_dorsi = equalibrium_angle+first_offset;
    dorsi_spacing = (angle_leveling-pt1_dorsi)/(pt_dorsi+1);
    theta_plantar = [plantar_max;-30; -15; -7.5; 0];
    theta_dorsi = [equalibrium_angle; pt1_dorsi; dorsi_spacing+pt1_dorsi; 2*dorsi_spacing+pt1_dorsi; angle_leveling];
    level = (dorsi_max-angle_leveling)/4;
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar; theta_dorsi; theta_leveling];
    M_dorsi = (theta_dorsi-equalibrium_angle)*stiffness_dorsi;
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = scalefactor*[M_plantar; M_dorsi; M_level];
end


theta_interp = deg2rad(plantar_max:0.005:dorsi_max);
theta = deg2rad(theta_deg);
M = interp1(theta, M_data, theta_interp,'spline');

%Plot moment profile
AbleBodiedAnkleMoment=xlsread('Data from Bovi.xls','Joint Moments','AN407:AN470');%AQ507');
AbleBodiedAnkleMoment = weight*AbleBodiedAnkleMoment;
AbleBodiedAnkleAngle = xlsread('Data from Bovi.xls','Joint Rotations','AN710:AN773');%:AQ810');
AbleBodiedAnkleAngle=AbleBodiedAnkleAngle+22.5;
figure(1); hold on
%plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[229,154,161]./255,'Linewidth',5)
plot(rad2deg(theta_interp),M,'k','Linewidth',1)
plot(rad2deg(theta),M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
xlabel('Angle (deg)')
ylabel('Torque (Nm)')
title('Desired Torque-Angle Curve')
set(gcf,'color','w');
legend('Able-Bodied','Primary Curve','Spline Points','Data Considered')
legend boxoff
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
hold off



%% Forward Model
stroke = x_center_max-x_center_min;
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m; %Distance between cam roller axis and simple support axis. This is the "primary slider position" (primary_slider-47)*mm2m
primary_slider = x_center*m2mm;

mu = asin(x_off/r0); % mu = atan(x_off/y_off);
y_off = r0*cos(mu);
tau = atan(y_center/x_center);
epsilon = pi/2+mu;
zeta = -tau+pi-epsilon; %Angle in between line along length of r0 and L

%Additional Parameters
L = sqrt(x_center^2+y_center^2); %Length of spring
d = sqrt((cos(mu)*r0+y_center)^2+(sin(mu)*r0+x_center)^2); %This is the distance between virtual spring centers
sigma = acos((r0^2-d^2-L^2)/(-2*d*L)); %This is the angle between virtual spring and line through spring centers


%Calculate gamma as a function of theta, as needed for M.
work_M = cumtrapz(theta_interp,M);
deg2rad(equalibrium_angle)
work_M = work_M - work_M(theta_interp==deg2rad(equalibrium_angle));    %center it so int_M = 0 when theta = 0

%Series Compliance
if(kdelt_nonlinear)
    kdelt_dorsi = 1450; %1450 used for ramtech cams 4, 5, and 6
    kdelt_plantar = 120; %120 used for ramtech cams 4, 5, and 6
    kdelt = kdelt_dorsi*(theta_interp>0)+kdelt_plantar*~(theta_interp>0);
end
delta = M./kdelt; %Amount of deflection of the series compliance
work_delta = 1/2.*kdelt.*delta.^2; %Mechanical energy stored in the series compliance
theta_cam = theta_interp-delta;

beta = atan((y_center+y_off)/(x_center+x_off)); %This is the angle between horizontal and the line between spring centers
omega = pi-beta-epsilon;

%Spring Stiffnesses
k = polyval(titanium,primary_slider)*(x_center)^2 %VSO  %(Nm/rad) The rotary spring stiffness with the simple support at L
k_VSPA = 0.5*10^6*0.0607^2;
%k_series_linear = 1200./((0.03241)^2);
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
psi = theta_cam-alpha; %This is the polar coordinate, with r, of the cam.  ie, the angle between the 'cam vertical' and r


y = r.*sin(psi);
x = r.*cos(psi);

%USING MATH TO OFFSET
xprime = diff(x)./diff(psi);
    xprime(end+1) = xprime(end);
yprime = diff(y)./diff(psi);
    yprime(end+1) = yprime(end);
curve_x = x + -cam_radius_VSO.*yprime./sqrt(xprime.^2 + yprime.^2);
curve_y = y + -cam_radius_VSO.*-xprime./sqrt(xprime.^2 + yprime.^2);


%Checking for garbage in the cam profile (will just remove the array elements)
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
curve_x(bad) = [];
curve_y(bad) = [];

% Export to Solidworks
new_x = curve_x(2:10:length(curve_x));
new_y = interp1(curve_x,curve_y,new_x);
curve_points = 1000*[new_y', new_x', 0.*new_x'];
%curve_points = sortrows(curve_points, 2);
dlmwrite('cam_curve.txt', curve_points, '\t')   
dlmwrite('moment_profile.txt', M, '\t')

%% Check to see if cam curve intersects itself
intersections = [];
for i = 2:length(curve_y)
    if((curve_y(i)-curve_y(i-1))<0) 
        intersections = [intersections; curve_y(i)];
    end
end
intersections

%% Doing weird cam stuff
if(different_cam)
    SolidworksImport = readtable('cam_3_final.txt');
    %SolidworksImport_Offset = readtable('CamTesting3.txt');
    x_import = table2array(SolidworksImport(:,2)).*0.001;
    y_import = table2array(SolidworksImport(:,1)).*0.001;
    x_import = smooth(x_import);
    y_import = smooth(y_import);
    [x_import_offset, y_import_offset] = offsetCurve(x_import,y_import,-0.0095);
    
    figure(8)
    hold on
    plot(x_import,y_import,'Linewidth',1);
    plot(x_import_offset,y_import_offset,'Linewidth',1);
    legend('Original', 'Offset')
    axis equal
    hold off
    %Invert to get (r,psi)
    psi = acot(x_import_offset./y_import_offset);
    r = y_import_offset./sin(psi);
    figure(79)
    polarplot(psi,r)
    hold on
    hold off
end

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
    figure(64)
    polarplot(psi,r,'linewidth',3)
    hold on
    psi = acot(x./y);
    r = y./sin(psi);
    polarplot(psi,r,'linewidth',3)
    hold off
    
end

if(characterization_parameter_testing)
    %Preload
    preload = 0.0000001*preload;
    %Series Compliance
    if(kdelt_nonlinear)
        kdelt_dorsi = 450; %1450 used for ramtech cams 4, 5, and 6
        kdelt_plantar = 200; %120 used for ramtech cams 4, 5, and 6
        kdelt = kdelt_dorsi*(theta_interp>0)+kdelt_plantar*~(theta_interp>0);
    end
end


%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERT THE BIRD)
F_cam = [];
F_cam_2 = [];
F_cam_3 = [];
s_lin = [];

%VSPA BACKWARDS(Everything gets backed out by new geometry + psi and r from primary curve)
vert_preload_init = -x_center.*tan(preload); %This is the translational equivalent to the rotational preload

x_center_new = [x_center_max,75,primary_slider,50,45,40,x_center_min];
ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3)), polyval(titanium,x_center_new(4)),polyval(titanium,x_center_new(5)), polyval(titanium,x_center_new(6)), polyval(titanium,x_center_new(7))];
x_center_new = x_center_new*mm2m;
if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    x_VSO_all = [x_center_max:-0.5:x_center_min];
    k_VSO_all = polyval(titanium,x_VSO_all);
    %x_center_new = x_VSO_all;
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end

if(plot_one)
    x_center_new = [primary_slider]*mm2m;
    ktranslational = [polyval(titanium,primary_slider)];

end

if(plot_select)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.5 0.90]);
    ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3))];
    x_center_new = x_center_new*mm2m;
end

preload_new = atan(vert_preload_init./-x_center_new);  %This allows the preload to update as the slider moves

figure(2); hold on
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
    theta_cam = alpha_new + psi; 
    gamma_new = acos((r.^2 - L(i)^2 - d(i)^2)./(-2*L(i)*d(i)))-sigma; %math in notebook (Just do r calculation in reverse)

    k(i) = ktranslational(i).*x_center_new(i)^2;
    %k(i) = ktranslational(i).*L(i)^2;
    M_spring = k(i)*(gamma_new + preload_new(i));

    work_spring = cumtrapz(gamma_new,M_spring);
    work_spring = work_spring - work_spring(gamma==0);
    %work_spring = work_spring; %this is just used for cam import to prevent errors

    %Differientiate to get ankle torque
    M_ankle = diff(work_spring)./diff(theta_cam); %diff takes differences change in Moment/change in theta_cam 
    M_ankle(end+1) = M_ankle(end); %diff() function decreases the length of the vector by one
    delta = M_ankle./kdelt;
    theta_new = theta_cam + delta;
    Moments(:,i) = M_ankle;
    Angles(:,i) = rad2deg(theta_new);
    
    v = plot(rad2deg(theta_new),M_ankle,'Linewidth',5);
   
    %v.Color = [0, 192, 192]./255;
    v.Color = [224, 224, 224]./255;
    %v.Color = [204, 153, 205]./255;

    %Cam Forces---------------------
    if(cam_forces)
        ROM_index = find(abs(theta_new-ROM_thresh)<deg2rad(0.01));
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
%     b = plot(radtodeg(theta_interp),M);
%     b.LineWidth = 5; b.Color = [0,0,0]/255;
%figure(23); hold on
if(primary_curve_scaled)
    h = plot(radtodeg(theta_interp),M,'Linewidth',5);
    h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
end
%plot(radtodeg(theta),M,'Linewidth',2,'Color','k','LineStyle','--')
%scatter(radtodeg(theta),M)
set(gcf,'color','w');
set(gca,'FontSize',20)
set(gca,'linewidth',2)
xlabel('Ankle Angle ({\circ})')
ylabel('Ankle Torque (Nm)')
if(zoom)
    torque_axis = M_ankle(ROM_index(1))+20;
    axis([-rad2deg(ROM_thresh)-5 rad2deg(ROM_thresh)+5 -0.33*torque_axis M_ankle(ROM_index(1))+20])
end
%title('Expected Range of Stiffnesses Available')

%% Collins and Plastic AFO
if(Collins)
    ROM_collins = [0 0.3]; %rad
    stiffness_collins = 0.6*[130 180 240 310 400]*ROM_collins(end); %Nm/rad 130 180 240 310 400
    colors = {[148,0,211]./255; [0,206,209]./255; [0,255,127]./255; [255,140,0]./255; [220,20,60]./255};
    %colors = [[];
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(end)],'Color',colors{1},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(4)],'Color',colors{2},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(3)],'Color',colors{3},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(2)],'Color',colors{4},'Linewidth',5)
    plot(rad2deg(ROM_collins)+equalibrium_angle, [0 stiffness_collins(1)],'Color',colors{5},'Linewidth',5)
       
end
if(AFO)
    plot(PlasticAFO(:,1),PlasticAFO(:,1),'Color',[0,0,0]./255,'Linewidth',5)
end
if(primary_curve_notscaled)
    plot(rad2deg(theta_interp),M/scalefactor,'k','Linewidth',5)
end
if(HUMAN)
    plot(AbleBodiedAnkleAngle,AbleBodiedAnkleMoment, 'Color',[32,178,170]./255,'Linewidth',5)
end

%% Unscaled Primary Curve
figure(3)
hold on
plot(rad2deg(theta_interp),M/scalefactor,'Linewidth',5)
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
    axis([-40 40 -75 180])
end
%% Plot Cam Forces
if(cam_forces)
    figure(4)
    hold on
    %plot(x_center_new,F_cam./1000,'Linewidth',5)
    %plot(x_center_new,F_cam_2./1000,'--','Linewidth',5)
    %plot(mm2perc(x_center_new*1000,x_center_max,x_center_min),F_cam_3./1000,'--','Linewidth',5)
    plot(x_center_new*1000,F_cam_3./1000,'--','Linewidth',5)
%     xlabel('Slider Position [0-100%]'); ylabel('Cam Force [kN]'); title('Cam Contact Force @'+string(rad2deg(ROM_thresh))+'deg Dorsiflexion and '+string(M_ankle(ROM_index(1)))+' Nm');
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

%% Variable Stiffness Performance
i_min = min(find(abs(Angles(:,1)-rad2deg(deg2rad(10)))<0.01));
k_min = Moments(i_min,1)./deg2rad(Angles(i_min,1));
i_max = min(find(abs(Angles(:,end)-rad2deg(deg2rad(10)))<0.01));
k_max = Moments(i_max,end)./deg2rad(Angles(i_max,end));
%-----------------------------
i_min_p = min(find(abs(Angles(:,1)-(-15))<0.01));
k_min_plantar = Moments(i_min_p,1)./deg2rad(Angles(i_min_p,1))
i_max_p = min(find(abs(Angles(:,end)-(-15))<0.01));
k_max_plantar = abs(Moments(i_max_p,end))./(abs(deg2rad(Angles(i_max_p,end)))+abs(deg2rad(equalibrium_angle)))
performance = k_max/k_min;
%% PLOT THE SPRING DATA
if(springProperties)
    %PLOT FIBERGLASS SPRING DATA
    figure
    hold on 
    %plot(primary_span_fiber, k_lin_fib/10^6,'Color',[229,154,161]./255,'markersize',10,'Linewidth',5)
    %plot(x_Blue_VSPA, k_Blue_VSPA,'Color',[0, 0.75, 0.75],'markersize',10,'Linewidth',2)
    plot(titan_percent,k_titan_percent,'Color','k','Linewidth',5)
    %legend('Red VSPA','Blue VSPA','VSO')
    legend boxoff 
    xlabel('Spring Support Position [%]'); ylabel('Spring Stiffness [kN/mm]'); %title('Spring Stiffness');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    %axis([0,100,0,2.9])
    hold off
    
    figure
    hold on
    plot(x_VSO_all,k_VSO_all./10^6,'Color','k','Linewidth',5)
    %legend('Red VSPA','Blue VSPA','VSO')
    legend boxoff 
    xlabel('X Center [mm]'); ylabel('Spring Stiffness [kN/mm]'); title('Spring Stiffness');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    %axis([0,100,0,2.9])
    hold off
end


%% PLOT THE CAM PROFILES
figure(8); hold on;
plot(curve_x,curve_y,'LineStyle','-','Linewidth',5)%[0, 0.75, 0.75] [229,154,161]./255
plot(x,y, 'Color',[229,154,161]./255 ,'LineStyle','--','Linewidth',5)%[0, 0.75, 0.75] [229,154,161]./255
%'Color',[229,154,161]./255 
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
    plot(rad2deg(theta_interp), work_M,'Linewidth',5)
    plot(rad2deg(theta_interp),work_delta,'Linewidth',5)
    plot(rad2deg(theta_interp),spring_work,'Linewidth',5)
    legend('Energy Stored by Primary Curve','Energy Stored by Shell','Energy Stored in Spring')
    title('Energy Storage in VSO'); xlabel('Ankle Angle ({\circ})'); ylabel('Work (Joules)');
    legend boxoff
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
    hold off
end

%% Automate Figure Placement
figs =  findobj('type','figure');
num_fig = length(figs);
num_cols =  4;
num_rows = 2;
screen_size  = get(0,'screensize');
task_bar = screen_size(3)/35;
pc_width  = 0.7*(screen_size(3)-task_bar);
pc_height = screen_size(4);
width = pc_width/num_cols;
height = 0.60*pc_height/num_rows;
buffer = 85;
x = 0;
y = 0;
for f=1:num_fig
    h = figure(f);
    if(x<=((num_cols-1)/num_cols)*pc_width)
        set_fig_position(h,y,x,height,width)

    else
        x = 0;
        y = y+height+buffer;
        set_fig_position(h,y,x,height,width)
    end
    x = x+width; 
end

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
            ["Highest Dorsi Stiffness [Nm/rad]: " + string(string(k_max))],...
            ["Lowest Dorsi Stiffness [Nm/rad]: " + string(string(k_min))],...
            ["Highest Plantar Stiffness [Nm/rad]: " + string(string(k_max_plantar))],...
            ["Lowest Plantar Stiffness [Nm/rad]: " + string(string(k_min_plantar))],...
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





