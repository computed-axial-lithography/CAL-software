function att_table = gen_att_table(params,domain_size,occlusion)
% INPUTS:  params        =  struct, contains all parameters specific to the
%                           process including vial radius, pentration depth,
%                           interpolation method
%          domain_size   =  vector, size of the reconstruction/target space
% 
% OUTPUTS: att_table     =  matrix, [N x N x N_theta] contribution of resin 
%                           attenuation at each angle in params.angles; 
%                           each contribution is used as a multiplier
%                           modifying the backprojected intensity in
%                           exp_iradon()


% Preallocate 3D matrix for lookup table
att_table = single(zeros([domain_size(1),domain_size(2),length(params.angles)]));
N = domain_size(1);

% Generate trignometric tables
costheta = cosd(params.angles);
sintheta = sind(params.angles);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);


% Convert physical parameters to dimensions of pixels if physical parameters are setup
if params.resin_abs_coeff ~= 0
    resin_penetration_depth_pix = round(1/params.resin_abs_coeff/params.voxel_size);
    vial_radius_pix = round(params.vial_radius/params.voxel_size);
end

% Circle that bounds the 
radius_bound = (x.^2 + y.^2 < vial_radius_pix^2);


for i = 1:length(params.angles)
    

    
    t = x.*costheta(i) + y.*sintheta(i);
    t_perp = -x.*sintheta(i) + y.*costheta(i); 
    
    w = real(-sqrt(vial_radius_pix^2 - x.^2)) - y;
    w(:,[1:size(x,1)/2-vial_radius_pix,size(x,1)/2+vial_radius_pix:end]) =  0;
    exp_decay = exp(w./resin_penetration_depth_pix);   % also could be exp(w./(resin_abs_coeff_pix)^-1)) which is exp(w./(resin_penetration_depth_pix))
    
    expProjContrib = interp2(x,y,exp_decay,t,t_perp,'linear');
    


    
    expProjContribNN = reshape(expProjContrib,N,N);
    
    if exist('occlusion','var')
        occlusion_line = ones(N,N).*((x == 0) & (y >= 0));
        occlusion_line = imrotate(occlusion_line,params.angles(i),'nearest','crop');
        shadow = conv2(occlusion_line,occlusion,'same');
        figure(100); imagesc(shadow);
        expProjContribNN = expProjContribNN.*radius_bound.*~shadow;
    else
        expProjContribNN = expProjContribNN.*radius_bound;
    end
    
    
    
    att_table(:,:,i) = expProjContribNN;
    

%     figure(1)
%     imagesc(att_table(:,:,i))
%     axis square   
    
end