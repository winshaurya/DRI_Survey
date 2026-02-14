import React, { useMemo } from 'react';
import { Bar } from 'react-chartjs-2';
import { registerCharts } from '../../lib/chart';
import { motion } from 'framer-motion';

registerCharts();

export default function BarChart() {
  const data = useMemo(
    () => ({
      labels: ['A', 'B', 'C'],
      datasets: [
        {
          label: 'Count',
          data: [5, 10, 3],
          backgroundColor: ['#ef4444', '#f59e0b', '#10b981'],
          borderRadius: 8,
          borderSkipped: false,
        },
      ],
    }),
    []
  );

  const options = useMemo(
    () => ({
      responsive: true,
      plugins: {
        legend: { display: false },
        tooltip: { enabled: true },
      },
      scales: {
        x: {
          grid: { display: false },
        },
        y: {
          grid: { color: '#e5e7eb' },
        },
      },
    }),
    []
  );

  return (
    <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7, type: 'spring' }}>
      <Bar data={data} options={options} />
    </motion.div>
  );
}
