function [x_perc] = mm2perc(x_mm,x_center_max,x_center_min)
    x_perc = ((x_center_max-x_mm)./(x_center_max-x_center_min))*100;
end