%% Generate Mask For ROI plots
% Peiyu Wang
% 10/10/2020

% Mask is generated for the exported Leica Falcon Lifetime image. The masks
% will be stored under a different folder with name "ROI_Mask", with the
% name ControlMask.tif 

% Expected export method: Tiff Files, with Fast FLim included

close all; clear all;

%% Hyper Parameters
% Please adjust the following parameters according to your needs

DataFolder = "D:\Scotts Lab\Collaborations\For Senta\Processed Pics";
% Where the data is stored
z_stacks = 1;      % Number os Z_stacks
mask_base_ch = 5;  % Which detector sequence to base the mask creation on.
mask_ch = 4;  % the channel number you want to create the mask on. XX according to chXX.
plot_color = ['r','m','g','c','y','w'];  % Order of colors displayed. Does not effect the ROI exportion.


%% Tiff file format parameters. Please don't change.
tagstruct.SampleFormat = 1;
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
tagstruct.BitsPerSample = 8;
tagstruct.SamplesPerPixel = 1;
tagstruct.Compression = Tiff.Compression.None;
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;

%% Data Read in
cond_folder = dir(DataFolder);
for cond_idx = 3:numel(cond_folder)
    ind_folder = dir(fullfile(DataFolder,cond_folder(cond_idx).name));
    for ind_idx = 3: numel(ind_folder)
        samp_folder = dir(fullfile(ind_folder(ind_idx).folder,ind_folder(ind_idx).name));
        for samp_idx = 3: numel(samp_folder)
            data_folder = fullfile(samp_folder(samp_idx).folder,samp_folder(samp_idx).name);
            
            imageFile = dir(fullfile(data_folder,'*.tif'));
            mask_folder = fullfile(data_folder,'ROI_Mask');
            if ~exist(mask_folder,'dir')
                mkdir(mask_folder)
            end
            
            %% Reading in the mask channels
            mask_org = imread(fullfile(data_folder,imageFile(mask_ch+1).name));
            
            figure; set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            imagesc(mask_org); axis image; colorbar; title("Original Mask");colormap(gca,hot);
            
            
            %% Select Square region:
            square_length = 200;  % Adjust this according to your desired square length
            square_number = 4;  % enter how many regions you want to make use
            
            while 1
                
                mask_img = zeros(size(mask_org));
                for i = 1: square_number
                    [x,y] = ginput(1);
                    disp("selected one")
                    x_start = x-square_length/2;  x_end = x+square_length/2-1;
                    y_start = y-square_length/2;  y_end = y+square_length/2-1;
                    
                    if x_start < 1; x_start = 1; x_end = square_length; x= square_length/2; end
                    if y_start< 1; y_start = 1; y_end = square_length; y = square_length/2; end
                    if x_end > size(mask_org,1); x_start = size(mask_org,1)-square_length+1; x = size(mask_org,1)-square_length/2; x_end =  size(mask_org,1); end
                    if y_end > size(mask_org,2); y_start = size(mask_org,2)-square_length+1; y =  size(mask_org,2)-square_length/2; y_end =  size(mask_org,2); end
                    
                    hold on;
                    h = rectangle('Position',[x_start,y_start,square_length,square_length],'LineWidth',1,'LineStyle','--','EdgeColor','w')
                    
                    mask_img(x_start:x_end,y_start:y_end) = 1;
                end
                promptMessage = ["Pixel Count: " + num2str(sum(mask_img(:))) + ". Reselect region?"];
                button = questdlg(promptMessage, 'Next?','Yes','No','Yes');
                if strcmp(button, 'No')
                    break
                else
                    close all;
                    figure; set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
                    imagesc(mask_org); axis image; colorbar; title("Original Mask");colormap(gca,hot);
                    mask_img = zeros(size(mask_org));
                end
            end
            
            %%
            t = Tiff(fullfile(mask_folder,"ControlMask.tif"),'w');
            
            tagstruct.ImageLength = size(mask_org,1);
            tagstruct.ImageWidth =size(mask_org,2);
            
            setTag(t,tagstruct);
            write(t,uint8(mask_img));
            writeDirectory(t);
        end
    end
end

%%