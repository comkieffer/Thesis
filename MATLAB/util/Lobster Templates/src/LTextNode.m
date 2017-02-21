
classdef LTextNode < LNode
    
    properties
       text = ''; 
    end
    
    methods
        function self = LTextNode(fragment)
           self@LNode(fragment); 
        end
        
        function process_fragment(self, fragment)
            self.text = fragment;
        end
        
        function str = render(self, ~)
           str = self.text; 
        end
    end
    
end