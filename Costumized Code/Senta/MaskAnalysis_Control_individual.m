%% Covid-19 Slide Analysis for Janielle
% 08/10/2021
% Peiyu Wang

% For Janielle only, the mask can be read by filefolder/ROI_Mask/ControlMask.tif;

% Data only has one z plane. which is pretty good! 

% Let's do this. 

close all; clear all;
addpath("Functions");

DataFolder = "D:\Scotts Lab\Collaborations\For Senta\Processed Pics";
%% 
condition = [];
islet_No = [];
individual = [];
G_mode = [];
S_mode = [];

cond_folder = dir(DataFolder);
for cond_idx = 3:numel(cond_folder)
    ind_folder = dir(fullfile(DataFolder,cond_folder(cond_idx).name));
    for ind_idx = 3: numel(ind_folder)
        samp_folder = dir(fullfile(ind_folder(ind_idx).folder,ind_folder(ind_idx).name));
        for samp_idx = 3: numel(samp_folder)
            data_folder = fullfile(samp_folder(samp_idx).folder,samp_folder(samp_idx).name);
            
            condition = cat(1,condition,string(cond_folder(cond_idx).name));
            individual = cat(1,individual,string(ind_folder(ind_idx).name));
            islet_No = cat(1,islet_No,string(samp_folder(samp_idx).name));
                      
            imageFile = dir(fullfile(data_folder,'*.tif'));
            int = imread(fullfile(imageFile(9).folder,imageFile(9).name));
            G = standardPhase(imread(fullfile(imageFile(11).folder,imageFile(11).name)));
            S = standardPhase(imread(fullfile(imageFile(12).folder,imageFile(12).name)));
            mask_img = imread(fullfile(data_folder,"ROI_Mask","ControlMask.tif"));  %% Change the name here to the name of the mask
            
            current_struct = struct('int',int,'G',G,'S',S);
            current_struct = maskphasorstruct(current_struct,mask_img);
            [G_m,S_m] = findModePhasor(current_struct);
            
            G_mode = cat(1,G_mode,G_m);
            S_mode = cat(1,S_mode,S_m);
        end
    end
end

%% analysis for individuals.
condition_names = unique(condition);
individual_name = unique(individual);

G_mode_sum = [];
S_mode_sum = [];
condition_sum = [];
individual_sum = [];

for i = 1: numel(individual_name)
    index = find(individual == individual_name(i));
    G_current = G_mode(index);
    S_current = G_mode(index);
    G_mode_sum = cat(1,G_mode_sum,mean(G_current(:)));
    S_mode_sum = cat(1,S_mode_sum,mean(S_current(:)));
    condition_sum =  cat(1,condition_sum,condition(index(1)));
    individual_sum =  cat(1,individual_sum, individual_name(i));
end
%% Line Extention Metabolism for Free Precentage Calculation
[Mask_Mode_LEXT,G_int,S_int,tao] = lineExtensionMetabolism(G_mode_sum,S_mode_sum);

%%

DataTable=table(condition_sum,individual_sum,G_mode_sum,S_mode_sum,Mask_Mode_LEXT,G_int,S_int,tao);
filename = 'individual.xlsx';
writetable(DataTable,filename,'Sheet',1)

%% Functions
function new_struct = maskphasorstruct(org_struct, map)

int = org_struct.int; G = org_struct.G; S = org_struct.S;
int(map == 0) = 0; G(map == 0) = 0; S(map == 0) = 0;

new_struct = struct('int',int,'G',G,'S',S);
end