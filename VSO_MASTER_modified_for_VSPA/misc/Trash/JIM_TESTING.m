% Nikko Van Crey
%nikkovc@umich.edyu
%8479179990
% Neurobionics Lab
clear
close all
close all hidden

%% Make sure to update BLOCK 1-4 for each cam/test

%% Notes
%line below is kinda sketchy
%torqueJIM_interp = rmmissing(torqueJIM_interp);

%% BLOCK 1: TESTING CONFIGURATION
%IMPORTANT
testing_time = 15; %time typed in JIM, not deduced from arrays in post

%Which JIM DATA
stiff = 0;
stiff_shoe = 0;
feather = 0;
final = 1;

%Plotting Color
red = 0;
blue = 0;
black = 1;

%Which Prototype
VSO = 1;

%% BLOCK 2: CHOOSE TA PARAMETERS
%primary_slider=0.4997;
primary_slider=0.5;

%% BLOCK 3: CONFIGURABLES
rmse_calc = 0;
filters = 0; %shows plot of original data, interpolation, and lowpass filter on same plot
sync_extreme = 1; %uses point of largest ankle deflection to sync JIM and VSO encoders
plot_ankle_angle = 0;
plot_continuous_delta = 0; %plots series compliance as a continuous function for each slider position rather than reporting the average value
remove_hysteresis = 0; %removes the unloading lines from the visuals
message_box = 1;


%% BLOCK 1: LOAD TESTING DATA


%DUAL CAM C2
% load('DATA/JIM/12_1_22/DC_C2.mat')
% cam = DC_C2;
% cam_folder = 'DATA/JIM/12_1_22/DC_C2/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).

%DUAL CAM C1
% load('DATA/JIM/11_2_22/DC_C1.mat')
% cam = test;
% cam_folder = 'DATA/JIM/11_2_22/DC_C1/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).


%CAM4
if(stiff_shoe)
    load('DATA/JIM/10_26_22/cam4_stiff_natalieshoe.mat')
    cam = cam4_stiff_natalieshoe;
    cam_folder = 'DATA/JIM/10_26_22/cam4/';
    plantar_first = 0; %1 if plantarflexion was loaded first (toe facing away from computer)
    dorsi_first = 1; %1 if dorsiflexion was loaded first (toe facing towards from computer)
    side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
    slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90"};
    slider_perc = [0 10.01 19.97 29.97 39.95 49.95 59.97 70.07 80.04 90.01]./100;
    equilibrium = 2;
end

%CAM5
% load('DATA/JIM/10_12_22/cam5_ramtech_natalieshoe.mat')
% cam = cam5_ramtech_natalieshoe;
% cam_folder = 'DATA/JIM/10_12_22/cam5/';
% plantar_first = 0; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 1; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = 1;
% slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90"};
% slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9]./100;
% equilibrium = 2;

% CAM5
% load('DATA/JIM/10_21_22/cam5_ztl_natalieshoe.mat')
% cam = cam5_cheap_natalieshoe;
% cam_folder = 'DATA/JIM/10_21_22/cam5_ztl/';
% plantar_first = 0; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 1; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = 1;
% slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90"};
% slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9]./100;
% equilibrium = 2;


%CAM3 (Goes with CAM3 Archive File)
if(stiff)
    load('DATA/JIM/3_10_22/cam3/cam3.mat')
    cam = cam3;
    cam_folder = 'DATA/JIM/3_10_22/cam3/';
    plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
    dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
    side = 1;
    slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x96"};
    slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9 96.06]./100;
    equilibrium = 0;
end

%Featherweight
if(feather)
    load('DATA/JIM/3_1_23/cam_feather/cam_feather.mat')
    cam = cam_feather;
    cam_folder = 'DATA/JIM/3_1_23/cam_feather/';
    plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
    dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
    side = -1;
    slider = {'x0' "x50" "x97"};
    slider_perc = [0 49.95 96.98]./100;
%     slider = {"x50"};
%     slider_perc = [49.95]./100;
%     slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x97"};
%     slider_perc = [0 10.01 19.97 29.97 39.95 49.95 59.97 70.07 80.04 90.01 96.98]./100;
    equilibrium = 0;
end

%Final
if(final)
    cam_blue_1 = 0;
    cam_blue_4 = 1;
    if(cam_blue_1)
        load('DATA/JIM/7_19_23/cam_blue_1_22.mat')
        cam = cam_blue_1_22;
        cam_folder = 'DATA/JIM/7_19_23/';
        plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
        dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
        side = -1;
        % slider = {'x0' "x50" "x99"};
        % slider_perc = [0 50 99]./100;
%         slider = {"x50"};
    %     slider_perc = [50]./100;
        slider = {'x0' 'x10' 'x20' "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x99"};
        slider_perc = [0 10 20 30 40 50 60 70 80 90 99]./100;
        equilibrium = 0;
    end
    
    if(cam_blue_4)
        load('DATA/JIM/7_17_23/cam_blue_4.mat')
        cam = cam_blue_4;
        cam_folder = 'DATA/JIM/7_17_23/';
        plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
        dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
        side = -1;
%         slider = {'x0' "x50" "x99"};
%         slider_perc = [0 50 99]./100;
    %     slider = {"x50"};
    %     slider_perc = [50]./100;
        slider = {'x0' 'x10' "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x99"};
        slider_perc = [0 10 30 40 50 60 70 80 90 99]./100;
        equilibrium = 0;
    end
end

%Breaking Bearings
% load('DATA/JIM/3_26_23/BreakBearings.mat')
% cam = BreakBearings;
% cam_folder = 'DATA/JIM/3_26_23';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'X12','X14','X17','X20'};
% equilibrium = 0;
% testing_time = 15;

%Dual Cam Testing
% load('DATA/JIM/3_29_23/PrelimDualCam.mat')
% cam = PrelimDualCam;
% cam_folder = 'DATA/JIM/3_29_23';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'x1','x2','x3','x4','x5'};
% %slider = {'x1'};
% equilibrium = 2.5;
% testing_time = 15;

%Dual Cam Ramtech full testing
% load('DATA/JIM/4_5_23/dualCamRamtech.mat')
% cam = dualCamRamtech;
% cam_folder = 'DATA/JIM/4_5_23/dualCamRamtech/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'x0','x10','x20','x30','x50','x60','x70'};
% slider_perc = [0 10 20 30 50 60 70]./100;
% % slider = {'x0','x30','x60'};
% % slider_perc = [0 30 60]./100;
% % slider = {'x60'};
% % slider_perc = [60]./100;
% equilibrium = 2.2;
% testing_time = 15;


%Dual cam hysteresis testing
% load('DATA/JIM/12_21_22/dualdebugC2.mat')
% cam = dualdebugC2;
% cam_folder = 'DATA/JIM/12_21_22';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% % slider = {'xswitch' 'xswitch2' 'xsinglecamc2'};
% slider = {'xswitch' 'xswitch2'};
% equilibrium = 0;
% testing_time = 15;

%Hashim Data%
% load('DATA/JIM/Hashim/DESR_N.mat')
% cam = DESR_N;
% cam_folder = 'DATA/JIM/Hashim';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'x33'};
% equilibrium = 0;
% testing_time = 11;


%specific energy
%77-J/kg for Zachs spring

%% BIOROB

% %Energy path Ramtech full testing
% load('DATA/JIM/1_19_24/energy_path_011924.mat')
% cam = energy_path;
% cam_folder = 'DATA/JIM/1_19_24/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% % slider = {'x0','x10','x20','x30','x40','x50','x70','x80','x90','x99d5'};
% % slider_perc = [0 10 20 30 40 50 70 80 90 99d5]./100;
% slider = {'x0','x50','x99d5'};
% slider_perc = [0 50 99d5]./100;
% % slider = {'x60'};
% % slider_perc = [60]./100;
% equilibrium = 0;
% testing_time = 15;

%% Energy Path with Backlash
% dual_cam = 1;
% load('1_30_24/energy_path013024.mat')
% cam = energypath130;
% cam_folder = '1_30_24/energy_path_1_30_24/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'x0','x10','x20','x30','x40','x50','x70','x80','x90','x100'};
% slider_perc = [0 10 20 30 40 50 70 80 90 100]./100;
% % slider = {'x0','x50','x100'};
% % slider_perc = [0 50 100]./100;
% % slider = {'x50'};
% % slider_perc = [50]./100;
% equilibrium = -0.403313533453571;
% equilibrium_blue = equilibrium;
% testing_time = 15;
% log_index = 2;

%% CAM 3 Blue

% load('DATA/JIM/1_30_24/energy_path013024.mat')
% cam = energypath130;
% cam_folder = 'DATA/JIM/1_30_24/energy_path_1_30_24/';
% plantar_first = 1; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 0; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = -1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% slider = {'x0','x10','x20','x30','x40','x50','x70','x80','x90','x100'};
% % slider_perc = [0 10 20 30 40 50 70 80 90 100]./100;
% slider = {'x0','x50','x100'};
% slider_perc = [0 50 100]./100;
% % slider = {'x60'};
% % slider_perc = [60]./100;
% equilibrium = 0;
% testing_time = 15;

%%
% load('DATA/JIM/1_22_24/cam_blue_3_StiffMount.mat')
% cam = cam3blueStiffMount;
% cam_folder = 'DATA/JIM/1_22_24/stiffmount/';
% plantar_first = 0; %1 if plantarflexion was loaded first (toe facing away from computer)
% dorsi_first = 1; %1 if dorsiflexion was loaded first (toe facing towards from computer)
% side = 1; %-1 for lateral and positive 1 for medial (local VSO reference frame).
% % slider = {'x0','x10','x20','x30','x40','x50','x70','x80','x90','x99d5'};
% % slider_perc = [0 10 20 30 40 50 70 80 90 99d5]./100;
% slider = {'x0','x50','x99d5'};
% slider_perc = [0 50 99d5]./100;
% % slider = {'x60'};
% % slider_perc = [60]./100;
% equilibrium = 0;
% testing_time = 15;


%% BLOCK 4: TESTING INFO
%slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x98"};
% slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x96"};
% slider = {'x0' "x50" "x96"};
% slider = {'x0' "x50" "x90"};
%slider = {'x0' 'x10' "x20" "x30"};
%slider = {"x20"};
%slider_perc = [0 9.92 19.9 29.4 40.03 49.97 59.97 70.02 80.05 90 98.02]./100;
% slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9 96.06]./100;
% slider_perc = [0 49.97 98]./100;
% slider_perc = [20]./100;
% slider_perc = [0 49.97 90]./100;
%slider_perc = [98]./100;

%% CHECKING FOR USER ERROR (NOT BULLETPROOF)
if((plantar_first*dorsi_first)==1)
    disp('Only choose 1 (plantar_first or dorsi_first')
    return
end


%% Initialize
%Colors
if(red)
    color_end = [255 0 0]./255;
    color_start = [255 230 230]./255;
    q = 2;
    color_ramp = 230/q;
    colors_ramp_2 = 120/(length(slider)-q);
end

if(blue)
    color_end = [25,25,112]./255;
    color_start = [175,238,255]./255;
    q = 6;
    color_ramp = 153/q;
    colors_ramp_2 = 120/(length(slider)-q);
end

kdelt_dorsi = [];
kdelt_plantar = [];
kankle_dorsi = [];

work_loading_dorsi = [];
work_loading_plantar = [];
work_unloading_dorsi = [];
work_unloading_plantar = [];

%sign of VSO ankle angle relative to JIM angle changes depending on VSO oritentation
if(plantar_first)
    convention = -1;
else
    convention = 1;
end


%% MAIN
for i=1:length(slider)
    slope = 0;
    if(red)
        if(i<=q)
            color_beginning = color_start+[0 -color_ramp*i -color_ramp*i]./255;
            colors = color_beginning;
        else
            colors_end = color_beginning+[-colors_ramp_2*(i-q) 0 0]./255;
            colors = colors_end;
        end
    end
    
    if(blue)
        if(i<=q)
            color_beginning = color_start+[-color_ramp*i -color_ramp*i 0]./255;
            colors = color_beginning;
        else
            colors_end = color_beginning+[0 0 -colors_ramp_2*(i-q)]./255;
            colors = colors_end;
        end
    end
    if(black)
        colors = [0 0 0]; 
    end
    %% Filter, and Interpolate
    %VSO
    time_midtest_equilibrium = testing_time/2;
    if(VSO)
        time_midtest_equilibrium = testing_time/2;
        test = xlsread(string(strcat(cam_folder,strcat(slider{i},'.csv'))));
        timeVSO = test(3:end,1);
        %time_midtest_equilibrium = max(timeVSO)/2; %Trying to find equilibrium after dorsiflexion unloading and before plantar loading, which happens near the midpoint of testing
        angleVSO = side*convention*test(3:end,2);
        max(angleVSO)
        figure(16)
        plot(angleVSO)
        %angleVSO_lowpass = lowpass(angleVSO,0.1);
        %angleVSO_lowpass = lowpass(angleVSO,6,30); % Used in paper
        angleVSO_lowpass = lowpass(angleVSO,6,1/timeVSO(2));
        %angleVSO_lowpass = angleVSO;
        %angleVSO_lowpass = lowpass(angleVSO,0.1);
        if(plot_ankle_angle)
            figure(6)
            plot(timeVSO,angleVSO_lowpass)
        end
    end
    
    %JIM
    timeJIM = cam.(slider{i}).timeJIM;
    angleJIM = rad2deg(cam.(slider{i}).angleJIM);
    max(angleJIM)
    torqueJIM = cam.(slider{i}).torque;
    
    %SYNC With Max Load
    if(sync_extreme && VSO)
        index_max_JIM = find(angleJIM==max(angleJIM));
        time_max_JIM = timeJIM(index_max_JIM);
        index_max_VSO = find(angleVSO_lowpass==max(angleVSO_lowpass));
        time_max_VSO = timeVSO(index_max_VSO);
        time_shift = time_max_VSO-time_max_JIM;
        startVSO = min(find(timeVSO>abs(time_shift)));
        timeVSO = timeVSO(startVSO:end)-timeVSO(startVSO);
        angleVSO_lowpass = angleVSO_lowpass(startVSO:end);
    end
    
    if(VSO)
        %Filtering and Interpolating
        angleJIM_interp = interp1(timeJIM,angleJIM,timeVSO);
        torqueJIM_interp = interp1(timeJIM,torqueJIM,timeVSO);
    end


    %LowPass Filter
%     torqueJIM_lowpass = torqueJIM_interp;
%     torqueJIM_lowpass = lowpass(torqueJIM_interp,9,830); %Used in Paper
%     torqueJIM_lowpass = lowpass(torqueJIM_interp,9,830);
    torqueJIM_lowpass = lowpass(torqueJIM_interp,3,length(torqueJIM_interp)/testing_time);
    
    %FILTERS
    if(filters)
        figure(11)
        hold on
        plot(angleJIM,torqueJIM, 'linewidth', 6)
        plot(angleJIM_interp,torqueJIM_interp, 'linewidth', 2)
        plot(angleJIM_interp,torqueJIM_lowpass, 'linewidth', 4)
        legend('orig','interp','lowpass')
        title('Filtering and Interpolation')
    end
    
    %% MAIN
    if(VSO)
        %Series Compliance
        delta = angleJIM_interp-angleVSO_lowpass;
        delta_dorsi = max(angleJIM)-max(angleVSO_lowpass);
        delta_plantar = abs(min(angleJIM))-abs(min(angleVSO_lowpass));
        %Series Stiffness
        delta_rad = deg2rad(delta);
        kdelt_plantar(i) = abs(min(torqueJIM_interp)./deg2rad(delta_plantar));
        kdelt_dorsi(i) = max(torqueJIM_interp)./deg2rad(delta_dorsi);
        kankle_dorsi(i) = max(torqueJIM_interp)./deg2rad((max(angleJIM_interp)));
        kankle_plantar(i) = abs(min(torqueJIM_interp)./deg2rad((min(angleJIM_interp))));
    end
    kdelt_dorsi_avg = mean(kdelt_dorsi);
    kdelt_plantar_avg = mean(kdelt_plantar);
    
    %DIVDE LOADING AND UNLOADING
    index_max_plantar = find(torqueJIM_lowpass==min(torqueJIM_lowpass));
    index_max_dorsi = find(torqueJIM_lowpass==max(torqueJIM_lowpass));
    for h = index_max_plantar:length(torqueJIM_lowpass)
        if(abs(torqueJIM_lowpass(1)-torqueJIM_lowpass(h))<0.005) %0.005
            index_equilibrium = h;
            break
        end
    end
    if(plantar_first)
        [M, index_equilibrium] = min(abs(timeVSO-time_midtest_equilibrium));
        index_loading = [index_max_plantar:-1:1 index_equilibrium:index_max_dorsi];
        index_loading_plantar = [index_max_plantar:-1:1];
        index_loading_dorsi = [index_equilibrium:index_max_dorsi];
        index_unloading_plantar = [index_max_plantar:-1:1:index_equilibrium];
        index_unloading_dorsi = [index_max_dorsi:1:length(torqueJIM_lowpass)];
        energy_plantar_load = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_loading_plantar)),torqueJIM_lowpass(index_loading_plantar))));
        energy_dorsi_load = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_loading_dorsi))),abs(torqueJIM_lowpass(index_loading_dorsi))));
        energy_plantar_unload = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_unloading_plantar)),torqueJIM_lowpass(index_unloading_plantar))));
        energy_dorsi_unload = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_unloading_dorsi))),abs(torqueJIM_lowpass(index_unloading_dorsi))));
    end
    if(dorsi_first)
        [M, index_equilibrium] = min(abs(timeVSO-time_midtest_equilibrium));
        index_loading = [index_max_plantar:-1:index_equilibrium 1:index_max_dorsi];
        index_loading_plantar = [index_max_plantar:-1:index_equilibrium];
        index_loading_dorsi = [1:index_max_dorsi];
        index_unloading_dorsi = [index_max_dorsi:-1:1:index_equilibrium]; %might be troublesome depending on sign of equilibrium angle
        index_unloading_plantar = [index_max_plantar:1:length(torqueJIM_lowpass)];
        energy_plantar_load = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_loading_plantar)),torqueJIM_lowpass(index_loading_plantar))));
        energy_dorsi_load = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_loading_dorsi))),abs(torqueJIM_lowpass(index_loading_dorsi))));
        energy_plantar_unload = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_unloading_plantar)),torqueJIM_lowpass(index_unloading_plantar))));
        energy_dorsi_unload = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_unloading_dorsi))),abs(torqueJIM_lowpass(index_unloading_dorsi))));
    end

    if(remove_hysteresis)
        index_plot = index_loading;
    else
        index_plot = 1:length(angleJIM_interp);
    end
    
 
 %% Hysteresis Calculation
    work_loading_dorsi = [work_loading_dorsi; max(abs(cumtrapz(deg2rad(angleJIM_interp(index_loading_dorsi)+equilibrium),torqueJIM_lowpass(index_loading_dorsi))))];
    work_loading_plantar = [work_loading_plantar; max(abs(cumtrapz(deg2rad(angleJIM_interp(index_loading_plantar)+equilibrium),torqueJIM_lowpass(index_loading_plantar))))];
    work_unloading_dorsi = [work_unloading_dorsi; max(abs(cumtrapz(deg2rad(angleJIM_interp(index_unloading_dorsi)+equilibrium),torqueJIM_lowpass(index_unloading_dorsi))))];
    work_unloading_plantar = [work_unloading_plantar; max(abs(cumtrapz(deg2rad(angleJIM_interp(index_unloading_plantar)+equilibrium),torqueJIM_lowpass(index_unloading_plantar))))];
    efficiency_dorsi = work_unloading_dorsi./work_loading_dorsi;
    efficiency_plantar = work_unloading_plantar./work_loading_plantar;
    dorsi_energy_return = work_unloading_dorsi-work_loading_dorsi;
    plantar_energy_storage = work_loading_plantar-work_unloading_plantar;
    figure(3)
    hold on
    plot(angleJIM_interp(index_loading_dorsi)+equilibrium,torqueJIM_lowpass(index_loading_dorsi),'k','linewidth',2)
    plot(angleJIM_interp(index_unloading_dorsi)+equilibrium,torqueJIM_lowpass(index_unloading_dorsi),'b','linewidth',2)
    plot(angleJIM_interp(index_loading_plantar)+equilibrium,torqueJIM_lowpass(index_loading_plantar),'g','linewidth',2)
    plot(angleJIM_interp(index_unloading_plantar)+equilibrium,torqueJIM_lowpass(index_unloading_plantar),'c','linewidth',2)
    legend('loading dorsi','unloading dorsi','loading plantar','unloading plantar')
    xlabel('Ankle Angle (\circ)'); ylabel('Ankle Torque (Nm)');
    legend boxoff
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)

    
    %% Plots
    %Torque Angle
    figure(2)
    hold on
    %plot(angleJIM,torqueJIM,'Color',colors,'linewidth',1)
    %plot(angleJIM_interp,torqueJIM_lowpass,'Color',colors,'linewidth',1)
    %colors = [224, 224, 224]./255;
    dashed_primary = 0;
    if(dashed_primary)
        toggle = '--';
    else
        toggle = '-';
    end
    
    if(VSO)
        if(slider_perc(i)==primary_slider)
            arrived = 1;
            plot(angleJIM_interp(index_plot)+equilibrium,torqueJIM_lowpass(index_plot),toggle,'Color',colors,'linewidth',2)
        else
            plot(angleJIM_interp(index_plot)+equilibrium,torqueJIM_lowpass(index_plot),'Color',colors,'linewidth',2)
        end
    end
    %plot(angleJIM_interp,torqueJIM_lowpass,'Color','k','linewidth',2)
%     hFig = figure(2);
%     width = 575;
%     set(hFig, 'Position', [0 0 width 0.78*width])
    xlabel('Ankle Angle (\circ)'); ylabel('Ankle Torque (Nm)');
    set(gcf,'color','w'); set(gca,'FontSize',12); set(gca,'linewidth',2)
    %fig = gcf;
    %fig.PaperPositionMode = 'auto';
    
    
    if(plot_ankle_angle)
        figure(6)
        hold on
% %         plot(timeJIM,angleJIM, 'linewidth', 4)
%         plot(test(3:end,1), -angleVSO, 'linewidth', 2)
% %         plot(timeVSO, angleJIM_interp, 'linewidth', 2)
%         plot(timeVSO, angleVSO_lowpass, 'linewidth', 2)
        xlabel('Time [sec]'); ylabel('Angle [Deg]'); title('');
        set(gcf,'color','w'); set(gca,'FontSize',12); set(gca,'linewidth',2)
        legend('JIM1','VSO1','JIM2','VSO2','JIM3','VSO3')
    end
    
    if(plot_continuous_delta)
        %Series Compliance
        figure(11)
        hold on
        plot(timeVSO, delta, 'Linewidth',3)
        xlabel('Ankle Angle [deg]'); ylabel('Series Compliance [degrees]'); title('');
        set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
        legend(slider); legend box off;
    end
    

    
    
    %% RMSE Stuff 
    if(rmse_calc)
        load('Cam_Moments.mat')
        load('Cam_angles.mat')
        figure(5)
        %Angle Match the Model with Tested Angles
        A = Angles(:,i);
        M = Moments(:,i);
        MJ = torqueJIM_lowpass(index_plot);
        AJ = angleJIM_interp(index_plot);
        if(stiff)
            plot(A,M,'b')
            M_stiff = polyfit(A,M,50);
            A = [min(A):0.005:max(A)];
            M = polyval(M_stiff,A);
        end
        tf = A >min(AJ);
        M = M(tf);
        A = A(tf);
        tb = A < max(AJ);
        A = A(tb);
        M = M(tb);
        hold on
        plot(A,M,'k','linewidth',3)
        plot(AJ+equilibrium,MJ,'r','linewidth',3)
        %plot(torqueJIM_lowpass)
        %error
        error = 0;
        errorpt = 0;
        a = length(MJ)/(length(M));
        for x=1:length(MJ)-1/a
            residual(x) = (-M(fix(x/a)) + MJ(x));
            e = residual(x)^2;
            ep = abs((-M(floor(x/a)) + MJ(x)))  /abs(length(M));
            %standard error
            errormat(x,i) = ep;
            errorpt = errorpt + ep;
            error = error + e;
            error_percent(x) = 100*(residual(x)/MJ(x));
        end
        pizza = max(residual);
        rmse_vso(i) = sqrt(error/(length(MJ)-2));
        rmse_vso_percent(i) = mean(error_percent);
        %error2 = rmse(M,torqueJIM_lowpass) %Nikko
        %average error 
        errorpt = errorpt./length(MJ); 
        errormatpt(i) = errorpt;
    %     figure(6)
    %     hold on
    %     plot(errormat(:,i), 'linewidth', 2);
    %     set(gcf,'color','w');
    %     set(gca,'FontSize',18)
    %     set(gca,'linewidth',2)
    %     xlabel('Ankle Angle')
    %     ylabel('Ankle Torque Error (Nm)')
    %     title('Data Error');
    end
    
end
figure_size = get(gcf,'position');
set(gcf,'PaperPosition', figure_size/100)
print(gcf,'TA_Figure','-dpng','-r400')

if(rmse_calc)
    rmse_vso
    rmse_mean = mean(rmse_vso)
    rmse_std = std(rmse_vso)
end
%END OF HUGE WHILE LOOP

std_efficiency_dorsi = std(efficiency_dorsi*100)
std_efficiency_plantar = std(efficiency_plantar*100)

%Series Stiffness
if(VSO)
    figure(1)
    hold on
    plot(slider_perc*100,kdelt_dorsi,'linewidth',3)
    plot(slider_perc*100,kdelt_plantar,'linewidth',3)
    mean(kdelt_dorsi)
    mean(kdelt_plantar)
    xlabel('Slider Position [%]'); ylabel('Series Stiffness [Nm/rad]'); title('');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    legend('dorsiflexion','platarflexion')
    legend boxoff
end

%% Stiffness Dial CSV
VSO_stiffness = polyfit(slider_perc*100,kankle_dorsi,6);
num_pts = 10000;
slider_csv = 0:100/(num_pts-1):100;
stiffness_csv = polyval(VSO_stiffness,slider_csv);
%loadedAngle_plantarflexion_csv = -2.5*ones(1,length(stiffness_csv));
%loadedAngle_dorsiflexion_csv = 5*ones(1,length(stiffness_csv));
figure(4)
hold on
plot(slider_perc*100,kankle_dorsi,'linewidth',4)
plot(slider_csv,stiffness_csv)
axis([0 100 0 polyval(VSO_stiffness,100)])
%writematrix([slider_csv; stiffness_csv; theta_plantar_loaded; theta_dorsi_loaded],'VSO_blue_cam2.csv')


%% Message Box
if(VSO)
    if(message_box)
        output = {["Dorsi Stiffness [Nm/rad]: [" + string(min(kankle_dorsi))+" | "+string(max(kankle_dorsi))+']'],...
                ["Plantar Stiffness [Nm/rad]: [" + string(min(kankle_plantar))+" | "+string(max(kankle_plantar))+']'],...
                ["Performance [Dorsi | Plantar]: [" + string(max(kankle_dorsi)/min(kankle_dorsi))+" | "+string(max(kankle_plantar)/min(kankle_plantar))+']'],...
                ["Efficiency [Dorsi | Plantar]: [" + string(mean(efficiency_dorsi))+" | "+string(mean(efficiency_plantar))+']']};
        msgbox(output,"Simulation Results");
    end
end


%% Automate Figure Placement
% 
% figs =  findobj('type','figure');
% fig_autoplace(figs)
