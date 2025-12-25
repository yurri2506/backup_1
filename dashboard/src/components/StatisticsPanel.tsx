import React from 'react';

interface Statistics {
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
}

interface StatisticsPanelProps {
  statistics: Statistics | null;
}

export const StatisticsPanel: React.FC<StatisticsPanelProps> = ({ statistics }) => {
  if (!statistics) {
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <p className="text-gray-500">Loading statistics...</p>
      </div>
    );
  }

  const typeColors: { [key: string]: string } = {
    v4: 'bg-purple-50 border-purple-200 text-purple-700',
    v5: 'bg-orange-50 border-orange-200 text-orange-700',
    baseline: 'bg-blue-50 border-blue-200 text-blue-700',
  };

  return (
    <div className="space-y-4">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="text-sm text-gray-600 mb-1">Total Experiments</div>
          <div className="text-3xl font-bold text-gray-900">{statistics.total}</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="text-sm text-gray-600 mb-1">Running</div>
          <div className="text-3xl font-bold text-blue-600">{statistics.byStatus.running}</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="text-sm text-gray-600 mb-1">Completed</div>
          <div className="text-3xl font-bold text-green-600">{statistics.byStatus.completed}</div>
        </div>
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="text-sm text-gray-600 mb-1">Failed</div>
          <div className="text-3xl font-bold text-red-600">{statistics.byStatus.failed}</div>
        </div>
      </div>

      {/* By Context */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Experiments by Context</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* AggSandbox Context */}
          {statistics.byContext['aggsandbox'] && (
            <div className="p-4 rounded-lg border border-blue-200 bg-blue-50">
              <div className="text-lg font-bold text-blue-900 mb-3">🔬 AggSandbox</div>
              <div className="text-xs text-blue-700 mb-2">(baseline + v5 từ aggsandbox_exp)</div>
              <div className="text-3xl font-bold text-blue-700 mb-4">
                {statistics.byContext['aggsandbox'].total} experiments
              </div>
              <div className="space-y-2">
                {Object.entries(statistics.byContext['aggsandbox'].byType).map(([type, data]) => (
                  <div key={type} className="text-sm">
                    <span className="font-medium">{type.toUpperCase()}:</span>{' '}
                    <span className="text-gray-700">{data.total} exp</span>
                    <span className="text-gray-500 ml-2">(N: {data.ns.join(', ')})</span>
                  </div>
                ))}
                {Object.keys(statistics.byContext['aggsandbox'].byType).length === 0 && (
                  <div className="text-sm text-gray-500">No experiments yet</div>
                )}
              </div>
            </div>
          )}
          
          {/* LMTR Context (V4 = only LMTR) */}
          {statistics.byContext['lmtr'] && (
            <div className="p-4 rounded-lg border border-purple-200 bg-purple-50">
              <div className="text-lg font-bold text-purple-900 mb-3">⚡ L-MAPLE (V4)</div>
              <div className="text-3xl font-bold text-purple-700 mb-4">
                {statistics.byContext['lmtr'].total} experiments
              </div>
              <div className="space-y-2">
                {Object.entries(statistics.byContext['lmtr'].byType).map(([type, data]) => (
                  <div key={type} className="text-sm">
                    <span className="font-medium">{type.toUpperCase()}:</span>{' '}
                    <span className="text-gray-700">{data.total} exp</span>
                    <span className="text-gray-500 ml-2">(N: {data.ns.join(', ')})</span>
                  </div>
                ))}
                {Object.keys(statistics.byContext['lmtr'].byType).length === 0 && (
                  <div className="text-sm text-gray-500">No experiments yet</div>
                )}
              </div>
            </div>
          )}
          
          {/* SABV+LMTR Context (V5 = SABV+LMTR) */}
          {statistics.byContext['sabv+lmtr'] && (
            <div className="p-4 rounded-lg border border-orange-200 bg-orange-50">
              <div className="text-lg font-bold text-orange-900 mb-3">🔥 S-MAPLE (V5)</div>
              <div className="text-3xl font-bold text-orange-700 mb-4">
                {statistics.byContext['sabv+lmtr'].total} experiments
              </div>
              <div className="space-y-2">
                {Object.entries(statistics.byContext['sabv+lmtr'].byType).map(([type, data]) => (
                  <div key={type} className="text-sm">
                    <span className="font-medium">{type.toUpperCase()}:</span>{' '}
                    <span className="text-gray-700">{data.total} exp</span>
                    <span className="text-gray-500 ml-2">(N: {data.ns.join(', ')})</span>
                  </div>
                ))}
                {Object.keys(statistics.byContext['sabv+lmtr'].byType).length === 0 && (
                  <div className="text-sm text-gray-500">No experiments yet</div>
                )}
              </div>
            </div>
          )}
          
          {/* Normal Context */}
          {statistics.byContext['normal'] && statistics.byContext['normal'].total > 0 && (
            <div className="p-4 rounded-lg border border-gray-200 bg-gray-50">
              <div className="text-lg font-bold text-gray-900 mb-3">⚙️ Normal</div>
              <div className="text-3xl font-bold text-gray-700 mb-4">
                {statistics.byContext['normal'].total} experiments
              </div>
              <div className="space-y-2">
                {Object.entries(statistics.byContext['normal'].byType).map(([type, data]) => (
                  <div key={type} className="text-sm">
                    <span className="font-medium">{type.toUpperCase()}:</span>{' '}
                    <span className="text-gray-700">{data.total} exp</span>
                    <span className="text-gray-500 ml-2">(N: {data.ns.join(', ')})</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* By Type (All Contexts) */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Experiments by Type (All Contexts)</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {Object.entries(statistics.byType).map(([type, data]) => (
            <div
              key={type}
              className={`p-4 rounded-lg border ${typeColors[type] || 'bg-gray-50 border-gray-200'}`}
            >
              <div className="text-sm font-medium mb-2">{type.toUpperCase()}</div>
              <div className="text-2xl font-bold mb-2">{data.total} experiments</div>
              <div className="text-sm text-gray-600 mb-1">
                N values: {data.ns.join(', ')}
              </div>
              <div className="text-sm text-gray-600">
                Max runs: {data.runs}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* By N */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Experiments by N</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
          {Object.entries(statistics.byN)
            .sort(([a], [b]) => parseInt(a) - parseInt(b))
            .map(([n, data]) => (
              <div key={n} className="p-3 bg-gray-50 rounded-lg border border-gray-200">
                <div className="text-sm font-medium text-gray-700 mb-1">N={n}</div>
                <div className="text-xl font-bold text-gray-900 mb-1">{data.total}</div>
                <div className="text-xs text-gray-600">
                  Types: {data.types.join(', ')}
                </div>
                <div className="text-xs text-gray-600">
                  Runs: {data.runs}
                </div>
              </div>
            ))}
        </div>
      </div>

      {/* Runs by Config */}
      <div className="bg-white rounded-lg border border-gray-200 p-4">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Runs per Configuration</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {Object.entries(statistics.runsByConfig)
            .sort(([a], [b]) => {
              const [typeA, nA] = a.split('-n');
              const [typeB, nB] = b.split('-n');
              if (typeA !== typeB) return typeA.localeCompare(typeB);
              return parseInt(nA) - parseInt(nB);
            })
            .map(([config, runs]) => {
              const [type, n] = config.split('-n');
              return (
                <div
                  key={config}
                  className={`p-3 rounded-lg border ${
                    typeColors[type] || 'bg-gray-50 border-gray-200'
                  }`}
                >
                  <div className="text-sm font-medium mb-1">
                    {type.toUpperCase()} N={n}
                  </div>
                  <div className="text-2xl font-bold">{runs} runs</div>
                </div>
              );
            })}
        </div>
      </div>
    </div>
  );
};

