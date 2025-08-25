;; Reputation Scoring Smart Contract
;; A simple contract to track and manage wallet reputation scores based on activity

;; Define constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-INVALID-SCORE (err u101))
(define-constant ERR-WALLET-NOT-FOUND (err u102))

;; Data variables
(define-data-var total-wallets uint u0)

;; Data maps
(define-map wallet-reputation
    principal
    {
        score: uint,
        last-updated: uint,
        activity-count: uint
    }
)

;; Public functions

;; Initialize or update a wallet's reputation score
(define-public (update-reputation-score (wallet principal) (score uint) (activity-increment uint))
    (begin
        (asserts! (<= score u100) ERR-INVALID-SCORE)
        (let ((current-data (default-to 
                {score: u0, last-updated: u0, activity-count: u0} 
                (map-get? wallet-reputation wallet))))
            (map-set wallet-reputation wallet
                {
                    score: score,
                    last-updated: block-height,
                    activity-count: (+ (get activity-count current-data) activity-increment)
                })
            (if (is-none (map-get? wallet-reputation wallet))
                (var-set total-wallets (+ (var-get total-wallets) u1))
                true
            )
            (ok true)
        )
    )
)

;; Increment reputation based on positive activity
(define-public (reward-positive-activity (wallet principal) (points uint))
    (let ((current-data (unwrap! (map-get? wallet-reputation wallet) ERR-WALLET-NOT-FOUND)))
        (let ((new-score (if (> (+ (get score current-data) points) u100)
                            u100
                            (+ (get score current-data) points))))
            (map-set wallet-reputation wallet
                {
                    score: new-score,
                    last-updated: block-height,
                    activity-count: (+ (get activity-count current-data) u1)
                })
            (ok new-score)
        )
    )
)

;; Penalize negative activity
(define-public (penalize-negative-activity (wallet principal) (penalty uint))
    (let ((current-data (unwrap! (map-get? wallet-reputation wallet) ERR-WALLET-NOT-FOUND)))
        (let ((new-score (if (> (get score current-data) penalty)
                            (- (get score current-data) penalty)
                            u0)))
            (map-set wallet-reputation wallet
                {
                    score: new-score,
                    last-updated: block-height,
                    activity-count: (+ (get activity-count current-data) u1)
                })
            (ok new-score)
        )
    )
)

;; Admin function to reset a wallet's reputation (contract owner only)
(define-public (reset-wallet-reputation (wallet principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (map-delete wallet-reputation wallet)
        (var-set total-wallets (- (var-get total-wallets) u1))
        (ok true)
    )
)

;; Read-only functions

;; Get reputation data for a specific wallet
(define-read-only (get-wallet-reputation (wallet principal))
    (map-get? wallet-reputation wallet)
)

;; Get just the reputation score for a wallet
(define-read-only (get-reputation-score (wallet principal))
    (match (map-get? wallet-reputation wallet)
        reputation-data (some (get score reputation-data))
        none
    )
)

;; Check if a wallet has a minimum reputation score
(define-read-only (has-minimum-reputation (wallet principal) (min-score uint))
    (match (get-reputation-score wallet)
        score (>= score min-score)
        false
    )
)

;; Get the total number of wallets being tracked
(define-read-only (get-total-wallets)
    (var-get total-wallets)
)

;; Get reputation tier based on score
(define-read-only (get-reputation-tier (wallet principal))
    (match (get-reputation-score wallet)
        score (if (>= score u80)
                "Excellent"
                (if (>= score u60)
                    "Good"
                    (if (>= score u40)
                        "Fair"
                        (if (>= score u20)
                            "Poor"
                            "Very Poor"))))
        "Unrated"
    )
)

;; Check if wallet exists in the system
(define-read-only (wallet-exists (wallet principal))
    (is-some (map-get? wallet-reputation wallet))
)