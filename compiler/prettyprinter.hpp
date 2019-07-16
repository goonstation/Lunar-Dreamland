#pragma once
#include "nodes.h"
#include <iostream>

class AstPrinter : public Visitor
{
public:
	int indent = -1;

	void evaluate(Node* e)
	{
		e->accept(*this);
	}

	void pprint(Node* n)
	{
		indent++;
		evaluate(n);
		indent--;
	}

	void iprint(std::string thing)
	{
		std::cout << std::string(indent, ' ') << thing << std::endl;
	}

	void visit(Block& b) override
	{
		iprint("{");
		for (Node* n : b.stmt_list)
		{
			pprint(n);
		}
		iprint("}");
	}

	void visit(ExpressionList& e)
	{
		if (e.expressions) {
			for (Node* n : *e.expressions)
			{
				pprint(n);
			}
		}
	}

	void visit(VariableDeclaration& v) override
	{
		iprint("var/" + v.name);
		if (v.initializer)
		{
			pprint(v.initializer);
		}
	}

	void visit(Integer& i) override
	{
		iprint(i.value);
	}

#define VISIT_BINOP(x, sym) void visit(##x##& y) override { iprint(sym); pprint(y.left); pprint(y.right); }

	VISIT_BINOP(Addition, "+")
	VISIT_BINOP(Subtraction, "-")
	VISIT_BINOP(Multiplication, "*")
	VISIT_BINOP(Division, "/")
	VISIT_BINOP(Equal, "==")
	VISIT_BINOP(NotEqual, "!=")
	VISIT_BINOP(GreaterThan, ">")
	VISIT_BINOP(LessThan, "<")
	VISIT_BINOP(GreaterOrEqual, ">=")
	VISIT_BINOP(LessOrEqual, "<=")

#undef VISIT_BINOP

	void visit(ArithmeticNegation& an) override
	{
		iprint("-");
		pprint(an.right);
	}

	void visit(LogicalNegation& an) override
	{
		iprint("!");
		pprint(an.right);
	}

	void visit(Group& g) override
	{
		evaluate(g.content);
	}

	void visit(FunctionCall& fc) override
	{
		iprint("<function call> " + fc.name);
		pprint(fc.args);
	}

	void visit(VariableAccess& va) override
	{
		iprint("<variable> " + va.name);
		if (va.subvar)
		{
			SubAccess* current_subvar = va.subvar;
			while (current_subvar)
			{
				iprint("." + current_subvar->name);
				current_subvar = current_subvar->subvar;
			}
		}
	}

	void visit(String& s) override
	{
		iprint("\"" + s.value + "\"");
	}

	void visit(Float& s) override
	{
		iprint(s.value);
	}

	void visit(If& i) override
	{
		iprint("if");
		pprint(i.condition);
		indent++;
		iprint("then");
		pprint(i.if_body);
		if (i.else_body) {
			iprint("else");
			pprint(i.else_body);
		}
		indent--;
	}

	void visit(Return& r) override
	{
		iprint("return");
		if (r.return_expr)
			pprint(r.return_expr);
	}

	void visit(Output& o) override
	{
		iprint("output");
		pprint(o.left);
		pprint(o.right);
	}

	void visit(ListDeclaration& ld) override
	{
		iprint("list");
		pprint(ld.contents);
	}

	void visit(ListAccess& la) override
	{
		iprint(la.name);
		iprint("[");
		pprint(la.index);
		iprint("]");
		if (la.subvar)
		{
			SubAccess* current_subvar = la.subvar;
			while (current_subvar)
			{
				iprint("." + current_subvar->name);
				current_subvar = current_subvar->subvar;
			}
		}
	}
};
