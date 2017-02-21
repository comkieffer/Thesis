
classdef TestTemplate < matlab.unittest.TestCase
   
    properties (TestParameter)
       falsy_value = {false, 0, '', []};
       truthy_value = {true, 1, -1, 2, 5, -7, 'true', 'stuff', [1, 1]};
    end
    
    methods (Test)
        function test_empty(self)
            tpl = LTemplate('');
            self.assertEqual(tpl.render(), '');
        end
        
        function test_simple(self)
            tpl = LTemplate('This is a test string.');
            self.assertEqual(tpl.render(), 'This is a test string.');
        end
        
        function test_int_var(self)
            context.var = 1;
            tpl = LTemplate('{{ var }}');
            self.assertEqual(tpl.render(context), '1');
        end
        
        function test_string_var(self)
            context.var = 'stuff';
            tpl = LTemplate('{{ var }}');
            self.assertEqual(tpl.render(context), 'stuff');
        end
        
        function test_text_and_var(self)
            context.var = 1;
            tpl = LTemplate('This is {{ var }}');
            self.assertEqual(tpl.render(context), 'This is 1');
        end
        
        function test_var_and_text(self)
            context.var = 1;
            tpl = LTemplate('{{ var }} is cool');
            self.assertEqual(tpl.render(context), '1 is cool');
		end
		
		function test_var_with_map_access(self)
            context.var = containers.Map('some_key', 'the value');
            tpl = LTemplate('{{ var }} is cool');
            self.assertEqual(tpl.render(context), 'the value is cool');
		end
		
		function test_undefined_var_error(self)
			context = struct();
            tpl = LTemplate('{{ var }} is cool');
			self.assertThat(tpl.render(), Throws('Lobster:TemplateContextError'));
		end
		
        function test_if_true_with_no_context(self)
            tpl = LTemplate('{% if true %}You should see this{% endif %}');
            self.assertEqual(tpl.render(), 'You should see this');
        end
        
        function test_if_false_with_no_context(self)
           tpl = LTemplate('{% if false %}You should not see this{% end %}');
           self.assertEqual(tpl.render(), '');
        end
        
        function test_if_true_with_else(self)
           tpl = LTemplate('{% if true %}Show this{% else %} Not this{% end %}');
           self.assertEqual(tpl.render(), 'Show this');
        end
        
        function test_if_false_with_else(self)
           tpl = LTemplate('{% if false %}Show this{% else %}Not this{% end %}');
           self.assertEqual(tpl.render(), 'Not this');
		end
		
		function test_if_with_conditional(self)
            tpl = LTemplate('{% if length(1:5) > 4 %}You should see this{% endif %}');
            self.assertEqual(tpl.render(), 'You should see this');
		end
        
        function test_for_with_array(self)
            tpl = LTemplate('{% for k in 1:5 %}{{ k }} {% end %}');
            self.assertEqual(tpl.render(), '1 2 3 4 5 ');
        end
        
        function test_for_with_empty_array(self)
            tpl = LTemplate('{% for k in [] %}{{ k }} {% end %}');
            self.assertEqual(tpl.render(), '');
        end
        
        function test_for_with_cell(self)
            context.collection = num2cell(1:5);
            tpl = LTemplate('{% for k in 1:5 %}{{ k }} {% end %}');
            self.assertEqual(tpl.render(context), '1 2 3 4 5 ');
        end
        
        function test_for_with_empty_cell(self)
            context.collection = cell(0);
            tpl = LTemplate('{% for k in collection %}{{ k }} {% end %}');
            self.assertEqual(tpl.render(context), '');
        end
        
        function test_for_with_struct(self)
            context.collection = struct('val', num2cell(1:5));
            tpl = LTemplate('{% for k in collection %}{{ k.val }} {% end %}');
            self.assertEqual(tpl.render(context), '1 2 3 4 5 ');
        end

        function test_for_with_empty_struct(self)   
            context.collection = struct([]);
            tpl = LTemplate('{% for k in collection %}{{ k.val }} {% end %}');
            self.assertEqual(tpl.render(context), '');
		end
    end
    
    methods (Test, ParameterCombination='sequential')
        
        function test_if_false_with_context(self, falsy_value)
            context.var = falsy_value;
            tpl = LTemplate('{% if var %}You should not see this{% end %}');
            self.assertEqual(tpl.render(context), '');
        end
        
        function test_if_true_with_context(self, truthy_value)
            context.var = truthy_value;
            tpl = LTemplate('{% if var %}You should see this{% endif %}');
            self.assertEqual(tpl.render(context), 'You should see this');
        end
	end
end
