# BitStack DAO Smart Contract

A decentralized autonomous organization (DAO) smart contract built on Stacks blockchain that enables community governance through proposal creation and voting.

## Overview

BitStack DAO is a decentralized governance system that allows members to:
- Join the DAO by staking STX tokens
- Create and vote on proposals
- Execute approved proposals
- Participate in community decision-making

## Features

- **Membership Management**: Join the DAO by staking STX tokens
- **Proposal System**: Create, vote on, and execute proposals
- **Voting Power**: Voting power calculated based on staked balance
- **Treasury Management**: Secure handling of DAO funds
- **Quorum Requirements**: Ensures meaningful participation in governance
- **Time-bound Voting**: Proposals have specific voting windows

## Technical Details

### Constants

- Minimum membership fee: 1,000,000 microSTX
- Proposal duration: 144 blocks (~1 day)
- Quorum threshold: 51%

### Key Functions

#### Public Functions

1. `join-dao()`
   - Allows new members to join by staking STX
   - Requires minimum membership fee
   - Updates member records and treasury balance

2. `create-proposal(title, description, amount, recipient)`
   - Creates new proposals for DAO consideration
   - Requires member status
   - Validates proposal parameters

3. `vote-on-proposal(proposal-id, vote-bool)`
   - Enables members to vote on active proposals
   - Voting power based on staked balance
   - Prevents double voting

4. `execute-proposal(proposal-id)`
   - Executes passed proposals
   - Requires quorum and majority approval
   - Handles fund transfers

#### Read-Only Functions

1. `get-proposal(proposal-id)`
   - Retrieves proposal details

2. `get-member(address)`
   - Fetches member information

3. `get-vote(proposal-id, voter)`
   - Returns voting record

4. `get-dao-info()`
   - Provides DAO statistics and configuration

## Getting Started

### Prerequisites

- Stacks wallet
- Sufficient STX tokens for membership

### Joining the DAO

1. Ensure you have enough STX tokens
2. Call the `join-dao()` function
3. Stake the required membership fee

### Creating a Proposal

1. Must be a DAO member
2. Call `create-proposal()` with:
   - Title (max 50 characters)
   - Description (max 500 characters)
   - Requested amount
   - Recipient address

### Voting

1. Browse active proposals using `get-proposal()`
2. Call `vote-on-proposal()` with your choice
3. Monitor proposal status

## Error Codes

| Code | Description |
|------|-------------|
| u100 | Owner only operation |
| u101 | Not a DAO member |
| u102 | Already a member |
| u103 | Insufficient balance |
| u104 | Proposal not found |
| u105 | Already voted |
| u106 | Proposal expired |
| u107 | Insufficient quorum |
| u108 | Proposal not passed |
| u109 | Invalid amount |
| u110 | Unauthorized |
| u111 | Proposal already executed |

## Security Considerations

- Time-locked voting periods
- Double-vote prevention
- Balance validations
- Quorum requirements
- Access control checks

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

For security concerns, please review our [SECURITY.md](SECURITY.md) file.	