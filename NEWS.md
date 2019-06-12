# gargle (development version)

# gargle 0.2.0

* All built-in API credentials have been rotated and are stored internally in a way that reinforces appropriate use. There is a new [Privacy policy](https://www.tidyverse.org/google_privacy_policy/) as well as a [policy for authors of packages or other applications](https://www.tidyverse.org/google_privacy_policy/#policies-for-authors-of-packages-or-other-applications). This is related to a process to get the gargle project [verified](https://support.google.com/cloud/answer/7454865?hl=en), which affects the OAuth2 capabilities and the consent screen.

* New vignette on "How to get your own API credentials", to help other package authors or users obtain their own API key or OAuth client ID and secret.

* `credentials_byo_oauth2()` is a new credential function. It is included in the
default registry consulted by `token_fetch()` and is tried just before
`credentials_user_oauth2()`.

# gargle 0.1.3

* Initial CRAN release
