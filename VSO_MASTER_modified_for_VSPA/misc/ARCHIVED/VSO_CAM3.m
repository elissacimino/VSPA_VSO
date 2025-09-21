% VSO Orthosis Cam Profile Derivation
% Nikko Van Crey
%nikkovc@umich.edyu
%8479179990
% Neurobionics Lab
clear
close all
close all hidden
%remember: uncomment line with gamma = 0;
camDisturbance = 0;
different_cam = 1; %txt for cam, y_center for cam, scaling and shape of cam, x_center_new in plot select
kdelt_nonlinear = 1;


%Cam (only choose one)
cam_lin = 1; %linear dorsi and plantar
cam_nonlin = 0;
cam_children = 0;

%Spring (only choose one)
spring_1 = 0;
spring_char = 0;
spring_scaled = 0;
spring_stiff = 1;


%% Design Parameters
%MISC
preload = 0.003; %(rad) Should be very small, the closer to 0 the better.
primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

%Geometric Parameters
%y_center = 0.0432896;% (meters) Distance between top of simple support (contact point under the spring) and cam roller axis
y_center = 0.008;
x_center_max = 88; %(mm) least stiff position in spring support stroke
x_center_min = 32.5; %(mm) most stiff position in spring support stroke
r0 = 0.03529; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)

if(cam_lin | cam_nonlin)
    kdelt = 600; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius_VSO = 0.0095; %(meters) %Cam roller radius
end

if(cam_children)
    kdelt = 800; %(600 used for cam first round of RAMTECH cams) Series stiffness of frame
    cam_radius_VSO = 0.008; %(meters) %Cam roller radius
    different_cam = 0;
    scalefactor = 1;
end



%% TA Curve Design Parameters
weight = 70; %kg

%% Binary Configurables
%Plots
fullscale = 0;
HUMAN = 0;
Collins = 0;
AFO = 0;
plot_all = 0;
perc_max = 0.96;
plot_one = 0;
plot_select = 0;
plot_tested = 1;
plot_primary_original = 0;
primary_curve_scaled = 0;
zoom  = 1;
dashed = 0;
cam_forces = 0;
%-------------
energy_surface = 0;
energy_storage = 0;
if(plot_all)
    springProperties = 1;
else
    springProperties = 0;
end


%% Load Data
%Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking
addpath('IMPORTS')
addpath('TA')
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
%x = 81:31;
% x_FEA = [89.29 79.29 69.29 59.29 49.29 39.29 32.41];
% k_FEA = [0.477859 0.698487 0.994695 1.39147 1.96207 2.95858 3.99255]*10^6;
% x_FEA = [87.9072 80 70 60 50 40 30.5189];
% k_FEA = [0.675676 0.904977 1.2791 1.77809 2.46488 3.58809 5.62746]*10^6;

if(spring_1)
    x_FEA = [87.9 80 60 40 30.52];
    k_FEA = [0.614251 0.82713 1.67 3.42818 5.39665]*10^6;
end
if(spring_char)
    x_FEA = flip([36.2580000000000,41.9960000000000,47.7340000000000,53.4720000000000,59.2100000000000,64.9480000000000,70.6860000000000,76.4240000000000,82.1620000000000]);
    k_FEA = [0.443826588865024,0.611273290728075,0.757129333024286,0.930957223464641,1.15043979725188,1.41631937733133,1.71851789445342,2.07763675650213,2.53943564317320]*10^6;
end
if(spring_scaled)
    x_FEA = flip([36.2580000000000,41.9960000000000,47.7340000000000,53.4720000000000,59.2100000000000,64.9480000000000,70.6860000000000,76.4240000000000,82.1620000000000]);
    k_FEA = [0.432465001702156,0.616126941919261,0.792258272479587,1.01274888074353,1.30070171341660,1.66157226218556,2.08664716371367,2.60261456478173,3.26999324785601]*10^6;
%     x_FEA = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
%     k_FEA = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
end

if(spring_stiff)
    %Experimental Data from Instron
    x_FEA = perc2mm([10,20,30,40,50,60,70,80,90],x_center_max,x_center_min);
    k_FEA = [0.504056504259215,0.643677301429046,0.832299197785623,1.05064584357359,1.32634309455410,1.66559355728660,2.08770991622833,2.63292510121457,3.32380116959065]*10^6;
end


titanium = polyfit(x_FEA,k_FEA,3);
x_titan = (x_center_max:-1:x_center_min);
k_titan = polyval(titanium,x_titan);
%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;
% figure
% hold on
% plot(x_FEA,k_FEA,'Linewidth',5)
% plot(x_titan,k_titan)
% legend('FEA','Fit')

%% Design TA Curves

%Primary Curve

if(cam_nonlin)
    ROM_thresh = deg2rad(18); %(deg) dorsiflexion angle that cam forces will be evaluated at
    scalefactor = 0.32;
    torque_max = 160;
    dorsi_max = 50; 
    plantar_max = -40; 
    equalibrium_angle = 2; %Degrees
    angle_leveling = 30+equalibrium_angle; %Degrees
    level = (dorsi_max-angle_leveling)/4;
    %------------------------
    stiffness_dorsi_lin = 275/rad2deg(1); %Nm/deg
    stiffness_dorsi = 2*stiffness_dorsi_lin; %Nm/rad
    stiffness_plantar = 0.33*stiffness_dorsi_lin; %Nm/deg

    %--------------------------------
    theta_plantar = [plantar_max;-30; -15; -7.5; 0];
    theta_dorsi = [10; 18; angle_leveling];
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
    dorsi_max = 40; 
    plantar_max = -40; 
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
%     theta_deg = [plantar_max;-25;-8;equalibrium_angle;8;15;22.5;dorsi_max];
%     M_data = scalefactor*[-45;-35;-25;0;25;65;95;125];
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

if(cam_children)
    ROM_thresh = deg2rad(15); %(deg) dorsiflexion angle that cam forces will be evaluated at
    dorsi_max = 40; 
    plantar_max = -40; 
    %D:40, P:-40
    stiffness_dorsi = 60; %Nm/rad 
    stiffness_dorsi = stiffness_dorsi/rad2deg(1); %Nm/deg
    stiffness_leveling = 0.5*stiffness_dorsi;
    stiffness_plantar = 0.33*stiffness_dorsi;
    equalibrium_angle = 2; %Degrees 
    angle_leveling = 25+equalibrium_angle;
    pt_dorsi = 2;
    first_offset = 2;
    pt1_dorsi = equalibrium_angle+first_offset;
    dorsi_spacing = (angle_leveling-pt1_dorsi)/(pt_dorsi+1);
%     theta_deg = [plantar_max;-25;-8;equalibrium_angle;8;15;22.5;dorsi_max];
%     M_data = scalefactor*[-45;-35;-25;0;25;65;95;125];
    theta_plantar = [plantar_max;-30; -15; -7.5; 0];
    theta_dorsi = [equalibrium_angle; pt1_dorsi; dorsi_spacing+pt1_dorsi; 2*dorsi_spacing+pt1_dorsi; angle_leveling];
    level = (dorsi_max-angle_leveling)/4;
    theta_leveling = [angle_leveling+level; angle_leveling+2*level; angle_leveling+3*level; dorsi_max];
    theta_deg = [theta_plantar; theta_dorsi; theta_leveling];
    M_dorsi = (theta_dorsi-equalibrium_angle)*stiffness_dorsi;
    M_plantar = (theta_plantar-equalibrium_angle)*stiffness_plantar;
    M_level = (theta_leveling-theta_dorsi(end))*stiffness_leveling+M_dorsi(end);
    M_data = [M_plantar; M_dorsi; M_level];
end


theta_interp_plantar = deg2rad(plantar_max:0.005:0);
theta_interp_dorsi = deg2rad(0:0.005:dorsi_max);
theta_interp = [theta_interp_plantar theta_interp_dorsi];
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
work_M = work_M - work_M(theta_interp==deg2rad(equalibrium_angle));    %center it so int_M = 0 when theta = 0

%Series Compliance
delta = M./kdelt; %Amount of deflection of the series compliance
work_delta = 1/2*kdelt*delta.^2; %Mechanical energy stored in the series compliance
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
    plot(x_import,y_import,'Linewidth',3);
    plot(x_import_offset,y_import_offset,'Linewidth',3);
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
    %Close (0.5*preload,12*kdelt,-4deg,0x,0.002y)
    %Preload
    
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

%% SIMULATING AVAILABLE STIFFNESS RANGE (INVERT THE BIRD)
%Adjust Model Parameters
%kdelt_JIM = 900;
%kdelt = kdelt_JIM;
preload = 0.0000000000000000001*preload;

F_cam = [];
F_cam_2 = [];
F_cam_3 = [];
s_lin = [];

%VSPA BACKWARDS(Everything gets backed out by new geometry + psi and r from primary curve)
vert_preload_init = -x_center.*tan(preload); %This is the translational equivalent to the rotational preload

% x_center_new = [x_center_max,75,primary_slider,50,45,40,x_center_min];
% ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3)), polyval(titanium,x_center_new(4)),polyval(titanium,x_center_new(5)), polyval(titanium,x_center_new(6)), polyval(titanium,x_center_new(7))];
% x_center_new = x_center_new*mm2m;
if(plot_all)
    %PLOTTING ALL SUPPORT CONDITIONS
    %x_VSO_all = [((x_center_max-x_center_min)*0.95+x_center_min):-0.5:x_center_min];
    %x_VSO_all = [x_center_max:-(x_center_max-x_center_min)/56:x_center_min];
    x_VSO_all = [x_center_max:-(x_center_max-x_center_min)*perc_max/56:(x_center_max-(x_center_max-x_center_min)*perc_max)];
    k_VSO_all = polyval(titanium,x_VSO_all);
    %x_center_new = x_VSO_all;
    x_center_new = x_VSO_all*mm2m;
    ktranslational = k_VSO_all;
end

if(plot_one)
    x_center_new = [primary_slider]*mm2m;cam_nonlin
    ktranslational = [polyval(titanium,primary_slider)];

end

if(plot_select)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.5 0.96])
    ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3))];
    x_center_new = x_center_new*mm2m;
    kdelt_dorsi = [911,1303,1822]; %cam3
    kdelt_planatar = [240,444,502]; %cam3
end

if(different_cam)
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.4984 0.9606])
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9 96.06]*(1/100))
    %x_center_new = x_center_max-((x_center_max-x_center_min)*[0, 0.40, 0.60])
    %ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3))];
    %ktranslational = polyval(titanium,x_center_new);
    %x_center_new = x_center_new*mm2m;
    %kdelt_dorsi = 1400*ones(1,length(x_center_new));
    %kdelt_plantar = 500*ones(1,length(x_center_new));
    
    %dk=length(x_center_new)-1;
%     kdelt_dorsi = [911:(1822-911)/dk:1822]; %cam3
%     kdelt_planatar = [240:(502-240)/dk:502]; %cam3
%     kdelt_dorsi = [911,1303,1822]; %cam3
%     kdelt_planatar = [240,444,502]; %cam3
%     kdelt_dorsi = [1041,1440,1673]; %cam1
%     kdelt_planatar = [516,620,721]; %cam1
%     kdelt_dorsi = [1440,1440,1440]; %testing
%     kdelt_planatar = [620,620,620]; %testing

    

    %PLOTTING ALL SUPPORT CONDITIONS
%     x_VSO_all = [((x_center_max-x_center_min)*0.95+x_center_min):-0.5:x_center_min];
%     k_VSO_all = polyval(titanium,x_VSO_all);
%     x_center_new = x_VSO_all*mm2m;
%     ktranslational = k_VSO_all;
%     x_VSO_all = [x_center_max:-(x_center_max-x_center_min)/56:x_center_min];
%     k_VSO_all = polyval(titanium,x_VSO_all);
    %x_center_new = x_VSO_all;
%     x_center_new = x_VSO_all*mm2m;
%     ktranslational = k_VSO_all;
    %1450 120
%     kdelt_dorsi = 1450*ones(1,length(x_center_new)); %cam3
%     kdelt_planatar = 120*ones(1,length(x_center_new)); %cam3
end

if(plot_tested)
    x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.0982 0.1982 0.2981 0.3982 0.4984 0.5982 0.698 0.7979 0.899 0.9606])
    ktranslational = [polyval(titanium,x_center_new(1)),polyval(titanium,x_center_new(2)),polyval(titanium,x_center_new(3)),polyval(titanium,x_center_new(4)),polyval(titanium,x_center_new(5)),polyval(titanium,x_center_new(6)),polyval(titanium,x_center_new(7)),polyval(titanium,x_center_new(8)),polyval(titanium,x_center_new(9)),polyval(titanium,x_center_new(10)),polyval(titanium,x_center_new(11))];
    x_center_new = x_center_new*mm2m;
    %kdelt_dorsi = [911,1066,1137,1181,1207,1303,1380,1476,1607,1773,1822];
    %kdelt_planatar = [240,304,331,408,407,444,519,503,542,513,502];
%     kdelt_dorsi = 1450*ones(1,length(x_center_new)); %cam3
%     kdelt_planatar = 150*ones(1,length(x_center_new)); %cam3
end

kdelt_dorsi = 1450*ones(1,length(x_center_new)); %cam3
kdelt_planatar = 120*ones(1,length(x_center_new)); %cam3 (120)
preload_new = atan(vert_preload_init./-x_center_new);  %This allows the preload to update as the slider moves

figure(2); hold on
color_end = [255 0 0]./255;
color_start = [255 230 230]./255;
q = 2;
color_ramp = 230/q;
colors_ramp_2 = 140/(4-q);
for i = 1:length(x_center_new)
    if(i<=q)
        color_beginning = color_start+[0 -color_ramp*i -color_ramp*i]./255;
        colors = color_beginning;
    else
        i
        -colors_ramp_2*(i-q)/255
        colors_end = color_beginning+[-colors_ramp_2*(i-q) 0 0]./255;
        colors = colors_end
    end
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
    %work_spring = work_spring - work_spring(gamma==0);
    work_spring = work_spring; %this is just used for cam import to prevent errors

    %Differientiate to get ankle torque
    M_ankle = diff(work_spring)./diff(theta_cam); %diff takes differences change in Moment/change in theta_cam 
    M_ankle(end+1) = M_ankle(end); %diff() function decreases the length of the vector by one
    if(kdelt_nonlinear)
        kdelt = [kdelt_planatar(i).*(M_ankle<0)+kdelt_dorsi(i).*(M_ankle>0)];
    end
    delta = M_ankle./kdelt;
    theta_new = theta_cam + delta;
    Moments(:,i) = M_ankle;
    save('Cam_Moments', 'Moments');
    Angles(:,i) = radtodeg(theta_new);
    save('Cam_angles', 'Angles');
    
    
    if(abs((x_center_new(i)-mm2m*(stroke*primary_percentage+x_center_min)))<0.0002)
        i_primary = i;
    end
    %v = plot(radtodeg(theta_new),M_ankle,'Linewidth',5,'Color',colors);
    v = plot(rad2deg(theta_new),M_ankle,'Linewidth',5);
    %v.Color = [0, 192, 192]./255;
    v.Color = [224, 224, 224]./255;
    %v.Color = [204, 153, 205]./255;

    %Cam Forces---------------------
    if(cam_forces)
        %r_test = (40+(100-primary_slider));
        ROM_index = find(abs(theta_new-ROM_thresh)<deg2rad(1));

        %F_cam = [F_cam L(i)*(ktranslational(i)*gamma_new(ROM_index(1))+(kdelt/(x_center_new(i))^2)*delta(ROM_index(1)))];
        %F_cam =  [F_cam (k(i)*gamma_new(ROM_index(1))+kdelt*delta(ROM_index(1)))/L(i)];
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
% if(plot_primary_original)
%     h = plot(radtodeg(theta_interp),M,'Linewidth',5);
%     h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
% end
if(primary_curve_scaled)
    h = plot(Angles(:,i_primary),Moments(:,i_primary),'Linewidth',5);
    %h = plot(radtodeg(theta_total),M,'Linewidth',5);
    h.Color = [96,96,96]/255; %h.Color = [255,203,5]/255; h.LineStyle = '--'
end
%plot(radtodeg(theta),M,'Linewidth',2,'Color','k','LineStyle','--')
%scatter(radtodeg(theta),M)
% set(gcf,'color','w');
% set(gca,'FontSize',11)
% set(gca,'linewidth',2)
% xlabel('Ankle Angle ({\circ})')
% ylabel('Ankle Torque (Nm)')
if(zoom)
    axis([-19 19 -20 100])
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
if(fullscale)
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
    figure
    hold on
    plot(x_center_new,F_cam./1000,'Linewidth',5)
    plot(x_center_new,F_cam_2./1000,'--','Linewidth',5)
    plot(x_center_new,F_cam_3./1000,'--','Linewidth',5)
    xlabel('Slider Position'); ylabel('Cam Force [kN]'); title('Cam Contact Force at Peak Torque @30 deg');
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
k_all_d = [];
k_all_p = [];
for i = 1:length(Angles(1,:))
    i_all_d = min(find(abs(Angles(:,i)-18)<0.7));
    i_all_p = min(find(abs(Angles(:,i)-(-18))<0.8));
    k_all_d = [k_all_d Moments(i_all_d,i)./deg2rad(Angles(i_all_d,i))];
    k_all_p = [k_all_p abs(Moments(i_all_p,i))./(abs(deg2rad(Angles(i_all_p,i))))];
%     i_all = min(find(abs(Angles(:,i)-18)<0.7));
%     k_all = [k_all Moments(i_all,i)./deg2rad(Angles(i_all,i))];
end
%----------------------------------
i_min = min(find(abs(Angles(:,1)-18)<0.7));
k_min = Moments(i_min,1)./deg2rad(Angles(i_min,1))
i_max = min(find(abs(Angles(:,end)-18)<0.8));
k_max = Moments(i_max,end)./deg2rad(Angles(i_max,end))
%-------------------------
i_min_p = min(find(abs(Angles(:,1)-(-18))<0.7));
k_min_plantar = Moments(i_min_p,1)./deg2rad(Angles(i_min_p,1))
i_max_p = min(find(abs(Angles(:,end)-(-18))<0.8));
k_max_plantar = abs(Moments(i_max_p,end))./(abs(deg2rad(Angles(i_max_p,end)))+abs(deg2rad(equalibrium_angle)))

performance = k_max/k_min
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
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
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
    plot(theta_interp, work_M,'Linewidth',5)
    plot(theta_interp,work_delta,'Linewidth',5)
    plot(theta_interp,spring_work,'Linewidth',5)
    legend('Energy Stored by Primary Curve','Energy Stored by Shell','Energy Stored in Spring')
    title('Energy Storage in VSO'); xlabel('Ankle Angle ({\circ})'); ylabel('Work (Joules)');
    legend boxoff
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2);
    hold off
end

output = {["Highest Dorsi Stiffness [Nm/rad]: " + string(string(k_max))],...
        ["Lowest Dorsi Stiffness [Nm/rad]: " + string(string(k_min))],...
        ["Highest Plantar Stiffness [Nm/rad]: " + string(string(k_max_plantar))],...
        ["Lowest Plantar Stiffness [Nm/rad]: " + string(string(k_min_plantar))],...
        ["ROM [Dorsi, Plantar]: [" + string(dorsi_max)+","+string(plantar_max)+']']}; 
msgbox(output,"Simulation Results");

%% Automate Figure Placement
% figs =  findobj('type','figure');
% num_fig = length(figs);
% num_cols =  4;
% num_rows = 2;
% screen_size  = get(0,'screensize');
% task_bar = screen_size(3)/35;
% pc_width  = 0.7*(screen_size(3)-task_bar);
% pc_height = screen_size(4);
% width = pc_width/num_cols;
% height = 0.60*pc_height/num_rows;
% buffer = 85;
% x = 0;
% y = 0;
% for f=1:num_fig
%     h = figure(f);
%     if(x<=((num_cols-1)/num_cols)*pc_width)
%         set_fig_position(h,y,x,height,width)
% 
%     else
%         x = 0;
%         y = y+height+buffer;
%         set_fig_position(h,y,x,height,width)
%     end
%     x = x+width; 
% end

%% Message Box
% output1 = {["Augmentation Factor: " + string(augmentation)],...
%         ["User Mass w/o Exoskeleton[kg]: " + string(weight)],...
%         ["Motor to Spring Gear Ratio: " + string(n_m2s)],...
%         ["Motor to Ankle Gear Ratio: " + string(n)],...
%         ["Average Motor Efficiency [%]: " + string(Overall_Efficiency_Motor)],...
%         ["Distance Traveled [miles]: " + string(distance_travel)],...
%         ["Max Current: " + string(max([max(i_q) max(iw_n)]))],...
%         ["Max Voltage: " + string(max([max(V_q) max(vw_n)]))],...
%         ["Steady State Temperature [Celsius]: " + string(max(T_w))]}; 
% msgbox(output1,"Simulation Results");
% 
% if(jump)
%     output1 = {["Jump Height Increase [m]: " + string(vertical_increase)],...
%         ["Spring Contribution to Jump Height [m]: " + string(height_jump_spring)],...
%         ["Motor Contribution to Jump Height [m]: " + string(height_jump_motor )],...
%         ["Biological Contribution to Jump Height [m]: " + string(height_jump_biological)],...
%         ["Total Jump Height [m]: " + string(height_jump_total)],}; 
% msgbox(output1,"Jumping Related Results");
% end

function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end







