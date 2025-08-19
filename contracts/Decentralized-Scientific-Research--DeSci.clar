(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_ALREADY_EXISTS (err u103))
(define-constant ERR_INSUFFICIENT_FUNDS (err u104))
(define-constant ERR_ALREADY_REVIEWED (err u105))
(define-constant ERR_INVALID_STATUS (err u106))
(define-constant ERR_FUNDING_CLOSED (err u107))

(define-data-var next-research-id uint u1)
(define-data-var next-funding-pool-id uint u1)
(define-data-var next-review-id uint u1)

(define-map research-proposals 
    uint 
    {
        researcher: principal,
        title: (string-ascii 256),
        description: (string-ascii 1024),
        funding-goal: uint,
        status: (string-ascii 32),
        created-at: uint,
        published-hash: (optional (string-ascii 64))
    }
)

(define-map funding-pools 
    uint 
    {
        research-id: uint,
        creator: principal,
        total-funded: uint,
        funding-goal: uint,
        deadline: uint,
        is-active: bool
    }
)

(define-map funders 
    {pool-id: uint, funder: principal} 
    {amount: uint}
)

(define-map peer-reviews 
    uint 
    {
        research-id: uint,
        reviewer: principal,
        rating: uint,
        comments: (string-ascii 512),
        created-at: uint,
        is-verified: bool
    }
)

(define-map researcher-profiles 
    principal 
    {
        name: (string-ascii 128),
        institution: (string-ascii 256),
        reputation-score: uint,
        total-funded: uint,
        publications-count: uint
    }
)

(define-read-only (get-research-proposal (research-id uint))
    (map-get? research-proposals research-id)
)

(define-read-only (get-funding-pool (pool-id uint))
    (map-get? funding-pools pool-id)
)

(define-read-only (get-peer-review (review-id uint))
    (map-get? peer-reviews review-id)
)

(define-read-only (get-researcher-profile (researcher principal))
    (map-get? researcher-profiles researcher)
)

(define-read-only (get-funder-contribution (pool-id uint) (funder principal))
    (map-get? funders {pool-id: pool-id, funder: funder})
)

(define-read-only (get-current-research-id)
    (var-get next-research-id)
)

(define-read-only (get-current-funding-pool-id)
    (var-get next-funding-pool-id)
)

(define-read-only (get-current-review-id)
    (var-get next-review-id)
)

(define-public (create-researcher-profile (name (string-ascii 128)) (institution (string-ascii 256)))
    (begin
        (asserts! (is-none (map-get? researcher-profiles tx-sender)) ERR_ALREADY_EXISTS)
        (map-set researcher-profiles tx-sender {
            name: name,
            institution: institution,
            reputation-score: u0,
            total-funded: u0,
            publications-count: u0
        })
        (ok true)
    )
)

(define-public (submit-research-proposal (title (string-ascii 256)) (description (string-ascii 1024)) (funding-goal uint))
    (let ((research-id (var-get next-research-id)))
        (asserts! (> funding-goal u0) ERR_INVALID_AMOUNT)
        (asserts! (is-some (map-get? researcher-profiles tx-sender)) ERR_UNAUTHORIZED)
        (map-set research-proposals research-id {
            researcher: tx-sender,
            title: title,
            description: description,
            funding-goal: funding-goal,
            status: "proposed",
            created-at: stacks-block-height,
            published-hash: none
        })
        (var-set next-research-id (+ research-id u1))
        (ok research-id)
    )
)

(define-public (create-funding-pool (research-id uint) (deadline uint))
    (let ((pool-id (var-get next-funding-pool-id))
          (research (unwrap! (map-get? research-proposals research-id) ERR_NOT_FOUND)))
        (asserts! (is-eq (get researcher research) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (> deadline stacks-block-height) ERR_INVALID_AMOUNT)
        (asserts! (is-eq (get status research) "proposed") ERR_INVALID_STATUS)
        (map-set funding-pools pool-id {
            research-id: research-id,
            creator: tx-sender,
            total-funded: u0,
            funding-goal: (get funding-goal research),
            deadline: deadline,
            is-active: true
        })
        (map-set research-proposals research-id (merge research {status: "funding"}))
        (var-set next-funding-pool-id (+ pool-id u1))
        (ok pool-id)
    )
)

(define-public (fund-research (pool-id uint) (amount uint))
    (let ((pool (unwrap! (map-get? funding-pools pool-id) ERR_NOT_FOUND))
          (existing-contribution (default-to {amount: u0} (map-get? funders {pool-id: pool-id, funder: tx-sender}))))
        (asserts! (get is-active pool) ERR_FUNDING_CLOSED)
        (asserts! (< stacks-block-height (get deadline pool)) ERR_FUNDING_CLOSED)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set funders {pool-id: pool-id, funder: tx-sender} 
            {amount: (+ (get amount existing-contribution) amount)})
        (map-set funding-pools pool-id 
            (merge pool {total-funded: (+ (get total-funded pool) amount)}))
        (let ((updated-pool (unwrap-panic (map-get? funding-pools pool-id))))
            (if (>= (get total-funded updated-pool) (get funding-goal updated-pool))
                (begin
                    (map-set funding-pools pool-id (merge updated-pool {is-active: false}))
                    (let ((research (unwrap-panic (map-get? research-proposals (get research-id pool)))))
                        (map-set research-proposals (get research-id pool) 
                            (merge research {status: "funded"}))
                        (let ((researcher-profile (unwrap-panic (map-get? researcher-profiles (get researcher research)))))
                            (map-set researcher-profiles (get researcher research)
                                (merge researcher-profile {total-funded: (+ (get total-funded researcher-profile) (get total-funded updated-pool))}))
                        )
                    )
                )
                true
            )
        )
        (ok true)
    )
)

(define-public (submit-paper (research-id uint) (paper-hash (string-ascii 64)))
    (let ((research (unwrap! (map-get? research-proposals research-id) ERR_NOT_FOUND)))
        (asserts! (is-eq (get researcher research) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status research) "funded") ERR_INVALID_STATUS)
        (map-set research-proposals research-id 
            (merge research {
                status: "submitted",
                published-hash: (some paper-hash)
            }))
        (ok true)
    )
)

(define-public (submit-peer-review (research-id uint) (rating uint) (comments (string-ascii 512)))
    (let ((research (unwrap! (map-get? research-proposals research-id) ERR_NOT_FOUND))
          (review-id (var-get next-review-id))
          (reviewer-profile (unwrap! (map-get? researcher-profiles tx-sender) ERR_UNAUTHORIZED)))
        (asserts! (is-eq (get status research) "submitted") ERR_INVALID_STATUS)
        (asserts! (not (is-eq (get researcher research) tx-sender)) ERR_UNAUTHORIZED)
        (asserts! (and (>= rating u1) (<= rating u5)) ERR_INVALID_AMOUNT)
        (asserts! (is-none (map-get? peer-reviews review-id)) ERR_ALREADY_REVIEWED)
        (map-set peer-reviews review-id {
            research-id: research-id,
            reviewer: tx-sender,
            rating: rating,
            comments: comments,
            created-at: stacks-block-height,
            is-verified: (>= (get reputation-score reviewer-profile) u10)
        })
        (var-set next-review-id (+ review-id u1))
        (let ((updated-reviewer (merge reviewer-profile {reputation-score: (+ (get reputation-score reviewer-profile) u1)})))
            (map-set researcher-profiles tx-sender updated-reviewer)
        )
        (ok review-id)
    )
)

(define-public (publish-research (research-id uint))
    (let ((research (unwrap! (map-get? research-proposals research-id) ERR_NOT_FOUND)))
        (asserts! (is-eq (get researcher research) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status research) "submitted") ERR_INVALID_STATUS)
        (map-set research-proposals research-id 
            (merge research {status: "published"}))
        (let ((researcher-profile (unwrap-panic (map-get? researcher-profiles tx-sender))))
            (map-set researcher-profiles tx-sender
                (merge researcher-profile {
                    publications-count: (+ (get publications-count researcher-profile) u1),
                    reputation-score: (+ (get reputation-score researcher-profile) u5)
                }))
        )
        (ok true)
    )
)

(define-public (withdraw-funding (pool-id uint))
    (let ((pool (unwrap! (map-get? funding-pools pool-id) ERR_NOT_FOUND))
          (research (unwrap! (map-get? research-proposals (get research-id pool)) ERR_NOT_FOUND)))
        (asserts! (is-eq (get researcher research) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (>= (get total-funded pool) (get funding-goal pool)) ERR_INSUFFICIENT_FUNDS)
        (asserts! (is-eq (get status research) "funded") ERR_INVALID_STATUS)
        (try! (as-contract (stx-transfer? (get total-funded pool) tx-sender (get creator pool))))
        (ok true)
    )
)

(define-read-only (calculate-research-score (research-id uint))
    (ok u0)
)
