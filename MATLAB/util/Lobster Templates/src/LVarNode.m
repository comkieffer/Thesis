
classdef LVarNode < LNode
    
    properties 
       name = ''; 
    end
    
    methods
        function self = LVarNode(fragment)
           self@LNode(fragment); 
        end
        
        function process_fragment(self, fragment)
            self.name = fragment;
        end
        
        function str = render(self, context)
            var = eval_with_context(self.name, context);
            
            if isnumeric(var)
                str = num2str(var);
            elseif ischar(var)
                str = var;
            else
                error('Lobster:VariableTypeError', ...
                    'I don''t know how to print the variable <%s> to a string', ... 
                    self.name);
            end
        end
    end
end
    