# request_retry() logic works as advertised

    Code
      fail_then_succeed <- request_retry(max_total_wait_time_in_seconds = 5)
    Message
      i Exponential base for retries is {BASE}s.
      x Request 1 failed [429: RESOURCE_EXHAUSTED].
      i Will retry in {WAIT_TIME}s.
      i Wait time strategy: exponential backoff, full jitter
        PLACEHOLDER FOR GOOGLE ERROR MESSAGE
      v Request 2 successful!

---

    Code
      fail_then_succeed <- request_retry()
    Message
      i Exponential base for retries is {BASE}s.
      x Request 1 failed [429: RESOURCE_EXHAUSTED].
      i Will retry in {WAIT_TIME}s.
      i Wait time strategy: 'Retry-After' header
        PLACEHOLDER FOR GOOGLE ERROR MESSAGE
      v Request 2 successful!

---

    Code
      fail_max_tries <- request_retry(max_tries_total = 3,
        max_total_wait_time_in_seconds = 6)
    Message
      i Exponential base for retries is {BASE}s.
      x Request 1 failed [429: RESOURCE_EXHAUSTED].
      i Will retry in {WAIT_TIME}s.
      i Wait time strategy: exponential backoff, full jitter
        PLACEHOLDER FOR GOOGLE ERROR MESSAGE
      x Request 2 failed [429: RESOURCE_EXHAUSTED].
      i Will retry in {WAIT_TIME}s.
      i Wait time strategy: exponential backoff, full jitter
        PLACEHOLDER FOR GOOGLE ERROR MESSAGE
      v Request 3 failed :(

