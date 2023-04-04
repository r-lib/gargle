# credentials_byo_oauth2() demands a Token2.0

    Code
      credentials_byo_oauth2(token = "a_naked_access_token")
    Condition
      Error in `credentials_byo_oauth2()`:
      ! inherits(token, "Token2.0") is not TRUE

# credentials_byo_oauth2() rejects a token that obviously not Google

    Code
      credentials_byo_oauth2(token = token)
    Condition
      Error in `credentials_byo_oauth2()`:
      ! Token doesn't use Google's OAuth endpoint.

