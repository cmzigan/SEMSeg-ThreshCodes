function core = erosion_dilation(img,peak_min,con)

% =========================================================================
% segment cells via a 2D erosion\dilation method.
% by Tianqi Guo, Feb 2018
% =========================================================================

% index-shift matrix for 4\8 pixel neighbourhood
if con == 4
    dx = [   0  0 -1  1];
    dy = [ -1  1   0  0];
elseif con == 8
    dx = [  0  0 -1  1 -1 -1   1 1];
    dy = [-1  1   0  0 -1   1 -1 1];
end

% range for peak intensities
[s1,s2] = size(img);

% range for peak intensities
peak_lo = peak_min;
peak_hi = max(img(:));
peak_step = 5;
% keyboard;
% =========================================================================
% erosion procedure

img = double(img);
% count for discovered local intensity peaks and particle numbers
p = 0;

level_set = peak_lo : peak_step : peak_hi + peak_step;
level_num = size(level_set,2);
region_peak_ind = cell(level_num,1);

% gradually increase intensity threshold for peaks
for i = 1 : level_num
    
    level = level_set(i);
    
    % all intensities below current threshold are set to zero
    img_l = img;
    img_l(img_l < level) = 0;
    
    % find the connected regions for the current level
    % each region potentially has a local maximum, i.e. a peak
    CC = bwconncomp(img_l);
    peak_ind = [];
    for j = 1 : size(CC.PixelIdxList,2)
        
        region_ind = cell2mat(CC.PixelIdxList(j));
        [~,ind] = max(img(region_ind));
        peak_ind(j) = region_ind(ind(1));
        
    end
    
    region_peak_ind{i} = peak_ind;
end

% peaks with pixel index (ii, jj)
% peaks = zeros(particle_num,3);
peaks = [];

for i = 2 : level_num
    
    peaks_old = cell2mat(region_peak_ind(i-1));
    peaks_new = cell2mat(region_peak_ind(i));
    
    flagSubset = ~ismember(peaks_old,peaks_new);
    
    [ii, jj] = ind2sub(size(img),peaks_old(flagSubset));
    
    dp = sum(flagSubset);
    
    peaks(p+1:p+dp,:) = [ii; jj]';
    
    p = p + dp;
    
end

[ii, jj] = ind2sub(size(img),cell2mat(region_peak_ind(level_num)));
dp = length(ii);
peaks(p+1:p+dp,:) = [ii; jj]';
p = p + dp;

peaks = peaks(1:p,:);

% =========================================================================
% dilation procedure

% the matrix that marks each voxel in particle cores with the particle number
core = zeros(size(img));

% a slower but more robust version of the dilation procedure
edge_i = zeros(1,p);
boundaries = cell(1,p);
for current_particle = 1 : p
    core_i = peaks(current_particle,1);
    core_j = peaks(current_particle,2);
    boundaries{current_particle} = [core_i, core_j];
    edge_i(current_particle) = img(core_i, core_j) * 0.25;
    core(core_i, core_j) = current_particle;
end

while ~isempty(boundaries)
    
    new_boundaries = {};
    
    for i = 1:length(boundaries)
        
        boundary = boundaries{i};
        new_boundary = [];
        
        for j = 1:size(boundary,1)
            
            x = boundary(j,1);
            y = boundary(j,2);
            current_particle = core(x,y);
            
            for search_voxel = 1 : size(dx,2)
                
                % the indices of the surrounding voxel
                xx = x + dx(search_voxel);
                yy = y + dy(search_voxel);
                
                if (xx < 1) || (xx > s1) || (yy < 1) || (yy > s2) || (core(xx,yy) > 0)
                    continue
                end;
                
                
                % if this voxel is brighter than the basic threshold
                % and dimmer than the current voxel
                if (img(xx,yy) >= edge_i(current_particle)) && (img(xx,yy) <= img(x,y)) %img(core_i,core_j)) %
                    
                    % mark this voxel with current particle number
                    core(xx,yy) = current_particle;
                    new_boundary = [new_boundary;xx yy];
                    
                end
            end
            
            
        end
        if ~isempty(new_boundary)
            new_boundaries{length(new_boundaries)+1} = new_boundary;
        end
    end
    boundaries = new_boundaries;
    
end


% a faster but less robust version of the dilation procedure

% % for each peak recorded in the erosion procedure
% for current_particle = 1 : p
%
%     % initialize the flood-fill with the peak location as the seed
%     seed = peaks(current_particle,:);
%     core_i = seed(1);
%     core_j = seed(2);
%     core(core_i,core_j) = current_particle;
%     edge_i = img(core_i,core_j) * 0.50;
%
%     % place the seed into the search stack
%     l = 1;
%     list = zeros(200,2);
%     list(l,:) = seed;
%
%     % the flood-fill procedure that marks the voxels with particle number
%     while l > 0
%
%         % take the voxel from the tail of the stack
%         pixel = list(l,:);
%         x = pixel(1);
%         y = pixel(2);
%         l = l - 1;
%
%         % look around the current voxel in the neighbors
%         for search_voxel = 1 : size(dx,2)
%
%             % the indices of the surrounding voxel
%             xx = x + dx(search_voxel);
%             yy = y + dy(search_voxel);
%
%             if (xx < 1) || (xx > s1) || (yy < 1) || (yy > s2)
%                 continue
%             end;
%
%             % if this voxel is brighter than the basic threshold
%             % and dimmer than the current voxel
%             if (img(xx,yy) >= edge_i) && (img(xx,yy) <= img(x,y)) % img(core_i,core_j)) %
%
%                 % if this voxel has not been visited before
%                 if (core(xx,yy) == 0)
%
%                     % mark this voxel with current particle number
%                     core(xx,yy) = current_particle;
%
%                     % place this voxel into the stack
%                     l = l + 1;
%                     list(l,:) = [xx,yy];
%
%                 end
%
%                 % if this voxel has been visited from other cores
%                 if  (core(xx,yy) > 0) && (core(xx,yy) ~= current_particle)
%
%                     % this voxel doesn't belong to a particle core
%                     % since it is under the influece of more than one particle
%                     core(xx,yy) = -1;
%
%                 end
%             end
%         end
%     end
%
% end
%
% % mark all the non-core voxels with zero
% core(core == -1) = 0;
%
% end