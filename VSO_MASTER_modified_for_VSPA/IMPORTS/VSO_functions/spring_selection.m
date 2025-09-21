function [titanium_data,gamma_titan] = spring_selection(spring,x_center_min,x_center_max,plotting)
%     addpath('IMPORTS/functions')
addpath("Spring_Characterization/Max_charact_poweredVSPA/Titanium Spring Raw Instron Data/")
addpath("Spring_Designer/")
if(strcmp(spring,'FEA'))
    %FEA Only
    x_spring_data = x_center_max-[0, 10, 20, 30, 40, 50, 56];
    k_spring_data = [0.519, 0.647, 1.108, 1.663, 2.505, 3.987, 5.407]*10^6;
    gamma_FEA_peak = [0.061 0.066 0.059 0.065 0.068 0.064 0.058];
    gamma_titan = polyfit(x_spring_data,gamma_FEA_peak,5);
    titanium_data = polyfit(x_spring_data,k_spring_data,5);
end

if(strcmp(spring,'instron'))
    xlocs = [1:3,5:16];
    %         figure(2); hold on
    for i = 1:length(xlocs)
        xloc = xlocs(i);
        data = csvread(strcat('Prosthetic Ankle 1-9-18_',num2str(xlocs(i)),'.txt'),8);
        y_load = data(:,2);
        deflection = data(:,3);
        %             plot(deflection,y_load)
        k(i) = 1000*(y_load(round(end/2))-y_load(round(0.75*end)))/(deflection(round(end/2))-deflection(round(0.75*end)));
        %             plot(deflection(round(end/2)),y_load(round(end/2)),'kx','LineWidth',2)
        %             plot(deflection(round(0.75*end)),y_load(round(0.75*end)),'kx','LineWidth',2)
    end
    %         ylabel('y_load (N)')
    %         xlabel('Deflection (mm)')
    %         set(gcf,'color','w');
    %         set(gca,'FontSize',14);
    %         set(gca,'FontName','Times New Roman');

    p = polyfit(0:5:70,k,4)
    new_x = [0:0.5:x_center_max-x_center_min];
    for i = 1:length(new_x)
        corresponding_y(1,i) = interp1(0:70, polyval(p,0:70), new_x(i), 'linear');
    end
    k_spring_data = corresponding_y;
    x_spring_data = perc2mm(linspace(0,100,length(k_spring_data)),x_center_max,x_center_min);
    %titanium_data = polyfit(new_x,k_spring_data,5);

    gamma_FEA_peak = [0.061 0.066 0.059 0.065 0.068 0.064 0.058];
    gamma_titan = polyfit(x_center_max-[0, 10, 20, 30, 40, 50, 56],gamma_FEA_peak,5);
    titanium_data = polyfit(x_spring_data,k_spring_data,5);
end

if(strcmp(spring,'fixed'))
    x_spring_data = [x_center_max:-1:x_center_min];
    k_spring_data = 2.509*[ones(size(x_spring_data))]*10^6;
    titanium_data = polyfit(x_spring_data,k_spring_data,0);

    gamma_titan = 0.061;%polyfit(x_center_max-[0, 10, 20, 30, 40, 50, 56],gamma_FEA_peak,5);

end


% titanium_data = polyfit(x_spring_data,k_spring_data,3); %ToDo
if(plotting)
    figure(3)
    hold on
    perc = mm2perc(x_spring_data,x_center_max,x_center_min);
    plot(perc,k_spring_data./10^6)
    x_titan = (x_center_max:-1:x_center_min);
    k_titan = polyval(titanium_data,x_titan);
    %Percentage
    titan_percent = 0:(100/(length(x_titan)-1)):100;
    k_titan_percent = k_titan./10^6;

    plot(mm2perc(x_spring_data,x_center_max,x_center_min),k_spring_data,'Linewidth',5)
    plot(mm2perc(x_titan,x_center_max,x_center_min),k_titan)
    %plot(mm2perc(x_titan,x_center_max,x_center_min),gamma_titan)
    fig_format('','','')
    legend('Spring Data','Fit used in Code')
end
end

