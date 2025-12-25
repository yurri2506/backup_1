import { useState, useMemo } from 'react';
import { useExperiments } from './hooks/useExperiments';
import { useAggSandbox } from './hooks/useAggSandbox';
import { ExperimentCard } from './components/ExperimentCard';
import { AggSandboxExperimentCard } from './components/AggSandboxExperimentCard';
import { StatisticsPanel } from './components/StatisticsPanel';
import { Sidebar } from './components/Sidebar';
import { TopNav } from './components/TopNav';
import type { AggSandboxExperiment } from './utils/aggsandboxAPI';

type PageType = 'dashboard' | 'experiments' | 'aggsandbox' | 'statistics';

function App() {
  const { experiments, selectedContext, setSelectedContext, getExperimentsByStatus } = useExperiments();
  const { status: aggsandboxStatus, loading: aggsandboxLoading, getExperimentLogs } = useAggSandbox();
  const [selectedPage, setSelectedPage] = useState<PageType>('dashboard');

  const running = getExperimentsByStatus('running');
  const completed = getExperimentsByStatus('completed');
  const failed = getExperimentsByStatus('failed');
  const pending = getExperimentsByStatus('pending');

  const handleViewAggSandboxLog = async (experimentId: string) => {
    const logs = await getExperimentLogs(experimentId);
    // Logs will be handled by the component's state
    return logs;
  };

  // AggSandbox View Component with Run Filter
  const AggSandboxView = ({ 
    experiments, 
    onViewLog 
  }: { 
    experiments: AggSandboxExperiment[];
    onViewLog: (id: string) => Promise<string[]>;
  }) => {
    const [selectedRun, setSelectedRun] = useState<number | 'all'>('all');
    const [selectedType, setSelectedType] = useState<string | 'all'>('all');
    
    // Get unique runs and types
    const runs = useMemo(() => {
      const runSet = new Set<number>();
      experiments.forEach(e => {
        if (e.run) runSet.add(e.run);
      });
      return Array.from(runSet).sort((a, b) => b - a); // Sort descending
    }, [experiments]);
    
    const types = useMemo(() => {
      const typeSet = new Set<string>();
      experiments.forEach(e => typeSet.add(e.type));
      return Array.from(typeSet).sort();
    }, [experiments]);
    
    // Filter experiments
    const filteredExperiments = useMemo(() => {
      return experiments.filter(e => {
        if (selectedRun !== 'all' && e.run !== selectedRun) return false;
        if (selectedType !== 'all' && e.type !== selectedType) return false;
        return true;
      });
    }, [experiments, selectedRun, selectedType]);
    
    return (
      <div className="space-y-4">
        {/* Filter Tabs */}
        <div className="bg-white rounded-lg border border-gray-200 p-4">
          <div className="flex flex-wrap gap-4 items-center">
            {/* Type Filter */}
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-gray-700">Type:</span>
              <div className="flex gap-2">
                <button
                  onClick={() => setSelectedType('all')}
                  className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                    selectedType === 'all'
                      ? 'bg-blue-100 text-blue-700 font-medium'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  All
                </button>
                {types.map((type: string) => (
                  <button
                    key={type}
                    onClick={() => setSelectedType(type)}
                    className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                      selectedType === type
                        ? 'bg-blue-100 text-blue-700 font-medium'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                  >
                    {type.toUpperCase()}
                  </button>
                ))}
              </div>
            </div>
            
            {/* Run Filter */}
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-gray-700">Run:</span>
              <div className="flex gap-2 flex-wrap">
                <button
                  onClick={() => setSelectedRun('all')}
                  className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                    selectedRun === 'all'
                      ? 'bg-blue-100 text-blue-700 font-medium'
                      : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                  }`}
                >
                  All ({experiments.length})
                </button>
                {runs.map((run: number) => {
                  const count = experiments.filter(e => e.run === run).length;
                  return (
                    <button
                      key={run}
                      onClick={() => setSelectedRun(run)}
                      className={`px-3 py-1 text-sm rounded-lg transition-colors ${
                        selectedRun === run
                          ? 'bg-blue-100 text-blue-700 font-medium'
                          : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                      }`}
                    >
                      Run {run} ({count})
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
          
          {/* Active Filters Summary */}
          {(selectedRun !== 'all' || selectedType !== 'all') && (
            <div className="mt-3 pt-3 border-t border-gray-200">
              <span className="text-sm text-gray-600">
                Showing {filteredExperiments.length} of {experiments.length} experiments
                {selectedType !== 'all' && ` • Type: ${selectedType.toUpperCase()}`}
                {selectedRun !== 'all' && ` • Run: ${selectedRun}`}
              </span>
            </div>
          )}
        </div>
        
        {/* Experiments Grid */}
        {filteredExperiments.length > 0 ? (
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {filteredExperiments.map((experiment) => (
              <AggSandboxExperimentCard
                key={experiment.id}
                experiment={experiment}
                onViewLog={async (id) => {
                  return await onViewLog(id);
                }}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
            <p className="text-gray-500">No experiments found for selected filters</p>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="min-h-screen bg-gray-50 flex">
      {/* Sidebar */}
      <Sidebar
        selectedPage={selectedPage}
        selectedContext={selectedContext}
        onPageChange={setSelectedPage}
        onContextChange={setSelectedContext}
      />

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Navigation */}
        <TopNav
          totalExperiments={experiments.length}
          runningCount={running.length}
          completedCount={completed.length}
          failedCount={failed.length}
          pendingCount={pending.length}
        />

        {/* Main Content Area */}
        <main className="flex-1 overflow-y-auto">
          <div className="p-6">
            {/* Stats Cards - Show on all pages */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-center gap-2 mb-1">
                  <div className="w-2 h-2 bg-blue-500 rounded-full animate-pulse" />
                  <span className="text-sm text-blue-600 font-medium">Running</span>
                </div>
                <div className="text-2xl font-bold text-blue-900">
                  {selectedPage === 'aggsandbox' && aggsandboxStatus 
                    ? aggsandboxStatus.runningCount 
                    : running.length}
                </div>
              </div>
              <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                <div className="flex items-center gap-2 mb-1">
                  <div className="w-2 h-2 bg-green-500 rounded-full" />
                  <span className="text-sm text-green-600 font-medium">Completed</span>
                </div>
                <div className="text-2xl font-bold text-green-900">
                  {selectedPage === 'aggsandbox' && aggsandboxStatus 
                    ? aggsandboxStatus.completedCount 
                    : completed.length}
                </div>
              </div>
              <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                <div className="flex items-center gap-2 mb-1">
                  <div className="w-2 h-2 bg-yellow-500 rounded-full" />
                  <span className="text-sm text-yellow-600 font-medium">Pending</span>
                </div>
                <div className="text-2xl font-bold text-yellow-900">
                  {selectedPage === 'aggsandbox' 
                    ? '-' 
                    : pending.length}
                </div>
              </div>
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <div className="flex items-center gap-2 mb-1">
                  <div className="w-2 h-2 bg-red-500 rounded-full" />
                  <span className="text-sm text-red-600 font-medium">Failed</span>
                </div>
                <div className="text-2xl font-bold text-red-900">
                  {selectedPage === 'aggsandbox' && aggsandboxStatus 
                    ? aggsandboxStatus.failedCount 
                    : failed.length}
                </div>
              </div>
            </div>

            {/* Content based on selected page */}
            {selectedPage === 'dashboard' ? (
              <div className="space-y-6">
                <div className="bg-white rounded-lg border border-gray-200 p-6">
                  <h2 className="text-xl font-semibold text-gray-900 mb-4">📊 Dashboard Overview</h2>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div>
                      <h3 className="text-sm font-medium text-gray-500 mb-2">Mock Experiments</h3>
                      <div className="text-3xl font-bold text-gray-900">{experiments.length}</div>
                      <p className="text-sm text-gray-500 mt-1">Total mock experiments</p>
                    </div>
                    <div>
                      <h3 className="text-sm font-medium text-gray-500 mb-2">AggSandbox Experiments</h3>
                      <div className="text-3xl font-bold text-gray-900">
                        {aggsandboxStatus ? aggsandboxStatus.experiments.length : '...'}
                      </div>
                      <p className="text-sm text-gray-500 mt-1">Real experiments from logs</p>
                    </div>
                  </div>
                  
                  {/* AggSandbox Experiments Preview */}
                  {aggsandboxStatus && aggsandboxStatus.experiments.length > 0 && (
                    <div className="mt-6 pt-6 border-t border-gray-200">
                      <div className="flex items-center justify-between mb-4">
                        <h3 className="text-lg font-semibold text-gray-900">Recent AggSandbox Experiments</h3>
                        <button
                          onClick={() => setSelectedPage('aggsandbox')}
                          className="text-sm text-blue-600 hover:text-blue-700 font-medium"
                        >
                          View All ({aggsandboxStatus.experiments.length}) →
                        </button>
                      </div>
                      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
                        {aggsandboxStatus.experiments.slice(0, 4).map((experiment) => (
                          <div
                            key={experiment.id}
                            className="p-4 border border-gray-200 rounded-lg hover:border-blue-300 transition-colors cursor-pointer"
                            onClick={() => setSelectedPage('aggsandbox')}
                          >
                            <div className="flex items-center justify-between mb-2">
                              <span className="text-sm font-medium text-gray-900">
                                {experiment.type.toUpperCase()} N={experiment.n}
                                {experiment.run && ` Run ${experiment.run}`}
                              </span>
                              <span className={`px-2 py-1 text-xs rounded ${
                                experiment.status === 'running' ? 'bg-blue-100 text-blue-700' :
                                experiment.status === 'completed' ? 'bg-green-100 text-green-700' :
                                'bg-red-100 text-red-700'
                              }`}>
                                {experiment.status}
                              </span>
                            </div>
                            <div className="flex items-center gap-4 text-xs text-gray-500">
                              {experiment.cpuUsage && (
                                <span>CPU: {experiment.cpuUsage.toFixed(0)}%</span>
                              )}
                              {experiment.ramUsage && (
                                <span>RAM: {experiment.ramUsage.toFixed(1)} GB</span>
                              )}
                              {experiment.elapsedTime && (
                                <span>Time: {experiment.elapsedTime}</span>
                              )}
                            </div>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
                
                <div className="bg-white rounded-lg border border-gray-200 p-6">
                  <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <button
                      onClick={() => setSelectedPage('experiments')}
                      className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left"
                    >
                      <div className="text-sm font-medium text-gray-900">View Experiments</div>
                      <div className="text-xs text-gray-500 mt-1">Mock data experiments</div>
                    </button>
                    <button
                      onClick={() => setSelectedPage('aggsandbox')}
                      className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left"
                    >
                      <div className="text-sm font-medium text-gray-900">View AggSandbox</div>
                      <div className="text-xs text-gray-500 mt-1">Real-time experiments</div>
                    </button>
                    <button
                      onClick={() => setSelectedPage('statistics')}
                      className="p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors text-left"
                    >
                      <div className="text-sm font-medium text-gray-900">View Statistics</div>
                      <div className="text-xs text-gray-500 mt-1">Detailed analytics</div>
                    </button>
                  </div>
                </div>
              </div>
            ) : selectedPage === 'experiments' ? (
              experiments.length === 0 ? (
                <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
                  <p className="text-gray-500">No experiments found for selected context</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                  {experiments.map((experiment) => (
                    <ExperimentCard key={experiment.id} experiment={experiment} />
                  ))}
                </div>
              )
            ) : selectedPage === 'aggsandbox' ? (
              aggsandboxLoading ? (
                <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
                  <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                  <p className="mt-4 text-gray-500">Loading AggSandbox experiments...</p>
                </div>
              ) : aggsandboxStatus && aggsandboxStatus.experiments.length > 0 ? (
                <AggSandboxView 
                  experiments={aggsandboxStatus.experiments}
                  onViewLog={handleViewAggSandboxLog}
                />
              ) : (
                <div className="text-center py-12 bg-white rounded-lg border border-gray-200">
                  <p className="text-gray-500">No AggSandbox experiments found</p>
                  <p className="text-sm text-gray-400 mt-2">Check logs/aggsandbox_exp/ for experiment data</p>
                </div>
              )
            ) : selectedPage === 'statistics' ? (
              <StatisticsPanel statistics={aggsandboxStatus?.statistics || null} />
            ) : null}
          </div>
        </main>
      </div>
    </div>
  );
}

export default App;
