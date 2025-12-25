import React, { useState, useRef, useEffect } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';

interface LogPanelProps {
  logs: string[];
  isExpanded?: boolean;
}

export const LogPanel: React.FC<LogPanelProps> = ({ logs, isExpanded: initialExpanded = false }) => {
  const [isExpanded, setIsExpanded] = useState(initialExpanded);
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isExpanded && logEndRef.current) {
      logEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [logs, isExpanded]);

  return (
    <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 py-3 flex items-center justify-between hover:bg-gray-50 transition-colors"
      >
        <div className="flex items-center gap-2">
          <span className="text-sm font-semibold text-gray-700">Logs</span>
          <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
            {logs.length} entries
          </span>
        </div>
        {isExpanded ? (
          <ChevronUp className="w-4 h-4 text-gray-500" />
        ) : (
          <ChevronDown className="w-4 h-4 text-gray-500" />
        )}
      </button>
      
      {isExpanded && (
        <div className="max-h-64 overflow-y-auto bg-gray-900 text-green-400 font-mono text-xs p-4">
          {logs.length === 0 ? (
            <p className="text-gray-500">No logs available</p>
          ) : (
            <>
              {logs.map((log, index) => (
                <div
                  key={index}
                  className="py-1 hover:bg-gray-800 px-2 rounded"
                >
                  {log}
                </div>
              ))}
              <div ref={logEndRef} />
            </>
          )}
        </div>
      )}
    </div>
  );
};
