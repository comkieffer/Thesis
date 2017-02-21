
classdef LFragment < handle
   
    properties 
       raw = ''; 
       clean = '';
       type;
    end
    
    methods (Access = private)
        % Strip the token start and end tags from the raw text of the framgent
        % and remove whitespace. 
        function cleaned_text = clean_fragment(~, raw)
            token_starts = {LCompiler.VAR_TOKEN_START LCompiler.BLOCK_TOKEN_START};
            
            if length(raw) >= 2 & find(strcmp(raw(1:2), token_starts))
                cleaned_text = strtrim(raw(3:end-2));
            else 
                cleaned_text = raw;
            end
        end
        
        function compute_type(self)
            % If the length of the raw string is less than the minimum length
            % needed to fit the START_BLOCK and END_BLOCK delimiters then we can
            % be sure that the fragment is a text node.  
            if length(self.raw) < 4
                self.type = LFRAGMENT_TYPE.TEXT;
                return
            end
            
            raw_start = self.raw(1:2);
            if strcmp(raw_start, LCompiler.VAR_TOKEN_START)
               self.type = LFRAGMENT_TYPE.VAR;
            elseif strcmp(raw_start, LCompiler.BLOCK_TOKEN_START)
                if strcmp(self.clean(1:3), 'end')
                    self.type = LFRAGMENT_TYPE.BLOCK_END;
                else
                    self.type = LFRAGMENT_TYPE.BLOCK_START;
                end               
            else
               self.type = LFRAGMENT_TYPE.TEXT;
end
        end
    end
    
    methods 
        function self = LFragment(raw)
           self.raw = raw;
           self.clean = self.clean_fragment(raw);
           
           self.compute_type();
        end
    end
end
