# request_retry() logic works as advertised

    Code
      writeLines(fix_strategy(fix_wait_time(msg_fail_once)))
    Output
      > Request failed [429]
        oops
        Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)

---

    Code
      writeLines(fix_strategy(fix_wait_time(msg_retry_after)))
    Output
      > Request failed [429]
        oops
        Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: 'Retry-After' header)

---

    Code
      writeLines(fix_strategy(fix_wait_time(msg_max_tries)))
    Output
      > Request failed [429]
        oops
        Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)
      > Request failed [429]
        oops
        Retry 2 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)

