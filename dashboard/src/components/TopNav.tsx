import React from 'react';
import { Activity, TrendingUp } from 'lucide-react';

interface TopNavProps {
  totalExperiments: number;
  runningCount: number;
  completedCount: number;
  failedCount: number;
  pendingCount: number;
}

export const TopNav: React.FC<TopNavProps> = ({
  totalExperiments,
  runningCount,
  completedCount,
  failedCount,
  pendingCount,
}) => {
  return (
    <nav className="bg-white border-b border-gray-200 sticky top-0 z-10">
      <div className="px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Stats */}
          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2">
              <Activity className="w-5 h-5 text-gray-500" />
              <span className="text-sm font-medium text-gray-700">
                {totalExperiments} Experiments
              </span>
            </div>
            <div className="h-6 w-px bg-gray-300" />
            <div className="flex items-center gap-4 text-sm">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse" />
                <span className="text-gray-600">{runningCount} Running</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 bg-green-500 rounded-full" />
                <span className="text-gray-600">{completedCount} Completed</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 bg-yellow-500 rounded-full" />
                <span className="text-gray-600">{pendingCount} Pending</span>
              </div>
              {failedCount > 0 && (
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 bg-red-500 rounded-full" />
                  <span className="text-gray-600">{failedCount} Failed</span>
                </div>
              )}
            </div>
          </div>

          {/* Right side actions */}
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2 text-sm text-gray-500">
              <TrendingUp className="w-4 h-4" />
              <span>Live Updates</span>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};
