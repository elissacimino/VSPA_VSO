clear
close all

%Configurables
toe_end = 0.8; %0.6 [mm]
offset = 0.275; %kN/mm
%% FEA
%% Blue VSPA
x_FEA_VSPA = flip([88.38 70 50 32.5]-32.5);
k_FEA_VSPA = [0.627746 1.26566 2.58131 5.70776];
x_VSPA= [0:5:70];
k_VSPA = [0.318120805369127,0.384000000000000,0.469798657718121,0.566666666666667,0.685333333333333,0.829530201342282,0.997315436241611,1.19798657718121,1.43500000000000,1.73307692307692,2.10454545454545,2.58222222222222,3.22400000000000,4.09000000000000,5.16400000000000];
%% VSO
spring_1 = 0;
spring_2 = 0;
spring_3 = 0;
spring_4 = 1;
if(spring_1) %Spring that was tested
    x_FEA = [87.9 80 60 40 30.52];
    k_FEA = [0.614251 0.82713 1.67 3.42818 5.39665]*10^6;
end
if(spring_2)
    x_FEA = [87.9 80 60 40 30.52];
    k_FEA = [0.762195 1.07681 2.24215 4.84183 7.85916]*10^6;
end
if(spring_3) %5mm base pg6
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.716888 1.04135 1.54093 2.24681 3.28091 5.04593 7.37265]*10^6;
end
if(spring_4) %4mm base pg6
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.559594 0.831758 1.26011 1.87619 2.78044 4.3241 6.39535]*10^6;
end

%Fit
max_perc = ((x_FEA(1)-x_FEA(end))/(x_FEA(1)-30.52))*100;
titanium = polyfit(x_FEA,k_FEA,3);
x_titan = x_FEA(1):-0.5:x_FEA(end);
k_titan = polyval(titanium,x_titan);
%Percentage
titan_percent = 0:(max_perc/(length(x_titan)-1)):max_perc;
k_titan_percent = k_titan./10^6;

%New Spring Fit
new_spring_fit = polyfit(x_FEA,k_FEA,4);
new_spring = polyval(new_spring_fit,x_titan);

%Master Spring Fit
x_FEA_old = [87.9 80 60 40 30.52];
k_FEA_old = [0.614251 0.82713 1.67 3.42818 5.39665]*10^6;
old_spring_fit = polyfit(x_FEA_old,k_FEA_old,4);
old_spring = polyval(old_spring_fit,x_titan);

SF_vec = polyval(new_spring_fit,x_FEA)./polyval(old_spring_fit,x_FEA);


%SF Fit
SF_fit = polyfit(x_FEA,SF_vec,4);
SF = polyval(SF_fit,x_titan);

figure(4)
hold on
plot(flip(x_titan),new_spring/10^6,'linewidth',3)
plot(flip(x_FEA),k_FEA/10^6,'x','linewidth',3)
%plot(x_titan,old_spring/10^6,'linewidth',3)
%plot(x_FEA_old,k_FEA_old/10^6,'x','linewidth',3)
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
xlabel('Slider Percentage'); ylabel('Translational Stiffness [kN/mm]'); title('Spring Stiffness');
title('Evaluating FITS')
legend('New Spring','New FEA','Old Spring','Old FEA')
legend box off

figure(5)
hold on
plot(x_FEA,SF_vec,'x','linewidth',3)
plot(x_titan,SF,'linewidth',3)
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
title('Evaluating FITS')
legend('Scale Factor Vector','Scale Factor Fit')
legend box off


%% Characterization
conditions = ["0" "10" "20" "30" "40" "50" "60" "70" "80" "90" "100"];
%colors = [[1, 1, 0]; [1, 0, 1]; [0, 1, 1]; [1, 0, 0]; [0, 1, 0]; [0, 0, 1]; [1, 1, 1]; [0, 0, 0]];
conditions_mm = ((double(conditions)./100*(x_FEA_old(1)-x_FEA_old(end)))+30.52); %Keep this 30.52 because old prototype went to this position
color_end = [255 0 0]./255;
color_start = [255 230 230]./255;
%colors = [1 0 0];
q = 6;
color_ramp = 230/q;
colors_ramp_2 = 140/(9-q);

for j=1:11
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
    plot(extension(extension>toe_end),load(extension>toe_end),'Color',colors,'linewidth',2)
    k_fit = polyfit(extension(extension>toe_end),load(extension>toe_end),1);
    plot(extension(extension>toe_end),polyval(k_fit,extension(extension>toe_end)),'Color',colors,'linewidth',1)
    k(j) = k_fit(1);
end
xlabel('Spring Displacement [mm]'); ylabel('Force [kN]'); title('VSO Instron Characterization');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
%-----------------------------------------------------
figure(2)
hold on
machine_stiffness = 5/0.23;
k_debug = ((1./k)-(1/machine_stiffness)).^(-1);
k_debug_2 = ((1./(k+offset))-(1/machine_stiffness)).^(-1);

%----------------------Plot Spring FEA------------------------------------
figure(2)
hold on 
plot(titan_percent,k_titan_percent,'Color','b','Linewidth',3)
plot(double(conditions),k,'linewidth',3)
%plot(double(conditions),k+offset,'--','linewidth',3)
plot(double(conditions),k_debug,'--','linewidth',3)
%plot(double(conditions),k_debug_2,'--','linewidth',3)
titan_percent = 0:(100/(length(x_FEA)-1)):100;
%xline(48,'--')
%plot(titan_percent,k_FEA/10^6,'Linewidth',4)
xlabel('Slider Percentage'); ylabel('Translational Stiffness [kN/mm]'); title('Spring Stiffness');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('VSO FEA','VSO Characterization','Instron Compliance','Both')
legend box off
%axis([0,100,0,2.9])
hold off

figure(3)
hold on
plot(x_FEA_VSPA,k_FEA_VSPA,'linewidth',3)
plot(x_VSPA,k_VSPA,'linewidth',3)
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('VSPA FEA','VSPA Characterization')
legend box off

figure(81)
hold on
plot(double(conditions),k,'linewidth',3)
xlabel('Slider Percentage'); ylabel('Translational Stiffness [kN/mm]'); title('Spring Stiffness');
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
legend('Expected', 'Instron')
legend box off





