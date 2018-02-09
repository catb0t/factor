! Copyright (C) 2005, 2010, 2018 Slava Pestov, Joe Groff, Cat Stevens.
USING: help.markup help.syntax kernel math opengl.gl sequences prettyprint urls ;
IN: math.matrices

ABOUT: "math.matrices"
{
  { <matrix> <matrix-by> <matrix-by-indices> <zero-matrix> <zero-square-matrix> <diagonal-matrix> <identity-matrix>
      <simple-eye> <eye> <square-rows> <square-cols> <upper-matrix> <lower-matrix> <cartesian-square-indices> }
  { <box-matrix> <hankel-matrix> <hilbert-matrix> <toeplitz-matrix> <vandermonde-matrix> }
  { <frustum-matrix4> <ortho-matrix4> <rotation-matrix3> <rotation-matrix4> <scale-matrix3>
      <scale-matrix4> <skew-matrix4> <translation-matrix4> }
  { mneg n+m m+n n-m m-n n*m m*n n/m m/n m^n }
  { m+ m- m* m/ m~ }
  { v.m m.v m. }
  { matrix-map column-map row-map cartesian-matrix-map cartesian-column-map cartesian-row-map
      gram-schmidt gram-schmidt-normalize stitch kronecker-product outer-product }
  { covariance-matrix covariance-matrix-ddof sample-covariance-matrix }
  { row rows col cols }
  { matrix-set-nth matrix-set-nths }
  { dim mmin mmax mnorm null-matrix? well-formed-matrix? square-matrix? }
  { negative-power-matrix m^n }
} [ related-words ] each

ARTICLE: "math.matrices" "Matrix operations"
"The " { $vocab-link "math.matrices" } " vocabulary implements many ways of working with 2-dimensional sequences, known as matrices. Operations on numeric vectors are implemented in " { $vocab-link "math.vectors" } ", upon which this vocabulary relies."
$nl
"Instead of a separate matrix " { $link tuple } " to be instantiated, words in this vocabulary operate on 2-dimensional sequences. In this vocabulary's stack effects, " { $snippet "m" } " and " { $snippet "matrix" } " are the conventional names used for a given matrix object, though " { $snippet "m" } " may refer to a number."
$nl
"Making simple matrices:"
{ $subsections
    <matrix>
    <matrix-by>
    <matrix-by-indices>
    <zero-matrix>
    <zero-square-matrix>
    <diagonal-matrix>
    <identity-matrix>
    <simple-eye>
    <eye>
    <square-rows>
    <square-cols>
    <upper-matrix>
    <lower-matrix>
    <cartesian-square-indices>
}

"Making special kinds of matrices:"
{ $subsections
    <box-matrix>
    <hankel-matrix>
    <hilbert-matrix>
    <toeplitz-matrix>
    <vandermonde-matrix>
}

"Making domain-specific transformation matrices:"
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

"By-element mathematical operations of a matrix and a scalar:"
{ $subsections mneg n+m m+n n-m m-n n*m m*n n/m m/n m^n }

"By-element mathematical operations of two matricess:"
{ $subsections m+ m- m* m/ m~ }

"Dot product (multiplication) of vectors and matrices:"
{ $subsections v.m m.v m. }

"Transformations on matrices:"
{ $subsections
    matrix-map
    column-map
    row-map
    cartesian-matrix-map
    cartesian-column-map
    cartesian-row-map
    gram-schmidt
    gram-schmidt-normalize
    stitch
    kronecker-product
    outer-product
}

"Covariance in matrices:"
{ $subsections
    covariance-matrix
    covariance-matrix-ddof
    sample-covariance-matrix
}

"Accesing parts of a matrix:"
{ $subsections row rows col cols }

"Mutating matrices in place:"
{ $subsections matrix-set-nth matrix-set-nths }

"Attributes of a matrix:"
{ $subsections
    dim
    mmin
    mmax
    mnorm
    null-matrix?
    well-formed-matrix?
    square-matrix?
}

"Errors thrown by this vocabulary:"
{ $subsections negative-power-matrix non-square-determinant } ;

HELP: negative-power-matrix
{ $values { "m" sequence } { "n" integer } }
{ $description "Throws a " { $link negative-power-matrix } " error." }
{ $error-description "Given the semantics of " { $link m^n } ", negative exponents are not within the domain of the power matrix function." } ;

HELP: non-square-determinant
{ $values { "m" integer } { "n" integer } }
{ $description "Throws a " { $link non-square-determinant } " error." }
{ $error-description { $link determinant } " was used with a non-square matrix whose dimensions are " { $snippet "m x n" } ". It is not generally possible to find the determinant of a non-square matrix." } ;


! creators
HELP: <matrix>
{ $values { "m" integer } { "n" integer } { "element" object } { "matrix" sequence } }
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
{ $values { "m" integer } { "n" integer } { "quot" { $quotation ( ... m' n' -- ... elt ) } } { "matrix" sequence } }
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
{ $values { "m" integer } { "n" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "m x n" } ", filled with zeroes." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 3 <zero-matrix> ."
        "{ { 0 0 0 } { 0 0 0 } }"
    }
} ;

HELP: <zero-square-matrix>
{ $values { "n" integer } { "matrix" sequence } }
{ $description "Creates a matrix of size " { $snippet "n x n" } ", filled with zeroes. Shorthand for " { $code "n n <zero-matrix>" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "2 <zero-square-matrix> ."
        "{ { 0 0 } { 0 0 } }"
    }
} ;

HELP: <diagonal-matrix>
{ $values { "diagonal-seq" sequence } { "matrix" sequence } }
{ $description "Creates a matrix with the specified diagonal values." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 1 2 3 } <diagonal-matrix> ."
        "{ { 1 0 0 } { 0 2 0 } { 0 0 3 } }"
    }
} ;

HELP: <identity-matrix>
{ $values { "n" integer } { "matrix" sequence } }
{ $description "Creates an " { $url URL" http://enwp.org/Identity_matrix" "identity matrix" } " of size " { $snippet "n x n" } ", where the diagonal values are all ones." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "4 <identity-matrix> ."
        "{ { 1 0 0 0 } { 0 1 0 0 } { 0 0 1 0 } { 0 0 0 1 } }"
    }
} ;

HELP: <eye>
{ $values { "m" integer } { "n" integer } { "k" integer } { "z" object } { "matrix" sequence } }
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
{ $values { "m" integer } { "n" integer } { "k" integer } { "matrix" sequence } }
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
{ $values { "desc" { $or sequence integer } } { "matrix" sequence } }
{ $description "Generate a square row matrix using the input descriptor. If the descriptor is a number, it is used to generate square rows within that range. If the descriptor is a sequence, it is " { $link replicate } "d to create each row." }
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
{ $values { "desc" { $or sequence integer } } { "matrix" sequence } }
{ $description "Generate a square column matrix using the input descriptor. If the descriptor is a number, it is used to generate square columns within that range. If the descriptor is a sequence, one column is created to replicate each of its elements." }
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
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" sequence } }
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
{ $values { "object" object } { "m" integer } { "n" integer } { "matrix" sequence } }
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
{ $values { "n" integer } { "matrix" sequence } }
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
{ $values { "n" integer } { "matrix" sequence } }
{ $description
    "A Hankel matrix is a symmetric, square matrix in which each ascending skew-diagonal from left to right is constant. See " { $url URL" https://en.wikipedia.org/wiki/Hankel_matrix" "hankel matrix" } "."
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
{ $values { "m" integer } { "n" integer } { "matrix" sequence } }
{ $description
    "A Hilbert matrix is a square matrix " { $snippet "A" } " in which entries are the unit fractions "
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
{ $values { "n" integer } { "matrix" sequence } }
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
{ $values { "r" integer } { "matrix" sequence } }
{ $description "Create a box (square) matrix with the dimensions of " { $snippet "r x r" } ", filled with ones. The number of elements in the output scales linearly (" { $snippet "(r*2)+1" } ") with the magnitude of " { $snippet "r" } "." }
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
{ $values { "factors" sequence } { "matrix" sequence } }
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
{ $values { "xy-dim" sequence } { "near" number } { "far" number } { "matrix" sequence } }
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
{ $values { "dim" sequence } { "matrix" sequence } }
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

HELP: mneg
{ $values { "m" sequence } { "m" object } }
{ $description "Negate (invert the sign) of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mneg ."
        "{ { -5 -9 } { -15 -17 } }"
    }
} ;

HELP: n+m
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "n" object } { "m" sequence }  }
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
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Adds two matrices element-wise." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 3 } { 3 2 1 } } { { 4 5 6 } { 6 5 4 } } m+ ."
        "{ { 5 7 9 } { 9 7 5 } }"
    }
} ;

HELP: m-
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Subtracts two matrices element-wise." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 4 5 6 } { 6 5 4 } } { { 1 2 3 } { 3 2 1 } } m- ."
        "{ { 3 3 3 } { 3 3 3 } }"
    }
} ;

HELP: m*
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Multiplies two matrices element-wise." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m* ."
        "{ { 15 18 } { 60 153 } }"
    }
} ;

HELP: m/
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Divides two matrices element-wise." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } { { 3 2 } { 4 9 } } m/ ."
        "{ { 1+2/3 4+1/2 } { 3+3/4 1+8/9 } }"
    }
} ;

HELP: m.v
{ $values { "m" sequence } { "v" sequence } { "p" sequence } }
{ $description "Computes the dot product of a matrix and a vector." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { 2 1 0 } m.v ."
        "{ 1 -3 }"
    }
} ;

HELP: v.m
{ $values { "m" sequence } { "v" sequence } { "p" sequence } }
{ $description "Computes the dot product of a vector and a matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 2 1 0 } { { 1 -1 2 } { 0 -3 1 } } v.m ."
        "{ 2 -5 5 }"
    }
} ;

HELP: m.
{ $values { "m" sequence } }
{ $description "Computes the dot product of two matrices, i.e multiplies them." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 -1 2 } { 0 -3 1 } } { { 3 7 } { 9 12 } } m. ."
        "{ { -6 -5 } { -27 -36 } }"
    }
} ;

HELP: m~
{ $values { "m1" sequence } { "m2" sequence } { "epsilon" number } { "?" boolean } }
{ $description "Compares the matrices using the " { $snippet "epsilon" } "." }
{ $examples
    { $example
        "USING: kernel math math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } dup [ .01 + ] matrix-map .1 m~ ."
        "t"
    }
} ;

HELP: mmin
{ $values { "m" sequence } { "n" object } }
{ $description "Calculate the minimum value of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmin ."
        "5"
    }
} ;

HELP: mmax
{ $values { "m" sequence } { "n" object } }
{ $description "Calculate the maximum value of all elements in the matrix." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mmax ."
        "17"
    }
} ;

HELP: mnorm
{ $values { "m" sequence } { "m'" object } }
{ $description "Calculate the normal value of each element in the matrix. This makes the maximum value in the sequence " { $snippet "1/1" } ", and computes other elements as fractions of this maximum. The output is a matrix, containing each original element as a fraction of the maximum." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 5 9 } { 15 17 } } mnorm ."
        "{ { 5/17 9/17 } { 15/17 1 } }"
    }
} ;

HELP: stitch
{ $values { "m" sequence } { "m'" sequence } }
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

HELP: kronecker-product
{ $values { "m1" sequence } { "m2" sequence } { "m" sequence } }
{ $description "Calculates the " { $url URL" http://enwp.org/Kronecker_product" "Kronecker product" } " of two matrices." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kronecker-product ."
        "{ { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }" }
} ;

HELP: outer-product
{ $values { "u" sequence } { "v" sequence } { "m" sequence } }
{ $description "Computes the " { $url URL" http://  enwp.org/Outer_product" "outer-product product" } " of " { $snippet "u" } " and " { $snippet "v" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 5 6 7 } { 1 2 3 } outer-product ."
        "{ { 5 10 15 } { 6 12 18 } { 7 14 21 } }" }
} ;

HELP: col
{ $values { "n" integer } { "matrix" sequence } { "col" sequence } }
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
{ $values { "seq" "a sequence of integers" } { "matrix" sequence } { "cols" sequence } }
{ $description "Get the columns from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } cols ."
        "{ { 1 3 } { 2 4 } }"
    }
} ;

HELP: row
{ $values { "n" integer } { "matrix" sequence } { "row" sequence } }
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
{ $values { "seq" "a sequence of integers" } { "matrix" sequence } { "rows" sequence } }
{ $description "Get the rows from " { $snippet "matrix" } " listed by " { $snippet "seq" } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ 0 1 } { { 1 2 } { 3 4 } } rows ."
        "{ { 1 2 } { 3 4 } }"
    }
} ;

HELP: transpose ;
{ transpose flip } related-words


HELP: null-matrix?
{ $values { "matrix" sequence } { "?" boolean } }
{ $description "Determine whether " { $snippet "matrix" } " is a null matrix. A null matrix is an empty sequence, or a sequence which consists only of empty sequences." }
{ $notes "In mathematics, a null matrix is a matrix full of zeroes. In Factor, a matrix with no scalar (non-sequence) elements is considered null. For the former behaviour, use " { $link zero-matrix? } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { } { } { } } null-matrix? ."
        "t"
    }
} ;

HELP: zero-matrix?
{ $values { "matrix" sequence } { "?" boolean } }
{ $description "Determine whether " { $snippet "matrix" } " is a zero matrix. A zero matrix has no nonzero elements." }
{ $notes "In mathematics, a null matrix is a matrix full of zeroes. In Factor, such a matrix is considered a zero matrix. For testing whether a matrix has no scalar (non-sequence) elements, use " { $link null-matrix? } "." }
{ $examples
    { $example
        "USING: math.matrices prettyprint ;"
        "{ { } { } { } } null-matrix? ."
        "t"
    }
} ;
