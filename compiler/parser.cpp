#include "stdafx.h"
#include "parser.h"
#include <iostream>

std::string convert_type_list(std::vector<TokenType> t)
{
	std::string res;
	for (TokenType& tt : t)
	{
		std::string name = std::to_string(tt);
		if (token_names.find(tt) != token_names.end())
		{
			name = token_names.at(tt);
		}
		res += name + ", ";
	}
	res.pop_back();
	res.pop_back();
	return res;
}

Parser::Parser(std::string code, std::vector<Token> tokens)
{
	this->code = code;
	this->tokens = tokens;
}

TokenType Parser::peek()
{
	return tokens[offset].type;
}

std::string Parser::vpeek()
{
	return tokens[offset].value;
}

TokenType Parser::peek_next()
{
	return tokens[offset + 1].type;
}

Token Parser::consume()
{
	if (peek() == TOKEN_EOF)
	{
		return tokens[offset];
	}
	return tokens[offset++];
}

void Parser::error(Token t, std::string msg)
{
	std::istringstream codestream(code);
	size_t cur_line = 0;
	std::string linetext;
	while (cur_line < t.line)
	{
		cur_line++;
		std::getline(codestream, linetext);
	}
	throw ParserError(t, msg, linetext);
}

Token Parser::expect(TokenType t)
{
	Token consumed = consume();
	if (consumed.type != t)
	{
		std::string got_name = std::to_string(consumed.type);
		std::string expected_name = std::to_string(t);
		if(token_names.find(t) != token_names.end())
		{
			expected_name = token_names.at(t);
		}
		if (token_names.find(consumed.type) != token_names.end())
		{
			got_name = token_names.at(consumed.type);
		}
		error(consumed, "Expected: " + expected_name + "\nGot: " + got_name);
	}
	return consumed;
}

Token Parser::expect(std::vector<TokenType> t)
{
	Token consumed = consume();
	if (std::find(t.begin(), t.end(), consumed.type) == t.end())
	{
		std::string got_name = std::to_string(consumed.type);
		if (token_names.find(consumed.type) != token_names.end())
		{
			got_name = token_names.at(consumed.type);
		}
		error(consumed, "Expected one of: " + convert_type_list(t) + "\nGot: " + got_name);
	}
	return consumed;
}

TokenType Parser::match(std::vector<TokenType> t)
{
	TokenType current = peek();
	if (std::find(t.begin(), t.end(), current) == t.end())
	{
		return TOKEN_PARSER_NO_MATCH;
	}
	return current;
}


Block* Parser::parse_block()
{
	Block* stmts = new Block();

	while (peek() != TOKEN_EOF && peek() != TOKEN_DEDENT)
	{
		switch (peek())
		{
		case TOKEN_IDENTIFIER:
			stmts->stmt_list.push_back(parse_identifier());
			break;
		case TOKEN_VAR:
			stmts->stmt_list.push_back(parse_variable_declaration());
			break;
		case TOKEN_RETURN:
			stmts->stmt_list.push_back(parse_return());
			break;
		case TOKEN_IF:
			stmts->stmt_list.push_back(parse_if());
			break;
		case TOKEN_NEWLINE:
			consume();
			break;
		default:
			error(consume(), "Unexpected token");
		}
	}
	return stmts;
}

Return* Parser::parse_return()
{
	expect(TOKEN_RETURN);
	if(peek() == TOKEN_NEWLINE)
	{
		return new Return();
	}
	return new Return(expression());
}

If* Parser::parse_if()
{
	expect(TOKEN_IF);
	expect(TOKEN_LEFT_PAREN);
	Expression* cond = expression();
	expect(TOKEN_RIGHT_PAREN);
	expect(TOKEN_NEWLINE);
	expect(TOKEN_INDENT);
	Block* if_body = parse_block();
	expect(TOKEN_DEDENT);
	Block* else_body = nullptr;
	if (peek() == TOKEN_ELSE)
	{
		consume();
		expect(TOKEN_NEWLINE);
		expect(TOKEN_INDENT);
		else_body = parse_block();
		expect(TOKEN_DEDENT);
	}
	return new If(cond, if_body, else_body);
}

Node* Parser::parse_identifier()
{
	std::cout << "Parsing identifier" << std::endl;
	std::cout << vpeek() << std::endl;
	switch(peek_next())
	{
	case TOKEN_SHIFT_LEFT:
		return parse_output();
	case TOKEN_LEFT_PAREN:
		return parse_function_call_statement();
	}
}

Output* Parser::parse_output()
{
	std::string var_name = consume().value;
	expect(TOKEN_SHIFT_LEFT);
	return new Output(new VariableAccess(var_name, parse_subaccess()), expression());
}

VariableDeclaration* Parser::parse_variable_declaration()
{
	expect(TOKEN_VAR);
	expect(TOKEN_SLASH);
	bool is_list = false;
	std::string name = expect({ TOKEN_IDENTIFIER, TOKEN_LIST }).value;
	if(name == "list")
	{
		is_list = true;
		expect(TOKEN_SLASH);
		name = expect(TOKEN_IDENTIFIER).value;
	}
	Expression* init = nullptr;
	if(peek() == TOKEN_ASSIGN)
	{
		consume();
		init = expression();
	}
	return new VariableDeclaration(name, init, is_list);
}

Expression* Parser::expression()
{
	return equality();
}

Expression* Parser::equality() {
	Expression* expr = comparison();

	while (match({ TOKEN_EQUAL, TOKEN_NOT_EQUAL })) {
		Token op = consume();
		Expression* right = comparison();
		if (op.type == TOKEN_EQUAL)
			expr = new Equal(expr, right);
		else
			expr = new NotEqual(expr, right);
	}

	return expr;
}

Expression* Parser::comparison() {
	return addition();
}

Expression* Parser::addition() {
	Expression* expr = multiplication();

	while (match({ TOKEN_PLUS, TOKEN_MINUS })) {
		Token op = consume();
		Expression* right = multiplication();
		if (op.type == TOKEN_PLUS)
			expr = new Addition(expr, right);
		else if (op.type == TOKEN_MINUS)
			expr = new Subtraction(expr, right);
	}

	return expr;
}

Expression* Parser::multiplication() {
	Expression* expr = unary();

	while (match({ TOKEN_STAR, TOKEN_SLASH })) {
		Token op = consume();
		Expression* right = unary();
		if (op.type == TOKEN_STAR)
			expr = new Multiplication(expr, right);
		else if (op.type == TOKEN_SLASH)
			expr = new Division(expr, right);
	}

	return expr;
}

Expression* Parser::unary() {
	switch(match({TOKEN_MINUS, TOKEN_EXCLAMATION}))
	{
	case TOKEN_MINUS:
		consume();
		return new ArithmeticNegation(unary());
	case TOKEN_EXCLAMATION:
		consume();
		return new LogicalNegation(unary());
	}
	return primary();
}

Expression* Parser::primary()
{
	switch (peek())
	{
	case TOKEN_INT:
		return new Integer(consume().value);
	case TOKEN_STRING:
		return new String(consume().value);
	case TOKEN_LEFT_PAREN:
	{
		consume();
		Expression* expr = expression();
		expect(TOKEN_RIGHT_PAREN);
		return new Group(expr);
	}
	case TOKEN_IDENTIFIER:
	{
		switch (peek_next())
		{
		case TOKEN_LEFT_PAREN:
			return parse_function_call();
		case TOKEN_LEFT_BRACKET:
			return parse_list_access();
		default:
			return parse_identifier_expression();
		}
	}
	case TOKEN_LIST:
		return parse_list_declaration();
	default:
		error(consume(), "Malformed expression");
	}
}

ListAccess* Parser::parse_list_access()
{
	std::string name = consume().value;
	expect(TOKEN_LEFT_BRACKET);
	Expression* idx = expression();
	expect(TOKEN_RIGHT_BRACKET);
	return new ListAccess(name, idx, parse_subaccess());
}

VariableAccess* Parser::parse_identifier_expression()
{
	std::string name = consume().value;
	return new VariableAccess(name, parse_subaccess());
}

ListDeclaration* Parser::parse_list_declaration()
{
	expect(TOKEN_LIST);
	return new ListDeclaration(parse_expression_list());
}

SubAccess* Parser::parse_subaccess()
{
	switch (peek())
	{
	case TOKEN_DOT:
	{
		consume();
		std::string subname = expect(TOKEN_IDENTIFIER).value;
		return new SubAccess(subname, parse_subaccess());
	}
	case TOKEN_LEFT_PAREN:
		error(consume(), "Subcall not implemented.");
		break;
	default:
		return nullptr;
	}
}

FunctionCall* Parser::parse_function_call_statement()
{
	FunctionCall* fc = parse_function_call();
	expect(TOKEN_NEWLINE);
	return fc;
}

FunctionCall* Parser::parse_function_call()
{
	const std::string name = expect(TOKEN_IDENTIFIER).value;
	return new FunctionCall(name, parse_expression_list());
}

ExpressionList* Parser::parse_expression_list()
{
	std::vector<Expression*> exprs;
	expect(TOKEN_LEFT_PAREN);
	if (peek() == TOKEN_RIGHT_PAREN)
	{
		consume();
		return new ExpressionList();
	}
	exprs.push_back(expression());
	while (peek() == TOKEN_COMMA) {
		consume();
		exprs.push_back(expression());
	}
	expect(TOKEN_RIGHT_PAREN);
	return new ExpressionList(exprs);
}