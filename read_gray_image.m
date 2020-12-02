function im_gray = read_gray_image(im_path)
%READ_GRAY_IMAGE Read image as grayscale.
%   
% `im_path` - Path to image to read.
%

    im_gray = im2double(imread(im_path));
    if length(size(im_gray)) == 3
        im_gray = rgb2gray(im_gray);
    end

end
