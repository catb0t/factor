USING: combinators.short-circuit kernel math math.matrices math.matrices.private
math.vectors sequences tools.test ;
IN: math.matrices.tests

{  { { 0 } { 0 } { 0 } }  } [ 3 1 <zero-matrix> ] unit-test

{ {
    { 1 0 0 }
    { 0 1 0 }
    { 0 0 1 }
} } [
    3 <identity-matrix>
] unit-test

{ {
    { 1 0 0 }
    { 0 2 0 }
    { 0 0 3 }
} } [
    { 1 2 3 } <diagonal-matrix>
] unit-test

{ {
    { 1 1 1 }
    { 4 2 1 }
    { 9 3 1 }
    { 25 5 1 } }
} [
    { 1 2 3 5 } 3 <vandermonde-matrix>
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

{ { 3 4 } } [ { { 1 0 } { 0 1 } } { 3 4 } m.v ] unit-test
{ { 4 3 } } [ { { 0 1 } { 1 0 } } { 3 4 } m.v ] unit-test

{ { { 6 } } } [ { { 3 } } { { 2 } } m. ] unit-test
{ { { 11 } } } [ { { 1 3 } } { { 5 } { 2 } } m. ] unit-test

{ { { 28 } } } [
    { { 2 4 6 } }
    { { 1 } { 2 } { 3 } }
    m.
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

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 5 <matrix> ] unit-test

{ {
    { 5 5 }
    { 5 5 }
} } [ 2 2 [ 5 ] <matrix-by> ] unit-test

{ {
    { 0 1 2 }
    { 1 2 3 }
} } [ 2 3 [ + ] <matrix-by-indices> ] unit-test

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

{ t } [ { } square-matrix? ] unit-test
{ t } [ { { 1 } } square-matrix? ] unit-test
{ t } [ { { 1 2 } { 3 4 } } square-matrix? ] unit-test
{ f } [ { { 1 } { 2 3 } } square-matrix? ] unit-test
{ f } [ { { 1 2 } } square-matrix? ] unit-test

! TODO: from <<<<<<< HEAD
{ 9 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } m-1norm ] unit-test

{ 8 }
[ { { 2 -2 1 } { 1 3 -1 } { 2 -4 2 } } m-infinity-norm ] unit-test

{ 2.0 }
[ { { 1 1 } { 1 1 } } frobenius-norm ] unit-test
! TODO: from "intermediate commit"
! any deep-empty matrix is null
! it doesn't make any sense for { } to be null while { { } } to be considered nonnull
{ t } [ { } null-matrix? ] unit-test
{ t } [ { { } } null-matrix? ] unit-test
{ t } [ { { { } } { { { } } } } null-matrix? ] unit-test
{ t } [ { { } { } { } } null-matrix? ] unit-test
{ f } [ { { { 1 } } { 2 } { } } null-matrix? ] unit-test

{ t } [ 10 dup <zero-matrix> zero-matrix? ] unit-test
{ t } [ 10 10 15 <simple-eye> zero-matrix? ] unit-test
{ f } [ 0 dup <zero-matrix> zero-matrix? ] unit-test
{ f } [ 4 <identity-matrix> zero-matrix? ] unit-test
{ f } [ 4 <box-matrix> zero-matrix? ] unit-test

{ { 1 1 1 1 } } [ 4 <identity-matrix> main-diagonal ] unit-test
{ 0 } [ 4 <identity-matrix> anti-diagonal sum ] unit-test

{ { 4 8 } } [ { { 4 6 } { 3 8 } } main-diagonal ] unit-test
{ { 6 3 } } [ { { 4 6 } { 3 8 } } anti-diagonal ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> main-diagonal ] unit-test
{ { 1 2 3 4 } } [ { 1 2 3 4 } <diagonal-matrix> transpose main-diagonal ] unit-test

{ 14 } [ { { 4 6 } { 3 8 } }   (2determinant) ] unit-test
{ 14 } [ { { 4 6 } { 3 8 } } 2 (ndeterminant) ] unit-test
{ 14 } [ { { 4 6 } { 3 8 } }      determinant ] unit-test
{ -14 } [ { { 3 8 } { 4 6 } }   (2determinant) ] unit-test
{ -14 } [ { { 3 8 } { 4 6 } } 2 (ndeterminant) ] unit-test
{ -14 } [ { { 3 8 } { 4 6 } }      determinant ] unit-test

{ -11 } [ { { 2 5 } { 1 -3 } }   (2determinant) ] unit-test
{ -11 } [ { { 2 5 } { 1 -3 } } 2 (ndeterminant) ] unit-test
{ -11 } [ { { 2 5 } { 1 -3 } }      determinant ] unit-test
{ 11 } [ { { 1 -3 } { 2 5 } }   (2determinant) ] unit-test
{ 11 } [ { { 1 -3 } { 2 5 } } 2 (ndeterminant) ] unit-test
{ 11 } [ { { 1 -3 } { 2 5 } }      determinant ] unit-test

{ -44 } [ { { 3 0 -1 } { 2 -5 4 } { -3 1 3 } }   (3determinant) ] unit-test
{ -44 } [ { { 3 0 -1 } { 2 -5 4 } { -3 1 3 } } 3 (ndeterminant) ] unit-test
{ -44 } [ { { 3 0 -1 } { 2 -5 4 } { -3 1 3 } }      determinant ] unit-test

{ -19 } [ { { 2 -3 1 } { 4 2 -1 } { -5 3 -2 } }   (3determinant) ] unit-test
{ -19 } [ { { 2 -3 1 } { 4 2 -1 } { -5 3 -2 } } 3 (ndeterminant) ] unit-test
{ -19 } [ { { 2 -3 1 } { 4 2 -1 } { -5 3 -2 } }      determinant ] unit-test

{ 65 } [ { { 5 1 -2 } { -1 0 4 } { 2 -3 3 } }   (3determinant) ] unit-test
{ 65 } [ { { 5 1 -2 } { -1 0 4 } { 2 -3 3 } } 3 (ndeterminant) ] unit-test
{ 65 } [ { { 5 1 -2 } { -1 0 4 } { 2 -3 3 } }      determinant ] unit-test

{ t } [ {
    { -5  4 -3  2 }
    { -2  1  0 -1 }
    { -2 -3 -4 -5  }
    {  0  2  0  4 }
} { [ 4 (ndeterminant) ] [ determinant ] [ -24 ] } 1&& ] unit-test

{ -306 } [ {
    { 6 1 1 }
    { 4 -2 5 }
    { 2 8 7 }
} (3determinant) ] unit-test
{ -306 } [ {
    { 6 1 1 }
    { 4 -2 5 }
    { 2 8 7 }
} determinant ] unit-test

