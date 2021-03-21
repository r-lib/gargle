# Resource exhausted (Sheets, ReadGroup)

    Client error: (429) RESOURCE_EXHAUSTED
      * Either out of resource quota or reaching rate limiting. The client should look for google.rpc.QuotaFailure error detail for more information.
      * Quota exceeded for quota metric 'Read requests' and limit 'Read requests per minute per user' of service 'sheets.googleapis.com' for consumer 'project_number:603366585132'.
    
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
      *       domain: global
      *       reason: notFound
      *      message: File not found: NOPE_NOT_A_GOOD_ID.
      * locationType: parameter
      *     location: fileId

# Request for which we don't have scope (Fitness)

    Client error: (403) Forbidden
    Request had insufficient authentication scopes.
    PERMISSION_DENIED
      * message: Insufficient Permission
      *  domain: global
      *  reason: insufficientPermissions

