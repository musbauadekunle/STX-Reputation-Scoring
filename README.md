Reputation Scoring Smart Contract

Overview

The Reputation Scoring Smart Contract is a Clarity-based contract designed to track and manage wallet reputation scores on the Stacks blockchain. It allows dApps, communities, and protocols to assign, update, and evaluate wallet reputations based on user activity, thereby enabling trust-based interactions.

This contract introduces:

Reputation scoring (0–100 scale).

Activity tracking (via incremented counters).

Positive/negative reputation adjustments.

Reputation tiers for easy classification.

Administrative controls for contract owner.

Features
Core Functionalities

Update Reputation

update-reputation-score allows initializing or updating a wallet’s reputation with activity increments.

Positive Reinforcement

reward-positive-activity boosts a wallet’s score (capped at 100).

Negative Penalties

penalize-negative-activity reduces a wallet’s score but never below 0.

Admin Reset

reset-wallet-reputation lets the contract owner reset a wallet’s reputation completely.

Read-Only Functions

get-wallet-reputation → Returns full reputation data (score, last updated block, activity count).

get-reputation-score → Returns only the reputation score.

has-minimum-reputation → Checks if a wallet meets a given threshold.

get-total-wallets → Returns the number of wallets being tracked.

get-reputation-tier → Classifies reputation as Excellent, Good, Fair, Poor, or Very Poor.

wallet-exists → Verifies if a wallet has an entry in the system.

Error Codes

ERR-OWNER-ONLY (u100) → Only the contract owner may perform this action.

ERR-INVALID-SCORE (u101) → Reputation score must be between 0 and 100.

ERR-WALLET-NOT-FOUND (u102) → Wallet does not exist in the reputation system.

Reputation Tiers

Excellent → Score ≥ 80

Good → Score ≥ 60

Fair → Score ≥ 40

Poor → Score ≥ 20

Very Poor → Score < 20

Unrated → No score set

Example Use Cases

Decentralized Marketplaces → Vet sellers and buyers based on their reputation history.

Community Governance → Assign voting weight based on reputation score.

Social Protocols → Reward active and trustworthy participants.

On-Chain Gaming → Track player fairness and engagement.

Deployment Notes

Ensure the deploying wallet is the contract owner (automatically set at deployment).

All scoring operations are capped at 0–100.

Use wallet-exists before reputation updates to confirm wallet presence.