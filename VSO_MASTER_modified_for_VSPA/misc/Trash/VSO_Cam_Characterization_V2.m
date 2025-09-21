% Nikko Van Crey
%nikkovc@umich.edyu
%8479179990
% Neurobionics Lab
clear
%close all

%% Notes
%line below is kinda sketchy
%torqueJIM_interp = rmmissing(torqueJIM_interp);

%% Configurables
cam5 = 0;
cam3 = 1; %least stiff
cam1 = 0; %most stiff
sync_extreme = 1;
plot_ankle_angle = 0;
plot_continuous_delta = 0;
remove_hysteresis = 1;
equalibrium = 0;

%% Load Data
primary_slider=0.4997;

if(cam5)
    plantar_first = 0;
    dorsi_first = 1;
    time_offset = 7.50255;
    load('JIM/10_12_22/cam5_ztl_natalieshoe.mat')
    cam = cam5_ztl_natalieshoe;
    %slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x98"};
    slider = {'x0' "x50" "x98"};
    %slider_perc = [0 9.92 19.9 29.4 40.03 49.97 59.97 70.02 80.05 90 98.02]./100;
    slider_perc = [0 49.97 98]./100;
    cam_folder = 'JIM/10_12_22/cam5/';
end

if(cam3)
    time_offset = 7.50255; %I don't understand why I put this in the code
    plantar_first = 1;
    dorsi_first = 0;
    load('JIM/3_10_22/cam3/cam3.mat')
    cam = cam3;
    %slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x96"};
    %slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9 96.06]./100;
    slider = {'x0' "x50" "x90"};
    slider_perc = [0 49.84 90];
    %slider = {'x50'};
    cam_folder = 'JIM/3_10_22/cam3/';
end

if(cam1)
%     load('JIM/3_10_22/cam1/cam1.mat')
%     slider = {'x0' 'x10' "x40" "x60"};
%     slider_perc = [0 10 40 60];
%     cam_folder = 'JIM/3_10_22/cam1/';

    %-------------------

%     load('JIM/4_21_22/cam1_titanium/cam1.mat')
%     slider = {'x0' "x20" "x40" "x60" "x80" "x95"};
%     slider_perc = [0 20 40 60 80 95];
%     cam_folder = 'JIM/4_21_22/cam1_titanium/';

    %-------------------

    load('JIM/4_21_22/cam1_aluminum/cam1.mat')
    slider = {'x0' "x20" "x40" "x60" "x80" "x95"};
    slider_perc = [0 20 40 60 80 95];
    cam_folder = 'JIM/4_21_22/cam1_aluminum/';
    %----------------------
    
    cam = cam1;
end

%% Initialize
%Colors
color_end = [255 0 0]./255;
color_start = [255 230 230]./255;
q = 6;
color_ramp = 230/q;
colors_ramp_2 = 120/(length(slider)-q);

kdelt_dorsi = [];
kdelt_plantar = [];
kankle_dorsi = [];

%% MAIN
for i=1:length(slider)
    slope = 0;
    if(i<=q)
        color_beginning = color_start+[0 -color_ramp*i -color_ramp*i]./255;
        colors = color_beginning;
    else
        -colors_ramp_2*(i-q)/255;
        colors_end = color_beginning+[-colors_ramp_2*(i-q) 0 0]./255;
        colors = colors_end;
    end
    %% Import, Filter, and Interpolate
    %VSO
    %test = xlsread('x50.csv');
    test = xlsread(string(strcat(cam_folder,strcat(slider{i},'.csv'))));
    timeVSO = test(3:end,1);
    angleVSO = -1*test(3:end,2);
    angleVSO_lowpass = lowpass(angleVSO,0.1);
    
    %JIM
    timeJIM = cam.(slider{i}).timeJIM;
    angleJIM = rad2deg(cam.(slider{i}).angleJIM);
    torqueJIM = cam.(slider{i}).torque;
    
    %SYNC With Max Load
    if(sync_extreme)
        index_max_JIM = find(angleJIM==max(angleJIM));
        time_max_JIM = timeJIM(index_max_JIM);
        index_max_VSO = find(angleVSO_lowpass==max(angleVSO_lowpass));
        time_max_VSO = timeVSO(index_max_VSO);
        time_shift = time_max_VSO-time_max_JIM;
        startVSO = min(find(timeVSO>time_shift));
        timeVSO = timeVSO(startVSO:end)-timeVSO(startVSO);
        angleVSO_lowpass = angleVSO_lowpass(startVSO:end);
    end
    
    %Filtering and Interpolating
    angleJIM_interp = interp1(timeJIM,angleJIM,timeVSO);
    torqueJIM_interp = interp1(timeJIM,torqueJIM,timeVSO);
    %angleJIM_interp = rmmissing(angleJIM_interp);
    torqueJIM_interp = rmmissing(torqueJIM_interp);
%     figure(87)
%     hold on
%     plot(angleJIM_interp,torqueJIM_interp)
    torqueJIM_lowpass = lowpass(torqueJIM_interp,0.025); %0.01
    
    %% MAIN
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
    
    if(remove_hysteresis)
        index_max_plantar = find(torqueJIM_lowpass==min(torqueJIM_lowpass));
        index_max_dorsi = find(torqueJIM_lowpass==max(torqueJIM_lowpass));
        for h = index_max_plantar:length(torqueJIM_lowpass)
            if(abs(torqueJIM_lowpass(1)-torqueJIM_lowpass(h))<0.005) %0.005
                index_equalibrium = h;
                break
            end
        end
        if(plantar_first)
            [M, index_equalibrium] = min(abs(timeVSO-time_offset));
            index_loading = [index_max_plantar:-1:1 index_equalibrium:index_max_dorsi];
            index_loading_planatar = [index_max_plantar:-1:1];
            index_loading_dorsi = [index_equalibrium:index_max_dorsi];
            index_unloading_plantar = [index_max_plantar:-1:1:index_equalibrium];
            index_unloading_dorsi = [index_max_dorsi:1:length(torqueJIM_lowpass)];
            energy_plantar_load = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_loading_planatar)),torqueJIM_lowpass(index_loading_planatar))));
            energy_dorsi_load = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_loading_dorsi))),abs(torqueJIM_lowpass(index_loading_dorsi))));
            energy_plantar_unload = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_unloading_plantar)),torqueJIM_lowpass(index_unloading_plantar))));
            energy_dorsi_unload = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_unloading_dorsi))),abs(torqueJIM_lowpass(index_unloading_dorsi))));
        end
        if(dorsi_first)
            [M, index_equalibrium] = min(abs(timeVSO-time_offset));
            index_loading = [index_max_plantar:-1:index_equalibrium 1:index_max_dorsi];
            index_loading_planatar = [index_max_plantar:-1:index_equalibrium];
            index_loading_dorsi = [1:index_max_dorsi];
            index_unloading_plantar = [index_max_dorsi:-1:1:index_equalibrium]; %might be troublesome depending on sign of equilibrium angle
            index_unloading_dorsi = [index_max_plantar:1:length(torqueJIM_lowpass)];
            energy_plantar_load = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_loading_planatar)),torqueJIM_lowpass(index_loading_planatar))));
            energy_dorsi_load = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_loading_dorsi))),abs(torqueJIM_lowpass(index_loading_dorsi))));
            energy_plantar_unload = abs(min(cumtrapz(deg2rad(angleJIM_interp(index_unloading_plantar)),torqueJIM_lowpass(index_unloading_plantar))));
            energy_dorsi_unload = max(cumtrapz(abs(deg2rad(angleJIM_interp(index_unloading_dorsi))),abs(torqueJIM_lowpass(index_unloading_dorsi))));
        end
    end

    %% Plots
    %Torque Angle
    figure(2)
    hold on
    %plot(angleJIM,torqueJIM,'Color',colors,'linewidth',1)
    %plot(angleJIM_interp,torqueJIM_lowpass,'Color',colors,'linewidth',1)
    if(slider_perc(i)==primary_slider)
        arrived = 1;
        plot(angleJIM_interp(index_loading)+equalibrium,torqueJIM_lowpass(index_loading),'--','Color',colors,'linewidth',2)
    else
        plot(angleJIM_interp(index_loading)+equalibrium,torqueJIM_lowpass(index_loading),'Color',colors,'linewidth',2)
    end
    %plot(angleJIM_interp,torqueJIM_lowpass,'Color','k','linewidth',2)
    xlabel('Ankle Angle [\circ]'); ylabel('Ankle Torque [Nm]');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    
    if(plot_ankle_angle)
        figure(10)
        hold on
        plot(timeJIM,angleJIM)
        %plot(timeVSO, angleVSO_lowpass)
        plot(timeVSO, angleJIM_interp)
        xlabel('Time [sec]'); ylabel('Angle [Deg]'); title('');
        set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
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
    
end

%Series Stiffness
figure
hold on
plot(slider_perc*100,kdelt_dorsi,'linewidth',3)
plot(slider_perc*100,kdelt_plantar,'linewidth',3)
mean(kdelt_dorsi)
mean(kdelt_plantar)
xlabel('Slider Position [%]'); ylabel('Series Stiffness [Nm/rad]'); title('');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('dorsiflexion','platarflexion')
legend boxoff


kankle_dorsi
kankle_plantar

