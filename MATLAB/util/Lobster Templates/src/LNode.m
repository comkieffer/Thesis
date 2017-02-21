
% The node is the basic element of a template. Every fragment of text will be 
% converted to an appropriate node type. 
% 
% Nodes need to implement certain behaviours:
%
% process_fragment takes care of parsing the textstring describing it to extract
% meaning. An if node for example will look for the conditional and store it to
% be evaluated at render time. 
%
% render is called to render the node. Each node is responsible for rendering
% itself. A text Node will simply return its contents wheras an if node will
% evaluate the conditioinal and decide whether to render the if branch or the
% else branch for example.
%
% Some nodes also have children. The children of a for loop for example are all
% the nodes contained between the initial {% for .. %} and the corresponding {%
% end %} node. A node can signal this fact by setting self.creates_scope to
% true.

classdef LNode < handle 
       
    properties
       creates_scope = false;
       children = cell(0); 
    end
    
    methods 
        function self = LNode(fragment)
            if ~exist('fragment', 'var')
                fragment = '';
            end
            
            self.process_fragment(fragment);
        end
        
        function process_fragment(self, fragment)
            error('Lobster:MethodNotImplemented', ...
                '<process_fragment> is not implemented on <LNode>');
        end
        
        function enter_scope(self)
            error('Lobster:MethodNotImplemented', ...
                '<enter_scope> is not implemented on <LNode>');
        end
        
        function exit_scope(self)
            error('Lobster:MethodNotImplemented', ...
                '<exit_scope> is not implemented on <LNode>');
        end
        
        function str = render(self, context)
            error('Lobster:MethodNotImplemented', ...
                '<render> is not implemented on <LNode>');
        end
        
        function str = render_children(self, context, children)
            if ~exist('children', 'var')
                children = self.children;
            end
            
            rendered_children = cellfun(@(x) x.render(context), ...
                children, 'Uniform', false);
            
            str = strjoin(rendered_children, '');
        end
            
        function add_child(self, child)
            if ~isa(child, 'LNode')
                error('Lobster:GenericError', ...
                    'Attempted to add a <%s> to this node''s children. Children must be subclasses of LNode.', ...
                    class(child));
            end
            
           self.children{end+1} = child; 
        end
    end
    
    
end
