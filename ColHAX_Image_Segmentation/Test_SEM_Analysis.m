% Citation: N/A (2023). Calculate the size of a grain in an SEM image 
% (https://www.mathworks.com/matlabcentral/fileexchange/124445-calculate-the-size-of-a-grain-in-an-sem-image), 
% MATLAB Central File Exchange. Retrieved July 6, 2023. 

% Load the SEM image
img = imread('2A2C.tif');
magnification=0.256;%(%pixels/microns)0.404
% Convert the image to grayscale
img_gray = im2gray(img);
% Apply a threshold to the image to segment the grains
img_threshold = img_gray > 128;
% Use bwlabel to identify the individual grains in the image
[labeled_img, num_grains] = bwlabel(img_threshold);
% Initialize a variable to hold the grain sizes
grain_sizes = zeros(1, num_grains);
% Loop over each grain in the image and calculate its size
for i = 1:num_grains
    grain_mask = labeled_img == i;
    grain_sizes(i) = sum(grain_mask(:));
end
% Calculate the average grain size
avg_grain_size = mean(grain_sizes);
avg_grain_um = avg_grain_size/magnification; 
% Print the average grain size to the command window
fprintf('The average grain size is %.2f um\n', avg_grain_um);