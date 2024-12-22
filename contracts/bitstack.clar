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