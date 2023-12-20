%%
% Add SynQuant Java class into Matlab

add_java_path('add')

%% 
% load example image
% The image should be scaled to be between 0 to 1

image_1 = imread("2019-6-6 Bassoon488 - Homer564 - VGLU1647 - Control - 2.bmp");

image_1_double = im2double(image_1);

figure
imshow(image_1)

image_1_red = image_1(:,:,1);

image_1_green = image_1(:,:,2);

image_1_red = im2double(image_1_red);

image_1_green = im2double(image_1_green);

figure
imshow(image_1_red)

figure
imshow(image_1_green)


% the first one is assumed to be pre-synaptic, the second post-synaptic
dat_two_channel = {image_1_red, image_1_green};

%% 
% A naive noise estimation method
%
% SynQuant need an estimated noise standard deviation. 
% A more sophisticated version is implemented in the Fiji plug-in,
% but that method is not always robust.
% You can also choose any exisint single image noise estimation method.
%
% This naive method compare a pixel with its neighbor to estimate noise.
% For smmothed images, choose a larger gap value.

gap = 1;
dif = image_1_red(:, 1+gap:end) - image_1_red(:,1:end-gap);
dif2 = dif.*dif;
noise_estimated = sqrt(median(dif2(:)));
disp(noise_estimated)

%%
% Run SynQuant on two channels
% You need to provide minimum synapse size (here 10), and maximum size (here 50)
%
% Inputs:
%
% Note that there are two additional parameters for function "synquant_3d_two_channels". 
% They are useful when pre- and post- synaptic puncta do not spatially overlap well.
%
% dext: search in XY direction for pre-synaptic puncta. Larger value leads to consider more remote ones as pair.
% dextz: search in Z direction for pre-synaptic puncta. Larger value leads to consider more remote ones as pair.
%
%
% Outputs:
%
% out_overall: the map for the combined synapse
% res_per_channel: SynQuant results for each channel
%

[out_overall, res_per_channel] = synquant_3d_two_channels(dat_two_channel, noise_estimated, 10, 50, 0, 0);

% pixel or voxel list for each combined synapse
pixLst = bwconncomp(out_overall);

figure
imshow(out_overall)


%% 
% Count synapses


%threshold SynQuant output

BW = imbinarize(out_overall);

%figure
%imshow(BW)

%count with bwconncomp https://www.mathworks.com/help/images/ref/bwconncomp.html
CC = bwconncomp(BW);
synapse_count = CC.NumObjects

%write binarized image to a file

imwrite(BW, "2019-6-6 Bassoon488 - Homer564 - VGLU1647 - Control - 2_binary.tiff")

