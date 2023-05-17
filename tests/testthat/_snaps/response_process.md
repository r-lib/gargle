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

# HTML error is offered as a file

    Code
      strwrap(readLines(path_to_html_error), width = 60)
    Output
       [1] "<html><head><meta http-equiv=\"content-type\""                    
       [2] "content=\"text/html;"                                             
       [3] "charset=utf-8\"/><title>Sorry...</title><style> body {"           
       [4] "font-family: verdana, arial, sans-serif; background-color:"       
       [5] "#fff; color: #000;"                                               
       [6] "}</style></head><body><div><table><tr><td><b><font"               
       [7] "face=sans-serif size=10><font color=#4285f4>G</font><font"        
       [8] "color=#ea4335>o</font><font color=#fbbc05>o</font><font"          
       [9] "color=#4285f4>g</font><font color=#34a853>l</font><font"          
      [10] "color=#ea4335>e</font></font></b></td><td"                        
      [11] "style=\"text-align: left; vertical-align: bottom;"                
      [12] "padding-bottom: 15px; width: 50%\"><div"                          
      [13] "style=\"border-bottom: 1px solid"                                 
      [14] "#dfdfdf;\">Sorry...</div></td></tr></table></div><div"            
      [15] "style=\"margin-left: 4em;\"><h1>We're sorry...</h1><p>... but"    
      [16] "your computer or network may be sending automated queries."       
      [17] "To protect our users, we can't process your request right"        
      [18] "now.</p></div><div style=\"margin-left: 4em;\">See <a"            
      [19] "href=\"https://support.google.com/websearch/answer/86640\">Google"
      [20] "Help</a> for more information.<br/><br/></div><div"               
      [21] "style=\"text-align: center; border-top: 1px solid"                
      [22] "#dfdfdf;\"><a href=\"https://www.google.com\">Google"             
      [23] "Home</a></div></body></html>"                                     

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

