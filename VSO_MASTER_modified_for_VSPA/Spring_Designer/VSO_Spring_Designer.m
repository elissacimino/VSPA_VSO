%VSO Spring Designer
%Nikko Van Crey 3/29/22
clear
close all
%% Configurables
%Choose Spring
VSO_DUAL = 0;
featherweight = 0;
featherweight_V2 = 1;
featherweight_short = 0;

%% spring FEA and data
if(VSO_DUAL) %4mm base pg6
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.559594 0.831758 1.26011 1.87619 2.78044 4.3241 6.39535]*10^6;
end

if(featherweight)
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.32108 0.449732 0.673329 0.997511 1.50032 2.29952 3.36197]*10^6;
end

if(featherweight_V2) %99 grams
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.318232 0.460678 0.681199 1.00134 1.51976 2.31942 3.37187]*10^6;
end

if(featherweight_short)
    x_FEA = [89 80 70 60 50 40 32.5];
    k_FEA = [0.221049 0.399412 0.783079 1.34005 2.09316 3.16744 4.51771]*10^6;
end

%% Transform FEA to Expected Instron Results
fea2reality = load('fea2reality')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,50.5);
k_instron_expected = k_FEA.*SF/10^6;


%Percentage
x_perc = ((89-x_FEA)./(89-32.5))*100;



figure(81)
hold on
plot(x_perc,k_FEA./10^6,'linewidth',2)
plot(x_perc,k_instron_expected,'linewidth',2)
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
title('Evaluating FITS')
legend('FEA','Expected Instron Results')
legend box off



figure(82)
hold on
plot(x_perc,k_instron_expected./10^6,'linewidth',5)
set(gcf,'color','w'); set(gca,'FontSize',18); set(gca,'linewidth',2)
title('VSO Spring Design')
legend('Expected Spring Properties','Measured Spring Properties')
legend box off
xlabel('Spring Support Position [%]')
ylabel('Spring Stiffness [kN/mm')
