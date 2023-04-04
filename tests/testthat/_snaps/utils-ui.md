# gargle_verbosity() validates the value it finds

    Option "gargle_verbosity" must be one of: 'debug', 'info', or 'silent'.

# gargle_verbosity() accomodates people using the old option

    Code
      out <- gargle_verbosity()
    Condition
      Warning:
      The "gargle_quiet" option was deprecated in gargle 1.1.0.
      i Please use the "gargle_verbosity" option instead.
      x Don't do this: `options(gargle_quiet = FALSE)`
      v Do this instead: `options(gargle_verbosity = "debug")`

# gargle_info() works

    Code
      gargle_info(c("aa {.field {blah}} bb", "cc {.emph xyz} dd"))
    Message
      aa 'BLAH' bb
      cc xyz dd

---

    Code
      gargle_info(c("ee {.field {blah}} ff", "gg {.emph xyz} hh"))
    Message
      ee 'BLAH' ff
      gg xyz hh

---

    Code
      gargle_info(c("ii {.field {blah}} jj", "kk {.emph xyz} ll"))

# gargle_debug() works

    Code
      gargle_debug(c("11 {.field {foo}} 22", "33 {.file a/b/c} 44"))
    Message
      11 'FOO' 22
      33 'a/b/c' 44

---

    Code
      gargle_debug(c("55 {.field {foo}} 66", "77 {.file a/b/c} 88"))

---

    Code
      gargle_debug(c("99 {.field {foo}} 00", "11 {.file a/b/c} 22"))

# bulletize() works

    Code
      cli::cli_bullets(bulletize(letters))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 21 more

---

    Code
      cli::cli_bullets(bulletize(letters, bullet = "x"))
    Message
      x a
      x b
      x c
      x d
      x e
        ... and 21 more

---

    Code
      cli::cli_bullets(bulletize(letters, n_show = 2))
    Message
      * a
      * b
        ... and 24 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:6]))
    Message
      * a
      * b
      * c
      * d
      * e
      * f

---

    Code
      cli::cli_bullets(bulletize(letters[1:7]))
    Message
      * a
      * b
      * c
      * d
      * e
      * f
      * g

---

    Code
      cli::cli_bullets(bulletize(letters[1:8]))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 3 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:6], n_fudge = 0))
    Message
      * a
      * b
      * c
      * d
      * e
        ... and 1 more

---

    Code
      cli::cli_bullets(bulletize(letters[1:8], n_fudge = 3))
    Message
      * a
      * b
      * c
      * d
      * e
      * f
      * g
      * h

