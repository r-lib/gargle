# unparseable JSON subject token errors without revealing it

    Code
      parse_subject_token("{\"id_token\": \"SECRET-TOKEN\"", format = list(type = "json",
        subject_token_field_name = "id_token"))
    Condition
      Error in `json_subject_token()`:
      ! The subject token source can't be parsed as JSON.

# service account impersonation is required

    Code
      init_oauth_external_account(list(credential_source = list(file = "x")))
    Condition
      Error in `init_oauth_external_account()`:
      ! gargle's workload identity federation flow requires 'service_account_impersonation_url'.
      i Direct workload identity federation, i.e. without service account impersonation, isn't supported yet.

