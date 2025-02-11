;; Credential Issuance Contract

;; Define data structures
(define-map credentials
  { id: uint }
  { issuer: principal, holder: principal, type: (string-ascii 64), data: (string-ascii 256), issued-at: uint }
)

(define-data-var credential-counter uint u0)

;; Error codes
(define-constant err-unauthorized (err u100))
(define-constant err-invalid-credential (err u101))

;; Issue a new credential
(define-public (issue-credential (holder principal) (type (string-ascii 64)) (data (string-ascii 256)))
  (let
    (
      (new-id (+ (var-get credential-counter) u1))
      (issuer tx-sender)
    )
    (var-set credential-counter new-id)
    (ok (map-set credentials
      { id: new-id }
      { issuer: issuer, holder: holder, type: type, data: data, issued-at: block-height }
    ))
  )
)

;; Revoke a credential
(define-public (revoke-credential (credential-id uint))
  (let ((issuer tx-sender))
    (match (map-get? credentials { id: credential-id })
      credential (if (is-eq issuer (get issuer credential))
                   (ok (map-delete credentials { id: credential-id }))
                   err-unauthorized)
      err-invalid-credential
    )
  )
)

;; Get credential details
(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { id: credential-id })
)

;; Check if a credential exists
(define-read-only (credential-exists (credential-id uint))
  (is-some (map-get? credentials { id: credential-id }))
)

