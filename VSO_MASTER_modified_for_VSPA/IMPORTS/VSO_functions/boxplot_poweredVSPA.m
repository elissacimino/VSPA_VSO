
i = 1;
x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
max_mass = 196.93; %g
x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115];%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
disp_FEA=    1e-3.*[1.004     0.929    0.9378   0.954     0.953     0.9391     0.912     0.875    0.818     0.746     0.648]; %mm
k = F_FEA./disp_FEA;
p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
x_FEA = x_FEA_good_yield;
k_FEA = k;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
k_instron_expected = k_FEA.*SF/10^6;
titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);

bx(:,i) = k_instron_expected;
name1 = max_mass;

i = 3; %width
x_stroke = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593   0.0535    0.0478    0.0420    0.0362    0.0305];
powered_mass =  115.58;%g
x_FEA_good_yield = [0.0880    0.0823    0.0765    0.0708    0.0650    0.0593     0.0535    0.0478    0.0420    0.0362    0.0305]; %m from inverse model
F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249    1.8309    2.1732    2.5773    3.0679    3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
disp_FEA=    1e-3.*[ 0.86  0.8035  0.8194  0.8482 0.8624  0.8655  0.8662   0.8523   0.8174   0.752   0.675]; %mm
k = F_FEA./disp_FEA;
p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
x_FEA = x_FEA_good_yield;
k_FEA = k;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
k_instron_expected = k_FEA.*SF/10^6;
titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
bx(:,i) = k_instron_expected;
name2 = powered_mass;


i = 2; %length
x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
powered_mass =  141.55;%g
x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
F_FEA =       1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249*2    1.8309*2    2.1732*2    2.5773*2    3.0679*2    3.6751*2    4.4115*2]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
disp_FEA=    1e-3.*[0.599     0.4871    0.4399    0.4069    0.7877     0.7601        0.7075     0.6274    0.5271        0.4144      0.301]; %mm
k = F_FEA./disp_FEA;
p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
x_FEA = x_FEA_good_yield;
k_FEA = k;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
k_instron_expected = k_FEA.*SF/10^6;
titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
bx(:,i) = k_instron_expected;
name3 = powered_mass;

i = 4;
x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
powered_mass =  81.72;%g
x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.5773   3.0679   3.6751    4.4115]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
disp_FEA=           1e-3.*[1.036   0.858     0.7908    0.7396     0.7357    0.733       0.7017   0.6403    0.547   0.4332        0.3155]; %mm
k = F_FEA./disp_FEA;
p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
x_FEA = x_FEA_good_yield;
k_FEA = k;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
k_instron_expected = k_FEA.*SF/10^6;
titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
bx(:,i) = k_instron_expected;
name4 = powered_mass;


i = 5;
x_stroke = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500         45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
powered_mass =  65.68;%g
x_FEA_good_yield = 1e-3.*[80.0000   74.2500   68.5000   62.7500   57.0000   51.2500    45.5000   39.7500   34.0000      28.2500      22.5000]; %m from inverse model
F_FEA =            1e3.*[0.6870    0.7942    0.9942    1.2454    1.5249      1.8309     2.1732   2.1732   2.1732   2.1732    2.1732]./2;%    4.9694    5.7892    6.7893    8.0314    9.5366].*1e3; %N y-componenet
disp_FEA=           1e-3.*[2.578    2.46     2.397    2.454       2.637      2.783     2.768       2.036     1.326   0.7502     0.3805]; %mm
k = F_FEA./disp_FEA;
p2 = polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k*1e-6,4);
new_k = polyval(p2,1e3*abs(x_stroke-max(x_stroke)))
x_FEA = x_FEA_good_yield;
k_FEA = k;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
SF = polyval(fea2reality,57.5); %should I consider the stroke of the lead
k_instron_expected = k_FEA.*SF/10^6;
titanium_data= polyfit(1e3*abs(x_FEA_good_yield-max(x_FEA_good_yield)),k_instron_expected.*1e6,5);
bx(:,i) = k_instron_expected;
name5 = powered_mass;

%% comparison
categories = {'max','length','width','length-width','length-width-height'}
group = repmat(categories, size(bx,1), 1);
group = categorical(group(:));
data = bx(:);
figure;
boxchart(group, data);
title('Boxchart');
xlabel('Springs');
ylabel('Stiffness (kN/mm)')
set(gcf,'color','w');
set(gca,'FontSize',14);
set(gca,'FontName','Times New Roman');


primaries = [bx(6,1) bx(6,2) bx(6,3) bx(6,4) bx(6,5)];
masses = [name1, name2, name3, name4, name5];
figure
plot(name1,bx(5,1),'o','LineWidth',3), hold on
plot(name2, bx(6,2),'v','LineWidth',3)
plot(name3, bx(5,3),'pentagram','LineWidth',3)
plot(name4, bx(6,4),"+",'LineWidth',3)
plot(name5, bx(6,5),"hexagram",'LineWidth',3)
legend(categories)
set(gcf,'color','w');
set(gca,'FontSize',14);
set(gca,'FontName','Times New Roman');
ylabel('Stiffness (kN/mm)')
xlabel('Mass (g)')
title('Mass-Stiffness grpah evaluated at 52 mm lead pos')


%% small figure
F_max_42mm = 4370;
disp_max_42mm = 1.257*1e-3;
max_mass = 196.93; 
F_pow = 2570.6;
disp_pow = 0.8075*1e-3;
pow_mass = 150.72;
k_max = F_max_42mm/ disp_max_42mm;
k_pow = F_pow/disp_pow;
fea2reality = load('fea2reality.mat')
fea2reality = fea2reality.fea2reality
% SF = polyval(fea2reality,50.5); %should I consider the stroke of the lead
SF = polyval(fea2reality,42); %should I consider the stroke of the lead
k_instron_expected_max = k_max.*SF/10^6;
k_instron_expected_pow = k_pow.*SF/10^6;

figure
% plot(max_mass,k_max*1e-6 ,'pentagram','LineWidth',3), hold on
% plot(pow_mass,k_pow*1e-6 ,'pentagram','LineWidth',3), hold on
plot(max_mass,k_instron_expected_max ,'pentagram','LineWidth',3), hold on
plot(pow_mass,k_instron_expected_pow ,'pentagram','LineWidth',3), hold on
set(gcf,'color','w');
set(gca,'FontSize',14);
set(gca,'FontName','Times New Roman');
ylabel('Stiffness (kN/mm)')
xlabel('Mass (g)')
% title('Mass-Stiffness grpah evaluated at 52 mm lead pos')