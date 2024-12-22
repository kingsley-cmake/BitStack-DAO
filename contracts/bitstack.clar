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