export type ExperimentStatus = 'pending' | 'running' | 'completed' | 'failed';

export type ExperimentContext = 'baseline' | 'lmtr' | 'sabv' | 'sabv+lmtr';

export interface ResourceMetrics {
  timestamp: number;
  cpu: number;
  ram: number; // in GB
}

export interface Experiment {
  id: string;
  name: string;
  context: ExperimentContext;
  status: ExperimentStatus;
  batchSize: number;
  cpuUsage: number; // percentage
  ramUsage: number; // GB
  elapsedTime: number; // seconds
  startTime: number; // timestamp
  endTime?: number; // timestamp
  logs: string[];
  metrics: ResourceMetrics[];
  modules: string[];
}

export interface ExperimentFilters {
  context?: ExperimentContext;
  status?: ExperimentStatus;
}
