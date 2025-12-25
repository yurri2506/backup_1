# Quick Start Guide

## 🚀 Installation

```bash
cd dashboard
npm install
```

## 🎯 Development

```bash
npm run dev
```

Then open http://localhost:5173

## 📦 What's Included

- ✅ Full React + TypeScript setup
- ✅ TailwindCSS configured
- ✅ All components ready to use
- ✅ Mock data with auto-updates (2s intervals)
- ✅ Responsive design
- ✅ Production-ready code structure

## 🎨 Features

1. **Real-time Updates**: Experiments update every 2 seconds
2. **Context Filtering**: Filter by Baseline, LMTR, SABV, SABV+LMTR
3. **Interactive Charts**: CPU & RAM usage over time
4. **Live Logs**: Terminal-style log viewer
5. **Status Tracking**: Pending, Running, Completed, Failed

## 🔧 Customization

### Change Update Interval
Edit `src/hooks/useExperiments.ts`:
```typescript
setInterval(() => {
  // ... update logic
}, 2000); // Change 2000 to desired milliseconds
```

### Replace Mock Data
Edit `src/utils/mockData.ts` and replace `generateMockExperiments()` with your API call.

### Add New Metrics
1. Add to `Experiment` interface in `src/types/experiment.ts`
2. Update `ExperimentCard.tsx` to display new metric
3. Update mock data generator

## 📝 File Overview

- `src/App.tsx` - Main dashboard page
- `src/components/` - All reusable components
- `src/hooks/` - Custom React hooks
- `src/utils/` - Utilities & mock data
- `src/types/` - TypeScript definitions

## 🎯 Ready to Use

All code is self-contained and production-ready. Just install dependencies and run!
