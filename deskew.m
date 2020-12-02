function im_deskew = deskew(im_og, sigma, num_peaks, fill_value)
%DESKEW Deskew image to nearest axis.
%   Align an image with one of the 4 main axes.
%
%   Input Arguments
%   ---------------
%   im_og - Grayscale image to deskew.
%   sigma - Sigma for Canny edge detector.
%   num_peaks - Max number of peaks to take from hough transform.
%   fill_value - Value to fill in the added margins with when rotating.
%
%   Ported to MATLAB from Python:
%       https://github.com/sbrunner/deskew
%

    %% Debug parameter: set to 1 to show plots.
    DEBUG = 1;
    

    %% Set default args.
    if nargin < 2
        sigma = sqrt(2);
    end
    
    if nargin < 3
        num_peaks = 20;
    end
    
    if nargin < 4
        fill_value = 255;
    end
    
    
    %% Check input args.
    % Ensure image is grayscale.
    assert(length(size(im_og)) == 2, 'Input image must be grayscale');
    % Ensure image is double.
    assert(isa(im_og, 'double'), 'Input image must be type double.');

    
    %% Helpers
    function max_freq_elts = get_max_freq_elt(peaks)
    % Get most frequent elements from array.
        unique_vals = unique(peaks);
        freqs = histc(peaks, unique_vals);
        max_freq = max(freqs);
        mode_indices = find(freqs == max_freq);
        max_freq_elts = peaks(mode_indices);
    end

    function deviation = calculate_deviation(angle)
        angle_in_degrees = abs(angle);
        deviation = abs(pi/4 - angle_in_degrees);
    end

    function result = compare_sum(value)
        result = (44 <= value) & (value <= 46);
    end

    
    %% Main
    % Crop out the borders, where there is likely to be noise (false
    % positive lines) due to the intersection of the page and the 
    % background.
    [h, w] = size(im_og);
    h_cut = round(h * 0.05);
    w_cut = round(w * 0.05);
    xmin = 1 + w_cut;
    ymin = 1 + h_cut;
    xmax = w - w_cut;
    ymax = h - h_cut;
    im = im_og(ymin:ymax, xmin:xmax);
    
    % Canny edges.
    edges = edge(im, 'canny', [], sigma);

    % Hough transform.
    % out       = H     (hough transform matrix)
    % angles    = theta 
    % distances = rho
    [out, angles, distances] = hough(edges);

    % Take peaks of hough transform.
    peaks = houghpeaks(out, num_peaks);

    % Determine lines from hough peaks.
    min_length = sqrt(h^2 + w^2) * 0.025;
    lines = houghlines(edges, angles, distances, peaks, 'FillGap', 5, 'MinLength', min_length);

    % Extract angles of lines.
    angle_peaks = zeros(1, length(lines));
    for i=1:length(lines)
        lin = lines(i);
        angle_peaks(i) = deg2rad(lin.theta);
    end


    absolute_deviations = zeros(1, length(angle_peaks));
    for i=1:length(angle_peaks)
        absolute_deviations(i) = calculate_deviation(angle_peaks(i));
    end
    average_deviation = mean(rad2deg(absolute_deviations));
    
    
    % Bin the angles to the nearest 45 degree bin.
    bin_0_45 = [];
    bin_45_90 = [];
    bin_0_45n = [];
    bin_45_90n = [];
    angle_peaks_degree = rad2deg(angle_peaks);
    for i=1:length(angle_peaks_degree)
        angle = angle_peaks_degree(i);

        deviation_sum = fix(90 - angle + average_deviation);
        if compare_sum(deviation_sum)
            bin_45_90 = [bin_45_90; angle];
            continue;
        end

        deviation_sum = fix(angle + average_deviation);
        if compare_sum(deviation_sum)
            bin_0_45 = [bin_0_45; angle];
            continue;  
        end

        deviation_sum = fix(-angle + average_deviation);
        if compare_sum(deviation_sum)
            bin_0_45n = [bin_0_45n; angle];
            continue;
        end

        deviation_sum = fix(90 + angle + average_deviation);
        if compare_sum(deviation_sum)
            bin_45_90n = [bin_45_90n; angle];
        end

    end
    
    % Gather the angle bins.
    angles = [bin_0_45; bin_45_90; bin_0_45n; bin_45_90n];

    % Determine largest bin.
    nb_angles_max = 0;
    max_angle_index = -1;
    for angle_index=1:length(angles)
        angles_in_bin = angles(angle_index);
        bin_size = length(angles_in_bin);
        if bin_size > nb_angles_max
            nb_angles_max = bin_size;
            max_angle_index = angle_index;
        end
    end
    
    % Determine angle from the bins.
    if nb_angles_max ~= 0
       ans_arr = get_max_freq_elt(angles(max_angle_index));
       angle = mean(ans_arr);
    elseif ~isempty(angle_peaks_degree)
        ans_arr = get_max_freq_elt(angle_peaks_degree);
        angle = mean(ans_arr);
    else
        % If the algorithm fails, then don't rotate.
        angle = 0;
    end

    % Deskew image.
    im_deskew = rotate_image(im_og, angle, fill_value);


    %% Debugging
    if DEBUG
        figure;
        set(gcf, 'units', 'normalized', 'position', [0.05, 0.05, 0.60, 0.60])
        subplot(1, 2, 1);
        imshow(im);
        title('Lines Used to Estimate Skew');
        hold on;
        axis tight;
        
        max_len = 0;
        for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

           % Plot beginnings and ends of lines
           plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

           % Determine the endpoints of the longest line segment
           len = norm(lines(k).point1 - lines(k).point2);
           if ( len > max_len)
              max_len = len;
           end
        end
        
        subplot(1, 2, 2);
        imshow(im_deskew);
        title('De-Skewed Image');
        axis tight;
        
    end
    
end
