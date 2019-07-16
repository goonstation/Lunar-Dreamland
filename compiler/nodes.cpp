#include "stdafx.h"
#include "nodes.h"
void Block::accept(Visitor& v) { v.visit(*this); }
void ExpressionList::accept(Visitor& v) { v.visit(*this); }
void FunctionCall::accept(Visitor& v) { v.visit(*this); }
void ListDeclaration::accept(Visitor& v) { v.visit(*this); }
void Group::accept(Visitor& v) { v.visit(*this); }
void ListAccess::accept(Visitor& v) { v.visit(*this); }
void VariableAccess::accept(Visitor& v) { v.visit(*this); }
void Integer::accept(Visitor& v) { v.visit(*this); }
void Float::accept(Visitor& v) { v.visit(*this); }
void String::accept(Visitor& v) { v.visit(*this); }
void ArithmeticNegation::accept(Visitor& v) { v.visit(*this); }
void LogicalNegation::accept(Visitor& v) { v.visit(*this); }
void Addition::accept(Visitor& v) { v.visit(*this); }
void Subtraction::accept(Visitor& v) { v.visit(*this); }
void Division::accept(Visitor& v) { v.visit(*this); }
void Multiplication::accept(Visitor& v) { v.visit(*this); }
void Equal::accept(Visitor& v) { v.visit(*this); }
void NotEqual::accept(Visitor& v) { v.visit(*this); }
void LessThan::accept(Visitor& v) { v.visit(*this); }
void GreaterThan::accept(Visitor& v) { v.visit(*this); }
void LessOrEqual::accept(Visitor& v) { v.visit(*this); }
void GreaterOrEqual::accept(Visitor& v) { v.visit(*this); }
void VariableDeclaration::accept(Visitor& v) { v.visit(*this); }
void If::accept(Visitor& v) { v.visit(*this); }
void Return::accept(Visitor& v) { v.visit(*this); }
void Output::accept(Visitor& v) { v.visit(*this); }

