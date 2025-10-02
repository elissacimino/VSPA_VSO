%% NEUROBIONICS LAB

%% ELISSA WORKSPACE VSPA v2
% VSPA Cam Profile Derivation, based on VSO Cam code by Nikko
% David Lam | davilam@umich.edu | Nikko Van Crey | nikkovc@umich.edu | 847-917-9990
clear
close all
%close all hidden
addpath('TA');addpath('TA/ottobock');addpath('TA/wearable_tech');addpath('TA/old');addpath('IMPORTS');addpath('IMPORTS/VSO_functions');addpath('IMPORTS/data');addpath('inputs')
addpath('IMPORTS/MATLABFunctions/');
tic


% CONFIGURABLES
%Which Prototype
prototype = 'Rotary VSPA';
%Export cam profile?
export = input('Export cam profile data? yes or no :','s');

%Which TA curve
% for foot = {'uniform','trustep','variflex','allpro','lvl','inc','dec'};
for foot = {'uniform','linear zero eq', 'linear off zero'};
%foot = 'lvl';
    % Old VSPA design with single cam profile
    if strcmp(prototype,'VSPA')
        VSPA_configuration()
        load('inputs/VSPA_configuration.mat')
    % New VSPA design with multiple cam profiles in rotary barrel
    elseif strcmp(prototype,'Rotary VSPA')
        Rotary_VSPA_configuration()
        load('inputs/Rotary_VSPA_configuration.mat')
        shift_curve = 1;
    end

    %Misc
    blue = 0;
    black = 0;
    grey = 1;
    % theta_query = [8.7 10]; %marks corresponding ankle angles on cam profile and TA function
    theta_query = [];
    characterization_parameter_testing = 0; %allows code to change series compliance and figure(6) in the inverted model, from those use to make cam profile
    different_cam = 0; %allows testing cams from pre'viously generated txt. Change the txt for cam, y_center for cam, scaling and shape of cam, x_center_inv in plot select, maybe change gamma==0 line for work calculation in inverse model
    dual_test = 0;


    % Create TA dataset
    max_d = 40;
    max_p = 40;
    theta_total = pi/180*(-max_p:0.05:max_d);
    equilibrium_angle = 0;   %we want different equilibrium angles -- some
    % may be at 0 but not all will be
    m=85.45; %body mass for mass-dependent TA curves

    if strcmp(cam,'rotary')
        thetapoints = deg2rad([-max_p:1:max_d]);
        stiffness_eq = 350;
        plantar_perc_eq = 0.8;
        plantar_perc = 0.33; 
        ez_p = -2;%Equilibrium Zone endpoint in plantarflexion
        ez_z = 0;%Equilibrium Zone zero point
        ez_d = 2; %Equilibrium Zone endpoint in dorsiflexion
        tz_p = -3;%Transition zone end point in plantarflexion
        tz_d = 3;%Transition zone end point in dorsiflexion

        ez_p_i = find(thetapoints==deg2rad(ez_p)); %index of equilibrium zone endpoint in plantarflexion
        ez_z_i = find(thetapoints==deg2rad(ez_z)); %index of Equilibrium Zone zero point
        ez_d_i = find(thetapoints==deg2rad(ez_d)); %index of Equilibrium Zone endpoint in dorsiflexion
        tz_p_i = find(thetapoints==deg2rad(tz_p)); %index of Transition zone end point in plantarflexion
        tz_d_i = find(thetapoints==deg2rad(tz_d)); %index of Transition zone end point in dorsiflexion
    end

    %Uniform linear stiffness as equilibrium region
    if strcmp(foot,'uniform')
        stiffness = stiffness_eq;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc_eq;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(4:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    end

    %Dataset collected by David with TT subject wearing commercial prosthesis
    if strcmp(foot,'trustep')
        load('TA/datasets/CP_Trustep_TT01.mat')
        Mpoints_in = [-25,-25,grid_torque,175,176,177]; %trustep
        thetapoints_in = deg2rad([-40,-10,grid_angle,17,30,40]); %trustep
        Mpoints = interp1(thetapoints_in, Mpoints_in, deg2rad([-max_p:1:max_d]),'pchip');
    elseif strcmp(foot,'variflex')
        load('TA/datasets/Ossur_Variflex_TT01.mat')
        Mpoints_in = [-40,-35,grid_torque,150,170,180]; %variflex
        thetapoints_in = deg2rad([-40,-10,grid_angle,23,30,40]); %variflex
        Mpoints = interp1(thetapoints_in, Mpoints_in, deg2rad([-max_p:1:max_d]),'pchip');
    elseif strcmp(foot,'allpro')
        load('TA/datasets/Fillauer_Allpro_TT01.mat')
        Mpoints_in = [-50,-30,grid_torque,144,170,180]; %AllPro
        thetapoints_in = deg2rad([-40,-10,grid_angle,23,30,40]); %allpro
        Mpoints = interp1(thetapoints_in, Mpoints_in, deg2rad([-max_p:1:max_d]),'pchip');
        %JIM tested VSPA at 40% stiffness on linear cam
    elseif strcmp(foot,'vspa')
        %load('TA/datasets/VSPA.mat')
        Mpoints = [-77.14,-17,-15,-11.35,-7.76,-4.51,0,11.61,32.94,49.68,58.84,287.0244];
        thetapoints = deg2rad([-40,-8.815,-7.36,-5.87,-3.86, -2.212,0,1.4,4.40,6.80,8.20,40]);
        %6.1mm d 1.6mm p
    %Average stiffness from Pett et al. 2024 avg m collected =93
    elseif strcmp(foot,'lvl')
        stiffness = 670.9/93*m;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(1-tz_p:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    elseif strcmp(foot,'inc')
        stiffness = 566.2/93*m;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(4:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    elseif strcmp(foot,'dec')
        stiffness = 712.8/93*m;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(4:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    elseif strcmp(foot,'asc')
        stiffness = 546.6/93*m;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(4:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    elseif strcmp(foot,'des')
        stiffness = 516.6/93*m;
        thetapoints = deg2rad([-max_p:1:max_d]);
        if shift_curve == 1
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
            Mpoints(1:max_p)= Mpoints(4:max_p-(tz_p))+stiffness_eq*plantar_perc_eq*deg2rad((tz_p));
            Mpoints(max_p+1:max_p+max_d+1) = Mpoints(max_p+1-tz_d:max_p+max_d+1-tz_d)+stiffness_eq*deg2rad(tz_d);
        else
            Mpoints(1:max_p) = stiffness*thetapoints(1:max_p)*plantar_perc;
            Mpoints(max_p+1:max_p+max_d+1) = stiffness*thetapoints(max_p+1:max_p+max_d+1);
        end
    % Shepherd et al.
    elseif strcmp(foot,'lvl_bovi')
        
        thetapoints_in = [-0.65, -0.5, -0.2, 0, 0.125, 0.21, 0.24, 0.4, 0.5, 0.65];
        Mpoints_in = [-25,-25,-17,0,25,60,76,100,100,100]/70*m;
        Mpoints = interp1(thetapoints_in, Mpoints_in, deg2rad([-max_p:1:max_d]),'pchip');
        

    %% These have been added to test a consistent linear TA relationship, with one having an equilbrium angle at 0 and another at -10deg
    elseif strcmp(foot, 'linear zero eq')
        thetapoints = deg2rad(-max_p:max_d);
        stiffness_linear = 15.8 * (180/pi);                  % Nm/deg to Nm/rad
        Mpoints = stiffness_linear * thetapoints;            % linear relationship from -40 to 40 degrees with stiffness of 15.8 Nm/deg
        % fileName = fullfile('inputs', 'TA_linear.mat');
        % save(fileName, 'Mpoints');

    elseif strcmp(foot, 'linear off zero')
        stiffness_linear = 15.8 * (180/pi);
        thetapoints = deg2rad(-max_p:max_d+10); 
        Mpoints = stiffness_linear * thetapoints;
        Mpoints = Mpoints(11:end);     
        thetapoints = deg2rad(-max_p:1:max_d);               % horizontal shift by 10 degrees (left), making the equilibrium angle at -10deg 
        eq_index = find(Mpoints==0);                         % index where M=0, otherwise known as equilibrium angle
        equilibrium_angle = rad2deg(thetapoints(eq_index));  % convert equilibrium point from rad to deg

    end


    %M = interp1(thetapoints, Mpoints, theta_total,'pchip');

    %defining TA of equilibrium zone for rotary cam
    % this will use the equilibrium zone centered at 0 (line 54), so don't
    % use this if using a curve with non-zero equilibrium point
    if strcmp(cam,'rotary') && ~strcmp(foot, 'linear off zero')
        thetapoints = deg2rad([-max_p:1:max_d]);
        Mpoints(ez_z_i:ez_d_i) = stiffness_eq*thetapoints(ez_z_i:ez_d_i);
        Mpoints(ez_p_i:ez_z_i) = stiffness_eq*plantar_perc_eq*thetapoints(ez_p_i:ez_z_i);
        Mpoints(tz_p_i+1:ez_p_i-1) = nan;
        Mpoints(ez_d_i+1:tz_d_i-1) = nan;
        M = interp1(thetapoints, Mpoints, theta_total,'pchip');

    % in future, can just do elseif to include all curves with non-zero
    % equilibrium angle
    elseif strcmp(cam, 'rotary') && strcmp(foot, 'linear off zero')
        thetapoints = deg2rad([-max_p:1:max_d]);
        % offset equilibrium zone and transition zone from non-zero
        % equilibrium angle
        ez_p = equilibrium_angle - 2;      % originally -2 deg; equilibrium zone endpoint in plantarflexion
        ez_z = equilibrium_angle;          % originally 0 deg; equilibrium zone zero point
        ez_d = equilibrium_angle + 2;      % originally 2 deg; equilibrium zone endpoint in dorsiflexion
        tz_p = equilibrium_angle - 3;      % originally -3 deg; transition zone end point in plantarflexion
        tz_d = equilibrium_angle + 3;      % originally 3 deg; transition zone end point in dorsiflexion

        ez_p_i = find(thetapoints==deg2rad(ez_p));  % index of equilibrium zone endpoint in plantarflexion
        ez_z_i = find(thetapoints==deg2rad(ez_z));  % index of equilibrium zone zero point
        ez_d_i = find(thetapoints==deg2rad(ez_d));  % index of equilibrium zone endpoint in dorsiflexion
        tz_p_i = find(thetapoints==deg2rad(tz_p));  % index of transition zone endpoint in plantarflexion
        tz_d_i = find(thetapoints==deg2rad(tz_d));  % index of transition zone endpoint in dorsiflexion

        Mpoints(ez_z_i:ez_d_i) = stiffness_eq*thetapoints(ez_z_i:ez_d_i);
        Mpoints(ez_p_i:ez_z_i) = stiffness_eq*plantar_perc_eq*thetapoints(ez_p_i:ez_z_i);
        Mpoints(tz_p_i+1:ez_p_i-1) = nan;
        Mpoints(ez_d_i+1:tz_d_i-1) = nan;
        % thetapoints = 
        M = interp1(thetapoints, Mpoints, theta_total,'pchip');
    end

    figure(1); 
    hold on
    plot(theta_total*180/pi,M,'LineWidth',2)
    exist Mpoints_in;
    if ans == 1
        %plot(thetapoints_in*180/pi,Mpoints_in,'.','Color','k')
    else
        %plot(thetapoints*180/pi,Mpoints,'.','Color','k')
    end
    xlabel('Angle (deg)')
    ylabel('Torque (Nm)')
    title('Desired Torque-Angle Curve')
    set(gcf,'color','w');
    ylim([-50,180]);
    xlim([-25,25]);
    set(gca,'XAxisLocation','origin','YAxisLocation','origin');
    

    % PLOTTING OPTIONS
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

    % IMPORT STUFF
    %Import Dorsalflexion from the Bovi gait library for 70kg adult in flat walking
    load('Human_ankle_moment')
    load('IMPORTS/Human_ankle_rot')
    %Import Plantarflexioin data from VSPA Prosthetic
    load('IMPORTS/Primary_data.mat')
    %Import TA for a Plastic AFO
    load('IMPORTS/PlasticAFO')
    conversions()
    load('inputs/conversions.mat')

    % CHECKING FOR USER ERROR (NOT BULLET PROOF)
    if((plot_all+plot_select)>1)
        disp('Only choose 1 plotting method')
        return
    end

    % INITIALIZE
    s_lin = [];

    % SIMULATE DUAL CAM
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
        equilibrium_angle = 0.02;
        scalefactor = 1;
        [~,equilibrium_index] = min(abs(M)); %FIND INDEX FOR WHEN M == 0 (OR CLOSE)
    end

    % SPRING SELECTION
    [titanium_data,gamma_titan] = spring_selection(spring,x_center_min,x_center_max,1);

    % CAM GENERATION FROM FORWARD MODEL
    [x,y,r,psi,theta_cam,x_center,epsilon,mu,y_off,gamma,kdelt,stroke,work_M] = forwared_model_VSPA(theta_total,M,equilibrium_angle,titanium_data,dual_test);
    %USING MATH TO OFFSET
    [curve_x curve_y] = offsetCamCurve(x,y,r,psi,roller_radius,'offset','diff');

    % CAM CURVE SELF INTERSECTIONS?
    [intersections] = check_intersections(curve_x,curve_y,theta_total);
    if(isempty(intersections)==0)
        rad2deg(theta_total(intersections))
        return
    end

    % CHECK IF SPRING WILL YIELD
    if(max(gamma)) > polyval(gamma_titan,(x_center*1000))
        pointBreak = find(gamma > polyval(gamma_titan,(x_center*1000)));

        pointBreak_p = find(pointBreak<length(theta_total)/2);
        pointBreak_d = find(pointBreak>length(theta_total)/2);
        if ~isempty(pointBreak_d)
            pointBreak_d=rad2deg(theta_total(pointBreak(pointBreak_d(1))));
        else
            pointBreak_d = inf;
        end
        if ~isempty(pointBreak_p)
            pointBreak_p=rad2deg(theta_total(pointBreak(pointBreak_p(end))));
        else
            pointBreak_p= inf;
        end

        %disp (strcat('Warning: spring may yield at :',num2str(pointBreak_d),' in dorsiflexion and :',num2str(pointBreak_p),' in plantarflexion'))
    end

    % Check if psi is a function (Leading Hypothesis is that this is possible, but will lock spring and produce max stiffness)
    %Doesn't use psi because we are evalating for the offset curve and not the progenitor curve
    psi_offset_err_ = atan(curve_y./curve_x);
    if min(diff(psi_offset_err_))<=0
        disp('Warning: offset cam curve is not a function in psi which may lock spring and produce peak stiffness')
    end

    % CHECK IF MATH EXPLOITS THETA_CAM TO PRODUCE INFINITE STIFFNESS
    for i = 2:length(theta_cam)
        if((theta_cam(i)-theta_cam(i-1))<=0)
            disp('Error: Cam has unfeasable geometry')
            return
        end
    end

    % PLOT THE CAM PROFILES
    figure(4)
    query_indices = [];
    for i=1:length(theta_query)
        query_index = find(abs(theta_inv(1,:)-deg2rad(theta_query(i)))<deg2rad(0.02));
        query_indices = [query_indices;query_index(1)];
    end

    [x_circle, y_circle] = plotCircle(r0,0, roller_radius);
    hold on;
    plot(curve_x,curve_y,'k','LineStyle','-','Linewidth',1)%[0, 0.75, 0.75] [229,154,161]./255
    plot(x,y, 'Color',[229,154,161]./255 ,'LineStyle','--','Linewidth',2)%[0, 0.75, 0.75] [229,154,161]./255
    plot(x_circle,y_circle,'b')
    scatter(curve_x(intersections), curve_y(intersections), 'MarkerEdgeColor', 'red','MarkerFaceColor', 'none', 'Marker', 'o')
    plot(curve_x(query_indices),curve_y(query_indices),'x','Linewidth',5,'markers',15,'Color',[0 1 0])
    axis equal
    xlabel('(meters)'); ylabel('(meters)'); title('Cam Profile')
    legend('Offset','Surface')
    legend boxoff
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',1);

    % UPDATING MODEL TO CORRELATE WITH TESTING DATA
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
            spring = 'stiff';
            [titanium_data,gamma_titan] = spring_selection(spring,x_center_min,x_center_max,1);
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

    % SIMULATING AVAILABLE STIFFNESS RANGE (INVERSE MODEL)
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
    %x_center_inv = x_center*m2mm;
    ktranslational = polyval(titanium_data,x_center_inv);
    x_center_inv = x_center_inv*mm2m; %ToDo (maybe didn'td do this for previously generated cams)

    % Inverse Model
    [theta_inv,delta_inv,M_ankle,theta_cam_inv,Angles,Moments,F_cam_3,ROM_index,cam_angles] = inverse_model_VSPA(preload_inv,kdelt,x_center,x_center_inv,ktranslational,epsilon,mu,y_off,r,psi,gamma,dual_test);

    % Plot Inverse Model
    if 0
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
    axis([-40,40,-30,150])
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
    end

% EXPORT CAM TO SOLIDWORKS
if(strcmp(export,'yes'))
    if(strcmp (cam,'rotary'))
        %length(curve_x)
        %[curve_points] = Matlab2Solidworks(curve_x,curve_y);
        [curve_points] = Matlab2Solidworks(curve_y,curve_x);
        %length(curve_points)
        writematrix(curve_points/1000, strcat('outputs/',char(foot),'_curve_rotary_ez.csv'))
        writematrix( M,strcat('outputs/',char(foot),'_moment_rotary_ez.csv'))
    else
        %length(curve_x)
        [curve_points] = Matlab2Solidworks(curve_x,curve_y);
        %[curve_points] = Matlab2Solidworks(curve_y,curve_x);
        %length(curve_points)
        dlmwrite(strcat('outputs/',char(foot),'_curve_FEA_2k.txt'), curve_points, '\t')
        dlmwrite(strcat('outputs/',char(foot),'_moment_FEA_2k.txt'), M, '\t')
    end
end
end



%% TESTING A CAM FROM TXT THAT WAS NOT GENERATED ABOVE
if(different_cam)
    %import_single_cam()
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
    plot(rad2deg(theta),M_data,'x','Linewidth',2,'markers',10,'Color',[1 0 0])
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
    fig_format('Ankle Angle ({\circ})','Work (Joules)','Energy Storage in VSO')
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
axis([plantar_max dorsi_max -50 0])

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
        ["Ankle ROM [Dorsi, Plantar]: [" + string(dorsi_max)+","+string(plantar_max)+']']};
    msgbox(output,"Simulation Results");
end
toc