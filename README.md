# Trading Challenge Marketplace

A platform for trading challenges with cryptocurrency payment integration. This application allows users to select from various trading challenge tiers, make payments in cryptocurrency, and receive funded trading accounts.

## Features

- Multiple challenge types:
  - Standard 2-Phase Challenges
  - Instant Phase Challenges with 30% consistency score
  - 1-Step Express Challenges
- Cryptocurrency payment integration (USDT)
- User authentication
- Email notifications for payment verification
- Responsive design for all devices

## Challenge Types

### Standard 2-Phase Challenges
Traditional trading challenges with two evaluation phases before receiving a funded account.

### Instant Phase Challenges
Get instant funding after achieving a 30% consistency score in your trading.

### 1-Step Express Challenges
Fast-track to funding with a single evaluation phase and higher profit targets.

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/challenge-marketplace-crypto.git
cd challenge-marketplace-crypto
```

2. Install dependencies
```bash
npm install
# or
yarn
```

3. Start the development server
```bash
npm run dev
# or
yarn dev
```

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Technologies Used

- React
- TypeScript
- Vite
- Tailwind CSS
- Supabase (Authentication & Database)
- Shadcn UI Components

## License

This project is licensed under the MIT License - see the LICENSE file for details.
