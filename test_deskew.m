%% CMD ARGS
input_dir = './test_images';
extension = '.png';
TARGET_DIAGONAL_SIZE = 2000;


%% Add src folder to path.
addpath('./src');


%% Main
% Ensure input_dir is a path to an existing directory.
assert(exist(input_dir, 'dir') == 7, 'Input directory does not exist.');

% Process each JPG image file.
im_files = dir(sprintf("%s/*.%s", input_dir, extension));
for file_idx=1:length(im_files)
    % Build image path.
    im_file = im_files(file_idx);
    im_path = fullfile(im_file.folder, im_file.name);
    fprintf('Processing file: %s\n', im_path);

    % Read image and normalize size.
    im = read_gray_image(im_path);
    im_norm = normalize_image_size(im, TARGET_DIAGONAL_SIZE);
    
    % Deskew the image.
    im_deskew = deskew(im_norm);
    
%     % Save the figure.
%     [~,stem,~] = fileparts(im_path);
%     fig_name = sprintf('%s__out.png', stem);
%     fig_path = fullfile('readme_files', fig_name);
%     saveas(gcf, fig_path);
end
