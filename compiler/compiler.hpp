#include "nodes.h"
#include <map>
#include <iostream>
#include "opcodes.h"

class CodeGenerator : Visitor
{
public:
	std::vector<unsigned int> bytecode;
	std::map<std::string, unsigned int> localvars;
	std::vector<unsigned int> string_positions;
	std::vector<const char*> strings;
	std::vector<unsigned int> call_positions;
	std::vector<const char*> function_names;
	void compile(Node* e)
	{
		e->accept(*this);
	}

	void emit(std::vector<unsigned int> bytes)
	{
		bytecode.insert(bytecode.end(), bytes.begin(), bytes.end());
	}

	void visit(Block& b) override
	{
		std::cout << "Compiling Block" << std::endl;
		for (Node* n : b.stmt_list)
		{
			compile(n);
		}
	}

	void visit(ExpressionList& e)
	{
		std::cout << "Compiling ExpressionList" << std::endl;
		if (e.expressions)
		{
			for (Node* n : *e.expressions)
			{
				compile(n);
			}
		}
	}

	void visit(VariableDeclaration& v) override
	{
		std::cout << "Compiling VariableDeclaration" << std::endl;
		if (v.initializer)
		{
			compile(v.initializer);
		}
		localvars[v.name] = localvars.size();
		emit({ SETVAR, LOCAL, localvars[v.name] });
	}

	void visit(Integer& i) override
	{
		std::cout << "Compiling Integer" << std::endl;
		emit({ PUSHI, std::stoul(i.value) });
	}

#define COMPILE_BINOP(x, opcode) void visit(##x##& y) override { std::cout << "Compiling " << #x << std::endl; compile(y.left); compile(y.right); emit({ opcode }); }

	COMPILE_BINOP(Addition, ADD)
	COMPILE_BINOP(Subtraction, SUB)
	COMPILE_BINOP(Multiplication, ADD)
	COMPILE_BINOP(Division, ADD)
	COMPILE_BINOP(Equal, TEQ)
	COMPILE_BINOP(NotEqual, TNE)
	COMPILE_BINOP(GreaterThan, TG)
	COMPILE_BINOP(LessThan, TL)
	COMPILE_BINOP(GreaterOrEqual, TGE)
	COMPILE_BINOP(LessOrEqual, TLE)

#undef COMPILE_BINOP

	void visit(ArithmeticNegation& an) override
	{
		std::cout << "Compiling ArithmeticNegation" << std::endl;
		compile(an.right);
		emit({ ANEG });
	}

	void visit(LogicalNegation& an) override
	{
		std::cout << "Compiling LogicalNegation" << std::endl;
		compile(an.right);
		emit({ NOT });
	}

	void visit(Group& g) override
	{
		std::cout << "Compiling Group" << std::endl;
		compile(g.content);
	}

	void visit(FunctionCall& fc) override
	{
		std::cout << "Compiling FunctionCall" << std::endl;
		compile(fc.args);
		emit({ CALLGLOB, fc.args->expressions->size(), 0x00 });
		call_positions.push_back(bytecode.size() - 1);
		char* c = new char[fc.name.size() + 1];
		strcpy_s(c, fc.name.size() + 1, fc.name.c_str());
		function_names.push_back(c);
	}

	std::vector<unsigned int> generate_subaccessor(SubAccess* acc)
	{
		std::vector<unsigned int> ret;
		if (acc->subvar)
		{
			ret.push_back(SUBVAR);
			auto subret = generate_subaccessor(acc->subvar);
			ret.insert(ret.end(), subret.begin(), subret.end());
			ret.push_back(0x00);
			string_positions.push_back(bytecode.size() - 1);
			char* c = new char[acc->subvar->name.size() + 1];
			strcpy_s(c, acc->subvar->name.size() + 1, acc->subvar->name.c_str());
			strings.push_back(c);
		}
		return ret;
	}

	void emit_accessor(VariableAccess& va)
	{
		if (va.name == "world")
			emit({ WORLD });
		else if (va.name == "src")
			emit({ SRC });
		else
		{
			if (localvars.find(va.name) == localvars.end()) {
				emit({ 0xDD, 0xEE });
			}
			else
				emit({ LOCAL, localvars[va.name] });
		}
	}

	void visit(VariableAccess& va) override
	{
		std::cout << "Compiling VariableAccess" << std::endl;
		emit({ GETVAR });
		if (va.subvar)
		{
			bytecode.push_back(SUBVAR);
			emit_accessor(va);
			auto subret = generate_subaccessor(va.subvar);
			bytecode.insert(bytecode.end(), subret.begin(), subret.end());
			bytecode.push_back(0x00);
			string_positions.push_back(bytecode.size() - 1);
			char* c = new char[va.subvar->name.size() + 1];
			strcpy_s(c, va.subvar->name.size() + 1, va.subvar->name.c_str());
			strings.push_back(c);
		}
		else {
			emit_accessor(va);
		}
	}

	void visit(String& s) override
	{
		std::cout << "Compiling String" << std::endl;
		emit({ PUSHVAL, STRING, 0x00 });
		string_positions.push_back(bytecode.size() - 1);
		char* c = new char[s.value.size() + 1];
		strcpy_s(c, s.value.size() + 1, s.value.c_str());
		strings.push_back(c);
	}

	void visit(Float& s) override
	{
		std::cout << "Compiling Float" << std::endl;
		union {
			unsigned int i;
			float f;
		} u;
		u.f = std::stof(s.value);
		emit({ PUSHVAL, NUMBER, u.i, 0x00 });
	}

	void visit(If& i) override
	{
		std::cout << "Compiling If" << std::endl;
		compile(i.condition);
		emit({ POP, JZ, 0x00 });
		const size_t jump_location = bytecode.size() - 1;
		compile(i.if_body);
		if (i.else_body) {
			emit({ JMP, 0x00 });
			size_t else_jump_location = bytecode.size() - 1;
			bytecode[jump_location] = bytecode.size();
			compile(i.else_body);
			bytecode[else_jump_location] = bytecode.size();
		}
		else
		{
			bytecode[jump_location] = bytecode.size();
		}
	}

	void visit(Return& r) override
	{
		std::cout << "Compiling Return" << std::endl;
		if (r.return_expr) {
			compile(r.return_expr);
			emit({ RET });
		}
		else
		{
			emit({ RETN });
		}
	}

	void visit(Output& o) override
	{
		std::cout << "Compiling Output" << std::endl;
		compile(o.left);
		compile(o.right);
		emit({ OUTPUT });
	}

	void visit(ListDeclaration& ld) override
	{
		std::cout << "Compiling ListDeclaration" << std::endl;
		compile(ld.contents);
		emit({ NLIST, ld.contents->expressions->size() });
	}

	void visit(ListAccess& la) override //TODO: Make ListAccess a type of SubVar
	{
		std::cout << "Compiling ListAccess" << std::endl;
		emit({ GETVAR, LOCAL, localvars[la.name] });
		compile(la.index);
		emit({ LISTGET });
	}

	void generate(Node* n)
	{
		compile(n);
		emit({ RETN });
	}
};