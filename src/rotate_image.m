function rotated_image = rotate_image(image, rot_angle_degree, fill_value)
% Rotate an image and fill in the background with given fill value.
%
%   `image` - the image to rotate.
%   `rot_angle_degree` - angle to rotate by, counterclockwise.
%   `fill_value` - integer to fill the background pixels with.
%
    tform = affine2d([cosd(rot_angle_degree)    -sind(rot_angle_degree)     0; ...
                      sind(rot_angle_degree)     cosd(rot_angle_degree)     0; ...
                      0                          0                          1]);

    rotated_image = imwarp(image, tform, 'interp', 'cubic', 'fillvalues', fill_value);
end
