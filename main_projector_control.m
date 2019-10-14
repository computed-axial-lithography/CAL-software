%{
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

%% Main projector-control code
% Created by: Joseph Toombs 09/2019

%% Options
params.wd_screen = 2716; % width in pixels of the projector's DMD
params.ht_screen = 1528; % height in pixels of the projector's DMD
params.scale_factor = 1; % projection image XY scaling factor 
params.invert_vertical = 0; % invert vertical orientation of projection
params.invert_horizontal = 0; % invert horizontal orientation of projection
params.ht_offset = 0; % height offset of projection within the bounds of the projected image
params.wd_offset = 0; % width offset of projection within the bounds of the projected image
params.intensity_scale_factor = 1; % intensity scaling factor

params.max_angle = 360; % max angle of the projection set
params.rot_velocity = 12; % stage rotational velocity degrees/s
params.n_rotations = 100000; % maximum number of rotations to complete in projection; set arbitrarily large for infinite or otherwise unknown maximum rotations
params.time_project = 100000; % maximum time of projection; set arbitrarily high for infinite or otherwise unknown projection duration
params.verbose = 1;

%% Projection operation
projection_set = create_projection_set(params,optimized_projections);

project(params,projection_set)