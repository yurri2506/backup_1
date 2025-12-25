import { useState, useEffect, useCallback } from 'react';
import { Experiment, ExperimentContext } from '../types/experiment';
import { generateMockExperiments, updateExperiment } from '../utils/mockData';

export function useExperiments() {
  const [experiments, setExperiments] = useState<Experiment[]>(() => 
    generateMockExperiments(50)
  );
  const [selectedContext, setSelectedContext] = useState<ExperimentContext | 'all'>('all');

  // Filter experiments by context
  const filteredExperiments = experiments.filter((exp) => {
    if (selectedContext === 'all') return true;
    return exp.context === selectedContext;
  });

  // Update running experiments periodically
  useEffect(() => {
    const interval = setInterval(() => {
      setExperiments((prev) =>
        prev.map((exp) =>
          exp.status === 'running' ? updateExperiment(exp) : exp
        )
      );
    }, 2000); // Update every 2 seconds

    return () => clearInterval(interval);
  }, []);

  const getExperimentsByStatus = useCallback((status: Experiment['status']) => {
    return filteredExperiments.filter((exp) => exp.status === status);
  }, [filteredExperiments]);

  return {
    experiments: filteredExperiments,
    selectedContext,
    setSelectedContext,
    getExperimentsByStatus,
  };
}
