%%  Analysis Template for FLIM data analysis
%  Update: 08/24/2021
%  Peiyu Wang

%  This is a template matlab program for data analysis.
%  Expected Data input: Exported GS files with Fast FLIM from Leica Falcon
%  System.
%  This program analyzes multiple layers; 

% Please do not put anything that is not the exported data in any
% subfolders.

%  This dataset had 2 fluorescence detector channels, which generate 8 output channels:
%  First detector: SYTO59 staining dye.
%  Second detector: NADH autofluroesence.

%  The input also stored the Bright Field data in the BF file


%  Workflow anlaysis:
%  Data input ->  Mask Generation -> Thresholding -> Filtering ->
%  Metablic analysis based on masking -> data output.

%  You can comment out entires sections if there are workflow precedures that you do not want.

%  Prerequisite: Function folder from the TIC collaborator github repository

close all; clear all;

addpath("Functions"); %Change the path name to the location of "Function",
%or put "Function" folder on the folder as the matlab
%script.
%% Input Variables

dataFolder = "/Users/mathiasbigger/Documents/Mathias Edits/1";  % dataFolder: location of the folder that contains Data.
% Change to your folder where you store the data like:
% dataFolder = "C:\User\20210823\Data"
% Please do not put anything that is not the exported data in any
% subfolders.

NADH_dec = 2;         % The detector sequence (not the channel) for NADH.
% NADH_dec depends on how many detector are activated before NADH is colected.
% If one other detector was activated, and NADH was second detector, put 2.
% Usually input as 1. For default dataset in script, as we have another dye collected beore NADH, therefore set as 2.

imageSize = 512;                        % Image Input Size

Excel_file = 'Analysis.xlsx';   % Name of the excel file to store all the data. Do not omit the ".xlsx"
%% Analysis procedures setup:
% For all the procedures, if you want to include, assign varable as 1, if asign as 0.
%% Masking Analysis
% If you wish to do analysis based on generated masks, asign mask_analyzing
% as 1, otherwise asign as 0. 
% Expect mask to be in the "mask" folder in the folder of the dataset, as
% mask_img.tif or mask_img_z0.tif for z stack analysis. 

% Mask creation settings is included in the next procedures.  

mask_analyzing = 0;      %If you wish to do analysis based on generated masks, asign mask_analyzing as 1, otherwise asign as 0. 

%% Mask creation procedure.
% Masking based on another input image for the same field of view
% Only do it if you have another image collected to generate the mask.
% If not, select 0 for all settings. Only one of the three procedures recomended here. Set zeros for others. .
batch_threshold_mask = 0;       % Batch thresholding for creating masks
individual_threshold_mask = 0;  % individual thresholding for masks
individual_draw_mask = 0;       % individual thresholding for masks.


%Additional Settings:
mask_ch = 1;                 % mask_ch: The channel which is used the generate the mask
% notice please input as the matlab order, "ch0.tif" will be input as 1.
mask_thresh = 500;            % Set to your batch masking value if batch_threshold_mask is select. Otherwise set as 0.
%%  Filtering proceure.
%  If you want to include the filtering, assign varable as 1, if not asign as 0.
%  Recommend to only include one, although if you want you can do both.
%  Recommend wavelet filtering when exporting the dataset.

cnlm_filtering =  0;        % Correlated Non local Mean filetering: Warning: might take quite some time.
med_filtering  =  1;         % Median fileting.


%  Advanced settings:  Refer to functions scripts. Changing is not necessary
window_size  =  3;            % Windowsize for median fileter and CNLM
serch_size   =  9;            % Search size for CNLM
average_coe  =  35;           % Averaging coefficient for CNLM.

%%  Thresholding for NADH based on NADH intensity Images
%   Leica output files does not output NADH thresholding.
%   Therefore thresholding is recomended for NADH Analysis.
%

NADH_thresholding  =  1;              % If you want to include the thresholding, assign varable as 1, if asign as 0

% Additional settings:
NADH_thresh_val  =  30;                % Threshold value for NADH in phasor analysis.
% Recommended value: At least 7 to get accurate counts.
% Recommend to decide value during you image acquition and when previewing  your images.

%% Caluculate phaosr representative for phasor cluster
%  Different ways to calculate the phasor representatives.
%  One, and only one should be assigned as 1. 

phasor_mode_calculating  =  1; % To calculate phasor based on mode, assign varable as 1, if not asign as 0

phasor_cen_calculating  =  0;  % To caluclaed phasor based on centroid, assign varable as 1, if not asign as 0

% phasor_mode_calculating is recommended, as it filter out noise components from other molecular speices that don't donminate the field of view.

%% Advanced Data Settings: Z analysis
% For Analysis of 3D stack layers. Number os z layers is calcualted  based on the total number of inputs channels inside the folder,
% and the total number of detectors that are used. Expecting 4 channel output for all detectors.
% Z stacks do not need to be the same for all data sets.
% If z_analysis is set to 0, it only takes the first z layer. 

z_analysis = 1;       %If you want to analyze based on different z, assign varable as 1, if not asign as 0

total_detector = 3;   % Enter the number of detector used for the imaging setting.

% Please mannually check whether the total number of tiff files in folder is : 4 *number of detectors * number of z stacks.

%% Advanced Data Settings: Output summary image of the condition. 

phasor_image = 1;             % Plot individual image for phasor plot before summarizing.
phasor_original_image = 1;    % plot original phasor image bofore filtering and preprocessing the image. 
summary_image = 1;            % plot summary image with phasor plot and intensity information. 
 
store_image = 1;              % Store the image inside the "Figures" folder. created.   
image_folder = "SavedFigures";     % Name of the figures folder.  All images will be stored in the figure folder. 

close_image = 1;                % closing all images after each field of view: Highly recommended if you have many datasets. This let you store the sumary image above. 
%%  Please do not modify code starting from here.
%%  Please do not modify code starting from here.
%%  Please do not modify code starting from here.
% Unless you are sure what you are doing, do not modify code. Contact TIC member to modify the code.

%% Predifiniing variables.

G_sum = [];   % Summarizing the information of G
G_avg = 0;
G_averages=[];
S_sum = [];   % Summarizing the information of S
Name = [];    % Stroing the names of the folder.
effective_pixel_count = [];  % Summarizing the information of pixel analzyed for each layer. 

if z_analysis  == 1
    z_num = [];     % Summarizing the information of z     
else
    z_stack = 1;
end

batch_threshold_mask = 1;       % Batch thresholding for creating masks
individual_threshold_mask = 0;  % individual thresholding for masks
individual_draw_mask = 0;       % individual thresholding for masks.

% Creat folder for saving images. 
if store_image == 1
    if ~exist(image_folder,'dir')
        mkdir(image_folder)
    end
end
%% Error check
% Checking if input setting is correct
if phasor_mode_calculating + phasor_cen_calculating ~= 1
    disp("Error in seeting phasor calculation mode, check Caluculate phaosr representative for phasor cluster! ")
    disp("Press Control + C to abort program! ")
    pause
end


if batch_threshold_mask + individual_threshold_mask + individual_draw_mask > 1
    disp("Error in seting mask, check Caluculate phaosr representative for phasor cluster! ")
    disp("Press Control + C to abort program! ")
    pause
end

%% Data read in;
imageFolder = dir(dataFolder);

for i = 3: numel(imageFolder)  % Looping through the different individual folders
    %  i starts with three, as i=1 and 2 is the current directory and previous
    %  directory respectively, named ".", and ".."
    
    disp("Reading in Data"); 
    
    currentFolder = fullfile(imageFolder(i).folder,imageFolder(i).name);
    
    mask_folder = fullfile(currentFolder,"mask");  % create folder to store the masks
    if ~exist(mask_folder,'dir')
        mkdir(mask_folder)
    end
    
    image_file = dir(fullfile(currentFolder,"*.tif")); %imgFiles: all tif input files.
    BF_file = dir(fullfile(currentFolder,"BF","*.tif"));
    
    
    if z_analysis == 1
        z_stack = numel(image_file)/4/total_detector;
    end
    
    %  original mask image;
    
    for z_cur = 1: z_stack
        
        int = imread(fullfile(image_file(1).folder,image_file((z_cur-1)*4*total_detector+(NADH_dec-1)*4+1).name));
        G = standardPhase( imread(fullfile(image_file(1).folder,image_file((z_cur-1)*4*total_detector+(NADH_dec-1)*4+3).name)));
        S = standardPhase( imread(fullfile(image_file(1).folder,image_file((z_cur-1)*4*total_detector+(NADH_dec-1)*4+4).name)));
        
        %  Data read in for int, G, and S; If necessaryly, addjust this according to
        %  your detector number for NADH.
        
        %% Create mask with batch mask thresholding.
        if batch_threshold_mask == 1
            disp("Performing batch masks by thresholding: ")
            mask_org = imread(fullfile(image_file(mask_ch).folder,image_file(mask_ch).name));
            
            mask_img = zeros(size(int));
            mask_img(mask_org <  mask_thresh) = 0;
            mask_img(mask_org >= mask_thresh) = 1;
            
            disp(["Saving mask for: " + imageFolder(i).name]);
            if z_analysis == 1
                imwrite(mask_img,fullfile(currentFolder,"mask",["mask_img_z" + num2str(z_cur) + ".tif"]));
            else
                imwrite(mask_img,fullfile(currentFolder,"mask","mask_img.tif"));
            end
        end
        %% Creating Individual mask based on thresholding
        
        
        if individual_threshold_mask == 1
            disp("Performing individual mask by thresholding: ")
            mask_org = imread(fullfile(image_file(mask_ch).folder,image_file(mask_ch).name));
            
            mask_img = zeros(size(int));
            
            mask_map = cat(3,ones(size(int))*0,ones(size(int))*1,ones(size(int))*1);
            %   Generate a cyan mask.  mask displayed as cyon for Selected threshold.
            
            disp('Thresholding Image to create Mask:')
            
            figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            
            imagesc(mask_org); colormap(gca, hot); axis image; colorbar;
            
            hold on;
            p1 = imshow(mask_map); set(p1, 'AlphaData',mask_img);
            
            %% Creating pop up window for doing this
            while 1
                
                temp_thresh_img = zeros(size(int));
                mask_thresh = input("Please input threshold level: ");
                
                temp_thresh_img(mask_org<mask_thresh) = 0;
                temp_thresh_img(mask_org>=mask_thresh) = 1;
                set(p1, 'AlphaData',temp_thresh_img*0.5);
                
                promptMessage = "Do you want to reselect?(Y/N):";
                button1 = questdlg(promptMessage, 'Reselect threshold?', 'Yes', 'No', 'Yes');
                if strcmpi(button1, 'No')
                    break
                else
                    set(p1, 'AlphaData',0);
                end
            end
            
            mask_img(mask_org <  mask_thresh) = 0;
            mask_img(mask_org >= mask_thresh) = 1;
            
            disp(["Saving mask for: " + imageFolder(i).name]);
            if z_analysis == 1
                imwrite(mask_img,fullfile(currentFolder,"mask",["mask_img_z" + num2str(z_cur) + ".tif"]));
            else
                imwrite(mask_img,fullfile(currentFolder,"mask","mask_img.tif"));
            end
        end
        %  Saving the mask image to the mask file.
        %% Mask Generating based on drawing.
        if individual_draw_mask == 1
            
            disp("Performing individual mask by thresholding: ")
            mask_org = imread(fullfile(image_file(mask_ch).folder,image_file(mask_ch).name));
            mask_img = zeros(size(int));
            
            mask_map = cat(3,ones(size(int))*0,ones(size(int))*1,ones(size(int))*1);
            % mask displayed as cyon for future images.
            current_map = cat(3,ones(size(int))*1,ones(size(int))*0,ones(size(int))*1);
            % mask displayed as megenta for future images.
            
            disp('Drawing on image to create mask:')
            
            figure;set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
            subplot(1,2,1);
            
            imagesc(mask_org); colormap(gca, hot); axis image; colorbar;
            
            subplot(1,2,2);
            
            imagesc(int); axis image; colormap(gca, jet); colorbar;
            hold on;
            p3 = imshow(mask_map); set(p3, 'AlphaData',mask_img);
            p4 = imshow(current_map); set(p4, 'AlphaData',mask_img);
            while 1     % Window drawing.
                subplot(1,2,1)
                H=drawfreehand('color','m','closed',true,'Linewidth',2);
                
                add_mask = H.createMask;
                set(p3, 'AlphaData',add_mask*0.55);
                
                button = questdlg("Add Another Region?", 'Next?', ...
                    'Add to Current Mask', 'Redo','Done(with this round)',...
                    'Add to Current Mask');
                if strcmp(button, 'Done(with this round)')
                    mask_img(add_mask == 1) = 1;
                    
                    
                    set(p3, 'AlphaData',0);
                    set(p4, 'AlphaData',mask_img*0.55);
                    
                    break
                elseif strcmp(button, 'Add to Current Mask')
                    mask_img(add_mask == 1) = 1;
                    
                    set(p3, 'AlphaData',0);
                    set(p4, 'AlphaData',mask_img*0.55);
                    
                else
                    delete(H)
                end
            end
            
            disp(["Saving mask for: " + imageFolder(i).name]);
            
            if z_analysis == 1
                imwrite(mask_img,fullfile(currentFolder,"mask",["mask_img_z" + num2str(z_cur) + ".tif"]));
            else
                imwrite(mask_img,fullfile(currentFolder,"mask","mask_img.tif"));
            end
        end
        %  Saving the mask image to the mask file.
        %% Filtering for NADH information
        org_struct = struct("int",int,"G",G,"S",S);
        
        % This org_struct stores information based on key value pairs:
        % the "int" is the key, that stores the value int inside the struct.
        % To access int, use org_struct.int;
        % This struct is the basic analysis unit for most of the Function
        % in the github repository function.
        
        % You can use the wavelet function that is provided in the Leica Falcon
        % systm. You can also use the median filter or the CNLM filter provided in
        % here.
        
        if phasor_original_image == 1 
            figure; 
            plotPhasorFast(org_struct);  title("Original Phasor plot")
        end
        
        %%  Different filtering options. 
        if cnlm_filtering == 1 % Correlated Non local Mean filetering: Warning: might take quite some time.
            org_struct = nlmfiltPhasor(org_struct, window_size, serch_size, average_coe); % Perform a nlm filting with a window size of 5, search window of 9, averaging level of 35
        end
        
        
        if med_filtering ==  1 % Median fileting.   
            org_struct = medfiltPhasor(org_struct, window_size); % Perform median filtering with a window size of 5
        end
       
      
        if phasor_image == 1
            figure; 
            plotPhasorFast(org_struct);  title("Filtered Phasor plot")
        end
        
        
        if summary_image == 1
            figure; set(gcf, 'units','normalized','outerposition',[0 0 1 1]); 
            subplot(1,2,1); imagesc(org_struct.int);  colorbar; colormap(gca,"hot"); axis image; 
            axis off; title("Intensity map"); set(gca,"FontSize",10);
            subplot(1,2,2); plotPhasorFast(org_struct);  title("Filtered Phasor plot");
            set(gca,"FontSize",10);
        end
        
        
        if store_image == 1
            saveas(gcf,fullfile(image_folder,[imageFolder(i).name+"_z"+num2str(z_cur)+".tif"])); 
        end
        
        
        if close_image == 1   
            close all;
        end
                
        %% Thresholding FLIM Phasors based on NADH intensities
        %  Thresholding the phasor cluster based on the NADH intensity image.
        %  The minial recommendation: 7 for only processing data with
        %  accurate FLIM signal 
        
        if NADH_thresholding == 1
            org_struct = threshPhasorStruct(org_struct,NADH_thresh_val);
        end
        %% Analysis of the data based on masked structure.
        
        % Usually filtering before masking is recommend, so that multiple masks
        % could be used without having to filter multiple times.
        
        % IF you don't have a mask, you can comment out the next 2 lines.
        
        if mask_analyzing == 1
            if ~exist(fullfile(currentFolder,"mask"),"dir")
                disp("Error in seting mask analysis, mask file missing!")
                disp("Press Control + C to abort program! ")
                pause
            end
            
            
            
            if z_analysis == 1
                mask_files = dir(fullfile(currentFolder,"mask","*.tif"));
                mask_img = imread(fullfile(mask_files(1).folder,mask_files(z_cur).name));
            else
                mask_img = imread(fullfile(currentFolder,"mask","mask_img.tif"));
            end% If you don't have a mask, just comment out this procedure.
            org_struct = maskPhasorStruct(org_struct,mask_img); % If you don't have a mask, just comment out this procedure.
        end
        
        
        if phasor_mode_calculating == 1
            [G_cur, S_cur] = findModePhasor(org_struct);  % Finding the mode of the phasors.
            
        elseif phasor_cen_calculating == 1
            [G_cur, S_cur] = findCenPhasor(mask_struct); % Finding the center of the phasor.
        else
            disp("Error in seting phasor calculation mode, check Caluculate phaosr representative for phasor cluster! ")
            disp("Press Control + C to abort program! ")
            pause
        end
        
        G_sum = cat(1,G_sum,G_cur);
        S_sum = cat(1,S_sum,S_cur);
        Name = cat(1, Name, imageFolder(i).name);
        pixel_cur = numel(find(org_struct.int));
        effective_pixel_count = cat(1, effective_pixel_count, pixel_cur);
        %  Stroing the names, and the G, S for current value.
        if z_analysis == 1
            z_num = cat(1,z_num,z_cur);    
        end
    end
    G_avg=0;
    for x=0:2
    G_avg = G_avg+G_sum(length(G_sum)-x);
    end
    G_averages = cat(1,G_averages,G_avg/3)
end

%% Advanced Analysis for NADH metabolism analysis
% Plese refer to the function discription for detailed analysis. 

% lineExtensionMetabolism: Draw line from free NADH, connect the input and
% intersect with output. 
% Output: 
% Free_LEXT:  The Free NADH proportion of the clusters based on LEXT
% G_int: The G cordinate for the Bound NADH. 
% S_int: The S cordinate for the Bound NADH. 
% tao: The lifetime for the Bound NADH. 

% LinearRegression_Analysis: Do linear regression for all datapoint, with
% free NADH point guaruenteed. 
% Output: 
% Free_LEXT:  The Free NADH proportion of the clusters based on LEXT
% G_int: The G cordinate for the Bound NADH. 
% S_int: The S cordinate for the Bound NADH. 
% tao: The lifetime for the Bound NADH. 


[Free_LEXT,G_int,S_int,tao] = lineExtensionMetabolism(G_averages, S_sum);
%   This is for the Line Extension metabolism analyis.
Free_LR = LinearRegression_Analysis(G_averages, S_sum);
%   This is for the Linear Regression analysis.

%% Output data folder
DataTable=table(Name,effective_pixel_count, G_averages, S_sum, Free_LEXT,G_int,S_int,tao,Free_LR);
writetable(DataTable,Excel_file,'Sheet',1)

