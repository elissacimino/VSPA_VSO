function TA_function()
    %BLACK
    % load('old/can_lin_cam4_cam5_cam6_RAMTECH')
    % cam_tango_lin()
    % load('ottobock/cam_tango_lin')
    % cam_tango_up()
    % load('ottobock/cam_tango_up')
    cam_tango_down()
    load('ottobock/cam_tango_down')
    
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

    %Save
    save('inputs/TA_function')
end