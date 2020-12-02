function [im_resized, scale_factor] = normalize_image_size(im, target_diagonal_size)
%NORMALIZE_IMAGE_SIZE Normalize an image size.
%   Normalize an image by resizing it so it's diagonal length matches the
%   given target diagonal length in pixels.
im_size = size(im);
h = im_size(1);
w = im_size(2);
im_diag = sqrt(h^2 + w^2);
scale_factor = target_diagonal_size / im_diag;
im_resized = imresize(im, scale_factor);
end
