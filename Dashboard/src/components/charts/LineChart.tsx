import React, { useMemo } from 'react';
import { Line } from 'react-chartjs-2';
import { registerCharts } from '../../lib/chart';
import { motion } from 'framer-motion';

registerCharts();

export default function LineChart() {
  const data = useMemo(
    () => ({
      labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      datasets: [
        {
          label: 'Submissions',
          data: [12, 19, 8, 14, 23, 9, 17],
          backgroundColor: 'rgba(59,130,246,0.15)',
          borderColor: '#3b82f6',
          borderWidth: 3,
          pointRadius: 5,
          pointBackgroundColor: '#6366f1',
          tension: 0.4,
        },
      ],
    }),
    []
  );

  const options = useMemo(
    () => ({
      responsive: true,
      plugins: {
        legend: { display: true },
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
      <Line data={data} options={options} />
    </motion.div>
  );
}
