function [theta_cam_violations] = check_theta_cam(theta_cam)
    theta_cam_violations = [];
    % CHECK IF MATH EXPLOITS NONMONOTONIC THETA_CAM TO BYPASS STIFFNESS STIFFNESS LIMITS(Second check for nonrealizable geometry)
    for i = 2:length(theta_cam)
        if((theta_cam(i)-theta_cam(i-1))<=0) 
            theta_cam_violations = [theta_cam_violations; [i rad2deg(theta_cam(i))]];
        end
    end
    if(isempty(theta_cam_violations)==0)
        disp('Error: cam has unfeasable geometry in theta_cam')
    end
end