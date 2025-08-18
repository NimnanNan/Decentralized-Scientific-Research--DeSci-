# 🧬 Decentralized Scientific Research (DeSci) Platform

## 🔬 Overview

A blockchain-based platform revolutionizing scientific research through decentralized funding, transparent peer review, and open-access publishing. Built on Stacks blockchain using Clarity smart contracts.

## ✨ Key Features

- 💰 **Tokenized Research Funding** - Create funding pools for research proposals
- 📚 **Immutable Publishing** - Publish research with cryptographic proof
- 🎯 **Transparent Peer Review** - Record all reviews on-chain with reputation tracking
- 👨‍🔬 **Researcher Profiles** - Build reputation through contributions and publications
- 🏆 **Reputation System** - Earn points for reviews, publications, and funded research

## 🚀 Quick Start

### Prerequisites
- Clarinet CLI installed
- Stacks wallet set up

### Installation

```bash
git clone <repository-url>
cd Decentralized-Scientific-Research--DeSci-
clarinet check
```

## 📖 Usage Guide

### 1. 👤 Create Researcher Profile

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci create-researcher-profile 
    "Dr. Jane Smith" 
    "MIT - Computer Science Department")
```

### 2. 📝 Submit Research Proposal

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci submit-research-proposal 
    "AI-Based Drug Discovery Platform" 
    "Developing machine learning algorithms for accelerated pharmaceutical research" 
    u1000000)
```

### 3. 💸 Create Funding Pool

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci create-funding-pool 
    u1 
    u1000)
```

### 4. 💵 Fund Research

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci fund-research 
    u1 
    u50000)
```

### 5. 📄 Submit Research Paper

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci submit-paper 
    u1 
    "QmXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx")
```

### 6. ⭐ Submit Peer Review

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci submit-peer-review 
    u1 
    u4 
    "Excellent methodology and clear results. Minor improvements needed in statistical analysis.")
```

### 7. 🎉 Publish Research

```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci publish-research u1)
```

## 🔍 Query Functions

### Get Research Proposal
```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci get-research-proposal u1)
```

### Get Funding Pool Status
```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci get-funding-pool u1)
```

### Get Researcher Profile
```clarity
(contract-call? .Decentralized-Scientific-Research--DeSci get-researcher-profile 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 📊 Research Lifecycle

1. **🎯 Propose** - Researchers submit proposals with funding goals
2. **💰 Fund** - Community funds promising research through tokenized pools  
3. **🔬 Research** - Conduct research once funding goal is met
4. **📤 Submit** - Upload research papers with IPFS hash
5. **👥 Review** - Peers provide ratings and feedback transparently
6. **🌍 Publish** - Make research publicly available and immutable

## 🏗️ Contract Architecture

### Data Structures
- **Research Proposals** - Title, description, funding goal, status
- **Funding Pools** - Crowdfunding mechanism with deadlines
- **Peer Reviews** - Ratings, comments, and verification status
- **Researcher Profiles** - Reputation scores and publication history

### Key Functions
- `create-researcher-profile` - Register as a researcher
- `submit-research-proposal` - Submit new research for funding
- `fund-research` - Contribute to research funding pools
- `submit-peer-review` - Provide scholarly peer review
- `publish-research` - Make research publicly available

## 🛡️ Security Features

- ✅ Authorization checks for all critical functions
- ✅ Input validation and error handling
- ✅ Reputation-based review verification
- ✅ Funding goal validation
- ✅ Status-based workflow enforcement

## 🧪 Testing

```bash
clarinet test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🙋‍♂️ Support

For questions or support, please open an issue on GitHub.

---

*Built with ❤️ for the future of open science*
