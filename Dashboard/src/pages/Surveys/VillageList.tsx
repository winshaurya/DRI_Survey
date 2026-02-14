import React from 'react';
import { useFetch } from '../../hooks/useFetch';

export default function VillageList(){
  const { data, loading } = useFetch('village_survey_sessions');

  return (
    <div>
      <h2>Village Surveys</h2>
      {loading && <p>Loading...</p>}
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr><th>session_id</th><th>surveyor_email</th><th>status</th></tr>
        </thead>
        <tbody>
          {data?.map((row:any) => (
            <tr key={row.session_id}>
              <td>{row.session_id}</td>
              <td>{row.surveyor_email}</td>
              <td>{row.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
