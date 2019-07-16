#pragma once
#include <locale>
#include <sstream>
#include "tokens.h"

class TokenizerError : std::exception
{
public:
	std::string msg;
	TokenizerError(std::string message, std::string line, size_t lineno, size_t column)
	{
		msg = message;
		msg += "\n";
		msg += "At line " + std::to_string(lineno) + ":";
		msg += "\n\n";
		msg += "    " + line;
		msg += "\n";
		msg += std::string(column + 3, ' ') + '^';
		msg += "\n\n";

	}
	const char* what() const throw()
	{
		return msg.c_str();
	}
};

class Tokenizer
{
public:
	std::string code;
	size_t offset = 0;
	size_t indent_level = 0;
	size_t line = 1;
	size_t column = 1;

	std::vector<Token> result;

	Tokenizer(std::string c);

	Token token(TokenType type, std::string valuie);
	void emit(TokenType type, std::string value);
	char peek();
	char peek_next();
	char consume();

	void error(std::string msg);

	Token skip_whitespace();
	void emit_indentation();
	Token skip();

	Token read_newline();
	Token read_integer();
	Token read_string();
	Token read_identifier();
	Token read_other();

	Token next();
	std::vector<Token> tokenize();
};