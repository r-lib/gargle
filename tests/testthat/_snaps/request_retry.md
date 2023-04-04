# request_retry() logic works as advertised

    Code
      fail_then_succeed <- request_retry(max_total_wait_time_in_seconds = 5)
    Message
      x Request failed [429]
        oops
      i Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)

---

    Code
      fail_then_succeed <- request_retry()
    Message
      x Request failed [429]
        oops
      i Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: 'Retry-After' header)

---

    Code
      fail_max_tries <- request_retry(max_tries_total = 3,
        max_total_wait_time_in_seconds = 6)
    Message
      x Request failed [429]
        oops
      i Retry 1 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)
      x Request failed [429]
        oops
      i Retry 2 happens in {WAIT_TIME} seconds ...
        (strategy: exponential backoff, full jitter)

