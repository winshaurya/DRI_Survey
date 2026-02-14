import React, { useMemo } from 'react';
import { Line } from 'react-chartjs-2';
import { registerCharts } from '../../lib/chart';

registerCharts();

export default function LineChart(){
  const data = useMemo(() => ({
    labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
    datasets: [{ label: 'Submissions', data: [12,19,8,14,23,9,17], backgroundColor: 'rgba(59,130,246,0.5)', borderColor: '#3b82f6' }]
  }), []);

  const options = useMemo(() => ({ responsive: true, plugins: { legend: { display: true } } }), []);

  return <Line data={data} options={options} />;
}
