import React from 'react';
import { formatTime } from '../utils/format';

interface MetricItemProps {
  label: string;
  value: string | number;
  unit?: string;
  icon?: React.ReactNode;
  trend?: 'up' | 'down' | 'neutral';
}

export const MetricItem: React.FC<MetricItemProps> = ({
  label,
  value,
  unit,
  icon,
  trend,
}) => {
  const displayValue = typeof value === 'number' && unit === 'time' 
    ? formatTime(value)
    : typeof value === 'number' && unit === 'percentage'
      ? `${value.toFixed(1)}%`
      : typeof value === 'number' && unit === 'gb'
        ? `${value.toFixed(2)} GB`
        : `${value}${unit ? ` ${unit}` : ''}`;

  const trendColor = trend === 'up' 
    ? 'text-green-600' 
    : trend === 'down' 
      ? 'text-red-600' 
      : 'text-gray-600';

  return (
    <div className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200 hover:border-gray-300 transition-colors">
      <div className="flex items-center gap-2">
        {icon && <div className="text-gray-500">{icon}</div>}
        <span className="text-sm text-gray-600">{label}</span>
      </div>
      <span className={`text-lg font-semibold ${trendColor}`}>
        {displayValue}
      </span>
    </div>
  );
};
