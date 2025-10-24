%% Plotting Torque-Angle Curves for incline and decline walking using GA-Tech dataset

% Add folder with GT dataset to path
addpath(genpath('C:\Users\ecimino\Documents\Important Data'));

% Load files by name and call it 'data'
load('taskData_strides.mat');

%% T-A Curve, Level Ground Walking

% another day

%% T-A Curve, Incline Walking

% Extracting Kinematic and Kinetic Data

% 5 Degree Incline
angle_5degup = taskData_strides.ramp_ascent.i5.ankle_angle;      % 166 strides with 500 datapoints per stride, 10 participants
angle_5degup = mean(angle_5degup, 2);                            % Averages the rows (2nd dimension)
torque_5degup = taskData_strides.ramp_ascent.i5.ankle_torque;
torque_5degup = mean(torque_5degup, 2);

% 10 Degree Incline
angle_10degup = taskData_strides.ramp_ascent.i10.ankle_angle;
angle_10degup = mean(angle_10degup, 2);
torque_10degup = taskData_strides.ramp_ascent.i10.ankle_torque;
torque_10degup = mean(torque_10degup, 2);

stance = 0.62 * length(angle_5degup);                            % Stance is approximately the first 64% of gait cycle

stanceAngle_5degup = angle_5degup(1:stance);
stanceAngle_10degup = angle_10degup(1:stance);
stanceTorque_5degup = torque_5degup(1:stance);
stanceTorque_10degup = torque_10degup(1:stance);

% Find equilibrium angle during stance (where torque = 0)
% equilibriumAngle_5degup = stanceAngle_5degup(find(stanceTorque_5degup == 0));
% equilibriumAngle_10degup = stanceAngle_10degup(find(stanceTorque_10degup == 0));

figure(2);
subplot(2,1,1);
plot(angle_5degup, torque_5degup, 'LineWidth',2, 'Color','b');
hold on;
plot(angle_5degup(1:stance), torque_5degup(1:stance), 'LineWidth',2,'Color','r');         % Plot stance only in another color
title('Torque-Angle Curve for 5 Degree Incline Walking');
xlabel('Ankle Angle (degrees)');
ylabel('Ankle Torque (Nm)');
yline(0);
grid on;
legend('Swing', 'Stance');

subplot(2,1,2);
plot(angle_10degup, torque_10degup, 'LineWidth',2, 'Color','b');
hold on;
plot(angle_10degup(1:stance), torque_10degup(1:stance),'LineWidth',2,'Color','r');        % Plot stance only in another color
title('Torque-Angle Curve for 10 Degree Incline Walking');
xlabel('Ankle Angle (degrees)');
ylabel('Ankle Torque (Nm)');
yline(0);
grid on;
legend('Swing', 'Stance');


%% T-A Curve, Decline Walking

% Extracting Kinematic and Kinetic Data

% 5 Degree Decline
angle_5degdown = taskData_strides.ramp_descent.in5.ankle_angle;      % 166 strides with 500 datapoints per stride, 10 participants
angle_5degdown = mean(angle_5degdown, 2);                            % Averages the rows (2nd dimension)
torque_5degdown = taskData_strides.ramp_descent.in5.ankle_torque;
torque_5degdown = mean(torque_5degdown, 2);

% 10 Degree Decline
angle_10degdown = taskData_strides.ramp_descent.in10.ankle_angle;
angle_10degdown = mean(angle_10degdown, 2);
torque_10degdown = taskData_strides.ramp_descent.in10.ankle_torque;
torque_10degdown = mean(torque_10degdown, 2);

figure(3);
subplot(2,1,1);
plot(angle_5degdown, torque_5degdown, 'LineWidth',2, 'Color','b');
hold on;
plot(angle_5degdown(1:stance), torque_5degdown(1:stance), 'LineWidth',2,'Color','r');            % Plot stance only in another color
title('Torque-Angle Curve for 5 Degree Decline Walking');
xlabel('Ankle Angle (degrees)');
ylabel('Ankle Torque (Nm)');
yline(0);
grid on;
legend('Swing', 'Stance');

subplot(2,1,2);
plot(angle_10degdown, torque_10degdown, 'LineWidth',2, 'Color','b');
hold on;
plot(angle_10degdown(1:stance), torque_10degdown(1:stance), 'LineWidth',2, 'Color','r');           % Plot stance only in another color
title('Torque-Angle Curve for 10 Degree Decline Walking');
xlabel('Ankle Angle (degrees)');
ylabel('Ankle Torque (Nm)');
yline(0);
grid on;
legend('Swing', 'Stance');