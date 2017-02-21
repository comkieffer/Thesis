
classdef LCallNode < LNode
    
    properties 
       expression = ''; 
    end
    
    methods
        function self = LCallNode(fragment)
            self@LNode(fragment);
        end
        
        function process_fragment(self, fragment)
            self.expression = strtrim(fragment);
        end
        
        function str = render(self, context)
            str = eval_with_context(self.expression, context);
            
            if ~ischar(str)
                error('Lobster:CallError', ...
                    'The output of <%s> was not a string.', self.expression);
            end
        end
    end
    
end