! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.vectors math.matrices
namespaces sequences fry sorting ;
IN: math.matrices.elimination


: change-row ( ..a row# quot: ( ..a seq -- ..b seq ) matrix -- ..b )
    swap change-nth ; inline

: exchange-rows ( pair matrix -- ) swap first2 exchange ;

: skip ( i seq quot -- n )
    over [ find-from drop ] dip swap [ ] [ length ] ?if ; inline

: first-nonzero-col ( matrix row# -- n )
    ! First non-zero column
    0 swap nth [ zero? not ] skip ;

: clear-scale ( col# pivot-row i-row -- n )
    [ over ] dip nth dup zero? [
        3drop 0
    ] [
        [ nth dup zero? ] dip swap [
            2drop 0
        ] [
            swap / neg
        ] if
    ] if ;

: (clear-col) ( col# pivot-row i -- )
    [ [ clear-scale ] 2keep [ n*v ] dip v+ ] change-row ; inline

: clear-col ( col# row# rows -- )
    [ matrix-nth ] dip [ [ 2dup ] dip (clear-col) ] each 2drop ;

: do-row ( matrix exchange-with row# -- )
    [ exchange-rows ] keep
    [ first-nonzero-col ] keep
    dup 1 + clear-col ;

: pivot-row ( matrix col# row# -- n )
    [ dupd nth nth zero? not ] find 2nip ;

: (echelon) ( matrix col# row# -- )
    over cols < over rows < and [
        2dup pivot-row [ over do-row 1 + ] when*
        [ 1 + ] dip (echelon)
    ] [
        2drop
    ] if ;

: echelon ( matrix -- matrix' )
    0 0 (echelon) ;

: nonzero-rows ( matrix -- matrix' )
    [ [ zero? ] all? ] reject ;

: null/rank ( matrix -- null rank )
    echelon dup length swap nonzero-rows length [ - ] keep ;

: leading ( seq -- n elt ) [ zero? not ] find ;

: reduced ( matrix' -- matrix'' )
    rows <iota> <reversed> [
        dup matrix-nth leading drop
        [ swap dup <iota> clear-col ] [ drop ] if*
    ] each ;

:: basis-vector ( row col# -- )
    row clone :> row'
    col# row' nth neg recip :> a
    0 col# row' set-nth
    a row n*v col# matrix get set-nth ;

: nullspace ( matrix -- seq )
    echelon reduced dup empty? [
        dup first length <identity-matrix>
        [
            dup leading drop
            [ basis-vector ] [ drop ] if*
        ] each
        flip nonzero-rows
    ] unless ;

: 1-pivots ( matrix -- matrix )
    [ dup leading nip [ recip v*n ] when* ] map ;

: solution ( matrix -- matrix )
    echelon nonzero-rows reduced 1-pivots ;

: inverse ( matrix -- matrix ) ! Assumes an invertible matrix
    dup length
    [ <identity-matrix> [ append ] 2map solution ] keep
    [ tail ] curry map ;
