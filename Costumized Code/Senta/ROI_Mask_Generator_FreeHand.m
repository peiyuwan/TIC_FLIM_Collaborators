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
    if cond_folder(cond_idx).name == "DS_Store"
        continue
    end
    
    ind_folder = dir(fullfile(DataFolder,cond_folder(cond_idx).name));
    for ind_idx = 3: numel(ind_folder)
        if ind_folder(ind_idx).name == "DS_Store"
            continue
        end
    
        samp_folder = dir(fullfile(ind_folder(ind_idx).folder,ind_folder(ind_idx).name));
        for samp_idx = 3: numel(samp_folder)
            if samp_folder(samp_idx).name == "DS_Store"
                continue
            end
            
            data_folder = fullfile(samp_folder(samp_idx).folder,samp_folder(samp_idx).name);
            
            imageFile = dir(fullfile(data_folder,'*.tif'));
            mask_folder = fullfile(data_folder,'ROI_Mask');
            if ~exist(mask_folder,'dir')
                mkdir(mask_folder)
            end
            
            %% Reading in the mask channels
            mask_org = imread(fullfile(data_folder,imageFile(mask_ch+1).name));
            
            figure; set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            ax = imagesc(mask_org); axis image; colorbar; title("Original Mask"); colormap(gca,hot);
            
            
            %% Select Square region:
            
            while 1
                
                mask_img = zeros(size(mask_org));
                H=drawfreehand('color','m','closed',true,'Linewidth',2);
                
                add_mask = H.createMask;
                
                
                button = questdlg("Add Another Region?", 'Next?', ...
                    'Add to Current Mask', 'Redo','Done(with this round)',...
                    'Add to Current Mask');
                
                if strcmp(button, 'Done(with this round)')
                    mask_img(add_mask == 1) = 1;
                    break
                elseif strcmp(button, 'Add to Current Mask')
                    mask_img(add_mask == 1) = 1;
                                      
                else
                    delete(H)
                end
                
                
            end
            
            %%
            t = Tiff(fullfile(mask_folder,"Mask.tif"),'w');
            
            tagstruct.ImageLength = size(mask_org,1);
            tagstruct.ImageWidth =size(mask_org,2);
            
            setTag(t,tagstruct);
            write(t,uint8(mask_img));
            writeDirectory(t);
        end
    end
end

%%