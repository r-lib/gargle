# it is possible to be 'outside the house'

    Code
      local(gargle:::check_permitted_package(), envir = globalenv())
    Condition
      Error:
      ! Attempt to directly access a credential that can only be used within tidyverse packages.
      This error may mean that you need to:
      * Create a new project on Google Cloud Platform.
      * Enable relevant APIs for your project.
      * Create an API key and/or an OAuth client ID.
      * Configure your requests to use your API key and OAuth client ID.
      i See gargle's "How to get your own API credentials" vignette for more details:
      i <https://gargle.r-lib.org/articles/get-api-credentials.html>

# tidyverse API key

    Code
      local(tidyverse_api_key(), envir = globalenv())
    Condition
      Error in `tidyverse_api_key()`:
      ! Attempt to directly access a credential that can only be used within tidyverse packages.
      This error may mean that you need to:
      * Create a new project on Google Cloud Platform.
      * Enable relevant APIs for your project.
      * Create an API key and/or an OAuth client ID.
      * Configure your requests to use your API key and OAuth client ID.
      i See gargle's "How to get your own API credentials" vignette for more details:
      i <https://gargle.r-lib.org/articles/get-api-credentials.html>

# gargle oauth app (deprecated)

    Code
      oa <- gargle_app()
    Condition
      Warning:
      `gargle_app()` was deprecated in gargle 1.3.0.
      i Please use `gargle_client()` instead.

# tidyverse oauth app (deprecated)

    Code
      oa <- tidyverse_app()
    Condition
      Warning:
      `tidyverse_app()` was deprecated in gargle 1.3.0.
      i Please use `tidyverse_client()` instead.

