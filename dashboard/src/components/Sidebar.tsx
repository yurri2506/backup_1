import React, { useState } from 'react';
import { ExperimentContext } from '../types/experiment';
import { Activity, Settings, Home, BarChart3, FlaskConical, ChevronDown, ChevronRight } from 'lucide-react';

type PageType = 'dashboard' | 'experiments' | 'aggsandbox' | 'statistics';

interface SidebarProps {
  selectedPage: PageType;
  selectedContext: ExperimentContext | 'all';
  onPageChange: (page: PageType) => void;
  onContextChange: (context: ExperimentContext | 'all') => void;
}

const mainMenuItems = [
  { value: 'dashboard' as const, label: 'Dashboard', icon: Home },
  { value: 'experiments' as const, label: 'Experiments', icon: Activity },
  { value: 'aggsandbox' as const, label: 'AggSandbox', icon: FlaskConical },
  { value: 'statistics' as const, label: 'Statistics', icon: BarChart3 },
];

const contextMenuItems = [
  { value: 'all' as const, label: 'All Experiments' },
  { value: 'baseline' as const, label: 'Baseline' },
  { value: 'lmtr' as const, label: 'L-MAPLE' },
  { value: 'sabv' as const, label: 'SABV' },
  { value: 'sabv+lmtr' as const, label: 'S-MAPLE' },
];

  const contextColors = {
    all: 'text-gray-700 hover:bg-gray-100',
    baseline: 'text-blue-700 hover:bg-blue-50',
    lmtr: 'text-purple-700 hover:bg-purple-50',
    sabv: 'text-purple-700 hover:bg-purple-50',
    'sabv+lmtr': 'text-orange-700 hover:bg-orange-50',
  };

export const Sidebar: React.FC<SidebarProps> = ({ 
  selectedPage, 
  selectedContext, 
  onPageChange, 
  onContextChange 
}) => {
  const [showContextMenu, setShowContextMenu] = useState(selectedPage === 'experiments');

  return (
    <aside className="w-64 bg-white border-r border-gray-200 flex flex-col h-screen sticky top-0">
      {/* Logo/Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-100 rounded-lg">
            <Activity className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-gray-900">Experiment Monitor</h1>
            <p className="text-xs text-gray-500">Real-time monitoring</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 overflow-y-auto">
        <div className="space-y-1">
          {mainMenuItems.map((item) => {
            const Icon = item.icon;
            const isActive = selectedPage === item.value;
            const isExperiments = item.value === 'experiments';
            
            return (
              <div key={item.value}>
                <button
                  onClick={() => {
                    onPageChange(item.value);
                    if (isExperiments) {
                      setShowContextMenu(!showContextMenu);
                    }
                  }}
                  className={`
                    w-full flex items-center justify-between px-4 py-3 rounded-lg text-sm font-medium transition-all
                    ${isActive
                      ? 'bg-blue-50 text-blue-700 border border-blue-200'
                      : 'text-gray-600 hover:bg-gray-50'
                    }
                  `}
                >
                  <div className="flex items-center gap-3">
                    <Icon className={`w-5 h-5 ${isActive ? 'text-blue-600' : 'text-gray-400'}`} />
                    {item.label}
                  </div>
                  {isExperiments && (
                    showContextMenu ? (
                      <ChevronDown className="w-4 h-4 text-gray-400" />
                    ) : (
                      <ChevronRight className="w-4 h-4 text-gray-400" />
                    )
                  )}
                </button>
                
                {/* Context submenu for Experiments */}
                {isExperiments && showContextMenu && (
                  <div className="ml-8 mt-1 space-y-1">
                    {contextMenuItems.map((ctxItem) => {
                      const isContextActive = selectedContext === ctxItem.value && isActive;
                      return (
                        <button
                          key={ctxItem.value}
                          onClick={() => {
                            onContextChange(ctxItem.value);
                            onPageChange('experiments');
                          }}
                          className={`
                            w-full flex items-center gap-2 px-3 py-2 rounded-lg text-sm transition-all
                            ${isContextActive
                              ? `${contextColors[ctxItem.value]} bg-opacity-10 font-medium`
                              : 'text-gray-500 hover:bg-gray-50'
                            }
                          `}
                        >
                          <div className={`w-1.5 h-1.5 rounded-full ${isContextActive ? 'bg-current' : 'bg-gray-300'}`} />
                          {ctxItem.label}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-200">
        <button className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-gray-600 hover:bg-gray-50 transition-colors">
          <Settings className="w-5 h-5 text-gray-400" />
          Settings
        </button>
      </div>
    </aside>
  );
};
