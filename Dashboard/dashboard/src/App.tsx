// dashboard/src/App.tsx
import React, { useState, useEffect } from "react";
import { MantineProvider, AppShell, Navbar, Header, Title, Container, NavLink, ScrollArea, Center, Loader } from "@mantine/core";
import { TableData } from "./components/TableData";
import { supabase } from "./supabaseClient";
import { Auth } from "@supabase/auth-ui-react";
import { ThemeSupa } from "@supabase/auth-ui-shared";

// List of all tables (from SQL completeness summary)
const TABLES = [
  "aadhaar_info",
  "aadhaar_scheme_members",
  "agricultural_equipment",
  "animals",
  "ayushman_card",
  "ayushman_scheme_members",
  "bank_accounts",
  "child_diseases",
  "children_data",
  "crop_productivity",
  "diseases",
  "disputes",
  "drinking_water_sources",
  "entertainment_facilities",
  "family_id",
  "family_id_scheme_members",
  "family_members",
  "family_survey_sessions",
  "fertilizer_usage",
  "folklore_medicine",
  "fpo_members",
  "handicapped_allowance",
  "handicapped_scheme_members",
  "health_programmes",
  "house_conditions",
  "house_facilities",
  "irrigation_facilities",
  "land_holding",
  "malnourished_children_data",
  "malnutrition_data",
  "medical_treatment",
  "merged_govt_schemes",
  "migration_data",
  "nutritional_garden",
  "pension_allowance",
  "pension_scheme_members",
  "pm_kisan_members",
  "pm_kisan_nidhi",
  "pm_kisan_samman_members",
  "pm_kisan_samman_nidhi",
  "ration_card",
  "ration_scheme_members",
  "samagra_id",
  "samagra_scheme_members",
  "shg_members",
  "social_consciousness",
  "training_data",
  "transport_facilities",
  "tribal_card",
  "tribal_questions",
  "tribal_scheme_members",
  "tulsi_plants",
  "vb_gram",
  "vb_gram_members",
  "widow_allowance",
  "widow_scheme_members"
];

function App() {
  const [selectedTable, setSelectedTable] = useState<string | null>(null);
  const [user, setUser] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const session = supabase.auth.getSession().then(({ data }) => {
      setUser(data.session?.user ?? null);
      setLoading(false);
    });
    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
    });
    return () => {
      listener?.subscription.unsubscribe();
    };
  }, []);

  if (loading) {
    return (
      <MantineProvider withGlobalStyles withNormalizeCSS>
        <Center style={{ height: "100vh" }}>
          <Loader />
        </Center>
      </MantineProvider>
    );
  }

  if (!user) {
    return (
      <MantineProvider withGlobalStyles withNormalizeCSS>
        <Center style={{ height: "100vh" }}>
          <Container size="xs">
            <Title order={2} align="center" mb="md">
              Login to Dashboard
            </Title>
            <Auth supabaseClient={supabase} appearance={{ theme: ThemeSupa }} providers={[]} />
          </Container>
        </Center>
      </MantineProvider>
    );
  }

  return (
    <MantineProvider withGlobalStyles withNormalizeCSS>
      <AppShell
        padding="md"
        navbar={
          <Navbar width={{ base: 250 }} p="xs">
            <Title order={3} mb="md">Survey Tables</Title>
            <ScrollArea style={{ height: "80vh" }}>
              {TABLES.map((table) => (
                <NavLink
                  key={table}
                  label={table.replace(/_/g, " ")}
                  active={selectedTable === table}
                  onClick={() => setSelectedTable(table)}
                  style={{ textTransform: "capitalize" }}
                />
              ))}
            </ScrollArea>
          </Navbar>
        }
        header={
          <Header height={60} p="xs" style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <Title order={2}>Family Survey Master Dashboard</Title>
            <button
              style={{
                background: "#e03131",
                color: "#fff",
                border: "none",
                borderRadius: 4,
                padding: "8px 16px",
                cursor: "pointer",
                fontWeight: 600,
                fontSize: 14,
              }}
              onClick={async () => {
                await supabase.auth.signOut();
                window.location.reload();
              }}
            >
              Logout
            </button>
          </Header>
        }
      >
        <Container>
          {selectedTable ? (
            <>
              <Title order={4} mb="md">{selectedTable.replace(/_/g, " ")}</Title>
              <TableData tableName={selectedTable} />
            </>
          ) : (
            <Title order={4}>Select a table to view data</Title>
          )}
        </Container>
      </AppShell>
    </MantineProvider>
  );
}

export default App;
