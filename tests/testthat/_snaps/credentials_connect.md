# connect_credentials() explains why it doesn't work

    Code
      . <- credentials_connect()
    Message
      trying `credentials_connect()`
      x We don't seem to be on Posit Connect.

---

    Code
      . <- credentials_connect()
    Message
      trying `credentials_connect()`
      x Viewer-based credentials only work in Shiny.

# ConnectToken makes exchange requests to the Connect server as expected

    Code
      token
    Output
      
      -- <ConnectToken (via gargle)> -------------------------------------------------
               id: user-token
           scopes: https://www.googleapis.com/auth/bigquery      , https://www.googleapis.com/auth/cloud-platform
      credentials: token_type, access_token, issued_token_type

