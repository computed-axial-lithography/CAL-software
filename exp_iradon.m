function [recon] = exp_iradon(params,projections,domain_size)
% INPUTS:   params       =  struct, contains all parameters specific to the
%                           process including vial radius, pentration depth,
%                           interpolation method
%           projections  =  matrix, projections from radon transform
%           domain_size  =  vector, size of the reconstruction/target space
%
% OUTPUTS:  recon        =  matrix, reconstruction with size of domain_size
%
%
% Copyright 1993-2017 The MathWorks, Inc.
%
% References:
%      A. C. Kak, Malcolm Slaney, "Principles of Computerized Tomographic
%      Imaging", IEEE Press 1988.


persistent exp_contrib_LU
if isempty(exp_contrib_LU)
    exp_contrib_LU = gen_att_table(params,domain_size);
end


p = projections;
N = domain_size(1);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);

len = size(p,1);
ctrIdx = ceil(len/2);     % index of the center of the projections

% Zero pad the projections to size 1+2*ceil(N/sqrt(2)) if this
% quantity is greater than the length of the projections
imgDiag = 2*ceil(N/sqrt(2))+1;  % largest distance through image.
if size(p,1) < imgDiag
    rz = imgDiag - size(p,1);  % how many rows of zeros
    p = [zeros(ceil(rz/2),size(p,2)); p; zeros(floor(rz/2),size(p,2))];
    ctrIdx = ctrIdx+ceil(rz/2);
end

% Backprojection - vectorized in (x,y), looping over angles
       

% interp_method = sprintf('*%s',params.interp_method); % Add asterisk to assert
                                       % even-spacing of taxis

% Generate trignometric tables
costheta = cosd(params.angles);
sintheta = sind(params.angles);

% Allocate memory for the image
recon = zeros(N,'like',p);

for i=1:length(params.angles)
    proj = p(:,i);
    taxis = (1:size(p,1)) - ctrIdx;
    t = x.*costheta(i) + y.*sintheta(i);

    projContrib = interp1(taxis,proj,t(:),'linear');
    recon = recon + exp_contrib_LU(:,:,i).*reshape(projContrib,N,N);


%     imagesc(recon)
%     colormap jet
%     daspect([1 1 1])
%     pause(0.01)


end

recon(isnan(recon)) = 0;


% figure(9)
% imagesc(recon)
% colormap jet
% daspect([1 1 1])
% pause(0.01)


recon = recon*pi/(2*length(params.angles));
