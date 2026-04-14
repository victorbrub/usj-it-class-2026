// =============================================================================
// The Valencia Museum Heist - Database Setup
// Paste this entire file into the Neo4j Browser query editor and run it.
// Alternatively, run each section separately using the separators as guides.
// =============================================================================


// --- STEP 1: CLEAR EXISTING DATA -------------------------------------------

MATCH (n) DETACH DELETE n;


// --- STEP 2: CREATE CONSTRAINTS ---------------------------------------------

CREATE CONSTRAINT person_name IF NOT EXISTS
FOR (p:Person) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT location_name IF NOT EXISTS
FOR (l:Location) REQUIRE l.name IS UNIQUE;

CREATE CONSTRAINT vehicle_plate IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.plate IS UNIQUE;


// --- STEP 3: PERSONS --------------------------------------------------------

// Museum staff
MERGE (:Person {name: "Martina Soler",    role: "Museum Director",     age: 52, phone: "600-111-001"});
MERGE (:Person {name: "Carlos Vidal",     role: "Night Security Guard", age: 34, phone: "600-111-002"});
MERGE (:Person {name: "Rosa Ferrer",      role: "Cleaning Staff",       age: 41, phone: "600-111-003"});

// Suspects
MERGE (:Person {name: "Andres Fuentes",   role: "Art Dealer",           age: 47, phone: "600-222-001"});
MERGE (:Person {name: "Elena Marchetti",  role: "Freelance Restorer",   age: 38, phone: "600-222-002"});
MERGE (:Person {name: "Tomás Reig",       role: "Unemployed",           age: 29, phone: "600-222-003"});
MERGE (:Person {name: "Lucía Peñas",      role: "Private Driver",       age: 44, phone: "600-222-004"});
MERGE (:Person {name: "Iván Bosch",       role: "Electrician",          age: 36, phone: "600-222-005"});
MERGE (:Person {name: "Nadia Orlov",      role: "Antique Shop Owner",   age: 51, phone: "600-222-006"});
MERGE (:Person {name: "Félix Castillo",   role: "Art Collector",        age: 63, phone: "600-222-007"});

// Witnesses
MERGE (:Person {name: "Pablo Ruiz",       role: "Taxi Driver",          age: 33, phone: "600-333-001"});
MERGE (:Person {name: "Sara Montoya",     role: "Bar Owner",            age: 45, phone: "600-333-002"});

// Police
MERGE (:Person {name: "Inspector Dávila", role: "Lead Investigator",    age: 49, phone: "600-444-001"});
MERGE (:Person {name: "Officer Sanz",     role: "Crime Scene Officer",  age: 31, phone: "600-444-002"});


// --- STEP 4: LOCATIONS ------------------------------------------------------

MERGE (:Location {name: "Museo de Arte Moderno de Valencia", type: "Museum",         district: "Ciutat Vella"});
MERGE (:Location {name: "Bar El Rincón",                     type: "Bar",            district: "Ruzafa"});
MERGE (:Location {name: "Galería Marchetti",                 type: "Art Gallery",    district: "El Carmen"});
MERGE (:Location {name: "Almacén Industrial Rioja",          type: "Warehouse",      district: "Patraix"});
MERGE (:Location {name: "Piso Andres Fuentes",               type: "Residence",      district: "Eixample"});
MERGE (:Location {name: "Taller Iván Bosch",                 type: "Workshop",       district: "Benimaclet"});
MERGE (:Location {name: "Tienda Nadia Orlov",                type: "Antique Shop",   district: "El Carmen"});
MERGE (:Location {name: "Puerto de Valencia",                type: "Port",           district: "Poblats Marítims"});
MERGE (:Location {name: "Parking Mestalla",                  type: "Parking",        district: "Algirós"});
MERGE (:Location {name: "Hotel Valentia",                    type: "Hotel",          district: "Extramurs"});
MERGE (:Location {name: "Aeropuerto de Valencia",            type: "Airport",        district: "Alboraia"});
MERGE (:Location {name: "Comisaría Central",                 type: "Police Station", district: "Extramurs"});


// --- STEP 5: VEHICLES -------------------------------------------------------

MERGE (:Vehicle {plate: "4782-KLM", type: "Van",      color: "White",  model: "Ford Transit"});
MERGE (:Vehicle {plate: "9901-ABX", type: "Car",      color: "Black",  model: "BMW 320"});
MERGE (:Vehicle {plate: "1144-ZZP", type: "Motorbike",color: "Red",    model: "Honda CB500"});
MERGE (:Vehicle {plate: "5530-GHT", type: "Car",      color: "Silver", model: "Seat León"});
MERGE (:Vehicle {plate: "7723-NNQ", type: "Van",      color: "Grey",   model: "Mercedes Sprinter"});


// --- STEP 6: PHONE CALLS (night of March 3rd) -------------------------------

MERGE (:PhoneCall {id: "CALL-001", date: "2026-03-03", time: "22:15", duration_seconds: 187, tower: "Ciutat Vella"});
MERGE (:PhoneCall {id: "CALL-002", date: "2026-03-03", time: "22:31", duration_seconds:  43, tower: "Ciutat Vella"});
MERGE (:PhoneCall {id: "CALL-003", date: "2026-03-03", time: "22:48", duration_seconds: 312, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-004", date: "2026-03-03", time: "23:02", duration_seconds:  95, tower: "Ruzafa"});
MERGE (:PhoneCall {id: "CALL-005", date: "2026-03-03", time: "23:19", duration_seconds: 228, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-006", date: "2026-03-03", time: "23:45", duration_seconds:  61, tower: "Poblats Marítims"});
MERGE (:PhoneCall {id: "CALL-007", date: "2026-03-04", time: "00:03", duration_seconds: 144, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-008", date: "2026-03-04", time: "00:22", duration_seconds:  76, tower: "Ciutat Vella"});


// --- STEP 7: FINANCIAL TRANSACTIONS (March 1-5) -----------------------------

MERGE (:FinancialTransaction {id: "TXN-001", date: "2026-03-01", amount:  15000, currency: "EUR", type: "Wire Transfer",    concept: "Art consultation fee"});
MERGE (:FinancialTransaction {id: "TXN-002", date: "2026-03-02", amount:   3200, currency: "EUR", type: "Cash Deposit",     concept: "Unknown"});
MERGE (:FinancialTransaction {id: "TXN-003", date: "2026-03-03", amount:    800, currency: "EUR", type: "Wire Transfer",    concept: "Electrical services"});
MERGE (:FinancialTransaction {id: "TXN-004", date: "2026-03-04", amount:  50000, currency: "EUR", type: "Wire Transfer",    concept: "Painting acquisition"});
MERGE (:FinancialTransaction {id: "TXN-005", date: "2026-03-04", amount:  50000, currency: "EUR", type: "Wire Transfer",    concept: "Art investment"});
MERGE (:FinancialTransaction {id: "TXN-006", date: "2026-03-05", amount:   9500, currency: "EUR", type: "Cash Withdrawal",  concept: "Unknown"});
MERGE (:FinancialTransaction {id: "TXN-007", date: "2026-03-05", amount:   1200, currency: "EUR", type: "Wire Transfer",    concept: "Transport services"});


// --- STEP 8: EVIDENCE -------------------------------------------------------

MERGE (:Evidence {id: "EVD-001", type: "Fingerprint", description: "Partial fingerprint on alarm panel",                   location_found: "Security Room"});
MERGE (:Evidence {id: "EVD-002", type: "Footprint",   description: "Size 42 boot print in dust near loading bay",          location_found: "Loading Bay"});
MERGE (:Evidence {id: "EVD-003", type: "Tool",        description: "Wire cutters with epoxy residue",                      location_found: "Loading Bay"});
MERGE (:Evidence {id: "EVD-004", type: "Fibre",       description: "Blue polyester fibres on broken display case",         location_found: "Gallery Room 3"});
MERGE (:Evidence {id: "EVD-005", type: "Receipt",     description: "Crumpled receipt from hardware store dated 2026-03-02",location_found: "Service Corridor"});
MERGE (:Evidence {id: "EVD-006", type: "CCTV_Frame",  description: "Partial image of white van near museum at 23:05",      location_found: "Street Camera"});


// --- STEP 9: CRIMINAL RECORDS -----------------------------------------------

MERGE (:CriminalRecord {id: "REC-001", offense: "Receiving stolen goods", year: 2019, sentenced: false});
MERGE (:CriminalRecord {id: "REC-002", offense: "Art fraud",              year: 2017, sentenced: true});
MERGE (:CriminalRecord {id: "REC-003", offense: "Breaking and entering",  year: 2021, sentenced: true});
MERGE (:CriminalRecord {id: "REC-004", offense: "Money laundering",       year: 2020, sentenced: false});


// --- STEP 10: WORKS_AT RELATIONSHIPS ----------------------------------------

MATCH (p:Person {name: "Martina Soler"}),    (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Carlos Vidal"}),     (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Rosa Ferrer"}),      (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Elena Marchetti"}),  (l:Location {name: "Galería Marchetti"})                 MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Iván Bosch"}),       (l:Location {name: "Taller Iván Bosch"})                 MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Nadia Orlov"}),      (l:Location {name: "Tienda Nadia Orlov"})                MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Sara Montoya"}),     (l:Location {name: "Bar El Rincón"})                     MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Inspector Dávila"}), (l:Location {name: "Comisaría Central"})                 MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Officer Sanz"}),     (l:Location {name: "Comisaría Central"})                 MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 11: VISITED RELATIONSHIPS -----------------------------------------

MATCH (p:Person {name: "Andres Fuentes"}),  (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-20", time: "11:00", purpose: "Private viewing"}]->(l);

MATCH (p:Person {name: "Elena Marchetti"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-28", time: "09:30", purpose: "Restoration assessment"}]->(l);

MATCH (p:Person {name: "Félix Castillo"}),  (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-01", time: "16:00", purpose: "Gala attendance"}]->(l);

MATCH (p:Person {name: "Iván Bosch"}),      (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-02", time: "08:45", purpose: "Electrical maintenance contract"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}),      (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "14:00", purpose: "Tourist visit"}]->(l);

MATCH (p:Person {name: "Iván Bosch"}),      (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "21:00", purpose: "Unknown"}]->(l);

MATCH (p:Person {name: "Lucía Peñas"}),     (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "21:30", purpose: "Unknown"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}),      (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-04", time: "01:00", purpose: "Unknown"}]->(l);

MATCH (p:Person {name: "Andres Fuentes"}),  (l:Location {name: "Hotel Valentia"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "20:00", purpose: "Business dinner"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}),      (l:Location {name: "Bar El Rincón"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "19:00", purpose: "Drinks"}]->(l);

MATCH (p:Person {name: "Pablo Ruiz"}),      (l:Location {name: "Parking Mestalla"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "22:00", purpose: "Fare pickup"}]->(l);

MATCH (p:Person {name: "Nadia Orlov"}),     (l:Location {name: "Puerto de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-05", time: "07:00", purpose: "Shipment collection"}]->(l);


// --- STEP 12: VEHICLE OWNERSHIP AND SIGHTINGS --------------------------------

MATCH (p:Person {name: "Iván Bosch"}),     (v:Vehicle {plate: "4782-KLM"}) MERGE (p)-[:OWNS]->(v);
MATCH (p:Person {name: "Andres Fuentes"}), (v:Vehicle {plate: "9901-ABX"}) MERGE (p)-[:OWNS]->(v);
MATCH (p:Person {name: "Lucía Peñas"}),    (v:Vehicle {plate: "1144-ZZP"}) MERGE (p)-[:OWNS]->(v);
MATCH (p:Person {name: "Nadia Orlov"}),    (v:Vehicle {plate: "5530-GHT"}) MERGE (p)-[:OWNS]->(v);
MATCH (p:Person {name: "Tomás Reig"}),     (v:Vehicle {plate: "7723-NNQ"}) MERGE (p)-[:OWNS]->(v);

MATCH (v:Vehicle {plate: "4782-KLM"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-03", time: "23:05"}]->(l);

MATCH (v:Vehicle {plate: "4782-KLM"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-03", time: "23:50"}]->(l);

MATCH (v:Vehicle {plate: "7723-NNQ"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-04", time: "00:45"}]->(l);

MATCH (v:Vehicle {plate: "9901-ABX"}), (l:Location {name: "Hotel Valentia"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-03", time: "20:05"}]->(l);

MATCH (v:Vehicle {plate: "5530-GHT"}), (l:Location {name: "Puerto de Valencia"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-05", time: "06:55"}]->(l);


// --- STEP 13: PHONE CALL RELATIONSHIPS --------------------------------------

MATCH (p:Person {name: "Iván Bosch"}),    (c:PhoneCall {id: "CALL-001"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-001"}),     (p:Person {name: "Lucía Peñas"})   MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Lucía Peñas"}),   (c:PhoneCall {id: "CALL-002"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-002"}),     (p:Person {name: "Iván Bosch"})    MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Tomás Reig"}),    (c:PhoneCall {id: "CALL-003"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-003"}),     (p:Person {name: "Nadia Orlov"})   MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Carlos Vidal"}),  (c:PhoneCall {id: "CALL-004"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-004"}),     (p:Person {name: "Martina Soler"}) MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Iván Bosch"}),    (c:PhoneCall {id: "CALL-005"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-005"}),     (p:Person {name: "Tomás Reig"})    MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Nadia Orlov"}),   (c:PhoneCall {id: "CALL-006"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-006"}),     (p:Person {name: "Félix Castillo"}) MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Iván Bosch"}),    (c:PhoneCall {id: "CALL-007"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-007"}),     (p:Person {name: "Lucía Peñas"})   MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Carlos Vidal"}),  (c:PhoneCall {id: "CALL-008"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-008"}),     (p:Person {name: "Rosa Ferrer"})   MERGE (c)-[:RECEIVED_BY]->(p);


// --- STEP 14: FINANCIAL TRANSACTION RELATIONSHIPS ---------------------------

// TXN-001: Félix Castillo -> Andres Fuentes (art consultation)
MATCH (p:Person {name: "Félix Castillo"}),  (t:FinancialTransaction {id: "TXN-001"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-001"}), (p:Person {name: "Andres Fuentes"})  MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-002: Tomás Reig cash deposit (unknown origin)
MATCH (p:Person {name: "Tomás Reig"}),      (t:FinancialTransaction {id: "TXN-002"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-002"}), (p:Person {name: "Tomás Reig"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-003: Museum pays Iván Bosch for electrical work
MATCH (p:Person {name: "Martina Soler"}),   (t:FinancialTransaction {id: "TXN-003"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-003"}), (p:Person {name: "Iván Bosch"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-004: Félix Castillo -> Nadia Orlov (painting acquisition, post-theft)
MATCH (p:Person {name: "Félix Castillo"}),  (t:FinancialTransaction {id: "TXN-004"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-004"}), (p:Person {name: "Nadia Orlov"})     MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-005: Andres Fuentes -> Nadia Orlov (art investment, post-theft)
MATCH (p:Person {name: "Andres Fuentes"}),  (t:FinancialTransaction {id: "TXN-005"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-005"}), (p:Person {name: "Nadia Orlov"})     MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-006: Iván Bosch cash withdrawal (post-theft)
MATCH (p:Person {name: "Iván Bosch"}),      (t:FinancialTransaction {id: "TXN-006"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-006"}), (p:Person {name: "Iván Bosch"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-007: Iván Bosch -> Lucía Peñas (transport payment)
MATCH (p:Person {name: "Iván Bosch"}),      (t:FinancialTransaction {id: "TXN-007"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-007"}), (p:Person {name: "Lucía Peñas"})     MERGE (t)-[:RECEIVED_BY]->(p);


// --- STEP 15: KNOWS RELATIONSHIPS -------------------------------------------

MATCH (a:Person {name: "Iván Bosch"}),      (b:Person {name: "Tomás Reig"})      MERGE (a)-[:KNOWS {since: 2018, context: "Neighborhood"}]->(b);
MATCH (a:Person {name: "Iván Bosch"}),      (b:Person {name: "Lucía Peñas"})     MERGE (a)-[:KNOWS {since: 2022, context: "Work contact"}]->(b);
MATCH (a:Person {name: "Tomás Reig"}),      (b:Person {name: "Nadia Orlov"})     MERGE (a)-[:KNOWS {since: 2020, context: "Antique market"}]->(b);
MATCH (a:Person {name: "Nadia Orlov"}),     (b:Person {name: "Félix Castillo"})  MERGE (a)-[:KNOWS {since: 2015, context: "Art world"}]->(b);
MATCH (a:Person {name: "Andres Fuentes"}),  (b:Person {name: "Félix Castillo"})  MERGE (a)-[:KNOWS {since: 2010, context: "Art Collector network"}]->(b);
MATCH (a:Person {name: "Andres Fuentes"}),  (b:Person {name: "Elena Marchetti"}) MERGE (a)-[:KNOWS {since: 2019, context: "Art gallery circuit"}]->(b);
MATCH (a:Person {name: "Elena Marchetti"}), (b:Person {name: "Martina Soler"})   MERGE (a)-[:KNOWS {since: 2021, context: "Museum restoration contract"}]->(b);
MATCH (a:Person {name: "Carlos Vidal"}),    (b:Person {name: "Rosa Ferrer"})     MERGE (a)-[:KNOWS {since: 2023, context: "Colleagues"}]->(b);
MATCH (a:Person {name: "Iván Bosch"}),      (b:Person {name: "Carlos Vidal"})    MERGE (a)-[:KNOWS {since: 2026, context: "Electrical work at museum"}]->(b);
MATCH (a:Person {name: "Pablo Ruiz"}),      (b:Person {name: "Tomás Reig"})      MERGE (a)-[:KNOWS {since: 2024, context: "Taxi fare - regular customer"}]->(b);


// --- STEP 16: EVIDENCE -> LOCATION AND EVIDENCE -> PERSON -------------------

MATCH (e:Evidence {id: "EVD-001"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-002"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-003"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-004"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-005"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-006"}), (l:Location {name: "Museo de Arte Moderno de Valencia"}) MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-001"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "medium", basis: "Access registry matches fingerprint zone"}]->(p);

MATCH (e:Evidence {id: "EVD-002"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "high", basis: "Boot size matches, same model purchased March 2nd"}]->(p);

MATCH (e:Evidence {id: "EVD-003"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "high", basis: "Epoxy brand matches supplies found in Taller Iván Bosch"}]->(p);

MATCH (e:Evidence {id: "EVD-004"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "medium", basis: "Fibres match workwear brand used by electricians"}]->(p);

MATCH (e:Evidence {id: "EVD-005"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "high", basis: "Receipt from Ferretería Camino, same store used for job materials"}]->(p);

MATCH (e:Evidence {id: "EVD-006"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "high", basis: "Plate 4782-KLM belongs to Iván Bosch, white Ford Transit"}]->(p);


// --- STEP 17: CRIMINAL RECORDS ----------------------------------------------

MATCH (p:Person {name: "Nadia Orlov"}),    (r:CriminalRecord {id: "REC-001"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Andres Fuentes"}), (r:CriminalRecord {id: "REC-002"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Tomás Reig"}),     (r:CriminalRecord {id: "REC-003"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Félix Castillo"}), (r:CriminalRecord {id: "REC-004"}) MERGE (p)-[:HAS_RECORD]->(r);


// =============================================================================
// EXTENDED DATA - Additional nodes and relationships for a more realistic scenario
// =============================================================================


// --- STEP 19: ADDITIONAL PERSONS --------------------------------------------

// Insurance investigator assigned to the museum policy
MERGE (:Person {name: "Carmen Ibáñez",  role: "Insurance Investigator", age: 43, phone: "600-555-001"});

// Intermediary courier used to move goods between criminal actors
MERGE (:Person {name: "Dimitri Sava",   role: "Courier",                age: 31, phone: "600-555-002"});

// Former museum technician and ex-colleague of Iván Bosch
MERGE (:Person {name: "Jorge Molina",   role: "Former Museum Technician", age: 40, phone: "600-555-003"});


// --- STEP 20: ADDITIONAL LOCATIONS ------------------------------------------

// Climate-controlled storage unit rented anonymously in the port district
MERGE (:Location {name: "Trastero Climatizado Mar",  type: "Storage Unit",     district: "Poblats Marítims"});

// Private members' club used for discreet meetings among art-world figures
MERGE (:Location {name: "Club Privado Almudín",       type: "Private Club",     district: "Ciutat Vella"});

// Hardware store where evidence receipt (EVD-005) was issued
MERGE (:Location {name: "Ferretería Camino",           type: "Hardware Store",   district: "Benimaclet"});


// --- STEP 21: ADDITIONAL VEHICLE --------------------------------------------

// Rental car used by Andres Fuentes the night of the crime (not his regular BMW)
MERGE (:Vehicle {plate: "3310-RTV", type: "Car", color: "Dark Blue", model: "Volkswagen Passat"});


// --- STEP 22: PAINTING NODE -------------------------------------------------

// The stolen artwork
MERGE (:Painting {
  id:         "PAINT-001",
  title:      "La Sombra del Rio",
  artist:     "Elías Mora",
  year:       1987,
  value_eur:  2400000,
  status:     "Stolen",
  insured:    true,
  insurer:    "Seguros Arte Levante S.A."
});


// --- STEP 23: ADDITIONAL PHONE CALLS ----------------------------------------

// Pre-crime planning calls (February 28 – March 2)
MERGE (:PhoneCall {id: "CALL-009", date: "2026-02-28", time: "20:05", duration_seconds: 421, tower: "Benimaclet"});
MERGE (:PhoneCall {id: "CALL-010", date: "2026-03-02", time: "18:33", duration_seconds: 298, tower: "Benimaclet"});

// Post-crime coordination call from the port area
MERGE (:PhoneCall {id: "CALL-011", date: "2026-03-05", time: "06:40", duration_seconds: 183, tower: "Poblats Marítims"});

// A call between Andres Fuentes and Félix Castillo the morning after the theft
MERGE (:PhoneCall {id: "CALL-012", date: "2026-03-04", time: "09:15", duration_seconds: 512, tower: "Eixample"});


// --- STEP 24: ADDITIONAL FINANCIAL TRANSACTIONS -----------------------------

// Storage unit rental paid in cash – links to post-theft concealment
MERGE (:FinancialTransaction {id: "TXN-008", date: "2026-03-01", amount:   600, currency: "EUR", type: "Cash Payment",   concept: "Storage unit rental - 3 months"});

// Payment from Nadia Orlov to Dimitri Sava for courier services
MERGE (:FinancialTransaction {id: "TXN-009", date: "2026-03-06", amount:  2500, currency: "EUR", type: "Wire Transfer",  concept: "Courier and logistics"});

// Rental car booking paid on Andres Fuentes's corporate card
MERGE (:FinancialTransaction {id: "TXN-010", date: "2026-03-03", amount:   185, currency: "EUR", type: "Card Payment",   concept: "Vehicle rental - 1 day"});

// Large cash deposit by Dimitri Sava shortly after receiving courier payment
MERGE (:FinancialTransaction {id: "TXN-011", date: "2026-03-07", amount:  2000, currency: "EUR", type: "Cash Deposit",   concept: "Unknown"});


// --- STEP 25: ADDITIONAL EVIDENCE -------------------------------------------

// Burner phone SIM card found behind a dumpster near the warehouse
MERGE (:Evidence {id: "EVD-007", type: "SIM Card",     description: "Prepaid SIM registered to a false name, last tower ping Patraix 00:15",  location_found: "Almacén Industrial Rioja exterior"});

// Partial glove left inside the museum cleaning supply cupboard
MERGE (:Evidence {id: "EVD-008", type: "Glove",        description: "Right-hand latex glove with partial DNA trace, cupboard near Gallery Room 3", location_found: "Gallery Room 3 Corridor"});

// Rental car key fob dropped in the hotel car park
MERGE (:Evidence {id: "EVD-009", type: "Key Fob",      description: "Rental car fob matching plate 3310-RTV, found in Hotel Valentia parking area", location_found: "Hotel Valentia"});


// --- STEP 26: ADDITIONAL CRIMINAL RECORD ------------------------------------

MERGE (:CriminalRecord {id: "REC-005", offense: "Handling stolen property (international)", year: 2023, sentenced: false});


// --- STEP 27: PAINTING RELATIONSHIPS ----------------------------------------

// The museum owns the painting
MATCH (l:Location {name: "Museo de Arte Moderno de Valencia"}), (pt:Painting {id: "PAINT-001"})
MERGE (l)-[:OWNS_ARTWORK]->(pt);

// After the theft the painting is stored at the climate-controlled unit
MATCH (pt:Painting {id: "PAINT-001"}), (l:Location {name: "Trastero Climatizado Mar"})
MERGE (pt)-[:STORED_AT {date: "2026-03-04", confirmed: false}]->(l);

// The painting was insured; Carmen Ibáñez is assigned to the case
MATCH (p:Person {name: "Carmen Ibáñez"}), (pt:Painting {id: "PAINT-001"})
MERGE (p)-[:INVESTIGATES]->(pt);

// Félix Castillo intended to acquire the painting (motive)
MATCH (p:Person {name: "Félix Castillo"}), (pt:Painting {id: "PAINT-001"})
MERGE (p)-[:SOUGHT_TO_ACQUIRE {method: "through intermediaries", documented: false}]->(pt);


// --- STEP 28: ADDITIONAL PERSON RELATIONSHIPS --------------------------------

// Jorge Molina knows Iván Bosch from their time working at the museum together
MATCH (a:Person {name: "Iván Bosch"}),      (b:Person {name: "Jorge Molina"})
MERGE (a)-[:KNOWS {since: 2019, context: "Former colleagues at museum"}]->(b);

// Jorge Molina also knows Nadia Orlov through second-hand dealings
MATCH (a:Person {name: "Jorge Molina"}),    (b:Person {name: "Nadia Orlov"})
MERGE (a)-[:KNOWS {since: 2022, context: "Introduced at antique fair"}]->(b);

// Dimitri Sava is a regular contact of Nadia Orlov for logistics
MATCH (a:Person {name: "Nadia Orlov"}),     (b:Person {name: "Dimitri Sava"})
MERGE (a)-[:KNOWS {since: 2021, context: "Logistics and shipping"}]->(b);

// Carmen Ibáñez has a professional relationship with Martina Soler (insurer-director)
MATCH (a:Person {name: "Carmen Ibáñez"}),   (b:Person {name: "Martina Soler"})
MERGE (a)-[:KNOWS {since: 2024, context: "Insurance policy audit"}]->(b);

// Andres Fuentes knows Jorge Molina through the gallery circuit
MATCH (a:Person {name: "Andres Fuentes"}),  (b:Person {name: "Jorge Molina"})
MERGE (a)-[:KNOWS {since: 2020, context: "Gallery restoration referrals"}]->(b);


// --- STEP 29: ADDITIONAL VISITED RELATIONSHIPS ------------------------------

// Jorge Molina visited the museum days before the theft (provided floor plan info)
MATCH (p:Person {name: "Jorge Molina"}),   (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-25", time: "14:30", purpose: "Personal visit - nostalgia"}]->(l);

// Iván Bosch visited the hardware store to buy the tools later found as evidence
MATCH (p:Person {name: "Iván Bosch"}),     (l:Location {name: "Ferretería Camino"})
MERGE (p)-[:VISITED {date: "2026-03-02", time: "11:15", purpose: "Tool purchase"}]->(l);

// Tomás Reig visited the storage unit to drop off the painting
MATCH (p:Person {name: "Tomás Reig"}),     (l:Location {name: "Trastero Climatizado Mar"})
MERGE (p)-[:VISITED {date: "2026-03-04", time: "02:30", purpose: "Unknown"}]->(l);

// Dimitri Sava picked up from the storage unit for onward shipping
MATCH (p:Person {name: "Dimitri Sava"}),   (l:Location {name: "Trastero Climatizado Mar"})
MERGE (p)-[:VISITED {date: "2026-03-06", time: "05:45", purpose: "Collection"}]->(l);

// Andres Fuentes and Félix Castillo both attended the private club the week before
MATCH (p:Person {name: "Andres Fuentes"}), (l:Location {name: "Club Privado Almudín"})
MERGE (p)-[:VISITED {date: "2026-02-26", time: "21:00", purpose: "Member dinner"}]->(l);

MATCH (p:Person {name: "Félix Castillo"}), (l:Location {name: "Club Privado Almudín"})
MERGE (p)-[:VISITED {date: "2026-02-26", time: "21:00", purpose: "Member dinner"}]->(l);

// Carmen Ibáñez visited the museum the next morning to assess the loss
MATCH (p:Person {name: "Carmen Ibáñez"}),  (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-04", time: "10:00", purpose: "Insurance assessment"}]->(l);


// --- STEP 30: ADDITIONAL VEHICLE RELATIONSHIPS ------------------------------

// Andres Fuentes rented the Volkswagen Passat on the night of the crime
MATCH (p:Person {name: "Andres Fuentes"}), (v:Vehicle {plate: "3310-RTV"})
MERGE (p)-[:RENTED {date: "2026-03-03", returned: "2026-03-04"}]->(v);

// The rental car was spotted at the hotel (matching the timing of Andres Fuentes's alibi)
MATCH (v:Vehicle {plate: "3310-RTV"}),     (l:Location {name: "Hotel Valentia"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-03", time: "22:50"}]->(l);

// The rental car key fob was also found there, confirming presence
MATCH (v:Vehicle {plate: "3310-RTV"}),     (l:Location {name: "Club Privado Almudín"})
MERGE (v)-[:SPOTTED_AT {date: "2026-03-03", time: "21:05"}]->(l);


// --- STEP 31: ADDITIONAL PHONE CALL RELATIONSHIPS ---------------------------

// CALL-009: Iván Bosch calls Jorge Molina (pre-crime: floor plan details)
MATCH (p:Person {name: "Iván Bosch"}),      (c:PhoneCall {id: "CALL-009"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-009"}),       (p:Person {name: "Jorge Molina"})   MERGE (c)-[:RECEIVED_BY]->(p);

// CALL-010: Iván Bosch calls Tomás Reig (pre-crime: operational briefing)
MATCH (p:Person {name: "Iván Bosch"}),      (c:PhoneCall {id: "CALL-010"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-010"}),       (p:Person {name: "Tomás Reig"})     MERGE (c)-[:RECEIVED_BY]->(p);

// CALL-011: Nadia Orlov calls Dimitri Sava (post-crime: arrange collection from storage)
MATCH (p:Person {name: "Nadia Orlov"}),     (c:PhoneCall {id: "CALL-011"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-011"}),       (p:Person {name: "Dimitri Sava"})   MERGE (c)-[:RECEIVED_BY]->(p);

// CALL-012: Andres Fuentes calls Félix Castillo (morning after: confirming the acquisition)
MATCH (p:Person {name: "Andres Fuentes"}),  (c:PhoneCall {id: "CALL-012"}) MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-012"}),       (p:Person {name: "Félix Castillo"}) MERGE (c)-[:RECEIVED_BY]->(p);


// --- STEP 32: ADDITIONAL FINANCIAL TRANSACTION RELATIONSHIPS ----------------

// TXN-008: Storage unit rental paid by Tomás Reig (cash, anonymous)
MATCH (p:Person {name: "Tomás Reig"}),      (t:FinancialTransaction {id: "TXN-008"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-008"}), (l:Location {name: "Trastero Climatizado Mar"}) MERGE (t)-[:PAID_FOR]->(l);

// TXN-009: Nadia Orlov pays Dimitri Sava for courier work
MATCH (p:Person {name: "Nadia Orlov"}),     (t:FinancialTransaction {id: "TXN-009"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-009"}), (p:Person {name: "Dimitri Sava"})    MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-010: Andres Fuentes rents the getaway-adjacent car
MATCH (p:Person {name: "Andres Fuentes"}),  (t:FinancialTransaction {id: "TXN-010"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-010"}), (v:Vehicle {plate: "3310-RTV"})      MERGE (t)-[:PAID_FOR]->(v);

// TXN-011: Dimitri Sava deposits cash after receiving payment (laundering trail)
MATCH (p:Person {name: "Dimitri Sava"}),    (t:FinancialTransaction {id: "TXN-011"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-011"}), (p:Person {name: "Dimitri Sava"})    MERGE (t)-[:RECEIVED_BY]->(p);


// --- STEP 33: ADDITIONAL EVIDENCE RELATIONSHIPS -----------------------------

// EVD-007 (SIM card) linked to Iván Bosch via tower ping matching his other calls
MATCH (e:Evidence {id: "EVD-007"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-007"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "medium", basis: "Last tower ping matches Bosch call pattern; same Patraix cell tower at 00:15"}]->(p);

// EVD-008 (glove) found near Gallery Room 3 - DNA pending
MATCH (e:Evidence {id: "EVD-008"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-008"}), (p:Person {name: "Iván Bosch"})
MERGE (e)-[:LINKED_TO {confidence: "low", basis: "DNA trace - lab results pending; glove size consistent with EVD-002 boot owner"}]->(p);

// EVD-009 (key fob) found at Hotel Valentia - links Andres Fuentes to the rental car
MATCH (e:Evidence {id: "EVD-009"}), (l:Location {name: "Hotel Valentia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-009"}), (p:Person {name: "Andres Fuentes"})
MERGE (e)-[:LINKED_TO {confidence: "high", basis: "Rental agreement for plate 3310-RTV is under Fuentes's corporate account"}]->(p);


// --- STEP 34: ADDITIONAL CRIMINAL RECORD RELATIONSHIP -----------------------

MATCH (p:Person {name: "Dimitri Sava"}), (r:CriminalRecord {id: "REC-005"})
MERGE (p)-[:HAS_RECORD]->(r);


// --- STEP 35: VERIFY (UPDATED) ----------------------------------------------

MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;

// Expected (after extended data):
// Person                 17  (+3: Carmen Ibáñez, Dimitri Sava, Jorge Molina)
// Location               15  (+3: Trastero Climatizado Mar, Club Privado Almudín, Ferretería Camino)
// PhoneCall              12  (+4: CALL-009 to CALL-012)
// FinancialTransaction   11  (+4: TXN-008 to TXN-011)
// Evidence                9  (+3: EVD-007, EVD-008, EVD-009)
// Vehicle                 6  (+1: 3310-RTV)
// CriminalRecord          5  (+1: REC-005)
// Painting                1  (+1: PAINT-001)
// Total nodes: 76
