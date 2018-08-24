! Copyright (C) 2006, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.short-circuit fry kernel locals math
math.matrices math.vectors namespaces sequences sorting
tools.deprecation ;
IN: math.matrices.elimination

SYMBOL: matrix deprecated

: overd ( x y z -- x y x z ) [ over ] dip ; deprecated

: with-matrix ( matrix quot -- )
    matrix swap [ matrix get ] compose with-variable ; inline deprecated

: ~with-matrix ( matrix quot: ( matrix -- matrix ) -- matrix )
    call( matrix -- matrix ) ;

: nth-row ( row# -- seq ) matrix get nth ; deprecated
: ~nth-row ( row# matrix -- seq ) nth ;

: change-row ( ..a row# quot: ( ..a seq -- ..b seq ) -- ..b )
    matrix get swap change-nth ; inline deprecated

: ~change-row ( ..a row# matrix quot: ( ..a seq -- ..b seq ) -- ..b matrix )
    change-nth ; inline

: exchange-rows ( row# row# -- ) matrix get exchange ; deprecated
: ~exchange-rows ( row# row# matrix -- ) exchange ;

! rename these
: rows ( -- n ) matrix get length ; deprecated
: ~count-rows ( matrix -- n ) length ;

: cols ( -- n ) 0 nth-row length ; deprecated
: ~count-cols ( matrix -- n ) [ 0 ] dip nth length ;

: skip ( i seq quot -- n )
    over [ find-from drop ] dip swap [ ] [ length ] ?if ; inline

: first-col ( row# -- n )
    ! First non-zero column
    0 swap nth-row [ zero? not ] skip ; deprecated

: ~first-nonzero-col ( row# matrix -- n )
    ! First non-zero column
    0 swap ~nth-row [ zero? not ] skip ;

: clear-scale ( col# pivot-row i-row -- n )
    overd nth dup zero? [
        3drop 0
    ] [
        [ nth dup zero? ] dip swap [
            2drop 0
        ] [
            swap / neg
        ] if
    ] if ;

: (clear-col) ( col# pivot-row i -- )
    [ [ clear-scale ] 2keep [ n*v ] dip v+ ] change-row ;

: ~(clear-col) ( col# pivot-row i matrix -- )
    [ [ clear-scale ] 2keep [ n*v ] dip v+ ] change-nth ;

: rows-from ( row# -- slice )
    rows dup <iota> <slice> ; deprecated

: ~rows-from ( row# matrix -- slice )
    ~count-rows dup <iota> <slice> ;

! rows is a 1-D array of row numbers

: clear-col ( col# row# rows -- )
    [ nth-row ] dip [ [ 2dup ] dip (clear-col) ] each 2drop ; deprecated

! correct locals implementation of clear-col
:: clear-col2 ( col# row# rows -- )
    row# nth-row :> nrow
    rows [ [ col# nrow ] dip (clear-col) ] each ; deprecated

! ???
:: ~clear-col ( col# row# matrix rows -- )
    row# matrix ~nth-row :> nrow
    rows [ [ col# nrow ] dip matrix ~(clear-col) ] each ;

: do-row ( exchange-with row# -- )
    [ exchange-rows ] keep
    [ first-col ] keep
    dup 1 + rows-from clear-col2 ; deprecated

! locals implementation passes tests
:: do-row2 ( exchange-with row# -- )
    exchange-with row# exchange-rows
    row# first-col :> n
    n row#
    dup 1 + rows-from clear-col2 ; deprecated

:: ~do-row ( exchange-with row# matrix -- )
    exchange-with row# matrix ~exchange-rows
    row# matrix ~first-nonzero-col :> n
    n row#
    dup 1 + matrix ~rows-from matrix ~clear-col ;

: find-row ( row# quot -- i elt )
    [ rows-from ] dip find ; inline deprecated

: ~find-row ( row# quot -- i elt )
    [ ~rows-from ] dip find ; inline

: pivot-row ( col# row# -- n )
    [ dupd nth-row nth zero? not ] find-row 2nip ; deprecated

: ~pivot-row ( col# row# matrix -- n )
    dup '[ dupd _ ~nth-row nth zero? not ] ~find-row 2nip ;

: (echelon) ( col# row# -- )
    over cols < over rows < and [
        2dup pivot-row [ over do-row2 1 + ] when*
        [ 1 + ] dip (echelon)
    ] [
        2drop
    ] if ;

:: (echelon)2 ( col# row# -- )
    col# cols < row# rows < and [
        col# row# 2dup pivot-row [ over do-row2 1 + ] when*
        [ 1 + ] dip (echelon)
    ] [

    ] if ;

:: ~(echelon) ( col# row# matrix -- matrix )
    col# matrix ~count-cols <
    row# matrix ~count-rows <
    and [
        col# row# 2dup matrix ~pivot-row [ over matrix ~do-row 1 + ] when*
        [ 1 + ] dip matrix ~(echelon)
    ] [
        matrix
    ] if ;

: echelon ( matrix -- matrix' )
    [ 0 0 (echelon)2 ] with-matrix ;

: ~echelon ( matrix -- matrix' )
    [ 0 0 ] dip ~(echelon) ;

: nonzero-rows ( matrix -- matrix' )
    [ [ zero? ] all? ] reject ;

: null/rank ( matrix -- null rank )
    echelon dup length swap nonzero-rows length [ - ] keep ;

: ~null/rank ( matrix -- null rank )
    ~echelon dup length swap nonzero-rows length [ - ] keep ;

: leading ( seq -- n elt ) [ zero? not ] find ;

: reduced ( matrix' -- matrix'' )
    [
        rows <iota> <reversed> [
            dup nth-row leading drop
            [ swap dup <iota> clear-col2 ] [ drop ] if*
        ] each
    ] with-matrix ; deprecated

:: ~reduced ( matrix' -- matrix'' )
    matrix' ~count-rows <iota> <reversed> [
        dup matrix' ~nth-row leading drop
        [ swap dup <iota> matrix ~clear-col ] [ drop ] if*
    ] each matrix ;

:: basis-vector ( row col# -- )
    row clone :> row'
    col# row' nth neg recip :> a
    0 col# row' set-nth
    a row n*v col# matrix get set-nth ; deprecated

! don't mutate the input blease
:: ~basis-vector ( row col# matrix -- )
    row clone :> row'
    col# row' nth neg recip :> a
    0 col# row' set-nth
    a row n*v col# matrix set-nth ;

: nullspace ( matrix -- seq )
    echelon reduced dup empty? [
        dup first length <identity-matrix> [
            [
                dup leading drop
                [ basis-vector ] [ drop ] if*
            ] each
        ] with-matrix flip nonzero-rows
    ] unless ; deprecated

:: ~nullspace ( matrix -- seq )
    matrix ~echelon ~reduced dup empty? [
        dup ~count-cols <identity-matrix>
            [
                dup leading drop
                [ matrix ~basis-vector ] [ drop ] if*
            ] each
        flip nonzero-rows
    ] unless ;

: 1-pivots ( matrix -- matrix )
    [ dup leading nip [ recip v*n ] when* ] map ;

: solution ( matrix -- matrix )
    echelon nonzero-rows reduced 1-pivots ; deprecated

: ~solution ( matrix -- matrix )
    ~echelon nonzero-rows ~reduced 1-pivots ;

: inverse ( matrix -- matrix ) ! Assumes an invertible matrix
    dup length
    [ <identity-matrix> [ append ] 2map solution ] keep
    [ tail ] curry map ; deprecated

: ~inverse ( matrix -- matrix ) ! Assumes an invertible matrix
    dup length
    [ <identity-matrix> [ append ] 2map ~solution ] keep
    [ tail ] curry map ;
