function TA_function_poweredVSPA(perc,ta_input, zero_origin)
    %here input the 
    %BLACK
    % load('old/can_lin_cam4_cam5_cam6_RAMTECH')
    % cam_tango_lin()
    % load('ottobock/cam_tango_lin')
    % cam_tango_up()
    % load('ottobock/cam_tango_up')
%     cam_tango_down()
%     load('ottobock/cam_tango_down')
    % import the mean of bovi, camargo, rieznick datasets
    switch ta_input
        case 'poweredVSPA'
            load("TA/datasets/data.mat")
            cam_no_plant(dat, perc, zero_origin)
            load("TA\datasets\cam_no_plant")
            %Save
            save('inputs/TA_function_poweredVSPA')
        case 'VSPA'
            load("TA/datasets/data.mat")
            cam_vspa(dat, perc)
            load("TA\datasets\cam_vspa")
            save('inputs/TA_function_poweredVSPA')
        otherwise
            disp('wrong')
    end


    %BLUE
    %WT used the two cams below and the three ottobock functions above

    %Wave Cam and Neg Cam
    % negative_stiffness_1()
    % load('wearable_tech/negative_stiffness_1')

    % cam_down_zero_plantar()
    % load('ottobock/cam_down_zero_plantar')
    

    %OLD
    % cam_final()
    % load('cam_final')
    % load('cam_final_stiffeq')
    % cam_final_linear()
    % load('cam_final_linear')
    % stiffness_limit()
    % load('stiffness_limit')
    % load('cam_buckling')
    % load('psi_curvey_fuction_investigation')


end