function [x_tangent, y_tangent] = findTangentPointFromData(curve1, curve2)
    % curve1 and curve2 are 2xn matrices where the first row contains x values and the second row contains y values
    
    % Ensure the input matrices are in the correct format
    assert(size(curve1, 1) == 2, 'curve1 should be a 2xn matrix');
    assert(size(curve2, 1) == 2, 'curve2 should be a 2xn matrix');
    
    % Interpolate the curves
    interp1_curve1 = @(x) interp1(curve1(1, :), curve1(2, :), x, 'spline');
    interp1_curve2 = @(x) interp1(curve2(1, :), curve2(2, :), x, 'spline');
    
    % Compute the derivatives using numerical differentiation
    df1 = @(x) (interp1_curve1(x + 1e-6) - interp1_curve1(x - 1e-6)) / (2e-6);
    df2 = @(x) (interp1_curve2(x + 1e-6) - interp1_curve2(x - 1e-6)) / (2e-6);
    
    % Define the function to find roots where the derivatives are equal
    tangent_eq = @(x) df1(x) - df2(x);
    
    % Find the intersection point by solving the equation
    x_initial_guess = (curve1(1, 1) + curve1(1, end)) / 2; % Initial guess for the solver
    x_tangent = fzero(tangent_eq, x_initial_guess);
    
    % Calculate the y-values at the tangent point
    y1 = interp1_curve1(x_tangent);
    y2 = interp1_curve2(x_tangent);
    
    % Check if y-values are approximately equal
    if abs(y1 - y2) < 1e-6
        y_tangent = y1; % or y2, they should be approximately equal
    else
        x_tangent = NaN;
        y_tangent = NaN;
        fprintf('No tangent point found.\n');
        return;
    end
    
    % Save the x, y position
    fprintf('Tangent point found at (%.6f, %.6f)\n', x_tangent, y_tangent);
end
