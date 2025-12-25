// API utilities for fetching AggSandbox experiment data

export interface AggSandboxExperiment {
  id: string;
  context?: 'aggsandbox' | 'lmtr' | 'sabv+lmtr' | 'normal';
  type: 'baseline' | 'v4' | 'v5';
  n: number;
  run?: number;
  status: 'running' | 'completed' | 'failed';
  pid?: number;
  exitCode?: number;
  elapsedTime?: string;
  elapsed?: string;
  userTime?: string;
  sysTime?: string;
  cpuPercent?: number;
  cpuUsage?: number;
  ramGB?: number;
  ramUsage?: number;
  fraudDetected?: boolean;
  l1VerifyStatus?: string;
  l1VerifyTime?: number;
  l1VerifyGas?: number;
  logFile?: string;
  proofDir?: string;
  startTime?: number;
  lastUpdate?: number;
}

export interface AggSandboxStatus {
  experiments: AggSandboxExperiment[];
  runningCount: number;
  completedCount: number;
  failedCount: number;
  statistics?: {
    total: number;
    byContext: {
      'aggsandbox': {
        total: number;
        byType: {
          [key: string]: {
            total: number;
            ns: number[];
            runs: number;
          };
        };
        byN: {
          [key: number]: {
            total: number;
            types: string[];
            runs: number;
          };
        };
      };
      'lmtr': {
        total: number;
        byType: {
          [key: string]: {
            total: number;
            ns: number[];
            runs: number;
          };
        };
        byN: {
          [key: number]: {
            total: number;
            types: string[];
            runs: number;
          };
        };
      };
      'sabv+lmtr': {
        total: number;
        byType: {
          [key: string]: {
            total: number;
            ns: number[];
            runs: number;
          };
        };
        byN: {
          [key: number]: {
            total: number;
            types: string[];
            runs: number;
          };
        };
      };
      'normal': {
        total: number;
        byType: {
          [key: string]: {
            total: number;
            ns: number[];
            runs: number;
          };
        };
        byN: {
          [key: number]: {
            total: number;
            types: string[];
            runs: number;
          };
        };
      };
    };
    byType: {
      [key: string]: {
        total: number;
        ns: number[];
        runs: number;
      };
    };
    byN: {
      [key: number]: {
        total: number;
        types: string[];
        runs: number;
      };
    };
    byStatus: {
      running: number;
      completed: number;
      failed: number;
    };
    runsByConfig: {
      [key: string]: number;
    };
  };
  lastUpdate: number;
}

const API_BASE = '/api/aggsandbox';

export async function fetchAggSandboxStatus(): Promise<AggSandboxStatus> {
  try {
    const response = await fetch(`${API_BASE}/status`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch AggSandbox status:', error);
    // Return mock data for development
    return getMockAggSandboxStatus();
  }
}

export async function fetchAggSandboxLog(experimentId: string): Promise<string[]> {
  try {
    const response = await fetch(`${API_BASE}/log/${experimentId}`);
    if (!response.ok) {
      return [];
    }
    const data = await response.json();
    return data.lines || [];
  } catch (error) {
    console.error('Failed to fetch log:', error);
    return [];
  }
}

// Mock data for development (when API is not available)
function getMockAggSandboxStatus(): AggSandboxStatus {
  const now = Date.now();
  return {
    experiments: [
      {
        id: 'v5-n200-run2',
        type: 'v5',
        n: 200,
        status: 'running',
        startTime: now - 1800000, // 30 minutes ago
        lastUpdate: now - 2000,
        cpuPercent: 850,
        ramGB: 15.2,
        fraudDetected: false,
      },
      {
        id: 'v5-n500-run1',
        type: 'v5',
        n: 500,
        status: 'running',
        startTime: now - 3600000, // 1 hour ago
        lastUpdate: now - 3000,
        cpuPercent: 920,
        ramGB: 18.5,
        fraudDetected: false,
      },
      {
        id: 'v5-n100-run5',
        type: 'v5',
        n: 100,
        status: 'completed',
        exitCode: 0,
        elapsedTime: '0:15:32',
        userTime: '12:45',
        sysTime: '0:23',
        cpuPercent: 780,
        ramGB: 14.8,
        fraudDetected: false,
        l1VerifyStatus: 'success',
        l1VerifyTime: 2.3,
        l1VerifyGas: 450000,
        startTime: now - 1800000,
        lastUpdate: now - 300000,
      },
    ],
    runningCount: 2,
    completedCount: 1,
    failedCount: 0,
    lastUpdate: now,
  };
}

