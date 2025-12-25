import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { ResourceMetrics } from '../types/experiment';

interface ResourceUsageChartProps {
  metrics: ResourceMetrics[];
  title?: string;
  showLegend?: boolean;
}

export const ResourceUsageChart: React.FC<ResourceUsageChartProps> = ({
  metrics,
  title = 'Resource Usage Over Time',
  showLegend = true,
}) => {
  // Format data for chart - take last 50 points for performance
  const chartData = metrics.slice(-50).map((metric) => ({
    time: new Date(metric.timestamp).toLocaleTimeString(),
    timestamp: metric.timestamp,
    CPU: metric.cpu,
    RAM: metric.ram,
  }));

  if (chartData.length === 0) {
    return (
      <div className="h-64 flex items-center justify-center bg-gray-50 rounded-lg border border-gray-200">
        <p className="text-gray-500">No data available</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-4">
      {title && (
        <h3 className="text-sm font-semibold text-gray-700 mb-4">{title}</h3>
      )}
      <ResponsiveContainer width="100%" height={240}>
        <LineChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
          <XAxis
            dataKey="time"
            stroke="#6b7280"
            fontSize={12}
            tick={{ fill: '#6b7280' }}
            interval="preserveStartEnd"
          />
          <YAxis
            yAxisId="cpu"
            orientation="left"
            stroke="#3b82f6"
            fontSize={12}
            tick={{ fill: '#3b82f6' }}
            label={{ value: 'CPU (%)', angle: -90, position: 'insideLeft' }}
          />
          <YAxis
            yAxisId="ram"
            orientation="right"
            stroke="#10b981"
            fontSize={12}
            tick={{ fill: '#10b981' }}
            label={{ value: 'RAM (GB)', angle: 90, position: 'insideRight' }}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: 'white',
              border: '1px solid #e5e7eb',
              borderRadius: '8px',
            }}
          />
          {showLegend && <Legend />}
          <Line
            yAxisId="cpu"
            type="monotone"
            dataKey="CPU"
            stroke="#3b82f6"
            strokeWidth={2}
            dot={false}
            name="CPU (%)"
          />
          <Line
            yAxisId="ram"
            type="monotone"
            dataKey="RAM"
            stroke="#10b981"
            strokeWidth={2}
            dot={false}
            name="RAM (GB)"
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
};
