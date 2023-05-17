# Resource exhausted (Sheets, ReadGroup)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (429) RESOURCE_EXHAUSTED
      * Either out of resource quota or reaching rate limiting. The client should look for google.rpc.QuotaFailure error detail for more information.
      * Quota exceeded for quota metric 'Read requests' and limit 'Read requests per minute per user' of service 'sheets.googleapis.com' for consumer 'project_number:603366585132'.
      
      Error details:
      * reason: RATE_LIMIT_EXCEEDED
      * domain: googleapis.com
      * metadata.quota_location: global
      * metadata.quota_metric: sheets.googleapis.com/read_requests
      * metadata.quota_limit: ReadRequestsPerMinutePerUser
      * metadata.quota_limit_value: 60
      * metadata.consumer: projects/603366585132
      * metadata.service: sheets.googleapis.com
      Links
      * Description: Request a higher quota limit.
        URL: https://cloud.google.com/docs/quota#requesting_higher_quota

# Request for non-existent resource (Drive)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (404) Not Found
      File not found: NOPE_NOT_A_GOOD_ID.
      * domain: global
      * reason: notFound
      * message: File not found: NOPE_NOT_A_GOOD_ID.
      * locationType: parameter
      * location: fileId

# Too many requests (Drive, HTML content)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (429) Too Many Requests (RFC 6585)
      x Expected content type 'application/json', not 'text/html'.
      i See 'VOLATILE_FILE_PATH' for the html error content.
      i Or execute `browseURL("VOLATILE_FILE_PATH")` to view it in your browser.

# Request for which we don't have scope (Fitness)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (403) Forbidden
      Request had insufficient authentication scopes.
      PERMISSION_DENIED
      * message: Insufficient Permission
      * domain: global
      * reason: insufficientPermissions

# Use key that's not enabled for the API (Sheets)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (403) PERMISSION_DENIED
      * Client does not have sufficient permission. This can happen because the OAuth token does not have the right scopes, the client doesn't have permission, or the API has not been enabled for the client project.
      * Google Sheets API has not been used in project 977449744253 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=977449744253 then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
      
      Error details:
      Links
      * Description: Google developers console API activation
        URL: https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=977449744253
      * reason: SERVICE_DISABLED
      * domain: googleapis.com
      * metadata.consumer: projects/977449744253
      * metadata.service: sheets.googleapis.com

# Request with invalid argument (Sheets, bad range)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (400) INVALID_ARGUMENT
      * Client specified an invalid argument. Check error message and error details for more information.
      * Unable to parse range: NOPE!A5:F15

# Request with bad field mask (Sheets)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (400) INVALID_ARGUMENT
      * Client specified an invalid argument. Check error message and error details for more information.
      * Request contains an invalid argument.
      
      Error details:
      Field violations
      * Field: sheets.sheetProperties
        Description: Error expanding 'fields' parameter. Cannot find matching fields for path 'sheets.sheetProperties'.

# Request for nonexistent resource (Sheets)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (404) NOT_FOUND
      * A specified resource is not found, or the request is rejected by undisclosed reasons, such as whitelisting.
      * Requested entity was not found.

# Request with invalid value (tokeninfo, stale token)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (400) Bad Request
      * Invalid Value

# Request to bad URL (tokeninfo, HTML content)

    Code
      response_process(resp)
    Condition
      Error in `expect_recorded_error()`:
      ! Client error: (404) Not Found
      x Expected content type 'application/json', not 'text/html'.
      i See 'VOLATILE_FILE_PATH' for the html error content.
      i Or execute `browseURL("VOLATILE_FILE_PATH")` to view it in your browser.

