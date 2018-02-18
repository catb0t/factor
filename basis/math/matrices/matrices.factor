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
SINGLETONS:      +full-rank+ +half-rank+ +deficient-rank+ +uncalculated-rank+ ;
UNION: rank-kind +full-rank+ +half-rank+ +deficient-rank+ +uncalculated-rank+ ;

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
    '[ _ _ random-integers ] replicate
    finish-randomizing-matrix ; inline

: <square-random-integer-matrix> ( n max -- matrix )
    dupd <random-integer-matrix> ; inline

: <random-unit-matrix> ( m n max -- matrix )
    '[ _ random-units [ _ random * ] map ] replicate
    finish-randomizing-matrix ; inline

: <square-random-unit-matrix> ( n max -- matrix )
    dupd <random-unit-matrix> ; inline

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
    cartesian-map ;

! if m = n and k = 0 then <identity-matrix> is (possibly) more efficient
:: <simple-eye> ( m n k -- matrix )
    m n = k 0 = and
    [ n <identity-matrix> ]
    [ m n k 1 <eye> ] if ; inline

: <coordinate-matrix> ( dim -- coordinates )
  first2 [ <iota> ] bi@ cartesian-product ; inline

DEFER: rows
DEFER: cols
DEFER: transpose
GENERIC: <square-rows> ( desc -- matrix )
M: integer <square-rows> <iota> <square-rows> ;

M: square-matrix <square-rows> ;
! could no-method here but coercing to square is more useful
M: matrix <square-rows>
    [ dim first2 ] keep 2over < [
        ! rows < cols
        nip [ <iota> ] dip cols transpose
    ] [ ! rows > cols
        swapd nip [ <iota> ] dip rows
    ] if ;

M: sequence <square-rows>
    [ length ] keep >array '[ _ clone ] { } replicate-as ;

GENERIC: <square-cols> ( desc -- matrix )
M: integer <square-cols> <iota> <square-cols> ;

M: square-matrix <square-cols> ;
M: matrix <square-cols>
    <square-rows> ;

M: sequence <square-cols>
    <square-rows> flip ;

! -------------------------------------------------------------
! end of the simple creators; here are the complex builders
DEFER: dimension-range
<PRIVATE ! implementation details of <lower-matrix> and <upper-matrix>
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

: <cartesian-square-indices> ( n -- matrix )
    <iota> dup cartesian-product ; inline

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

! Transformation matrices
:: <rotation-matrix3> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +    x y * 1.0 c - * z s * -  x z * 1.0 c - * y s * + 3array
    x y * 1.0 c - * z s * +  y sq 1.0 y sq - c * +    y z * 1.0 c - * x s * - 3array
    x z * 1.0 c - * y s * -  y z * 1.0 c - * x s * +  z sq 1.0 z sq - c * +   3array
    3array ;

:: <rotation-matrix4> ( axis theta -- matrix )
    theta cos :> c
    theta sin :> s
    axis first3 :> ( x y z )
    x sq 1.0 x sq - c * +    x y * 1.0 c - * z s * -  x z * 1.0 c - * y s * +  0 4array
    x y * 1.0 c - * z s * +  y sq 1.0 y sq - c * +    y z * 1.0 c - * x s * -  0 4array
    x z * 1.0 c - * y s * -  y z * 1.0 c - * x s * +  z sq 1.0 z sq - c * +    0 4array
    { 0.0 0.0 0.0 1.0 } 4array ;

:: <translation-matrix4> ( offset -- matrix )
    offset first3 :> ( x y z )
    {
        { 1.0 0.0 0.0 x   }
        { 0.0 1.0 0.0 y   }
        { 0.0 0.0 1.0 z   }
        { 0.0 0.0 0.0 1.0 }
    } ;

<PRIVATE
: >scale-factors ( number/sequence -- x y z )
    dup number? [ dup dup ] [ first3 ] if ;
PRIVATE>

:: <scale-matrix3> ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 }
        { 0.0 y   0.0 }
        { 0.0 0.0 z   }
    } ;

:: <scale-matrix4> ( factors -- matrix )
    factors >scale-factors :> ( x y z )
    {
        { x   0.0 0.0 0.0 }
        { 0.0 y   0.0 0.0 }
        { 0.0 0.0 z   0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

: <ortho-matrix4> ( factors -- matrix )
    [ recip ] map <scale-matrix4> ;

:: <frustum-matrix4> ( xy-dim near far -- matrix )
    xy-dim first2 :> ( x y )
    near x /f :> xf
    near y /f :> yf
    near far + near far - /f :> zf
    2 near far * * near far - /f :> wf

    {
        { xf  0.0  0.0 0.0 }
        { 0.0 yf   0.0 0.0 }
        { 0.0 0.0  zf  wf  }
        { 0.0 0.0 -1.0 0.0 }
    } ;

:: <skew-matrix4> ( theta -- matrix )
    theta tan :> zf
    {
        { 1.0 0.0 0.0 0.0 }
        { 0.0 1.0 0.0 0.0 }
        { 0.0 zf  1.0 0.0 }
        { 0.0 0.0 0.0 1.0 }
    } ;

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
: mneg ( m -- m ) [ vneg ] map ;
: mabs ( m -- m ) [ vabs ] map ;

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
: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;

: (m^n) ( m n -- n )
    make-bits over first length <identity-matrix>
    [ [ dupd mdot ] when [ dup mdot ] dip ] reduce nip ;
PRIVATE>

: gram-schmidt ( matrix -- orthogonal )
    [ V{ } clone [ over (gram-schmidt) suffix! ] reduce ] keep like ;

: gram-schmidt-normalize ( matrix -- orthonormal )
    gram-schmidt [ normalize ] map ; inline

DEFER: multiplicative-inverse
! A^-1 is the inverse but other negative powers are nonsense
: m^n ( m n -- n ) {
        { [ dup -1 = ] [ drop multiplicative-inverse ] }
        { [ dup 0 >= ] [ (m^n) ] }
        [ negative-power-matrix ]
    } cond ;

: n^m ( n m -- n ) swap m^n ;

: kronecker-product ( m1 m2 -- m )
    '[ [ _ n*m  ] map ] map stitch stitch ;

: outer-product ( u v -- m )
    '[ _ n*v ] map ;

! -------------------------------------------------
! numerical analysis of matrices follows
<PRIVATE
: (rows-iota) ( matrix -- matrix rows )
    dup dim first <iota> ;
: (cols-iota) ( matrix -- matrix cols )
    dup dim second <iota> ;

: lookup-rank ( matrix -- rank-class ) ;
PRIVATE>

GENERIC: rank ( matrix -- rank-class )
M: zero-matrix rank
    drop 0 ;

M: square-matrix rank
    drop 0 ;

M: matrix rank
    lookup-rank ;

GENERIC: nullity ( matrix -- nullity )

! well-defined for square matrices; but works on nonsquare too
: main-diagonal ( matrix -- vec )
    [ swap nth ] map-index ; inline

! top right to bottom left; reverse the result if you expected it to start in the lower left
: anti-diagonal ( matrix -- vec )
    [ swap nth-end ] map-index ; inline

ALIAS: transpose flip

! VERY slow implementation
: anti-transpose ( matrix -- newmatrix )
    [ reverse ] map transpose [ reverse ] map ;

GENERIC: rows-except ( matrix desc -- others )
M: integer rows-except
    [ (rows-iota) ] dip
    '[ _ = ] pick reject-as swap rows ;

M: sequence rows-except
    [ (rows-iota) ] dip
    '[ _ member? ] pick reject-as swap rows ;

GENERIC: cols-except ( matrix desc -- others )
M: integer cols-except
    [ (cols-iota) ] dip
    '[ _ = ] pick reject-as swap cols transpose ; ! need to un-transpose the result of cols

M: sequence cols-except
    [ (cols-iota) ] dip
    '[ _ member? ] pick reject-as swap cols transpose ;

! well-defined for any well-formed-matrix
: matrix-except ( matrix exclude-pair -- submatrix )
    first2 [ rows-except ] dip cols-except ;

:: matrix-except-all ( matrix-seq -- expansion )
    matrix-seq dim [ <iota> ] map first2 cartesian-product
    [ [ matrix-seq swap matrix-except ] map ] map ;

! implementation details of determinant and inverse
<PRIVATE
: alternating-sign ( seq odd-elts? -- seq' )
    '[ even? _ = [ neg ] unless ] map-index ;

! the determinant of a 1x1 matrix is the value itself
! this works for any-dimensional matrices too
: (1determinant) ( matrix -- 1det ) flatten first ; inline

! optimized to find the determinant of a 2x2 matrix
: (2determinant) ( matrix -- 2det )
    ! multiply the diagonals and subtract
    [ main-diagonal ] [ anti-diagonal ] bi [ first2 * ] bi@ - ; inline

! optimized for 3x3
! https://www.mathsisfun.com/algebra/matrix-determinant.html
:: (3determinant) ( matrix-seq -- 3det )
    ! first 3 elements of row 1
    matrix-seq first first3 :> ( a b c )
    ! last 2 rows, transposed to make the next step easier
    matrix-seq rest transpose
    ! get the lower sub-matrices in reverse order of a b c columns
    [ rest ] [ [ first ] [ third ] bi 2array ] [ 1 head* ] tri 3array
    ! find determinants
    [ (2determinant) ] map
    ! negate odd elements of a b c and multiply by the new determinants
    { a b c } t alternating-sign v*
    ! sum the resulting sequence
    sum ;

DEFER: (ndeterminant)
: make-determinants ( n matrix -- seq )
    <repetition> [
        cols-except [ length ] keep (ndeterminant) ! recurses here
    ] map-index ;

DEFER: (determinant)
! generalized to 4 and higher
: (ndeterminant) ( n matrix -- ndet )
    ! TODO? recurse for n < 3
    over 4 < [ (determinant) ] [
        [ nip first t alternating-sign ] [ rest make-determinants ] 2bi
        v* sum
    ] if ;

! switches on dimensions only
: (determinant) ( n matrix -- determinant )
    over {
        { 1 [ nip (1determinant) ] }
        { 2 [ nip (2determinant) ] }
        { 3 [ nip (3determinant) ] }
        [ drop (ndeterminant) ]
    } case ;
PRIVATE>

GENERIC: determinant ( matrix -- determinant )
M: zero-square-matrix determinant
    drop 0 ;

M: square-matrix determinant
    [ length ] keep (determinant) ;

! determinant is undefined for m =/= n, unlike inverse
M: matrix determinant
    dim first2 non-square-determinant ;

: 1/det ( matrix -- 1/det )
    determinant recip ; inline

! -----------------------------------------------------
! inverse operations and implementations follow
ALIAS: additive-inverse mneg

! per element, find the determinant of all other elements except the element's row / col
! https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
: >minors ( matrix -- matrix' )
    matrix-except-all [ [ determinant ] map ] map ;

! alternately invert values of the matrix (see alternating-sign)
: >cofactors ( matrix -- matrix' )
    [ even? alternating-sign ] map-index ;

! multiply a matrix by the inverse of its determinant
: m*1/det ( matrix -- matrix' )
    [ 1/det ] keep n*m ; inline

! inverse implementation
<PRIVATE
! https://www.mathsisfun.com/algebra/matrix-inverse-minors-cofactors-adjugate.html
: (square-inverse) ( square-matrix -- inverted )
    ! inverse of the determinant of the input matrix
    [ 1/det ]
    ! adjugate of the cofactors of the matrix of minors
    [ >minors >cofactors transpose ]
    ! adjugate * 1/det
    bi n*m ;

! TODO
: (left-inverse) ( matrix -- left-invert )   ;
: (right-inverse) ( matrix -- right-invert ) ;

! TODO update this when rank works properly
! only defined for rank(A) = rows(A) OR rank(A) = cols(M)
! https://en.wikipedia.org/wiki/Invertible_matrix
: (specialized-inverse) ( rect-matrix -- inverted )
    dup [ rank ] [ dim ] bi [ = ] with map {
        { { t f } [ (left-inverse) ] }
        { { f t } [ (right-inverse) ] }
        [ no-case ]
    } case ;
PRIVATE>

! A^-1
GENERIC: multiplicative-inverse ( matrix -- inverse )
M: zero-square-matrix multiplicative-inverse
    length <zero-square-matrix> ;

M: square-matrix multiplicative-inverse
    (square-inverse) ;

M: zero-matrix multiplicative-inverse
    dim first2 <zero-matrix> ; ! TODO: error based on rankiness

M: matrix multiplicative-inverse
    (specialized-inverse) ;

! -----------------------------
! end of inverse operations !

: dim ( matrix -- pair/f )
    [ { 0 0 } ]
    [ [ length ] [ first length ] bi 2array ] if-empty ;

: dimension-range ( matrix -- dim range )
    dim [ <coordinate-matrix> ] [ first [1,b] ] bi ;

! TODO: use the faster algorithm here
: invertible-matrix? ( matrix -- ? )
    ! determinant zero?
    [ dim first2 max <identity-matrix> ] keep
    dup multiplicative-inverse mdot = ;

: linearly-independent-matrix? ( matrix -- ? ) ;

: covariance-matrix-ddof ( matrix ddof -- cov )
    '[ _ cov-ddof ] cartesian-column-map ; inline

: covariance-matrix ( matrix -- cov )
    0 covariance-matrix-ddof ; inline

: sample-covariance-matrix ( matrix -- cov )
    1 covariance-matrix-ddof ; inline
