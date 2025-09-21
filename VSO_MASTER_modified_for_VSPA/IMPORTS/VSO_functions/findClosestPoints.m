function [x1_closest, y1_closest, x2_closest, y2_closest] = findClosestPoints(curve1, curve2)
    % curve1 and curve2 are 2xn matrices where the first row contains x values and the second row contains y values

    % Ensure the input matrices are in the correct format
    assert(size(curve1, 1) == 2, 'curve1 should be a 2xn matrix');
    assert(size(curve2, 1) == 2, 'curve2 should be a 2xn matrix');

    % Remove duplicate x values and interpolate the y values accordingly
    [unique_x1, unique_idx1] = unique(curve1(1, :));
    y1_unique = curve1(2, unique_idx1);
    interp1_curve1 = @(x) interp1(unique_x1, y1_unique, x, 'spline');

    [unique_x2, unique_idx2] = unique(curve2(1, :));
    y2_unique = curve2(2, unique_idx2);
    interp1_curve2 = @(x) interp1(unique_x2, y2_unique, x, 'spline');

    % Generate a fine grid of points along both curves
    x1_vals = linspace(min(unique_x1), max(unique_x1), 1000);
    x2_vals = linspace(min(unique_x2), max(unique_x2), 1000);

    % Initialize minimum distance
    min_dist = Inf;

    % Loop through all points on curve1 and curve2 to find the closest pair
    for i = 1:length(x1_vals)
        for j = 1:length(x2_vals)
            x1 = x1_vals(i);
            y1 = interp1_curve1(x1);
            x2 = x2_vals(j);
            y2 = interp1_curve2(x2);
            
            dist = sqrt((x1 - x2)^2 + (y1 - y2)^2);
            
            if dist < min_dist
                min_dist = dist;
                x1_closest = x1;
                y1_closest = y1;
                x2_closest = x2;
                y2_closest = y2;
            end
        end
    end
    
    % Display the closest points
    fprintf('Closest points are (%.6f, %.6f) on curve1 and (%.6f, %.6f) on curve2 with a distance of %.6f\n', ...
        x1_closest, y1_closest, x2_closest, y2_closest, min_dist);
end
