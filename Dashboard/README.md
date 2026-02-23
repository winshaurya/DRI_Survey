# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

---

## Supabase integration (service role key in frontend)

This project is intentionally configured to place the **service role key**
directly in the client bundle. All Supabase requests are made from React
using the official JS client. This is **strongly discouraged** for production,
but may be acceptable for a closed, trusted internal dashboard or demo.

### 1. Environment variables

Add the following to `.env`:

```env
VITE_SUPABASE_URL=https://xettwbdyiydigpmjumbg.supabase.co
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

There is no need for an anon key in this setup.  The key will be embedded in
the built JavaScript, so rotate it regularly and restrict access to the
app.

### 2. Frontend usage

The code uses `@supabase/supabase-js` directly.  For example, `src/services/supabase.ts`:

```ts
import { createClient } from "@supabase/supabase-js";
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseServiceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY;
export const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

export async function fetchTableData(table: string) {
  const { data, error } = await supabase.from(table).select("*");
  if (error) throw error;
  return data;
}
```

Just import `supabase` or `fetchTableData` from anywhere in your React app.

### 3. Supabase docs

Refer to the official docs when expanding functionality:

- https://supabase.com/docs/reference/javascript
- https://supabase.com/docs/guides/api

> **Security notice:** The service role key bypasses RLS and can modify any
> data in your project.  Do **not** use this approach for public or unknown
> audiences.  Consider implementing authentication + anon key whenever
> possible.

---

