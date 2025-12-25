import { Experiment, ExperimentContext } from '../types/experiment';

const contexts: ExperimentContext[] = ['baseline', 'lmtr', 'sabv', 'sabv+lmtr'];
const statuses: Experiment['status'][] = ['pending', 'running', 'completed', 'failed'];
const batchSizes = [1, 10, 50, 100, 200, 500, 700];

function generateLogs(experimentId: string, count: number = 50): string[] {
  const logs: string[] = [];
  const logTemplates = [
    `[${experimentId}] Starting experiment...`,
    `[${experimentId}] Initializing SABV5 verification...`,
    `[${experimentId}] Building Merkle tree...`,
    `[${experimentId}] Running LMTR4 rebalancing...`,
    `[${experimentId}] Generating SP1 proof...`,
    `[${experimentId}] Trace generation in progress...`,
    `[${experimentId}] Compressing proof data...`,
    `[${experimentId}] Verifying proof integrity...`,
    `[${experimentId}] L1 verification successful`,
  ];

  for (let i = 0; i < count; i++) {
    const template = logTemplates[Math.floor(Math.random() * logTemplates.length)];
    const timestamp = new Date(Date.now() - (count - i) * 10000).toISOString();
    logs.push(`[${timestamp}] ${template}`);
  }

  return logs;
}

function generateMetrics(startTime: number, elapsedSeconds: number): Array<{ timestamp: number; cpu: number; ram: number }> {
  const metrics: Array<{ timestamp: number; cpu: number; ram: number }> = [];
  const interval = 10; // seconds between metrics

  for (let i = 0; i <= elapsedSeconds; i += interval) {
    const progress = i / elapsedSeconds;
    const baseCpu = 800 + Math.random() * 200;
    const baseRam = 12 + Math.random() * 4;
    
    // Simulate CPU/RAM variations
    const cpu = Math.max(100, Math.min(1200, baseCpu + Math.sin(progress * Math.PI * 2) * 50));
    const ram = Math.max(8, Math.min(24, baseRam + Math.sin(progress * Math.PI * 1.5) * 2));

    metrics.push({
      timestamp: startTime + i * 1000,
      cpu: Math.round(cpu * 10) / 10,
      ram: Math.round(ram * 100) / 100,
    });
  }

  return metrics;
}

export function generateMockExperiments(count: number = 12): Experiment[] {
  const experiments: Experiment[] = [];
  const now = Date.now();

  for (let i = 0; i < count; i++) {
    const context = contexts[Math.floor(Math.random() * contexts.length)];
    const batchSize = batchSizes[Math.floor(Math.random() * batchSizes.length)];
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    
    const startTime = now - (Math.random() * 24 * 60 * 60 * 1000); // Random time in last 24h
    const elapsedSeconds = status === 'running' 
      ? Math.floor((now - startTime) / 1000)
      : status === 'completed' 
        ? 1800 + Math.random() * 3600 // 30-90 minutes
        : status === 'failed'
          ? 300 + Math.random() * 600 // 5-15 minutes
          : 0;

    const endTime = status !== 'running' && status !== 'pending' 
      ? startTime + elapsedSeconds * 1000 
      : undefined;

    const currentMetrics = generateMetrics(startTime, elapsedSeconds);
    const currentMetric = currentMetrics[currentMetrics.length - 1] || { cpu: 0, ram: 0, timestamp: now };

    const modules: string[] = [];
    if (context === 'lmtr' || context === 'sabv+lmtr') modules.push('LMTR4');
    if (context === 'sabv' || context === 'sabv+lmtr') modules.push('SABV5');
    if (context === 'baseline') modules.push('Baseline');

    experiments.push({
      id: `exp-${i + 1}-${Date.now()}`,
      name: `${context.toUpperCase()} N=${batchSize} Run ${Math.floor(Math.random() * 5) + 1}`,
      context,
      status,
      batchSize,
      cpuUsage: currentMetric.cpu,
      ramUsage: currentMetric.ram,
      elapsedTime: elapsedSeconds,
      startTime,
      endTime,
      logs: generateLogs(`exp-${i + 1}`, 50),
      metrics: currentMetrics,
      modules,
    });
  }

  return experiments.sort((a, b) => b.startTime - a.startTime);
}

export function updateExperiment(experiment: Experiment): Experiment {
  if (experiment.status !== 'running') return experiment;

  const now = Date.now();
  const elapsedSeconds = Math.floor((now - experiment.startTime) / 1000);
  
  // Update metrics with slight variations
  const lastMetric = experiment.metrics[experiment.metrics.length - 1];
  const newCpu = Math.max(100, Math.min(1200, 
    lastMetric.cpu + (Math.random() - 0.5) * 20
  ));
  const newRam = Math.max(8, Math.min(24, 
    lastMetric.ram + (Math.random() - 0.5) * 0.5
  ));

  const newMetrics = [...experiment.metrics, {
    timestamp: now,
    cpu: Math.round(newCpu * 10) / 10,
    ram: Math.round(newRam * 100) / 100,
  }];

  // Keep only last 100 metrics points
  const trimmedMetrics = newMetrics.slice(-100);

  // Occasionally add new log entries
  const newLogs = [...experiment.logs];
  if (Math.random() > 0.7 && newLogs.length < 200) {
    const logTemplates = [
      `[${experiment.id}] Processing batch ${Math.floor(Math.random() * experiment.batchSize) + 1}...`,
      `[${experiment.id}] Memory usage: ${newRam.toFixed(2)}GB`,
      `[${experiment.id}] CPU utilization: ${newCpu.toFixed(1)}%`,
      `[${experiment.id}] Shard ${Math.floor(Math.random() * 20) + 1} completed`,
    ];
    const timestamp = new Date(now).toISOString();
    newLogs.push(`[${timestamp}] ${logTemplates[Math.floor(Math.random() * logTemplates.length)]}`);
  }

  // Keep only last 100 log entries
  const trimmedLogs = newLogs.slice(-100);

  return {
    ...experiment,
    elapsedTime: elapsedSeconds,
    cpuUsage: newCpu,
    ramUsage: newRam,
    metrics: trimmedMetrics,
    logs: trimmedLogs,
  };
}
