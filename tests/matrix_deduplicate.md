Fix Coordinate Matrix Deduplication
================
[Skyler Lewis](mailto:slewis@flowwest.com)
2024-09-23

Make a test matrix with duplicates

``` r
A = matrix(
  c(1, 2, 
    3, 4, 
    3, 4,
    5, 6), 
  ncol = 2,
  byrow = TRUE)
colnames(A) = c("X", "Y")
print(A)
```

    ##      X Y
    ## [1,] 1 2
    ## [2,] 3 4
    ## [3,] 3 4
    ## [4,] 5 6

``` r
df <- as.data.frame(A)
print(df)
```

    ##   X Y
    ## 1 1 2
    ## 2 3 4
    ## 3 3 4
    ## 4 5 6

This is the current make_coordinate_df function. Deduplication is
incorrect

``` r
make_coordinate_df_old <- function(x) {
  if (is.matrix(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinate pairs, only unique pairs were kept")
      return(as.data.frame(matrix(x[!duplicated(x), ], ncol=2, byrow=TRUE, dimnames = list(NULL, c("x", "y")))))
    } else 
      return(as.data.frame(matrix(x, ncol=2, dimnames = list(NULL, c("x", "y"))))) 
  } else if (is.data.frame(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinates, only unique pairs will be used")
      colnames(x) <- c("x", "y")
      return(x[!duplicated(x), ])
    } else {
      colnames(x) <- c("x", "y")
      return(x)
    }
  } else {
    stop("input coordinates format must be one of matrix or data.frame", call. = FALSE)
  }
}

# works fine for data frames
make_coordinate_df_old(df)
```

    ## Warning in make_coordinate_df_old(df): Duplicate values found in coordinates,
    ## only unique pairs will be used

    ##   x y
    ## 1 1 2
    ## 2 3 4
    ## 4 5 6

``` r
# does not work for matrices
make_coordinate_df_old(A)
```

    ## Warning in make_coordinate_df_old(A): Duplicate values found in coordinate
    ## pairs, only unique pairs were kept

    ##   x y
    ## 1 1 3
    ## 2 5 2
    ## 3 4 6

Revised version

``` r
make_coordinate_df_new <- function(x) {
  if (is.matrix(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinate pairs, only unique pairs were kept")
      return(as.data.frame(matrix(x[!duplicated(x), ], ncol=2, byrow=FALSE, dimnames = list(NULL, c("x", "y")))))
    } else 
      return(as.data.frame(matrix(x, ncol=2, dimnames = list(NULL, c("x", "y"))))) 
  } else if (is.data.frame(x)) {
    if (anyDuplicated(x)) {
      warning("Duplicate values found in coordinates, only unique pairs will be used")
      colnames(x) <- c("x", "y")
      return(x[!duplicated(x), ])
    } else {
      colnames(x) <- c("x", "y")
      return(x)
    }
  } else {
    stop("input coordinates format must be one of matrix or data.frame", call. = FALSE)
  }
}

# works fine for data frames
make_coordinate_df_new(df)
```

    ## Warning in make_coordinate_df_new(df): Duplicate values found in coordinates,
    ## only unique pairs will be used

    ##   x y
    ## 1 1 2
    ## 2 3 4
    ## 4 5 6

``` r
# works for matrices too
make_coordinate_df_new(A)
```

    ## Warning in make_coordinate_df_new(A): Duplicate values found in coordinate
    ## pairs, only unique pairs were kept

    ##   x y
    ## 1 1 2
    ## 2 3 4
    ## 3 5 6
