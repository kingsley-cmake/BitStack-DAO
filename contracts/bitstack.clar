;; Title
;; BitStack DAO Smart Contract

;; Summary
;; This smart contract implements a decentralized autonomous organization (DAO) for the BitStack community.
;; It allows members to join the DAO, create proposals, vote on proposals, and execute proposals if they pass the required quorum.

;; Description
;; The BitStack DAO smart contract is designed to manage a decentralized organization where members
;; can participate in governance by creating and voting on proposals.

;; Constants: Error Codes
;; Each error code represents a specific validation or state error in the contract
(define-constant ERR-OWNER-ONLY (err u100))           ;; Operation restricted to contract owner
(define-constant ERR-NOT-MEMBER (err u101))           ;; User is not a DAO member
(define-constant ERR-ALREADY-MEMBER (err u102))       ;; User is already a DAO member
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))  ;; Not enough funds for operation
(define-constant ERR-PROPOSAL-NOT-FOUND (err u104))   ;; Requested proposal doesn't exist
(define-constant ERR-ALREADY-VOTED (err u105))        ;; Member has already voted on this proposal
(define-constant ERR-PROPOSAL-EXPIRED (err u106))     ;; Proposal voting period has ended
(define-constant ERR-INSUFFICIENT-QUORUM (err u107))  ;; Proposal didn't reach required votes
(define-constant ERR-PROPOSAL-NOT-PASSED (err u108))  ;; Proposal didn't get enough yes votes
(define-constant ERR-INVALID-AMOUNT (err u109))       ;; Invalid amount specified
(define-constant ERR-UNAUTHORIZED (err u110))         ;; User not authorized for operation
(define-constant ERR-PROPOSAL-EXECUTED (err u111))    ;; Proposal has already been executed

;; State Variables
;; Core configuration and state tracking for the DAO
(define-data-var minimum-membership-fee uint u1000000) ;; Minimum STX required to join (in microSTX)
(define-data-var proposal-duration uint u144)          ;; Proposal voting window in blocks (~1 day)
(define-data-var quorum-threshold uint u51)            ;; Minimum percentage of votes required (51%)
(define-data-var total-members uint u0)                ;; Current number of DAO members
(define-data-var treasury-balance uint u0)             ;; Total STX held by the DAO
(define-data-var next-proposal-id uint u0)             ;; Auto-incrementing proposal counter

;; Data Maps
;; Member Information
;; Tracks individual member details and participation metrics
(define-map members principal 
    {
        joined-at: uint,           ;; Block height when member joined
        stx-balance: uint,         ;; Member's staked STX balance
        voting-power: uint,        ;; Calculated voting power based on stake
        proposals-created: uint,   ;; Number of proposals created by member
        last-vote-height: uint     ;; Block height of member's last vote
    }
)

;; Proposal Details
;; Stores all information about proposals including their current state
(define-map proposals uint 
    {
        creator: principal,                ;; Address that created the proposal
        title: (string-ascii 50),         ;; Short proposal title
        description: (string-ascii 500),   ;; Detailed proposal description
        amount: uint,                      ;; STX amount requested
        recipient: principal,              ;; Recipient of funds if approved
        created-at: uint,                  ;; Block height at creation
        expires-at: uint,                  ;; Block height when voting ends
        yes-votes: uint,                   ;; Total yes votes received
        no-votes: uint,                    ;; Total no votes received
        executed: bool,                    ;; Whether proposal has been executed
        total-votes: uint                  ;; Total votes cast
    }
)

;; Vote Records
;; Tracks individual votes cast by members on proposals
(define-map votes {proposal-id: uint, voter: principal} 
    {
        vote: bool,    ;; true for yes, false for no
        power: uint    ;; Voting power used for this vote
    }
)

;; Private Helper Functions

;; Checks if an address is a DAO member
(define-private (is-member (address principal))
    (is-some (map-get? members address))
)

;; Validates member status and returns error if not a member
(define-private (check-is-member (address principal))
    (if (is-member address)
        (ok true)
        ERR-NOT-MEMBER
    )
)

;; Calculates voting power based on staked balance
(define-private (calculate-voting-power (balance uint))
    (/ balance u1000000)
)

;; Public Functions

;; Allows a new member to join the DAO by staking STX
(define-public (join-dao)
    (let 
        (
            (membership-fee (var-get minimum-membership-fee))
        )
        (asserts! (not (is-member tx-sender)) ERR-ALREADY-MEMBER)
        (try! (stx-transfer? membership-fee tx-sender (as-contract tx-sender)))
        
        (map-set members tx-sender
            {
                joined-at: block-height,
                stx-balance: membership-fee,
                voting-power: (calculate-voting-power membership-fee),
                proposals-created: u0,
                last-vote-height: u0
            }
        )
        
        (var-set total-members (+ (var-get total-members) u1))
        (var-set treasury-balance (+ (var-get treasury-balance) membership-fee))
        (ok true)
    )
)

;; Creates a new proposal for the DAO
(define-public (create-proposal (title (string-ascii 50)) (description (string-ascii 500)) (amount uint) (recipient principal))
    (let
        (
            (member-data (unwrap! (map-get? members tx-sender) ERR-NOT-MEMBER))
            (proposal-id (var-get next-proposal-id))
        )
        (asserts! (<= amount (var-get treasury-balance)) ERR-INSUFFICIENT-BALANCE)
        (asserts! (> (len title) u0) ERR-INVALID-AMOUNT)
        (asserts! (> (len description) u0) ERR-INVALID-AMOUNT)
        (asserts! (is-eq recipient recipient) ERR-INVALID-AMOUNT)
        
        (map-set proposals proposal-id
            {
                creator: tx-sender,
                title: title,
                description: description,
                amount: amount,
                recipient: recipient,
                created-at: block-height,
                expires-at: (+ block-height (var-get proposal-duration)),
                yes-votes: u0,
                no-votes: u0,
                executed: false,
                total-votes: u0
            }
        )
        
        (map-set members tx-sender
            (merge member-data 
                {
                    proposals-created: (+ (get proposals-created member-data) u1)
                }
            )
        )
        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

;; Allows a member to vote on an active proposal
(define-public (vote-on-proposal (proposal-id uint) (vote-bool bool))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
            (member-data (unwrap! (map-get? members tx-sender) ERR-NOT-MEMBER))
            (voting-power (get voting-power member-data))
        )
        (asserts! (< block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender})) ERR-ALREADY-VOTED)
        
        (map-set votes {proposal-id: proposal-id, voter: tx-sender}
            {
                vote: vote-bool,
                power: voting-power
            }
        )
        
        (map-set proposals proposal-id
            (merge proposal
                {
                    yes-votes: (if vote-bool (+ (get yes-votes proposal) voting-power) (get yes-votes proposal)),
                    no-votes: (if vote-bool (get no-votes proposal) (+ (get no-votes proposal) voting-power)),
                    total-votes: (+ (get total-votes proposal) voting-power)
                }
            )
        )
        
        (map-set members tx-sender
            (merge member-data
                {
                    last-vote-height: block-height
                }
            )
        )
        (ok true)
    )
)

;; Executes a passed proposal, transferring funds to the
(define-public (execute-proposal (proposal-id uint))
    (let
        (
            (proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
            (total-votes (get total-votes proposal))
            (yes-votes (get yes-votes proposal))
        )
        (asserts! (>= block-height (get expires-at proposal)) ERR-PROPOSAL-EXPIRED)
        (asserts! (not (get executed proposal)) ERR-PROPOSAL-EXECUTED)
        (asserts! (>= (* yes-votes u100) (* total-votes (var-get quorum-threshold))) ERR-INSUFFICIENT-QUORUM)
        
        (try! (as-contract (stx-transfer? (get amount proposal) tx-sender (get recipient proposal))))
        
        (map-set proposals proposal-id
            (merge proposal
                {
                    executed: true
                }
            )
        )
        
        (var-set treasury-balance (- (var-get treasury-balance) (get amount proposal)))
        (ok true)
    )
)
