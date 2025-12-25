// Simple Express server to serve AggSandbox experiment data
import express from 'express';
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import cors from 'cors';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

const BASE_DIR = path.resolve(__dirname, '..');
const LOG_DIR = path.join(BASE_DIR, 'logs', 'aggsandbox_exp');
const SUMMARY_FILE = path.join(LOG_DIR, 'summary.txt');

// Scan all log directories for experiments
function scanAllExperiments() {
  const experiments = new Map(); // key: context-type-n-run
  
  // 1. Scan summary.txt
  if (fs.existsSync(SUMMARY_FILE)) {
    const summaryContent = fs.readFileSync(SUMMARY_FILE, 'utf8');
    const lines = summaryContent.split('\n');
    
    lines.forEach((line, index) => {
      const experiment = parseSummaryLine(line);
      if (!experiment || !experiment.type || !experiment.n) return;
      
      // Extract run number from log file path
      let run = 1;
      if (experiment.logFile) {
        const runMatch = experiment.logFile.match(/n\d+_run(\d+)/);
        if (runMatch) run = parseInt(runMatch[1]);
        else {
          // Try to find by counting existing experiments with same type and n
          const keyPrefix = `${experiment.type}-n${experiment.n}`;
          let maxRun = 0;
          experiments.forEach((exp, key) => {
            if (key.startsWith(keyPrefix)) {
              maxRun = Math.max(maxRun, exp.run || 1);
            }
          });
          run = maxRun + 1;
        }
      }
      
      // Determine context based on type (for summary.txt from aggsandbox_exp)
      // AggSandbox context includes baseline and v5 from aggsandbox_exp
      let context = 'aggsandbox'; // Default for aggsandbox_exp (baseline and v5 stay here)
      if (experiment.type === 'v4') {
        context = 'lmtr'; // V4 = only LMTR (even from aggsandbox_exp goes to lmtr)
      }
      // v5 and baseline in aggsandbox_exp stay as 'aggsandbox'
      
      const key = `${context}-${experiment.type}-n${experiment.n}-run${run}`;
      if (!experiments.has(key)) {
        const logFile = experiment.logFile 
          ? path.resolve(BASE_DIR, experiment.logFile)
          : null;
        
        let startTime = null;
        if (logFile && fs.existsSync(logFile)) {
          try {
            const stats = fs.statSync(logFile);
            startTime = stats.birthtimeMs || stats.mtimeMs;
          } catch (err) {}
        }
        
        experiments.set(key, {
          id: key,
          context: context,
          type: experiment.type,
          n: experiment.n,
          run: run,
          status: getExperimentStatus(experiment, logFile),
          exitCode: experiment.exitCode,
          elapsedTime: experiment.elapsedTime,
          userTime: experiment.userTime,
          sysTime: experiment.sysTime,
          cpuPercent: experiment.cpuPercent,
          ramGB: experiment.ramGB,
          fraudDetected: experiment.fraudDetected,
          l1VerifyStatus: experiment.l1VerifyStatus,
          l1VerifyTime: experiment.l1VerifyTime,
          l1VerifyGas: experiment.l1VerifyGas,
          logFile: experiment.logFile,
          startTime: startTime,
          lastUpdate: Date.now(),
        });
      }
    });
  }
  
  // 2. Scan log directories for additional experiments (prioritize aggsandbox_exp)
  const logDirs = [
    path.join(BASE_DIR, 'logs', 'aggsandbox_exp'), // Main aggsandbox directory (includes baseline)
  ];
  
  logDirs.forEach(logDir => {
    try {
      if (!fs.existsSync(logDir)) return;
      const files = fs.readdirSync(logDir);
      files.forEach(file => {
        if (!file.endsWith('.log')) return;
        
        // Parse filename: baseline_n100_20241211.log, v5_n100_run1.log, v4_n50_20241211.log, etc.
        const baselineMatch = file.match(/^baseline/i);
        const v4Match = file.match(/^v4/i);
        const v5Match = file.match(/^v5/i);
        
        let type = null;
        if (baselineMatch) type = 'baseline';
        else if (v5Match) type = 'v5';
        else if (v4Match) type = 'v4';
        
        if (!type) return; // Skip files that don't match our patterns
        
        const nMatch = file.match(/n(\d+)/i);
        const runMatch = file.match(/run(\d+)/i);
        
        if (!nMatch) return;
        
        const n = parseInt(nMatch[1]);
        let run = runMatch ? parseInt(runMatch[1]) : 1;
        
        // Determine context: aggsandbox_exp -> baseline/v5=aggsandbox, v4=lmtr
        let context = 'aggsandbox';
        if (type === 'v4') {
          context = 'lmtr';
        } else if (type === 'baseline' || type === 'v5') {
          context = 'aggsandbox';
        }
        
        // If no run number in filename, try to count existing runs for this context+type+n
        const keyPrefix = `${context}-${type}-n${n}-run`;
        let maxRun = 0;
        experiments.forEach((exp, key) => {
          if (key.startsWith(keyPrefix)) {
            const existingRun = exp.run || 1;
            maxRun = Math.max(maxRun, existingRun);
          }
        });
        if (!runMatch && maxRun > 0) {
          run = maxRun + 1;
        }
        
        const key = `${context}-${type}-n${n}-run${run}`;
        
        if (!experiments.has(key)) {
          const logFile = path.join(logDir, file);
          let startTime = null;
          try {
            const stats = fs.statSync(logFile);
            startTime = stats.birthtimeMs || stats.mtimeMs;
          } catch (err) {}
          
          experiments.set(key, {
            id: key,
            context: context,
            type: type,
            n: n,
            run: run,
            status: 'completed', // Assume completed if we only have log file
            logFile: path.relative(BASE_DIR, logFile),
            startTime: startTime,
            lastUpdate: Date.now(),
          });
        }
      });
    } catch (err) {
      console.error(`Error scanning log directory:`, err.message);
    }
  });
  
  // Convert Map to Array
  return Array.from(experiments.values());
}

// Get statistics summary
function getStatisticsSummary(experiments) {
  const stats = {
    total: experiments.length,
    byContext: {
      'aggsandbox': { total: 0, byType: {}, byN: {} },
      'lmtr': { total: 0, byType: {}, byN: {} },
      'sabv+lmtr': { total: 0, byType: {}, byN: {} },
      'normal': { total: 0, byType: {}, byN: {} },
    },
    byType: {},
    byN: {},
    byStatus: { running: 0, completed: 0, failed: 0 },
    runsByConfig: {}, // context-type-n -> count
  };
  
  experiments.forEach(exp => {
    const context = exp.context || 'normal';
    
    // By context (initialize if doesn't exist)
    if (!stats.byContext[context]) {
      stats.byContext[context] = { total: 0, byType: {}, byN: {} };
    }
    stats.byContext[context].total++;
    
    // By context + type
    if (!stats.byContext[context].byType[exp.type]) {
      stats.byContext[context].byType[exp.type] = { total: 0, ns: new Set(), runs: 0 };
    }
    stats.byContext[context].byType[exp.type].total++;
    stats.byContext[context].byType[exp.type].ns.add(exp.n);
    stats.byContext[context].byType[exp.type].runs = Math.max(
      stats.byContext[context].byType[exp.type].runs,
      exp.run || 1
    );
    
    // By context + N
    if (!stats.byContext[context].byN[exp.n]) {
      stats.byContext[context].byN[exp.n] = { total: 0, types: new Set(), runs: 0 };
    }
    stats.byContext[context].byN[exp.n].total++;
    stats.byContext[context].byN[exp.n].types.add(exp.type);
    stats.byContext[context].byN[exp.n].runs = Math.max(
      stats.byContext[context].byN[exp.n].runs,
      exp.run || 1
    );
    
    // By type (across all contexts)
    if (!stats.byType[exp.type]) {
      stats.byType[exp.type] = { total: 0, ns: new Set(), runs: 0 };
    }
    stats.byType[exp.type].total++;
    stats.byType[exp.type].ns.add(exp.n);
    stats.byType[exp.type].runs = Math.max(stats.byType[exp.type].runs, exp.run || 1);
    
    // By N (across all contexts)
    if (!stats.byN[exp.n]) {
      stats.byN[exp.n] = { total: 0, types: new Set(), runs: 0 };
    }
    stats.byN[exp.n].total++;
    stats.byN[exp.n].types.add(exp.type);
    stats.byN[exp.n].runs = Math.max(stats.byN[exp.n].runs, exp.run || 1);
    
    // By status
    if (stats.byStatus[exp.status] !== undefined) {
      stats.byStatus[exp.status]++;
    }
    
    // Runs by config (context-type-n)
    const configKey = `${context}-${exp.type}-n${exp.n}`;
    if (!stats.runsByConfig[configKey]) {
      stats.runsByConfig[configKey] = 0;
    }
    stats.runsByConfig[configKey] = Math.max(stats.runsByConfig[configKey], exp.run || 1);
  });
  
  // Convert Sets to Arrays
  Object.keys(stats.byType).forEach(type => {
    stats.byType[type].ns = Array.from(stats.byType[type].ns).sort((a, b) => a - b);
  });
  
  Object.keys(stats.byN).forEach(n => {
    stats.byN[n].types = Array.from(stats.byN[n].types);
  });
  
  // Convert context Sets to Arrays
  Object.keys(stats.byContext).forEach(context => {
    Object.keys(stats.byContext[context].byType).forEach(type => {
      stats.byContext[context].byType[type].ns = Array.from(
        stats.byContext[context].byType[type].ns
      ).sort((a, b) => a - b);
    });
    Object.keys(stats.byContext[context].byN).forEach(n => {
      stats.byContext[context].byN[n].types = Array.from(stats.byContext[context].byN[n].types);
    });
  });
  
  return stats;
}

// Get process info from PID
function getProcessInfo(pid) {
  try {
    const stat = fs.readFileSync(`/proc/${pid}/stat`, 'utf8').split(' ');
    const status = fs.readFileSync(`/proc/${pid}/status`, 'utf8');
    
    const vmRSSMatch = status.match(/VmRSS:\s+(\d+)\s+kB/);
    const ramMB = vmRSSMatch ? parseInt(vmRSSMatch[1]) / 1024 : 0;
    
    return {
      pid: parseInt(pid),
      ramGB: ramMB / 1024,
      exists: true,
    };
  } catch (err) {
    return { pid: parseInt(pid), exists: false };
  }
}

// Get CPU and RAM from ps command
function getProcessMetrics(pid) {
  try {
    const result = execSync(`ps -p ${pid} -o pid,%cpu,rss,etime,cmd --no-headers 2>/dev/null || echo ""`, { encoding: 'utf8' });
    if (!result.trim()) return null;
    
    const parts = result.trim().split(/\s+/);
    const cpu = parseFloat(parts[1]) || 0;
    const rssKB = parseInt(parts[2]) || 0;
    const etime = parts.slice(3, -1).join(' ');
    
    return {
      cpu: cpu,
      ramGB: rssKB / 1024 / 1024,
      elapsed: etime,
    };
  } catch (err) {
    return null;
  }
}

// Get process start time
function getProcessStartTime(pid) {
  try {
    const stat = fs.statSync(`/proc/${pid}`);
    return stat.birthtimeMs || stat.mtimeMs;
  } catch (err) {
    return null;
  }
}

// Parse summary.txt line
function parseSummaryLine(line) {
  if (!line || line.startsWith('#') || !line.trim()) return null;
  
  const parts = line.split(',');
  const experiment = {};
  
  // First part is the type (baseline, v5, v4) without '='
  if (parts.length > 0) {
    const firstPart = parts[0].trim().toLowerCase();
    if (firstPart && (firstPart === 'baseline' || firstPart === 'v5' || firstPart === 'v4')) {
      experiment.type = firstPart;
    }
  }
  
  // Parse remaining parts with key=value format
  for (let i = 1; i < parts.length; i++) {
    const part = parts[i];
    const equalIndex = part.indexOf('=');
    if (equalIndex < 0) continue;
    
    const key = part.substring(0, equalIndex).trim().toLowerCase();
    const value = part.substring(equalIndex + 1).trim();
    
    if (!key || !value) continue;
    
    switch (key) {
      case 'type':
        experiment.type = value.toLowerCase();
        break;
      case 'n':
        experiment.n = parseInt(value);
        break;
      case 'exit':
        experiment.exitCode = parseInt(value);
        break;
      case 'time':
        experiment.elapsedTime = value;
        break;
      case 'user':
        experiment.userTime = value;
        break;
      case 'sys':
        experiment.sysTime = value;
        break;
      case 'cpu':
        const cpuValue = value.replace('%', '').replace(/[^0-9.]/g, '');
        if (cpuValue && !isNaN(parseFloat(cpuValue))) {
          experiment.cpuPercent = parseFloat(cpuValue);
        }
        break;
      case 'ram':
        experiment.ramGB = parseFloat(value.replace(/gb/gi, ''));
        break;
      case 'fraud':
        experiment.fraudDetected = value.toLowerCase() === 'true' || value.toLowerCase() === 'yes';
        break;
      case 'l1verify':
        experiment.l1VerifyStatus = value.toLowerCase();
        break;
      case 'l1verifytime':
        experiment.l1VerifyTime = parseFloat(value);
        break;
      case 'l1verifygas':
        if (value.toLowerCase() !== 'n/a') {
          experiment.l1VerifyGas = parseInt(value);
        }
        break;
      case 'log':
        experiment.logFile = value;
        break;
    }
  }
  
  return experiment;
}

// Find running processes
function findRunningExperiments() {
  const running = [];
  
  try {
    // Find ppgen processes (v4, v5, baseline)
    // Match both "ppgen...target/release" and "target/release...ppgen" patterns
    const result = execSync(`ps aux | grep -E "(ppgen.*target/release|target/release.*ppgen|ppgen.*baseline)" | grep -v grep || echo ""`, { encoding: 'utf8' });
    if (!result.trim()) return running;
    
    const lines = result.trim().split('\n');
    lines.forEach(line => {
      const parts = line.trim().split(/\s+/);
      const pid = parts[1];
      const cmd = parts.slice(10).join(' ');
      
      // Extract type (v4, v5, baseline)
      let type = 'v5';
      if (cmd.includes('baseline') || cmd.includes('--baseline')) {
        type = 'baseline';
      } else if (cmd.includes('sabv_lmtr4') || cmd.includes('v4') || cmd.includes('ppgen_sabv_lmtr4')) {
        type = 'v4';
      } else if (cmd.includes('sabv_lmtr5') || cmd.includes('v5') || cmd.includes('ppgen_sabv_lmtr5')) {
        type = 'v5';
      }
      
      // Extract N from command
      const nMatch = cmd.match(/--n-exits\s+(\d+)/);
      const n = nMatch ? parseInt(nMatch[1]) : null;
      
      // Extract proof-dir to identify run
      const proofDirMatch = cmd.match(/--proof-dir\s+([^\s]+)/);
      const proofDir = proofDirMatch ? proofDirMatch[1] : null;
      
      if (pid && n) {
        const metrics = getProcessMetrics(pid);
        const startTime = getProcessStartTime(pid);
        
        // Determine run number from proof-dir
        let run = 1;
        if (proofDir) {
          const runMatch = proofDir.match(/n\d+_run(\d+)/);
          run = runMatch ? parseInt(runMatch[1]) : 1;
        }
        
        running.push({
          pid: parseInt(pid),
          n: n,
          run: run,
          type: type,
          proofDir: proofDir,
          cpuPercent: metrics ? metrics.cpu : 0,
          ramGB: metrics ? metrics.ramGB : 0,
          elapsed: metrics ? metrics.elapsed : 'N/A',
          startTime: startTime,
          cmd: cmd,
        });
      }
    });
  } catch (err) {
    console.error('Error finding running experiments:', err);
  }
  
  return running;
}

// Get experiment status
function getExperimentStatus(experiment, logFile) {
  if (!logFile || !fs.existsSync(logFile)) {
    return 'unknown';
  }
  
  const stats = fs.statSync(logFile);
  const now = Date.now();
  const lastModified = stats.mtimeMs;
  const timeSinceModified = (now - lastModified) / 1000;
  
  if (timeSinceModified < 300) {
    try {
      const logContent = fs.readFileSync(logFile, 'utf8');
      if (logContent.includes('COMPLETED') || logContent.includes('✅')) {
        return 'completed';
      }
      if (logContent.includes('FAILED') || logContent.includes('❌')) {
        return 'failed';
      }
      return 'running';
    } catch (err) {
      return 'unknown';
    }
  }
  
  return experiment.exitCode === 0 ? 'completed' : 'failed';
}

// API: Get all experiments status (including running ones)
app.get('/api/aggsandbox/status', (req, res) => {
  try {
    const allExperiments = scanAllExperiments();
    const runningProcesses = findRunningExperiments();
    
    // Update or add running experiments
    runningProcesses.forEach(proc => {
      // Determine context based on proofDir and type
      let context = 'normal';
      if (proc.proofDir && proc.proofDir.includes('aggsandbox_exp')) {
        // From aggsandbox_exp directory: baseline and v5 = aggsandbox
        if (proc.type === 'baseline' || proc.type === 'v5') {
          context = 'aggsandbox';
        } else if (proc.type === 'v4') {
          context = 'lmtr'; // V4 = only LMTR (even from aggsandbox_exp)
        }
      } else {
        // From normal directories
        if (proc.type === 'v4') {
          context = 'lmtr'; // V4 = only LMTR
        } else if (proc.type === 'v5') {
          context = 'sabv+lmtr'; // V5 = SABV+LMTR
        } else if (proc.type === 'baseline') {
          context = 'normal'; // Baseline outside aggsandbox_exp
        }
      }
      
      const key = `${context}-${proc.type}-n${proc.n}-run${proc.run}`;
      const existingIndex = allExperiments.findIndex(e => e.id === key);
      
      if (existingIndex >= 0) {
        // Update existing - preserve existing data from summary.txt, only update running-specific fields
        const existing = allExperiments[existingIndex];
        allExperiments[existingIndex] = {
          ...existing, // Keep all existing data (elapsedTime, userTime, sysTime, etc. from summary.txt)
          status: 'running',
          pid: proc.pid,
          cpuPercent: proc.cpuPercent || existing.cpuPercent,
          ramGB: proc.ramGB || existing.ramGB,
          cpuUsage: proc.cpuPercent || existing.cpuPercent, // Add cpuUsage for compatibility
          ramUsage: proc.ramGB || existing.ramGB, // Add ramUsage for compatibility
          elapsed: proc.elapsed,
          startTime: proc.startTime || existing.startTime,
          lastUpdate: Date.now(),
          proofDir: proc.proofDir || existing.proofDir,
        };
      } else {
        // Add new running experiment
        allExperiments.push({
          id: key,
          context: context,
          type: proc.type,
          n: proc.n,
          run: proc.run,
          status: 'running',
          pid: proc.pid,
          cpuPercent: proc.cpuPercent,
          ramGB: proc.ramGB,
          elapsed: proc.elapsed,
          startTime: proc.startTime,
          lastUpdate: Date.now(),
          proofDir: proc.proofDir,
        });
      }
    });
    
    // Sort: running first, then by start time (newest first)
    allExperiments.sort((a, b) => {
      if (a.status === 'running' && b.status !== 'running') return -1;
      if (a.status !== 'running' && b.status === 'running') return 1;
      return (b.startTime || 0) - (a.startTime || 0);
    });
    
    const runningCount = allExperiments.filter(e => e.status === 'running').length;
    const completedCount = allExperiments.filter(e => e.status === 'completed').length;
    const failedCount = allExperiments.filter(e => e.status === 'failed').length;
    
    // Get statistics
    const statistics = getStatisticsSummary(allExperiments);
    
    res.json({
      total: allExperiments.length,
      experiments: allExperiments,
      runningCount,
      completedCount,
      failedCount,
      statistics,
      lastUpdate: Date.now(),
    });
  } catch (error) {
    console.error('Error fetching status:', error);
    res.status(500).json({ error: error.message });
  }
});

// API: Get statistics only
app.get('/api/aggsandbox/statistics', (req, res) => {
  try {
    const allExperiments = scanAllExperiments();
    const statistics = getStatisticsSummary(allExperiments);
    res.json(statistics);
  } catch (error) {
    console.error('Error fetching statistics:', error);
    res.status(500).json({ error: error.message });
  }
});

// API: Get experiment log
app.get('/api/aggsandbox/log/:experimentId', (req, res) => {
  try {
    const { experimentId } = req.params;
    
    // Try to find log file from running processes
    const runningProcesses = findRunningExperiments();
    const proc = runningProcesses.find(p => {
      let context = 'normal';
      if (p.proofDir && p.proofDir.includes('aggsandbox_exp')) {
        if (p.type === 'baseline' || p.type === 'v5') context = 'aggsandbox';
        else if (p.type === 'v4') context = 'lmtr';
      } else {
        if (p.type === 'v4') context = 'lmtr';
        else if (p.type === 'v5') context = 'sabv+lmtr';
        else if (p.type === 'baseline') context = 'normal';
      }
      const id = `${context}-${p.type}-n${p.n}-run${p.run}`;
      return id === experimentId;
    });
    
    if (proc && proc.proofDir) {
      const logDir = path.dirname(proc.proofDir.replace('/v5/proofs/', '/').replace('/v4/proofs/', '/'));
      const logFiles = fs.readdirSync(logDir).filter(f => f.includes(`n${proc.n}`) && f.endsWith('.log'));
      const latestLog = logFiles.sort().reverse()[0];
      
      if (latestLog) {
        const logFile = path.join(logDir, latestLog);
        if (fs.existsSync(logFile)) {
          const logContent = fs.readFileSync(logFile, 'utf8');
          const logLines = logContent.split('\n').slice(-100);
          return res.json({ lines: logLines });
        }
      }
    }
    
    // Find from scanned experiments
    const allExperiments = scanAllExperiments();
    const experiment = allExperiments.find(e => e.id === experimentId);
    
    if (experiment && experiment.logFile) {
      const logFile = path.resolve(BASE_DIR, experiment.logFile);
      if (fs.existsSync(logFile)) {
        const logContent = fs.readFileSync(logFile, 'utf8');
        const logLines = logContent.split('\n').slice(-100);
        return res.json({ lines: logLines });
      }
    }
    
    res.json({ lines: [] });
  } catch (error) {
    console.error('Error fetching log:', error);
    res.status(500).json({ error: error.message });
  }
});

// API: Get real-time metrics for running experiment
app.get('/api/aggsandbox/metrics/:pid', (req, res) => {
  try {
    const { pid } = req.params;
    const metrics = getProcessMetrics(pid);
    
    if (!metrics) {
      return res.status(404).json({ error: 'Process not found' });
    }
    
    const startTime = getProcessStartTime(pid);
    
    res.json({
      pid: parseInt(pid),
      cpu: metrics.cpu,
      ramGB: metrics.ramGB,
      elapsed: metrics.elapsed,
      startTime: startTime,
      timestamp: Date.now(),
    });
  } catch (error) {
    console.error('Error fetching metrics:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 AggSandbox API server running on http://localhost:${PORT}`);
  console.log(`📁 Log directory: ${LOG_DIR}`);
  console.log(`📊 Scanning all experiment data...`);
});
