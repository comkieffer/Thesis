
classdef LElseNode < LNode
   
    methods
        function self = LElseNode()
            self@LNode('');
        end
        
        function str = render(~, ~)
            str = '';
        end
    end
end