# gargle_verbosity() validates the value it finds

    Option "gargle_verbosity" must be one of: 'debug', 'info', and 'silent'

# gargle_verbosity() accomodates people using the old option

    Code
      out <- gargle_verbosity()
    Message
      ! Option "gargle_quiet" is deprecated in favor of "gargle_verbosity"
      i Instead of: `options(gargle_quiet = FALSE)`
        Now do: `options(gargle_verbosity = "debug")`

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

# cli_menu() basic usage

    Code
      cli_menu_with_mock(1)
    Message
      Found multiple thingies.
      Which one do you want to use?
      1: label a
      2: label b
      3: label c
      Selection: 1
    Output
      [1] 1

# cli_menu() invalid selection

    Code
      cli_menu_with_mock("nope")
    Message
      Found multiple thingies.
      Which one do you want to use?
      1: label a
      2: label b
      3: label c
      Selection: nope
    Condition
      Error in `cli_menu_with_mock()`:
      x Internal error: mocked input is invalid.

# cli_menu(), request exit via 0

    Code
      cli_menu_with_mock(0)
    Message
      Found multiple thingies.
      Which one do you want to use?
      1: label a
      2: label b
      3: label c
      Selection: 0
    Condition
      Error:
      ! Exiting...

# cli_menu(exit =) works

    Code
      cli_menu_with_mock(1)
    Message
      Hey we need to talk.
      What do you want to do?
      1: Give up
      2: Some other thing
      Selection: 1
    Condition
      Error:
      ! Exiting...

---

    Code
      cli_menu_with_mock(2)
    Message
      Hey we need to talk.
      What do you want to do?
      1: Give up
      2: Some other thing
      Selection: 2
    Output
      [1] 2

# cli_menu() inline markup and environment passing

    Code
      cli_menu_with_mock(1)
    Message
      Hey we need to "talk".
      What do you want to "do"?
      1: Send email to 'jane@example.com'
      2: Install the nifty package
      Selection: 1
    Output
      [1] 1

# cli_menu() not_interactive, many strings, chained error

    Code
      wrapper_fun()
    Condition
      Error in `wrapper_fun()`:
      ! Multiple things found.
      i Use `thingy` to specify one of "thing 1", "thing 2", and "thing 3".

