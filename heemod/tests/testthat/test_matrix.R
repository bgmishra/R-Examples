context("Matrix objects")


test_that(
  "Matrix definition", {
    mat1 <- define_matrix(
      state_names = c("X1", "X2"),
      .3, .7,
      .6, .4
    )
    expect_output(
      str(mat1),
      'List of 4
 $ cell_1_1:List of 2
  ..$ expr: num 0.3',
      fixed = TRUE
    )
    expect_error(
      define_matrix(
        state_names = c("X1", "X1"),
        .3, .7,
        .6, .4
      )
    )
    expect_error(
      define_matrix(
        state_names = c("X1", "X2", "X3"),
        .3, .7,
        .6, .4
      )
    )
    expect_error(
      define_matrix(
        state_names = c("X1", "X2"),
        .3, .7,
        .6, .4, .4
      )
    )
    expect_error(
      modify(
        mat1,
        marcel = .4,
        cell_1_2 = .6
      )
    )
    expect_output(
      str(
        modify(
          mat1,
          cell_1_1 = .4,
          cell_1_2 = .6
        )
      ),
      'List of 4
 $ cell_1_1:List of 2
  ..$ expr: num 0.4',
      fixed = TRUE
    )
    expect_output(
      print(mat1),
      'An unevaluated matrix, 2 states.

   X1  X2 
X1 0.3 0.7
X2 0.6 0.4',
      fixed = TRUE
    )
  }
)

test_that(
  "Functions on matrix objects", {
    mat1 <- define_matrix(
      state_names = c("X1", "X2"),
      .3, .7,
      .6, .4
    )
    plot(mat1)
    expect_error(
      check_matrix(
        matrix(
          c(1, 0, 1, 1),
          nrow = 2
        )
      )
    )
    expect_error(
      check_matrix(
        matrix(
          c(1, 0, 1, 1),
          nrow = 2
        )
      )
    )
    expect_error(
      check_matrix(
        matrix(
          c(1, -1, 0, 2),
          nrow = 2
        )
      )
    )
    expect_equal(
      heemod:::get_matrix_order(mat1),
      2
    )
    expect_equal(
      get_state_names(mat1),
      c("X1", "X2")
    )
  }
)

test_that(
  "Matrix evaluation", {
    par1 <- define_parameters(
      a = .1,
      b = 1 / (markov_cycle + 1)
    )
    mat1 <- define_matrix(
      state_names = c("X1", "X2"),
      1-a, a,
      1-b, b
    )
    matC <- define_matrix(
      state_names = c("X1", "X2"),
      C, a,
      C, b
    )
    e_par1 <- eval_parameters(
      par1, 10
    )
    e_mat <- eval_matrix(
      mat1, e_par1
    )
    e_matC <- eval_matrix(
      matC, e_par1
    )
    expect_output(
      str(e_mat),
      'List of 10
 $ : num [1:2, 1:2] 0.9 0.5 0.1 0.5
 $ : num [1:2, 1:2] 0.9 0.667 0.1 0.333
 $ : num [1:2, 1:2] 0.9 0.75 0.1 0.25
 $ : num [1:2, 1:2] 0.9 0.8 0.1 0.2
 $ : num [1:2, 1:2] 0.9 0.833 0.1 0.167
 $ : num [1:2, 1:2] 0.9 0.857 0.1 0.143
 $ : num [1:2, 1:2] 0.9 0.875 0.1 0.125
 $ : num [1:2, 1:2] 0.9 0.889 0.1 0.111
 $ : num [1:2, 1:2] 0.9 0.9 0.1 0.1
 $ : num [1:2, 1:2] 0.9 0.9091 0.1 0.0909
 - attr(*, "class")= chr [1:2] "eval_matrix" "list"
 - attr(*, "state_names")= chr [1:2] "X1" "X2"',
      fixed = TRUE
    )
    expect_output(
      print(e_mat),
      'An evaluated matrix, 2 states, 10 markov cycles.

State names:

X1
X2

[[1]]
     [,1] [,2]
[1,]  0.9  0.1
[2,]  0.5  0.5',
      fixed = TRUE
    )
    expect_equal(
      get_state_names(e_mat),
      c("X1", "X2")
    )
    expect_equal(
      get_matrix_order(e_mat), 2
    )
    expect_equal(e_mat, e_matC)
  }
)
