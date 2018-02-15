! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, and Cat Stevens.
USING: arrays combinators.short-circuit grouping kernel math math.matrices math.matrices.private
math.statistics math.vectors sequences sequences.deep sets tools.test ;
IN: math.matrices.tests

: call-eq? ( obj quots -- ? )
    [ call( x -- x ) ] with map all-eq? ; !  inline

! ------------------------
! predicates

{ t } [ { }                 well-formed-matrix? ] unit-test
{ t } [ { { } }             well-formed-matrix? ] unit-test
{ t } [ { { 1 2 } }         well-formed-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } well-formed-matrix? ] unit-test
{ t } [ { { 1 } { 3 } }     well-formed-matrix? ] unit-test
{ f } [ { { 1 2 } { 3 } }   well-formed-matrix? ] unit-test
{ f } [ { { 1 } { 3 2 } }   well-formed-matrix? ] unit-test


{ t } [ { } square-matrix? ] unit-test
{ t } [ { { 1 } } square-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } square-matrix? ] unit-test
{ f } [ { { 1 } { 2 3 } } square-matrix? ] unit-test
{ f } [ { { 1 2 } } square-matrix? ] unit-test

! any deep-empty matrix is null
! it doesn't make any sense for { } to be null while { { } } to be considered nonnull
{ t } [ {
    { }
    { { } }
    { { { } } }
    { { } { } { } }
    { { { } } { { { } } } }
} [ null-matrix? ] map [ ] all?
] unit-test

{ f } [ {
    { 1 2 }
    { { 1 2 } }
    { { 1 } { 2 } }
    { { { 1 } } { 2 } { } }
} [ null-matrix? ] map [ ] any?
] unit-test

{ t } [ 10 dup <zero-matrix> zero-matrix? ] unit-test
{ t } [ 10 10 15 <simple-eye> zero-matrix? ] unit-test
{ t } [ 0 dup <zero-matrix> null-matrix? ] unit-test
{ f } [ 0 dup <zero-matrix> zero-matrix? ] unit-test
{ f } [ 4 <identity-matrix> zero-matrix? ] unit-test
{ f } [ 4 <box-matrix> zero-matrix? ] unit-test
! make sure we're not using the sum-to-zero strategy
{ f } [ { { 0 -2 } { 1 -1 } } zero-matrix? ] unit-test

{ 3 } [ { 1 2 3 } 0 swap nth-end ] unit-test
{ 2 } [ { 1 2 3 } 1 swap nth-end ] unit-test
{ 1 } [ { 1 2 3 } 2 swap nth-end ] unit-test

[ { 1 2 3 } -1 swap nth-end ] [ bounds-error? ] must-fail-with
[ { 1 2 3 } 3 swap nth-end ] [ bounds-error? ] must-fail-with
[ { 1 2 3 } 4 swap nth-end ] [ bounds-error? ] must-fail-with

{ { 0 0 1 } } [ { 0 0 0 } dup 1 0 rot set-nth-end ] unit-test
{ { 0 2 0 } } [ { 0 0 0 } dup 2 1 rot set-nth-end ] unit-test
{ { 3 0 0 } } [ { 0 0 0 } dup 3 2 rot set-nth-end ] unit-test

[ { 0 0 0 } dup 1 -1 rot set-nth-end ] [ bounds-error? ] must-fail-with
[ { 0 0 0 } dup 2 3 rot set-nth-end ] [ bounds-error? ] must-fail-with
[ { 0 0 0 } dup 3 4 rot set-nth-end ] [ bounds-error? ] must-fail-with

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 5 <matrix> ] unit-test
! a matrix-matrix
{ { {
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
} {
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
    { { -1 -1 } { -1 -1 } }
} } } [ 2 3 2 2 -1 <matrix> <matrix> ] unit-test

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 [ 5 ] <matrix-by> ] unit-test
{ {
    { 6 6 }
    { 6 6 }
} } [ 2 2 [ 3 2 * ] <matrix-by> ] unit-test

{ {
    { 0 1 2 }
    { 1 2 3 }
} } [ 2 3 [ + ] <matrix-by-indices> ] unit-test
{ {
    { 0 0 0 }
    { 0 1 2 }
    { 0 2 4 }
} } [ 3 3 [ * ] <matrix-by-indices> ] unit-test

{ t } [ 3 3 <zero-matrix> zero-square-matrix? ] unit-test
{ t } [ 3 <zero-square-matrix> zero-square-matrix? ] unit-test
{ t f } [ 3 1 <zero-matrix> [ zero-matrix? ] [ square-matrix? ] bi ] unit-test

{ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} } [
    { 1 2 3 } <diagonal-matrix>
] unit-test

{ {
    { -11 0 0 0 }
    { 0 -12 0 0 }
    { 0 0 -33 0 }
    { 0 0 0 -14 }
} } [ { -11 -12 -33 -14 } <diagonal-matrix> ] unit-test

{ {
    { 0 0 1 }
    { 0 2 0 }
    { 3 0 0 }
} } [ { 1 2 3 } <anti-diagonal-matrix> ] unit-test

{ {
    { 0 0 0 -11 }
    { 0 0 -12 0 }
    { 0 -33 0 0 }
    { -14 0 0 0 }
} } [ { -11 -12 -33 -14 } <anti-diagonal-matrix> ] unit-test

{ {
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    3 <identity-matrix>
] unit-test

{ {
    { 0 1 }
    { 0 1 }
} } [ 2 <square-rows> ] unit-test

{ {
    { 0 0 }
    { 1 1 }
} } [ 2 <square-cols> ] unit-test

{ {
    { 5 6 }
    { 5 6 }
} } [ { 5 6 } <square-rows> ] unit-test

{ {
    { 5 5 }
    { 6 6 }
} } [ { 5 6 } <square-cols> ] unit-test

{  {
    { 1 }
} } [ {
    { 1 2 }
} <square-rows> ] unit-test

{  {
    { 1 2 }
    { 3 4 }
} } [ {
    { 1 2 5 }
    { 3 4 6 }
} <square-rows> ] unit-test

{  {
    { 1 2 }
    { 3 4 }
} } [ {
    { 1 2 }
    { 3 4 }
    { 5 6 }
} <square-rows> ] unit-test

{ {
    { 2 0 0 }
    { 0 2 0 }
    { 0 0 2 }
} } [
    3 3 0 2 <eye>
] unit-test

{ {
    { 0 2 0 }
    { 0 0 2 }
    { 0 0 0 }
} } [
    3 3 1 2 <eye>
] unit-test

{ {
    { 0 0 0 0 }
    { 2 0 0 0 }
    { 0 2 0 0 }
} } [
    3 4 -1 2 <eye>
] unit-test


{ {
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    3 3 0 <simple-eye>
] unit-test

{ {
    { 0 1 0 }
    { 0 0 1 }
    { 0 0 0 }
} } [
    3 3 1 <simple-eye>
] unit-test

{ {
    { 0 0 0 }
    { 1 0 0 }
    { 0 1 0 }
} } [
    3 3 -1 <simple-eye>
] unit-test

{ {
    { 1 0 0 0 }
    { 0 1 0 0 }
    { 0 0 1 0 }
} } [
    3 4 0 <simple-eye>
] unit-test

{ {
    { 0 1 0 }
    { 0 0 1 }
    { 0 0 0 }
    { 0 0 0 }
} } [
    4 3 1 <simple-eye>
] unit-test

{ {
    { 0 0 0 }
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    4 3 -1 <simple-eye>
] unit-test

{ {
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
    { { 3 0 } { 3 1 } { 3 2 } }
} } [ { 4 3 } <coordinate-matrix> ] unit-test

{ {
    { 1   1/2 1/3 1/4 }
    { 1/2 1/3 1/4 1/5 }
    { 1/3 1/4 1/5 1/6 }
} } [ 3 4 <hilbert-matrix> ] unit-test

{ {
    { 1 2 3 4 }
    { 2 1 2 3 }
    { 3 2 1 2 }
    { 4 3 2 1 }
} } [ 4 <toeplitz-matrix> ] unit-test

{ {
    { 1 2 3 4 }
    { 2 3 4 0 }
    { 3 4 0 0 }
    { 4 0 0 0 } }
} [ 4 <hankel-matrix> ] unit-test

{ {
    { 1 1 1 }
    { 4 2 1 }
    { 9 3 1 }
    { 25 5 1 } }
} [
    { 1 2 3 5 } 3 <vandermonde-matrix>
] unit-test

{ {
    { 1 0 4 }
    { 0 7 0 }
    { 6 0 3 } }
} [ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} {
    { 0 0 4 }
    { 0 5 0 }
    { 6 0 0 }
}
    m+
] unit-test

{ {
    { 1 0 4 }
    { 0 7 0 }
    { 6 0 3 }
} } [ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} {
    { 0 0 -4 }
    { 0 -5 0 }
    { -6 0 0 }
}
    m-
] unit-test

{ { 3 4 } } [ { { 1 0 } { 0 1 } } { 3 4 } mdotv ] unit-test
{ { 4 3 } } [ { { 0 1 } { 1 0 } } { 3 4 } mdotv ] unit-test

{ { { 6 } } } [ { { 3 } } { { 2 } } mdot ] unit-test
{ { { 11 } } } [ { { 1 3 } } { { 5 } { 2 } } mdot ] unit-test

{ { { 28 } } } [
    { { 2 4 6 } }
    { { 1 } { 2 } { 3 } }
    mdot
] unit-test

{ {
    { 4181 6765 }
    { 6765 10946 }
} } [
  { { 0 1 } { 1 1 } } 20 m^n
] unit-test

[ { { 0 1 } { 1 1 } } -20 m^n ] [ negative-power-matrix? ] must-fail-with
[ { { 0 1 } { 1 1 } } -8 m^n ] [ negative-power-matrix? ] must-fail-with

{ {
    { 0 5 0 10 }
    { 6 7 12 14 }
    { 0 15 0 20 }
    { 18 21 24 28 }
} } [ {
    { 1 2 }
    { 3 4 }
} {
    { 0 5 }
    { 6 7 }
} kronecker-product ] unit-test

{ {
    { 1  1  1  1 }
    { 1 -1  1 -1 }
    { 1  1 -1 -1 }
    { 1 -1 -1  1 }
} } [ {
    { 1  1 }
    { 1 -1 }
} dup kronecker-product ] unit-test

{ {
    { 1 1 1 1 1 1 1 1 }
    { 1 -1 1 -1 1 -1 1 -1 }
    { 1 1 -1 -1 1 1 -1 -1 }
    { 1 -1 -1 1 1 -1 -1 1 }
    { 1 1 1 1 -1 -1 -1 -1 }
    { 1 -1 1 -1 -1 1 -1 1 }
    { 1 1 -1 -1 -1 -1 1 1 }
    { 1 -1 -1 1 -1 1 1 -1 }
} } [ {
    { 1 1 }
    { 1 -1 }
} dup dup kronecker-product kronecker-product ] unit-test

{ {
    { 1 1 1 1 1 1 1 1 }
    { 1 -1 1 -1 1 -1 1 -1 }
    { 1 1 -1 -1 1 1 -1 -1 }
    { 1 -1 -1 1 1 -1 -1 1 }
    { 1 1 1 1 -1 -1 -1 -1 }
    { 1 -1 1 -1 -1 1 -1 1 }
    { 1 1 -1 -1 -1 -1 1 1 }
    { 1 -1 -1 1 -1 1 1 -1 }
} } [ {
    { 1 1 }
    { 1 -1 }
} dup dup kronecker-product swap kronecker-product ] unit-test


! kronecker-product is not generally commutative, make sure we have the right order
{ {
    { 1 2 3 4 5 1 2 3 4 5 }
    { 6 7 8 9 10 6 7 8 9 10 }
    { 1 2 3 4 5 -1 -2 -3 -4 -5 }
    { 6 7 8 9 10 -6 -7 -8 -9 -10 }
} } [ {
    { 1 1 }
    { 1 -1 }
} {
    { 1 2 3 4 5 }
    { 6 7 8 9 10 }
} kronecker-product ] unit-test

{ {
    { 1 1 2 2 3 3 4 4 5 5 }
    { 1 -1 2 -2 3 -3 4 -4 5 -5 }
    { 6 6 7 7 8 8 9 9 10 10 }
    { 6 -6 7 -7 8 -8 9 -9 10 -10 }
} } [ {
    { 1 1 }
    { 1 -1 }
} {
    { 1 2 3 4 5 }
    { 6 7 8 9 10 }
} swap kronecker-product ] unit-test

{ {
    { 5 10 15 }
    { 6 12 18 }
    { 7 14 21 }
} } [
    { 5 6 7 }
    { 1 2 3 }
    outer-product
] unit-test


CONSTANT: test-points {
    { 80  27  89 } { 80  27  88 } { 75  25  90 }
    { 62  24  87 } { 62  22  87 } { 62  23  87 }
    { 62  24  93 } { 62  24  93 } { 58  23  87 }
    { 58  18  80 } { 58  18  89 } { 58  17  88 }
    { 58  18  82 } { 58  19  93 } { 50  18  89 }
    { 50  18  86 } { 50  19  72 } { 50  19  79 }
    { 50  20  80 } { 56  20  82 } { 70  20  91 }
}

{ {
    { 84+2/35 22+23/35 24+4/7 }
    { 22+23/35 9+104/105 6+87/140 }
    { 24+4/7 6+87/140 28+5/7 }
} } [ test-points sample-covariance-matrix ] unit-test

{ {
    { 80+8/147 21+85/147 23+59/147 }
    { 21+85/147 9+227/441 6+15/49 }
    { 23+59/147 6+15/49 27+17/49 }
} } [ test-points covariance-matrix ] unit-test

! TODO: note: merge conflict from HEAD contained the following
! ------------------------
! predicates

{ t } [ { } square-matrix? ] unit-test
{ t } [ { { 1 } } square-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } square-matrix? ] unit-test
{ f } [ { { 1 } { 2 3 } } square-matrix? ] unit-test
{ f } [ { { 1 2 } } square-matrix? ] unit-test

{ 9 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } m-1norm ] unit-test

{ 8 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } m-infinity-norm ] unit-test

{ 2.0 }
[ { { 1 1 } { 1 1 } } frobenius-norm ] unit-test
! from "intermediate commit"
! any deep-empty matrix is null
! it doesn't make any sense for { } to be null while { { } } to be considered nonnull
{ t } [ {
    { }
    { { } }
    { { { } } }
    { { } { } { } }
    { { { } } { { { } } } }
} [ null-matrix? ] map [ ] all?
] unit-test

{ f } [ {
    { 1 2 }
    { { 1 2 } }
    { { 1 } { 2 } }
    { { { 1 } } { 2 } { } }
} [ null-matrix? ] map [ ] any?
] unit-test

{ t } [ 10 dup <zero-matrix> zero-matrix? ] unit-test
{ t } [ 10 10 15 <simple-eye> zero-matrix? ] unit-test
{ t } [ 0 dup <zero-matrix> null-matrix? ] unit-test
{ f } [ 0 dup <zero-matrix> zero-matrix? ] unit-test
{ f } [ 4 <identity-matrix> zero-matrix? ] unit-test
{ f } [ 4 <box-matrix> zero-matrix? ] unit-test

{ t } [ { }                 well-formed-matrix? ] unit-test
{ t } [ { { } }             well-formed-matrix? ] unit-test
{ t } [ { { 1 2 } }         well-formed-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } well-formed-matrix? ] unit-test
{ t } [ { { 1 } { 3 } }     well-formed-matrix? ] unit-test
{ f } [ { { 1 2 } { 3 } }   well-formed-matrix? ] unit-test
{ f } [ { { 1 } { 3 2 } }   well-formed-matrix? ] unit-test
! TODO: note: lines since last HEAD comment were deleted in "fix more code and add more rigorous tests"

! diagonals

{ { 1 1 1 1 } } [ 4 <identity-matrix> main-diagonal ] unit-test
{ { 0 0 0 0 } } [ 4 <identity-matrix> anti-diagonal ] unit-test
{ { 4 8 } } [ { { 4 6 } { 3 8 } } main-diagonal ] unit-test
{ { 6 3 } } [ { { 4 6 } { 3 8 } } anti-diagonal ] unit-test
{ { 1 2 3 } } [ { { 0 0 1 } { 0 2 0 } { 3 0 0 } } anti-diagonal ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> main-diagonal ] unit-test

! transposition
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> transpose main-diagonal ] unit-test
{ t } [ 50 <box-matrix> dup transpose = ] unit-test
{ t } [ 50 <identity-matrix> dup transpose = ] unit-test
{ { 4 3 2 1 } } [ { 1 2 3 4 } <anti-diagonal-matrix> transpose anti-diagonal ] unit-test

! anti transposition
{ { 1 2 3 4 } } [ { 1 2 3 4 } <anti-diagonal-matrix> anti-transpose anti-diagonal ] unit-test
{ t } [ 50 <box-matrix> dup                  anti-transpose = ] unit-test
{ t } [ 50 <iota> <anti-diagonal-matrix> dup anti-transpose = ] unit-test
{ { 4 3 2 1 } } [ { 1 2 3 4 } <diagonal-matrix> anti-transpose main-diagonal ] unit-test

SYMBOLS: A B C D E F G H I J K L M N O P ;
{ { {
    { E F G H }
    { I J K L }
    { M N O P }
} {
    { A B C D }
    { I J K L }
    { M N O P }
} {
    { A B C D }
    { E F G H }
    { M N O P }
} {
    { A B C D }
    { E F G H }
    { I J K L }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ rows-except ] map-index
] unit-test

{ { { 2 } } } [ { { 1 } { 2 } } 0 rows-except ] unit-test
{ { { 1 } } } [ { { 1 } { 2 } } 1 rows-except ] unit-test
{ { } } [ { { 1 } }       0 rows-except ] unit-test
{ { { 1 } } } [ { { 1 } } 1 rows-except ] unit-test

{ { {
    { B C D }
    { F G H }
    { J K L }
    { N O P }
} {
    { A C D }
    { E G H }
    { I K L }
    { M O P }
} {
    { A B D }
    { E F H }
    { I J L }
    { M N P }
} {
    { A B C }
    { E F G }
    { I J K }
    { M N O }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ cols-except ] map-index
] unit-test

{ { } } [ { { 1 } { 2 } } 0 cols-except ] unit-test
{ { { 1 } { 2 } } } [ { { 1 } { 2 } } 1 cols-except ] unit-test
{ { } } [ { { 1 } }       0 cols-except ] unit-test
{ { { 1 } } } [ { { 1 } } 1 cols-except ] unit-test
{ { { 2 } { 4 } } } [ { { 1 2 } { 3 4 } } 0 cols-except ] unit-test
{ { { 1 } { 3 } } } [ { { 1 2 } { 3 4 } } 1 cols-except ] unit-test

{ { {
    { F G H }
    { J K L }
    { N O P }
} {
    { A C D }
    { I K L }
    { M O P }
} {
    { A B D }
    { E F H }
    { M N P }
} {
    { A B C }
    { E F G }
    { I J K }
} } } [
    4 {
        { A B C D }
        { E F G H }
        { I J K L }
        { M N O P }
    } <repetition>
    [ dup 2array matrix-except ] map-index
] unit-test

! prepare for bracket hell
! going to test the Matrix of Minors permutation strategy

! going to test 1x2 inputs
! the input had 2 elements, the output has 2 0-matrices across 2 arrays ;)
{ { { { } { } } } } [ { { 1 2 } } matrix-except-all ] unit-test

! any matrix with a 1 in its dimensions will give a void matrix output
{ t } [ { { 1 2 } }     matrix-except-all null-matrix? ] unit-test
{ t } [ { { 1 } { 2 } } matrix-except-all null-matrix? ] unit-test

! going to test 2x2 inputs
! these 1x1 output matrices have omitted a row and column from the 2x2 input

! the input had 4 elements, the output has 4 1-matrices across 2 arrays
! the permutations of indices 0 1 are: 0 0, 0 1, 1 0, 1 1
{
    { ! output array
        { ! item #1: excluding row 0...
            { { 3 } } ! and col 0 = 0 0
            { { 2 } } ! and col 1 = 0 1
        }
        { ! item #2: excluding row 1...
            { { 1 } } ! and col 0 = 1 0
            { { 0 } } ! and col 1 = 1 1
        }
    }
} [
    ! the input to the function is a simple 2x2
    { { 0 1 } { 2 3 } } matrix-except-all
] unit-test

! we are going to ensure that "duplicate" matrices are not omitted in the output
{
    {
        { ! item 1
            { { 0 } }
            { { 0 } }
        }
        { ! item 2
            { { 0 } }
            { { 0 } }
        }
    }
} [ { { 0 0 } { 0 0 } } matrix-except-all ] unit-test
! the output only has elements from the input
{ t } [ 44 <zero-square-matrix> matrix-except-all zero-matrix? ] unit-test

! going to test 2x3 and 3x2 inputs
{
    { ! output array
        { ! excluding row 0
            { { 2 } { 3 } } ! and col 0
            { { 1 } { 2 } } ! and col 1
        }
        { ! excluding row 1
            { { 1 } { 3 } } ! and col 0
            { { 0 } { 2 } } ! and col 1
        }
        { ! excluding row 2
            { { 1 } { 2 } } ! col 0
            { { 0 } { 1 } } ! col 1
        }
    }
} [ {
    { 0 1 }
    { 1 2 }
    { 2 3 }
} matrix-except-all ] unit-test

{
    { ! output array
        { ! excluding row 0
            { { 2 3 } } ! col 0
            { { 1 3 } } ! col 1
            { { 1 2 } } ! col 2
        }
        { ! row 1
            { { 1 2 } } ! col 0
            { { 0 2 } } ! col 1
            { { 0 1 } } ! col 2
        }
    }
} [ {
    { 0 1 2 }
    { 1 2 3 }
} matrix-except-all ] unit-test

! going to test 3x3 inputs

! the input had 9 elements, the output has 9 2-matrices across 3 arrays
! every element from the input is represented 4 times in the output
! the number of copies of each element found in the output is the side length of the next smaller square matrix
! 3x3 input gives 4 copies of each element; (N-1) ^ 2 = 4 where N=3
! the permutations of indices 0 1 2 are: 0 0, 0 1, 0 2; 1 0, 1 1, 1 2; 2 0, 2 1, 2 2
{
    { ! output array
        { ! item #1: excluding row 0...
            { ! and col 0 = 0 0
                { 4 5 }
                { 7 8 }
            }
            { ! and col 1 = 0 1
                { 3 5 }
                { 6 8 }
            }
            { ! and col 2 = 0 2
                { 3 4 }
                { 6 7 }
            }
        }

        { ! item #2: excluding row 1...
            { ! and col 0 = 1 0
                { 1 2 }
                { 7 8 }
            }
            { ! and col 1 = 1 1
                { 0 2 }
                { 6 8 }
            }
            { ! and col 2 = 1 2
                { 0 1 }
                { 6 7 }
            }
        }

        { ! item #2: excluding row 2...
            { ! and col 0 = 2 0
                { 1 2 }
                { 4 5 }
            }
            { ! and col 1 = 2 1
                { 0 2 }
                { 3 5 }
            }
            { ! and col 2 = 2 2
                { 0 1 }
                { 3 4 }
            }
        }
    }
    t ! note this
} [ {
    { 0 1 2 }
    { 3 4 5 }
    { 6 7 8 }
} matrix-except-all dup flatten sorted-histogram [ second ] map
    { [ length 9 = ] [ [ 4 = ] all? ] }
    1&&
] unit-test

! going to test 4x4 inputs

! don't feel like handwriting this right now, so a sanity check test instead
! the input contains 4 rows and 4 columns for 16 elements
! 4x4 input gives 9 copies of each element; (N-1) ^ 2 = 9 where N = 4
{ t } [ {
    { 0 1 2 3 }
    { 4 5 6 7 }
    { 8 9 10 11 }
    { 12 13 14 15 }
} matrix-except-all flatten sorted-histogram [ second ] map
    { [ length 16 = ] [ [ 9 = ] all? ] }
    1&&
] unit-test

{ { 1 -2 3 -4 } } [ { 1 2 3 4 } t alternating-sign ] unit-test
{ { -1 2 -3 4 } } [ { 1 2 3 4 } f alternating-sign ] unit-test

{ t } [ { { 1 } }
    { [ drop 1 ] [ (1determinant) ] [ 1 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ 0 } [ { { 0 } } determinant ] unit-test

{ t } [ {
    { 4 6 } ! order is significant
    { 3 8 }
} { [ drop 14 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 8 }
    { 4 6 }
} { [ drop -14 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 5 }
    { 1 -3 }
} { [ drop -11 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 1 -3 }
    { 2 5 }
} { [ drop 11 ] [ (2determinant) ] [ 2 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 0 -1 }
    { 2 -5 4 }
    { -3 1 3 }
} { [ drop -44 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 3 0 -1 }
    { -3 1 3 }
    { 2 -5 4 }
} { [ drop 44 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 -3 1 }
    { 4 2 -1 }
    { -5 3 -2 }
} { [ drop -19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 -3 1 }
    { -5 3 -2 }
    { 4 2 -1 }
} { [ drop 19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 4 2 -1 }
    { 2 -3 1 }
    { -5 3 -2 }
} { [ drop 19 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 5 1 -2 }
    { -1 0 4 }
    { 2 -3 3 }
} { [ drop 65 ] [ (3determinant) ] [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 6 1 1 }
    { 4 -2 5 }
    { 2 8 7 }
} { [ drop -306 ] [ (3determinant) ]  [ 3 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { -5  4 -3  2 }
    { -2  1  0 -1 }
    { -2 -3 -4 -5  }
    {  0  2  0  4 }
} { [ drop -24 ] [ 4 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ t } [ {
    { 2 4 2 2 }
    { 5 1 -6 10 }
    { 4 3 -1 7 }
    { 9 8 7 3 }
} { [ drop 272 ] [ 4 swap (ndeterminant) ] [ determinant ] }
    call-eq?
] unit-test

{ {
    { 2 2 2 }
    { -2 3 3 }
    { 0 -10 0 }
} } [ {
    { 3 0 2 }
    { 2 0 -2 }
    { 0 1 1 }
} >minors ] unit-test

! i think this unit test is wrong
! { {
!     { 1 -6 -13 }
!     { 0 0 0 }
!     { 1 -6 -13 }
! } } [ {
!     { 1 2 1 }
!     { 6 -1 0 }
!     { 1 -2 -1 }
! } >minors ] unit-test

{ {
    { 1 6 -13 }
    { 0 0 0 }
    { 1 6 -13 }
} } [ {
    { 1 -6 -13 }
    { 0 0 0 }
    { 1 -6 -13 }
} >cofactors ] unit-test
