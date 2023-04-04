# gargle_oauth_client() rejects bad input

    Code
      gargle_oauth_client()
    Condition
      Error in `gargle_oauth_client()`:
      ! `id` must be a single string, not absent.

---

    Code
      gargle_oauth_client(1234)
    Condition
      Error in `gargle_oauth_client()`:
      ! `id` must be a single string, not the number 1234.

---

    Code
      gargle_oauth_client(id = "ID")
    Condition
      Error in `gargle_oauth_client()`:
      ! `secret` must be a single string, not absent.

---

    Code
      gargle_oauth_client(id = "ID", secret = 1234)
    Condition
      Error in `gargle_oauth_client()`:
      ! `secret` must be a single string, not the number 1234.

---

    Code
      gargle_oauth_client("ID", "SECRET", type = "nope")
    Condition
      Error in `gargle_oauth_client()`:
      ! `type` must be one of "installed" or "web", not "nope".

# gargle_oauth_client() has special handling for web clients

    Code
      gargle_oauth_client("ID", "SECRET", type = "web")
    Condition
      Error in `gargle_oauth_client()`:
      ! A "web" type OAuth client must have one or more 'redirect_uris'.

---

    Code
      gargle_oauth_client("ID", "SECRET", type = "web", redirect_uris = c(
        "http://localhost:8111/", "http://127.0.0.1:8100/",
        "https://example.com/aaa/bbb/v"))
    Message
      <gargle_oauth_client>
      name: 7f82e05dfbeb26a264621f1482a14e25
      id: ID
      secret: <REDACTED>
      type: web
      redirect_uris: http://localhost:8111/, http://127.0.0.1:8100/,
      https://example.com/aaa/bbb/v

# service account JSON throws an informative error

    Code
      gargle_oauth_client_from_json(test_path("fixtures",
        "service-account-token.json"))
    Condition
      Error in `gargle_oauth_client_from_json()`:
      ! JSON has an unexpected form
      i Are you sure this is the JSON downloaded for an OAuth client?
      i It is easy to confuse the JSON for an OAuth client and a service account.

