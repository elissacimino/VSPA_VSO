function Rotary_VSPA_configuration()
    clear
    % close all

    %% MAIN

    % I hvae two ways to characterize the torque dropfoot. 1) simply find
    % from CAD the CoM of the prosthesis and apply the weight of the device. Or 2)
    % model the backdrivability of the device to get more accurate system
    %Rotary VSPA: Estimated 700 g at (-59.167, -62.137)
    Torque_DropFoot = 0.70*9.81*58.654/1000; %Nm at the moment set this to 0
    
    % do that at max dorsiflexion angle
    ROM_thresh = deg2rad(20); %(deg) dorsiflexion angle that cam forces will be evaluated at  -- peak torque at dorsiflexion ish
    %     ROM_thresh = deg2rad(7);
    theta_eval_dorsi = 4; %15.5 for a single cam ICORR and 15 for dual cam Biorob
    theta_eval_plantar = -12; %15.5 for a single cam ICORR and 15 for dual cam Biorob
    preload = 0.003; %(rad) prevents backlash, but should be small as it also places pressure on the spring support
    primary_percentage = 0.5; %Normalized primary slider position along stroke [0-1] corresponds to [1-100%]

    %Geometric Parameters
    y_center = 0.010;% (meters) Distance between top of simple support (contact point under the spring) and cam roller axis
    lead_screw = 0; %mm
    x_center_min = 63; %(mm) most stiff position in spring support stroke --- measured from CAD
    x_center_max = x_center_min + lead_screw; %(mm) least stiff position in spring support stroke ---
    r0 = 0.0435; %0.03529 (meters) distance from ankle center to roller center (actual radius is smaller, but cam generated with math will be offset to account for this)
    x_off = 0; %(mm) if line from ankle center to center of cam roller is perpendicular to the bottom of the spring then leave this zero (otherwise might need to talk to Nikko)

    cam = 'rotary';
    spring = 'fixed';
    roller_radius = 0.0095; %(meters) %Cam roller radius
    kdelt_dorsi = 2000;
    kdelt_plantar = 2000;

    save('inputs/Rotary_VSPA_configuration')
end