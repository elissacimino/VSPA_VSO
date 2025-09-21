function [psi_violations] = check_psi(curve_x,curve_y,theta_total)
    psi_violations = [];
    % Check if psi is a function (Leading Hypothesis is that this is possible, but will lock spring and produce max stiffness)
    %Doesn't use psi and psi2 because we are evalating for the offset curve and not the progenitor curve
    psi_offset_err = atan(curve_y./curve_x);
    if (min(diff(psi_offset_err))<=0)
        psi_violations = [1];
    end
    if(isempty(psi_violations)==0)
        disp('Warning: offset cam curve is not a function in psi which may lock spring and produce peak stiffness')
    end
end