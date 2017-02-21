classdef LRoot < LNode
  
    methods
        function self = LRoot()
            self@LNode('');
        end
        
        function str = render(self, context)
            if ~exist('context', 'var')
                context = struct();
            end
            
            str = self.render_children(context);
        end        
        
        function process_fragment(self, fragment)
        end
    end
    
end