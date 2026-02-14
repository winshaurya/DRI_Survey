import React from 'react';
import { useFetch } from '../../hooks/useFetch';

export default function FamilyList(){
  const { data, loading } = useFetch('family_survey_sessions');

  return (
    <div>
      <h2>Family Surveys</h2>
      {loading && <p>Loading...</p>}
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead>
          <tr><th>phone_number</th><th>surveyor_email</th><th>status</th></tr>
        </thead>
        <tbody>
          {data?.map((row:any) => (
            <tr key={row.phone_number}>
              <td>{row.phone_number}</td>
              <td>{row.surveyor_email}</td>
              <td>{row.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
