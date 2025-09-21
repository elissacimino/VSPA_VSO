function conversions()
    clear
    % addpath('IMPORTS')
    mm2m = 1/1000;
    m2mm = 1000;
    cm2m = 1/100; 
    lb2N = 4.4482216282509;
    GPa2N_mm2 = 1000;
    radian2deg = 180/pi;
    degree2rad = pi/180;
    save('inputs/conversions.mat')
end