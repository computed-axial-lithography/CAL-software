classdef CALCreateImageSet
    
    properties
        projection_obj
        image_params
        backwards_comp_params
        default
        angles
        proj
        verbose
    end
    
    methods
        function obj = CALCreateImageSet(projection_obj,image_params,varargin)
            
            obj.projection_obj = projection_obj;
            obj.image_params = image_params;
            
            if nargin == 3
                obj.verbose = varargin{1};
            else
                obj.verbose = 0;
            end
            
            if ~isequal(class(projection_obj),'ProjObj')
                if ~isfield(obj.image_params,'angles')
                    error('Backwards compatibility: Creating projection set directly from projection matrix requires image_params.angles to be set to the angles at which the projection matrix was generated.')
                    return
                else
                    obj.backwards_comp_params.gen_from_old_proj = true;
                    warning('Attempting backward compatible image set creation. Check that the output image set matches expectations.');
                    pause(1);fprintf('.');pause(1);fprintf('.');pause(1);fprintf('.');pause(1);fprintf('.');pause(1);fprintf('.');
                end
                obj.angles = obj.image_params.angles;
                obj.proj = projection_obj;
                
            else
                obj.backwards_comp_params.gen_from_old_proj = false;
                obj.angles = projection_obj.proj_params_used.angles;
                obj.proj = obj.projection_obj.projection;
            end
            
            
            
            
            % set default parameters
            obj.default.t_offset = 0;
            obj.default.z_offset = 0;
            obj.default.array_offset = 0;
            obj.default.array_num = 1;
            obj.default.size_scale_factor = 1;
            obj.default.intensity_scale_factor = 1;
            obj.default.invert_vert = 0;
            obj.default.rotate = 0;
            
            if ~isfield(obj.image_params,'image_width')
                error('You must specify the width of the projection image in dimensions of pixels in the image parameters.');
            end          
            if ~isfield(obj.image_params,'image_height')
                error('You must specify the height of the projection image in dimensions of pixels in the image parameters.');
            end 
            if ~isfield(obj.image_params,'t_offset')
                obj.image_params.t_offset = obj.default.t_offset;
            end       
            if ~isfield(obj.image_params,'z_offset')
                obj.image_params.z_offset = obj.default.z_offset;
            end    
            if ~isfield(obj.image_params,'array_offset')
                obj.image_params.array_offset = obj.default.array_offset;
            end 
            if ~isfield(obj.image_params,'array_num')
                obj.image_params.array_num = obj.default.array_num;
            end       
            if ~isfield(obj.image_params,'size_scale_factor')
                obj.image_params.size_scale_factor = obj.default.size_scale_factor;
            end
            if ~isfield(obj.image_params,'intensity_scale_factor')
                obj.image_params.intensity_scale_factor = obj.default.intensity_scale_factor;
            end
            if ~isfield(obj.image_params,'invert_vert')
                obj.image_params.invert_vert = obj.default.invert_vert;
            end
            if ~isfield(obj.image_params,'rotate')
                obj.image_params.rotate = obj.default.rotate;
            end

           
            
        end
        
        function [image_set_obj] = run(obj)
            
            
            % input dimensions: [nT,nTheta,nZ]
            proj_mod = permute(obj.proj,[3,2,1]);
            % output dimensions: [nZ,nTheta,nT]
            % reverse order of z to get from intrinsic c.s. of image to
            % expected c.s. of .stl
            proj_mod = obj.flipUD(proj_mod);
            
            if obj.image_params.invert_vert ~= obj.default.invert_vert
                proj_mod = obj.flipUD(proj_mod);
            end
            
            if obj.image_params.rotate ~= obj.default.rotate
                proj_mod = obj.rotate(proj_mod,obj.image_params.rotate);
            end
            
            if obj.image_params.size_scale_factor ~= obj.default.size_scale_factor
                proj_mod = obj.sizeScale(proj_mod,obj.image_params.size_scale_factor);
            end
            
            if obj.image_params.intensity_scale_factor ~= obj.default.intensity_scale_factor
                proj_mod = obj.intensityScale(proj_mod,obj.image_params.intensity_scale_factor);
            end

            
            if max(obj.angles) <= 180
                image_set = cell(1,2*length(obj.angles));
                for i=1:length(obj.angles)
                    if obj.verbose
                        fprintf('\nAdding projection #%5.0f to image #%5.0f/%5.0f',i,i,2*length(obj.angles));
                    end
                    image_set{i} = obj.arrayInsertProj(  squeeze(proj_mod(:,i,:)),...
                                                        obj.image_params.image_width,...
                                                        obj.image_params.image_height,...
                                                        obj.image_params.t_offset,...
                                                        obj.image_params.z_offset,...
                                                        obj.image_params.array_num,...
                                                        obj.image_params.array_offset);
                end
                proj_mod = obj.flipLR(proj_mod);
                for i=1:length(obj.angles)
                    if obj.verbose
                        fprintf('\nAdding projection #%5.0f to image #%5.0f/%5.0f',i+length(obj.angles),i+length(obj.angles),2*length(obj.angles));
                    end
                    image_set{i+length(obj.angles)} = obj.arrayInsertProj(  squeeze(proj_mod(:,i,:)),...
                                                        obj.image_params.image_width,...
                                                        obj.image_params.image_height,...
                                                        obj.image_params.t_offset,...
                                                        obj.image_params.z_offset,...
                                                        obj.image_params.array_num,...
                                                        obj.image_params.array_offset);
                end
            end
            if max(obj.angles) > 180 && max(obj.angles) <= 360
                image_set = cell(1,length(obj.angles));
                for i=1:length(obj.angles)
                    if obj.verbose
                        fprintf('\nAdding projection #%5.0f to image #%5.0f/%5.0f',i,i,length(obj.angles));
                    end
                    image_set{i} = obj.arrayInsertProj(  squeeze(proj_mod(:,i,:)),...
                                                        obj.image_params.image_width,...
                                                        obj.image_params.image_height,...
                                                        obj.image_params.t_offset,...
                                                        obj.image_params.z_offset,...
                                                        obj.image_params.array_num,...
                                                        obj.image_params.array_offset);
                end
            end
            
            

            if obj.backwards_comp_params.gen_from_old_proj == true 
                obj.backwards_comp_params.angles = obj.angles;
                image_set_obj = ImageSetObj(image_set,...
                                          obj.image_params,...
                                          obj.backwards_comp_params,...
                                          []);
                
            else
                image_set_obj = ImageSetObj(image_set,...
                                      obj.image_params,...
                                      obj.projection_obj.proj_params_used,...
                                      obj.projection_obj.opt_params_used);
            end
        end
        
        

    end
    
    methods (Static = true)
        function out = flipUD(proj)
            out = flip(proj,1);
        end
        
        function out = flipLR(proj)
            out = flip(proj,3);
        end
        
        function out = rotate(proj,angle)
            out = imrotate3(proj,angle,[1,0,0],'nearest');
        end

        function out = sizeScale(proj,scale)
            [nT,nTheta,nZ] = size(proj);
            
            nT_in = linspace(0,1,nT);
            nZ_in = linspace(0,1,nZ);
            
            gi = griddedInterpolant;
            gi.GridVectors = {nT_in, 1:nTheta, nZ_in};
            gi.Values = double(proj);
            gi.Method = 'nearest';

            nT_out = linspace(0,1,round(nT*scale));
            nZ_out = linspace(0,1,round(nZ*scale));
            
            out = gi({nT_out,1:nTheta,nZ_out});
        end
        
        function out = intensityScale(proj,scale)
            proj = 255*proj/max(proj(:));
            out = min(255,proj.*scale);
            out = uint8(out);
        end
        
        function image = arrayInsertProj(proj,image_width,image_height,t_offset,z_offset,array_num,array_offset)
            
            function array_vec = arrayVec(array_num)
                array_vec = zeros(1,array_num);
                for i=0:array_num-1
                    array_vec(i+1) = 0 + ceil(i/2)*(-1)^(i+1);
                end
            end
            
            function image = insertProj(proj,image,image_width,image_height,t_offset,z_offset)
                
                assert(abs(t_offset) < image_width/2,'Transverse projection offset is too large and the projection falls outside the image bounds');
                assert(abs(z_offset) < image_height/2,'Z projection offset is too large and the projection falls outside the image bounds. Decrease z offset or array offset (if multiplying projection images).')
                
                [proj_height,proj_width] = size(proj);

                % Define the position of the projection within the full size projected
                % image
                img_rows = round(image_height/2 - proj_height/2 - z_offset): round(image_height/2 + proj_height/2-1 - z_offset);
                img_cols = round(image_width/2 - proj_width/2 + t_offset): round(image_width/2 + proj_width/2-1 + t_offset);

                image(img_rows,img_cols) = proj;
            end
            
            proj = uint8(proj/max(proj(:))*255);
            image = zeros(image_height,image_width,'uint8');
            array_vec = arrayVec(array_num);
            for k=1:array_num
                tmp_z_offset = array_offset*array_vec(k) + z_offset;
                image = insertProj(proj,image,image_width,image_height,t_offset,tmp_z_offset);
            end

        end
        
        function [] = saveImages(image_set_obj,save_path,image_type)
                        
            if ~exist('image_type','var')
                image_type = '.jpg';
            end
            
            if ~exist(fullfile(save_path,'images'), 'dir')
                mkdir(fullfile(save_path,'images'));
            end
            
            for i=1:size(image_set_obj.image_set,2)
                filename = strcat(sprintf('%04d',i),image_type);
                imwrite(image_set_obj.image_set{i},fullfile(save_path,'images',filename));
                fprintf('Writing image %4d/%d\n',i,size(image_set_obj.image_set,2))
            end
        end

    end
    
end

