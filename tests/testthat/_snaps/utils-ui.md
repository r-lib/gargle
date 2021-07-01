# gargle_verbosity() validates the value it finds

    Option "gargle_verbosity" must be one of: 'debug', 'info', and 'silent'

# gargle_verbosity() accomodates people using the old option

    Code
      out <- gargle_verbosity()
    Message <cliMessage>
      ! Option "gargle_quiet" is deprecated in favor of "gargle_verbosity"
      i Instead of: `options(gargle_quiet = FALSE)`
        Now do: `options(gargle_verbosity = "debug")`

# gargle_info() works

    Code
      gargle_info(c("aa {.field {blah}} bb", "cc {.emph xyz} dd"))
    Message <cliMessage>
      aa 'BLAH' bb
      cc xyz dd

---

    Code
      gargle_info(c("ee {.field {blah}} ff", "gg {.emph xyz} hh"))
    Message <cliMessage>
      ee 'BLAH' ff
      gg xyz hh

---

    Code
      gargle_info(c("ii {.field {blah}} jj", "kk {.emph xyz} ll"))

# gargle_debug() works

    Code
      gargle_debug(c("11 {.field {foo}} 22", "33 {.file a/b/c} 44"))
    Message <cliMessage>
      11 'FOO' 22
      33 'a/b/c' 44

---

    Code
      gargle_debug(c("55 {.field {foo}} 66", "77 {.file a/b/c} 88"))

---

    Code
      gargle_debug(c("99 {.field {foo}} 00", "11 {.file a/b/c} 22"))

