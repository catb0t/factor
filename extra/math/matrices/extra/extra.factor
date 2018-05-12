USING: math.matrices ;
IN: math.matrices.extra

<PRIVATE
: (gram-schmidt) ( v seq -- newseq )
    [ dupd proj v- ] each ;
PRIVATE>

: gram-schmidt ( matrix -- orthogonal )
    [ V{ } clone [ over (gram-schmidt) suffix! ] reduce ] keep like ;

: gram-schmidt-normalize ( matrix -- orthonormal )
    gram-schmidt [ normalize ] map ; inline

: kronecker-product ( m1 m2 -- m )
    '[ [ _ n*m  ] map ] map stitch stitch ;

: outer-product ( u v -- m )
    '[ _ n*v ] map ;

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
GENERIC: >scale-factors ( object -- x y z )
M: number >scale-factors
    dup dup ;
M: sequence >scale-factors
    first3 ;
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

! -------------------------------------------------
! numerical analysis of matrices follows
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

: square-rank ( square-matrix -- rank ) ;
: nonsquare-rank ( matrix -- rank ) ;
PRIVATE>

GENERIC: rank ( matrix -- rank )
M: zero-matrix rank
    drop +zero-rank+ ;

M: square-matrix rank
    square-rank ;

M: matrix rank
    nonsquare-rank ;

GENERIC: nullity ( matrix -- nullity )


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

! -----------------------------
! end of inverse operations !

! TODO: use the faster algorithm here
: invertible-matrix? ( matrix -- ? )
    ! determinant zero?
    [ dim first2 max <identity-matrix> ] keep
    dup multiplicative-inverse mdot = ;

: linearly-independent-matrix? ( matrix -- ? ) ;

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

: covariance-matrix-ddof ( matrix ddof -- cov )
    '[ _ cov-ddof ] cartesian-column-map ; inline

: covariance-matrix ( matrix -- cov )
    0 covariance-matrix-ddof ; inline

: sample-covariance-matrix ( matrix -- cov )
    1 covariance-matrix-ddof ; inline
