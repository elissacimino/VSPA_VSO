if ~exist("R01_Normalized")
    load Normalized.mat
    R01_Normalized = Normalized;
end
load FinucaneParticipantData.mat
load HoodParticipantData.mat
load Riener_Normalized.mat
load Friedl_Normalized.mat

addpath('Utility Functions')

%Get Walk Data R01
walk_s1_R01 = getStrideBiomechanics_R01Normalized(R01_Normalized,"Walk","s1");
walk_s1x2_R01 = getStrideBiomechanics_R01Normalized(R01_Normalized,"Walk","s1x2");
walk_s0x8_R01 = getStrideBiomechanics_R01Normalized(R01_Normalized,"Walk","s0x8");

%Get Stair Data Riener
stair_Riener = Riener_Normalized;

%Get Sit/StandData
sitStand_Friedl = Friedl_Normalized;


%% Getting Averages (don't touch)
% --------------------------------- Walk ----------------------------------
% s1 Walking Data
% Angles
kneeAngle_walk_s1_in10 = walk_s1_R01.in10.full.knee_angle_mean;
kneeAngle_walk_s1_in5 = walk_s1_R01.in5.full.knee_angle_mean;
kneeAngle_walk_s1_i0 = walk_s1_R01.i0.full.knee_angle_mean;
kneeAngle_walk_s1_i5 = walk_s1_R01.i5.full.knee_angle_mean;
kneeAngle_walk_s1_i10 = walk_s1_R01.i10.full.knee_angle_mean;

ankleAngle_walk_s1_in10 = walk_s1_R01.in10.full.ankle_angle_mean;
ankleAngle_walk_s1_in5 = walk_s1_R01.in5.full.ankle_angle_mean;
ankleAngle_walk_s1_i0 = walk_s1_R01.i0.full.ankle_angle_mean;
ankleAngle_walk_s1_i5 = walk_s1_R01.i5.full.ankle_angle_mean;
ankleAngle_walk_s1_i10 = walk_s1_R01.i10.full.ankle_angle_mean;

%Moments
kneeMoment_walk_s1_in10 = abs(walk_s1_R01.in10.full.knee_moment_mean); %+ walk_s1_R01.in10.full.knee_moment_std;
kneeMoment_walk_s1_in5 = abs(walk_s1_R01.in5.full.knee_moment_mean); %+ walk_s1_R01.in5.full.knee_moment_std;
kneeMoment_walk_s1_i0 = abs(walk_s1_R01.i0.full.knee_moment_mean); %+ walk_s1_R01.i0.full.knee_moment_std;
kneeMoment_walk_s1_i5 = abs(walk_s1_R01.i5.full.knee_moment_mean); %+ walk_s1_R01.i5.full.knee_moment_std;
kneeMoment_walk_s1_i10 = abs(walk_s1_R01.i10.full.knee_moment_mean); %+ walk_s1_R01.i10.full.knee_moment_std;

ankleMoment_walk_s1_in10 = abs(walk_s1_R01.in10.full.ankle_moment_mean); %+ walk_s1_R01.in10.full.ankle_moment_std;
ankleMoment_walk_s1_in5 = abs(walk_s1_R01.in5.full.ankle_moment_mean); %+ walk_s1_R01.in5.full.ankle_moment_std;
ankleMoment_walk_s1_i0 = abs(walk_s1_R01.i0.full.ankle_moment_mean); %+ walk_s1_R01.i0.full.ankle_moment_std;
ankleMoment_walk_s1_i5 = abs(walk_s1_R01.i5.full.ankle_moment_mean); %+ walk_s1_R01.i5.full.ankle_moment_std;
ankleMoment_walk_s1_i10 = abs(walk_s1_R01.i10.full.ankle_moment_mean); %+ walk_s1_R01.i10.full.ankle_moment_std;

%Velocity
kneeVelocity_walk_s1_in10 = abs(walk_s1_R01.in10.full.knee_velocity_mean); %+ walk_s1_R01.in10.full.knee_velocity_std;
kneeVelocity_walk_s1_in5 = abs(walk_s1_R01.in5.full.knee_velocity_mean); %+ walk_s1_R01.in5.full.knee_velocity_std;
kneeVelocity_walk_s1_i0 = abs(walk_s1_R01.i0.full.knee_velocity_mean); %+ walk_s1_R01.i0.full.knee_velocity_std;
kneeVelocity_walk_s1_i5 = abs(walk_s1_R01.i5.full.knee_velocity_mean); %+ walk_s1_R01.i5.full.knee_velocity_std;
kneeVelocity_walk_s1_i10 = abs(walk_s1_R01.i10.full.knee_velocity_mean); %+ walk_s1_R01.i10.full.knee_velocity_std;

ankleVelocity_walk_s1_in10 = abs(walk_s1_R01.in10.full.ankle_velocity_mean); %+ walk_s1_R01.in10.full.ankle_velocity_std;
ankleVelocity_walk_s1_in5 = abs(walk_s1_R01.in5.full.ankle_velocity_mean); %+ walk_s1_R01.in5.full.ankle_velocity_std;
ankleVelocity_walk_s1_i0 = abs(walk_s1_R01.i0.full.ankle_velocity_mean); %+ walk_s1_R01.i0.full.ankle_velocity_std;
ankleVelocity_walk_s1_i5 = abs(walk_s1_R01.i5.full.ankle_velocity_mean); %+ walk_s1_R01.i5.full.ankle_velocity_std;
ankleVelocity_walk_s1_i10 = abs(walk_s1_R01.i10.full.ankle_velocity_mean); %+ walk_s1_R01.i10.full.ankle_velocity_std;

%Power
kneePower_walk_s1_in10 = abs(walk_s1_R01.in10.full.knee_power_mean); %+ walk_s1_R01.in10.full.knee_power_std;
kneePower_walk_s1_in5 = abs(walk_s1_R01.in5.full.knee_power_mean); %+ walk_s1_R01.in5.full.knee_power_std;
kneePower_walk_s1_i0 = abs(walk_s1_R01.i0.full.knee_power_mean); %+ walk_s1_R01.i0.full.knee_power_std;
kneePower_walk_s1_i5 = abs(walk_s1_R01.i5.full.knee_power_mean); %+ walk_s1_R01.i5.full.knee_power_std;
kneePower_walk_s1_i10 = abs(walk_s1_R01.i10.full.knee_power_mean); %+ walk_s1_R01.i10.full.knee_power_std;

anklePower_walk_s1_in10 = abs(walk_s1_R01.in10.full.ankle_power_mean); %+ walk_s1_R01.in10.full.ankle_power_std;
anklePower_walk_s1_in5 = abs(walk_s1_R01.in5.full.ankle_power_mean); %+ walk_s1_R01.in5.full.ankle_power_std;
anklePower_walk_s1_i0 = abs(walk_s1_R01.i0.full.ankle_power_mean); %+ walk_s1_R01.i0.full.ankle_power_std;
anklePower_walk_s1_i5 = abs(walk_s1_R01.i5.full.ankle_power_mean); %+ walk_s1_R01.i5.full.ankle_power_std;
anklePower_walk_s1_i10 = abs(walk_s1_R01.i10.full.ankle_power_mean); %+ walk_s1_R01.i10.full.ankle_power_std;

% s0x8 Walking Data
% Angles
kneeAngle_walk_s0x8_in10 = walk_s0x8_R01.in10.full.knee_angle_mean;
kneeAngle_walk_s0x8_in5 = walk_s0x8_R01.in5.full.knee_angle_mean;
kneeAngle_walk_s0x8_i0 = walk_s0x8_R01.i0.full.knee_angle_mean;
kneeAngle_walk_s0x8_i5 = walk_s0x8_R01.i5.full.knee_angle_mean;
kneeAngle_walk_s0x8_i10 = walk_s0x8_R01.i10.full.knee_angle_mean;

ankleAngle_walk_s0x8_in10 = walk_s0x8_R01.in10.full.ankle_angle_mean;
ankleAngle_walk_s0x8_in5 = walk_s0x8_R01.in5.full.ankle_angle_mean;
ankleAngle_walk_s0x8_i0 = walk_s0x8_R01.i0.full.ankle_angle_mean;
ankleAngle_walk_s0x8_i5 = walk_s0x8_R01.i5.full.ankle_angle_mean;
ankleAngle_walk_s0x8_i10 = walk_s0x8_R01.i10.full.ankle_angle_mean;

%Moments
kneeMoment_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.knee_moment_mean); %+ walk_s0x8_R01.in10.full.knee_moment_std;
kneeMoment_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.knee_moment_mean); %+ walk_s0x8_R01.in5.full.knee_moment_std;
kneeMoment_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.knee_moment_mean); %+ walk_s0x8_R01.i0.full.knee_moment_std;
kneeMoment_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.knee_moment_mean); %+ walk_s0x8_R01.i5.full.knee_moment_std;
kneeMoment_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.knee_moment_mean); %+ walk_s0x8_R01.i10.full.knee_moment_std;

ankleMoment_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.ankle_moment_mean); %+ walk_s0x8_R01.in10.full.ankle_moment_std;
ankleMoment_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.ankle_moment_mean); %+ walk_s0x8_R01.in5.full.ankle_moment_std;
ankleMoment_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.ankle_moment_mean); %+ walk_s0x8_R01.i0.full.ankle_moment_std;
ankleMoment_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.ankle_moment_mean); %+ walk_s0x8_R01.i5.full.ankle_moment_std;
ankleMoment_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.ankle_moment_mean); %+ walk_s0x8_R01.i10.full.ankle_moment_std;

%Velocity
kneeVelocity_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.knee_velocity_mean); %+ walk_s0x8_R01.in10.full.knee_velocity_std;
kneeVelocity_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.knee_velocity_mean); %+ walk_s0x8_R01.in5.full.knee_velocity_std;
kneeVelocity_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.knee_velocity_mean); %+ walk_s0x8_R01.i0.full.knee_velocity_std;
kneeVelocity_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.knee_velocity_mean); %+ walk_s0x8_R01.i5.full.knee_velocity_std;
kneeVelocity_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.knee_velocity_mean); %+ walk_s0x8_R01.i10.full.knee_velocity_std;

ankleVelocity_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.ankle_velocity_mean); %+ walk_s0x8_R01.in10.full.ankle_velocity_std;
ankleVelocity_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.ankle_velocity_mean); %+ walk_s0x8_R01.in5.full.ankle_velocity_std;
ankleVelocity_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.ankle_velocity_mean); %+ walk_s0x8_R01.i0.full.ankle_velocity_std;
ankleVelocity_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.ankle_velocity_mean); %+ walk_s0x8_R01.i5.full.ankle_velocity_std;
ankleVelocity_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.ankle_velocity_mean); %+ walk_s0x8_R01.i10.full.ankle_velocity_std;

%Power
kneePower_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.knee_power_mean); %+ walk_s0x8_R01.in10.full.knee_power_std;
kneePower_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.knee_power_mean); %+ walk_s0x8_R01.in5.full.knee_power_std;
kneePower_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.knee_power_mean); %+ walk_s0x8_R01.i0.full.knee_power_std;
kneePower_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.knee_power_mean); %+ walk_s0x8_R01.i5.full.knee_power_std;
kneePower_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.knee_power_mean); %+ walk_s0x8_R01.i10.full.knee_power_std;

anklePower_walk_s0x8_in10 = abs(walk_s0x8_R01.in10.full.ankle_power_mean); %+ walk_s0x8_R01.in10.full.ankle_power_std;
anklePower_walk_s0x8_in5 = abs(walk_s0x8_R01.in5.full.ankle_power_mean); %+ walk_s0x8_R01.in5.full.ankle_power_std;
anklePower_walk_s0x8_i0 = abs(walk_s0x8_R01.i0.full.ankle_power_mean); %+ walk_s0x8_R01.i0.full.ankle_power_std;
anklePower_walk_s0x8_i5 = abs(walk_s0x8_R01.i5.full.ankle_power_mean); %+ walk_s0x8_R01.i5.full.ankle_power_std;
anklePower_walk_s0x8_i10 = abs(walk_s0x8_R01.i10.full.ankle_power_mean); %+ walk_s0x8_R01.i10.full.ankle_power_std;

% s1x2 Walking Data
% Angles
kneeAngle_walk_s1x2_in10 = walk_s1x2_R01.in10.full.knee_angle_mean;
kneeAngle_walk_s1x2_in5 = walk_s1x2_R01.in5.full.knee_angle_mean;
kneeAngle_walk_s1x2_i0 = walk_s1x2_R01.i0.full.knee_angle_mean;
kneeAngle_walk_s1x2_i5 = walk_s1x2_R01.i5.full.knee_angle_mean;
kneeAngle_walk_s1x2_i10 = walk_s1x2_R01.i10.full.knee_angle_mean;

ankleAngle_walk_s1x2_in10 = walk_s1x2_R01.in10.full.ankle_angle_mean;
ankleAngle_walk_s1x2_in5 = walk_s1x2_R01.in5.full.ankle_angle_mean;
ankleAngle_walk_s1x2_i0 = walk_s1x2_R01.i0.full.ankle_angle_mean;
ankleAngle_walk_s1x2_i5 = walk_s1x2_R01.i5.full.ankle_angle_mean;
ankleAngle_walk_s1x2_i10 = walk_s1x2_R01.i10.full.ankle_angle_mean;

%Moments
kneeMoment_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.knee_moment_mean); %+ walk_s1x2_R01.in10.full.knee_moment_std;
kneeMoment_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.knee_moment_mean); %+ walk_s1x2_R01.in5.full.knee_moment_std;
kneeMoment_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.knee_moment_mean); %+ walk_s1x2_R01.i0.full.knee_moment_std;
kneeMoment_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.knee_moment_mean); %+ walk_s1x2_R01.i5.full.knee_moment_std;
kneeMoment_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.knee_moment_mean); %+ walk_s1x2_R01.i10.full.knee_moment_std;

ankleMoment_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.ankle_moment_mean); %+ walk_s1x2_R01.in10.full.ankle_moment_std;
ankleMoment_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.ankle_moment_mean); %+ walk_s1x2_R01.in5.full.ankle_moment_std;
ankleMoment_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.ankle_moment_mean); %+ walk_s1x2_R01.i0.full.ankle_moment_std;
ankleMoment_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.ankle_moment_mean); %+ walk_s1x2_R01.i5.full.ankle_moment_std;
ankleMoment_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.ankle_moment_mean); %+ walk_s1x2_R01.i10.full.ankle_moment_std;

%Velocity
kneeVelocity_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.knee_velocity_mean); %+ walk_s1x2_R01.in10.full.knee_velocity_std;
kneeVelocity_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.knee_velocity_mean); %+ walk_s1x2_R01.in5.full.knee_velocity_std;
kneeVelocity_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.knee_velocity_mean); %+ walk_s1x2_R01.i0.full.knee_velocity_std;
kneeVelocity_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.knee_velocity_mean); %+ walk_s1x2_R01.i5.full.knee_velocity_std;
kneeVelocity_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.knee_velocity_mean); %+ walk_s1x2_R01.i10.full.knee_velocity_std;

ankleVelocity_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.ankle_velocity_mean); %+ walk_s1x2_R01.in10.full.ankle_velocity_std;
ankleVelocity_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.ankle_velocity_mean); %+ walk_s1x2_R01.in5.full.ankle_velocity_std;
ankleVelocity_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.ankle_velocity_mean); %+ walk_s1x2_R01.i0.full.ankle_velocity_std;
ankleVelocity_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.ankle_velocity_mean); %+ walk_s1x2_R01.i5.full.ankle_velocity_std;
ankleVelocity_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.ankle_velocity_mean); %+ walk_s1x2_R01.i10.full.ankle_velocity_std;

%Power
kneePower_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.knee_power_mean); %+ walk_s1x2_R01.in10.full.knee_power_std;
kneePower_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.knee_power_mean); %+ walk_s1x2_R01.in5.full.knee_power_std;
kneePower_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.knee_power_mean); %+ walk_s1x2_R01.i0.full.knee_power_std;
kneePower_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.knee_power_mean); %+ walk_s1x2_R01.i5.full.knee_power_std;
kneePower_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.knee_power_mean); %+ walk_s1x2_R01.i10.full.knee_power_std;

anklePower_walk_s1x2_in10 = abs(walk_s1x2_R01.in10.full.ankle_power_mean); %+ walk_s1x2_R01.in10.full.ankle_power_std;
anklePower_walk_s1x2_in5 = abs(walk_s1x2_R01.in5.full.ankle_power_mean); %+ walk_s1x2_R01.in5.full.ankle_power_std;
anklePower_walk_s1x2_i0 = abs(walk_s1x2_R01.i0.full.ankle_power_mean); %+ walk_s1x2_R01.i0.full.ankle_power_std;
anklePower_walk_s1x2_i5 = abs(walk_s1x2_R01.i5.full.ankle_power_mean); %+ walk_s1x2_R01.i5.full.ankle_power_std;
anklePower_walk_s1x2_i10 = abs(walk_s1x2_R01.i10.full.ankle_power_mean); %+ walk_s1x2_R01.i10.full.ankle_power_std;

% Knee
kneeAngle_walk = [kneeAngle_walk_s1x2_in10; kneeAngle_walk_s1x2_in5; kneeAngle_walk_s1x2_i0; kneeAngle_walk_s1x2_i5; kneeAngle_walk_s1x2_i10;...
    kneeAngle_walk_s1_in10; kneeAngle_walk_s1_in5; kneeAngle_walk_s1_i0; kneeAngle_walk_s1_i5; kneeAngle_walk_s1_i10;...
    kneeAngle_walk_s0x8_in10; kneeAngle_walk_s0x8_in5; kneeAngle_walk_s0x8_i0; kneeAngle_walk_s0x8_i5; kneeAngle_walk_s0x8_i10];

kneeMoment_walk = [kneeMoment_walk_s1x2_in10; kneeMoment_walk_s1x2_in5; kneeMoment_walk_s1x2_i0; kneeMoment_walk_s1x2_i5; kneeMoment_walk_s1x2_i10;...
    kneeMoment_walk_s1_in10; kneeMoment_walk_s1_in5; kneeMoment_walk_s1_i0; kneeMoment_walk_s1_i5; kneeMoment_walk_s1_i10;...
    kneeMoment_walk_s0x8_in10; kneeMoment_walk_s0x8_in5; kneeMoment_walk_s0x8_i0; kneeMoment_walk_s0x8_i5; kneeMoment_walk_s0x8_i10];

kneeVelocity_walk = deg2rad([kneeVelocity_walk_s1x2_in10; kneeVelocity_walk_s1x2_in5; kneeVelocity_walk_s1x2_i0; kneeVelocity_walk_s1x2_i5; kneeVelocity_walk_s1x2_i10;...
    kneeVelocity_walk_s1_in10; kneeVelocity_walk_s1_in5; kneeVelocity_walk_s1_i0; kneeVelocity_walk_s1_i5; kneeVelocity_walk_s1_i10;...
    kneeVelocity_walk_s0x8_in10; kneeVelocity_walk_s0x8_in5; kneeVelocity_walk_s0x8_i0; kneeVelocity_walk_s0x8_i5; kneeVelocity_walk_s0x8_i10]);

kneePower_walk = [kneePower_walk_s1x2_in10; kneePower_walk_s1x2_in5; kneePower_walk_s1x2_i0; kneePower_walk_s1x2_i5; kneePower_walk_s1x2_i10;...
    kneePower_walk_s1_in10; kneePower_walk_s1_in5; kneePower_walk_s1_i0; kneePower_walk_s1_i5; kneePower_walk_s1_i10;...
    kneePower_walk_s0x8_in10; kneePower_walk_s0x8_in5; kneePower_walk_s0x8_i0; kneePower_walk_s0x8_i5; kneePower_walk_s0x8_i10];

[kneeAngle_walk_sort, walk_sort_ind] = sort(kneeAngle_walk,2);
% for j = 1:size(kneeAngle_walk_sort)
%     kneeMoment_walk_sort(j,:) = interp1(kneeAngle_walk_sort(j,:),kneeMoment_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneeVelocity_walk_sort(j,:) = interp1(kneeAngle_walk_sort(j,:),kneeVelocity_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneePower_walk_sort(j,:) = interp1(kneeAngle_walk_sort(j,:),kneePower_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
% end

% Ankle
ankleAngle_walk = [ankleAngle_walk_s1x2_in10; ankleAngle_walk_s1x2_in5; ankleAngle_walk_s1x2_i0; ankleAngle_walk_s1x2_i5; ankleAngle_walk_s1x2_i10;...
    ankleAngle_walk_s1_in10; ankleAngle_walk_s1_in5; ankleAngle_walk_s1_i0; ankleAngle_walk_s1_i5; ankleAngle_walk_s1_i10;...
    ankleAngle_walk_s0x8_in10; ankleAngle_walk_s0x8_in5; ankleAngle_walk_s0x8_i0; ankleAngle_walk_s0x8_i5; ankleAngle_walk_s0x8_i10];

ankleMoment_walk = [ankleMoment_walk_s1x2_in10; ankleMoment_walk_s1x2_in5; ankleMoment_walk_s1x2_i0; ankleMoment_walk_s1x2_i5; ankleMoment_walk_s1x2_i10;...
    ankleMoment_walk_s1_in10; ankleMoment_walk_s1_in5; ankleMoment_walk_s1_i0; ankleMoment_walk_s1_i5; ankleMoment_walk_s1_i10;...
    ankleMoment_walk_s0x8_in10; ankleMoment_walk_s0x8_in5; ankleMoment_walk_s0x8_i0; ankleMoment_walk_s0x8_i5; ankleMoment_walk_s0x8_i10];

ankleVelocity_walk = deg2rad([ankleVelocity_walk_s1x2_in10; ankleVelocity_walk_s1x2_in5; ankleVelocity_walk_s1x2_i0; ankleVelocity_walk_s1x2_i5; ankleVelocity_walk_s1x2_i10;...
    ankleVelocity_walk_s1_in10; ankleVelocity_walk_s1_in5; ankleVelocity_walk_s1_i0; ankleVelocity_walk_s1_i5; ankleVelocity_walk_s1_i10;...
    ankleVelocity_walk_s0x8_in10; ankleVelocity_walk_s0x8_in5; ankleVelocity_walk_s0x8_i0; ankleVelocity_walk_s0x8_i5; ankleVelocity_walk_s0x8_i10]);

anklePower_walk = [anklePower_walk_s1x2_in10; anklePower_walk_s1x2_in5; anklePower_walk_s1x2_i0; anklePower_walk_s1x2_i5; anklePower_walk_s1x2_i10;...
    anklePower_walk_s1_in10; anklePower_walk_s1_in5; anklePower_walk_s1_i0; anklePower_walk_s1_i5; anklePower_walk_s1_i10;...
    anklePower_walk_s0x8_in10; anklePower_walk_s0x8_in5; anklePower_walk_s0x8_i0; anklePower_walk_s0x8_i5; anklePower_walk_s0x8_i10];

[ankleAngle_walk_sort, walk_sort_ind] = sort(ankleAngle_walk,2);
% for j = 1:size(ankleAngle_walk_sort)
%     ankleMoment_walk_sort(j,:) = interp1(ankleAngle_walk_sort(j,:),ankleMoment_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
%     ankleVelocity_walk_sort(j,:) = interp1(ankleAngle_walk_sort(j,:),ankleVelocity_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
%     anklePower_walk_sort(j,:) = interp1(ankleAngle_walk_sort(j,:),anklePower_walk(j,walk_sort_ind(j,:)),theta_ROM,'linear',0);
% end


% --------------------------- Sit-to-Stand Data ---------------------------
% Angles
kneeAngle_sitStand = (sitStand_Friedl.SitStand.JointAngles.KneeAngles_mean); %+ sitStand_Friedl.SitStand.JointAngles.KneeAngles_std;

ankleAngle_sitStand = (sitStand_Friedl.SitStand.JointAngles.AnkleAngles_mean); %+ sitStand_Friedl.SitStand.JointAngles.AnkleAngles_std;
% Angles
kneeMoment_sitStand = abs(sitStand_Friedl.SitStand.JointMoments.KneeMoments_mean); %+ sitStand_Friedl.SitStand.JointMoments.KneeMoments_std;

ankleMoment_sitStand = abs(sitStand_Friedl.SitStand.JointMoments.AnkleMoments_mean); %+ sitStand_Friedl.SitStand.JointMoments.AnkleMoments_std;

% Velocity
kneeVelocity_sitStand = deg2rad(abs(sitStand_Friedl.SitStand.JointVelocities.KneeVelocities_mean)); %+ sitStand_Friedl.SitStand.JointVelocities.KneeVelocities_std;

ankleVelocity_sitStand = deg2rad(abs(sitStand_Friedl.SitStand.JointVelocities.AnkleVelocities_mean)); %+ sitStand_Friedl.SitStand.JointVelocities.AnkleVelocities_std;

% Power
kneePower_sitStand = abs(sitStand_Friedl.SitStand.JointPowers.KneePowers_mean); %+ sitStand_Friedl.SitStand.JointPowers.KneePowers_std;

anklePower_sitStand = abs(sitStand_Friedl.SitStand.JointPowers.AnklePowers_mean); %+ sitStand_Friedl.SitStand.JointPowers.AnklePowers_std;

[kneeAngle_sitStand_sort, sitStand_sort_ind] = sort(kneeAngle_sitStand,2);
% for j = 1:size(kneeAngle_sitStand_sort)
%     kneeMoment_sitStand_sort(j,:) = interp1(kneeAngle_sitStand_sort(j,:),kneeMoment_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneeVelocity_sitStand_sort(j,:) = interp1(kneeAngle_sitStand_sort(j,:),kneeVelocity_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneePower_sitStand_sort(j,:) = interp1(kneeAngle_sitStand_sort(j,:),kneePower_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
% end

[ankleAngle_sitStand_sort, sitStand_sort_ind] = sort(ankleAngle_sitStand,2);
% for j = 1:size(ankleAngle_sitStand_sort)
%     ankleMoment_sitStand_sort(j,:) = interp1(ankleAngle_sitStand_sort(j,:),ankleMoment_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
%     ankleVelocity_sitStand_sort(j,:) = interp1(ankleAngle_sitStand_sort(j,:),ankleVelocity_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
%     anklePower_sitStand_sort(j,:) = interp1(ankleAngle_sitStand_sort(j,:),anklePower_sitStand(j,sitStand_sort_ind(j,:)),theta_ROM,'linear',0);
% end


% --------------------------- Stand-to-Sit Data ---------------------------
% Angles
kneeAngle_standSit = (sitStand_Friedl.StandSit.JointAngles.KneeAngles_mean); %+ sitStand_Friedl.StandSit.JointAngles.KneeAngles_std;

ankleAngle_standSit = (sitStand_Friedl.StandSit.JointAngles.AnkleAngles_mean); %+ sitStand_Friedl.StandSit.JointAngles.AnkleAngles_std;
% Moments
kneeMoment_standSit = abs(sitStand_Friedl.StandSit.JointMoments.KneeMoments_mean); %+ sitStand_Friedl.StandSit.JointMoments.KneeMoments_std;

ankleMoment_standSit = abs(sitStand_Friedl.StandSit.JointMoments.AnkleMoments_mean); %+ sitStand_Friedl.StandSit.JointMoments.AnkleMoments_std;

% Velocity
kneeVelocity_standSit = deg2rad(abs(sitStand_Friedl.StandSit.JointVelocities.KneeVelocities_mean)); %+ sitStand_Friedl.StandSit.JointVelocities.KneeVelocities_std;

ankleVelocity_standSit = deg2rad(abs(sitStand_Friedl.StandSit.JointVelocities.AnkleVelocities_mean)); %+ sitStand_Friedl.StandSit.JointVelocities.AnkleVelocities_std;

% Power
kneePower_standSit = abs(sitStand_Friedl.StandSit.JointPowers.KneePowers_mean); %+ sitStand_Friedl.StandSit.JointPowers.KneePowers_std;

anklePower_standSit = abs(sitStand_Friedl.StandSit.JointPowers.AnklePowers_mean); %+ sitStand_Friedl.StandSit.JointPowers.AnklePowers_std;

[kneeAngle_standSit_sort, standSit_sort_ind] = sort(kneeAngle_standSit,2);
% for j = 1:size(kneeAngle_standSit_sort)
%     kneeMoment_standSit_sort(j,:) = interp1(kneeAngle_standSit_sort(j,:),kneeMoment_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneeVelocity_standSit_sort(j,:) = interp1(kneeAngle_standSit_sort(j,:),kneeVelocity_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneePower_standSit_sort(j,:) = interp1(kneeAngle_standSit_sort(j,:),kneePower_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
% end

[ankleAngle_standSit_sort, standSit_sort_ind] = sort(ankleAngle_standSit,2);
% for j = 1:size(ankleAngle_standSit_sort)
%     ankleMoment_standSit_sort(j,:) = interp1(ankleAngle_standSit_sort(j,:),ankleMoment_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
%     ankleVelocity_standSit_sort(j,:) = interp1(ankleAngle_standSit_sort(j,:),ankleVelocity_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
%     anklePower_standSit_sort(j,:) = interp1(ankleAngle_standSit_sort(j,:),anklePower_standSit(j,standSit_sort_ind(j,:)),theta_ROM,'linear',0);
% end


% ------------------------------ Stair Data -------------------------------
% Angles
% kneeAngle_stair_i42 = stair_Riener.i42.KneeAngles;
kneeAngle_stair_i30 = (stair_Riener.i30.KneeAngles);
kneeAngle_stair_i24 = (stair_Riener.i24.KneeAngles);
kneeAngle_stair_in24 = (stair_Riener.in24.KneeAngles);
kneeAngle_stair_in30 = (stair_Riener.in30.KneeAngles);
% kneeAngle_stair_in42 = stair_Riener.in42.KneeAngles;

% ankleAngle_stair_i42 = stair_Riener.i42.AnkleAngles;
ankleAngle_stair_i30 = (stair_Riener.i30.AnkleAngles);
ankleAngle_stair_i24 = (stair_Riener.i24.AnkleAngles);
ankleAngle_stair_in24 = (stair_Riener.in24.AnkleAngles);
ankleAngle_stair_in30 = (stair_Riener.in30.AnkleAngles);
% ankleAngle_stair_in42 = stair_Riener.in42.AnkleAngles;

% Moments
% kneeMoment_stair_i42 = stair_Riener.i42.KneeMoments;
kneeMoment_stair_i30 = abs(stair_Riener.i30.KneeMoments);
kneeMoment_stair_i24 = abs(stair_Riener.i24.KneeMoments);
kneeMoment_stair_in24 = abs(stair_Riener.in24.KneeMoments);
kneeMoment_stair_in30 = abs(stair_Riener.in30.KneeMoments);
% kneeMoment_stair_in42 = stair_Riener.in42.KneeMoments;

% ankleMoment_stair_i42 = stair_Riener.i42.AnkleMoments;
ankleMoment_stair_i30 = abs(stair_Riener.i30.AnkleMoments);
ankleMoment_stair_i24 = abs(stair_Riener.i24.AnkleMoments);
ankleMoment_stair_in24 = abs(stair_Riener.in24.AnkleMoments);
ankleMoment_stair_in30 = abs(stair_Riener.in30.AnkleMoments);
% ankleMoment_stair_in42 = stair_Riener.in42.AnkleMoments;
% Velocity
% kneeVelocity_stair_i42 = stair_Riener.i42.KneeVelocities;
kneeVelocity_stair_i30 = abs(stair_Riener.i30.KneeVelocities);
kneeVelocity_stair_i24 = abs(stair_Riener.i24.KneeVelocities);
kneeVelocity_stair_in24 = abs(stair_Riener.in24.KneeVelocities);
kneeVelocity_stair_in30 = abs(stair_Riener.in30.KneeVelocities);
% kneeVelocity_stair_in42 = stair_Riener.in42.KneeVelocities;

% ankleVelocity_stair_i42 = stair_Riener.i42.AnkleVelocities;
ankleVelocity_stair_i30 = abs(stair_Riener.i30.AnkleVelocities);
ankleVelocity_stair_i24 = abs(stair_Riener.i24.AnkleVelocities);
ankleVelocity_stair_in24 = abs(stair_Riener.in24.AnkleVelocities);
ankleVelocity_stair_in30 = abs(stair_Riener.in30.AnkleVelocities);
% ankleVelocity_stair_in42 = stair_Riener.in42.AnkleVelocities;

% Power
% kneePower_stair_i42 = stair_Riener.i42.KneePowers;
kneePower_stair_i30 = abs(stair_Riener.i30.KneePowers);
kneePower_stair_i24 = abs(stair_Riener.i24.KneePowers);
kneePower_stair_in24 = abs(stair_Riener.in24.KneePowers);
kneePower_stair_in30 = abs(stair_Riener.in30.KneePowers);
% kneePower_stair_in42 = stair_Riener.in42.KneePowers;

% anklePower_stair_i42 = stair_Riener.i42.AnklePowers;
anklePower_stair_i30 = abs(stair_Riener.i30.AnklePowers);
anklePower_stair_i24 = abs(stair_Riener.i24.AnklePowers);
anklePower_stair_in24 = abs(stair_Riener.in24.AnklePowers);
anklePower_stair_in30 = abs(stair_Riener.in30.AnklePowers);
% anklePower_stair_in42 = stair_Riener.in42.AnklePowers;

kneeAngle_stair = [kneeAngle_stair_i30; kneeAngle_stair_i24; kneeAngle_stair_in24; kneeAngle_stair_in30];
kneeMoment_stair = [kneeMoment_stair_i30; kneeMoment_stair_i24; kneeMoment_stair_in24; kneeMoment_stair_in30];
kneeVelocity_stair = deg2rad([kneeVelocity_stair_i30; kneeVelocity_stair_i24; kneeVelocity_stair_in24; kneeVelocity_stair_in30]);
kneePower_stair = [kneePower_stair_i30; kneePower_stair_i24; kneePower_stair_in24; kneePower_stair_in30];

[kneeAngle_stair_sort, stair_sort_ind] = sort(kneeAngle_stair,2);
% for j = 1:size(kneeAngle_stair_sort)
%     kneeMoment_stair_sort(j,:) = interp1(kneeAngle_stair_sort(j,:),kneeMoment_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneeVelocity_stair_sort(j,:) = interp1(kneeAngle_stair_sort(j,:),kneeVelocity_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
%     kneePower_stair_sort(j,:) = interp1(kneeAngle_stair_sort(j,:),kneePower_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
% end
ankleAngle_stair = [ankleAngle_stair_i30; ankleAngle_stair_i24; ankleAngle_stair_in24; ankleAngle_stair_in30];
ankleMoment_stair = [ankleMoment_stair_i30; ankleMoment_stair_i24; ankleMoment_stair_in24; ankleMoment_stair_in30];
ankleVelocity_stair = deg2rad([ankleVelocity_stair_i30; ankleVelocity_stair_i24; ankleVelocity_stair_in24; ankleVelocity_stair_in30]);
anklePower_stair = [anklePower_stair_i30; anklePower_stair_i24; anklePower_stair_in24; anklePower_stair_in30];
[ankleAngle_stair_sort, stair_sort_ind] = sort(ankleAngle_stair,2);
% for j = 1:size(ankleAngle_stair_sort)
%     ankleMoment_stair_sort(j,:) = interp1(ankleAngle_stair_sort(j,:),ankleMoment_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
%     ankleVelocity_stair_sort(j,:) = interp1(ankleAngle_stair_sort(j,:),ankleVelocity_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
%     anklePower_stair_sort(j,:) = interp1(ankleAngle_stair_sort(j,:),anklePower_stair(j,stair_sort_ind(j,:)),theta_ROM,'linear',0);
% end


%% Insert Your Code Here
 % variable names are as such: [joint][Metric]_[activity] and will include
 % all version of the activity (eg all inclines)
 % ex: ankleAngle_walk
 close all
 gait_phase = 0:(100/149):100;
 %Walking
 subplot(6,3,1)
 hold on
 plot(gait_phase,ankleAngle_walk_s1_i0,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_walk_s1_i0,'Color',[60,179,113]./255,'LineWidth',3)
 title('Walking'); xlabel('Gait Phase'); ylabel('Joint Angle')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,2)
 hold on
 walking_ratio = ankleAngle_walk_s1_i0./kneeAngle_walk_s1_i0;
 plot(gait_phase,walking_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Walking'); xlabel('Gait Phase'); ylabel('Gear Ratio [Knee/Ankle]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 %Sit To Stand
 subplot(6,3,4)
 hold on
 plot(gait_phase,ankleAngle_standSit,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_standSit,'Color',[60,179,113]./255,'LineWidth',3)
 title('Sit to Stand'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,5)
 hold on
 sit_stand_ratio = ankleAngle_standSit./kneeAngle_standSit;
 plot(gait_phase,sit_stand_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Sit to Stand'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 %Upstairs
 subplot(6,3,7)
 hold on
 plot(gait_phase,ankleAngle_stair_i24,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_stair_i24,'Color',[60,179,113]./255,'LineWidth',3)
 title('Upstairs'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,8)
 hold on
 upstair_ratio = ankleAngle_stair_i24./kneeAngle_stair_i24;
 plot(gait_phase,upstair_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Upstairs'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 %Inclines
 subplot(6,3,10)
 hold on
 plot(gait_phase,ankleAngle_walk_s1_i10,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_walk_s1_i10,'Color',[60,179,113]./255,'LineWidth',3)
 title('Inclines'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,11)
 hold on
 incline_ratio = ankleAngle_walk_s1_i10./kneeAngle_walk_s1_i10;
 plot(gait_phase,incline_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Inclines'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 %Declines
 subplot(6,3,13)
 hold on
 plot(gait_phase,ankleAngle_walk_s1_in10,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_walk_s1_in10,'Color',[60,179,113]./255,'LineWidth',3)
 title('Declines'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,14)
 hold on
 decline_ratio = ankleAngle_walk_s1_in10./kneeAngle_walk_s1_in10;
 plot(gait_phase,decline_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Declines'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 %Downstairs
 subplot(6,3,16)
 hold on
 plot(gait_phase,ankleAngle_stair_in24,'Color',[65,106,225]./255,'LineWidth',3)
 plot(gait_phase,kneeAngle_stair_in24,'Color',[60,179,113]./255,'LineWidth',3)
 title('Downstairs'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);
 subplot(6,3,17)
 hold on
 downstair_ratio = ankleAngle_stair_in24./kneeAngle_stair_in24;
 plot(gait_phase,downstair_ratio,'Color',[47,79,79]./255,'LineWidth',3)
 title('Downstairs'); xlabel('Gait Phase'); ylabel('Gear Ratio [Ankle/Knee]')
 set(gcf,'color','w'); set(gca,'linewidth',2);

 figure(10)
 hold on
 plot(gait_phase,kneeMoment_walk_s1_i0)
 plot(gait_phase,kneeMoment_walk_s1_i10)
 plot(gait_phase,kneeMoment_walk_s1_in10)
 legend('Level','Incline','Decline')
 title('Knee Torque')
 % plot(gait_phase,ankleMoment_walk_s1_i0)


 figure(11)
 hold on
 plot(gait_phase,ankleMoment_walk_s1_i0)
 plot(gait_phase,ankleMoment_walk_s1_i10)
 plot(gait_phase,ankleMoment_walk_s1_in10)
 legend('Level','Incline','Decline')
 title('Ankle Torque')
 % plot(gait_phase,ankleMoment_walk_s1_i0)






