#include "stdafx.h"
#include "tokenizer.h"

Tokenizer::Tokenizer(std::string c)
{
	code = c;
	if(code.at(code.size()-1) != '\n')
	{
		code += '\n';
	}
}


Token Tokenizer::token(TokenType type, std::string value)
{
	Token t;
	t.type = type;
	t.value = value;
	t.line = line;
	t.column = column;
	return t;
}

void Tokenizer::emit(TokenType type, std::string value)
{
	result.push_back(token(type, value));
}

char Tokenizer::peek()
{
	if (offset >= code.size())
	{
		return 0;
	}
	return code[offset];
}

char Tokenizer::peek_next()
{
	if (offset+1 >= code.size())
	{
		return 0;
	}
	return code[offset + 1];
}

char Tokenizer::consume()
{
	if(offset >= code.size())
	{
		return 0;
	}
	column++;
	return code[offset++];
}

Token Tokenizer::skip_whitespace()
{
	while (isspace(peek()))
	{
		consume();
	}
	return next();
}

void Tokenizer::emit_indentation()
{
	int current_indent = 0;
	while (peek() == '\t')
	{
		current_indent++;
		consume();
	}
	int diff = current_indent - indent_level;
	if (diff > 0)
	{
		for (int _ = 0; _<diff; _++)
		{
			emit(TOKEN_INDENT, "INDENT");
		}
	}
	else if (diff < 0)
	{
		diff = -diff;
		for (int _ = 0; _<diff; _++)
		{
			emit(TOKEN_DEDENT, "DEDENT");
		}
	}
	indent_level = current_indent;
}

Token Tokenizer::skip()
{
	consume();
	return next();
}

void Tokenizer::error(std::string msg)
{
	std::istringstream codestream(code);
	size_t cur_line = 0;
	std::string linetext;
	while(cur_line < line)
	{
		cur_line++;
		std::getline(codestream, linetext);
	}
	throw TokenizerError(msg, linetext, line, column);
}

Token Tokenizer::read_integer()
{
	std::string start(1, consume());
	while (isdigit(peek()))
	{
		start += consume();
	}
	return token(TOKEN_INT, start);
}

Token Tokenizer::read_string()
{
	consume();
	std::string start(1, consume());
	while (peek() != '"')
	{
		if(peek() == '\n')
		{
			error("Unterminated string");
		}
		start += consume();
	}
	consume();
	return token(TOKEN_STRING, start);
}

Token Tokenizer::read_identifier()
{
	std::string start(1, consume());
	while (isalnum(peek()) || peek() == '_')
	{
		start += consume();
	}
	if (keywords.find(start) != keywords.end())
	{
		return token(keywords.at(start), start);
	}
	return token(TOKEN_IDENTIFIER, start);
}

Token Tokenizer::read_newline()
{
	consume();
	emit(TOKEN_NEWLINE, "EOL");
	emit_indentation();
	line++;
	column = 1;
	return next();
}

Token Tokenizer::read_other()
{
	const std::string ssingle(1, peek());
	const std::string sdouble = ssingle + peek_next();

	if(twochar_tokens.find(sdouble) != twochar_tokens.end())
	{
		consume();
		consume();
		return token(twochar_tokens.at(sdouble), sdouble);
	}

	if(singlechar_tokens.find(ssingle) != singlechar_tokens.end())
	{
		consume();
		return token(singlechar_tokens.at(ssingle), ssingle);
	}

	error("Unknown character: " + ssingle);
}

Token Tokenizer::next()
{
	const char current = peek();
	if(current == '\0')
	{
		return token(TOKEN_EOF, "EOF");
	}
	if(current == '\r')
	{
		return skip();
	}
	if(current == '"')
	{
		return read_string();
	}
	if(current == '\n')
	{
		return read_newline();
	}
	if(isspace(current))
	{
		return skip_whitespace();
	}
	if(isdigit(current))
	{
		return read_integer();
	}
	if(isalpha(current))
	{
		return read_identifier();
	}
	return read_other();
}

std::vector<Token> Tokenizer::tokenize()
{
	while(true)
	{
		Token t = next();
		result.push_back(t);
		if (t.type == TOKEN_EOF) return result;
	}
}
