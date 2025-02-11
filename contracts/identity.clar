;; Identity Contract

;; Define data structures
(define-map identities
  { id: principal }
  { username: (string-ascii 64), public-key: (string-ascii 128), created-at: uint }
)

;; Error codes
(define-constant err-identity-already-exists (err u100))
(define-constant err-identity-not-found (err u101))
(define-constant err-not-identity-owner (err u102))

;; Create a new identity
(define-public (create-identity (username (string-ascii 64)) (public-key (string-ascii 128)))
  (let ((caller tx-sender))
    (if (is-some (map-get? identities { id: caller }))
      err-identity-already-exists
      (ok (map-set identities { id: caller } { username: username, public-key: public-key, created-at: block-height }))
    )
  )
)

;; Update an existing identity
(define-public (update-identity (username (string-ascii 64)) (public-key (string-ascii 128)))
  (let ((caller tx-sender))
    (match (map-get? identities { id: caller })
      identity (ok (map-set identities { id: caller } (merge identity { username: username, public-key: public-key })))
      err-identity-not-found
    )
  )
)

;; Get identity details
(define-read-only (get-identity (id principal))
  (map-get? identities { id: id })
)

;; Check if an identity exists
(define-read-only (identity-exists (id principal))
  (is-some (map-get? identities { id: id }))
)

