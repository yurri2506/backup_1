import React from 'react';
import { ExperimentContext } from '../types/experiment';
import { Check } from 'lucide-react';

interface ExperimentContextSelectorProps {
  selectedContext: ExperimentContext | 'all';
  onContextChange: (context: ExperimentContext | 'all') => void;
}

const contexts: Array<{ value: ExperimentContext | 'all'; label: string; color: string }> = [
  { value: 'all', label: 'All Contexts', color: 'bg-gray-100 text-gray-700' },
  { value: 'baseline', label: 'Baseline', color: 'bg-blue-100 text-blue-700' },
  { value: 'lmtr', label: 'LMTR', color: 'bg-green-100 text-green-700' },
  { value: 'sabv', label: 'SABV', color: 'bg-purple-100 text-purple-700' },
  { value: 'sabv+lmtr', label: 'SABV+LMTR', color: 'bg-orange-100 text-orange-700' },
];

export const ExperimentContextSelector: React.FC<ExperimentContextSelectorProps> = ({
  selectedContext,
  onContextChange,
}) => {
  return (
    <div className="flex gap-2 flex-wrap">
      {contexts.map((context) => (
        <button
          key={context.value}
          onClick={() => onContextChange(context.value)}
          className={`
            px-4 py-2 rounded-lg text-sm font-medium transition-all
            ${selectedContext === context.value
              ? `${context.color} ring-2 ring-offset-2 ring-gray-400`
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }
          `}
        >
          <div className="flex items-center gap-2">
            {selectedContext === context.value && (
              <Check className="w-4 h-4" />
            )}
            {context.label}
          </div>
        </button>
      ))}
    </div>
  );
};
