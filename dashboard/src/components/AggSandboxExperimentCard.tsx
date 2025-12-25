import React, { useState, useEffect } from 'react';
import { AggSandboxExperiment } from '../utils/aggsandboxAPI';
import { LogPanel } from './LogPanel';
import { ResourceUsageChart } from './ResourceUsageChart';
import { ResourceMetrics } from '../types/experiment';
import { formatTime } from '../utils/format';
import { 
  Clock, 
  Cpu, 
  HardDrive, 
  CheckCircle,
  XCircle,
  Loader,
  AlertTriangle,
  Activity
} from 'lucide-react';

interface AggSandboxExperimentCardProps {
  experiment: AggSandboxExperiment;
  onViewLog?: (experimentId: string) => Promise<string[]>;
}

export const AggSandboxExperimentCard: React.FC<AggSandboxExperimentCardProps> = ({
  experiment,
  onViewLog,
}) => {
  const [showDetails, setShowDetails] = useState(false);
  const [showLogs, setShowLogs] = useState(false);
  const [logs, setLogs] = useState<string[]>([]);
  const [realTimeMetrics, setRealTimeMetrics] = useState<{
    cpu: number;
    ramGB: number;
    elapsed: string;
  } | null>(null);
  const [metricsHistory, setMetricsHistory] = useState<ResourceMetrics[]>([]);

  // Update real-time metrics for running experiments and build metrics history for charts
  useEffect(() => {
    if (experiment.status !== 'running' || !experiment.pid) {
      setRealTimeMetrics(null);
      return;
    }

    const fetchMetrics = async () => {
      try {
        const response = await fetch(`/api/aggsandbox/metrics/${experiment.pid}`);
        if (response.ok) {
          const data = await response.json();
          const now = Date.now();
          setRealTimeMetrics({
            cpu: data.cpu,
            ramGB: data.ramGB,
            elapsed: data.elapsed,
          });
          
          // Build metrics history for chart (keep last 50 points)
          setMetricsHistory(prev => {
            const newMetrics: ResourceMetrics[] = [
              ...prev,
              {
                timestamp: now,
                cpu: data.cpu || 0,
                ram: data.ramGB || 0,
              }
            ];
            return newMetrics.slice(-50); // Keep last 50 points
          });
        }
      } catch (error) {
        console.error('Failed to fetch metrics:', error);
      }
    };

    fetchMetrics();
    const interval = setInterval(fetchMetrics, 2000); // Update every 2 seconds
    return () => clearInterval(interval);
  }, [experiment.status, experiment.pid]);

  // Load logs when details are expanded
  useEffect(() => {
    if (showDetails && !showLogs && onViewLog && logs.length === 0) {
      onViewLog(experiment.id).then((logLines) => {
        setLogs(logLines);
        setShowLogs(true);
      });
    }
  }, [showDetails, experiment.id, onViewLog, showLogs, logs.length]);

  const statusConfig = {
    running: { 
      icon: Loader, 
      color: 'bg-blue-100 text-blue-700 border-blue-200',
      label: 'Running',
      animate: 'animate-spin'
    },
    completed: { 
      icon: CheckCircle, 
      color: 'bg-green-100 text-green-700 border-green-200',
      label: 'Completed'
    },
    failed: { 
      icon: XCircle, 
      color: 'bg-red-100 text-red-700 border-red-200',
      label: 'Failed'
    },
  };

  const typeColors: { [key: string]: string } = {
    baseline: 'bg-blue-50 border-blue-200 text-blue-700',
    v4: 'bg-purple-50 border-purple-200 text-purple-700',
    v5: 'bg-orange-50 border-orange-200 text-orange-700',
  };

  const StatusIcon = statusConfig[experiment.status].icon;
  const statusStyle = statusConfig[experiment.status];

  const handleViewLogs = async () => {
    if (!showLogs && onViewLog) {
      const logLines = await onViewLog(experiment.id);
      setLogs(logLines);
    }
    setShowLogs(!showLogs);
  };

  // Use real-time metrics if available, otherwise use experiment data
  const currentCpu = realTimeMetrics?.cpu ?? experiment.cpuUsage ?? experiment.cpuPercent ?? 0;
  const currentRam = realTimeMetrics?.ramGB ?? experiment.ramUsage ?? experiment.ramGB ?? 0;
  const elapsedDisplay = realTimeMetrics?.elapsed 
    ? (realTimeMetrics.elapsed.includes(':') ? realTimeMetrics.elapsed.split(' ')[0] : realTimeMetrics.elapsed)
    : experiment.elapsedTime || (experiment.startTime 
      ? formatTime(Math.floor((Date.now() - experiment.startTime) / 1000))
      : 'N/A');

  const elapsedSeconds = experiment.startTime 
    ? Math.floor((Date.now() - experiment.startTime) / 1000)
    : 0;

  return (
    <div className="bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <h3 className="text-lg font-semibold text-gray-900">
                {experiment.context === 'aggsandbox' ? '🔬 AggSandbox' : 
                 experiment.context === 'lmtr' ? '⚡ L-MAPLE' :
                 experiment.context === 'sabv+lmtr' ? '🔥 S-MAPLE' :
                 '⚙️ Normal'}{' '}
                {experiment.type.toUpperCase()} N={experiment.n}
                {experiment.run && ` Run ${experiment.run}`}
              </h3>
              <span className={`px-2 py-1 text-xs font-medium rounded border ${typeColors[experiment.type] || 'bg-gray-100 text-gray-700'}`}>
                {experiment.type.toUpperCase()}
              </span>
              {experiment.context && (
                <span className={`px-2 py-1 text-xs font-medium rounded border ${
                  experiment.context === 'aggsandbox' 
                    ? 'bg-blue-50 border-blue-200 text-blue-700' 
                    : experiment.context === 'lmtr'
                    ? 'bg-purple-50 border-purple-200 text-purple-700'
                    : experiment.context === 'sabv+lmtr'
                    ? 'bg-orange-50 border-orange-200 text-orange-700'
                    : 'bg-gray-50 border-gray-200 text-gray-700'
                }`}>
                  {experiment.context === 'aggsandbox' ? 'AggSandbox' : 
                   experiment.context === 'lmtr' ? 'L-MAPLE' :
                   experiment.context === 'sabv+lmtr' ? 'S-MAPLE' :
                   'Normal'}
                </span>
              )}
              {experiment.fraudDetected && (
                <span className="px-2 py-1 text-xs font-medium rounded border bg-red-100 text-red-700 border-red-200 flex items-center gap-1">
                  <AlertTriangle className="w-3 h-3" />
                  Fraud
                </span>
              )}
            </div>
            {experiment.startTime && (
              <div className="flex items-center gap-4 text-sm text-gray-600">
                <span className="flex items-center gap-1">
                  <Clock className="w-4 h-4" />
                  Started: {new Date(experiment.startTime).toLocaleString()}
                </span>
                {experiment.status === 'running' && (
                  <span className="text-blue-600 font-medium">
                    Running: {formatTime(elapsedSeconds)}
                  </span>
                )}
              </div>
            )}
          </div>
          
          <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg border ${statusStyle.color}`}>
            <StatusIcon className={`w-4 h-4 ${('animate' in statusStyle && statusStyle.animate) || ''}`} />
            <span className="text-sm font-medium">{statusStyle.label}</span>
          </div>
        </div>
      </div>

      {/* Real-time indicator for running experiments */}
      {experiment.status === 'running' && realTimeMetrics && (
        <div className="px-4 pt-2">
          <div className="flex items-center gap-2 text-xs text-green-600 bg-green-50 px-3 py-1 rounded-full w-fit">
            <Activity className="w-3 h-3 animate-pulse" />
            <span>Live Updates</span>
          </div>
        </div>
      )}

      {/* Metrics Grid */}
      <div className="p-4 grid grid-cols-1 md:grid-cols-3 gap-3">
        {(currentCpu > 0 || experiment.cpuPercent !== undefined) && (
          <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
            <div className="flex items-center gap-2">
              <Cpu className="w-4 h-4 text-gray-500" />
              <span className="text-sm text-gray-600">CPU Usage</span>
            </div>
            <span className={`text-lg font-semibold ${experiment.status === 'running' ? 'text-blue-600' : 'text-gray-700'}`}>
              {currentCpu.toFixed(1)}%
            </span>
          </div>
        )}
        
        {(currentRam > 0 || experiment.ramGB !== undefined) && (
          <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
            <div className="flex items-center gap-2">
              <HardDrive className="w-4 h-4 text-gray-500" />
              <span className="text-sm text-gray-600">RAM Usage</span>
            </div>
            <span className={`text-lg font-semibold ${experiment.status === 'running' ? 'text-green-600' : 'text-gray-700'}`}>
              {currentRam.toFixed(2)} GB
            </span>
          </div>
        )}

        <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-gray-500" />
            <span className="text-sm text-gray-600">Elapsed Time</span>
          </div>
          <span className={`text-lg font-semibold ${
            experiment.status === 'running' ? 'text-blue-600' : 'text-gray-700'
          }`}>
            {elapsedDisplay}
          </span>
        </div>

        {experiment.userTime && (
          <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
            <div className="flex items-center gap-2">
              <Activity className="w-4 h-4 text-gray-500" />
              <span className="text-sm text-gray-600">User Time</span>
            </div>
            <span className="text-lg font-semibold text-gray-700">
              {experiment.userTime}
            </span>
          </div>
        )}

        {experiment.sysTime && (
          <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
            <div className="flex items-center gap-2">
              <Activity className="w-4 h-4 text-gray-500" />
              <span className="text-sm text-gray-600">System Time</span>
            </div>
            <span className="text-lg font-semibold text-gray-700">
              {experiment.sysTime}
            </span>
          </div>
        )}

        {experiment.l1VerifyStatus && (
          <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
            <div className="flex items-center gap-2">
              <CheckCircle className="w-4 h-4 text-gray-500" />
              <span className="text-sm text-gray-600">L1 Verify</span>
            </div>
            <span className={`text-sm font-semibold ${
              experiment.l1VerifyStatus === 'success' ? 'text-green-600' : 'text-red-600'
            }`}>
              {experiment.l1VerifyStatus === 'success' ? '✅ Success' : '❌ Failed'}
            </span>
          </div>
        )}
      </div>

      {/* Additional Info */}
      {(experiment.exitCode !== undefined || experiment.l1VerifyTime || experiment.l1VerifyGas || experiment.fraudDetected || experiment.logFile) && (
        <div className="px-4 pb-4 border-t border-gray-100 pt-4">
          <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-xs">
            {experiment.exitCode !== undefined && (
              <div className="text-gray-600">
                <span className="font-medium">Exit Code:</span> {experiment.exitCode}
              </div>
            )}
            {experiment.l1VerifyTime && (
              <div className="text-gray-600">
                <span className="font-medium">L1 Verify Time:</span> {experiment.l1VerifyTime}s
              </div>
            )}
            {experiment.l1VerifyGas && (
              <div className="text-gray-600">
                <span className="font-medium">L1 Verify Gas:</span> {experiment.l1VerifyGas.toLocaleString()}
              </div>
            )}
            {experiment.fraudDetected !== undefined && (
              <div className={experiment.fraudDetected ? 'text-red-600 font-medium' : 'text-green-600'}>
                <span className="font-medium">Fraud:</span> {experiment.fraudDetected ? '⚠️ Detected' : '✓ None'}
              </div>
            )}
            {experiment.logFile && (
              <div className="text-gray-500 col-span-full truncate">
                <span className="font-medium">Log:</span> {experiment.logFile.split('/').pop()}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Expand/Collapse Details Button */}
      <div className="px-4 pb-4">
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="w-full py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
        >
          {showDetails ? 'Hide Details' : 'Show Details'}
        </button>
      </div>

      {/* Expanded Details - Charts and Logs */}
      {showDetails && (
        <div className="px-4 pb-4 space-y-4 border-t border-gray-200 pt-4">
          {/* Resource Usage Chart - show if we have metrics history or completed experiment data */}
          {(metricsHistory.length > 0 || experiment.cpuPercent !== undefined) && (
            <ResourceUsageChart
              metrics={metricsHistory.length > 0 ? metricsHistory : (
                experiment.startTime && experiment.cpuPercent !== undefined ? [
                  {
                    timestamp: experiment.startTime,
                    cpu: experiment.cpuPercent || 0,
                    ram: experiment.ramGB || 0,
                  }
                ] : []
              )}
              title="CPU & RAM Over Time"
            />
          )}
          
          {/* Logs Panel */}
          {onViewLog && (
            <LogPanel 
              logs={logs} 
              isExpanded={true}
            />
          )}
        </div>
      )}
    </div>
  );
};

