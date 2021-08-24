%% Read_Ref
% Peiyu Wang
% 07/19/2019

function ref_struct = readref(MasterFolderName,FolderOrder,property_string,channel_No,har_num)

refClassifier(MasterFolderName,FolderOrder,property_string,channel_No,har_num);  %% Adjust the channels you have: 
end

%% Function

% Read in is done with recurrsion. The recurrsion end criteria is when it
% does not have subfolders in it, or when the only folder name is "Metadata."

function refClassifier(master_folder_name,property_names,property_string,channel_numbers,har_num);
current_folder = dir(master_folder_name);
current_folder = current_folder([current_folder.isdir]);

if numel(current_folder) == 2
    readRef(master_folder_name,property_names,property_string,channel_numbers,har_num);
else
    current_folder = current_folder(3:end); % (first and second folder are . and ..)
    if strcmp(current_folder(1).name,"MetaData")% The naturally exported file has a Meta Data;
        readRef(master_folder_name,property_names,property_string,channel_numbers,har_num);
    else
        for i = 1: numel(current_folder)
            current_string =[property_string;string(current_folder(i).name)];
            refClassifier(fullfile(current_folder(i).folder,...
                current_folder(i).name),property_names,current_string,channel_numbers,har_num);
        end
    end
end
end

%%
function readRef(master_folder_name,property_names,property_string,channel_No,har_num)


%% for adjusting channel_No, please adjust the Read in section accordingling;
if channel_No<3
    channel_con = '%01d';
else
    channel_con = '%02d';
end

imageFile = dir(fullfile(master_folder_name,'*.tif'));
z_stacks = numel(imageFile)/(har_num*4*channel_No); %2 harmonics, 4 channel for each aquicisiton channels 
ref_stack = cell(z_stacks,channel_No+1);

property_struct = struct;
file_name =strjoin(property_string(1:numel(property_names)),'_');

for i = 1: numel(property_names)
    eval(['property_struct.'+property_names(i)+ '='''+property_string(i)+''';']);
end

for z = 1: z_stacks
    % Adjusting the read in names according to the number of z stacks.
    if z_stacks == 1
        current_z = '*.tif';
    elseif z_stacks < 11
        current_z = num2str(z-1.','z%01d');
    else
        current_z = num2str(z-1.','z%02d');
    end
    
    % all the files that have the according z_numbers. 
    current_filename = [];
    for k = 1: numel(imageFile)
        if contains(imageFile(k).name,current_z)
            current_filename = [current_filename;imageFile(k).name];
        end
    end
    
    %% Read In
    for j = 1: channel_No
        if har_num == 2
            for h = 1: size(current_filename,1)
                if contains(current_filename(h,:),['ch' num2str((j-1)*4,channel_con) '.tif']);
                    ref_int = imread(fullfile(master_folder_name,current_filename(h,:)));
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+2,channel_con) '.tif']) && contains(current_filename(h,:),'h1_','IgnoreCase',true);
                    G = imread(fullfile(master_folder_name,current_filename(h,:)));
                    G = standardPhase(G);
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+3,channel_con) '.tif'])&& contains(current_filename(h,:),'h1_','IgnoreCase',true);
                    S = imread(fullfile(master_folder_name,current_filename(h,:)));
                    S = standardPhase(S);
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+2,channel_con) '.tif'])&& contains(current_filename(h,:),'h2_','IgnoreCase',true);
                    G2 = imread(fullfile(master_folder_name,current_filename(h,:)));
                    G2 = standardPhase(G2);
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+3,channel_con) '.tif'])&& contains(current_filename(h,:),'h2_','IgnoreCase',true);
                    S2 = imread(fullfile(master_folder_name,current_filename(h,:)));
                    S2 = standardPhase(S2);
                end
            end
            current_ref = struct('int',ref_int,'G', G, 'S', S, 'G2',G2,'S2', S2);
        else
            for h = 1: size(current_filename,1)
                if contains(current_filename(h,:),['ch' num2str((j-1)*4,channel_con) '.tif']);
                    ref_int = imread(fullfile(master_folder_name,current_filename(h,:)));
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+2,channel_con) '.tif']);
                    G = imread(fullfile(master_folder_name,current_filename(h,:)));
                    G = standardPhase(G);
                end
                if contains(current_filename(h,:),['ch' num2str((j-1)*4+3,channel_con) '.tif']);
                    S = imread(fullfile(master_folder_name,current_filename(h,:)));
                    S = standardPhase(S);
                end
            end
            current_ref = struct('int',ref_int,'G', G, 'S', S);
        end
        ref_stack{z,j} = current_ref;
    end
    ref_stack{z,channel_No+1} = property_struct;
end
save(file_name,'ref_stack')
end


%% Functions
function sta_phase = standardPhase(org_phase)
%G and S vales were scaled from -1 ~ +1 to 0 ~ (2^16-1), 32767.5 is 0;
sta_phase = (double(org_phase)-32767.5)/32767.5;
end