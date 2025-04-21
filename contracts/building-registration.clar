;; Building Registration Contract
;; Records details of commercial structures

(define-data-var last-building-id uint u0)

;; Building data structure
(define-map buildings
  { building-id: uint }
  {
    owner: principal,
    name: (string-utf8 100),
    location: (string-utf8 100),
    square-footage: uint,
    year-built: uint,
    registered-at: uint
  }
)

;; Register a new building
(define-public (register-building
    (name (string-utf8 100))
    (location (string-utf8 100))
    (square-footage uint)
    (year-built uint))
  (let
    (
      (new-id (+ (var-get last-building-id) u1))
      (caller tx-sender)
      (current-time u2023) ;; Using fixed value instead of block-height
    )
    (asserts! (> (len name) u0) (err u1)) ;; Name cannot be empty
    (asserts! (> (len location) u0) (err u2)) ;; Location cannot be empty
    (asserts! (> square-footage u0) (err u3)) ;; Square footage must be positive
    (asserts! (<= year-built u2023) (err u4)) ;; Year built must be valid (using 2023 as current year)

    (map-set buildings
      { building-id: new-id }
      {
        owner: caller,
        name: name,
        location: location,
        square-footage: square-footage,
        year-built: year-built,
        registered-at: current-time
      }
    )

    (var-set last-building-id new-id)
    (ok new-id)
  )
)

;; Update building information
(define-public (update-building
    (building-id uint)
    (name (string-utf8 100))
    (location (string-utf8 100))
    (square-footage uint)
    (year-built uint))
  (let
    (
      (building-data (unwrap! (map-get? buildings { building-id: building-id }) (err u10)))
      (caller tx-sender)
    )
    (asserts! (is-eq (get owner building-data) caller) (err u11)) ;; Only owner can update
    (asserts! (> (len name) u0) (err u1))
    (asserts! (> (len location) u0) (err u2))
    (asserts! (> square-footage u0) (err u3))
    (asserts! (<= year-built u2023) (err u4)) ;; Using 2023 as current year

    (map-set buildings
      { building-id: building-id }
      {
        owner: caller,
        name: name,
        location: location,
        square-footage: square-footage,
        year-built: year-built,
        registered-at: (get registered-at building-data)
      }
    )

    (ok true)
  )
)

;; Get building details
(define-read-only (get-building (building-id uint))
  (map-get? buildings { building-id: building-id })
)

;; Check if caller is building owner
(define-read-only (is-building-owner (building-id uint) (owner principal))
  (let
    (
      (building-data (map-get? buildings { building-id: building-id }))
    )
    (if (is-some building-data)
      (is-eq (get owner (unwrap-panic building-data)) owner)
      false
    )
  )
)
