! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, Cat Stevens.
USING: accessors arrays assocs generic.single formatting locals help.markup help.markup.private help.syntax io
kernel math math.functions math.order math.ratios math.vectors opengl.gl prettyprint
sequences sequences.generalizations random urls ;
IN: math.matrices

<PRIVATE
! like $subsections but skip the extra blank line
: $subs-nobl ( children -- )
    [ $subsection* ] each ;

! swapped and n-matrix variants
: $equiv-word-note ( children -- )
    [ "This word is the " ] dip
    first2
    " variant of " swap
    [ { $link } ] dip suffix
    "."
    5 narray print-element ;

! words like <scale-matrix3> which have an array of inputs
: $finite-input-note ( children -- )
    [ "Only the first " ] dip
    first2
    " values in " swap
    [ { $snippet } ] dip suffix
    " are used."
    5 narray print-element ;

! a note for when a word assumes a 2d matrix
: $2d-only-note ( children -- )
    drop { "This word is intended for use with \"flat\" (2-dimensional) matrices. "
      ! "Using it with matrices of 3 or more dimensions may lead to unexpected results."
    }
    print-element ;

! a note for numeric-specific operations
: $matrix-scalar-note ( children -- )
    \ $subs-nobl prefix
    "This word assumes that elements of the input matrix are compatible with the following words:"
    swap 2array
    print-element ;

: $keep-shape-note ( children -- )
    drop { "The shape of the input matrix is preserved in the output." } print-element ;

: $link2 ( children -- )
    first2 swap [ write-link ] topic-span ;

! so that we don't end up with multiple $notes calls leading to multiple Notes sections
: $notelist ( children -- )
    \ $list prefix $notes ;
PRIVATE>

ABOUT: "math.matrices"

ARTICLE: "math.matrices" "Matrix operations"
"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with " { $emphasis "matrices" } " — sequences which have a minimum of 2 dimensions. Operations on 1-dimensional numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"In this vocabulary's documentation, " { $snippet "m" } " and " { $snippet "matrix" } " are the conventional names used for a given matrix object. " { $snippet "m" } " may refer to a number."
$nl
"Matrices are classified their mathematical properties, and by predicate words:"
$nl
! split up intentionally
{ $subsections
    matrix
    square-matrix
    zero-matrix
    zero-square-matrix
    null-matrix

} { $subsections
    well-formed-matrix?
    matrix?
    square-matrix?
    zero-matrix?
    zero-square-matrix?
    null-matrix?

} { $subsections
    invertible-matrix?
    linearly-independent-matrix?
}

"There are many ways to create 2-dimensional matrices:"
{ $subsections
    <matrix>
    <matrix-by>
    <matrix-by-indices>

} { $subsections
    <random-integer-matrix>
    <random-unit-matrix>
    <zero-matrix>
    <zero-square-matrix>
    <diagonal-matrix>
    <anti-diagonal-matrix>
    <identity-matrix>
    <simple-eye>
    <eye>

} { $subsections
    <coordinate-matrix>
    <square-rows>
    <square-cols>
    <upper-matrix>
    <lower-matrix>
    <cartesian-square-indices>
}

"These constructions have special mathematical properties:"
{ $subsections
    <box-matrix>
    <hankel-matrix>
    <hilbert-matrix>
    <toeplitz-matrix>
    <vandermonde-matrix>
}

"Common transformation matrices:"
{ $subsections
    <frustum-matrix4>
    <ortho-matrix4>
    <rotation-matrix3>
    <rotation-matrix4>
    <scale-matrix3>
    <scale-matrix4>
    <skew-matrix4>
    <translation-matrix4>
}

"By-element mathematical operations on a matrix:"
{ $subsections mneg m+n m-n m*n m/n m^n n+m n-m n*m n/m n^m }

"By-element mathematical operations of two matricess:"
{ $subsections m+ m- m* m/ m~ }

"Dot product (multiplication) of vectors and matrices:"
{ $subsections vdotm mdotv mdot }

"Transformations and elements of matrices:"
{ $subsections
    dim transpose
    matrix-nth matrix-nths matrix-set-nth matrix-set-nths

} { $subsections
    row rows rows-except
    col cols cols-except

} { $subsections
    matrix-except matrix-except-all

} { $subsections
    matrix-map column-map row-map stitch

} { $subsections
    cartesian-matrix-map
    cartesian-column-map
    cartesian-row-map
}

"Common algorithms on matrices:"
{ $subsections
    gram-schmidt
    gram-schmidt-normalize
    kronecker-product
    outer-product
}

"Matrix algebra:"
{ $subsections
    mmin
    mmax
    mnorm
    rank
    nullity

} { $subsections
    main-diagonal
    anti-diagonal

} { $subsections
    determinant 1/det m*1/det
    >minors >cofactors
    additive-inverse
    multiplicative-inverse
}

"Covariance in matrices:"
{ $subsections
    covariance-matrix
    covariance-matrix-ddof
    sample-covariance-matrix
}

"Errors thrown by this vocabulary:"
{ $subsections negative-power-matrix non-square-determinant undefined-inverse }
;

! PREDICATE CLASSES

HELP: matrix
{ $class-description "The class of matrices. In mathematics and linear algebra, a matrix is a collection of scalar elements for the purpose of the uniform application of algorithms." }
{ $notes "In Factor, any sequence with two or more dimensions can be a " { $link matrix } ", and the elements may be any " { $link object } "."
$nl "A well-formed matrix is a sequence with more than one dimension, whose rows are all of equal length. See " { $link well-formed-matrix? } "." } ;

HELP: square-matrix
{ $class-description "The class of square matrices. A square matrix is a " { $link matrix } " which has the same number of rows and columns." } ;

HELP: zero-matrix
{ $class-description "The class of zero matrices. A zero matrix is a matrix whose only elements are the scalar " { $snippet "0" } "." }
{ $notes "In mathematics, a zero-filled matrix is called a null matrix. In Factor, a "{ $link null-matrix } " is an empty matrix." } ;

HELP: zero-square-matrix
{ $class-description "The class of square zero matrices. This predicate is a composition of " { $link zero-matrix } " and " { $link square-matrix } "." } ;

HELP: null-matrix
{ $class-description "The class of null matrices. A null matrix is an empty sequence, or a sequence which consists only of empty sequences." }
{ $notes "In mathematics, a null matrix is a matrix full of zeroes. In Factor, such a matrix is called a " { $link zero-matrix } "." } ;

! NON-PREDICATE TESTS

HELP: well-formed-matrix?
{ $values { "object" object } { "?" boolean } }
{ $description "Tests if the object is a well-formed " { $link matrix } ". A well-formed matrix is a sequence, which has an equal number of elements in every row, and an equal number of elements in every column, such that there are no empty slots." }
{ $notes "The " { $link null-matrix } " is considered well-formed, because of semantic requirements of the matrix implementation." }
{ $examples
    "The example is a poorly formed matrix, because the rows have an unequal number of elements."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 } { } } well-formed-matrix? ."
        "f"
    }
    "The example is a well formed matrix, because the rows have an equal number of elements."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 } { 2 } } well-formed-matrix? ."
        "t"
    }
} ;

HELP: invertible-matrix?
{ $values { "matrix" matrix } { "?" boolean } }
{ $description "Tests whether the input matrix has a " { $link multiplicative-inverse } ". In order for a matrix to be invertible, it must be a " { $link square-matrix } ", " { $emphasis "or" } ", if it is non-square, it must not be of " { $link +deficient-rank+ } "." }
{ $examples { $example "USING: math.matrices prettyprint ;" "" } } ;

HELP: linearly-independent-matrix?
{ $values { "matrix" matrix } { "?" boolean } }
{ $description "Tests whether the input matrix is linearly independent." }
{ $examples { $example "USING: math.matrices prettyprint ;" "" } } ;

! SINGLETON RANK TYPES
HELP: rank-kind
{ $class-description "The class of matrix rank quantifiers." } ;

HELP: +full-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of full rank." } ;
HELP: +half-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of half rank." } ;
HELP: +zero-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of zero rank." } ;
HELP: +deficient-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of deficient rank." } ;
HELP: +uncalculated-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix whose rank is not (yet) known." } ;

! ERRORS

HELP: negative-power-matrix
{ $values { "m" matrix } { "n" integer } }
{ $description "Throws a " { $link negative-power-matrix } " error." }
{ $error-description "Given the semantics of " { $link m^n } ", negative exponents are not within the domain of the power matrix function." } ;

HELP: non-square-determinant
{ $values { "m" integer } { "n" integer } }
{ $description "Throws a " { $link non-square-determinant } " error." }
{ $error-description { $link determinant } " was used with a non-square matrix whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the determinant of a non-square matrix." } ;

HELP: undefined-inverse
{ $values { "m" integer } { "n" integer } { "r" rank-kind } }
{ $description "Throws an " { $link undefined-inverse } " error." }
{ $error-description { $link multiplicative-inverse } " was used with a non-square matrix of rank " { $snippet "rank" } " whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the inverse of a " { $link +deficient-rank+ } " non-square " { $link matrix } "." } ;

! BUILDERS
HELP: <matrix>
{ $values { "m" integer } { "n" integer } { "element" object } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with " { $snippet "element" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 2 10 <matrix> ."
        "{ { 10 10 } { 10 10 } { 10 10 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "4 1 \"¢\" <matrix> ."
        "{ { \"¢\" } { \"¢\" } { \"¢\" } { \"¢\" } }"
    }
} ;

HELP: <matrix-by>
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... -- elt ) } } }
{ $description "Creates a matrix of size " { $snippet "m x n" } " using elements given by " { $snippet "quot" } ", a quotation called to create each element."  }
{ $notes "The following are equivalent:"
  { $code "m n [ 2drop foo ] <matrix-by-indices>" }
  { $code "m n [ foo ] <matrix-by>" }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 5 [ 5 ] <matrix-by> ."
        "{ { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } { 5 5 5 5 5 } }"
    }
} ;

HELP: <matrix-by-indices>
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... m' n' -- ... elt ) } } { "matrix" matrix } }
{ $description "Creates an " { $snippet "m x n" } " " { $link matrix } " using elements given by " { $snippet "quot" } " . This word differs from " { $link <matrix-by> } " in that the indices are placed on the stack (in the same order) before " { $snippet "quot" } " runs. The output of the quotation will be the element at the given position in the matrix." }
{ $notes "The following are equivalent:"
  { $code "m n [ 2drop foo ] <matrix-by-indices>" }
  { $code "m n [ foo ] <matrix-by>" }
}
{ $examples
    { $example
        "USING: math math.matrices prettyprint ;"
        "3 4 [ * ] <matrix-by-indices> ."
        "{ { 0 0 0 0 } { 0 1 2 3 } { 0 2 4 6 } }"
    }
} ;

HELP: <random-integer-matrix>
{ $values { "m" integer } { "n" integer } { "max" integer } { "matrix" matrix } }
{ $description "Creates a " { $snippet "m x n" } " " { $link matrix } " full of random, possibly signed " { $link integer } "s whose absolute values are less than or equal to " { $snippet "max" } ", as given by " { $link random-integers } "." }
{ $notelist
    { "The signedness of the numbers in the resulting matrix will be randomized. Use " { $link mabs } " with this word to generate a matrix of random positive integers." }
    { $equiv-word-note "integral" <random-unit-matrix> }
}
{ $errors { $link no-method } " if " { $snippet "max"} " is not an " { $link integer } "." }
{ $examples
    { $unchecked-example
        "USING: math.matrices prettyprint ;"
        "2 4 15 <random-integer-matrix> ."
        "{ { -9 -9 1 3 } { -14 -8 14 10 } }"
    }
} ;

HELP: <random-unit-matrix>
{ $values { "m" integer } { "n" integer } { "max" number } { "matrix" matrix } }
{ $description "Creates a " { $snippet "m x n" } " " { $link matrix } " full of random, possibly signed " { $link float } "s  as a fraction of " { $snippet "max" } "." }
{ $notelist
    { "The signedness of the numbers in the resulting matrix will be randomized. Use " { $link mabs } " with this word to generate a matrix of random positive numbers." }
    { $equiv-word-note "real" <random-integer-matrix> }
    { "This word is implemented by generating sub-integral floats through " { $link random-units } " and multiplying by random integers less than or equal to " { $snippet "max" } "." }
}
{ $examples
    { $unchecked-example
        "USING: math.matrices prettyprint ;"
        "4 2 15 <random-unit-matrix> ."
"{
    { -3.713295909201797 3.815787135075961 }
    { -2.460506890603817 1.535222788710546 }
    { 3.692213981267878 -1.462963244399762 }
    { 13.8967592095433 -6.688509969360172 }
}"
    }
} ;

HELP: <zero-matrix>
{ $values { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 3 <zero-matrix> ."
        "{ { 0 0 0 } { 0 0 0 } }"
    }
} ;

HELP: <zero-square-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "Creates a matrix of size " { $snippet "n x n" } ", filled with zeroes. Shorthand for " { $code "n n <zero-matrix>" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 <zero-square-matrix> ."
        "{ { 0 0 } { 0 0 } }"
    }
} ;

HELP: <diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" matrix } }
{ $description "Creates a matrix with the specified main diagonal. This word has the opposite effect of " { $link anti-diagonal } "." }
{ $notes "To use a diagonal starting in the lower right, reverse the input sequence before calling this word." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 2 3 } <diagonal-matrix> ."
        "{ { 1 0 0 } { 0 2 0 } { 0 0 3 } }"
    }
} ;

HELP: <anti-diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" matrix } }
{ $description "Creates a matrix with the specified anti-diagonal. This word has the opposite effect of " { $link main-diagonal } "." }
{ $notes "To use a diagonal starting in the lower left, reverse the input sequence before calling this word." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 2 3 } <anti-diagonal-matrix> ."
        "{ { 0 0 1 } { 0 2 0 } { 3 0 0 } }"
    }
} ;

HELP: <identity-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "Creates an " { $url URL" http://enwp.org/Identity_matrix" "identity matrix" } " of size " { $snippet "n x n" } ", where the diagonal values are all ones." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 <identity-matrix> ."
        "{ { 1 0 0 0 } { 0 1 0 0 } { 0 0 1 0 } { 0 0 0 1 } }"
    }
} ;

HELP: <eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "z" object } { "matrix" matrix } }
{ $description "Creates an " { $snippet "m x n" } " matrix with a diagonal of " { $snippet "z" } " offset by " { $snippet "k" } " from the main diagonal. A positive value of " { $snippet "k" } " gives a diagonal above the main diagonal, whereas a negative value of " { $snippet "k" } " gives a diagonal below the main diagonal." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "5 6 0 4 <eye> ."
        "{
    { 4 0 0 0 0 0 }
    { 0 4 0 0 0 0 }
    { 0 0 4 0 0 0 }
    { 0 0 0 4 0 0 }
    { 0 0 0 0 4 0 }
}"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "5 5 2 2 <eye> ."
        "{
    { 0 0 2 0 0 }
    { 0 0 0 2 0 }
    { 0 0 0 0 2 }
    { 0 0 0 0 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: <simple-eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "matrix" matrix } }
{ $description
    "Creates an " { $snippet "m x n" } " matrix with a diagonal of ones offset by " { $snippet "k" } " from the main diagonal."
    "The following are equivalent for any " { $snippet "m n k" } ":" { $code "m n k 1 <eye>" } { $code "m n k <simple-eye>" }
    $nl
    "Specify a different diagonal value with " { $link <eye> } "."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 5 2 <simple-eye> ."
        "{ { 0 0 1 0 0 } { 0 0 0 1 0 } { 0 0 0 0 1 } { 0 0 0 0 0 } }"
    }
} ;

HELP: <coordinate-matrix>
{ $values { "dim" pair } { "coordinates" matrix } }
{ $description "Create a matrix in which each element is its own coordinate pair, also called a " { $link cartesian-product } "." }
{ $notelist
    { $equiv-word-note "non-square" <cartesian-square-indices> }
    { $finite-input-note "two" "dim" }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 4 } <coordinate-matrix> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
}"
    }
} ;

HELP: <cartesian-indices>
{ $values { "dim" pair } { "coordinates" matrix } }
{ $description "An alias for " { $link <coordinate-matrix> } " which serves as the logical non-square companion to " { $link <cartesian-square-indices> } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 4 } <cartesian-indices> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } { 0 3 } }
    { { 1 0 } { 1 1 } { 1 2 } { 1 3 } }
}"
    }
} ;

HELP: <cartesian-square-indices>
{ $values { "n" integer } { "matrix" square-matrix } }
{ $description "Create a " { $link square-matrix } " full of " { $link cartesian-product } "s. See " { $url URL" https://en.wikipedia.org/wiki/Cartesian_product" "cartesian product" } "." }
{ $notes
    { $equiv-word-note "square" <cartesian-indices> }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 <cartesian-square-indices> ."
        "{ { { 0 0 } } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <cartesian-square-indices> ."
"{
    { { 0 0 } { 0 1 } { 0 2 } }
    { { 1 0 } { 1 1 } { 1 2 } }
    { { 2 0 } { 2 1 } { 2 2 } }
}"
    }
} ;

HELP: <square-rows>
{ $values { "desc" { $or sequence integer matrix } } { "matrix" matrix } }
{ $contract "Generate a " { $link square-matrix } " from a descriptor." }
{ $description "If the descriptor is an " { $link integer } ", it is used to generate square rows within that range." $nl "If it is a 1-dimensional sequence, it is " { $link replicate } "d to create each row." $nl "If it is a " { $link matrix } ", it is cropped into a " { $link square-matrix } "." $nl "If it is a " { $link square-matrix } ", it is returned unchanged." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <square-rows> ."
        "{ { 0 1 2 } { 0 1 2 } { 0 1 2 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 3 5 } <square-rows> ."
        "{ { 2 3 5 } { 2 3 5 } { 2 3 5 } }"
    }
} ;

HELP: <square-cols>
{ $values { "desc" { $or sequence integer matrix } } { "matrix" matrix } }
{ $contract "Generate a " { $link square-matrix } " from a descriptor." }
{ $description "If the descriptor is an " { $link integer } ", it is used to generate square columns within that range." $nl "If it is a 1-dimensional sequence, it is " { $link replicate } "d to create each column." $nl "If it is a " { $link matrix } ", it is cropped into a " { $link square-matrix } "." $nl "If it is a " { $link square-matrix } ", it is returned unchanged." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <square-cols> ."
        "{ { 0 0 0 } { 1 1 1 } { 2 2 2 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 3 5 } <square-cols> ."
        "{ { 2 2 2 } { 3 3 3 } { 5 5 5 } }"
    }
} ;

HELP: <lower-matrix>
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Make a lower triangular matrix, where all the values above the main diagonal are " { $snippet "0" } ". " { $snippet "object" } " will be used as the value for the nonzero part of the matrix, while " { $snippet "m" } " and " { $snippet "n" } " are used as the dimensions. The inverse of this word is " { $link <upper-matrix> } ". See " { $url URL" https://en.wikipedia.org/wiki/Triangular_matrix" "triangular matrix" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 5 5 <lower-matrix> ."
"{
    { 1 0 0 0 0 }
    { 1 1 0 0 0 }
    { 1 1 1 0 0 }
    { 1 1 1 1 0 }
    { 1 1 1 1 1 }
}"
    }
} ;

HELP: <upper-matrix>
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description "Make an upper triangular matrix, where all the values below the main diagonal are " { $snippet "0" } ". " { $snippet "object" } " will be used as the value for the nonzero part of the matrix, while " { $snippet "m" } " and " { $snippet "n" } " are used as the dimensions. The inverse of this word is " { $link <lower-matrix> } ". See " { $url URL" https://en.wikipedia.org/wiki/Triangular_matrix" "triangular matrix" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 5 5 <upper-matrix> ."
"{
    { 1 1 1 1 1 }
    { 0 1 1 1 1 }
    { 0 0 1 1 1 }
    { 0 0 0 1 1 }
    { 0 0 0 0 1 }
}"
    }
} ;

HELP: <hankel-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description
    "A Hankel matrix is a symmetric, " { $link square-matrix } " in which each ascending skew-diagonal from left to right is constant. See " { $url URL" https://en.wikipedia.org/wiki/Hankel_matrix" "hankel matrix" } "."
    $nl
    "The following is true of any Hankel matrix" { $snippet "A" } ": " { $snippet "A[i][j] = A[j][i] = a[i+j-2]" } "."
    $nl
    "The " { $link <toeplitz-matrix> } " is an upside-down Hankel matrix."
    $nl
    "The " { $link <hilbert-matrix> } " is a special case of the Hankel matrix."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 <hankel-matrix> ."
        "{ { 1 2 3 4 } { 2 3 4 0 } { 3 4 0 0 } { 4 0 0 0 } }"
    }
} ;

HELP: <hilbert-matrix>
{ $values { "m" integer } { "n" integer } { "matrix" matrix } }
{ $description
    "A Hilbert matrix is a " { $link square-matrix } " " { $snippet "A" } " in which entries are the unit fractions "
    { $snippet "A[i][j] = 1/(i+j-1)" }
    ". See " { $url URL" https://en.wikipedia.org/wiki/Hilbert_matrix" "hilbert matrix" } "."
    $nl
    "A Hilbert matrix is a special case of the " { $link <hankel-matrix> } "."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "1 2 <hilbert-matrix> ."
        "{ { 1 1/2 } }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "3 6 <hilbert-matrix> ."
"{
    { 1 1/2 1/3 1/4 1/5 1/6 }
    { 1/2 1/3 1/4 1/5 1/6 1/7 }
    { 1/3 1/4 1/5 1/6 1/7 1/8 }
}"
    }
} ;

HELP: <toeplitz-matrix>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "A Toeplitz matrix is an upside-down " { $link <hankel-matrix> } ". Unlike the Hankel matrix, a Toeplitz matrix can be non-square. See " { $url URL" https://en.wikipedia.org/wiki/Hankel_matrix" "hankel matrix" } "."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 <toeplitz-matrix> ."
        "{ { 1 2 3 4 } { 2 1 2 3 } { 3 2 1 2 } { 4 3 2 1 } }"
    }
} ;

HELP: <box-matrix>
{ $values { "r" integer } { "matrix" matrix } }
{ $description "Create a box matrix (a " { $link square-matrix } ") with the dimensions of " { $snippet "r x r" } ", filled with ones. The number of elements in the output scales linearly (" { $snippet "(r*2)+1" } ") with " { $snippet "r" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 <box-matrix> ."
"{
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
    { 1 1 1 1 1 }
}"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "3 <box-matrix> ."
"{
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
    { 1 1 1 1 1 1 1 }
}"
    }

} ;

HELP: <scale-matrix3>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Make a " { $snippet "3 x 3" } " scaling matrix, used to scale an object in 3 dimensions. See " { $url URL" https://en.wikipedia.org/wiki/Scaling_(geometry)#Matrix_representation" "scaling matrix on Wikipedia" } "." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "3-matrix" <scale-matrix4> }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ 22 33 -44 } <scale-matrix4> ."
"{
    { 22 0.0 0.0 0.0 }
    { 0.0 33 0.0 0.0 }
    { 0.0 0.0 -44 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <scale-matrix4>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " scaling matrix, used to scale an object in 3 or more dimensions. See " { $url URL" https://en.wikipedia.org/wiki/Scaling_(geometry)#Matrix_representation" "scaling matrix on Wikipedia" } "." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "4-matrix" <scale-matrix3> }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ 22 33 -44 } <scale-matrix4> ."
"{
    { 22 0.0 0.0 0.0 }
    { 0.0 33 0.0 0.0 }
    { 0.0 0.0 -44 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <ortho-matrix4>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Create a " { $link <scale-matrix4> } ", with the scale factors inverted." }
{ $notelist
    { $finite-input-note "three" "factors" }
    { $equiv-word-note "inverse" <scale-matrix4> }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ -9.3 100 1/2 } <ortho-matrix4> ."
"{
    { -0.1075268817204301 0.0 0.0 0.0 }
    { 0.0 1/100 0.0 0.0 }
    { 0.0 0.0 2 0.0 }
    { 0.0 0.0 0.0 1.0 }
}"
    }
} ;

HELP: <frustum-matrix4>
{ $values { "xy-dim" pair } { "near" number } { "far" number } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " matrix suitable for representing an occlusion frustum. A viewing or occlusion frustum is the three-dimensional region of a three-dimensional object which is visible on the screen. See " { $url URL" https://en.wikipedia.org/wiki/Frustum" "frustum on Wikipedia" } "." }
{ $notes { $finite-input-note "two" "xy-dim" } }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ 5 4 } 5 6 <frustum-matrix4> ."
"{
    { 1.0 0.0 0.0 0.0 }
    { 0.0 1.25 0.0 0.0 }
    { 0.0 0.0 -11.0 -60.0 }
    { 0.0 0.0 -1.0 0.0 }
}"
    }
} ;
{ <frustum-matrix4> glFrustum } related-words

HELP: stitch
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Folds an " { $snippet "n>2" } "-dimensional matrix onto itself." }
{ $examples
    { $unchecked-example
        "USING: math.matrices prettyprint ;"
"{
    { { 0 5 } { 6 7 } { 0 15 } { 18 21 } }
    { { 0 10 } { 12 14 } { 0 20 } { 24 28 } }
} stitch ."
"{
    { 0 5 0 10 }
    { 6 7 12 14 }
    { 0 15 0 20 }
    { 18 21 24 28 }
}"
    }
} ;

HELP: row
{ $values { "n" integer } { "matrix" matrix } { "row" sequence } }
{ $description "Get the nth row of the matrix." }
{ $notes "Like most Factor sequences, indexing is 0-based. The first row is given by " { $snippet "m 0 row" } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } 1 swap row ."
        "{ 3 4 }"
    }
} ;

HELP: rows
{ $values { "seq" sequence } { "matrix" matrix } { "rows" sequence } }
{ $description "Get the rows from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $notelist { $equiv-word-note "multiplexing" row } }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } rows ."
        "{ { 1 2 } { 3 4 } }"
    }
} ;

HELP: col
{ $values { "n" integer } { "matrix" matrix } { "col" sequence } }
{ $description "Get the " { $snippet "n" } "th column of the matrix." }
{ $notes "Like most Factor sequences, indexing is 0-based. The first column is given by " { $snippet "m 0 col" } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } 1 swap col ."
        "{ 2 4 }"
    }
} ;

HELP: cols
{ $values { "seq" sequence } { "matrix" matrix } { "cols" sequence } }
{ $description "Get the columns from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } cols ."
        "{ { 1 3 } { 2 4 } }"
    }
} ;

HELP: matrix-map
{ $values { "quot" { $quotation ( ... elt -- ... elt' ) } } { "matrix" matrix } { "matrix'" matrix } }
{ $description "Apply the quotation to every element of the matrix." }
{ $notelist $2d-only-note }
{ $examples
    { $example
        "USING: math.matrices kernel math prettyprint ;"
        "3 <identity-matrix> [ zero? 15 -8 ? ] matrix-map ."
        "{ { -8 15 15 } { 15 -8 15 } { 15 15 -8 } }"
    }
} ;

HELP: column-map
{ $values { "quot" { $quotation ( ... col -- ... col' ) } } { "matrix" matrix } { "matrix'" { $maybe sequence matrix } } }
{ $description "Apply the quotation to every column of the matrix. The output of the quotation must be a sequence." }
{ $notelist $2d-only-note { $equiv-word-note "transpose" row-map } }
{ $examples
    { $example
        "USING: sequences math.matrices prettyprint ;"
        "3 <identity-matrix> [ reverse ] column-map ."
        "{ { 0 0 1 } { 0 1 0 } { 1 0 0 } }"
    }
} ;

HELP: row-map
{ $values { "quot" { $quotation ( ... col -- ... col' ) } } { "matrix" matrix } { "matrix'" { $maybe sequence matrix } } }
{ $description "Apply the quotation to every row of the matrix. The output of the quotation must be a sequence." }
{ $notelist $2d-only-note { $equiv-word-note "transpose" column-map } { $equiv-word-note "aliased" map } }
{ $examples
    { $example
        "USING: sequences math.matrices prettyprint ;"
        "3 <identity-matrix> [ reverse ] row-map ."
        "{ { 0 0 1 } { 0 1 0 } { 1 0 0 } }"
    }
} ;

HELP: cartesian-matrix-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... pair elt -- ... elt' ) } } { "matrix'" matrix } }
{ $notelist { $equiv-word-note "orthogonal" cartesian-column-map } { $equiv-word-note "two-dimensional" map-index } $2d-only-note }
;

HELP: cartesian-column-map
{ $values { "matrix" matrix } { "quot" { $quotation ( ... pair elt -- ... elt' ) } } { "matrix'" matrix } }
{ $notelist { $equiv-word-note "orthogonal" cartesian-matrix-map } $2d-only-note }
;

HELP: matrix-nth
{ $values { "pair" pair } { "matrix" matrix } { "elt" object } }
{ $description "Retrieve the element in the matrix at the zero-indexed " { $snippet "row, column" } " pair." }
{ $notelist { $equiv-word-note "two-dimensional" nth } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element in " { $snippet "pair" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element in " { $snippet "pair" } " is greater than the maximum column index in " { $snippet "matrix" } }
} }
{ $examples
    "Get the entry at row 1, column 0."
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 0 } { { 0 1 } { 2 3 } } matrix-nth ."
        "2"
    }
} ;

HELP: matrix-nths
{ $values { "pairs" assoc } { "matrix" matrix } { "elts" sequence } }
{ $description "Retrieve all the elements in the matrix at each of the zero-indexed " { $snippet "row, column" } " pairs in " { $snippet "pairs" } "." }
{ $notelist { $equiv-word-note "two-dimensional" nths } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
} }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 0 } { 1 1 } } { { 0 1 } { 2 3 } } matrix-nths ."
        "{ 2 3 }"
    }
} ;

HELP: matrix-set-nth
{ $values { "obj" object } { "pair" pair } { "matrix" matrix } }
{ $description "Set the element in the matrix at the 2D index given by " { $snippet "pair" } " to " { $snippet "obj" } ". This operation is destructive." }
{ $side-effects "matrix" }
{ $notelist { $equiv-word-note "two-dimensional" set-nth } $2d-only-note  }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
    "Throws an error if the sequence cannot hold elements of the given type."
} }
{ $examples
    "Change the entry at row 1, column 0."
    { $example
        "USING: math.matrices kernel prettyprint ;"
        "{ { 0 1 } { 2 3 } } \"a\" { 1 0 } pick matrix-set-nth ."
        "{ { 0 1 } { \"a\" 3 } }"
    }
} ;

HELP: matrix-set-nths
{ $values { "obj" object } { "pairs" assoc } { "matrix" matrix } }
{ $description "Applies " { $link matrix-set-nth } " to " { $snippet "matrix" } " for each " { $snippet "row, column" } " pair in " { $snippet "pairs" } ", setting the elements to " { $snippet "obj" } "." }
{ $side-effects "matrix" }
{ $notelist { $equiv-word-note "multiplexing" matrix-set-nth } $2d-only-note }
{ $errors { $list
    { { $link bounds-error } " if the first element of a pair in " { $snippet "pairs" } " is greater than the maximum row index in " { $snippet "matrix" } }
    { { $link bounds-error } " if the second element of a pair in " { $snippet "pairs" } " is greater than the maximum column index in " { $snippet "matrix" } }
    "Throws an error if the sequence cannot hold elements of the given type."
} }
{ $examples
    "Change both entries on row 0."
    { $example
        "USING: math.matrices kernel prettyprint ;"
        "{ { 0 1 } { 2 3 } } \"a\" { { 1 0 } { 1 1 } } pick matrix-set-nths ."
        "{ { 0 1 } { \"a\" \"a\" } }"
    }
} ;

HELP: additive-inverse
{ $values { "m" matrix } { "m'" matrix } }
{ $description "An alias for " { $link mneg } " which serves as the companion to " { $link multiplicative-inverse } "." }
{ $notelist $2d-only-note { $matrix-scalar-note neg } } ;

HELP: mneg
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Negate (invert the sign) of every element in the matrix." }
{ $notelist
    { $equiv-word-note "companion" mabs }
    $2d-only-note
    { $matrix-scalar-note neg }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 -17 } } mneg ."
        "{ { -5 -9 } { -15 17 } }"
    }
} ;

HELP: mabs
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Compute the absolute value (" { $link abs } ") of each element in the matrix." }
{ $notelist
    { $equiv-word-note "companion" mneg }
    $2d-only-note
    { $matrix-scalar-note abs }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { -5 -9 } { -15 17 } } mabs ."
        "{ { 5 9 } { 15 17 } }"
    }
} ;

HELP: n+m
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" m+n }
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "1 3 <identity-matrix> n+m ."
        "{ { 2 1 1 } { 1 2 1 } { 1 1 2 } }"
    }
} ;

HELP: m+n
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" n+m }
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 1 m+n ."
        "{ { 2 1 1 } { 1 2 1 } { 1 1 2 } }"
    }
} ;

HELP: n-m
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and subtracted from each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" m-n }
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "1 3 <identity-matrix> n-m ."
        "{ { 0 1 1 } { 1 0 1 } { 1 1 0 } }"
    }
} ;

HELP: m-n
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and subtracted from each element of the matrix " { $snippet "m" } "." }
{ $notelist
    { $equiv-word-note "swapped" n-m }
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 1 m-n ."
        "{ { 0 -1 -1 } { -1 0 -1 } { -1 -1 0 } }"
    }
} ;

HELP: n*m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar "{ $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" m*n }
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 3 <identity-matrix> n*m ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: m*n
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar "{ $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" n*m }
    $2d-only-note
    { $matrix-scalar-note * }
}

{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 3 m*n ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: n/m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar "{ $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" m/n }
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "2 2 <box-matrix> n/m ."
"{
    { 2 2 2 2 2 }
    { 2 2 2 2 2 }
    { 2 2 2 2 2 }
    { 2 2 2 2 2 }
    { 2 2 2 2 2 }
}"
    }
} ;

HELP: m/n
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar "{ $snippet "n" } "." }
{ $notelist
    $keep-shape-note
    { $equiv-word-note "swapped" n/m }
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "2 <box-matrix> 2 m/n ."
"{
    { 1/2 1/2 1/2 1/2 1/2 }
    { 1/2 1/2 1/2 1/2 1/2 }
    { 1/2 1/2 1/2 1/2 1/2 }
    { 1/2 1/2 1/2 1/2 1/2 }
    { 1/2 1/2 1/2 1/2 1/2 }
}"
    }
} ;

HELP: m+
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Adds two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 3 } { 3 2 1 } } { { 4 5 6 } { 6 5 4 } } m+ ."
        "{ { 5 7 9 } { 9 7 5 } }"
    }
} ;

HELP: m-
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Subtracts two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note - }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 4 5 6 } { 6 5 4 } } { { 1 2 3 } { 3 2 1 } } m- ."
        "{ { 3 3 3 } { 3 3 3 } }"
    }
} ;

HELP: m*
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Multiplies two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m* ."
        "{ { 15 18 } { 60 153 } }"
    }
} ;

HELP: m/
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Divides two matrices element-wise." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note / }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m/ ."
        "{ { 1+2/3 4+1/2 } { 3+3/4 1+8/9 } }"
    }
} ;

HELP: mdotv
{ $values { "m" matrix } { "v" sequence } { "p" matrix } }
{ $description "Computes the dot product of a matrix and a vector." }
{ $notelist
    { $equiv-word-note "swapped" vdotm }
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } mdotv ."
        "{ 1 -3 }"
    }
} ;

HELP: vdotm
{ $values { "m" matrix } { "v" sequence } { "p" matrix } }
{ $description "Computes the dot product of a vector and a matrix." }
{ $notelist
    { $equiv-word-note "swapped" mdotv }
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 1 0 } { { 1 -1 2 } { 0 -3 1 } } vdotm ."
        "{ 2 -5 5 }"
    }
} ;

HELP: mdot
{ $values { "m" matrix } }
{ $description "Computes the dot product of two matrices, i.e multiplies them." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note * + }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { { 3 7 } { 9 12 } } mdot ."
        "{ { -6 -5 } { -27 -36 } }"
    }
} ;

HELP: m~
{ $values { "m1" matrix } { "m2" matrix } { "epsilon" number } { "?" boolean } }
{ $description "Compares the matrices like " { $link ~ } ", using the " { $snippet "epsilon" } "." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note ~ }
}
{ $examples
    { "In the example, only " { $snippet ".01" } " was added to each element, so the new matrix is within the epsilon " { $snippet ".1" } "of the original." }
    { $example
        "USING: kernel math math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } dup [ .01 + ] matrix-map .1 m~ ."
        "t"
    }
} ;

HELP: mmin
{ $values { "m" matrix } { "n" object } }
{ $description "Determine the minimum value of the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note min }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmin ."
        "5"
    }
} ;

HELP: mmax
{ $values { "m" matrix } { "n" object } }
{ $description "Determine the maximum value of the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmax ."
        "17"
    }
} ;

HELP: mnorm
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Normalize a matrix. Each element from the input matrix is computed as a fraction of the maximum element. The maximum element becomes " { $snippet "1/1" } "." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mnorm ."
        "{ { 5/17 9/17 } { 15/17 1 } }"
    }
} ;

HELP: gram-schmidt
{ $values { "matrix" matrix } { "orthogonal" matrix } }
{ $description "Apply a Gram-Schmidt transform on the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } { 5 6 } } gram-schmidt ."
        "{ { 1 2 } { 4/5 -2/5 } { 0 0 } }"
    }
} ;

HELP: gram-schmidt-normalize
{ $values { "matrix" matrix } { "orthogonal" matrix } }
{ $description "Apply a Gram-Schmidt transform on the matrix, and " { $link normalize } " each row of the result." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } { 5 6 } } gram-schmidt-normalize ."
"{
    { 0.4472135954999579 0.8944271909999159 }
    { 0.894427190999916 -0.447213595499958 }
    { NAN: 8000000000000 NAN: 8000000000000 }
}"
    }
} ;

HELP: m^n
{ $values { "n" object } { "m" matrix } }
{ $description "Compute the " { $snippet "nth" } " power of the input matrix. If " { $snippet "n" } " is " { $snippet "-1" } ", the inverse of the matrix is calculated (but see " { $link multiplicative-inverse } " for pitfalls)." }
{ $errors
    { $link negative-power-matrix } " if " { $snippet "n" } " is a negative number other than " { $snippet "-1" } "."
    $nl
    { $link undefined-inverse } " if " { $snippet "n" } " is " { $snippet "-1" } " and the " { $link multiplicative-inverse } " of " { $snippet "m" } " is undefined."
}
{ $notelist
    { $equiv-word-note "swapped" n^m }
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } 2 m^n ."
        "{ { 7 10 } { 15 22 } }"
    }
} ;

HELP: n^m
{ $values { "n" object } { "m" matrix } }
{ $description "Because it is nonsensical to raise a number to the power of a matrix, this word exists to save typing " { $snippet "swap m^n" } ". See " { $link m^n } " for more information." }
{ $errors
    { $link negative-power-matrix } " if " { $snippet "n" } " is a negative number other than " { $snippet "-1" } "."
    $nl
    { $link undefined-inverse } " if " { $snippet "n" } " is " { $snippet "-1" } " and the " { $link multiplicative-inverse } " of " { $snippet "m" } " is undefined."
}
{ $notelist
    { $equiv-word-note "swapped" m^n }
    $2d-only-note
    { $matrix-scalar-note max abs / }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 { { 1 2 } { 3 4 } } n^m ."
        "{ { 7 10 } { 15 22 } }"
    }
} ;

HELP: kronecker-product
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices. This product can be described as a generalization of the vector-based " { $link outer-product } " to matrices. The Kronecker product gives the matrix of the tensor product with respect to a standard choice of basis." }
{ $notelist
    { $equiv-word-note "matrix" outer-product }
    $2d-only-note
    { $matrix-scalar-note * }
}
{ $examples
    { $unchecked-example
        "USING: math.matrices prettyprint ;"
"{
    { 1 2 }
    { 3 4 }
} {
    { 0 5 }
    { 6 7 }
} kronecker-product ."
"{
    { 0 5 0 10 }
    { 6 7 12 14 }
    { 0 15 0 20 }
    { 18 21 24 28 }
}" }
} ;

HELP: outer-product
{ $values { "u" sequence } { "v" sequence } { "matrix" matrix } }
{ $description "Computes the " { $url URL" http://  enwp.org/Outer_product" "outer-product product" } " of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer-product ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;

HELP: rank ;
HELP: nullity ;

HELP: >square-matrix
{ $values { "m" matrix } { "subset" square-matrix } }
{ $description "Find only the " { $link2 square-matrix "square" } " subset of the input matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 0 2 4 6 } { 1 3 5 7 } } >square-matrix ."
        "{ { 0 2 } { 1 3 } }"
    }
} ;

HELP: main-diagonal
{ $values { "matrix" matrix } { "seq" sequence } }
{ $description "Find the main diagonal of a matrix." $nl "This diagonal begins in the upper left of the matrix at index " { $snippet "{ 0 0 }" } ", continuing downward and rightward for all indices " { $snippet "{ n n }" } " in the " { $link square-matrix } " subset of the input (see " { $link <square-rows> } ")." }
{ $notelist
    { "If the number of rows in the square subset of the input is even, then this diagonal will not contain elements found in the " { $link anti-diagonal } ". However, if the size of the square subset is odd, then this diagonal will share at most one element with " { $link anti-diagonal } "." }
    { "This diagonal is sometimes called the " { $emphasis "first diagonal" } "." }
    { $equiv-word-note "opposite" anti-diagonal }
}
{ $examples
    { "The operation is simple on a " { $link square-matrix } ":" }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 7 2 11 }
    { 9 7 7 }
    { 1 8 0 }
} main-diagonal ."
        "{ 7 7 0 }"
    }
    "The square subset of the following input matrix consists of all rows but the last. The main diagonal does not include the last row because it has no fourth element."
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 6 5 0 }
    { 7 2 6 }
    { 4 3 9 }
    { 3 3 3 }
} main-diagonal ."
        "{ 6 2 9 }"
    }
} ;

HELP: anti-diagonal
{ $values { "matrix" matrix } { "seq" sequence } }
{ $description "Find the anti-diagonal of a matrix." $nl "This diagonal begins in the upper right of the matrix, continuing downward and leftward for all indices in the " { $link square-matrix } " subset of the input (see " { $link <square-rows> } ")." }
{ $notelist
    { "If the number of rows in the square subset of the input is even, then this diagonal will not contain elements found in the " { $link main-diagonal } ". However, if the size of the square subset is odd, then this diagonal will share at most one element with " { $link main-diagonal } "." }
    { "This diagonal is sometimes called the " { $emphasis "second diagonal" } "." }
    { $equiv-word-note "opposite" main-diagonal }
}
{ $examples
    { "The operation is simple on a " { $link square-matrix } ":" }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 7 2 11 }
    { 9 7 7 }
    { 1 8 0 }
} anti-diagonal ."
        "{ 11 7 1 }"
    }
    "The square subset of the following input matrix consists of all rows but the last. The anti-diagonal does not include the last row because it has no fourth element."
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 6 5 0 }
    { 7 2 6 }
    { 4 3 9 }
    { 3 3 3 }
} anti-diagonal ."
        "{ 0 2 4 }"
    }
} ;


HELP: transpose
{ $values { "matrix" matrix } { "newmatrix" matrix } }
{ $description "Transpose the input matrix over its " { $link main-diagonal } ". The main diagonal itself is left untouched, whereas the anti-diagonal is reversed." }
{ $notelist
    { "This word is an alias for " { $link flip } ", so that it may be recognised as the common mathematical operation." }
    { $equiv-word-note "opposite" anti-transpose }
}
{ $examples
    { $example
        "USING: math.matrices sequences prettyprint ;"
        "5 <iota> <anti-diagonal-matrix> transpose ."
"{
    { 0 0 0 0 4 }
    { 0 0 0 3 0 }
    { 0 0 2 0 0 }
    { 0 1 0 0 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: anti-transpose
{ $values { "matrix" matrix } { "newmatrix" matrix } }
{ $description "Like " { $link transpose } " except that the matrix is transposed over the " { $link anti-diagonal } "." }
{ $notes { $equiv-word-note "opposite" transpose } }
{ $examples
    { $example
        "USING: math.matrices sequences prettyprint ;"
        "5 <iota> <diagonal-matrix> anti-transpose ."
"{
    { 4 0 0 0 0 }
    { 0 3 0 0 0 }
    { 0 0 2 0 0 }
    { 0 0 0 1 0 }
    { 0 0 0 0 0 }
}"
    }
} ;

HELP: rows-except
{ $values { "matrix" matrix } { "desc" { $or integer sequence } } { "others" matrix } }
{ $contract "Get all the rows from " { $snippet "matrix" } " " { $emphasis "not" } " described by " { $snippet "desc" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 2 7 12 2 }
    { 8 9 10 0 }
    { 1 3 3 5 }
    { 8 13 7 12 }
} { 1 3 } rows-except ."
        "{ { 2 7 12 2 } { 1 3 3 5 } }"
    }
} ;

HELP: cols-except
{ $values { "matrix" matrix } { "desc" { $or integer sequence } } { "others" matrix } } ;
HELP: matrix-except
{ $values { "matrix" matrix } { "exclude-pair" pair } { "submatrix" matrix } } ;
HELP: matrix-except-all
{ $values { "matrix-seq" matrix } { "submatrix" matrix } } ;

HELP: determinant
{ $values { "matrix" square-matrix } { "determinant" number } }
{ $contract "Compute the determinant of the input matrix. Generally, the determinant of a matrix is a scaling factor of the transformation described by the matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note max - * }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    {  3  0 -1 }
    { -3  1  3 }
    {  2 -5  4 }
} determinant ."
        "44"
    }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { -8 -8 13 11 10 -5 -14 }
    { 3 -11 -8 3 -7 -3 4 }
    { 10 4 -5 3 0 -6 -12 }
    { -14 0 -3 -8 10 0 10 }
    { 3 -6 1 -10 -9 10 0 }
    { 5 -12 -14 6 5 -1 -7 }
    { -9 -14 -8 5 2 2 -2 }
} determinant ."
        "-103488155"
    }
} ;

HELP: 1/det
{ $values { "matrix" square-matrix } { "1/det" number } }
{ $description "Find the inverse (" { $link recip } ") of the " { $link determinant } " of the input matrix." }
{ $notelist
    $2d-only-note
    { $matrix-scalar-note determinant recip }
}
{ $errors
    { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "."
    $nl
    { $link division-by-zero } " if the " { $link determinant } " of the input matrix is " { $snippet "0" } "."
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 0 10 -12 4 }
    { -9 6 -11 9 }
    { -5 -10 0 2 }
    { -7 -11 10 11 }
} 1/det ."
        "-1/9086"
    }
} ;

HELP: m*1/det
{ $values { "matrix" square-matrix } { "matrix'" square-matrix } }
{ $description "Multiply the input matrix by the inverse (" { $link recip } ") of its " { $link determinant } "." }
{ $notelist
    { "This word is used to implement " { $link multiplicative-inverse } "." }
    $2d-only-note
    { $matrix-scalar-note determinant recip }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { -14 0 -13 7 }
    { -4 11 7 -12 }
    { -3 2 9 -14 }
    { 3 -5 10 -2 }
} m*1/det ."
"{
    { 7/6855 0 13/13710 -7/13710 }
    { 2/6855 -11/13710 -7/13710 2/2285 }
    { 1/4570 -1/6855 -3/4570 7/6855 }
    { -1/4570 1/2742 -1/1371 1/6855 }
}"
    }
}
;

HELP: >minors
{ $values { "matrix" square-matrix } { "matrix'" square-matrix } }
{ $description "Calculate the " { $emphasis "matrix of minors" } " of the input matrix. See " { $url URL" https://en.wikipedia.org/wiki/Minor_(linear_algebra)" "minor on Wikipedia" } "." }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note determinant }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { -8 0 7 -11 }
    { 15 0 -3 -11 }
    { 1 -10 -4 6 }
    { 11 -15 3 -15 }
} >minors ."
"{
    { 1710 -130 2555 -1635 }
    { -690 -286 -2965 1385 }
    { 1650 -754 3795 -1215 }
    { 1100 416 2530 -810 }
}"
    }
} ;

HELP: >cofactors
{ $values { "matrix" matrix } { "matrix'" matrix } }
{ $description "Calculate the " { $emphasis "matrix of cofactors" } " of the input matrix. See " { $url URL" https://en.wikipedia.org/wiki/Minor_(linear_algebra)#Inverse_of_a_matrix" "matrix of cofactors on Wikipedia" } ". Alternating elements of the input matrix have their signs inverted." $nl "On odd rows, the even elements have their signs inverted. On even rows, odd elements have their signs inverted." }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note neg }
}
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { 8 0 7 11 }
    { 15 0 3 11 }
    { 1 10 4 6 }
    { 11 15 3 15 }
} >cofactors ."
"{
    { 8 0 7 -11 }
    { -15 0 -3 11 }
    { 1 -10 4 -6 }
    { -11 15 -3 15 }
}"
    }
    { $example
        "USING: math.matrices prettyprint ;"
"{
    { -8 0 7 -11 }
    { 15 0 -3 -11 }
    { 1 -10 -4 6 }
    { 11 -15 3 -15 }
} >cofactors ."
"{
    { -8 0 7 11 }
    { -15 0 3 -11 }
    { 1 10 -4 -6 }
    { -11 -15 -3 -15 }
}"
    }
} ;

HELP: multiplicative-inverse
{ $values { "matrix" matrix } { "inverse" matrix } }
{ $description "Calculate the multiplicative inverse of the input." $nl "If the input is a " { $link square-matrix } ", this is done by multiplying the " { $link transpose } " of the " { $link2 >cofactors "cofactors" } " of the " { $link2 >minors "minors" } " of the input matrix by the " { $link2 1/det "inverse of the determinant" } " of the input matrix."  }
{ $notelist
    $keep-shape-note
    $2d-only-note
    { $matrix-scalar-note determinant >cofactors 1/det }
}
{ $errors { $link non-square-determinant } " if the input matrix is not a " { $link square-matrix } "." }
;

HELP: dim
{ $values { "matrix" matrix } { "dimensions" pair } }
{ $description "Find the dimensions of the input matrix, in the order of " { $snippet "{ rows cols }"} "." }
{ $notes $2d-only-note }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 30 1 <matrix> dim ."
        "{ 4 30 }"
    }
    { $example
        "USING: math.matrices prettyprint ;"
        "{ } dim ."
        "{ 0 0 }"
    }
} ;

HELP: covariance-matrix ;
HELP: covariance-matrix-ddof ;
HELP: sample-covariance-matrix ;
