%% Generate Mask For ROI plots
% Peiyu Wang
% 08/20/2020

% Mask is generated for the exported Leica Falcon Lifetime image. The masks
% will be stored under a different folder with name "ROI_Mask", with the
% name of the same file and mask.tif at the end.

% If multiple layers of ROIs were selected that are wished to be seperately
% processed, it will still be stored in the same file, just with different
% numbers inside the file.

% Expected exportion method: Tiff Files, with Fast FLim included

close all; clear all;

addpath(fullfile(pwd,'Functions'))
%% Hyper Parameters
% Please adjust the following parameters according to your needs

DataFolder = "D:\Scotts Lab\FLIM\Leica SP8\Leica Program\UnderDevelopment\Mask_Creation\Data1";
% Where the data is stored
detector_No = 2;   % Number of detectors exported
z_stacks = 2;      % Number os Z_stacks
mask_base_ch = 1;  % Which channel to base the mask creation on.
plot_color = ['r','m','g','c','y','w'];  % Order of colors displayed. Does not effect the ROI exportion.


%% Tiff file format parameters. Please don't change. 
tagstruct.SampleFormat = 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

%% Data Read in

imageFile = dir(fullfile(DataFolder,'*.tif'));
z_stacks = numel(imageFile)/detector_No/4;


mask_folder = fullfile(DataFolder,'ROI_Mask');
if ~exist(mask_folder,'dir')
    mkdir(mask_folder)
end

if detector_No<3;channel_con = '%01d';
else;channel_con = '%02d';end

figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
int = imread(fullfile(DataFolder,imageFile(1).name));
G = standardPhase(imread(fullfile(DataFolder,imageFile(3).name)));
S = standardPhase(imread(fullfile(DataFolder,imageFile(4).name)));
current_struct = struct('int',int,'G',G,'S',S);
red_map = cat(3,ones(size(int)),zeros(size(int))...
        ,zeros(size(int)));
subplot(1,2,1); imagesc(current_struct.int); axis image; colorbar; colormap jet;
ax = gca; ax.Colormap(1,:)=[0,0,0];
while 1
   thresh_struct = current_struct;
   low_thresh = input("Please input lower threshold: ");
   up_thresh = input("Please input upper threshold: ");
   thresh_struct.int((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   thresh_struct.G((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   thresh_struct.S((current_struct.int < low_thresh) | (current_struct.int > up_thresh)) = 0;
   subplot(1,2,1);
   hold on; 
   h = imshow(red_map);
   color_int = double(thresh_struct.int);
   color_int(thresh_struct.int~=0) = 0.8;
   set(h, 'AlphaData',  color_int);
   subplot(2,2,2); plotPhasorFast(medfiltPhasorFast(current_struct));title('Before Threshold')
   subplot(2,2,4); plotPhasorFast(medfiltPhasorFast(thresh_struct));title('After Threshold')
   
   promptMessage = "Reselect Thresholds?";
   button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
   if strcmp(button, 'No')
       break
   else
       delete(h);
   end
end

filename = 'Parameters.xlsx';
writecell({'Upper Threshold','Lower_threshold'},fullfile(mask_folder,filename),'Sheet',1,'Range','A1');
writematrix([up_thresh,low_thresh],fullfile(mask_folder,filename),'Sheet',1,'Range','A2');


figure;
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
for z = 1: z_stacks


    % Adjusting the read in names according to the number of z stacks.
    % Maximum z stacks is 100;
    if z_stacks == 1; current_z = '.tif';
    elseif z_stacks < 11; current_z = num2str(z-1.','z%01d');
    else; current_z = num2str(z-1.','z%02d'); end
    
    current_filename = [];
    for k = 1: numel(imageFile)
        if contains(imageFile(k).name,current_z) && contains(imageFile(k).name,['ch' num2str((mask_base_ch-1)*4,channel_con) '.tif'])
            %% Create Mask:
            
            org_img = imread(fullfile(DataFolder,imageFile(k).name));
            partial_name = regexp(imageFile(k).name, '\w*_z\w*_', 'match');
            org_img((org_img < low_thresh) | (org_img > up_thresh)) = 0;
            imagesc(org_img); axis image; colormap jet; colorbar;
            ax = gca; ax.Colormap(1,:)=[0,0,0];
            
            hold on;
            color_idx = 1; mask_idx = 1;
            
            current_mask = zeros(size(org_img,1),size(org_img,2));
            final_mask = zeros(size(org_img,1),size(org_img,2));
            while 1
                
                title(["Image: "+ partial_name+", Mask No.: "+num2str(mask_idx)]);
                H=drawfreehand('color',plot_color(color_idx),'closed',true,'Linewidth',1);
                pause
                add_mask = H.createMask;
                %                 mask_plot = plot(fix(find(add_mask == 1)/size(add_mask,1)),rem(find(add_mask == 1),size(add_mask,1)),'color',plot_color(color_idx),'Marker','.','LineStyle','none');
                button = questdlg("Add Another Region?", 'Next?', ...
                    'Add to Current Mask', 'Add Another Mask','Done(with this round)',...
                    'Add to Current Mask');
                if strcmp(button, 'Done(with this round)')
                    current_mask(add_mask == 1) = 1;
                    final_mask(:,:,mask_idx) = current_mask;
                    %                     imwrite(final_mask, fullfile(mask_folder,[partial_name+"mask.tif"]));
                    t = Tiff(fullfile(mask_folder,[partial_name+"mask.tif"]),'w');
                    
                    tagstruct.ImageLength = size(org_img,1);
                    tagstruct.ImageWidth =size(org_img,2);
                  
                    for ii=1:mask_idx
                        setTag(t,tagstruct);
                        write(t,uint8(final_mask(:,:,ii)));
                        writeDirectory(t);
                    end
                    close(t)
                    hold off                    
                    break
                elseif strcmp(button, 'Add to Current Mask')
                    current_mask(add_mask == 1) = 1;
                else
                    current_mask(add_mask == 1) = 1;
                    final_mask(:,:,mask_idx) = current_mask;
                    current_mask = zeros(size(org_img,1),size(org_img,2));
                    mask_idx = mask_idx+1;
                    
                    color_idx = color_idx+1;
                    if color_idx > numel(plot_color)
                        color_idx = 1;
                    end
                end
            end
        end
    end
end

%% Testing of the mask
% Please update '001_z0_mask.tif' with the name of the mask file, and the
% number 3 with the layer of mask you want to see. 

file_name = '001_z0_mask.tif';
selected_mask = 1; 
test_img = imread(fullfile(mask_folder,file_name),selected_mask);
figure
imagesc(test_img(:,:,1));axis image;

