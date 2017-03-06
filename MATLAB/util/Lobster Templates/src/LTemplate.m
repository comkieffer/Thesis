
classdef LTemplate < handle
   
    properties
       root;
    end
    
    methods (Static)
        function tpl = load(filename)
           [fid, err] = fopen(filename, 'rt'); 
           
           if fid < 0 
               error('Unable to open %s. Error: %s\n', filename, err);
           end
           
           file_contents = {};
           line = fgetl(fid);
           while ischar(line)
              file_contents{end+1} = line;
              line = fgetl(fid);
           end
           
           % tpl = LCompiler(fread(fid));
           tpl = LTemplate(file_contents);
        end
    end
    
    methods
        function self = LTemplate(template_string)
            if iscell(template_string)
                template_string = strjoin(template_string, '\n');
            end
            
%           assert(~(ischar(template_string) || iscellstr(template_string), fprintf( ...
%                 'template_string must be a string or a cellarray of strings. Instead it was a <%s>', class(template_string)));
            
            self.root = LCompiler(template_string).compile();
        end
        
        function str = render(self, context)
            if ~exist('context', 'var')
                context = struct();
            end
            
            str = self.root.render(context);
            str = strrep(str, '{#', '{');
            str = strrep(str, '#}', '}');
        end
    end
    
end