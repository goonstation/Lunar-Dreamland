#pragma once

#include "tokens.h"
#include "nodes.h"
#include <sstream>

class ParserError : std::exception
{
public:
	std::string msg;
	ParserError(Token t, std::string message, std::string line)
	{
		msg = message;
		msg += "\n";
		msg += "At line " + std::to_string(t.line) + ":";
		msg += "\n\n";
		msg += "    " + line;
		msg += "\n";
		msg += std::string(t.column + 2, ' ') + '^';
		msg += "\n\n";

	}
	const char* what() const throw()
	{
		return msg.c_str();
	}
};

class Parser
{
public:
	std::string code;
	std::vector<Token> tokens;
	size_t offset = 0;
	bool eof_hit = false;
	Parser(std::string code, std::vector<Token> tokens);

	void error(Token t, std::string msg);

	TokenType peek();
	std::string vpeek();
	TokenType peek_next();

	Token consume();
	Token expect(TokenType t);
	Token expect(std::vector<TokenType> t);
	TokenType match(std::vector<TokenType> t);

	Block* parse_block();

	Node* parse_identifier();
	VariableDeclaration* parse_variable_declaration();
	VariableAccess* parse_identifier_expression();
	SubAccess* parse_subaccess();
	FunctionCall* parse_function_call_statement();
	FunctionCall* parse_function_call();
	ExpressionList* parse_expression_list();
	ListDeclaration* parse_list_declaration();
	ListAccess* parse_list_access();
	Output* parse_output();
	Return* parse_return();
	If* parse_if();

	Expression* expression();
	Expression* equality();
	Expression* comparison();
	Expression* addition();
	Expression* multiplication();
	Expression* unary();
	Expression* primary();
};