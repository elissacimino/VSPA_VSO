function [curve_points] = Matlab2Solidworks(curve_x,curve_y)
    num_pts = 4300;
    if(length(curve_x)>num_pts)
        inc = round(length(curve_x)/num_pts,1);
        new_x = curve_x(2:inc:length(curve_x)); 
        new_y = interp1(curve_x,curve_y,new_x);
        curve_points = 1000*[new_x', new_y', 0.*new_x'];
    else
        curve_points = 1000*[curve_x', curve_y', 0.*curve_x'];
    end
end