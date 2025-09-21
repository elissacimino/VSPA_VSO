% clear all
% close all
% clc

%% Max spring
mass1 = 196.95; %g
sliderPos = [ -0.09, -0.08, -0.07 -0.06 -0.05 -0.04]; %m
load_y = [2000, 2500, 3400 4400 6000 8100]; %N
displacement = [ 3.52, 2.994, 2.82, 2.837, 2.38, 2.063].*1e-3; %m

min_val = min(sliderPos);
max_val = max(sliderPos);
x_normalized = (sliderPos - min_val) / (max_val - min_val);
x_percentage = x_normalized * 100;

klin = load_y./displacement %N/m
max_stiff1 = max(klin);
figure
plot(x_percentage, klin.*1e-6)
xlabel('Slider position (%)')
ylabel('Beam Stiffness  (kN/mm)')


%% powered spring
%width reduction of 5 mm
mass2 = 163.79; %g
sliderPos = [ -0.09, -0.08, -0.07 -0.06 -0.05 -0.04]; %m
load_y = [2000, 2500, 3400 4400 6000 8100]; %N
displacement = [4.26, 3.62 3.41 3.091 2.895 2.532].*1e-3; %m

min_val = min(sliderPos);
max_val = max(sliderPos);
x_normalized = (sliderPos - min_val) / (max_val - min_val);
x_percentage = x_normalized * 100;

klin = load_y./displacement %N/m
max_stiff2 = max(klin);

figure
plot(x_percentage, klin.*1e-6)
xlabel('Slider position (%)')
ylabel('Beam Stiffness  (kN/mm)')

%% width reduction of 10 mm
mass3 = 130.63; %g
sliderPos = [ -0.09, -0.08, -0.07 -0.06 -0.05 -0.04]; %m
load_y = [2000, 2500, 3400 4400 6000 8100]; %N
displacement = [5.297, 4.499 4.255 3.883 3.673 3.255].*1e-3; %m

min_val = min(sliderPos);
max_val = max(sliderPos);
x_normalized = (sliderPos - min_val) / (max_val - min_val);
x_percentage = x_normalized * 100;

klin = load_y./displacement %N/m
max_stiff3 = max(klin);

figure
plot(x_percentage, klin.*1e-6)
xlabel('Slider position (%)')
ylabel('Beam Stiffness  (kN/mm)')


%% comparison
masses = [ mass1 mass2 mass3];
max_stif =[max_stiff1 max_stiff2 max_stiff3];

figure
plot(masses, max_stif, 'o')
xlabel('mass (g)')
ylabel('Beam Stiffness  (kN/mm)')
title('Width reduction')