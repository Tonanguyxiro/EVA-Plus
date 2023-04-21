#include "eva/ir/constant_value.h"
#include "eva/ir/term.h"
#include "eva/serialization/eva.pb.h"
#include "program.h"

#include <cstdint>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

namespace eva {
/**
    Wrapper for EVA's native Term class. Provides operator overloads that
    create terms in the associated EvaProgram.

    Attributes
    ----------
    term
        The EVA native term
    program : eva.EVAProgram
        The program the wrapped term is in
    */

class Expr {
public:

    Expr(Term::Ptr term, Program &program)
        : term_(term), program_(program) {
    }

    Expr operator+(const Expr &other) {
        return Expr(program_.makeTerm(eva::Op::Add, {term_, other.term_}), program_);
    }

    Expr operator-(const Expr &other) {
        return Expr(program_.makeTerm(eva::Op::Sub, {term_, other.term_}), program_);
    }

    Expr operator*(const Expr &other) {
        return Expr(program_.makeTerm(eva::Op::Mul, {term_, other.term_}), program_);
    }

    Expr operator<<(int rotation) {
        return Expr(program_.makeLeftRotation(term_, rotation), program_);
    }

    Expr operator>>(int rotation) {
        return Expr(program_.makeRightRotation(term_, rotation), program_);
    }

    Expr operator-() {
        return Expr(program_.makeTerm(eva::Op::Negate, {term_}), program_);
    }

    Expr pow(int exponent) {
        if (exponent < 1) {
            throw std::invalid_argument("exponent must be greater than zero, got " + std::to_string(exponent));
        }
        auto result = term_;
        for (int i = 0; i < exponent - 1; ++i) {
            result = program_.makeTerm(eva::Op::Mul, {result, term_});
        }
        return Expr(result, program_);
    }

    Expr log() {

    }

    Expr reciprocal() {

    }
    
    Term::Ptr term_;
    Program &program_;

};

} // namespace eva

/*




*/