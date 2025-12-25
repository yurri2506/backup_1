# Experiment Dashboard

Real-time monitoring dashboard for experiment contexts (Baseline, LMTR, SABV, SABV+LMTR).

## Quick Start

```bash
cd dashboard
npm install
npm run dev
```

Open http://localhost:5173

## Features

- ✅ Sidebar + Top Navigation layout
- ✅ Real-time updates (2s intervals)
- ✅ Context filtering (Baseline, LMTR, SABV, SABV+LMTR)
- ✅ Status tracking (Pending/Running/Completed/Failed)
- ✅ CPU & RAM charts
- ✅ Live log viewer
- ✅ Responsive design

## Project Structure

```
dashboard/
├── src/
│   ├── components/      # React components
│   ├── hooks/           # Custom hooks
│   ├── types/           # TypeScript types
│   ├── utils/           # Utilities & mock data
│   ├── App.tsx          # Main app
│   └── main.tsx         # Entry point
└── package.json
```

All code is production-ready and self-contained!
