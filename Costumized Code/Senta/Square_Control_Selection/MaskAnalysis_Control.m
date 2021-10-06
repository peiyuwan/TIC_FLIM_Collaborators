%% Covid-19 Slide Analysis for Janielle
% 08/31/2021
% Peiyu Wang

% For Janielle only, the mask can be read by filefolder/ROI_Mask/ControlMask.tif;

% Data only has one z plane. which is pretty good!

% Let's do this.

close all; clear all;
addpath("D:\Scotts Lab\Leica Program\Collaborations\Codes\TIC_FLIM_Collaborators\Functions");

DataFolder = "D:\Scotts Lab\Collaborations\For Senta\20210810_Segmentation\TestData";
%%
condition = [];
islet_No = [];
G_mode = [];
S_mode = [];
pixel_count = [];

cond_folder = dir(DataFolder);
for cond_idx = 3:numel(cond_folder)
    if cond_folder(cond_idx).name == "DS_Store"
        continue
    end
    
    samp_folder = dir(fullfile(cond_folder(cond_idx).folder,cond_folder(cond_idx).name));
    
    for samp_idx = 3: numel(samp_folder)
        if samp_folder(samp_idx).name == "DS_Store"
            continue
        end
        
        data_folder = fullfile(samp_folder(samp_idx).folder,samp_folder(samp_idx).name);
        
        disp(["Analyzing: " + string(data_folder)]);
        condition = cat(1,condition,string(cond_folder(cond_idx).name));
        islet_No = cat(1,islet_No,string(samp_folder(samp_idx).name));
        
        
        imageFile = dir(fullfile(data_folder,'*.tif'));
        if numel(imageFile) == 20
            int = imread(fullfile(imageFile(17).folder,imageFile(17).name));
            G = standardPhase(imread(fullfile(imageFile(19).folder,imageFile(19).name)));
            S = standardPhase(imread(fullfile(imageFile(20).folder,imageFile(20).name)));
            
        else
            int = imread(fullfile(imageFile(9).folder,imageFile(9).name));
            G = standardPhase(imread(fullfile(imageFile(11).folder,imageFile(11).name)));
            S = standardPhase(imread(fullfile(imageFile(12).folder,imageFile(12).name)));
        end
        
        mask_img_name = fullfile(data_folder,"ROI_Mask","ControlMask.tif");
        if ~exist(mask_img_name,'file')
            disp(["Missing Mask for: " + string(samp_folder(samp_idx).name)]);
            disp("Please abort program with Contrl + C and add mask!")
            pause
        end
        
        mask_img = imread(fullfile(data_folder,"ROI_Mask","ControlMask.tif"));  %% Change the name here to the name of the mask
        
        current_struct = struct('int',int,'G',G,'S',S);
        current_struct = maskphasorstruct(current_struct,mask_img);
        [G_m,S_m] = findCenPhasor(current_struct);
        
        G_mode = cat(1,G_mode,G_m);
        S_mode = cat(1,S_mode,S_m);
        pixel_count = cat(1,pixel_count,sum(mask_img(:)));
    end
end


%% analysis for individuals.

[Mask_Mode_LEXT,G_int,S_int,tao] = lineExtensionMetabolism(G_mode,S_mode);

%%

DataTable=table(condition,islet_No,pixel_count,G_mode,S_mode,Mask_Mode_LEXT,G_int,S_int,tao);
filename = 'Summary.xlsx';
writetable(DataTable,filename,'Sheet',1)



%% Uncomment this if you want the mean calculated for a seperate excell sheet.
% condition_names = unique(condition);
%
% G_mode_sum = [];
% S_mode_sum = [];
% condition_sum = [];
%
% for i = 1: numel(condition_names)
%     index = find(condition == condition_names(i));
%     G_current = G_mode(index);
%     S_current = G_mode(index);
%     G_mode_sum = cat(1,G_mode_sum,mean(G_current(:)));
%     S_mode_sum = cat(1,S_mode_sum,mean(S_current(:)));
%     condition_sum =  cat(1,condition_sum,condition(index(1)));
% end
%
% [Mask_Mode_LEXT,G_int,S_int,tao] = lineExtensionMetabolism(G_mode_sum,S_mode_sum);
%
% DataTable=table(condition_sum,G_mode_sum,S_mode_sum,Mask_Mode_LEXT,G_int,S_int,tao);
% filename = 'individual2.xlsx';
% xlswrite(filename,DataTable,2)

%% Functions
function new_struct = maskphasorstruct(org_struct, map)

int = org_struct.int; G = org_struct.G; S = org_struct.S;
int(map == 0) = 0; G(map == 0) = 0; S(map == 0) = 0;

new_struct = struct('int',int,'G',G,'S',S);
end

