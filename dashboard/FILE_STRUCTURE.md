# File Structure

```
dashboard/
├── src/
│   ├── components/
│   │   ├── ExperimentCard.tsx          # Main experiment card with metrics, charts, logs
│   │   ├── ExperimentContextSelector.tsx # Context filter buttons
│   │   ├── LogPanel.tsx                # Collapsible log viewer
│   │   ├── MetricItem.tsx              # Reusable metric display
│   │   └── ResourceUsageChart.tsx      # CPU/RAM line charts
│   ├── hooks/
│   │   └── useExperiments.ts           # Custom hook for experiment state management
│   ├── types/
│   │   └── experiment.ts               # TypeScript interfaces
│   ├── utils/
│   │   ├── format.ts                   # Time/bytes/date formatters
│   │   └── mockData.ts                 # Mock data generators & updaters
│   ├── App.tsx                         # Main dashboard component
│   ├── main.tsx                        # React entry point
│   └── index.css                       # Global styles + Tailwind
├── index.html                          # HTML template
├── package.json                        # Dependencies
├── tsconfig.json                       # TypeScript config
├── tsconfig.node.json                  # Node TypeScript config
├── tailwind.config.js                  # TailwindCSS config
├── postcss.config.js                   # PostCSS config
├── vite.config.ts                      # Vite bundler config
├── .eslintrc.cjs                       # ESLint config
├── .gitignore
├── README.md
└── FILE_STRUCTURE.md                   # This file
```

## Key Files

### Entry Points
- `index.html` - Main HTML file
- `src/main.tsx` - React app entry
- `src/App.tsx` - Root component

### Components
All components are self-contained and reusable:
- **ExperimentCard**: Full experiment display with expandable details
- **ExperimentContextSelector**: Filter buttons for contexts
- **ResourceUsageChart**: Recharts-based line charts
- **LogPanel**: Terminal-style log viewer
- **MetricItem**: Small metric display cards

### Hooks
- **useExperiments**: Manages experiment state, filtering, and auto-updates

### Utils
- **mockData.ts**: Generates and updates mock experiment data
- **format.ts**: Utility functions for formatting time, bytes, dates

### Types
- **experiment.ts**: All TypeScript interfaces for type safety


