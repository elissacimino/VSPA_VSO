%VSO Spring Designer
%Nikko Van Crey 3/29/22
% clear
% close all
%% Configurables
%Choose Spring
VSO_DUAL = 0;
featherweight = 0;
featherweight_V2 = 0;
featherweight_short = 0;

max_vspa = 1;
powered_vspa_width = 0;
powered_vspa_length = 0;
powered_vspa_length_width = 0;
powered_vspa_length_width_height = 0;
% spring FEA and data
if(VSO_DUAL) %4mm base pg6
    x_FEA_good_yield = [89 80 70 60 50 40 32.5];
    k_FEA = [0.559594 0.831758 1.26011 1.87619 2.78044 4.3241 6.39535]*10^6;
end

if(featherweight)
    x_FEA_good_yield = [89 80 70 60 50 40 32.5];
    k_FEA = [0.32108 0.449732 0.673329 0.997511 1.50032 2.29952 3.36197]*10^6;
end

if(featherweight_V2) %99 grams
    x_FEA_good_yield = [89 80 70 60 50 40 32.5];
    k_FEA = [0.318232 0.460678 0.681199 1.00134 1.51976 2.31942 3.37187]*10^6;
end

if(featherweight_short)
    x_FEA_good_yield = [89 80 70 60 50 40 32.5];
    k_FEA = [0.221049 0.399412 0.783079 1.34005 2.09316 3.16744 4.51771]*10^6;
end

if (max_vspa) %evaluated at 7 deg, no problem at yielding
    x_stroke = [0.0880    0.08225    0.0765    0.07075    0.0650    0.05925   0.0535    0.04775    0.0420    0.03625    0.0305];
    max_mass = 196.93; %g
    x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
    F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115];%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
    disp_FEA=    1e-3.*[1.004     0.929    0.9378   0.954     0.953     0.9391     0.912     0.875    0.818     0.746     0.648]; %mm
    k = F_FEA./disp_FEA;
    figure(2), hold on
    plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'o')
    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
    plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
end
x_FEA = x_FEA_good_yield;
k_FEA = k;


if (powered_vspa_width)  %evaluated at 7 deg, no problem at yielding -- divided by 2
    x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
    powered_mass =  115.58;%g
    x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
    F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
    disp_FEA=    1e-3.*[ 0.86  0.8035  0.8194  0.8482 0.8624  0.8655  0.8662   0.8523   0.8174   0.752   0.675]; %mm
    k = F_FEA./disp_FEA;
        figure(2), hold on
    plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'o')
    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
    plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
end
x_pow_FEA = x_FEA_good_yield;
k_pow_FEA = k;

if (powered_vspa_length)  %evaluated at 7 deg, no problem at yielding -- divided by 2
    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    powered_mass =  141.55;%g
    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249*2    1.8309*2    2.1732*2    2.5773*2    3.0679*2    3.6751*2    4.4115*2]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
    disp_FEA=    1e-3.*[0.599     0.4871    0.4399    0.4069    0.7877     0.7601        0.7075     0.6274    0.5271        0.4144      0.301]; %mm
    k = F_FEA./disp_FEA;
        figure(2), hold on
    plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'o')
    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
    plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
end
x_pow_FEA = x_FEA_good_yield;
k_pow_FEA = k;

if (powered_vspa_length_width)  %evaluated at 7 deg, no problem at yielding -- divided by 2
    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    powered_mass = 81.72;  %g
    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.5773   3.0679   3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
    disp_FEA=           1e-3.*[1.036   0.858     0.7908    0.7396     0.7357    0.733       0.7017   0.6403    0.547   0.4332        0.3155]; %mm
    k = F_FEA./disp_FEA;
        figure(2), hold on
    plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'o')
    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
    plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
end
x_pow_FEA = x_FEA_good_yield;
k_pow_FEA = k;

if (powered_vspa_length_width_height)  %evaluated at 7 deg, no problem at yielding -- divided by 2
    x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    powered_mass =  65.68;%g
    x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
    F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.1732   2.1732   2.1732    2.1732]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
    disp_FEA=           1e-3.*[2.578    2.46     2.397    2.454       2.637      2.783     2.768       2.036     1.326   0.7502     0.3805]; %mm
    k = F_FEA./disp_FEA;
        figure(2), hold on
    plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,'o')
    p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
    new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
    plot(1e3*abs(x_stroke-max(x_stroke)), new_k)
end
x_pow_FEA = x_FEA_good_yield;
k_pow_FEA = k;

if(rotary_vspa_fixedSpring)

%% Transform FEA to Expected Instron Results
fea2reality = load('fea2reality')
fea2reality = fea2reality.fea2reality
% SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead

k_instron_expected = k_FEA.*SF/10^6;
k_instron_expected_pow = k_pow_FEA.*SF/10^6;

%rescale once more for VSPA %least square error approach
% Calculate the rescaling factor
alpha = dot(ktranslational, k_FEA) / dot(k_FEA, k_FEA);
% Rescale the k_FEA vector
k_FEA_rescaled = alpha * k_FEA;
k_pow_FEA_rescaled = alpha * k_pow_FEA;


%Percentage
x_perc = ((0.088-x_FEA)./(0.088-0.0305))*100;
plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected,'linewidth',2)
plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_instron_expected_pow,'linewidth',2)
plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_FEA_rescaled.*1e-6,'linewidth',2)
plot(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)), k_pow_FEA_rescaled.*1e-6,'linewidth',2)

legend('characterized','','','lead screw limit','FEA VSPA','','FEA pow VSPA','','Expected Instron Results VSPA','Expected Instron Results pow VSPA')


figure(80)
plot([powered_mass max_mass],[max(k_pow_FEA) max(k_FEA) ],'o')

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
