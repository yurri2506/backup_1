import { useState, useEffect } from 'react';
import { AggSandboxStatus, fetchAggSandboxStatus, fetchAggSandboxLog } from '../utils/aggsandboxAPI';

export function useAggSandbox() {
  const [status, setStatus] = useState<AggSandboxStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = async () => {
    try {
      setError(null);
      const data = await fetchAggSandboxStatus();
      setStatus(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch status');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
    const interval = setInterval(refresh, 5000); // Refresh every 5 seconds
    return () => clearInterval(interval);
  }, []);

  const getExperimentLogs = async (experimentId: string): Promise<string[]> => {
    try {
      return await fetchAggSandboxLog(experimentId);
    } catch (err) {
      console.error('Failed to fetch logs:', err);
      return [];
    }
  };

  return {
    status,
    loading,
    error,
    refresh,
    getExperimentLogs,
  };
}


