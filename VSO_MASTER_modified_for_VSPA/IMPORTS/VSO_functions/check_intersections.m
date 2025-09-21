function [intersections] = check_intersections(curve_x,curve_y,theta_total)
    intersections = [];
    for i = 2:length(curve_y)
        if((curve_y(i)-curve_y(i-1))<=0) 
            % intersections = [intersections; [i rad2deg(theta_total(i)) curve_x(i) curve_y(i)]];
            intersections = [intersections; i];
        end
    end
    if(isempty(intersections)==0)
        disp('Error: intersections in cam. Check vector in the command window')
    end
end