import React, { useState } from 'react';
import { Experiment } from '../types/experiment';
import { MetricItem } from './MetricItem';
import { ResourceUsageChart } from './ResourceUsageChart';
import { LogPanel } from './LogPanel';
import { formatDate } from '../utils/format';
import { 
  Clock, 
  Cpu, 
  HardDrive, 
  Package,
  CheckCircle,
  XCircle,
  Loader,
  AlertCircle
} from 'lucide-react';

const statusConfig = {
  pending: { 
    icon: AlertCircle, 
    color: 'bg-yellow-100 text-yellow-700 border-yellow-200',
    label: 'Pending'
  },
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

const contextColors = {
  baseline: 'bg-blue-50 border-blue-200 text-blue-700',
  lmtr: 'bg-green-50 border-green-200 text-green-700',
  sabv: 'bg-purple-50 border-purple-200 text-purple-700',
  'sabv+lmtr': 'bg-orange-50 border-orange-200 text-orange-700',
};

export const ExperimentCard: React.FC<{ experiment: Experiment }> = ({ experiment }) => {
  const [showDetails, setShowDetails] = useState(false);
  const StatusIcon = statusConfig[experiment.status].icon;
  const statusStyle = statusConfig[experiment.status];

  return (
    <div className="bg-white rounded-lg border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
      {/* Header */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-2">
              <h3 className="text-lg font-semibold text-gray-900">{experiment.name}</h3>
              <span className={`px-2 py-1 text-xs font-medium rounded border ${contextColors[experiment.context]}`}>
                {experiment.context.toUpperCase()}
              </span>
            </div>
            <div className="flex items-center gap-4 text-sm text-gray-600">
              <span className="flex items-center gap-1">
                <Package className="w-4 h-4" />
                Batch: {experiment.batchSize}
              </span>
              <span className="flex items-center gap-1">
                <Clock className="w-4 h-4" />
                Started: {formatDate(experiment.startTime)}
              </span>
            </div>
          </div>
          
          <div className={`flex items-center gap-2 px-3 py-1.5 rounded-lg border ${statusStyle.color}`}>
            <StatusIcon className={`w-4 h-4 ${('animate' in statusStyle && statusStyle.animate) || ''}`} />
            <span className="text-sm font-medium">{statusStyle.label}</span>
          </div>
        </div>

        {/* Modules */}
        <div className="flex gap-2 flex-wrap">
          {experiment.modules.map((module) => (
            <span
              key={module}
              className="px-2 py-1 bg-gray-100 text-gray-700 text-xs rounded"
            >
              {module}
            </span>
          ))}
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="p-4 grid grid-cols-1 md:grid-cols-3 gap-3">
        <MetricItem
          label="CPU Usage"
          value={experiment.cpuUsage}
          unit="percentage"
          icon={<Cpu className="w-4 h-4" />}
        />
        <MetricItem
          label="RAM Usage"
          value={experiment.ramUsage}
          unit="gb"
          icon={<HardDrive className="w-4 h-4" />}
        />
        <MetricItem
          label="Elapsed Time"
          value={experiment.elapsedTime}
          unit="time"
          icon={<Clock className="w-4 h-4" />}
        />
      </div>

      {/* Expand Button */}
      <div className="px-4 pb-4">
        <button
          onClick={() => setShowDetails(!showDetails)}
          className="w-full py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
        >
          {showDetails ? 'Hide Details' : 'Show Details'}
        </button>
      </div>

      {/* Expanded Details */}
      {showDetails && (
        <div className="px-4 pb-4 space-y-4 border-t border-gray-200 pt-4">
          <ResourceUsageChart
            metrics={experiment.metrics}
            title="CPU & RAM Over Time"
          />
          <LogPanel logs={experiment.logs} isExpanded={false} />
        </div>
      )}
    </div>
  );
};
