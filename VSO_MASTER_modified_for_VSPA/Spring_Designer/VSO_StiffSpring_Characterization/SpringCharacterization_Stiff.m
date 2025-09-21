%% READ ME
%put this code in the folder of the data you want to process
%% 
clear
close all

%Configurables
toe_end = 0.8;
%% VSO
spring_4 = 1;
if(spring_4) %4mm base pg6
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.559594 0.831758 1.26011 1.87619 2.78044 4.3241 6.39535]*10^6;
end

%Fit
titanium = polyfit(x_FEA,k_FEA,3);
x_titan = x_FEA(1):-0.5:x_FEA(end);
k_titan = polyval(titanium,x_titan);
%Percentage
titan_percent = 0:(100/(length(x_titan)-1)):100;
k_titan_percent = k_titan./10^6;


%% Characterization
conditions = ["10" "20" "30" "40" "50" "60" "70" "80" "90"];
%colors = [[1, 1, 0]; [1, 0, 1]; [0, 1, 1]; [1, 0, 0]; [0, 1, 0]; [0, 0, 1]; [1, 1, 1]; [0, 0, 0]];
conditions_mm = ((double(conditions)./100*(x_FEA(1)-x_FEA(end)))+x_FEA(end));
color_end = [255 0 0]./255;
color_start = [255 230 230]./255;
q = 6;
color_ramp = 230/q;
colors_ramp_2 = 140/(9-q);

for j=1:9
    if(j<=q)
        color_beginning = color_start+[0 -color_ramp*j -color_ramp*j]./255;
        colors = color_beginning;
    else
        j
        -colors_ramp_2*(j-q)/255
        colors_end = color_beginning+[-colors_ramp_2*(j-q) 0 0]./255;
        colors = colors_end
    end
    %--------------------
    test = readtable(strcat(convertStringsToChars(conditions(j)),'.txt'));
    time = table2array(test(:,1));
    extension = -1*table2array(test(:,2));
    load = -1*table2array(test(:,3));
    figure(1)
    hold on
    %plot(extension,load)
    
    for i=1:length(extension)
        monotonic = extension(i+1)-extension(i);
        if(monotonic<0)
            max_deflect = i;
            break
        end
    end
    extension = extension(1:max_deflect-5);
    load = load(1:max_deflect-5);
    figure(1)
    hold on
    plot(extension(extension>toe_end)-toe_end,load(extension>toe_end),'Color',colors,'linewidth',2)
    k_fit = polyfit(extension(extension>toe_end),load(extension>toe_end),1);
    plot(extension(extension>toe_end)-toe_end,polyval(k_fit,extension(extension>toe_end)),'Color',colors,'linewidth',1)
    k(j) = k_fit(1);
end
xlabel('Spring Displacement [mm]'); ylabel('Force [kN]'); title('Testing Spring with Instron');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)

%----------------------Plot Spring FEA------------------------------------
figure(2)
hold on 
plot(titan_percent,k_titan_percent,'Color','b','Linewidth',3)
plot(double(conditions),k,'linewidth',3)
titan_percent = 0:(100/(length(x_FEA)-1)):100;
xlabel('Slider Percentage'); ylabel('Translational Stiffness [kN/mm]'); title('Spring Stiffness');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('VSO FEA','VSO Characterization','VSO Scaled','Instron Compliance','Both')
legend box off
hold off

figure(82)
hold on
plot(double(conditions),k,'linewidth',5,'LineStyle','--')






