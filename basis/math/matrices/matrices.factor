! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, and Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.singleton columns combinators
combinators.short-circuit combinators.smart formatting fry
grouping kernel locals math math.bits math.functions math.order
math.ranges math.statistics math.vectors math.vectors.private
random sequences sequences.deep sequences.private summary ;
IN: math.matrices

! defined here because of issue #1943
DEFER: well-formed-matrix?
: well-formed-matrix? ( object -- ? )
    [ t ] [
        dup first length
        '[ length _ = ] all?
    ] if-empty ;


! the MRO (class linearization) is performed in the order the predicates appear here
! except that null-matrix is last (but it is relied upon by zero-matrix)
! in other words:
! sequence > matrix > zero-matrix > square-matrix > zero-square-matrix > null-matrix

DEFER: dim
PREDICATE: matrix < sequence
    { [ [ sequence? ] all? ] [ well-formed-matrix? ] } 1&& ;

! can't define dim using this predicate for this reason,
! unless we are going to write two versions of dim, one of which is generic
PREDICATE: square-matrix < matrix
    { [ well-formed-matrix? ] [ dim all-eq? ] } 1&& ;

! really truly empty
PREDICATE: null-matrix < matrix
    flatten empty? ;

! just full of zeroes
PREDICATE: zero-matrix < matrix
    dup null-matrix? [ drop f ] [ flatten [ zero? ] all? ] if ;

! square and full of zeroes
PREDICATE: zero-square-matrix < square-matrix
    { [ zero-matrix? ] [ square-matrix? ] } 1&& ;

! TODO: triangular predicates, etc?

! questionable implementation
SINGLETONS:      +full-rank+ +half-rank+ +zero-rank+ +deficient-rank+ +uncalculated-rank+ ;
UNION: rank-kind +full-rank+ +half-rank+ +zero-rank+ +deficient-rank+ +uncalculated-rank+ ;

ERROR: negative-power-matrix
    { m matrix } { n integer } ;
ERROR: non-square-determinant
    { m integer }  { n integer } ;
ERROR: undefined-inverse
    { m integer }  { n integer } { r rank-kind initial: +uncalculated-rank+ } ;

<PRIVATE
: ordinal-suffix ( n -- suffix ) 10 mod abs {
        { 1 [ "st" ] }
        { 2 [ "nd" ] }
        { 3 [ "rd" ] }
        [ drop "th" ]
    } case ;

M: negative-power-matrix summary
    n>> dup ordinal-suffix "%s%s power of a matrix is undefined" sprintf ;
M: non-square-determinant summary
    [ m>> ] [ n>> ] bi "%s x %s matrix is not square and has no determinant" sprintf ;
M: undefined-inverse summary
    [ m>> ] [ n>> ] [ r>> name>> ] tri "%s x %s matrix with rank %s has no inverse" sprintf ;

: (nth-from-end) ( n seq -- n )
    length 1 - swap - ; inline

: nth-end ( n seq -- elt )
    [ (nth-from-end) ] keep nth ; inline

: set-nth-end ( elt n seq -- )
    [ (nth-from-end) ] keep set-nth ; inline

DEFER: alternating-sign
: finish-randomizing-matrix ( matrix -- matrix' )
    [ f alternating-sign randomize ] map randomize ; inline
PRIVATE>

! Benign matrix constructors
: <matrix> ( m n element -- matrix )
    '[ _ _ <array> ] replicate ; inline

: <matrix-by> ( m n quot: ( ... -- elt ) -- matrix )
    '[ _ _ replicate ] replicate ; inline

: <matrix-by-indices> ( ... m n quot: ( ... m' n' -- ... elt ) -- ... matrix )
    [ [ <iota> ] bi@ ] dip cartesian-map ; inline

: <random-integer-matrix> ( m n max -- matrix )
    '[ _ _ 1 + random-integers ] replicate
    finish-randomizing-matrix ; inline

: <random-unit-matrix> ( m n max -- matrix )
    '[ _ random-units [ _ * ] map ] replicate
    finish-randomizing-matrix ; inline

: <zero-matrix> ( m n -- matrix )
    0 <matrix> ; inline

: <zero-square-matrix> ( n -- matrix )
    dup <zero-matrix> ; inline

! main-diagonal matrix
! running time is improved by 10% over the old implementation
: <diagonal-matrix> ( diagonal-seq -- matrix )
    [ length <zero-square-matrix> ] keep over
    '[ dup _ nth set-nth ] each-index ; inline

! could be written: <diagonal-matrix> [ reverse ] map
! but that's 3x slower because of iterating the matrix twice
: <anti-diagonal-matrix> ( diagonal-seq -- matrix )
    [ length <zero-square-matrix> ] keep over
    '[ dup _ nth set-nth-end ] each-index ; inline

: <identity-matrix> ( n -- matrix )
    1 <repetition> <diagonal-matrix> ; inline

: <eye> ( m n k z -- matrix )
    [ [ <iota> ] bi@ ] 2dip
    '[ _ neg + = _ 0 ? ]
    cartesian-map ; inline

! if m = n and k = 0 then <identity-matrix> is (possibly) more efficient
:: <simple-eye> ( m n k -- matrix )
    m n = k 0 = and
    [ n <identity-matrix> ]
    [ m n k 1 <eye> ] if ; inline

: <coordinate-matrix> ( dim -- coordinates )
  first2 [ <iota> ] bi@ cartesian-product ; inline

ALIAS: <cartesian-indices> <coordinate-matrix>

: <cartesian-square-indices> ( n -- matrix )
    dup 2array <cartesian-indices> ; inline

DEFER: rows
DEFER: cols
DEFER: transpose
DEFER: >square-matrix
GENERIC: <square-rows> ( desc -- matrix )
M: integer <square-rows>
    <iota> <square-rows> ;
M: sequence <square-rows>
    [ length ] keep >array '[ _ clone ] { } replicate-as ;

M: square-matrix <square-rows> ;
M: matrix <square-rows> >square-matrix ; ! could no-method here but coercing to square is more useful

GENERIC: <square-cols> ( desc -- matrix )
M: integer <square-cols>
    <iota> <square-cols> ;
M: sequence <square-cols>
    <square-rows> flip ;

M: square-matrix <square-cols> ;
M: matrix <square-cols>
    >square-matrix ;

! -------------------------------------------------------------
! end of the simple creators; here are the complex builders
<PRIVATE ! implementation details of <lower-matrix> and <upper-matrix>
: dimension-range ( matrix -- dim range )
    dim [ <coordinate-matrix> ] [ first [1,b] ] bi ;

: upper-matrix-indices ( matrix -- matrix' )
    dimension-range <reversed> [ tail-slice* >array ] 2map concat ;

: lower-matrix-indices ( matrix -- matrix' )
    dimension-range [ head-slice >array ] 2map concat ;
PRIVATE>

! triangulars
DEFER: matrix-set-nths
: <lower-matrix> ( object m n -- matrix )
    <zero-matrix> [ lower-matrix-indices ] [ matrix-set-nths ] [ ] tri ;

: <upper-matrix> ( object m n -- matrix )
    <zero-matrix> [ upper-matrix-indices ] [ matrix-set-nths ] [ ] tri ;

! Special matrix constructors follow
: <hankel-matrix> ( n -- matrix )
  [ <iota> dup ] keep '[ + abs 1 + dup _ > [ drop 0 ] when ] cartesian-map ;

: <hilbert-matrix> ( m n -- matrix )
    [ <iota> ] bi@ [ + 1 + recip ] cartesian-map ;

: <toeplitz-matrix> ( n -- matrix )
    <iota> dup [ - abs 1 + ] cartesian-map ;

: <box-matrix> ( r -- matrix )
    2 * 1 + dup '[ _ 1 <array> ] replicate ;

: <vandermonde-matrix> ( u n -- matrix )
    <iota> [ v^n ] with map reverse flip ;

! element- and sequence-wise operations, getters and setters
: stitch ( m -- m' )
    [ ] [ [ append ] 2map ] map-reduce ;

: row ( n matrix -- row )
    nth ; inline

: rows ( seq matrix -- rows )
    '[ _ row ] map ; inline

: col ( n matrix -- col )
    swap '[ _ swap nth ] map ; inline

: cols ( seq matrix -- cols )
    '[ _ col ] map ; inline

: matrix-map ( matrix quot: ( ... elt -- ... elt' ) -- matrix' )
    '[ _ map ] map ; inline

: column-map ( matrix quot: ( ... col -- ... col' ) -- matrix' )
    [ transpose ] dip map transpose ; inline
    ! [ [ first length <iota> ] keep ] dip '[ _ col @ ] map ; inline

! row-map would make sense compared to column-map
ALIAS: row-map map

: cartesian-matrix-map ( matrix quot: ( ... pair elt -- ... elt' ) -- matrix' )
    [ [ first length <cartesian-square-indices> ] keep ] dip
    '[ _ @ ] matrix-map ; inline

: cartesian-column-map ( matrix quot: ( ... pair elt -- ... elt' ) -- matrix' )
    [ cols first2 ] prepose cartesian-matrix-map ; inline

ALIAS: cartesian-row-map cartesian-matrix-map

: matrix-nth ( pair matrix -- elt )
    [ first2 swap ] dip nth nth ; inline

: matrix-nths ( pairs matrix -- elts )
    '[ _ matrix-nth ] map ; inline

: matrix-set-nth ( obj pair matrix -- )
    [ first2 swap ] dip nth set-nth ; inline

: matrix-set-nths ( obj pairs matrix -- )
    '[ _ matrix-set-nth ] with each ; inline

! -------------------------------------------
! simple math of matrices follows
: mneg ( m -- m' ) [ vneg ] map ;
: mabs ( m -- m' ) [ vabs ] map ;

: n+m ( n m -- m ) [ n+v ] with map ;
: m+n ( m n -- m ) [ v+n ] curry map ;
: n-m ( n m -- m ) [ n-v ] with map ;
: m-n ( m n -- m ) [ v-n ] curry map ;
: n*m ( n m -- m ) [ n*v ] with map ;
: m*n ( m n -- m ) [ v*n ] curry map ;
: n/m ( n m -- m ) [ n/v ] with map ;
: m/n ( m n -- m ) [ v/n ] curry map ;

: m+  ( m1 m2 -- m ) [ v+ ] 2map ;
: m-  ( m1 m2 -- m ) [ v- ] 2map ;
: m*  ( m1 m2 -- m ) [ v* ] 2map ;
: m/  ( m1 m2 -- m ) [ v/ ] 2map ;

: vdotm ( v m -- p ) flip [ vdot ] with map ;
: mdotv ( m v -- p ) [ vdot ] curry map ;
: mdot ( m m -- m ) flip [ swap mdotv ] curry map ;

: m~  ( m1 m2 epsilon -- ? ) [ v~ ] curry 2all? ;

: mmin ( m -- n ) [ 1/0. ] dip [ [ min ] each ] each ;
: mmax ( m -- n ) [ -1/0. ] dip [ [ max ] each ] each ;
: mnorm ( m -- n ) dup mmax abs m/n ;
: m-infinity-norm ( m -- n ) [ [ abs ] map-sum ] map supremum ;
: m-1norm ( m -- n ) flip m-infinity-norm ;
: frobenius-norm ( m -- n ) [ [ sq ] map-sum ] map-sum sqrt ;

: cross ( vec1 vec2 -- vec3 )
    [ [ { 1 2 0 } vshuffle ] [ { 2 0 1 } vshuffle ] bi* v* ]
    [ [ { 2 0 1 } vshuffle ] [ { 1 2 0 } vshuffle ] bi* v* ] 2bi v- ; inline

:: normal ( vec1 vec2 vec3 -- vec4 )
    vec2 vec1 v- vec3 vec1 v- cross normalize ; inline

: proj ( v u -- w )
    [ [ v. ] [ norm-sq ] bi / ] keep n*v ;

: perp ( v u -- w )
    dupd proj v- ;

! implementation details of slightly complicated math like gram schmidt
<PRIVATE
: (m^n) ( m n -- n )
    make-bits over first length <identity-matrix>
    [ [ dupd mdot ] when [ dup mdot ] dip ] reduce nip ;
PRIVATE>
DEFER: multiplicative-inverse
! A^-1 is the inverse but other negative powers are nonsense
: m^n ( m n -- n ) {
        { [ dup -1 = ] [ drop multiplicative-inverse ] }
        { [ dup 0 >= ] [ (m^n) ] }
        [ negative-power-matrix ]
    } cond ;

: n^m ( n m -- n ) swap m^n ;

:: >square-matrix ( m -- subset )
    m dim first2 :> ( x y ) {
        { [ x y = ] [ m ] }
        { [ x y < ] [ x <iota> m cols transpose ] }
        { [ x y > ] [ y <iota> m rows ] }
    } cond ;

! well-defined for square matrices; but works on nonsquare too
: main-diagonal ( matrix -- seq )
    >square-matrix [ swap nth ] map-index ; inline

! top right to bottom left; reverse the result if you expected it to start in the lower left
: anti-diagonal ( matrix -- seq )
    >square-matrix [ swap nth-end ] map-index ; inline

ALIAS: transpose flip

! VERY slow implementation
: anti-transpose ( matrix -- newmatrix )
    [ reverse ] map transpose [ reverse ] map ;

GENERIC: rows-except ( matrix desc -- others )
M: integer rows-except  scalar-except-quot   simple-rows-except ;
M: sequence rows-except sequence-except-quot simple-rows-except ;

GENERIC: cols-except ( matrix desc -- others )
M: integer cols-except  scalar-except-quot   simple-cols-except ;
M: sequence cols-except sequence-except-quot simple-cols-except ;

! well-defined for any well-formed-matrix
: matrix-except ( matrix exclude-pair -- submatrix )
    first2 [ rows-except ] dip cols-except ;

:: matrix-except-all ( matrix-seq -- expansion )
    matrix-seq dim [ <iota> ] map first2 cartesian-product
    [ [ matrix-seq swap matrix-except ] map ] map ;

: dim ( matrix -- dimensions )
    [ { 0 0 } ]
    [ [ length ] [ first length ] bi 2array ] if-empty ;
