function VSPA_configuration()
clear
% close all

%% MAIN
% I hvae two ways to characterize the torque dropfoot. 1) simply find
% from CAD the CoM of the prosthesis and apply the weight of the device. Or 2)
% model the backdrivability of the device to get more accurate system
Torque_DropFoot = 0; %Nm at the moment set this to 0
% do that at max dorsiflexion angle
ROM_thresh = deg2rad(16.62); %(deg) dorsiflexion angle that cam forces will be evaluated at  -- peak torque at dorsiflexion ish
%     ROM_thresh = deg2rad(7);
theta_eval_dorsi = 4; %15.5 for a single cam ICORR and 15 for dual cam Biorob
theta_eval_plantar = -12; %15.5 for a single cam ICORR and 15 for dual cam Biorob
preload = 0.003; %(rad) prevents backlash, but should be small as it also places pressure on the spring support
primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

%Geometric Parameters
y_center = 0.008;%0.012;% (meters) Distance between top of simple support (contact point under the spring) and cam roller axis
lead_screw = 55.9; %mm
x_center_min = 32.5; %(mm) most stiff position in spring support stroke --- measured from CAD
x_center_max = x_center_min + lead_screw; %(mm) least stiff position in spring support stroke ---
r0 = 0.0435; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)

spring = 'instron';
cam = 'single';
%ta_input = 'VSPA'; %poweredVSPA VSPA
%max_spring = 1;
%max_FEA_only = 1;
%FEA_peak = 1;
%spring_change = 'width';%'modifywidthheight';%'length'; % 'widthlength' 'width' 'length' 'widthlengthheight'
%zero_origin = 1;
roller_radius = 0.0095; %(meters) %Cam roller radius
% roller_radius = 0.006; %(meters) %FPL412
% kdelt_dorsi = 650; %dual cam biorob
% kdelt_plantar = 350; %dual cam biorob
% if (strcmp(spring_change,'length'))
%     x_center_min = 22.5;
%     x_center_max = x_center_min + lead_screw;
% end
% if (strcmp(spring_change,'widthlength'))
%     x_center_min = 22.5;
%     x_center_max = x_center_min + lead_screw;
% end
% if (strcmp(spring_change,'widthlengthheight'))
%     x_center_min = 22.5;
%     x_center_max = x_center_min + lead_screw;
% end
% if max_spring == 1
%     kdelt_dorsi = 2000; % estimate of the series frame compliance
%     kdelt_plantar = kdelt_dorsi; % check
% else
%     kdelt_dorsi = 1700; % estimate of the series frame compliance
%     kdelt_plantar = kdelt_dorsi; % check
% end
kdelt_dorsi = 2200;
kdelt_plantar = 2100;

save('inputs/VSPA_configuration')
end