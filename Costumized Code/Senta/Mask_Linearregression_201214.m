%% Linear Regression from Mask Folder
% Peiyu Wang
% 12/08/2020

% 1.Reading the files from the folder structure. It takes the name of the
%   folders it belongs to and stores it in a Table. This is achieved by
%   doing multiple for loops(Not recurrsion this time).

% 2.Doing the phasor caluclations based on the Masks that are drawn on
% ROI_Masks folder, thresholding based on the xlsx form. Extracting the
% phasor centers of G and S

% 3. Based on all the G and S calculated, we do a regression, and display
% the G and S.

% 4. ALL the data will be stored in an xlsx file. 

% clear all; close all;
addpath(fullfile(pwd,'Functions'));
%% Hyper Perameters to Edit.  
master_folder = "D:\Scotts Lab\Leica Program\Collaborations\For Senta\20201213\Processed Pics";

mask_ch = [1];
FolderOrder = ["Condition","Islet No","Time Point"];

%%
cond_folder = dir(master_folder);

% struct_cell = cell(47,1);
% struct_idx = 1;

G_sum = [];
S_sum = [];
condition = [];
islet_No = [];
mask_num = [];
filefolder = [];
for mask_idx = 1:numel(mask_ch)
    for idx1 = 3:numel(dir(master_folder))
        islet_folder = dir(fullfile(cond_folder(idx1).folder,cond_folder(idx1).name));
        for idx2 = 3:numel(islet_folder)
            file_folder = fullfile(islet_folder(idx2).folder,islet_folder(idx2).name);
            disp([cond_folder(idx1).name ' ' islet_folder(idx2).name ' ' mask_ch(mask_idx)])
            
            if numel(dir(fullfile(file_folder,"*.tif"))) == 12
                NADH_ch = 3;
                ch_max = 3;
            else
                NADH_ch = 5;
                ch_max = 5;
            end
            
            img_files = dir(fullfile(file_folder,'*.tif'));
            mask_files = dir(fullfile(file_folder,'ROI_Mask','*.tif'));
            
            G_cen_stack = zeros(1,numel(mask_files));
            S_cen_stack = zeros(1,numel(mask_files));
            pixel_num_stack = zeros(1,numel(mask_files));
            for z = 1: numel(mask_files)
                mask_img = imread(fullfile(mask_files(z).folder,mask_files(z).name),mask_ch(mask_idx));
                G = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).name)));
                S = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).name)));
                int = imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+1).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+1).name));
                
                current_struct = struct('int',int,'G',G,'S',S);
%                 current_struct = nlmfiltPhasor(current_struct,3,7,2);
%                 struct_cell{struct_idx} = current_struct;
%                 struct_idx = struct_idx+1;
                
                mask_struct = struct_mask(current_struct,mask_preprocess(mask_img));
                disp(["Mean:" + num2str(mean(current_struct.int(:)))]);
                [G_cen_z,S_cen_z,pixel_num_z] = phasor_cen(mask_struct);
                
                G_cen_stack(z) = G_cen_z;
                S_cen_stack(z) = S_cen_z;
                pixel_num_stack(z) = pixel_num_z;
            end
            
            pixel_sum = sum(pixel_num_stack(:));
            if pixel_sum == 0
                S_cen = 0;
                G_cen = 0;
            else
                G_cen = G_cen_stack * pixel_num_stack'/pixel_sum;
                S_cen = S_cen_stack * pixel_num_stack'/pixel_sum;
            end
            
            disp(['G:' num2str(G_cen) '; S:' num2str(S_cen) '; Pixels: ' num2str(pixel_sum)]);
            G_sum = cat(1,G_sum,G_cen);
            S_sum = cat(1,S_sum,S_cen);
            condition = [condition;string(cond_folder(idx1).name)];
            islet_No = [islet_No;string(islet_folder(idx2).name)];
            mask_num = [mask_num; mask_ch(mask_idx)];
            filefolder = [filefolder;string(file_folder)];
        end
    end
end

%% Linear Regression: Without fixed point
map_res = 500;
color_order = ['m','c','r','b','y','g','k','k'];
P = polyfit(G_sum,S_sum,1);  % P is the linear fit for the the given values.
X = [0:0.002:1];
Y = P(2)+P(1)*X;
figure; 
axis image; plotUnitCircle; hold on;
% subplot(1,2,1); axis image; plotUnitCircle; hold on;
% subplot(1,2,2); axis image; plotUnitCircle; hold on;
f = polyval(P,G_sum,'HandleVisibility','off');
condition_names = unique(condition);
for i = 1: numel(G_sum)
   
%    subplot(1,2,mask_num(i));
%    hold on;
   plot(G_sum(i),S_sum(i),'Marker','.','MarkerSize',20,...
       'Color',color_order(condition_names == condition(i)));
end
plot(X,Y,'r-','HandleVisibility','off');
legend_name = [condition+" "+islet_No + " "+mask_num];
legend(legend_name,"NumColumns",4)

uni_y1 = sqrt(0.25-(X-0.5).^2);
plot(X,uni_y1,'r')  
[G_inter,S_inter] = intersections(X,Y,X,uni_y1,0);
[G_inter,S_order] = sort(G_inter);
S_inter = S_inter(S_order);
plot(G_inter,S_inter,'ro','HandleVisibility','off');

tao = zeros(1,2);f = 80e6;omega = 2*f*pi;

tao(2) = 1e9/omega*sqrt((1-G_inter(1))/G_inter(1)); 
tao(1) = 1e9/omega*sqrt((1-G_inter(2))/G_inter(2));
title(["Intersection Lifetime: " + num2str(tao(1)) + ' , ' + num2str(tao(2))])
%% Linear Regression: with fixed point. 
NADH_free_LT = 0.4; % Set the designed Lifetime here. 

G_free_LT = 1/(1+(omega*NADH_free_LT/1e9)^2);
S_free_LT = sqrt(0.25-(G_free_LT-0.5).^2);

plot(G_free_LT,S_free_LT,'bx','markersize',10,'HandleVisibility','off');

G_New = G_sum - G_free_LT;
S_New = S_sum - S_free_LT;

b1 = G_New\S_New;
b0 = S_free_LT- b1*G_free_LT;

P1 = [b1,b0];
f = polyval(P1,G_sum,'HandleVisibility','off');
Y1 = P1(2)+P1(1)*X;
plot(X,Y1,'b-','HandleVisibility','off')
%legend('data','linear fit through fixed point')

[G1_inter,S1_inter] = intersections(X,Y1,X,uni_y1,0);

[G1_inter,S1_order] = sort(G1_inter);  % Sorting in accending order First G is waht we want
S1_inter = S1_inter(S_order);
plot(G1_inter(1),S1_inter(1),'bo','HandleVisibility','off')

tao1 = zeros(1,2);

tao1(2) = 1e9/omega*sqrt((1-G1_inter(1))/G1_inter(1)); 
tao1(1) = 1e9/omega*sqrt((1-G1_inter(2))/G1_inter(2));
title(["Intersection Lifetime: " + num2str(tao(1)) + ' , ' + num2str(tao(2)), ...
    " Fixed Intersection Lifetime: " + num2str(tao1(1)) + ' , ' + num2str(tao1(2))])

axis([0.36 0.55 0.26 0.38]);
%% Calculating the Gree Portions
P1_pro = -1/P1(1);  %To calculate the vertical intersection, the negetive inverse as a slope

G1_pro = (S_sum + 1/P1(1) * G_sum - P1(2))/(P1(1)+ 1/P1(1)); %The G values of the intersection
S1_pro = polyval(P1,G1_pro); % The S values of the intersections
% plot(G1_pro,S1_pro,'x');
Free_precentage = (G1_pro-G1_inter(1))/(G1_inter(2)-G1_inter(1)); % The portion of free calculated portion.

%%

figure;
boxplot(Free_precentage,condition);
P_value = anova1(Free_precentage,condition);
%%

DataTable=table(condition,islet_No,G_sum,S_sum,Free_precentage);
filefolder = 'DataTable_mask1.xlsx';
writetable(DataTable,filefolder,'Sheet',1)

%% Let's do the histogram
his_axis = [0:0.004:1];

his_sum = zeros(numel(dir(master_folder))-2,numel(his_axis)-1);

for mask_idx = 1:numel(mask_ch)
    for idx1 = 3:numel(dir(master_folder))
        islet_folder = dir(fullfile(cond_folder(idx1).folder,cond_folder(idx1).name));
        current_bin = zeros(1,numel(his_axis)-1);
        for idx2 = 3:numel(islet_folder)
            file_folder = fullfile(islet_folder(idx2).folder,islet_folder(idx2).name);
                        
            if numel(dir(fullfile(file_folder,"*.tif"))) == 12
                NADH_ch = 3;
                ch_max = 3;
            else
                NADH_ch = 5;
                ch_max = 5;
            end
            
            img_files = dir(fullfile(file_folder,'*.tif'));
            mask_files = dir(fullfile(file_folder,'ROI_Mask','*.tif'));
            
            for z = 1: numel(mask_files)
                mask_img = imread(fullfile(mask_files(z).folder,mask_files(z).name),mask_ch(mask_idx));
                G = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+3).name)));
                S = standardPhase(imread(fullfile(img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).folder,img_files((z-1)*ch_max*4+(NADH_ch-1)*4+4).name)));
                int = imread(fullfile(img_files((z-1)*4+1).folder,img_files((z-1)*4+1).name));
                
                current_struct = struct('int',int,'G',G,'S',S);
                mask_struct = struct_mask(current_struct,mask_preprocess(mask_img));
                
                his_bin = phasor_line_his(current_struct,his_axis,P1);
            end
            current_bin = current_bin+his_bin;
            
        end
        his_sum(idx1-2,:) = current_bin;
    end
end

%%
his_sum = (his_sum'./sum(his_sum'))';
figure
for i = 1:3
      b = bar(his_axis(1:end-1)+(his_axis(2)-his_axis(1))/2,his_sum(i,:),1); 
      set(b,'FaceAlpha',0.5)
      hold on;
end
legend_name = dir(master_folder);
legend_name = legend_name(3:end);
legend(["14 Days","7 days", "Control"]);

%% Functions
%% Function: struct mask
% Create phasor struct that is masked out by mask_img 
% Masked areas are set to 0
function mask_struct = struct_mask(current_struct,mask_img)

    mask_struct = current_struct;
        
    mask_struct.int(mask_img == 0) = 0; 
    mask_struct.G(mask_img == 0) = 0;
    mask_struct.S(mask_img == 0) = 0;
end

%% Function: phasor_cen
% Calcualte the phasor center of current struct. 
function [G_cen,S_cen,pixel_num] = phasor_cen(current_struct)
G_cen = mean(current_struct.G(abs(current_struct.G)>=1.53e-05));
S_cen = mean(current_struct.S(abs(current_struct.S)>=1.53e-05));

pixel_num = numel(find(current_struct.int));
end


%% Function mask_preprocess
% Preprocess mask by eliminating noise islands and filling small holes. 
function new_mask = mask_preprocess(org_mask)

mask = bwareafilt(logical(org_mask),[60 1024^2]);
com_mask = 1-mask; 
com_mask = bwareafilt(logical(com_mask),[0 80]);
new_mask = mask+com_mask;
end

%% Histogram for Free precentage based on given line coeeficients. 

function his_bin = phasor_line_his(current_struct,his_axis,P)

P1_pro = -1/P(1);  %To calculate the vertical intersection, the negetive inverse as a slope
G_pro = (current_struct.S + 1/P(1) * current_struct.G - P(2))/(P(1)+ 1/P(1));
X = [0:0.002:1];
Y1 = P(2)+P(1)*X;
uni_y1 = sqrt(0.25-(X-0.5).^2);

[G_inter,S1_inter] = intersections(X,Y1,X,uni_y1,0);

[G_inter,S1_order] = sort(G_inter);  % Sorting in accending order First G is waht we want
S1_inter = S1_inter(S1_order);

Free_precentage = (G_pro-G_inter(1))/(G_inter(2)-G_inter(1));

%%
h = histogram(Free_precentage(logical(current_struct.int)),his_axis);
his_bin = h.Values; 
end



%%
function [x0,y0,iout,jout] = intersections(x1,y1,x2,y2,robust)
%INTERSECTIONS Intersections of curves.
%   Computes the (x,y) locations where two curves intersect.  The curves
%   can be broken with NaNs or have vertical segments.
%
% Example:
%   [X0,Y0] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% where X1 and Y1 are equal-length vectors of at least two points and
% represent curve 1.  Similarly, X2 and Y2 represent curve 2.
% X0 and Y0 are column vectors containing the points at which the two
% curves intersect.
%
% ROBUST (optional) set to 1 or true means to use a slight variation of the
% algorithm that might return duplicates of some intersection points, and
% then remove those duplicates.  The default is true, but since the
% algorithm is slightly slower you can set it to false if you know that
% your curves don't intersect at any segment boundaries.  Also, the robust
% version properly handles parallel and overlapping segments.
%
% The algorithm can return two additional vectors that indicate which
% segment pairs contain intersections and where they are:
%
%   [X0,Y0,I,J] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% For each element of the vector I, I(k) = (segment number of (X1,Y1)) +
% (how far along this segment the intersection is).  For example, if I(k) =
% 45.25 then the intersection lies a quarter of the way between the line
% segment connecting (X1(45),Y1(45)) and (X1(46),Y1(46)).  Similarly for
% the vector J and the segments in (X2,Y2).
%
% You can also get intersections of a curve with itself.  Simply pass in
% only one curve, i.e.,
%
%   [X0,Y0] = intersections(X1,Y1,ROBUST);
%
% where, as before, ROBUST is optional.

% Version: 2.0, 25 May 2017
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Theory of operation:
%
% Given two line segments, L1 and L2,
%
%   L1 endpoints:  (x1(1),y1(1)) and (x1(2),y1(2))
%   L2 endpoints:  (x2(1),y2(1)) and (x2(2),y2(2))
%
% we can write four equations with four unknowns and then solve them.  The
% four unknowns are t1, t2, x0 and y0, where (x0,y0) is the intersection of
% L1 and L2, t1 is the distance from the starting point of L1 to the
% intersection relative to the length of L1 and t2 is the distance from the
% starting point of L2 to the intersection relative to the length of L2.
%
% So, the four equations are
%
%    (x1(2) - x1(1))*t1 = x0 - x1(1)
%    (x2(2) - x2(1))*t2 = x0 - x2(1)
%    (y1(2) - y1(1))*t1 = y0 - y1(1)
%    (y2(2) - y2(1))*t2 = y0 - y2(1)
%
% Rearranging and writing in matrix form,
%
%  [x1(2)-x1(1)       0       -1   0;      [t1;      [-x1(1);
%        0       x2(2)-x2(1)  -1   0;   *   t2;   =   -x2(1);
%   y1(2)-y1(1)       0        0  -1;       x0;       -y1(1);
%        0       y2(2)-y2(1)   0  -1]       y0]       -y2(1)]
%
% Let's call that A*T = B.  We can solve for T with T = A\B.
%
% Once we have our solution we just have to look at t1 and t2 to determine
% whether L1 and L2 intersect.  If 0 <= t1 < 1 and 0 <= t2 < 1 then the two
% line segments cross and we can include (x0,y0) in the output.
%
% In principle, we have to perform this computation on every pair of line
% segments in the input data.  This can be quite a large number of pairs so
% we will reduce it by doing a simple preliminary check to eliminate line
% segment pairs that could not possibly cross.  The check is to look at the
% smallest enclosing rectangles (with sides parallel to the axes) for each
% line segment pair and see if they overlap.  If they do then we have to
% compute t1 and t2 (via the A\B computation) to see if the line segments
% cross, but if they don't then the line segments cannot cross.  In a
% typical application, this technique will eliminate most of the potential
% line segment pairs.


% Input checks.
if verLessThan('matlab','7.13')
	error(nargchk(2,5,nargin)) %#ok<NCHKN>
else
	narginchk(2,5)
end

% Adjustments based on number of arguments.
switch nargin
	case 2
		robust = true;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 3
		robust = x2;
		x2 = x1;
		y2 = y1;
		self_intersect = true;
	case 4
		robust = true;
		self_intersect = false;
	case 5
		self_intersect = false;
end

% x1 and y1 must be vectors with same number of points (at least 2).
if sum(size(x1) > 1) ~= 1 || sum(size(y1) > 1) ~= 1 || ...
		length(x1) ~= length(y1)
	error('X1 and Y1 must be equal-length vectors of at least 2 points.')
end
% x2 and y2 must be vectors with same number of points (at least 2).
if sum(size(x2) > 1) ~= 1 || sum(size(y2) > 1) ~= 1 || ...
		length(x2) ~= length(y2)
	error('X2 and Y2 must be equal-length vectors of at least 2 points.')
end


% Force all inputs to be column vectors.
x1 = x1(:);
y1 = y1(:);
x2 = x2(:);
y2 = y2(:);

% Compute number of line segments in each curve and some differences we'll
% need later.
n1 = length(x1) - 1;
n2 = length(x2) - 1;
xy1 = [x1 y1];
xy2 = [x2 y2];
dxy1 = diff(xy1);
dxy2 = diff(xy2);


% Determine the combinations of i and j where the rectangle enclosing the
% i'th line segment of curve 1 overlaps with the rectangle enclosing the
% j'th line segment of curve 2.

% Original method that works in old MATLAB versions, but is slower than
% using binary singleton expansion (explicit or implicit).
% [i,j] = find( ...
% 	repmat(mvmin(x1),1,n2) <= repmat(mvmax(x2).',n1,1) & ...
% 	repmat(mvmax(x1),1,n2) >= repmat(mvmin(x2).',n1,1) & ...
% 	repmat(mvmin(y1),1,n2) <= repmat(mvmax(y2).',n1,1) & ...
% 	repmat(mvmax(y1),1,n2) >= repmat(mvmin(y2).',n1,1));

% Select an algorithm based on MATLAB version and number of line
% segments in each curve.  We want to avoid forming large matrices for
% large numbers of line segments.  If the matrices are not too large,
% choose the best method available for the MATLAB version.
if n1 > 1000 || n2 > 1000 || verLessThan('matlab','7.4')
	% Determine which curve has the most line segments.
	if n1 >= n2
		% Curve 1 has more segments, loop over segments of curve 2.
		ijc = cell(1,n2);
		min_x1 = mvmin(x1);
		max_x1 = mvmax(x1);
		min_y1 = mvmin(y1);
		max_y1 = mvmax(y1);
		for k = 1:n2
			k1 = k + 1;
			ijc{k} = find( ...
				min_x1 <= max(x2(k),x2(k1)) & max_x1 >= min(x2(k),x2(k1)) & ...
				min_y1 <= max(y2(k),y2(k1)) & max_y1 >= min(y2(k),y2(k1)));
			ijc{k}(:,2) = k;
		end
		ij = vertcat(ijc{:});
		i = ij(:,1);
		j = ij(:,2);
	else
		% Curve 2 has more segments, loop over segments of curve 1.
		ijc = cell(1,n1);
		min_x2 = mvmin(x2);
		max_x2 = mvmax(x2);
		min_y2 = mvmin(y2);
		max_y2 = mvmax(y2);
		for k = 1:n1
			k1 = k + 1;
			ijc{k}(:,2) = find( ...
				min_x2 <= max(x1(k),x1(k1)) & max_x2 >= min(x1(k),x1(k1)) & ...
				min_y2 <= max(y1(k),y1(k1)) & max_y2 >= min(y1(k),y1(k1)));
			ijc{k}(:,1) = k;
		end
		ij = vertcat(ijc{:});
		i = ij(:,1);
		j = ij(:,2);
	end
	
elseif verLessThan('matlab','9.1')
	% Use bsxfun.
	[i,j] = find( ...
		bsxfun(@le,mvmin(x1),mvmax(x2).') & ...
		bsxfun(@ge,mvmax(x1),mvmin(x2).') & ...
		bsxfun(@le,mvmin(y1),mvmax(y2).') & ...
		bsxfun(@ge,mvmax(y1),mvmin(y2).'));
	
else
	% Use implicit expansion.
	[i,j] = find( ...
		mvmin(x1) <= mvmax(x2).' & mvmax(x1) >= mvmin(x2).' & ...
		mvmin(y1) <= mvmax(y2).' & mvmax(y1) >= mvmin(y2).');
	
end


% Find segments pairs which have at least one vertex = NaN and remove them.
% This line is a fast way of finding such segment pairs.  We take
% advantage of the fact that NaNs propagate through calculations, in
% particular subtraction (in the calculation of dxy1 and dxy2, which we
% need anyway) and addition.
% At the same time we can remove redundant combinations of i and j in the
% case of finding intersections of a line with itself.
if self_intersect
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2)) | j <= i + 1;
else
	remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2));
end
i(remove) = [];
j(remove) = [];

% Initialize matrices.  We'll put the T's and B's in matrices and use them
% one column at a time.  AA is a 3-D extension of A where we'll use one
% plane at a time.
n = length(i);
T = zeros(4,n);
AA = zeros(4,4,n);
AA([1 2],3,:) = -1;
AA([3 4],4,:) = -1;
AA([1 3],1,:) = dxy1(i,:).';
AA([2 4],2,:) = dxy2(j,:).';
B = -[x1(i) x2(j) y1(i) y2(j)].';

% Loop through possibilities.  Trap singularity warning and then use
% lastwarn to see if that plane of AA is near singular.  Process any such
% segment pairs to determine if they are colinear (overlap) or merely
% parallel.  That test consists of checking to see if one of the endpoints
% of the curve 2 segment lies on the curve 1 segment.  This is done by
% checking the cross product
%
%   (x1(2),y1(2)) - (x1(1),y1(1)) x (x2(2),y2(2)) - (x1(1),y1(1)).
%
% If this is close to zero then the segments overlap.

% If the robust option is false then we assume no two segment pairs are
% parallel and just go ahead and do the computation.  If A is ever singular
% a warning will appear.  This is faster and obviously you should use it
% only when you know you will never have overlapping or parallel segment
% pairs.

if robust
	overlap = false(n,1);
	warning_state = warning('off','MATLAB:singularMatrix');
	% Use try-catch to guarantee original warning state is restored.
	try
		lastwarn('')
		for k = 1:n
			T(:,k) = AA(:,:,k)\B(:,k);
			[unused,last_warn] = lastwarn; %#ok<ASGLU>
			lastwarn('')
			if strcmp(last_warn,'MATLAB:singularMatrix')
				% Force in_range(k) to be false.
				T(1,k) = NaN;
				% Determine if these segments overlap or are just parallel.
				overlap(k) = rcond([dxy1(i(k),:);xy2(j(k),:) - xy1(i(k),:)]) < eps;
			end
		end
		warning(warning_state)
	catch err
		warning(warning_state)
		rethrow(err)
	end
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) <= 1 & T(2,:) <= 1).';
	% For overlapping segment pairs the algorithm will return an
	% intersection point that is at the center of the overlapping region.
	if any(overlap)
		ia = i(overlap);
		ja = j(overlap);
		% set x0 and y0 to middle of overlapping region.
		T(3,overlap) = (max(min(x1(ia),x1(ia+1)),min(x2(ja),x2(ja+1))) + ...
			min(max(x1(ia),x1(ia+1)),max(x2(ja),x2(ja+1)))).'/2;
		T(4,overlap) = (max(min(y1(ia),y1(ia+1)),min(y2(ja),y2(ja+1))) + ...
			min(max(y1(ia),y1(ia+1)),max(y2(ja),y2(ja+1)))).'/2;
		selected = in_range | overlap;
	else
		selected = in_range;
	end
	xy0 = T(3:4,selected).';
	
	% Remove duplicate intersection points.
	[xy0,index] = unique(xy0,'rows');
	x0 = xy0(:,1);
	y0 = xy0(:,2);
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		sel_index = find(selected);
		sel = sel_index(index);
		iout = i(sel) + T(1,sel).';
		jout = j(sel) + T(2,sel).';
	end
else % non-robust option
	for k = 1:n
		[L,U] = lu(AA(:,:,k));
		T(:,k) = U\(L\B(:,k));
	end
	
	% Find where t1 and t2 are between 0 and 1 and return the corresponding
	% x0 and y0 values.
	in_range = (T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) < 1 & T(2,:) < 1).';
	x0 = T(3,in_range).';
	y0 = T(4,in_range).';
	
	% Compute how far along each line segment the intersections are.
	if nargout > 2
		iout = i(in_range) + T(1,in_range).';
		jout = j(in_range) + T(2,in_range).';
	end
end
end

% Plot the results (useful for debugging).
% plot(x1,y1,x2,y2,x0,y0,'ok');

function y = mvmin(x)
% Faster implementation of movmin(x,k) when k = 1.
y = min(x(1:end-1),x(2:end));
end

function y = mvmax(x)
% Faster implementation of movmax(x,k) when k = 1.
y = max(x(1:end-1),x(2:end));
end
