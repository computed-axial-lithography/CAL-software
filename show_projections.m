%{
Function that displays projections

INPUTS:
  projections = matrix, if 3D (nR x nTheta x nZ) the display will be
  sequential; if 2D (nR x nTheta) the display will be in sinogram form
  params.angles = vector, real projection angles in degrees

OUTPUTS:
  none

Created by: Joseph Toombs 09/2019

----------------------------------------------------------------------------
Copyright � 2017-2019. The Regents of the University of California, Berkeley. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.
3. Neither the name of the University of California, Berkeley nor the names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS 
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.
%}

function show_projections(params,projections)

% add path containing files for inferno colormap
addpath('inferno_bin');
addpath('imshow_3D_bin');

pause(0.5)
if numel(size(projections)) == 2
    subplot(2,4,4)
    imagesc(projections)
    colormap inferno
    title('Optimized Sinogram')
    pause(0.02);
else
    optimized_projections_axes = figure;
    [~, nTheta, ~] = size(projections);
    
    
    
    for ii_theta = 1:nTheta
%         axes(optimized_projections_axes);
        
        imagesc(squeeze(projections(:,ii_theta,:))')
       
        colormap inferno
        title_string = sprintf('Optimized Projections\n\\theta = %2.0f�', params.angles(ii_theta));
        title(title_string)
        axis equal
        axis off
        pause(0.02);
    end
    
    
    figure
    colormap inferno
    imshow3D(permute(projections,[3,1,2]),[],1);
end