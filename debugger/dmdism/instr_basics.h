#pragma once

#include "instruction.h"
#include "disassembler.h"


ADD_INSTR_ARG(NEW, 1)
ADD_INSTR(OUTPUT)
ADD_INSTR(TEST)
ADD_INSTR_ARG(NLIST, 1)
ADD_INSTR_VAR(GETVAR)
ADD_INSTR_VAR(SETVAR)
ADD_INSTR_ARG(PUSHI, 1)
ADD_INSTR(POP)
ADD_INSTR_ARG(ITERLOAD, 2)
ADD_INSTR(ITERNEXT)
ADD_INSTR_CUSTOM(PUSHVAL)
ADD_INSTR(LISTGET)
ADD_INSTR_ARG(POPN, 1)
ADD_INSTR(CHECKNUM)
ADD_INSTR_ARG(FOR_RANGE, 2)
