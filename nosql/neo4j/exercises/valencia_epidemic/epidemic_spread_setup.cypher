// =============================================================================
// The Valencia VRS-26 Outbreak - Epidemic Spread Database Setup
// Author: Víctor Barceló
//
// Paste this entire file into the Neo4j Browser query editor and run it,
// OR run each labeled section separately using the separators as guides.
//
// Story: On February 14, 2026, the Hospital General de Valencia reported an
// unusual cluster of respiratory cases. Within two weeks, 9 people across the
// city had tested positive for a novel respiratory illness: VRS-26.
// Epidemiologists must trace the transmission chain back to Patient Zero.
// =============================================================================


// --- STEP 1: CLEAR EXISTING DATA -------------------------------------------

MATCH (n) DETACH DELETE n;


// --- STEP 2: CREATE CONSTRAINTS ---------------------------------------------

CREATE CONSTRAINT person_name IF NOT EXISTS
FOR (p:Person) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT location_name IF NOT EXISTS
FOR (l:Location) REQUIRE l.name IS UNIQUE;

CREATE CONSTRAINT travel_id IF NOT EXISTS
FOR (t:TravelRecord) REQUIRE t.id IS UNIQUE;


// --- STEP 3: PERSONS --------------------------------------------------------

// Health investigators
MERGE (:Person {name: "Dra. Carmen Valls",  role: "Epidemiologist",          age: 44, phone: "600-111-001", status: "healthy"});
MERGE (:Person {name: "Miguel Torres",       role: "Contact Tracer",          age: 31, phone: "600-111-002", status: "healthy"});
MERGE (:Person {name: "Dra. Ana Puig",       role: "Hospital Doctor",         age: 52, phone: "600-111-003", status: "healthy"});

// Confirmed and suspected cases
MERGE (:Person {name: "Ramin Tehrani",       role: "Research Scientist",      age: 38, phone: "600-222-001", status: "recovered"});
MERGE (:Person {name: "Sofía Blanco",        role: "Yoga Instructor",         age: 33, phone: "600-222-002", status: "recovered"});
MERGE (:Person {name: "Jordi Mas",           role: "Office Manager",          age: 42, phone: "600-222-003", status: "recovered"});
MERGE (:Person {name: "Laia Ferrer",         role: "Primary School Teacher",  age: 36, phone: "600-222-004", status: "recovered"});
MERGE (:Person {name: "Omar Hassan",         role: "Market Vendor",           age: 49, phone: "600-222-005", status: "recovered"});
MERGE (:Person {name: "Cristina Llopis",     role: "Supermarket Cashier",     age: 27, phone: "600-222-006", status: "recovered"});
MERGE (:Person {name: "Pau Giner",           role: "Restaurant Waiter",       age: 24, phone: "600-222-007", status: "recovered"});
MERGE (:Person {name: "Neus Boix",           role: "Retired",                 age: 71, phone: "600-222-008", status: "hospitalised"});

// Contacts under investigation
MERGE (:Person {name: "Marta Vidal",         role: "University Student",      age: 21, phone: "600-333-001", status: "healthy"});
MERGE (:Person {name: "Khalid Amrani",       role: "Personal Trainer",        age: 35, phone: "600-333-002", status: "recovered"});
MERGE (:Person {name: "Rosa Camps",          role: "Pharmacist",              age: 46, phone: "600-333-003", status: "healthy"});


// --- STEP 4: LOCATIONS ------------------------------------------------------

MERGE (:Location {name: "Hospital General de Valencia",    type: "Hospital",        district: "Extramurs"});
MERGE (:Location {name: "Centro Deportivo Ruzafa",         type: "Gym",             district: "Ruzafa"});
MERGE (:Location {name: "Colegio San Vicente Ferrer",      type: "School",          district: "Benimaclet"});
MERGE (:Location {name: "Oficinas Solaris SL",             type: "Office",          district: "Eixample"});
MERGE (:Location {name: "Mercado Central",                 type: "Market",          district: "Ciutat Vella"});
MERGE (:Location {name: "Supermercado Consum Benimaclet",  type: "Supermarket",     district: "Benimaclet"});
MERGE (:Location {name: "Restaurante La Taula",            type: "Restaurant",      district: "Ruzafa"});
MERGE (:Location {name: "Aeropuerto de Valencia",          type: "Airport",         district: "Alboraia"});
MERGE (:Location {name: "Sala de Conferencias Ateneo",     type: "Conference Hall", district: "Ciutat Vella"});
MERGE (:Location {name: "Farmacia Central Benimaclet",     type: "Pharmacy",        district: "Benimaclet"});
MERGE (:Location {name: "Residencia Ramin Tehrani",        type: "Residence",       district: "Benimaclet"});
MERGE (:Location {name: "Unidad de Epidemiologia",         type: "Health Dept",     district: "Extramurs"});


// --- STEP 5: TRAVEL RECORDS -------------------------------------------------

MERGE (:TravelRecord {id: "FLT-001", type: "International Flight", code: "VY6620", origin: "Valencia",   destination: "Geneva",   date: "2026-02-05", carrier: "Vueling"});
MERGE (:TravelRecord {id: "FLT-002", type: "International Flight", code: "VY6621", origin: "Geneva",     destination: "Valencia", date: "2026-02-10", carrier: "Vueling"});
MERGE (:TravelRecord {id: "FLT-003", type: "Bus",                  code: "ALSA-M22", origin: "Madrid",  destination: "Valencia", date: "2026-02-09", carrier: "ALSA"});
MERGE (:TravelRecord {id: "FLT-004", type: "High Speed Train",     code: "AVE-7821", origin: "Barcelona", destination: "Valencia", date: "2026-02-10", carrier: "Renfe"});
MERGE (:TravelRecord {id: "FLT-005", type: "Domestic Flight",      code: "VY1205",  origin: "Valencia",  destination: "Alicante", date: "2026-02-12", carrier: "Vueling"});


// --- STEP 6: CONTACT EVENTS -------------------------------------------------

MERGE (:ContactEvent {id: "CONT-001", date: "2026-02-11", time: "10:00", duration_minutes: 120, setting: "Sala de Conferencias Ateneo",   type: "Science Conference"});
MERGE (:ContactEvent {id: "CONT-002", date: "2026-02-11", time: "14:00", duration_minutes:  45, setting: "Restaurante La Taula",           type: "Conference Lunch"});
MERGE (:ContactEvent {id: "CONT-003", date: "2026-02-13", time: "09:30", duration_minutes:  60, setting: "Centro Deportivo Ruzafa",        type: "Yoga Class"});
MERGE (:ContactEvent {id: "CONT-004", date: "2026-02-13", time: "11:30", duration_minutes:  20, setting: "Mercado Central",                type: "Market Shopping"});
MERGE (:ContactEvent {id: "CONT-005", date: "2026-02-14", time: "09:00", duration_minutes: 480, setting: "Oficinas Solaris SL",            type: "Shared Workspace"});
MERGE (:ContactEvent {id: "CONT-006", date: "2026-02-15", time: "17:30", duration_minutes:  25, setting: "Supermercado Consum Benimaclet", type: "Grocery Shopping"});
MERGE (:ContactEvent {id: "CONT-007", date: "2026-02-16", time: "16:00", duration_minutes:  30, setting: "Colegio San Vicente Ferrer",     type: "Parent-Teacher Meeting"});
MERGE (:ContactEvent {id: "CONT-008", date: "2026-02-17", time: "10:30", duration_minutes:  10, setting: "Farmacia Central Benimaclet",    type: "Pharmacy Visit"});


// --- STEP 7: TEST RESULTS ---------------------------------------------------

MERGE (:TestResult {id: "TST-001", date: "2026-02-13", type: "PCR",     result: "POSITIVE", ct_value: 18,   lab: "Lab Clinic Valencia",        notes: "Very high viral load - earliest positive in cluster"});
MERGE (:TestResult {id: "TST-002", date: "2026-02-16", type: "PCR",     result: "POSITIVE", ct_value: 25,   lab: "Hospital General",           notes: "Moderate viral load"});
MERGE (:TestResult {id: "TST-003", date: "2026-02-16", type: "PCR",     result: "POSITIVE", ct_value: 22,   lab: "Lab Clinic Valencia",        notes: "Moderate-high viral load"});
MERGE (t:TestResult {id: "TST-004"})
SET t.date = "2026-02-16", t.type = "Antigen", t.result = "POSITIVE", t.ct_value = null,
    t.lab = "Farmacia Central Benimaclet", t.notes = "Rapid test - PCR confirmation pending";
MERGE (:TestResult {id: "TST-005", date: "2026-02-18", type: "PCR",     result: "POSITIVE", ct_value: 24,   lab: "Hospital General",           notes: "Moderate viral load"});
MERGE (:TestResult {id: "TST-006", date: "2026-02-18", type: "PCR",     result: "POSITIVE", ct_value: 20,   lab: "Hospital General",           notes: "High viral load - patient admitted"});
MERGE (:TestResult {id: "TST-007", date: "2026-02-19", type: "PCR",     result: "POSITIVE", ct_value: 26,   lab: "Lab Clinic Valencia",        notes: "Moderate viral load"});


// --- STEP 8: SYMPTOM REPORTS ------------------------------------------------

MERGE (:SymptomReport {id: "SYM-001", symptoms: "fever, dry cough",                     onset_date: "2026-02-12", severity: "mild",     days_post_exposure: 2});
MERGE (:SymptomReport {id: "SYM-002", symptoms: "fatigue, sore throat, headache",       onset_date: "2026-02-15", severity: "mild",     days_post_exposure: 4});
MERGE (:SymptomReport {id: "SYM-003", symptoms: "fever, body aches, cough",             onset_date: "2026-02-15", severity: "moderate", days_post_exposure: 4});
MERGE (:SymptomReport {id: "SYM-004", symptoms: "cough, fever, loss of smell",          onset_date: "2026-02-15", severity: "moderate", days_post_exposure: 2});
MERGE (:SymptomReport {id: "SYM-005", symptoms: "sneezing, sore throat, mild fever",    onset_date: "2026-02-17", severity: "mild",     days_post_exposure: 3});
MERGE (:SymptomReport {id: "SYM-006", symptoms: "high fever, difficulty breathing",     onset_date: "2026-02-17", severity: "severe",   days_post_exposure: 2});


// --- STEP 9: MEDICAL HISTORY ------------------------------------------------

MERGE (:MedicalHistory {id: "MED-001", condition: "Unvaccinated - VRS-26",                      relevance: "No prior immunity against VRS-26",      risk_level: "high"});
MERGE (:MedicalHistory {id: "MED-002", condition: "Type 2 Diabetes",                            relevance: "Significantly higher severity risk",     risk_level: "high"});
MERGE (:MedicalHistory {id: "MED-003", condition: "International travel - Geneva WHO symposium",relevance: "Exposure to international cases possible",risk_level: "medium"});
MERGE (:MedicalHistory {id: "MED-004", condition: "Immunocompromised - post-chemotherapy",      relevance: "Extremely high severity risk",            risk_level: "very_high"});


// --- STEP 10: WORKS_AT RELATIONSHIPS ----------------------------------------

MATCH (p:Person {name: "Dra. Carmen Valls"}), (l:Location {name: "Unidad de Epidemiologia"})           MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Miguel Torres"}),      (l:Location {name: "Unidad de Epidemiologia"})           MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Dra. Ana Puig"}),      (l:Location {name: "Hospital General de Valencia"})      MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Sofía Blanco"}),       (l:Location {name: "Centro Deportivo Ruzafa"})           MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Jordi Mas"}),          (l:Location {name: "Oficinas Solaris SL"})               MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Laia Ferrer"}),        (l:Location {name: "Colegio San Vicente Ferrer"})        MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Omar Hassan"}),        (l:Location {name: "Mercado Central"})                   MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Cristina Llopis"}),    (l:Location {name: "Supermercado Consum Benimaclet"})    MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Pau Giner"}),          (l:Location {name: "Restaurante La Taula"})              MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Rosa Camps"}),         (l:Location {name: "Farmacia Central Benimaclet"})       MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 11: VISITED RELATIONSHIPS -----------------------------------------

// Ramin's movements after returning from Geneva
MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-10", time: "08:30", purpose: "Arrival from Geneva"}]->(l);

MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Sala de Conferencias Ateneo"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "10:00", purpose: "Invited speaker at regional science symposium"}]->(l);

MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Restaurante La Taula"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "14:00", purpose: "Post-conference lunch"}]->(l);

MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "11:30", purpose: "Grocery shopping - despite mild symptoms"}]->(l);

MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Hospital General de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "09:00", purpose: "Self-referred - reported fever and cough"}]->(l);

// Other attendees at the conference
MATCH (p:Person {name: "Jordi Mas"}),    (l:Location {name: "Sala de Conferencias Ateneo"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "10:00", purpose: "Conference attendee"}]->(l);

MATCH (p:Person {name: "Sofía Blanco"}), (l:Location {name: "Sala de Conferencias Ateneo"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "10:00", purpose: "Conference attendee"}]->(l);

MATCH (p:Person {name: "Pau Giner"}),    (l:Location {name: "Sala de Conferencias Ateneo"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "13:00", purpose: "Catering staff for conference lunch"}]->(l);

// Downstream exposure visits
MATCH (p:Person {name: "Khalid Amrani"}), (l:Location {name: "Centro Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "09:30", purpose: "Attended yoga class"}]->(l);

MATCH (p:Person {name: "Omar Hassan"}),   (l:Location {name: "Supermercado Consum Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-15", time: "17:30", purpose: "Grocery shopping after market shift"}]->(l);

MATCH (p:Person {name: "Laia Ferrer"}),   (l:Location {name: "Oficinas Solaris SL"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "10:00", purpose: "Work meeting to collect project documents"}]->(l);

MATCH (p:Person {name: "Neus Boix"}),     (l:Location {name: "Supermercado Consum Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-15", time: "17:30", purpose: "Weekly grocery shopping"}]->(l);

MATCH (p:Person {name: "Neus Boix"}),     (l:Location {name: "Farmacia Central Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-17", time: "10:30", purpose: "Collected regular medication"}]->(l);

MATCH (p:Person {name: "Marta Vidal"}),   (l:Location {name: "Colegio San Vicente Ferrer"})
MERGE (p)-[:VISITED {date: "2026-02-16", time: "16:00", purpose: "Parent-teacher meeting"}]->(l);


// --- STEP 12: TRAVEL RECORDS - BOARDED / ARRIVED_AT / DEPARTED_FROM --------

// Who boarded which travel record
MATCH (p:Person {name: "Ramin Tehrani"}), (t:TravelRecord {id: "FLT-001"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Ramin Tehrani"}), (t:TravelRecord {id: "FLT-002"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Sofía Blanco"}),  (t:TravelRecord {id: "FLT-003"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Marta Vidal"}),   (t:TravelRecord {id: "FLT-004"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Omar Hassan"}),   (t:TravelRecord {id: "FLT-005"}) MERGE (p)-[:BOARDED]->(t);

// Travel records linked to Valencia airport
MATCH (t:TravelRecord {id: "FLT-001"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:DEPARTED_FROM {date: "2026-02-05", time: "07:30"}]->(l);

MATCH (t:TravelRecord {id: "FLT-002"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-10", time: "08:15"}]->(l);

MATCH (t:TravelRecord {id: "FLT-003"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-09", time: "21:00"}]->(l);

MATCH (t:TravelRecord {id: "FLT-004"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-10", time: "11:40"}]->(l);

MATCH (t:TravelRecord {id: "FLT-005"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:DEPARTED_FROM {date: "2026-02-12", time: "15:00"}]->(l);


// --- STEP 13: CONTACT EVENT RELATIONSHIPS -----------------------------------
// Both people at the same exposure event use WAS_PRESENT_AT

// CONT-001: Science conference - Ramin, Jordi, Sofía in the same room for 2 hours
MATCH (p:Person {name: "Ramin Tehrani"}), (c:ContactEvent {id: "CONT-001"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Jordi Mas"}),     (c:ContactEvent {id: "CONT-001"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Sofía Blanco"}),  (c:ContactEvent {id: "CONT-001"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-002: Conference lunch - Ramin dined, Pau served
MATCH (p:Person {name: "Ramin Tehrani"}), (c:ContactEvent {id: "CONT-002"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Pau Giner"}),     (c:ContactEvent {id: "CONT-002"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-003: Yoga class - Sofía instructed, Khalid attended
MATCH (p:Person {name: "Sofía Blanco"}),  (c:ContactEvent {id: "CONT-003"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Khalid Amrani"}), (c:ContactEvent {id: "CONT-003"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-004: Market shopping - Ramin bought produce at Omar's stall
MATCH (p:Person {name: "Ramin Tehrani"}), (c:ContactEvent {id: "CONT-004"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Omar Hassan"}),   (c:ContactEvent {id: "CONT-004"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-005: Shared workspace - Jordi and Laia in prolonged proximity
MATCH (p:Person {name: "Jordi Mas"}),     (c:ContactEvent {id: "CONT-005"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Laia Ferrer"}),   (c:ContactEvent {id: "CONT-005"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-006: Supermarket - Omar shopped, Cristina at checkout, Neus also present
MATCH (p:Person {name: "Omar Hassan"}),    (c:ContactEvent {id: "CONT-006"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Cristina Llopis"}),(c:ContactEvent {id: "CONT-006"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Neus Boix"}),      (c:ContactEvent {id: "CONT-006"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-007: Parent-teacher meeting - Laia (teacher) received Marta (parent)
MATCH (p:Person {name: "Laia Ferrer"}),   (c:ContactEvent {id: "CONT-007"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Marta Vidal"}),   (c:ContactEvent {id: "CONT-007"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-008: Pharmacy - Neus collected medication, Rosa dispensed
MATCH (p:Person {name: "Neus Boix"}),     (c:ContactEvent {id: "CONT-008"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Rosa Camps"}),    (c:ContactEvent {id: "CONT-008"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);


// --- STEP 14: TEST RESULT RELATIONSHIPS -------------------------------------

MATCH (p:Person {name: "Ramin Tehrani"}),  (t:TestResult {id: "TST-001"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Jordi Mas"}),      (t:TestResult {id: "TST-002"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Sofía Blanco"}),   (t:TestResult {id: "TST-003"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Omar Hassan"}),    (t:TestResult {id: "TST-004"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Laia Ferrer"}),    (t:TestResult {id: "TST-005"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Neus Boix"}),      (t:TestResult {id: "TST-006"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Khalid Amrani"}),  (t:TestResult {id: "TST-007"}) MERGE (p)-[:TOOK_TEST]->(t);


// --- STEP 15: MAY_HAVE_INFECTED (TRANSMISSION CHAIN) -----------------------
// Suspected transmission from infector to infectee, based on contact events and timeline

MATCH (a:Person {name: "Ramin Tehrani"}), (b:Person {name: "Jordi Mas"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-11", setting: "Science conference", confidence: "high"}]->(b);

MATCH (a:Person {name: "Ramin Tehrani"}), (b:Person {name: "Sofía Blanco"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-11", setting: "Science conference", confidence: "high"}]->(b);

MATCH (a:Person {name: "Ramin Tehrani"}), (b:Person {name: "Pau Giner"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-11", setting: "Conference lunch", confidence: "medium"}]->(b);

MATCH (a:Person {name: "Ramin Tehrani"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-13", setting: "Mercado Central - vendor stall", confidence: "medium"}]->(b);

MATCH (a:Person {name: "Sofía Blanco"}),  (b:Person {name: "Khalid Amrani"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-13", setting: "Yoga class - close indoor contact", confidence: "high"}]->(b);

MATCH (a:Person {name: "Jordi Mas"}),     (b:Person {name: "Laia Ferrer"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-14", setting: "Shared office workspace 8 hours", confidence: "high"}]->(b);

MATCH (a:Person {name: "Omar Hassan"}),   (b:Person {name: "Cristina Llopis"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-15", setting: "Supermarket checkout", confidence: "medium"}]->(b);

MATCH (a:Person {name: "Omar Hassan"}),   (b:Person {name: "Neus Boix"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-15", setting: "Supermarket - same aisle", confidence: "medium"}]->(b);

MATCH (a:Person {name: "Laia Ferrer"}),   (b:Person {name: "Marta Vidal"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-16", setting: "School parent meeting - brief contact", confidence: "low"}]->(b);


// --- STEP 16: SYMPTOM REPORTS -> PERSON AND LOCATION -----------------------

MATCH (s:SymptomReport {id: "SYM-001"}), (p:Person {name: "Ramin Tehrani"})
MERGE (s)-[:REPORTED_BY {basis: "Earliest symptom onset - 2 days after return from Geneva"}]->(p);

MATCH (s:SymptomReport {id: "SYM-002"}), (p:Person {name: "Jordi Mas"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 4 days after conference - consistent incubation period"}]->(p);

MATCH (s:SymptomReport {id: "SYM-003"}), (p:Person {name: "Sofía Blanco"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 4 days after conference - consistent incubation period"}]->(p);

MATCH (s:SymptomReport {id: "SYM-004"}), (p:Person {name: "Omar Hassan"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 2 days after market contact with Ramin"}]->(p);

MATCH (s:SymptomReport {id: "SYM-005"}), (p:Person {name: "Laia Ferrer"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 3 days after office exposure with Jordi"}]->(p);

MATCH (s:SymptomReport {id: "SYM-006"}), (p:Person {name: "Neus Boix"})
MERGE (s)-[:REPORTED_BY {basis: "Severe onset - immunocompromised, supermarket exposure"}]->(p);

// All symptom reports recorded at the hospital
MATCH (s:SymptomReport {id: "SYM-001"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-002"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-003"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-004"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-005"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-006"}), (l:Location {name: "Hospital General de Valencia"}) MERGE (s)-[:RECORDED_AT]->(l);


// --- STEP 17: MEDICAL HISTORY -----------------------------------------------

MATCH (p:Person {name: "Ramin Tehrani"}), (m:MedicalHistory {id: "MED-003"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Jordi Mas"}),     (m:MedicalHistory {id: "MED-002"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Khalid Amrani"}), (m:MedicalHistory {id: "MED-001"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Neus Boix"}),     (m:MedicalHistory {id: "MED-004"}) MERGE (p)-[:HAS_HISTORY]->(m);


// --- STEP 18: VERIFY INITIAL DATA (steps 1-17) -----------------------------
// Run this query alone after loading steps 1-17 to verify the base dataset.
//
// Expected node counts:
// Person           | 14
// Location         | 12
// ContactEvent     |  8
// TestResult       |  7
// TravelRecord     |  5
// SymptomReport    |  6
// MedicalHistory   |  4
// TOTAL            | 56

MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;


// =============================================================================
// ADDITIONAL DATA  -  Extended epidemic network (steps 19 - 36)
// =============================================================================


// --- STEP 19: ADDITIONAL PERSONS --------------------------------------------

// New cases and contacts discovered during extended contact tracing
MERGE (:Person {name: "Álvaro Martínez",  role: "Primary School Student", age:  9, phone: "600-444-001", status: "recovered"});
MERGE (:Person {name: "Beatriz Sanz",     role: "Hospital Nurse",          age: 29, phone: "600-444-002", status: "recovered"});
MERGE (:Person {name: "Carlos Oñate",     role: "Software Developer",      age: 31, phone: "600-444-003", status: "recovered"});
MERGE (:Person {name: "Prof. Wei Chen",   role: "Virologist",              age: 55, phone: "+86-10-5550199", status: "isolated"});
MERGE (:Person {name: "Elena Ribas",      role: "Pilates Instructor",      age: 28, phone: "600-444-004", status: "recovered"});


// --- STEP 20: ADDITIONAL LOCATIONS ------------------------------------------

MERGE (:Location {name: "Centro de Salud Benimaclet",      type: "Health Centre", district: "Benimaclet"});
MERGE (:Location {name: "Universidad Politécnica VLC",      type: "University",    district: "Camins al Grau"});
MERGE (:Location {name: "Metro Estación Benimaclet",        type: "Metro Station", district: "Benimaclet"});
MERGE (:Location {name: "Aeropuerto Internacional Ginebra", type: "Airport",       district: "Geneva - Switzerland"});


// --- STEP 21: ADDITIONAL TRAVEL RECORDS ------------------------------------

// Prof. Wei Chen flew from Beijing to Geneva before the WHO symposium
MERGE (:TravelRecord {id: "TRV-006", type: "International Flight", code: "LX188",   origin: "Beijing",      destination: "Geneva",     date: "2026-02-07", carrier: "Swiss Air"});
// Beatriz Sanz daily metro commute to hospital on the day Ramin was triaged
MERGE (:TravelRecord {id: "TRV-007", type: "Metro",                code: "L3-Val",  origin: "Estació Nord", destination: "Benimaclet", date: "2026-02-14", carrier: "Metrovalencia"});
// Álvaro Martínez bus ride to health centre for antigen test
MERGE (:TravelRecord {id: "TRV-008", type: "City Bus",             code: "EMT-41",  origin: "Ruzafa",       destination: "Benimaclet", date: "2026-02-19", carrier: "EMT Valencia"});


// --- STEP 22: ADDITIONAL CONTACT EVENTS ------------------------------------

// Root event: Ramin was exposed at the Geneva WHO Symposium
MERGE (:ContactEvent {id: "CONT-009", date: "2026-02-08", time: "09:00", duration_minutes: 360, setting: "Geneva WHO Symposium Hall",    type: "International Symposium"});
// Ramin arrived at hospital for triage, unwittingly exposing nurse Beatriz Sanz
MERGE (:ContactEvent {id: "CONT-010", date: "2026-02-14", time: "09:15", duration_minutes:  15, setting: "Hospital General de Valencia", type: "Triage Assessment"});
// Jordi Mas, already symptomatic, had a brief corridor conversation with Carlos Oñate
MERGE (:ContactEvent {id: "CONT-011", date: "2026-02-14", time: "11:00", duration_minutes:  10, setting: "Oficinas Solaris SL",          type: "Office Corridor Chat"});
// Laia Ferrer taught her class in pre-symptomatic stage, exposing student Álvaro
MERGE (:ContactEvent {id: "CONT-012", date: "2026-02-14", time: "09:00", duration_minutes: 270, setting: "Colegio San Vicente Ferrer",   type: "Classroom Lesson"});
// Khalid Amrani, recovered but still shedding, shared training space with Elena Ribas
MERGE (:ContactEvent {id: "CONT-013", date: "2026-02-15", time: "10:00", duration_minutes:  30, setting: "Centro Deportivo Ruzafa",      type: "Shared Training Space"});


// --- STEP 23: ADDITIONAL TEST RESULTS --------------------------------------

// TST-008: Pau Giner - PCR NEGATIVE (no ct_value for negative results)
MERGE (t:TestResult {id: "TST-008"})
SET t.date = "2026-02-17", t.type = "PCR", t.result = "NEGATIVE", t.ct_value = null,
    t.lab = "Centro de Salud Benimaclet", t.notes = "Negative - voluntary test after conference lunch, no transmission confirmed";

MERGE (:TestResult {id: "TST-009", date: "2026-02-19", type: "PCR",    result: "POSITIVE", ct_value: 23, lab: "Lab Clinic Valencia",          notes: "Moderate viral load - secondary case at supermarket checkout"});
MERGE (:TestResult {id: "TST-010", date: "2026-02-18", type: "PCR",    result: "POSITIVE", ct_value: 21, lab: "Hospital General",             notes: "High viral load - healthcare worker occupational exposure at triage"});

// TST-011: Álvaro Martínez - Antigen POSITIVE (antigen tests do not produce ct values)
MERGE (t:TestResult {id: "TST-011"})
SET t.date = "2026-02-19", t.type = "Antigen", t.result = "POSITIVE", t.ct_value = null,
    t.lab = "Centro de Salud Benimaclet", t.notes = "School secondary case - antigen positive, PCR confirmation requested";

MERGE (:TestResult {id: "TST-012", date: "2026-02-20", type: "PCR",    result: "POSITIVE", ct_value: 25, lab: "Lab Clinic Valencia",          notes: "Moderate viral load - office secondary case"});

// TST-013: Marta Vidal - PCR NEGATIVE
MERGE (t:TestResult {id: "TST-013"})
SET t.date = "2026-02-19", t.type = "PCR", t.result = "NEGATIVE", t.ct_value = null,
    t.lab = "Hospital General", t.notes = "Negative - close contact of Laia Ferrer, no onward transmission detected";

MERGE (:TestResult {id: "TST-014", date: "2026-02-21", type: "PCR",    result: "POSITIVE", ct_value: 28, lab: "Centro de Salud Benimaclet",   notes: "Low-moderate viral load - gym secondary case"});


// --- STEP 24: ADDITIONAL SYMPTOM REPORTS -----------------------------------

MERGE (:SymptomReport {id: "SYM-007", symptoms: "mild cough, runny nose",       onset_date: "2026-02-18", severity: "mild",     days_post_exposure: 3});
MERGE (:SymptomReport {id: "SYM-008", symptoms: "fever, loss of appetite",       onset_date: "2026-02-17", severity: "moderate", days_post_exposure: 3});
MERGE (:SymptomReport {id: "SYM-009", symptoms: "sore throat, headache, cough",  onset_date: "2026-02-19", severity: "mild",     days_post_exposure: 5});
MERGE (:SymptomReport {id: "SYM-010", symptoms: "fever, fatigue, muscle pain",   onset_date: "2026-02-18", severity: "moderate", days_post_exposure: 4});
MERGE (:SymptomReport {id: "SYM-011", symptoms: "fatigue, mild cough",           onset_date: "2026-02-19", severity: "mild",     days_post_exposure: 4});


// --- STEP 25: ADDITIONAL MEDICAL HISTORY -----------------------------------

MERGE (:MedicalHistory {id: "MED-005", condition: "Fully vaccinated VRS-26 seasonal",              relevance: "Partial immunity - milder symptoms and faster recovery",     risk_level: "low"});
MERGE (:MedicalHistory {id: "MED-006", condition: "Mild asthma",                                   relevance: "Increased risk of respiratory complications",                risk_level: "medium"});
MERGE (:MedicalHistory {id: "MED-007", condition: "Age under 10 - unvaccinated",                   relevance: "Children show mild symptoms but are efficient spreaders",     risk_level: "medium"});
MERGE (:MedicalHistory {id: "MED-008", condition: "Recent travel from active VRS-26 outbreak zone",relevance: "High probability of VRS-26 exposure before Geneva symposium",  risk_level: "very_high"});


// --- STEP 26: WORKS_AT FOR NEW PERSONS -------------------------------------

MATCH (p:Person {name: "Beatriz Sanz"}),  (l:Location {name: "Hospital General de Valencia"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Carlos Oñate"}),  (l:Location {name: "Oficinas Solaris SL"})           MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Elena Ribas"}),   (l:Location {name: "Centro Deportivo Ruzafa"})        MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 27: VISITED FOR NEW PERSONS AND PREVIOUSLY UNLINKED NODES --------

// Ramin returned home and self-isolated after his positive result
MATCH (p:Person {name: "Ramin Tehrani"}),   (l:Location {name: "Residencia Ramin Tehrani"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "12:00", purpose: "Self-isolation after positive PCR - 10 days"}]->(l);

// Prof. Wei Chen arrived in Geneva for the WHO symposium
MATCH (p:Person {name: "Prof. Wei Chen"}),  (l:Location {name: "Aeropuerto Internacional Ginebra"})
MERGE (p)-[:VISITED {date: "2026-02-07", time: "18:45", purpose: "Arrival from Beijing for WHO Symposium"}]->(l);

// Beatriz Sanz was on triage duty when Ramin arrived
MATCH (p:Person {name: "Beatriz Sanz"}),    (l:Location {name: "Hospital General de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "09:00", purpose: "Triage shift - triaged Ramin Tehrani on arrival"}]->(l);

// Álvaro Martínez - school day and subsequent health centre visit
MATCH (p:Person {name: "Álvaro Martínez"}), (l:Location {name: "Colegio San Vicente Ferrer"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "09:00", purpose: "Regular class - Laia Ferrer pre-symptomatic"}]->(l);

MATCH (p:Person {name: "Álvaro Martínez"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-19", time: "10:00", purpose: "Antigen test after fever and loss of appetite"}]->(l);

// Carlos Oñate - office and health centre
MATCH (p:Person {name: "Carlos Oñate"}),    (l:Location {name: "Oficinas Solaris SL"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "11:00", purpose: "Regular work day - corridor chat with symptomatic Jordi"}]->(l);

MATCH (p:Person {name: "Carlos Oñate"}),    (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-20", time: "09:30", purpose: "PCR test after onset of sore throat and cough"}]->(l);

// Elena Ribas - gym and health centre
MATCH (p:Person {name: "Elena Ribas"}),     (l:Location {name: "Centro Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-15", time: "10:00", purpose: "Shared training hall with Khalid Amrani"}]->(l);

MATCH (p:Person {name: "Elena Ribas"}),     (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-21", time: "11:00", purpose: "PCR test after fatigue and mild cough onset"}]->(l);

// Marta Vidal - university and health centre
MATCH (p:Person {name: "Marta Vidal"}),     (l:Location {name: "Universidad Politécnica VLC"})
MERGE (p)-[:VISITED {date: "2026-02-18", time: "09:00", purpose: "Regular class attendance"}]->(l);

MATCH (p:Person {name: "Marta Vidal"}),     (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-19", time: "12:00", purpose: "PCR test requested as contact of confirmed case Laia Ferrer"}]->(l);

// Pau Giner voluntarily tested after attending the conference lunch
MATCH (p:Person {name: "Pau Giner"}),       (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-17", time: "16:00", purpose: "Voluntary PCR - alerted as contact at conference lunch"}]->(l);

// Cristina Llopis tested after symptom onset
MATCH (p:Person {name: "Cristina Llopis"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-19", time: "14:00", purpose: "PCR test after mild cough and runny nose"}]->(l);


// --- STEP 28: TRAVEL RECORD RELATIONSHIPS FOR NEW RECORDS ------------------

MATCH (p:Person {name: "Prof. Wei Chen"}),  (t:TravelRecord {id: "TRV-006"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Beatriz Sanz"}),    (t:TravelRecord {id: "TRV-007"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Álvaro Martínez"}), (t:TravelRecord {id: "TRV-008"}) MERGE (p)-[:BOARDED]->(t);

MATCH (t:TravelRecord {id: "TRV-006"}), (l:Location {name: "Aeropuerto Internacional Ginebra"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-07", time: "18:45"}]->(l);

MATCH (t:TravelRecord {id: "TRV-007"}), (l:Location {name: "Metro Estación Benimaclet"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-14", time: "08:50"}]->(l);

MATCH (t:TravelRecord {id: "TRV-008"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-19", time: "09:50"}]->(l);


// --- STEP 29: WAS_PRESENT_AT FOR NEW CONTACT EVENTS ------------------------

// CONT-009: Geneva WHO Symposium - Prof. Wei Chen was the source for Ramin
MATCH (p:Person {name: "Prof. Wei Chen"}),  (c:ContactEvent {id: "CONT-009"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Ramin Tehrani"}),   (c:ContactEvent {id: "CONT-009"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-010: Hospital triage - Ramin was assessed by nurse Beatriz Sanz
MATCH (p:Person {name: "Ramin Tehrani"}),   (c:ContactEvent {id: "CONT-010"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Beatriz Sanz"}),    (c:ContactEvent {id: "CONT-010"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-011: Office corridor - Jordi (symptomatic) chatted briefly with Carlos
MATCH (p:Person {name: "Jordi Mas"}),       (c:ContactEvent {id: "CONT-011"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Carlos Oñate"}),    (c:ContactEvent {id: "CONT-011"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-012: Classroom - Laia (pre-symptomatic) taught Álvaro
MATCH (p:Person {name: "Laia Ferrer"}),     (c:ContactEvent {id: "CONT-012"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Álvaro Martínez"}), (c:ContactEvent {id: "CONT-012"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-013: Gym training - Khalid (contagious) shared space with Elena
MATCH (p:Person {name: "Khalid Amrani"}),   (c:ContactEvent {id: "CONT-013"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Elena Ribas"}),     (c:ContactEvent {id: "CONT-013"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);


// --- STEP 30: TEST RESULT RELATIONSHIPS FOR NEW TESTS ----------------------

MATCH (p:Person {name: "Pau Giner"}),       (t:TestResult {id: "TST-008"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Cristina Llopis"}), (t:TestResult {id: "TST-009"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Beatriz Sanz"}),    (t:TestResult {id: "TST-010"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Álvaro Martínez"}), (t:TestResult {id: "TST-011"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Carlos Oñate"}),    (t:TestResult {id: "TST-012"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Marta Vidal"}),     (t:TestResult {id: "TST-013"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Elena Ribas"}),     (t:TestResult {id: "TST-014"}) MERGE (p)-[:TOOK_TEST]->(t);


// --- STEP 31: EXTENDED MAY_HAVE_INFECTED CHAIN -----------------------------

// Upstream root: Prof. Wei Chen in Geneva -> Ramin (explains how VRS-26 entered Valencia)
MATCH (a:Person {name: "Prof. Wei Chen"}),  (b:Person {name: "Ramin Tehrani"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-08", setting: "Geneva WHO Symposium - 6h shared indoor hall", confidence: "high"}]->(b);

// Healthcare worker occupational exposure
MATCH (a:Person {name: "Ramin Tehrani"}),   (b:Person {name: "Beatriz Sanz"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-14", setting: "Hospital triage - initial PPE not worn", confidence: "high"}]->(b);

// Office secondary chain
MATCH (a:Person {name: "Jordi Mas"}),       (b:Person {name: "Carlos Oñate"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-14", setting: "Office corridor - Jordi already symptomatic", confidence: "medium"}]->(b);

// School secondary chain
MATCH (a:Person {name: "Laia Ferrer"}),     (b:Person {name: "Álvaro Martínez"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-14", setting: "Classroom - teacher in pre-symptomatic contagious stage", confidence: "high"}]->(b);

// Gym tertiary chain
MATCH (a:Person {name: "Khalid Amrani"}),   (b:Person {name: "Elena Ribas"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-15", setting: "Gym shared training area - close indoor proximity", confidence: "medium"}]->(b);


// --- STEP 32: SYMPTOM REPORT RELATIONSHIPS FOR NEW CASES ------------------

MATCH (s:SymptomReport {id: "SYM-007"}), (p:Person {name: "Cristina Llopis"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 3 days after supermarket contact with Omar Hassan"}]->(p);

MATCH (s:SymptomReport {id: "SYM-008"}), (p:Person {name: "Álvaro Martínez"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 3 days after classroom contact with Laia Ferrer"}]->(p);

MATCH (s:SymptomReport {id: "SYM-009"}), (p:Person {name: "Carlos Oñate"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 5 days after brief corridor contact with Jordi Mas"}]->(p);

MATCH (s:SymptomReport {id: "SYM-010"}), (p:Person {name: "Beatriz Sanz"})
MERGE (s)-[:REPORTED_BY {basis: "Occupational exposure confirmed - onset 4 days post triage shift"}]->(p);

MATCH (s:SymptomReport {id: "SYM-011"}), (p:Person {name: "Elena Ribas"})
MERGE (s)-[:REPORTED_BY {basis: "Onset 4 days after gym shared training with Khalid Amrani"}]->(p);

MATCH (s:SymptomReport {id: "SYM-007"}), (l:Location {name: "Centro de Salud Benimaclet"})    MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-008"}), (l:Location {name: "Centro de Salud Benimaclet"})    MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-009"}), (l:Location {name: "Centro de Salud Benimaclet"})    MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-010"}), (l:Location {name: "Hospital General de Valencia"})  MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-011"}), (l:Location {name: "Centro de Salud Benimaclet"})    MERGE (s)-[:RECORDED_AT]->(l);


// --- STEP 33: MEDICAL HISTORY FOR NEW AND EXISTING PERSONS -----------------

MATCH (p:Person {name: "Sofía Blanco"}),    (m:MedicalHistory {id: "MED-005"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Laia Ferrer"}),     (m:MedicalHistory {id: "MED-006"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Álvaro Martínez"}), (m:MedicalHistory {id: "MED-007"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Prof. Wei Chen"}),  (m:MedicalHistory {id: "MED-008"}) MERGE (p)-[:HAS_HISTORY]->(m);


// --- STEP 34: INVESTIGATOR AND HEALTHCARE WORKER RELATIONSHIPS -------------

// Dra. Carmen Valls investigated the Valencia cluster origin
MATCH (a:Person {name: "Dra. Carmen Valls"}), (b:Person {name: "Ramin Tehrani"})
MERGE (a)-[:INVESTIGATED {date: "2026-02-14", reason: "Patient Zero candidate - earliest positive PCR in cluster"}]->(b);

MATCH (a:Person {name: "Dra. Carmen Valls"}), (b:Person {name: "Prof. Wei Chen"})
MERGE (a)-[:INVESTIGATED {date: "2026-02-17", reason: "Upstream international source - Geneva symposium contact"}]->(b);

// Miguel Torres conducted contact tracing interviews
MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Sofía Blanco"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-17", context: "Contact tracing - conference attendee, secondary spreader at gym"}]->(b);

MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-16", context: "Contact tracing - market vendor with direct contact to Ramin"}]->(b);

MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Jordi Mas"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-17", context: "Contact tracing - conference attendee, office chain source"}]->(b);

// Dra. Ana Puig treated patients at the hospital
MATCH (a:Person {name: "Dra. Ana Puig"}), (b:Person {name: "Neus Boix"})
MERGE (a)-[:TREATED {from_date: "2026-02-17", to_date: "2026-02-28", outcome: "Discharged - fully recovered"}]->(b);

MATCH (a:Person {name: "Dra. Ana Puig"}), (b:Person {name: "Ramin Tehrani"})
MERGE (a)-[:TREATED {from_date: "2026-02-14", to_date: "2026-02-14", outcome: "Discharged same day - mild, home isolation advised"}]->(b);

// Rosa Camps dispensed medication to Neus Boix, unaware she was infectious
MATCH (a:Person {name: "Rosa Camps"}), (b:Person {name: "Neus Boix"})
MERGE (a)-[:DISPENSED {date: "2026-02-17", medication: "Ibuprofen and prescribed anticoagulant", context: "Routine prescription collection - Neus showed no symptoms yet"}]->(b);


// --- STEP 35: SELF-ISOLATION AND KNOWS RELATIONSHIPS -----------------------

// Ramin self-isolated at home after diagnosis
MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Residencia Ramin Tehrani"})
MERGE (p)-[:SELF_ISOLATED_AT {from_date: "2026-02-14", to_date: "2026-02-24", duration_days: 10, mandated_by: "Hospital General de Valencia"}]->(l);

// Professional and social connections for new persons
MATCH (a:Person {name: "Beatriz Sanz"}),   (b:Person {name: "Dra. Ana Puig"})
MERGE (a)-[:KNOWS {since: 2024, context: "Hospital colleagues - same ward"}]->(b);

MATCH (a:Person {name: "Carlos Oñate"}),   (b:Person {name: "Jordi Mas"})
MERGE (a)-[:KNOWS {since: 2023, context: "Colleagues at Oficinas Solaris SL"}]->(b);

MATCH (a:Person {name: "Elena Ribas"}),    (b:Person {name: "Sofía Blanco"})
MERGE (a)-[:KNOWS {since: 2021, context: "Gym colleagues - both fitness instructors at Centro Deportivo"}]->(b);

MATCH (a:Person {name: "Elena Ribas"}),    (b:Person {name: "Khalid Amrani"})
MERGE (a)-[:KNOWS {since: 2022, context: "Regular shared training sessions at the gym"}]->(b);

MATCH (a:Person {name: "Ramin Tehrani"}),  (b:Person {name: "Prof. Wei Chen"})
MERGE (a)-[:KNOWS {since: 2023, context: "International academic conference network"}]->(b);


// --- STEP 36: FULL VERIFY ---------------------------------------------------
// Run this query after loading all 35 steps to confirm the complete dataset.
//
// Expected node counts:
// Person           | 19
// Location         | 16
// ContactEvent     | 13
// TestResult       | 14
// TravelRecord     |  8
// SymptomReport    | 11
// MedicalHistory   |  8
// TOTAL            | 89

MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;


// =============================================================================
// NOISE AND AMBIGUITY LAYER  -  Extended social web (steps 37 - 54)
//
// Eight additional persons are introduced as deliberate red herrings.
// Cross-connections between previously unlinked existing nodes are added
// to make the visual origin harder to identify.
// =============================================================================


// --- STEP 37: ADDITIONAL PERSONS (RED HERRINGS) -----------------------------

// Dr. Vasyl Ivanenko: Ukrainian virologist who attended both the Geneva WHO
// Symposium AND the Valencia conference. He tested POSITIVE on Feb 12 with a
// high viral load (ct=19), making him a plausible alternative Patient Zero.
MERGE (:Person {name: "Dr. Vasyl Ivanenko",  role: "Virologist",              age: 44, phone: "+380-44-5550111", status: "isolated"});

// Fátima Morales: market vendor whose stall is adjacent to Omar Hassan's.
// She tested positive on Feb 14, raising the question of whether the
// Mercado Central was an independent cluster origin, not just a downstream site.
MERGE (:Person {name: "Fátima Morales",      role: "Market Vendor",           age: 43, phone: "600-555-001", status: "recovered"});

// Raúl Gutiérrez: delivery driver whose daily route covers the market,
// supermarket, restaurant and gym area. He is connected to four separate
// confirmed cases via independent delivery contacts - a super-connector.
MERGE (:Person {name: "Raúl Gutiérrez",      role: "Delivery Driver",         age: 36, phone: "600-555-002", status: "recovered"});

// Ingrid Halvorsen: Norwegian delegate who attended the Geneva WHO Symposium.
// She tested positive in Oslo on Feb 14 (ct=21), suggesting she was also
// infected at the Geneva event - but by whom?
MERGE (:Person {name: "Ingrid Halvorsen",    role: "Public Health Delegate",  age: 39, phone: "+47-22-5550190", status: "isolated"});

// Pere Ferrer: retired, age 68, father of Laia Ferrer. He visited the school
// to collect a neighbour's child on Feb 14, when Laia was still pre-symptomatic.
// He tested positive on Feb 19, creating an alternative school-family chain.
MERGE (:Person {name: "Pere Ferrer",         role: "Retired",                 age: 68, phone: "600-555-003", status: "recovered"});

// Naomi Clarke: receptionist at Hotel Ateneo Suites, where conference speakers
// including Ramin and Ivanenko checked in on Feb 10. She feels well but is a
// potential silent bridge between the conference and the wider city.
MERGE (:Person {name: "Naomi Clarke",        role: "Hotel Receptionist",      age: 32, phone: "600-555-004", status: "healthy"});

// Amina Benali: university student, close friend of Marta Vidal. She attended
// the same classes and visited the health centre independently, creating a
// parallel university chain that does not trace back clearly to any single source.
MERGE (:Person {name: "Amina Benali",        role: "University Student",      age: 22, phone: "600-555-005", status: "healthy"});

// Tomàs Roig: owner of Bar Deportivo Ruzafa, frequented by gym staff and clients.
// He knows Khalid, Elena and Sofía socially and was present at the bar on evenings
// when multiple infected persons visited, yet his test came back negative.
MERGE (:Person {name: "Tomàs Roig",          role: "Bar Owner",               age: 58, phone: "600-555-006", status: "healthy"});


// --- STEP 38: ADDITIONAL LOCATIONS ------------------------------------------

// Hotel where conference speakers (Ramin, Ivanenko, Halvorsen) were accommodated
MERGE (:Location {name: "Hotel Ateneo Suites",   type: "Hotel",   district: "Ciutat Vella"});
// Bar adjacent to the gym - social hub for fitness crowd
MERGE (:Location {name: "Bar Deportivo Ruzafa",  type: "Bar",     district: "Ruzafa"});
// Neighbourhood bakery in Benimaclet - connects pharmacy, school and supermarket chains
MERGE (:Location {name: "Panadería La Espiga",   type: "Bakery",  district: "Benimaclet"});


// --- STEP 39: ADDITIONAL TRAVEL RECORDS ------------------------------------

// Ivanenko flew Kyiv → Geneva before the symposium (Feb 6) - arrived one day before Ramin
MERGE (:TravelRecord {id: "TRV-009", type: "International Flight", code: "PS102",    origin: "Kyiv",       destination: "Geneva",    date: "2026-02-06", carrier: "Ukraine International"});
// Ivanenko flew Geneva → Valencia on Feb 9 - arrived the day BEFORE Ramin
MERGE (:TravelRecord {id: "TRV-010", type: "International Flight", code: "VY6100",   origin: "Geneva",     destination: "Valencia",  date: "2026-02-09", carrier: "Vueling"});
// Halvorsen flew Oslo → Geneva (Feb 7)
MERGE (:TravelRecord {id: "TRV-011", type: "International Flight", code: "SK4751",   origin: "Oslo",       destination: "Geneva",    date: "2026-02-07", carrier: "SAS"});


// --- STEP 40: ADDITIONAL CONTACT EVENTS ------------------------------------

// Conference speakers' dinner the evening before the public conference
// (Ivanenko, Ramin, Jordi Mas invited as local academic host - hotel dining room)
MERGE (:ContactEvent {id: "CONT-014", date: "2026-02-10", time: "20:00", duration_minutes: 120, setting: "Hotel Ateneo Suites - dining room",   type: "Conference Pre-dinner"});

// Adjacent market stall daily contact - Fátima and Omar work side by side every morning
MERGE (:ContactEvent {id: "CONT-015", date: "2026-02-12", time: "08:00", duration_minutes: 480, setting: "Mercado Central - adjacent stalls",   type: "Shared Workspace - Market"});

// Raúl's delivery stop at Mercado Central on Feb 12 - he spoke with Omar and Fátima
MERGE (:ContactEvent {id: "CONT-016", date: "2026-02-12", time: "10:30", duration_minutes:  15, setting: "Mercado Central - loading area",       type: "Delivery Drop-off"});

// Raúl's delivery stop at Restaurante La Taula on Feb 12 lunchtime - met Pau
MERGE (:ContactEvent {id: "CONT-017", date: "2026-02-12", time: "12:00", duration_minutes:  10, setting: "Restaurante La Taula - back entrance", type: "Delivery Drop-off"});

// Private post-conference academic meeting between Ivanenko and Jordi Mas
// (both have publications in the same respiratory disease journal)
MERGE (:ContactEvent {id: "CONT-018", date: "2026-02-11", time: "17:30", duration_minutes:  60, setting: "Hotel Ateneo Suites - lobby",           type: "Private Academic Meeting"});

// Pere Ferrer collected a neighbour's child at school when Laia was still contagious
MERGE (:ContactEvent {id: "CONT-019", date: "2026-02-14", time: "17:00", duration_minutes:  10, setting: "Colegio San Vicente Ferrer - entrance", type: "School Pickup"});


// --- STEP 41: ADDITIONAL TEST RESULTS --------------------------------------

// TST-015: Ivanenko POSITIVE Feb 12 - ct=19 (high load), onset Feb 11
// The earliness and high load make him look like a strong Patient Zero candidate
MERGE (:TestResult {id: "TST-015", date: "2026-02-12", type: "PCR", result: "POSITIVE", ct_value: 19, lab: "Centre Médical Genève", notes: "High viral load - tested before leaving Geneva hotel. Notified Valencia health authorities."});

// TST-016: Fátima Morales POSITIVE Feb 14 - triggers market-origin hypothesis
MERGE (:TestResult {id: "TST-016", date: "2026-02-14", type: "PCR", result: "POSITIVE", ct_value: 22, lab: "Lab Clinic Valencia",  notes: "Moderate-high viral load - adjacent stall to Omar Hassan. Raises market cluster hypothesis."});

// TST-017: Raúl Gutiérrez POSITIVE Feb 17 - late positive, many contacts
MERGE (:TestResult {id: "TST-017", date: "2026-02-17", type: "PCR", result: "POSITIVE", ct_value: 26, lab: "Centro de Salud Benimaclet", notes: "Moderate viral load - multiple delivery site contacts make source difficult to identify."});

// TST-018: Pere Ferrer POSITIVE Feb 19
MERGE (:TestResult {id: "TST-018", date: "2026-02-19", type: "PCR", result: "POSITIVE", ct_value: 24, lab: "Hospital General", notes: "Moderate viral load - school contact consistent with Laia Ferrer as source, but also frequented bakery."});

// TST-019: Ingrid Halvorsen POSITIVE Feb 14 (tested in Oslo)
MERGE (:TestResult {id: "TST-019", date: "2026-02-14", type: "PCR", result: "POSITIVE", ct_value: 21, lab: "Folkehelseinstituttet Oslo", notes: "High viral load - tested on arrival in Oslo. Exposure traced to Geneva symposium. Source: Wei Chen or Ivanenko?"});


// --- STEP 42: ADDITIONAL SYMPTOM REPORTS -----------------------------------

// Ivanenko had onset on Feb 11 - the very day of the Valencia conference
// This is EARLIER than Ramin's Feb 12 onset - the key misleading clue
MERGE (:SymptomReport {id: "SYM-012", symptoms: "fever, dry cough, body aches", onset_date: "2026-02-11", severity: "moderate", days_post_exposure: 3});

MERGE (:SymptomReport {id: "SYM-013", symptoms: "fever, runny nose, fatigue",   onset_date: "2026-02-13", severity: "mild",     days_post_exposure: 2});
MERGE (:SymptomReport {id: "SYM-014", symptoms: "fatigue, mild cough",          onset_date: "2026-02-16", severity: "mild",     days_post_exposure: 4});
MERGE (:SymptomReport {id: "SYM-015", symptoms: "fever, sore throat, chills",   onset_date: "2026-02-18", severity: "moderate", days_post_exposure: 4});
MERGE (:SymptomReport {id: "SYM-016", symptoms: "high fever, severe cough",     onset_date: "2026-02-13", severity: "moderate", days_post_exposure: 6});


// --- STEP 43: ADDITIONAL MEDICAL HISTORY -----------------------------------

// Ivanenko: Ukraine had an active VRS-26 cluster in Jan 2026 - he may have been
// exposed there, making him the true import source (not Ramin via Geneva)
MERGE (:MedicalHistory {id: "MED-009", condition: "Travel from active VRS-26 zone - Ukraine Jan 2026", relevance: "Possible pre-existing infection before Geneva symposium", risk_level: "very_high"});

// Pere Ferrer: age and comorbid hypertension
MERGE (:MedicalHistory {id: "MED-010", condition: "Hypertension and age 68",     relevance: "Elevated severity risk for respiratory illness",        risk_level: "high"});

// Raúl Gutiérrez: occupational high-contact profile
MERGE (:MedicalHistory {id: "MED-011", condition: "High-contact delivery profession", relevance: "Daily multi-site visits make source tracing very difficult", risk_level: "high"});


// --- STEP 44: WORKS_AT FOR NEW PERSONS -------------------------------------

MATCH (p:Person {name: "Fátima Morales"}), (l:Location {name: "Mercado Central"})                MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Naomi Clarke"}),   (l:Location {name: "Hotel Ateneo Suites"})            MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Tomàs Roig"}),     (l:Location {name: "Bar Deportivo Ruzafa"})            MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 45: VISITED - NEW PERSONS AND EXISTING NODES (CROSS-LOCATION NOISE)
// This section is the core of the ambiguity layer. Several existing confirmed
// cases now have movements that create plausible alternative transmission paths.

// --- Ivanenko movements ---
MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-09", time: "19:30", purpose: "Arrival from Geneva - one day before Ramin"}]->(l);

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (l:Location {name: "Hotel Ateneo Suites"})
MERGE (p)-[:VISITED {date: "2026-02-10", time: "10:00", purpose: "Conference speaker accommodation - checked in Feb 9"}]->(l);

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (l:Location {name: "Sala de Conferencias Ateneo"})
MERGE (p)-[:VISITED {date: "2026-02-11", time: "10:00", purpose: "Conference co-speaker - presented after Ramin"}]->(l);

// --- Fátima Morales movements ---
MATCH (p:Person {name: "Fátima Morales"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "07:00", purpose: "Regular market shift - adjacent stall to Omar Hassan"}]->(l);

MATCH (p:Person {name: "Fátima Morales"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "15:00", purpose: "PCR test after fever onset"}]->(l);

// --- Raúl Gutiérrez delivery movements ---
MATCH (p:Person {name: "Raúl Gutiérrez"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "10:30", purpose: "Morning delivery - produce to three stalls including Omar and Fátima"}]->(l);

MATCH (p:Person {name: "Raúl Gutiérrez"}), (l:Location {name: "Restaurante La Taula"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "12:00", purpose: "Lunch delivery - kitchen supplies"}]->(l);

MATCH (p:Person {name: "Raúl Gutiérrez"}), (l:Location {name: "Supermercado Consum Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "09:00", purpose: "Morning delivery - cold chain products"}]->(l);

MATCH (p:Person {name: "Raúl Gutiérrez"}), (l:Location {name: "Centro Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "11:00", purpose: "Delivery of sports drinks to gym reception"}]->(l);

MATCH (p:Person {name: "Raúl Gutiérrez"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-17", time: "17:00", purpose: "PCR test after mild cough and fatigue onset"}]->(l);

// --- Naomi Clarke at hotel ---
MATCH (p:Person {name: "Naomi Clarke"}), (l:Location {name: "Hotel Ateneo Suites"})
MERGE (p)-[:VISITED {date: "2026-02-10", time: "08:00", purpose: "Front desk shifts during conference check-in period Feb 10-12"}]->(l);

// --- Amina Benali ---
MATCH (p:Person {name: "Amina Benali"}), (l:Location {name: "Universidad Politécnica VLC"})
MERGE (p)-[:VISITED {date: "2026-02-18", time: "09:00", purpose: "Regular classes - same faculty as Marta Vidal"}]->(l);

MATCH (p:Person {name: "Amina Benali"}), (l:Location {name: "Centro de Salud Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-20", time: "10:30", purpose: "Voluntary PCR test - preventive, contact of Marta Vidal"}]->(l);

// --- Pere Ferrer ---
MATCH (p:Person {name: "Pere Ferrer"}), (l:Location {name: "Colegio San Vicente Ferrer"})
MERGE (p)-[:VISITED {date: "2026-02-14", time: "17:00", purpose: "Collected neighbour child from school - brief contact with Laia Ferrer at entrance"}]->(l);

MATCH (p:Person {name: "Pere Ferrer"}), (l:Location {name: "Panadería La Espiga"})
MERGE (p)-[:VISITED {date: "2026-02-15", time: "09:00", purpose: "Daily morning bread purchase - long-standing routine"}]->(l);

MATCH (p:Person {name: "Pere Ferrer"}), (l:Location {name: "Hospital General de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-19", time: "08:30", purpose: "PCR test and hypertension follow-up"}]->(l);

// --- Tomàs Roig ---
MATCH (p:Person {name: "Tomàs Roig"}), (l:Location {name: "Bar Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "20:00", purpose: "Evening bar service shift - Khalid Amrani and Elena Ribas among patrons"}]->(l);

// --- New cross-location visits for EXISTING confirmed cases ---
// These create alternative plausible chains that bypass Ramin as the common node

// Sofía Blanco visited the market BEFORE Ramin did - she could have encountered Fátima or Omar
MATCH (p:Person {name: "Sofía Blanco"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "10:00", purpose: "Buying fresh produce before afternoon yoga class"}]->(l);

// Jordi Mas had a business dinner at Restaurante La Taula the evening before the conference
MATCH (p:Person {name: "Jordi Mas"}), (l:Location {name: "Restaurante La Taula"})
MERGE (p)-[:VISITED {date: "2026-02-10", time: "21:00", purpose: "Business dinner with local client - evening before conference"}]->(l);

// Khalid Amrani visited the market on Feb 13 - same morning Ramin was there
MATCH (p:Person {name: "Khalid Amrani"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "11:00", purpose: "Buying protein-rich food after morning yoga class"}]->(l);

// Pau Giner visited the market on Feb 12 to buy produce for the restaurant
MATCH (p:Person {name: "Pau Giner"}), (l:Location {name: "Mercado Central"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "09:00", purpose: "Buying fresh produce for the restaurant kitchen"}]->(l);

// Omar Hassan visited the gym on Feb 16 (recovering, but possibly still infectious)
MATCH (p:Person {name: "Omar Hassan"}), (l:Location {name: "Centro Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-16", time: "18:00", purpose: "Light exercise session during recovery"}]->(l);

// Neus Boix was at the hospital on Feb 12 for her oncology follow-up
// This creates an alternative: could she have caught VRS-26 at the hospital?
MATCH (p:Person {name: "Neus Boix"}), (l:Location {name: "Hospital General de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-12", time: "10:00", purpose: "Routine oncology follow-up appointment"}]->(l);

// Cristina Llopis visited the bakery (same one as Pere Ferrer) on Feb 15
MATCH (p:Person {name: "Cristina Llopis"}), (l:Location {name: "Panadería La Espiga"})
MERGE (p)-[:VISITED {date: "2026-02-15", time: "08:30", purpose: "Morning pastry before supermarket shift"}]->(l);

// Beatriz Sanz picked up personal prescription at the pharmacy on Feb 16
MATCH (p:Person {name: "Beatriz Sanz"}), (l:Location {name: "Farmacia Central Benimaclet"})
MERGE (p)-[:VISITED {date: "2026-02-16", time: "15:30", purpose: "Collecting personal prescription after hospital shift"}]->(l);

// Ramin Tehrani and Ivanenko both checked into Hotel Ateneo Suites on Feb 10
MATCH (p:Person {name: "Ramin Tehrani"}), (l:Location {name: "Hotel Ateneo Suites"})
MERGE (p)-[:VISITED {date: "2026-02-10", time: "18:00", purpose: "Conference speaker accommodation - shared hotel with Ivanenko"}]->(l);

// Ingrid Halvorsen arrived at Geneva airport before the symposium
MATCH (p:Person {name: "Ingrid Halvorsen"}), (l:Location {name: "Aeropuerto Internacional Ginebra"})
MERGE (p)-[:VISITED {date: "2026-02-07", time: "21:15", purpose: "Arrival from Oslo for WHO Symposium"}]->(l);

// Carlos Oñate teaches an evening course at the university
MATCH (p:Person {name: "Carlos Oñate"}), (l:Location {name: "Universidad Politécnica VLC"})
MERGE (p)-[:VISITED {date: "2026-02-17", time: "18:00", purpose: "Evening programming course - met Marta and Amina in corridor"}]->(l);

// Bar Deportivo Ruzafa: Khalid and Elena were there the same evening Feb 13
MATCH (p:Person {name: "Khalid Amrani"}), (l:Location {name: "Bar Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "20:00", purpose: "After-work drinks with gym colleagues"}]->(l);

MATCH (p:Person {name: "Elena Ribas"}), (l:Location {name: "Bar Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "20:00", purpose: "After-work drinks with gym colleagues"}]->(l);

MATCH (p:Person {name: "Sofía Blanco"}), (l:Location {name: "Bar Deportivo Ruzafa"})
MERGE (p)-[:VISITED {date: "2026-02-13", time: "20:00", purpose: "Evening drinks with gym colleagues"}]->(l);


// --- STEP 46: TRAVEL RECORD RELATIONSHIPS FOR NEW RECORDS ------------------

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (t:TravelRecord {id: "TRV-009"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (t:TravelRecord {id: "TRV-010"}) MERGE (p)-[:BOARDED]->(t);
MATCH (p:Person {name: "Ingrid Halvorsen"}),   (t:TravelRecord {id: "TRV-011"}) MERGE (p)-[:BOARDED]->(t);

MATCH (t:TravelRecord {id: "TRV-009"}), (l:Location {name: "Aeropuerto Internacional Ginebra"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-06", time: "17:00"}]->(l);

MATCH (t:TravelRecord {id: "TRV-010"}), (l:Location {name: "Aeropuerto de Valencia"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-09", time: "19:30"}]->(l);

MATCH (t:TravelRecord {id: "TRV-011"}), (l:Location {name: "Aeropuerto Internacional Ginebra"})
MERGE (t)-[:ARRIVED_AT {date: "2026-02-07", time: "21:15"}]->(l);


// --- STEP 47: WAS_PRESENT_AT - NEW PERSONS ON EXISTING AND NEW EVENTS ------

// CONT-001 (Valencia conference): Ivanenko was also present as co-speaker
MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (c:ContactEvent {id: "CONT-001"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-002 (conference lunch): Ivanenko also attended
MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (c:ContactEvent {id: "CONT-002"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-004 (Mercado Central shopping): Khalid, Fátima and Raúl were all there the same slot
MATCH (p:Person {name: "Khalid Amrani"}),   (c:ContactEvent {id: "CONT-004"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Fátima Morales"}),  (c:ContactEvent {id: "CONT-004"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Raúl Gutiérrez"}),  (c:ContactEvent {id: "CONT-004"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// CONT-006 (supermarket): Raúl made a delivery there the same morning
MATCH (p:Person {name: "Raúl Gutiérrez"}),  (c:ContactEvent {id: "CONT-006"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

// New events
MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (c:ContactEvent {id: "CONT-014"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Ramin Tehrani"}),       (c:ContactEvent {id: "CONT-014"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Jordi Mas"}),           (c:ContactEvent {id: "CONT-014"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Naomi Clarke"}),        (c:ContactEvent {id: "CONT-014"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

MATCH (p:Person {name: "Fátima Morales"}),  (c:ContactEvent {id: "CONT-015"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Omar Hassan"}),     (c:ContactEvent {id: "CONT-015"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

MATCH (p:Person {name: "Raúl Gutiérrez"}),  (c:ContactEvent {id: "CONT-016"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Omar Hassan"}),      (c:ContactEvent {id: "CONT-016"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Fátima Morales"}),   (c:ContactEvent {id: "CONT-016"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

MATCH (p:Person {name: "Raúl Gutiérrez"}),  (c:ContactEvent {id: "CONT-017"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Pau Giner"}),        (c:ContactEvent {id: "CONT-017"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (c:ContactEvent {id: "CONT-018"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Jordi Mas"}),           (c:ContactEvent {id: "CONT-018"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);

MATCH (p:Person {name: "Pere Ferrer"}), (c:ContactEvent {id: "CONT-019"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);
MATCH (p:Person {name: "Laia Ferrer"}), (c:ContactEvent {id: "CONT-019"}) MERGE (p)-[:WAS_PRESENT_AT]->(c);


// --- STEP 48: TEST RESULT RELATIONSHIPS FOR NEW PERSONS --------------------

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (t:TestResult {id: "TST-015"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Fátima Morales"}),     (t:TestResult {id: "TST-016"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Raúl Gutiérrez"}),     (t:TestResult {id: "TST-017"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Pere Ferrer"}),        (t:TestResult {id: "TST-018"}) MERGE (p)-[:TOOK_TEST]->(t);
MATCH (p:Person {name: "Ingrid Halvorsen"}),   (t:TestResult {id: "TST-019"}) MERGE (p)-[:TOOK_TEST]->(t);


// --- STEP 49: MAY_HAVE_INFECTED - AMBIGUOUS ALTERNATIVE CHAINS -------------
// These are NOT confirmed transmissions. They represent plausible paths that
// investigators must evaluate and rule out. Confidence is deliberately mixed.

// Ivanenko arrived in Valencia before Ramin and had a pre-dinner with Jordi.
// Could he have infected Jordi independently from the conference?
MATCH (a:Person {name: "Dr. Vasyl Ivanenko"}), (b:Person {name: "Jordi Mas"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-10", setting: "Hotel Ateneo Suites pre-dinner - 2 hours indoors", confidence: "medium"}]->(b);

// Ivanenko sat next to Sofía Blanco at the conference morning session
MATCH (a:Person {name: "Dr. Vasyl Ivanenko"}), (b:Person {name: "Sofía Blanco"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-11", setting: "Conference seating - sat adjacent during Ramin keynote", confidence: "medium"}]->(b);

// Fátima to Omar: daily side-by-side stall contact - could she have been the market source, not Ramin?
MATCH (a:Person {name: "Fátima Morales"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-12", setting: "Adjacent market stall - all-day shared indoor space", confidence: "medium"}]->(b);

// Raúl to Omar: delivery contact one day before Ramin visited the market
MATCH (a:Person {name: "Raúl Gutiérrez"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-12", setting: "Market delivery - brief unmasked contact", confidence: "low"}]->(b);

// Raúl to Pau: delivery to restaurant - could explain Pau's test without the conference link
MATCH (a:Person {name: "Raúl Gutiérrez"}), (b:Person {name: "Pau Giner"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-12", setting: "Restaurant delivery - back kitchen contact", confidence: "low"}]->(b);

// Raúl to Cristina: delivery to supermarket one day before Omar's shopping visit
MATCH (a:Person {name: "Raúl Gutiérrez"}), (b:Person {name: "Cristina Llopis"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-13", setting: "Supermarket delivery - cold storage area", confidence: "low"}]->(b);

// Sofía could also have infected Jordi at the conference (they sat together)
MATCH (a:Person {name: "Sofía Blanco"}), (b:Person {name: "Jordi Mas"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-11", setting: "Conference hall - sat in same row for 2 hours", confidence: "low"}]->(b);

// Laia infected her father during school pickup
MATCH (a:Person {name: "Laia Ferrer"}), (b:Person {name: "Pere Ferrer"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-14", setting: "School entrance - brief outdoor farewell contact", confidence: "high"}]->(b);

// Omar Hassan could have been the one who infected Fátima (reverse direction)
MATCH (a:Person {name: "Omar Hassan"}), (b:Person {name: "Fátima Morales"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-13", setting: "Adjacent market stall - direction of transmission unclear", confidence: "low"}]->(b);

// Khalid Amrani was at the market the same time as Ramin on Feb 13
// Could Khalid have caught it at the market rather than at the yoga class?
MATCH (a:Person {name: "Ramin Tehrani"}), (b:Person {name: "Khalid Amrani"})
MERGE (a)-[:MAY_HAVE_INFECTED {date: "2026-02-13", setting: "Mercado Central - same market visit slot", confidence: "low"}]->(b);


// --- STEP 50: SYMPTOM REPORT RELATIONSHIPS FOR NEW PERSONS -----------------

MATCH (s:SymptomReport {id: "SYM-012"}), (p:Person {name: "Dr. Vasyl Ivanenko"})
MERGE (s)-[:REPORTED_BY {basis: "Onset Feb 11 - same day as Valencia conference, earlier than Ramin (Feb 12). Raises question of who infected whom."}]->(p);

MATCH (s:SymptomReport {id: "SYM-013"}), (p:Person {name: "Fátima Morales"})
MERGE (s)-[:REPORTED_BY {basis: "Onset Feb 13 - consistent with market exposure Feb 12, either from Omar or Raúl delivery"}]->(p);

MATCH (s:SymptomReport {id: "SYM-014"}), (p:Person {name: "Raúl Gutiérrez"})
MERGE (s)-[:REPORTED_BY {basis: "Onset Feb 16 after multiple delivery site contacts - impossible to identify single source"}]->(p);

MATCH (s:SymptomReport {id: "SYM-015"}), (p:Person {name: "Pere Ferrer"})
MERGE (s)-[:REPORTED_BY {basis: "Onset Feb 18 - consistent with school contact (Laia) and also bakery (Cristina earlier customer)"}]->(p);

MATCH (s:SymptomReport {id: "SYM-016"}), (p:Person {name: "Ingrid Halvorsen"})
MERGE (s)-[:REPORTED_BY {basis: "Onset Feb 13 in Oslo - 5 days post Geneva symposium. Source: Wei Chen, Ivanenko, or Ramin?"}]->(p);

MATCH (s:SymptomReport {id: "SYM-012"}), (l:Location {name: "Hospital General de Valencia"})   MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-013"}), (l:Location {name: "Centro de Salud Benimaclet"})     MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-014"}), (l:Location {name: "Centro de Salud Benimaclet"})     MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-015"}), (l:Location {name: "Hospital General de Valencia"})   MERGE (s)-[:RECORDED_AT]->(l);
MATCH (s:SymptomReport {id: "SYM-016"}), (l:Location {name: "Folkehelseinstituttet Oslo"})     MERGE (s)-[:RECORDED_AT]->(l);


// --- STEP 51: MEDICAL HISTORY FOR NEW PERSONS ------------------------------

MATCH (p:Person {name: "Dr. Vasyl Ivanenko"}), (m:MedicalHistory {id: "MED-009"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Pere Ferrer"}),         (m:MedicalHistory {id: "MED-010"}) MERGE (p)-[:HAS_HISTORY]->(m);
MATCH (p:Person {name: "Raúl Gutiérrez"}),      (m:MedicalHistory {id: "MED-011"}) MERGE (p)-[:HAS_HISTORY]->(m);


// --- STEP 52: EXTENDED KNOWS NETWORK (SOCIAL WEB NOISE) --------------------
// Adds pre-existing social and professional ties not previously recorded.
// These create visual hubs that make any single node look equally central.

// Ramin and Ivanenko knew each other from a prior conference (2024 Amsterdam)
MATCH (a:Person {name: "Dr. Vasyl Ivanenko"}), (b:Person {name: "Ramin Tehrani"})
MERGE (a)-[:KNOWS {since: 2024, context: "Co-authored paper on respiratory virus surveillance"}]->(b);

// Ivanenko and Prof. Wei Chen are colleagues - same research institute network
MATCH (a:Person {name: "Dr. Vasyl Ivanenko"}), (b:Person {name: "Prof. Wei Chen"})
MERGE (a)-[:KNOWS {since: 2018, context: "Virology international research network - WHO advisory board"}]->(b);

// Ivanenko and Jordi Mas had a prior academic collaboration
MATCH (a:Person {name: "Dr. Vasyl Ivanenko"}), (b:Person {name: "Jordi Mas"})
MERGE (a)-[:KNOWS {since: 2022, context: "Jordi hosted a public health data workshop Ivanenko attended"}]->(b);

// Omar and Fátima are long-standing market neighbors
MATCH (a:Person {name: "Omar Hassan"}), (b:Person {name: "Fátima Morales"})
MERGE (a)-[:KNOWS {since: 2017, context: "Adjacent market stall vendors - 8 years working side by side"}]->(b);

// Pau buys regularly from Omar's stall for the restaurant
MATCH (a:Person {name: "Pau Giner"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:KNOWS {since: 2023, context: "Restaurant supplier relationship - weekly produce purchase"}]->(b);

// Cristina and Neus know each other - Neus is a long-standing supermarket regular
MATCH (a:Person {name: "Cristina Llopis"}), (b:Person {name: "Neus Boix"})
MERGE (a)-[:KNOWS {since: 2021, context: "Regular customer at supermarket checkout every Thursday"}]->(b);

// Raúl delivers to both the market and the restaurant - knows Omar and Pau
MATCH (a:Person {name: "Raúl Gutiérrez"}), (b:Person {name: "Omar Hassan"})
MERGE (a)-[:KNOWS {since: 2022, context: "Regular delivery client at Mercado Central"}]->(b);

MATCH (a:Person {name: "Raúl Gutiérrez"}), (b:Person {name: "Pau Giner"})
MERGE (a)-[:KNOWS {since: 2022, context: "Regular delivery client at Restaurante La Taula"}]->(b);

// Pere Ferrer is Laia's father - they live together
MATCH (a:Person {name: "Pere Ferrer"}), (b:Person {name: "Laia Ferrer"})
MERGE (a)-[:KNOWS {since: 1988, context: "Father and daughter - shared household"}]->(b);

// Tomàs Roig knows the gym crowd - staff and regulars visit the bar often
MATCH (a:Person {name: "Tomàs Roig"}), (b:Person {name: "Khalid Amrani"})
MERGE (a)-[:KNOWS {since: 2020, context: "Regular customer at Bar Deportivo after training sessions"}]->(b);

MATCH (a:Person {name: "Tomàs Roig"}), (b:Person {name: "Elena Ribas"})
MERGE (a)-[:KNOWS {since: 2021, context: "Regular customer at Bar Deportivo after fitness classes"}]->(b);

MATCH (a:Person {name: "Tomàs Roig"}), (b:Person {name: "Sofía Blanco"})
MERGE (a)-[:KNOWS {since: 2021, context: "Regular gym instructor who visits bar after work"}]->(b);

// Amina Benali and Marta Vidal are close university friends
MATCH (a:Person {name: "Amina Benali"}), (b:Person {name: "Marta Vidal"})
MERGE (a)-[:KNOWS {since: 2023, context: "Same degree cohort - study group members"}]->(b);

// Carlos Oñate knows Marta and Amina from the university evening course
MATCH (a:Person {name: "Carlos Oñate"}), (b:Person {name: "Marta Vidal"})
MERGE (a)-[:KNOWS {since: 2025, context: "Evening programming course at UPV - Carlos teaches, Marta attends"}]->(b);

// Naomi Clarke knows Ramin and Ivanenko (checked them in)
MATCH (a:Person {name: "Naomi Clarke"}), (b:Person {name: "Ramin Tehrani"})
MERGE (a)-[:KNOWS {since: 2026, context: "Hotel check-in interaction Feb 10 - provided room keys and city map"}]->(b);

MATCH (a:Person {name: "Naomi Clarke"}), (b:Person {name: "Dr. Vasyl Ivanenko"})
MERGE (a)-[:KNOWS {since: 2026, context: "Hotel check-in interaction Feb 9 - Ivanenko arrived one day earlier"}]->(b);

// Beatriz Sanz knows Rosa Camps (professional network, both healthcare)
MATCH (a:Person {name: "Beatriz Sanz"}), (b:Person {name: "Rosa Camps"})
MERGE (a)-[:KNOWS {since: 2023, context: "Professional healthcare network - occasional hospital-pharmacy coordination"}]->(b);


// --- STEP 53: INVESTIGATOR RELATIONSHIPS EXTENDED -------------------------

// Carmen Valls also investigated Ivanenko as an alternative Patient Zero
MATCH (a:Person {name: "Dra. Carmen Valls"}), (b:Person {name: "Dr. Vasyl Ivanenko"})
MERGE (a)-[:INVESTIGATED {date: "2026-02-15", reason: "Alternative Patient Zero candidate - arrived in Valencia before Ramin, positive PCR with ct=19"}]->(b);

// Miguel Torres conducted contact tracing for the new cases
MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Fátima Morales"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-15", context: "Market cluster investigation - adjacent stall to Omar Hassan"}]->(b);

MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Raúl Gutiérrez"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-18", context: "Super-connector follow-up - multiple site contacts, route reconstruction"}]->(b);

MATCH (a:Person {name: "Miguel Torres"}), (b:Person {name: "Pere Ferrer"})
MERGE (a)-[:INTERVIEWED {date: "2026-02-20", context: "School-family chain - confirmed link via Laia Ferrer"}]->(b);

// Dra. Ana Puig treated Pere Ferrer and Beatriz Sanz
MATCH (a:Person {name: "Dra. Ana Puig"}), (b:Person {name: "Beatriz Sanz"})
MERGE (a)-[:TREATED {from_date: "2026-02-18", to_date: "2026-02-23", outcome: "Discharged - occupational exposure confirmed, PPE protocol updated"}]->(b);

MATCH (a:Person {name: "Dra. Ana Puig"}), (b:Person {name: "Pere Ferrer"})
MERGE (a)-[:TREATED {from_date: "2026-02-19", to_date: "2026-02-25", outcome: "Discharged - hypertension managed, full recovery"}]->(b);


// --- STEP 54: FULL VERIFY ---------------------------------------------------
// Run this query after loading all 53 steps to confirm the complete dataset.
//
// Expected node counts:
// Person           | 27
// Location         | 20
// ContactEvent     | 19
// TestResult       | 19
// TravelRecord     | 11
// SymptomReport    | 16
// MedicalHistory   | 11
// TOTAL            | 123

MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;
