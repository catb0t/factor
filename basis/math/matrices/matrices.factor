! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, and Cat Stevens.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.singleton columns combinators
combinators.short-circuit combinators.smart formatting fry
grouping kernel locals math math.bits math.functions math.order
math.ranges math.statistics math.vectors math.vectors.private
sequences sequences.deep sequences.private summary ;
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

PREDICATE: matrix < sequence
    { [ [ sequence? ] all? ] [ well-formed-matrix? ] } 1&& ;

DEFER: dim
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

<PRIVATE
: (nth-from-end) ( n seq -- n )
    length 1 - swap - ; inline

: nth-end ( n seq -- elt )
    [ (nth-from-end) ] keep nth ; inline

: set-nth-end ( elt n seq -- )
    [ (nth-from-end) ] keep set-nth ; inline

PRIVATE>

! Benign matrix constructors
: <matrix> ( m n element -- matrix )
    '[ _ _ <array> ] replicate ; inline

: <matrix-by> ( m n quot: ( ... -- elt ) -- matrix )
    '[ _ _ replicate ] replicate ; inline

: <matrix-by-indices> ( ... m n quot: ( ... m' n' -- ... elt ) -- ... matrix )
    [ [ <iota> ] bi@ ] dip cartesian-map ; inline

: <zero-matrix> ( m n -- matrix )
    0 <matrix> ; inline

: <zero-square-matrix> ( n -- matrix )
    dup <zero-matrix> ; inline

! main-diagonal matrix
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

ALIAS: transpose flip

! VERY slow
: anti-transpose ( matrix -- newmatrix )
    [ reverse ] map transpose [ reverse ] map ;

: row ( n matrix -- row )
    nth ; inline

: rows ( seq matrix -- rows )
    '[ _ row ] map ; inline

: col ( n matrix -- col )
    swap '[ _ swap nth ] map ; inline

: cols ( seq matrix -- cols )
    '[ _ col ] map ; inline

:: >square-matrix ( m -- subset )
    m dim first2 :> ( x y ) {
        { [ x y = ] [ m ] }
        { [ x y < ] [ x <iota> m cols transpose ] }
        { [ x y > ] [ y <iota> m rows ] }
    } cond ;

GENERIC: <square-rows> ( desc -- matrix )
M: integer <square-rows>
    <iota> <square-rows> ;
M: sequence <square-rows>
    [ length ] keep >array '[ _ clone ] { } replicate-as ;

M: square-matrix <square-rows> ;
M: matrix <square-rows> >square-matrix ; ! coercing to square is more useful than no-method

GENERIC: <square-cols> ( desc -- matrix )
M: integer <square-cols>
    <iota> <square-cols> ;
M: sequence <square-cols>
    <square-rows> flip ;

M: square-matrix <square-cols> ;
M: matrix <square-cols>
    >square-matrix ;

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

! element- and sequence-wise operations, getters and setters
: stitch ( m -- m' )
    [ ] [ [ append ] 2map ] map-reduce ;

: matrix-map ( matrix quot: ( ... elt -- ... elt' ) -- matrix' )
    '[ _ map ] map ; inline

: column-map ( matrix quot: ( ... col -- ... col' ) -- matrix' )
    [ transpose ] dip map transpose ; inline

! a simpler verison of this like matrix-map except but map-index should be possible
: cartesian-matrix-map ( matrix quot: ( ... pair elt -- ... elt' ) -- matrix' )
    [ [ first length <cartesian-square-indices> ] keep ] dip
    '[ _ @ ] matrix-map ; inline

: cartesian-column-map ( matrix quot: ( ... pair elt -- ... elt' ) -- matrix' )
    [ cols first2 ] prepose cartesian-matrix-map ; inline

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
: mnorm ( m -- m' ) dup mmax abs m/n ;
: m-infinity-norm ( m -- n ) [ [ abs ] map-sum ] map supremum ;
: m-1norm ( m -- n ) flip m-infinity-norm ;
: frobenius-norm ( m -- n ) [ [ sq ] map-sum ] map-sum sqrt ;

! well-defined for square matrices; but works on nonsquare too
: main-diagonal ( matrix -- seq )
    >square-matrix [ swap nth ] map-index ; inline

! top right to bottom left; reverse the result if you expected it to start in the lower left
: anti-diagonal ( matrix -- seq )
    >square-matrix [ swap nth-end ] map-index ; inline

<PRIVATE
: (rows-iota) ( matrix -- rows-iota )
    dim first <iota> ;
: (cols-iota) ( matrix -- cols-iota )
    dim second <iota> ;

: simple-rows-except ( matrix desc quot -- others )
    curry [ dup (rows-iota) ] dip
    pick reject-as swap rows ; inline

: simple-cols-except ( matrix desc quot -- others )
    curry [ dup (cols-iota) ] dip
    pick reject-as swap cols transpose ; inline ! need to un-transpose the result of cols

CONSTANT: scalar-except-quot [ = ]
CONSTANT: sequence-except-quot [ member? ]
PRIVATE>

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

: matrix-dim ( matrix -- dimensions )
    [ { 0 0 } ]
    [ [ length ] [ first length ] bi 2array ] if-empty ;
