function R = radofcurv(r, theta)
% INPUTS:
    % r: 1-D vector of polar radius
    % theta: 1-D vector of polar angle (rad)
% OUTPUT:
    % R: radius of curvature across polar curve; (+) = convex, (-) = concave

    dr = dydx(r, theta);
    ddr = dydx(dr, theta);

    % https://mathworld.wolfram.com/RadiusofCurvature.html
    R = (r.^2 + dr.^2).^(3/2)./(r.^2 + 2*dr.^2 - r.*ddr);

end