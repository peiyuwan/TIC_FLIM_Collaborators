%% Generate Mask For ROI plots
% Peiyu Wang
% 07/05/2020

% Mask is generated for the exported Leica Falcon Lifetime image. The masks
% will be stored under a different folder with name "ROI_Mask". 

% Expected exportion method: Tiff Files, with Fast FLim included

close all; clear all;
%% Hyper Parameters
% Please adjust the following parameters according to your needs

DataFolder = "D:\Scotts Lab\FLIM\Leica SP8\Leica Program\UnderDevelopment\Mask_Creation\Data1";
% Where the data is stored
detector_No = 2;   % Number of detectors exported
z_stacks = 2;      % Number os Z_stacks 
mask_base_ch = 1;  % Which channel to base the mask creation on.
plot_color = ['r','m','g','c','y','w'];  % Order of colors displayed. Does not effect the ROI exportion.

%% Data Read in

imageFile = dir(fullfile(DataFolder,'*.tif'));

mask_folder = fullfile(DataFolder,'ROI_Mask');
if ~exist(mask_folder,'dir')
    mkdir(mask_folder)
end

if detector_No<3;channel_con = '%01d';
else;channel_con = '%02d';end

figure;
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
hold on;
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
            imagesc(org_img); axis image; colormap jet; colorbar; 
            color_idx = 1; mask_idx = 0;
            
            current_mask = zeros(size(org_img,1),size(org_img,2));
            while 1
                H=drawfreehand('color',plot_color(color_idx),'closed',true,'Linewidth',1);
                add_mask = H.createMask;
                
                mask_plot = plot(fix(find(add_mask == 1)/size(add_mask,1)),rem(find(add_mask == 1),size(add_mask,1)),'color',plot_color(color_idx),'Marker','.','LineStyle','none');
                button = questdlg("Add Another Region?", 'Next?', ...
                    'Add to Current Mask', 'Add Another Mask','Done(with this round)',...
                    'Add to Current Mask');
                if strcmp(button, 'Done(with this round)')
                    current_mask(add_mask == 1) = 1;
                    imwrite(current_mask, fullfile(mask_folder,[partial_name+"_mask"+num2str(mask_idx)+".tif"]));
                    
                    break
                elseif strcmp(button, 'Add to Current Mask')
                    current_mask(add_mask == 1) = 1;
     
                else
                    
                    current_mask(add_mask == 1) = 1;
                    imwrite(current_mask, fullfile(mask_folder,[partial_name+"_mask"+num2str(mask_idx)+".tif"]));
                    
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


%
%         for j = 1: channel_No
%                 for h = 1: size(current_filename,1)
%                     if contains(current_filename(h,:),['ch' num2str((j-1)*4,channel_con) '.tif']);
%                         ref_int = imread(fullfile(foldername(data_num,:),current_filename(h,:)));
%                     end
%                     if contains(current_filename(h,:),['ch' num2str((j-1)*4+2,channel_con) '.tif']);
%                         G = imread(fullfile(foldername(data_num,:),current_filename(h,:)));
%                         G = standardPhase(G);
%                     end
%                     if contains(current_filename(h,:),['ch' num2str((j-1)*4+3,channel_con) '.tif']);
%                         S = imread(fullfile(foldername(data_num,:),current_filename(h,:)));
%                         S = standardPhase(S);
%                     end
%                 end
%                 current_ref = struct('int',ref_int,'G', G, 'S', S);
%             end
%             ref_stack{z,j} = current_ref;
%     end
%
%     org_ref_stack{data_num,1}=ref_stack{z,j};
%
%     file_name = "Islet";
%     save(file_name,'ref_stack')

