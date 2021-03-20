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

