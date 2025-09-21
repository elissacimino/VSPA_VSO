% Nikko Van Crey
%nikkovc@umich.edyu
%8479179990
% Neurobionics Lab
clear
%close all

%% Configurables
sync_extreme = 1;
continuous_delta = 0;
kdelt_cont = 0;

%% Load Data
load('VSO_Characterization.mat')

%% Initialize
slider = {'x0' 'x10' "x20" "x30" "x40" "x50" "x60" "x70" "x80" "x90" "x96"};
slider_perc = [0 9.82 19.82 29.81 39.82 49.84 59.82 69.8 79.79 89.9 96.06]./100;
%slider = {'x0' "x50" "x96"};
%slider = {'x80'};

%Colors
color_end = [255 0 0]./255;
color_start = [255 230 230]./255;
q = length(slider_perc);
color_ramp = 230/q;
colors_ramp_2 = 140/(9-q);

kdelt_dorsi = [];
kdelt_plantar = [];

%% MAIN
for i=1:length(slider)
    slope = 0;
    if(i<=q)
        color_beginning = color_start+[0 -color_ramp*i -color_ramp*i]./255;
        colors = color_beginning;
    else
        -colors_ramp_2*(i-q)/255
        colors_end = color_beginning+[-colors_ramp_2*(i-q) 0 0]./255;
        colors = colors_end
    end
    %% Import, Filter, and Interpolate
    %VSO
    %test = xlsread('x50.csv');
    test = xlsread(string(strcat(slider{i},'.csv')));
    timeVSO = test(3:end,1);
    angleVSO = -1*test(3:end,2);
    angleVSO_lowpass = lowpass(angleVSO,0.1);
    
    %JIM
    timeJIM = cam3.(slider{i}).timeJIM;
    angleJIM = rad2deg(cam3.(slider{i}).angleJIM);
    torqueJIM = cam3.(slider{i}).torque;
    
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
    torqueJIM_lowpass = lowpass(torqueJIM_interp,0.01); %0.01
    
    %% MAIN
    %Series Compliance
    delta = angleJIM_interp-angleVSO_lowpass;
    delta_dorsi = max(angleJIM)-max(angleVSO_lowpass);
    delta_plantar = abs(min(angleJIM))-abs(min(angleVSO_lowpass));
    %Series Stiffness
    delta_rad = deg2rad(delta);
%     kdelt_dorsi_cont(i) = max(torqueJIM_interp)./delta_rad(find(max(torqueJIM_interp)));
%     kdelt_plantar_cont(i) = abs(min(torqueJIM_interp)./delta_rad(find(min(torqueJIM_interp))));
    kdelt_dorsi(i) = max(torqueJIM_interp)./deg2rad(delta_dorsi);
    kdelt_plantar(i) = abs(min(torqueJIM_interp)./deg2rad(delta_plantar));
    delta_rad_lowpass = lowpass(delta_rad,0.01);
    kdelt = torqueJIM_interp./delta_rad_lowpass;
    kdelt_lowpass = lowpass(kdelt,0.01);
    noise = find(kdelt>2000);
    kdelt_noise_extract = kdelt;
    for n=1:length(noise)
        if(n>1)
            kdelt_noise_extract(noise(n)) = kdelt_noise_extract(noise(n)-1);
        end
    end
    %% Plots
    figure(2)
    hold on
    %plot(angleJIM,torqueJIM,'Color',colors,'linewidth',1)
    plot(angleJIM_interp,torqueJIM_lowpass,'Color',colors,'linewidth',1)
    %plot(angleJIM_interp,torqueJIM_lowpass,'Color','k','linewidth',2)
    xlabel('Ankle Angle [deg]'); ylabel('Torque [Nm]'); title('VSO JIM Characterization');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
     
    figure(10)
    hold on
    plot(timeJIM,angleJIM)
    plot(timeVSO, angleVSO_lowpass)
    plot(timeVSO, angleJIM_interp)
    xlabel('Time [sec]'); ylabel('Angle [Deg]'); title('');
    set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    
    if(continuous_delta)
        %Series Compliance
        figure(11)
        hold on
        plot(timeVSO, delta, 'Linewidth',3)
        xlabel('Ankle Angle [deg]'); ylabel('Series Compliance [degrees]'); title('');
        set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
        legend(slider); legend box off;
    end
    
    %Series Stiffnes
    if(kdelt_cont)
        figure(15)
        hold on
        plot(timeVSO,kdelt_noise_extract,'linewidth',3)
        axis([0,20,0,2000]) 
        xlabel('Time'); ylabel('Series Stiffness [Nm/rad]'); title('');
        set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
    end
    
end

%Series Stiffness
figure
hold on
plot(slider_perc*100,kdelt_dorsi,'linewidth',3)
plot(slider_perc*100,kdelt_plantar,'linewidth',3)
xlabel('Slider Position [%]'); ylabel('Series Stiffness [Nm/rad]'); title('');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('dorsiflexion','platarflexion')
legend boxoff

