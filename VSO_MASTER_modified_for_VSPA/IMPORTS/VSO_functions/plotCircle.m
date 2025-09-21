function [x_circle, y_circle] = plotCircle(h, k, r)
    % Generate values for theta
    theta = linspace(0, 2*pi, 100);
    % Parametric equations for the circle
    x_circle = h + r * cos(theta);
    y_circle = k + r * sin(theta);
end