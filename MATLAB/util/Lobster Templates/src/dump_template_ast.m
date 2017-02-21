

function dump_template_ast(root)
    if isa(root, 'LTemplate')
        root = root.root;
    end

    print_node(root, 0)
end

function print_node(node, indent)
    node_type = class(node);
    indent_str = repmat(' ', 1, indent);
    
    if strcmp(node_type, 'LRoot')
        fprintf('%s[LRoot]\n', indent_str);
    elseif strcmp(node_type, 'LTextNode')
        fprintf('%s[Text Node] - <%s>\n', indent_str, ...
            strrep(node.text, sprintf('\n'), ''));
    elseif strcmp(node_type, 'LVarNode')
        fprintf('%s[Var Node] - <{{ %s }}>\n', indent_str, node.name);
    elseif strcmp(node_type, 'LIfNode')
        fprintf('%s[If Node] - <Expr: %s>\n', indent_str, node.expression);
    elseif strcmp(node_type, 'LElseNode')
        fprintf('%s[Else Node]\n', indent_str);
    elseif strcmp(node_type, 'LForNode')
        fprintf('%s[For Node] - Expr: %s in %s>\n', indent_str, node.lhs, node.rhs);
    elseif strcmp(node_type, 'LCallNode')
        fprintf('%s[Call Node] - <Expr: %s>\n', indent_str, node.expression);
    else
        fprintf('%s[Unknown Node Type] <%s>\n', indent_str, class(node));
    end
    
    for k = 1:length(node.children)
        print_node(node.children{k}, indent+2);
    end
end