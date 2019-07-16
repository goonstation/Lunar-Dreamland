#pragma once

#include <vector>
#include <unordered_map>

enum TokenType
{
	TOKEN_PARSER_NO_MATCH, //used in matching

	TOKEN_INT,
	TOKEN_FLOAT,
	TOKEN_STRING,
	TOKEN_IDENTIFIER,

	TOKEN_PLUS,
	TOKEN_MINUS,
	TOKEN_STAR,
	TOKEN_SLASH,
	TOKEN_ASSIGN,
	TOKEN_EXCLAMATION,

	TOKEN_LEFT_PAREN,
	TOKEN_RIGHT_PAREN,
	TOKEN_LEFT_BRACKET,
	TOKEN_RIGHT_BRACKET,
	TOKEN_COMMA,
	TOKEN_DOT,

	TOKEN_LESS,
	TOKEN_GREATER,
	TOKEN_LESS_OR_EQUAL,
	TOKEN_GREATER_OR_EQUAL,
	TOKEN_EQUAL,
	TOKEN_NOT_EQUAL,

	TOKEN_SHIFT_LEFT,
	TOKEN_DOUBLEDOT,

	TOKEN_IF,
	TOKEN_ELSE,
	TOKEN_WHILE,
	TOKEN_FOR,
	TOKEN_RETURN,
	TOKEN_VAR,
	TOKEN_LIST,

	TOKEN_INDENT,
	TOKEN_DEDENT,
	TOKEN_NEWLINE,
	TOKEN_EOF,
};

const std::unordered_map<TokenType, std::string> token_names =
{
	{ TOKEN_IDENTIFIER,		"identifier" },
	{ TOKEN_LEFT_PAREN,		"opening parenthesis" },
	{ TOKEN_RIGHT_PAREN,	"closing parenthesis" },
	{ TOKEN_LEFT_BRACKET,	"opening bracket" },
	{ TOKEN_RIGHT_BRACKET,	"closing bracket" },
	{ TOKEN_ASSIGN,			"assignment" },
	{ TOKEN_INDENT,			"indented block" },
	{ TOKEN_NEWLINE,		"line end"},
};

const std::unordered_map<std::string, TokenType> singlechar_tokens =
{
	{ "+", TOKEN_PLUS},
	{ "-", TOKEN_MINUS },
	{ "*", TOKEN_STAR },
	{ "/", TOKEN_SLASH },
	{ "!", TOKEN_EXCLAMATION },
	{ "=", TOKEN_ASSIGN },

	{ "(", TOKEN_LEFT_PAREN },
	{ ")", TOKEN_RIGHT_PAREN },
	{ "[", TOKEN_LEFT_BRACKET },
	{ "]", TOKEN_RIGHT_BRACKET },
	{ ",", TOKEN_COMMA },
	{ ".", TOKEN_DOT },

	{ "<", TOKEN_LESS},
	{ ">", TOKEN_GREATER},
};

const std::unordered_map<std::string, TokenType> twochar_tokens =
{
	{ "==", TOKEN_EQUAL },
	{ "!=", TOKEN_NOT_EQUAL },
	{ ">=", TOKEN_GREATER_OR_EQUAL },
	{ "<=", TOKEN_LESS_OR_EQUAL },

	{ "<<", TOKEN_SHIFT_LEFT },
	{ "..", TOKEN_DOUBLEDOT },
};

const std::unordered_map<std::string, TokenType> keywords =
{
	{ "var",	TOKEN_VAR},
	{ "if",		TOKEN_IF },
	{ "else",	TOKEN_ELSE },

	{ "for",	TOKEN_FOR },
	{ "while",	TOKEN_WHILE },

	{"list",	TOKEN_LIST},
	{ "return", TOKEN_RETURN },
};

struct Token
{
	TokenType type;
	std::string value;
	unsigned int line;
	unsigned int column;
};