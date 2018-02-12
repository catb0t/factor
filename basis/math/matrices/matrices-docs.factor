! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, Cat Stevens.
USING: arrays help.markup help.syntax kernel math opengl.gl sequences prettyprint urls ;
IN: math.matrices

ABOUT: "math.matrices"

ARTICLE: "math.matrices" "Matrix operations"
"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with " { $emphasis "matrices" } " — sequences which have a minimum of 2 dimensions. Operations on 1-dimensional numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"In this vocabulary's documentation, " { $snippet "m" } " and " { $snippet "matrix" } " are the conventional names used for a given matrix object. " { $snippet "m" } " may refer to a number."
$nl
"Matrices are classified their mathematical properties, and by predicate words."
$nl
{ $subsections
    matrix
    square-matrix
    zero-matrix
    zero-square-matrix
    null-matrix

    well-formed-matrix?
    matrix?
    square-matrix?
    zero-matrix?
    zero-square-matrix?
    null-matrix?

    invertible-matrix?
    linearly-independent-matrix?
}

"There are many ways to create 2-dimensional matrices:"
{ $subsections
    <matrix>
    <matrix-by>
    <matrix-by-indices>
    <zero-matrix>
    <zero-square-matrix>
    <diagonal-matrix>
    <anti-diagonal-matrix>
    <identity-matrix>
    <simple-eye>
    <eye>
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
{ $subsections v.m m.v m. }

"Transformations and elements of matrices:"
{ $subsections
    dim dimension-range transpose
    matrix-nth matrix-set-nth matrix-set-nths

    row rows rows-except
    col cols cols-except

    matrix-except matrix-except-all

    matrix-map column-map row-map
    stitch

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

    main-diagonal
    anti-diagonal

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
{ $subsections negative-power-matrix non-square-determinant non-square-inverse }
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
{ $description "Tests if the object is a well-formed " { $link matrix } ". A well-formed matrix has an equal number of elements in every row, and an equal number of elements in every column, such that there are no empty slots." }
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
HELP: +deficient-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix of deficient rank." } ;
HELP: +uncalculated-rank+
{ $class-description "A " { $link rank-kind } " describing a matrix whose rank is not known." } ;

! ERRORS

HELP: negative-power-matrix
{ $values { "m" matrix } { "n" integer } }
{ $description "Throws a " { $link negative-power-matrix } " error." }
{ $error-description "Given the semantics of " { $link m^n } ", negative exponents are not within the domain of the power matrix function." } ;

HELP: non-square-determinant
{ $values { "m" integer } { "n" integer } }
{ $description "Throws a " { $link non-square-determinant } " error." }
{ $error-description { $link determinant } " was used with a non-square matrix whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the determinant of a non-square matrix." } ;

HELP: non-square-inverse
{ $values { "m" integer } { "n" integer } { "r" "rank" } }
{ $description "Throws a " { $link non-square-inverse } " error." }
{ $error-description { $link multiplicative-inverse } " was used with a non-square matrix of rank " { $snippet "rank" } " whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the determinant of a rank-deficient non-square matrix." } ;

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
{ $description "Creates an " { $snippet "m x n" } " matrix using elements given by " { $snippet "quot" } " . This word differs from " { $link <matrix-by> } " in that the indices are placed on the stack (in the same order) before " { $snippet "quot" } " runs. The output of the quotation will be the element at the given position in the matrix." }
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

HELP: <cartesian-square-indices>
{ $values { "n" integer } { "matrix" matrix } }
{ $description "Create a square matrix full of cartesian products. See " { $url URL" https://en.wikipedia.org/wiki/Cartesian_product" "cartesian product" } "." }
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
{ $description "Create a box matrix (a " { $link square-matrix } ") with the dimensions of " { $snippet "r x r" } ", filled with ones. The number of elements in the output scales linearly (" { $snippet "(r*2)+1" } ") with the magnitude of " { $snippet "r" } "." }
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

HELP: <scale-matrix4>
{ $values { "factors" sequence } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " scaling matrix, used to scale an object in 3 or more dimensions. See " { $url URL" https://en.wikipedia.org/wiki/Scaling_(geometry)#Matrix_representation" "scaling matrix on Wikipedia" } "." }
{ $notes "Only the first three values in " { $snippet "factors" } " are used." }
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

HELP: <frustum-matrix4>
{ $values { "xy-dim" pair } { "near" number } { "far" number } { "matrix" matrix } }
{ $description "Make a " { $snippet "4 x 4" } " matrix suitable for representing an occlusion frustum. A viewing or occlusion frustum is the three-dimensional region of a three-dimensional object which is visible on the screen. See " { $url URL" https://en.wikipedia.org/wiki/Frustum" "frustum on Wikipedia" } "." }
{ $notes
    "Only the first two values from " { $snippet "xy-dim" } " are used."
    $nl
    "Though the domain is technically unlimited, for unexpected inputs the range may be undefined."
}
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

HELP: <ortho-matrix4>
{ $values { "dim" pair } { "matrix" matrix } }
{ $description "Create a " { $snippet "4 x 4" } " orthogonal matrix. Each element in " { $snippet "dim" } " is converted to its reciprocal (" { $link recip } "), and a " { $link <scale-matrix4> } " is created with the inverted sequence." }
{ $notes "Only the first three values from " { $snippet "dim" } " are used." }
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
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } rows ."
        "{ { 1 2 } { 3 4 } }"
    }
} ;

HELP: col
{ $values { "n" integer } { "matrix" matrix } { "col" sequence } }
{ $description "Get the nth column of the matrix." }
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

HELP: matrix-map ;
HELP: column-map ;
HELP: row-map ;
HELP: cartesian-matrix-map ;
HELP: cartesian-column-map ;
HELP: cartesian-row-map ;

HELP: matrix-nth ;
HELP: matrix-set-nth ;
HELP: matrix-set-nths ;

HELP: additive-inverse
{ $values { "m" matrix } { "m'" matrix } }
{ $description "An alias for " { $link mneg } " which serves as the companion to " { $link multiplicative-inverse } "." } ;

HELP: mneg
{ $values { "m" matrix } { "m'" matrix } }
{ $description "Negate (invert the sign) of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mneg ."
        "{ { -5 -9 } { -15 -17 } }"
    }
} ;

HELP: n+m
{ $values { "n" object } { "m" matrix }  }
{ $description { $snippet "n" } " is treated as a scalar and added to each element of the matrix " { $snippet "m" } "." }
{ $notes "This word is the swapped equivalent of " { $link m+n } "." }
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
{ $notes "This word is the swapped equivalent of " { $link n+m } "." }
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
{ $notes "This word is the swapped equivalent of " { $link m-n } "." }
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
{ $notes "This word is the swapped equivalent of " { $link n-m } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 1 m-n ."
        "{ { 0 -1 -1 } { -1 0 -1 } { -1 -1 0 } }"
    }
} ;

HELP: n*m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar "{ $snippet "n" } ". The output has the same shape as the input." }
{ $notes "This word is the swapped equivalent of " { $link m*n } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 3 <identity-matrix> n*m ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: m*n
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is multiplied by the scalar "{ $snippet "n" } ". The output has the same shape as the input." }
{ $notes "This word is the swapped equivalent of " { $link n*m } "." }
{ $examples
    { $example
        "USING: kernel math.matrices prettyprint ;"
        "3 <identity-matrix> 3 m*n ."
        "{ { 3 0 0 } { 0 3 0 } { 0 0 3 } }"
    }
} ;

HELP: n/m
{ $values { "n" object } { "m" matrix }  }
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar "{ $snippet "n" } ". The output has the same shape as the input." }
{ $notes "This word is the swapped equivalent of " { $link m/n } "." }
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
{ $description "Every element in the input matrix " { $snippet "m" } " is divided by the scalar "{ $snippet "n" } ". The output has the same shape as the input." }
{ $notes "This word is the swapped equivalent of " { $link n/m } "." }
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
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m/ ."
        "{ { 1+2/3 4+1/2 } { 3+3/4 1+8/9 } }"
    }
} ;

HELP: m.v
{ $values { "m" matrix } { "v" sequence } { "p" matrix } }
{ $description "Computes the dot product of a matrix and a vector." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } m.v ."
        "{ 1 -3 }"
    }
} ;

HELP: v.m
{ $values { "m" matrix } { "v" sequence } { "p" matrix } }
{ $description "Computes the dot product of a vector and a matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 1 0 } { { 1 -1 2 } { 0 -3 1 } } v.m ."
        "{ 2 -5 5 }"
    }
} ;

HELP: m.
{ $values { "m" matrix } }
{ $description "Computes the dot product of two matrices, i.e multiplies them." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { { 3 7 } { 9 12 } } m. ."
        "{ { -6 -5 } { -27 -36 } }"
    }
} ;

HELP: m~
{ $values { "m1" matrix } { "m2" matrix } { "epsilon" number } { "?" boolean } }
{ $description "Compares the matrices using the " { $snippet "epsilon" } "." }
{ $examples
    { $example
        "USING: kernel math math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } dup [ .01 + ] matrix-map .1 m~ ."
        "t"
    }
} ;

HELP: mmin
{ $values { "m" matrix } { "n" object } }
{ $description "Calculate the minimum value of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmin ."
        "5"
    }
} ;

HELP: mmax
{ $values { "m" matrix } { "n" object } }
{ $description "Calculate the maximum value of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmax ."
        "17"
    }
} ;

HELP: mnorm
{ $values { "m" matrix } { "m'" object } }
{ $description "Calculate the normal value of each element in the matrix. This makes the maximum value in the sequence " { $snippet "1/1" } ", and computes other elements as fractions of this maximum. The output is a matrix, containing each original element as a fraction of the maximum." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mnorm ."
        "{ { 5/17 9/17 } { 15/17 1 } }"
    }
} ;

HELP: gram-schmidt ;
HELP: gram-schmidt-normalize ;

HELP: kronecker-product
{ $values { "m1" matrix } { "m2" matrix } { "m" matrix } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kronecker-product ."
        "{ { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }" }
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

HELP: main-diagonal ;
HELP: anti-diagonal ;

HELP: transpose
{ $values { "matrix" matrix } { "newmatrix" matrix } }
{ $description "Transpose the input matrix over its " { $link main-diagonal } ". The main diagonal itself is left untouched, whereas the anti-diagonal is reversed." }
{ $notes "This word is an alias for " { $link flip } ", so that it may be recognised as the common mathematical operation." }
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
{ $examples
    { $examples
        "USING: math.matrices sequences prettyprint ;"
        "5 <iota> <diagonal-matrix> anti-transpose ."
        ""
    }
} ;

HELP: rows-except ;
HELP: cols-except ;
HELP: matrix-except ;
HELP: matrix-except-all ;

HELP: determinant ;
HELP: 1/det ;
HELP: m*1/det ;

HELP: >minors ;
HELP: >cofactors ;
HELP: multiplicative-inverse ;

HELP: dim ;
HELP: dimension-range ;

HELP: covariance-matrix ;
HELP: covariance-matrix-ddof ;
HELP: sample-covariance-matrix ;
