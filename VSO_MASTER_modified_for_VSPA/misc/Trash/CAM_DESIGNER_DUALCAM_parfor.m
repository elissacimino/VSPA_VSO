%% NEUROBIONICS LAB

%Dual Cam VSO Orthosis Cam Profile Derivation
%Nikko Van Crey (nikkovc@umich.edu) and Hashim Quaraishi
%Emily Bywater function edits for parfor loop (ebywater@umich.edu)
% function CAM_DESIGNER_DUALCAM_parfor()
function [catchit, int_blue1, int_blue2, int_orange1, int_orange2, ...
    sbe, soe, equibO, equibB, tangdorsi1, tangdorsi2, tangplantar1, tangplantar2, intse, slopee,...
    emid, edorsi, ecomp, epush] = CAM_DESIGNER_DUALCAM_parfor(plantar_scaling, switching_angle_dorsi, switching_angle_plantar, ...
    equilibrium_blue, equilibrium_orange, r1, r4, r2, square_buffer)
% addpath('IMPORTS')
% addpath('IMPORTS/nurbs_toolbox')
catchit = 0; int_blue1 = 0; int_blue2 = 0; int_orange1 = 0; int_orange2 = 0; sbe = 0;
soe = 0; equibO = 0; equibB = 0; tangdorsi1 = 0; tangdorsi2 = 0;
tangplantar1 = 0; tangplantar2 = 0; intse = 0;
slopee = 0; emid = 0; edorsi = 0; ecomp = 0; epush = 0;
% addpath('DUAL_CAMS')
% load('dual_cams_emily.mat')
%% dual_cams_emily 
%What Stiffness
slope_dorsi_rad = 80; %This is the desired dorsi slope in Nm/rad
end_scaling = 0.5;
%Tune Angles
angle_leveling = 25; %Dorsiflexion Angle that leveling begins
converge = 0.5; %angle ROM for curve to converge to one-another
kdelt_dorsi = 650; %measured on Ottobock Prototype
kdelt_plantar = 350; %measured on Ottobock Prototype
% CHECKING FOR USER ERROR (NOT BULLET PROOF)
if((-switching_angle_plantar>=equilibrium_orange)||(switching_angle_dorsi<=equilibrium_blue))
%     disp('equalibrium angle must be before switch')
    catchit = 1;
    return
end
if(r2*switching_angle_dorsi<=equilibrium_blue)
%     disp('r2 must have a greater value because it is too close to equilibrium')
    catchit = 1;
    return
end
% MATH
scalefactor = 1; %Don't change
slope_dorsi_deg = slope_dorsi_rad/rad2deg(1);
slope_plantar_rad  = plantar_scaling*slope_dorsi_rad;
slope_plantar_deg = plantar_scaling*slope_dorsi_deg;
moment_dorsi_switch = slope_dorsi_deg*(switching_angle_dorsi);
moment_plantar_switch = slope_dorsi_deg*(-switching_angle_plantar)*plantar_scaling;
slope_end_dorsi = end_scaling*slope_dorsi_deg;
% ORANGE
xo1 = -switching_angle_plantar;
xo2 = -switching_angle_plantar+converge;
xo3 = equilibrium_orange;
shift = (r4*switching_angle_dorsi-xo3)/2;
xo4 = xo3+shift;
xo5 = xo4+shift; %Design
xo6 = switching_angle_dorsi-converge;
xo7 = switching_angle_dorsi;
%-----------------------------------------
theta_orange = [xo1, xo2, xo3, xo4, xo5, xo6, xo7]; % orange curve (degrees)
%-----------------------------------------
yo1 = moment_plantar_switch;
yo2 = moment_plantar_switch+converge*slope_plantar_deg;
yo3 = 0; %Equlibrium
yo4 = (r1*moment_dorsi_switch)/2;
yo5 = yo4*2; %Design
yo6 = moment_dorsi_switch-converge*slope_dorsi_deg; 
yo7 = moment_dorsi_switch;
%-----------------------------------------
moments_orange = [yo1, yo2, yo3, yo4, yo5, yo6, yo7];
%-----------------------------------------
orange_control_points = [deg2rad(theta_orange); moments_orange]'; % orange curve

% BLUE
xb1 = xo1;
xb2 = xo2;
xb3 = equilibrium_blue-square_buffer; %Design
xb4 = equilibrium_blue;
xb5 = r2*switching_angle_dorsi; %Design
xb6 = xo6;
xb7 = xo7;
theta_blue = [xb1, xb2, xb3, xb4, xb5, xb6, xb7]; % blue curve (degrees)
%-----------------------------------------
yb1 = yo1;
yb2 = yo2;
yb3 = 0.85*yo2; %Design
yb4 = 0; %Equlibrium
yb5 = 0.9*yo7; %Design
yb6 = yo6; 
yb7 = yo7;
%-----------------------------------------
moments_blue = [yb1, yb2, yb3, yb4, yb5, yb6, yb7];
blue_control_points = [deg2rad(theta_blue); moments_blue]'; %blue curve

blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]); %equally spaced knots, but doesn't have to be
blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))'; %evaluate the crv object
orange_crv = nrbmak(orange_control_points',[0 0 0 0.2, 0.4 0.6, 0.8 1 1 1]);  %equally spaced knots, but doesn't have to be
orange_pts = nrbeval(orange_crv,linspace(0.0,1.0,100))'; %evaluate the crv object

%%%PLOTTING CONTROL POINTS
figure(15); hold on; grid on
plot(orange_control_points(:,1)*180/pi, orange_control_points(:,2),'Linewidth',2,'Color', [255 136 0]/255)
plot(blue_control_points(:,1)*180/pi, blue_control_points(:,2),'Linewidth',2,'Color', [88 164 176]/255)
set(gcf,'color','w');
set(gca,'FontSize',15)
set(gca,'linewidth',2)
xlabel('Ankle Angle [deg]')
ylabel('Ankle Torque [N.m]')
xlim([-15 15])
ylim([-30 50])
legend('Orange Control Points', 'Blue Control Points')
legend box off
title('NURBS TA Curves')

%% CAM_DESIGNER_DUALCOM_parfor
try
preload = 0.003;
primary_percentage = 0.5;
y_center = 0.008;
x_center_max = 88;
x_center_min = 32.5;
r0 = 0.03529;
cam_radius = 0.0085;
load('IMPORTS/Conversions.mat')
F_cam = [];
deflect = [];
transition = [];
transition_angles = [];
equilibrium_blue_array = [];
equilibrium_orange_array = [];
ES_array = [];
ER_array = [];
midstance_energy_array = [];
dorsi_energy_array = [];
pushoff_energy_array = [];
ExpectedAdditionalEnergy_Percent_array = [];
res = 0.005;
theta = pi/180*(-switching_angle_plantar:res:switching_angle_dorsi);
theta_total = pi/180*(-40:res:40);
[~,pf_transition] = min(abs(-switching_angle_plantar-rad2deg(theta_total))); % Check for two identical points
[~,df_transition] = min(abs(switching_angle_dorsi-rad2deg(theta_total)));
x_spring = perc2mm([0,10.01,19.97,29.97,39.95,49.95,59.97,70.07,80.04,90.01,96.98],x_center_max,x_center_min);
k_spring = [0.166318991334212,0.208391576135634,0.282351259287986,0.374190624007133,0.489817440908308,0.631742113520826,0.796116260994716,1.01916697238319,1.34705270360385,1.70337140522367,2.13270292544089]*10^6; % kN/mm
titanium = polyfit(x_spring,k_spring,5);
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
BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
OrangeMoment = interp1(orange_pts(:,1),orange_pts(:,2),theta);
figure(70)
hold on
plot(theta,BlueMoment)
plot(theta,OrangeMoment)
[~,BlueIndex] = min(abs(BlueMoment));
[~,OrangeIndex] = min(abs(OrangeMoment));
ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex))));
ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));
knob = blue_control_points(5,2)/(slope_dorsi_rad*pi/180);
    while ER>ES*1.0001
        knob = knob-0.001;
        blue_control_points(5,2) = knob;
        blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))';
        if theta(end) > blue_pts(end, 1)
            if round(theta(end), 4) < blue_pts(end, 1)
                theta(end) = round(theta(end), 4);
            elseif round(blue_pts(end, 1), 4) > theta(end)
                blue_pts(end, 1) = round(blue_pts(end, 1), 4);
            end
        end
        BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
        [~,BlueIndex] = min(abs(BlueMoment));
        ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));
    end
    while ER<ES*0.9999
        knob = knob+0.001;
        blue_control_points(5,2) = knob;
        blue_crv = nrbmak(blue_control_points',[0 0 0 0.2, 0.4 0.6 0.8 1 1 1]);
        blue_pts = nrbeval(blue_crv,linspace(0.0,1.0,100))';
        if theta(end) > blue_pts(end, 1)
            if round(theta(end), 4) < blue_pts(end, 1)
                theta(end) = round(theta(end), 4);
            elseif round(blue_pts(end, 1), 4) > theta(end)
                blue_pts(end, 1) = round(blue_pts(end, 1), 4);
            end
        end
        BlueMoment = interp1(blue_pts(:,1),blue_pts(:,2),theta);
        [~,BlueIndex] = min(abs(BlueMoment));
        ER = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end)))) - max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));
    end
OrangeMoment = scalefactor*OrangeMoment;
BlueMoment = scalefactor*BlueMoment;
[~,BlueIndex] = min(abs(BlueMoment));
[~,OrangeIndex] = min(abs(OrangeMoment));
ES = max(abs(cumtrapz(theta(1:BlueIndex),BlueMoment(1:BlueIndex)))) - max(abs(cumtrapz(theta(1:OrangeIndex),OrangeMoment(1:OrangeIndex))));
midstance_energy = ES;
dorsi_energy = max(abs(cumtrapz(theta(OrangeIndex:end),OrangeMoment(OrangeIndex:end))));
pushoff_energy = max(abs(cumtrapz(theta(BlueIndex:end),BlueMoment(BlueIndex:end))));
ExpectedAdditionalEnergy_Percent = 100+(pushoff_energy-dorsi_energy)/dorsi_energy*100;
OrangeMoment = (1/scalefactor)*OrangeMoment;
BlueMoment = (1/scalefactor)*BlueMoment;
th_plantar = deg2rad([-40 -30 -20]');
M_plantar = slope_plantar_rad*th_plantar;
th_dorsi = deg2rad([12.5 15 22 angle_leveling 28 34 40]');
M_dorsi = [slope_dorsi_deg*[rad2deg(th_dorsi(1:4))]; (slope_end_dorsi*(rad2deg(th_dorsi(5:end))-angle_leveling)+slope_dorsi_deg*angle_leveling)];
M_points = [M_plantar; BlueMoment';M_dorsi];
theta_points = [th_plantar; theta' ;th_dorsi];
% disp([plantar_scaling, switching_angle_dorsi, switching_angle_plantar, ...
%     equilibrium_blue, equilibrium_orange, r1, r4, r2, square_buffer])
% BlueMomentIdeal = interp1(unique(theta_points),unique(M_points),theta_total,'spline');
BlueMomentIdeal = interp1(theta_points,M_points,theta_total,'spline');
OrangeMomentIdeal = [BlueMomentIdeal(1:pf_transition-1) OrangeMoment BlueMomentIdeal(df_transition+1:end)];
% if size(OrangeMomentIdeal, 2) < size(theta_total, 2)
%     catchit = 1;
%     return
% end
BlueMomentIdeal = scalefactor*BlueMomentIdeal;
OrangeMomentIdeal = scalefactor*OrangeMomentIdeal;
[~,BlueMomentIdealIndex] = min(abs(BlueMomentIdeal));
[~,OrangeMomentIdealIndex] = min(abs(OrangeMomentIdeal));
slope_blue_error = [];
slope_orange_error = [];
sbe = 0; soe = 0; slopee = 0;
for p = 2:length(BlueMomentIdeal)
    if((BlueMomentIdeal(p)-BlueMomentIdeal(p-1))<=0)
        slope_blue_error = [BlueMomentIdeal(p); theta_total(p)*180/pi];
    end
end
for q = 2:length(OrangeMomentIdeal)
    if ((OrangeMomentIdeal(q)-OrangeMomentIdeal(q-1))<=0)
        slope_orange_error = [OrangeMomentIdeal(q); theta_total(q)];
    end
end
if((isempty(slope_blue_error)==0)||(isempty(slope_orange_error)==0))
    sbe = 1;
    soe = 1;
    slopee = 1;
end
stroke = x_center_max-x_center_min;
x_center = (x_center_min+(1-primary_percentage)*stroke)*mm2m;
primary_slider = x_center*m2mm;
L = sqrt(x_center^2+y_center^2);
d = sqrt((r0+y_center)^2+x_center^2);
sigma = acos((r0^2-d^2-L^2)/(-2*d*L));
work_P_fw = cumtrapz(theta_total,BlueMomentIdeal);
work_P_fw = work_P_fw - work_P_fw(BlueMomentIdealIndex);
work_D_fw = cumtrapz(theta_total,OrangeMomentIdeal);
work_D_fw = work_D_fw - work_D_fw(OrangeMomentIdealIndex);
equilibrium_orange_actual = theta(OrangeIndex);
kdelt_orange = kdelt_dorsi*(theta_total>equilibrium_orange_actual)+kdelt_plantar*~(theta_total>equilibrium_orange_actual);
equilibrium_blue_actual = theta(BlueIndex);
kdelt_blue = kdelt_dorsi*(theta_total>equilibrium_blue_actual)+kdelt_plantar*~(theta_total>equilibrium_blue_actual);
k = polyval(titanium,primary_slider)*(x_center)^2;
delta = BlueMomentIdeal./kdelt_blue;
work_delta_fw = 1/2.*kdelt_blue.*delta.^2;
delta_fw2 = OrangeMomentIdeal./kdelt_orange;
work_delta_fw2 = 1/2.*kdelt_orange.*delta_fw2.^2;
theta_cam_fw = theta_total-delta;
theta_cam_fw2 = theta_total-delta_fw2;
gammao = preload;
a = k./2;
b = k.*gammao;
c = work_delta_fw-(work_P_fw); 
gamma_fw = (-b+sqrt(b.^2-4.*a.*c))./(2*a);
r = sqrt(L^2 + d^2 - 2*L*d*cos(gamma_fw+sigma));
angle_constant_fw = atan((-y_center-r0)/-x_center); 
omega_fw = asin(L./r.*sin(gamma_fw+sigma));
alpha_fw = omega_fw + angle_constant_fw-pi/2;
psi = theta_cam_fw-alpha_fw;
y = r.*sin(psi);
x = r.*cos(psi);
xprime = diff(x)./diff(psi);
    xprime(end+1) = xprime(end);
yprime = diff(y)./diff(psi);
    yprime(end+1) = yprime(end);
% curve_x = x + -cam_radius.*yprime./sqrt(xprime.^2 + yprime.^2);
curve_y = y + -cam_radius.*-xprime./sqrt(xprime.^2 + yprime.^2);
% curve_z = sqrt(curve_x.^2 + curve_y.^2); % m
gamma2o = sqrt((ES+0.5*k*gammao.^2)/(0.5*k))-gammao;
sigma_fw2 = sigma + gamma2o;
a2 = k./2;
b2 = k.*(gamma2o+gammao);
c2 = work_delta_fw2-(work_D_fw); 
gamma_fw2 = (-b2+sqrt(b2.^2-4.*a2.*c2))./(2*a2);
r2 = sqrt(L^2 + d^2 - 2*L*d*cos(gamma_fw2+sigma_fw2));
omega_fw2 = asin(L./r2.*sin(gamma_fw2+sigma_fw2));
alpha_fw2 = omega_fw2 + angle_constant_fw-pi/2;
psi2 = theta_cam_fw2-alpha_fw2;
y2 = r2.*sin(psi2);
x2 = r2.*cos(psi2);
xprime2 = diff(x2)./diff(psi2);
    xprime2(end+1) = xprime2(end);
yprime2 = diff(y2)./diff(psi2);
    yprime2(end+1) = yprime2(end);
% curve_x2 = x2 + -cam_radius.*yprime2./sqrt(xprime2.^2 + yprime2.^2);
curve_y2 = y2 + -cam_radius.*-xprime2./sqrt(xprime2.^2 + yprime2.^2);
% curve_z2 = sqrt(curve_x2.^2 + curve_y2.^2);
% curves = [curve_z; curve_z2];
% setGlobalCatchit(curves);
transition_dorsi = switching_angle_dorsi;
index_dt = find(theta_total==deg2rad(transition_dorsi));
rad2deg(theta_cam_fw(index_dt));
rad2deg(delta(index_dt));
intersections_blue = [];
intersections_orange = [];
for i = 2:length(curve_y2)
    if((curve_y(i)-curve_y(i-1))<0) 
        intersections_blue = [intersections_blue ;[i rad2deg(theta_total(i)) curve_y(i)]];
    end
    if((curve_y2(i)-curve_y2(i-1))<0) 
        intersections_orange = [intersections_orange ;[i rad2deg(theta_total(i)) curve_y2(i)]];
    end
end
int_blue1 = 0; int_blue2 = 0;
int_orange1 = 0; int_orange2 = 0;
if(isempty(intersections_blue)==0 || isempty(intersections_orange)==0)
    intse = 1;
    if isempty(intersections_blue)==0
        int_blue1 = intersections_blue(1, 2);
        int_blue2 = intersections_blue(end, 2);
    end
    if isempty(intersections_orange)==0
        int_orange1 = intersections_orange(1, 2);
        int_orange2 = intersections_orange(end, 2);
    end
end
x_center_new = x_center_max-((x_center_max-x_center_min)*[0 0.5 1]);
ktranslational = [polyval(titanium,x_center_new)];
x_center_new = x_center_new*mm2m;
vert_preload_inv = -x_center.*tan(preload); 
spring_preload_inv = atan(vert_preload_inv./-x_center_new);
vert_preload_inv2 = -x_center.*tan(gamma2o + preload);
spring_preload_inv2 = atan(vert_preload_inv2./-x_center_new);
for i = 1:length(x_center_new)
    transition = [];
    l_spring_inv(i) = sqrt(x_center_new(i).^2+y_center^2);
    d_inv(i) = sqrt((r0+y_center)^2+x_center_new(i).^2);
    sigma_inv(i) = atan(x_center_new(i)/y_center)-atan(-x_center_new(i)/(-r0-y_center));
    angle_constant_inv(i) = atan((-y_center-r0)/-x_center_new(i));
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
    sigma_inv2 = sigma_inv + spring_preload_inv2(i) - spring_preload_inv(i);
    omega_inv2 = acos((l_spring_inv(i).^2 - r2.^2 - d_inv(i).^2)./(-2*r2.*d_inv(i)));
    alpha_inv2 = -(atan(-x_center_new(i)/(-r0-y_center)) - omega_inv2);
    theta_cam_inv2 = alpha_inv2 + psi2;
    gamma_inv2 = acos((r2.^2 - l_spring_inv(i)^2 - d_inv(i)^2)./(-2*l_spring_inv(i)*d_inv(i)))-sigma_inv2(i);
    OrangeMomentSpring = k(i)*(gamma_inv2 + spring_preload_inv2(i));  
    work_spring_inv2 = cumtrapz(gamma_inv2 ,OrangeMomentSpring); 
    OrangeMomentAnkle = diff(work_spring_inv2)./diff(theta_cam_inv2); 
    OrangeMomentAnkle(end+1) = OrangeMomentAnkle(end);
    delta_inv2 = OrangeMomentAnkle./kdelt_orange;
    theta_inv2 = theta_cam_inv2 + delta_inv2;
    %%
    % ROM_thresh = deg2rad(27);
    % ROM_index = find(abs(theta_inv2-ROM_thresh)<deg2rad(1));%0.006
    % F_cam = [F_cam OrangeMomentSpring(ROM_index(1))./l_spring_inv(i)];
    % deflect = [deflect F_cam(i)/(0.1663*10^6)];
    %%
    difference = abs(OrangeMomentAnkle-BlueMomentAnkle);
    transition_tolerance = 0.005; % [Nm]
    check = difference<transition_tolerance;
    for j=2:length(check)
        if((rad2deg(theta_total(j))<(-switching_angle_plantar+3)) | (rad2deg(theta_total(j))>(switching_angle_dorsi-3)))
            if(check(j)~=check(j-1))
                transition = [transition;j];
            end
        end
    end
    if length(transition) ~= 2
        transition_angles = [0 0];
        TAmistake = 1;
    else
        transition_angles = [transition_angles; rad2deg(theta_inv(transition))];
        TAmistake = 0;
    end
    [~,BlueIndex_new] = min(abs(BlueMomentAnkle));
    [~,OrangeIndex_new] = min(abs(OrangeMomentAnkle));
    equilibrium_blue_array = [equilibrium_blue_array;rad2deg(theta_inv(BlueIndex_new))];
    equilibrium_orange_array = [equilibrium_orange_array;rad2deg(theta_inv2(OrangeIndex_new))];

end

if slopee ~= 1 && intse ~= 1
    equibO = mean(equilibrium_orange_array);
    equibB = mean(equilibrium_blue_array);
    if TAmistake == 0
        tangdorsi1 = min(transition_angles(:,2));
        tangdorsi2 = max(transition_angles(:,2));
        tangplantar1 = -min(abs(transition_angles(:,1)));
        tangplantar2 = -max(abs(transition_angles(:,1)));
    else
        tangdorsi1 = 0; tangdorsi2 = 0; tangplantar1 = 0; tangplantar2 = 0;
    end
    emid = midstance_energy;
    edorsi = dorsi_energy;
    ecomp = ExpectedAdditionalEnergy_Percent;
    epush = pushoff_energy;
else
    equibO = NaN;
    equibB = NaN;
    tangdorsi1 = NaN;
    tangdorsi2 = NaN;
    tangplantar1 = NaN;
    tangplantar2 = NaN;
    emid = NaN;
    edorsi = NaN;
    ecomp = NaN;
    epush = NaN;
end

catch
    int_blue1 = NaN; int_blue2 = NaN; int_orange1 = NaN; int_orange2 = NaN; sbe = NaN;
    soe = NaN; equibO = NaN; equibB = NaN; tangdorsi1 = NaN; tangdorsi2 = NaN;
    tangplantar1 = NaN; tangplantar2 = NaN; intse = NaN;
    slopee = NaN; emid = NaN; edorsi = NaN; ecomp = NaN; epush = NaN;
end
end


function [x_mm] = perc2mm(x_perc,x_center_max,x_center_min)
    x_mm = (x_center_max-(x_center_max-x_center_min)*(x_perc/100));
end

