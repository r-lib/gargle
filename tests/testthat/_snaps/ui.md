# gargle_verbosity() validates the value it finds

    Option "gargle_verbosity" must be one of: 'debug', 'info', 'silent'

# gargle_verbosity() accomodates people using the old option

    Code
      out <- gargle_verbosity()
    Message <cliMessage>
      Option "gargle_quiet" is deprecated in favor of "gargle_verbosity"
      Instead of: `options(gargle_quiet = FALSE)`
      Now do: `options(gargle_verbosity = "debug")`

