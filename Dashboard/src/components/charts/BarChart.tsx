import React, { useMemo } from 'react';
import { Bar } from 'react-chartjs-2';
import { registerCharts } from '../../lib/chart';

registerCharts();

export default function BarChart(){
  const data = useMemo(() => ({
    labels: ['A','B','C'],
    datasets: [{ label: 'Count', data: [5,10,3], backgroundColor: ['#ef4444','#f59e0b','#10b981'] }]
  }), []);

  return <Bar data={data} />;
}
