%% Add Islet Based on Name
% Peiyu Wang

close all; clear all;

load("filtered_data.mat");
%%
add_data_folder = "D:\Scotts Lab\Collaborations\For Senta\Processed Pics\Zika Pregnant Control\Control_01533";
islet_folder = dir(add_data_folder);
addpath("Functions")
%%
individual_name = "Control_01533";
selected_idx = [4,5,10,11,12,13];
struct_cell = cell(numel(condition)+numel(selected_idx),1);
for i = 1:numel(filefolder)
    struct_cell{i} = filtered_struct{i};
end

struct_idx = numel(filefolder);
z=1;
for idx = 3:numel(islet_folder)
    if find(selected_idx == idx)
        file_folder = fullfile(islet_folder(idx).folder,islet_folder(idx).name);
        disp([islet_folder(idx).name])
        
        if numel(dir(fullfile(file_folder,"*.tif"))) == 12
            NADH_ch = 3;
            ch_max = 3;
        else
            NADH_ch = 5;
            ch_max = 5;
        end
        
        img_files = dir(fullfile(file_folder,'*.tif'));
        G = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).name)));
        S = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).name)));
        int = imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+1).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+1).name));
        

        current_struct = struct('int',int,'G',G,'S',S);
        current_struct = nlmfiltPhasor(current_struct,3,7,2);
        struct_idx = struct_idx+1;
        struct_cell{struct_idx} = current_struct;
        
        
        figure;
        subplot(1,2,1); imagesc(current_struct.int); axis image; axis off;
        colormap(gca,hot); colorbar;
        subplot(1,2,2); plotPhasorFast(current_struct);
        
        condition = [condition;"Zika Pregnant Control"];
        islet_No = [islet_No;string(islet_folder(idx).name)];
        filefolder = [filefolder;string(file_folder)];
        individual = [individual;individual_name];
    end
end


% 
% 
% 
% [condition,filefolder,individual,islet_No,new_struct] = delete_islet...
%     (del_name,condition,filefolder,individual,islet_No,filtered_struct)
% 
% del_idx = 0;
% for i = 1:numel(condition)
%     if strcmp(del_name,islet_No(i))
%         del_idx = i;
%         break
%     end
% end
% 
% new_struct = cell(numel(condition)-1,1);
% if del_idx == 0
%     disp("Wrong Name Input")
% else
%     idx = 1;
%     for i = 1:numel(condition)
%        if i == del_idx
%            continue
%        else
%             new_struct{idx} = filtered_struct{i};
%             idx = idx + 1;
%        end
%     end
% end
%     
% 
% condition(del_idx) = [];
% filefolder(del_idx) = [];
% individual(del_idx) = [];
% islet_No(del_idx) = [];