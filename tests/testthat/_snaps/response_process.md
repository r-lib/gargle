# Resource exhausted (Sheets, ReadGroup)

    Client error: (429) RESOURCE_EXHAUSTED
    * Either out of resource quota or reaching rate limiting. The client should look
      for google.rpc.QuotaFailure error detail for more information.
    * Quota exceeded for quota metric 'Read requests' and limit 'Read requests per
      minute per user' of service 'sheets.googleapis.com' for consumer
      'project_number:603366585132'.
    
    Error details:
    * reason: RATE_LIMIT_EXCEEDED
    * domain: googleapis.com
    * metadata.quota_limit: ReadRequestsPerMinutePerUser
    * metadata.consumer: projects/603366585132
    * metadata.service: sheets.googleapis.com
    * metadata.quota_metric: sheets.googleapis.com/read_requests

# Request for non-existent resource (Drive)

    Client error: (404) Not Found
    File not found: NOPE_NOT_A_GOOD_ID.
    * domain: global
    * reason: notFound
    * message: File not found: NOPE_NOT_A_GOOD_ID.
    * locationType: parameter
    * location: fileId

# Request for which we don't have scope (Fitness)

    Client error: (403) Forbidden
    Request had insufficient authentication scopes.
    PERMISSION_DENIED
    * message: Insufficient Permission
    * domain: global
    * reason: insufficientPermissions

# Use key that's not enabled for the API (Sheets)

    Client error: (403) PERMISSION_DENIED
    * Client does not have sufficient permission. This can happen because the OAuth
      token does not have the right scopes, the client doesn't have permission, or
      the API has not been enabled for the client project.
    * Google Sheets API has not been used in project 977449744253 before or it is
      disabled. Enable it by visiting
      https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=977449744253
      then retry. If you enabled this API recently, wait a few minutes for the
      action to propagate to our systems and retry.
    
    Error details:
    Links
    * Description: Google developers console API activation
      URL:
      https://console.developers.google.com/apis/api/sheets.googleapis.com/overview?project=977449744253
    * reason: SERVICE_DISABLED
    * domain: googleapis.com
    * metadata.consumer: projects/977449744253
    * metadata.service: sheets.googleapis.com

# Request with invalid argument (Sheets, bad range)

    Client error: (400) INVALID_ARGUMENT
    * Client specified an invalid argument. Check error message and error details for
      more information.
    * Unable to parse range: NOPE!A5:F15

# Request with bad field mask (Sheets)

    Client error: (400) INVALID_ARGUMENT
    * Client specified an invalid argument. Check error message and error details for
      more information.
    * Request contains an invalid argument.
    
    Error details:
    Field violations
    * Field: sheets.sheetProperties
      Description: Error expanding 'fields' parameter. Cannot find matching fields
      for path 'sheets.sheetProperties'.

# Request for nonexistent resource (Sheets)

    Client error: (404) NOT_FOUND
    * A specified resource is not found, or the request is rejected by undisclosed
      reasons, such as whitelisting.
    * Requested entity was not found.

# Request with invalid value (tokeninfo, stale token)

    Client error: (400) Bad Request
    * Invalid Value

# Request to bad URL (tokeninfo, HTML content)

    Expected content type 'application/json', not 'text/html'.
    * Not Found

