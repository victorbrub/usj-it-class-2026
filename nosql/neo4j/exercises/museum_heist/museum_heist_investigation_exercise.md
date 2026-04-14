# Author: Víctor Barceló
# The Valencia Museum Heist - A Graph Database Crime Investigation

**Duration**: 90 minutes  
**Tool**: Neo4j Desktop  
**Difficulty**: Introductory - Intermediate  

---

## The Story

On the night of **March 3rd, 2026**, a priceless painting - "La Sombra del Rio" by fictional painter Elías Mora - was stolen from the **Museo de Arte Moderno de Valencia**. The painting was valued at 2.4 million euros.

Security cameras were tampered with. The alarm was disabled from the inside. The police have identified **10 suspects** based on museum access logs, phone records, and witness statements.

**Your mission**: Use graph database queries to uncover the connections between suspects, locations, phone calls, financial transactions, and evidence - and identify the thief.

---

## Graph Model

### Node Labels

| Label | Represents |
|---|---|
| `Person` | People involved: suspects, witnesses, police officers, museum staff |
| `Location` | Places relevant to the investigation |
| `Vehicle` | Cars and motorbikes linked to suspects |
| `PhoneCall` | Recorded phone calls made near the museum that night |
| `FinancialTransaction` | Bank transfers made in the days around the crime |
| `Evidence` | Physical evidence found at the crime scene |
| `CriminalRecord` | Prior offenses linked to a person |
| `Painting` | The stolen artwork and its metadata |

### Relationship Types

| Relationship | Meaning |
|---|---|
| `(:Person)-[:KNOWS]->(:Person)` | Two people know each other |
| `(:Person)-[:WORKS_AT]->(:Location)` | Person is employed at a location |
| `(:Person)-[:VISITED {date, time}]->(:Location)` | Person visited a location on a date |
| `(:Person)-[:OWNS]->(:Vehicle)` | Person owns a vehicle |
| `(:Vehicle)-[:SPOTTED_AT {date, time}]->(:Location)` | Vehicle was seen at a location |
| `(:Person)-[:MADE_CALL]->(:PhoneCall)` | Person made a phone call |
| `(:PhoneCall)-[:RECEIVED_BY]->(:Person)` | A phone call was received by a person |
| `(:Person)-[:SENT_TRANSACTION]->(:FinancialTransaction)` | Person sent money |
| `(:FinancialTransaction)-[:RECEIVED_BY]->(:Person)` | Person received money |
| `(:Evidence)-[:FOUND_AT]->(:Location)` | Evidence was found at a location |
| `(:Evidence)-[:LINKED_TO]->(:Person)` | Evidence is linked to a person |
| `(:Person)-[:HAS_RECORD]->(:CriminalRecord)` | Person has a prior criminal record |
| `(:Location)-[:OWNS_ARTWORK]->(:Painting)` | A location holds a painting |
| `(:Painting)-[:STORED_AT]->(:Location)` | Painting is stored at a location (post-theft) |
| `(:Person)-[:INVESTIGATES]->(:Painting)` | Insurance investigator is assigned to a stolen painting |
| `(:Person)-[:SOUGHT_TO_ACQUIRE]->(:Painting)` | Person tried to obtain the painting through back channels |
| `(:Person)-[:RENTED]->(:Vehicle)` | Person rented a vehicle |
| `(:FinancialTransaction)-[:PAID_FOR]->(:Location\|Vehicle)` | A payment was made for a specific asset or service |

---

## Part 0 - Setup (10 minutes)

### Step 0.1 - Open Neo4j Desktop

1. Open Neo4j Desktop.
2. Start your local database instance from the Projects panel.
3. Click **Open** to open the built-in query editor.

### Step 0.2 - Clear Any Existing Data

```cypher
MATCH (n)
DETACH DELETE n;
```

Confirm the database is empty:

```cypher
MATCH (n)
RETURN count(n) AS total_nodes;
```

Expected result: `0`

### Step 0.3 - Create Constraints

```cypher
CREATE CONSTRAINT person_name IF NOT EXISTS
FOR (p:Person) REQUIRE p.name IS UNIQUE;

CREATE CONSTRAINT location_name IF NOT EXISTS
FOR (l:Location) REQUIRE l.name IS UNIQUE;

CREATE CONSTRAINT vehicle_plate IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.plate IS UNIQUE;
```

---

## Part 1 - Loading the Investigation Data (15 minutes)

Run the following blocks **one block at a time** in Neo4j Desktop. Each block is independent.

### Block 1: Create Persons

```cypher
// Museum staff
MERGE (:Person {name: "Martina Soler", role: "Museum Director", age: 52, phone: "600-111-001"});
MERGE (:Person {name: "Carlos Vidal", role: "Night Security Guard", age: 34, phone: "600-111-002"});
MERGE (:Person {name: "Rosa Ferrer", role: "Cleaning Staff", age: 41, phone: "600-111-003"});

// Suspects with known criminal connections
MERGE (:Person {name: "Andres Fuentes", role: "Art Dealer", age: 47, phone: "600-222-001"});
MERGE (:Person {name: "Elena Marchetti", role: "Freelance Restorer", age: 38, phone: "600-222-002"});
MERGE (:Person {name: "Tomás Reig", role: "Unemployed", age: 29, phone: "600-222-003"});
MERGE (:Person {name: "Lucía Peñas", role: "Private Driver", age: 44, phone: "600-222-004"});
MERGE (:Person {name: "Iván Bosch", role: "Electrician", age: 36, phone: "600-222-005"});
MERGE (:Person {name: "Nadia Orlov", role: "Antique Shop Owner", age: 51, phone: "600-222-006"});
MERGE (:Person {name: "Félix Castillo", role: "Art Collector", age: 63, phone: "600-222-007"});

// Witnesses
MERGE (:Person {name: "Pablo Ruiz", role: "Taxi Driver", age: 33, phone: "600-333-001"});
MERGE (:Person {name: "Sara Montoya", role: "Bar Owner", age: 45, phone: "600-333-002"});

// Police
MERGE (:Person {name: "Inspector Dávila", role: "Lead Investigator", age: 49, phone: "600-444-001"});
MERGE (:Person {name: "Officer Sanz", role: "Crime Scene Officer", age: 31, phone: "600-444-002"});
```

### Block 2: Create Locations

```cypher
MERGE (:Location {name: "Museo de Arte Moderno de Valencia", type: "Museum", district: "Ciutat Vella"});
MERGE (:Location {name: "Bar El Rincón", type: "Bar", district: "Ruzafa"});
MERGE (:Location {name: "Galería Marchetti", type: "Art Gallery", district: "El Carmen"});
MERGE (:Location {name: "Almacén Industrial Rioja", type: "Warehouse", district: "Patraix"});
MERGE (:Location {name: "Piso Andres Fuentes", type: "Residence", district: "Eixample"});
MERGE (:Location {name: "Taller Iván Bosch", type: "Workshop", district: "Benimaclet"});
MERGE (:Location {name: "Tienda Nadia Orlov", type: "Antique Shop", district: "El Carmen"});
MERGE (:Location {name: "Puerto de Valencia", type: "Port", district: "Poblats Marítims"});
MERGE (:Location {name: "Parking Mestalla", type: "Parking", district: "Algirós"});
MERGE (:Location {name: "Hotel Valentia", type: "Hotel", district: "Extramurs"});
MERGE (:Location {name: "Aeropuerto de Valencia", type: "Airport", district: "Alboraia"});
MERGE (:Location {name: "Comisaría Central", type: "Police Station", district: "Extramurs"});
```

### Block 3: Create Vehicles

```cypher
MERGE (:Vehicle {plate: "4782-KLM", type: "Van", color: "White", model: "Ford Transit"});
MERGE (:Vehicle {plate: "9901-ABX", type: "Car", color: "Black", model: "BMW 320"});
MERGE (:Vehicle {plate: "1144-ZZP", type: "Motorbike", color: "Red", model: "Honda CB500"});
MERGE (:Vehicle {plate: "5530-GHT", type: "Car", color: "Silver", model: "Seat León"});
MERGE (:Vehicle {plate: "7723-NNQ", type: "Van", color: "Grey", model: "Mercedes Sprinter"});
```

### Block 4: Create Phone Calls (night of March 3rd)

```cypher
MERGE (:PhoneCall {id: "CALL-001", date: "2026-03-03", time: "22:15", duration_seconds: 187, tower: "Ciutat Vella"});
MERGE (:PhoneCall {id: "CALL-002", date: "2026-03-03", time: "22:31", duration_seconds: 43, tower: "Ciutat Vella"});
MERGE (:PhoneCall {id: "CALL-003", date: "2026-03-03", time: "22:48", duration_seconds: 312, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-004", date: "2026-03-03", time: "23:02", duration_seconds: 95, tower: "Ruzafa"});
MERGE (:PhoneCall {id: "CALL-005", date: "2026-03-03", time: "23:19", duration_seconds: 228, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-006", date: "2026-03-03", time: "23:45", duration_seconds: 61, tower: "Poblats Marítims"});
MERGE (:PhoneCall {id: "CALL-007", date: "2026-03-04", time: "00:03", duration_seconds: 144, tower: "Patraix"});
MERGE (:PhoneCall {id: "CALL-008", date: "2026-03-04", time: "00:22", duration_seconds: 76, tower: "Cidade Vella"});
```

### Block 5: Create Financial Transactions (March 1-5)

```cypher
MERGE (:FinancialTransaction {id: "TXN-001", date: "2026-03-01", amount: 15000, currency: "EUR", type: "Wire Transfer", concept: "Art consultation fee"});
MERGE (:FinancialTransaction {id: "TXN-002", date: "2026-03-02", amount: 3200,  currency: "EUR", type: "Cash Deposit",   concept: "Unknown"});
MERGE (:FinancialTransaction {id: "TXN-003", date: "2026-03-03", amount: 800,   currency: "EUR", type: "Wire Transfer", concept: "Electrical services"});
MERGE (:FinancialTransaction {id: "TXN-004", date: "2026-03-04", amount: 50000, currency: "EUR", type: "Wire Transfer", concept: "Painting acquisition"});
MERGE (:FinancialTransaction {id: "TXN-005", date: "2026-03-04", amount: 50000, currency: "EUR", type: "Wire Transfer", concept: "Art investment"});
MERGE (:FinancialTransaction {id: "TXN-006", date: "2026-03-05", amount: 9500,  currency: "EUR", type: "Cash Withdrawal", concept: "Unknown"});
MERGE (:FinancialTransaction {id: "TXN-007", date: "2026-03-05", amount: 1200,  currency: "EUR", type: "Wire Transfer", concept: "Transport services"});
```

### Block 6: Create Evidence

```cypher
MERGE (:Evidence {id: "EVD-001", type: "Fingerprint", description: "Partial fingerprint on alarm panel", location_found: "Security Room"});
MERGE (:Evidence {id: "EVD-002", type: "Footprint", description: "Size 42 boot print in dust near loading bay", location_found: "Loading Bay"});
MERGE (:Evidence {id: "EVD-003", type: "Tool", description: "Wire cutters with epoxy residue", location_found: "Loading Bay"});
MERGE (:Evidence {id: "EVD-004", type: "Fibre", description: "Blue polyester fibres on broken display case", location_found: "Gallery Room 3"});
MERGE (:Evidence {id: "EVD-005", type: "Receipt", description: "Crumpled receipt from hardware store dated 2026-03-02", location_found: "Service Corridor"});
MERGE (:Evidence {id: "EVD-006", type: "CCTV_Frame", description: "Partial image of white van near museum at 23:05", location_found: "Street Camera"});
```

### Block 7: Create Criminal Records

```cypher
MERGE (:CriminalRecord {id: "REC-001", offense: "Receiving stolen goods", year: 2019, sentenced: false});
MERGE (:CriminalRecord {id: "REC-002", offense: "Art fraud", year: 2017, sentenced: true});
MERGE (:CriminalRecord {id: "REC-003", offense: "Breaking and entering", year: 2021, sentenced: true});
MERGE (:CriminalRecord {id: "REC-004", offense: "Money laundering", year: 2020, sentenced: false});
MERGE (:CriminalRecord {id: "REC-005", offense: "Handling stolen property (international)", year: 2023, sentenced: false});
```

### Block 7b: Create the Stolen Painting

```cypher
MERGE (:Painting {
  id:        "PAINT-001",
  title:     "La Sombra del Rio",
  artist:    "Elías Mora",
  year:      1987,
  value_eur: 2400000,
  status:    "Stolen",
  insured:   true,
  insurer:   "Seguros Arte Levante S.A."
});
```

### Block 7c: Create Additional Persons

```cypher
// Insurance investigator assigned to the museum policy
MERGE (:Person {name: "Carmen Ibáñez",  role: "Insurance Investigator",    age: 43, phone: "600-555-001"});

// Courier used to move stolen goods
MERGE (:Person {name: "Dimitri Sava",   role: "Courier",                    age: 31, phone: "600-555-002"});

// Former museum technician who knew the layout
MERGE (:Person {name: "Jorge Molina",   role: "Former Museum Technician",   age: 40, phone: "600-555-003"});
```

### Block 7d: Create Additional Locations

```cypher
MERGE (:Location {name: "Trastero Climatizado Mar",  type: "Storage Unit",   district: "Poblats Marítims"});
MERGE (:Location {name: "Club Privado Almudín",       type: "Private Club",   district: "Ciutat Vella"});
MERGE (:Location {name: "Ferretería Camino",           type: "Hardware Store", district: "Benimaclet"});
```

### Block 7e: Create Additional Vehicle and Phone Calls

```cypher
// Rental car used by Andres Fuentes
MERGE (:Vehicle {plate: "3310-RTV", type: "Car", color: "Dark Blue", model: "Volkswagen Passat"});

// Pre-crime planning calls
MERGE (:PhoneCall {id: "CALL-009", date: "2026-02-28", time: "20:05", duration_seconds: 421, tower: "Benimaclet"});
MERGE (:PhoneCall {id: "CALL-010", date: "2026-03-02", time: "18:33", duration_seconds: 298, tower: "Benimaclet"});

// Post-crime coordination from the port
MERGE (:PhoneCall {id: "CALL-011", date: "2026-03-05", time: "06:40", duration_seconds: 183, tower: "Poblats Marítims"});

// Morning-after call between Fuentes and Castillo
MERGE (:PhoneCall {id: "CALL-012", date: "2026-03-04", time: "09:15", duration_seconds: 512, tower: "Eixample"});
```

### Block 7f: Create Additional Financial Transactions

```cypher
MERGE (:FinancialTransaction {id: "TXN-008", date: "2026-03-01", amount:   600, currency: "EUR", type: "Cash Payment",  concept: "Storage unit rental - 3 months"});
MERGE (:FinancialTransaction {id: "TXN-009", date: "2026-03-06", amount:  2500, currency: "EUR", type: "Wire Transfer", concept: "Courier and logistics"});
MERGE (:FinancialTransaction {id: "TXN-010", date: "2026-03-03", amount:   185, currency: "EUR", type: "Card Payment",  concept: "Vehicle rental - 1 day"});
MERGE (:FinancialTransaction {id: "TXN-011", date: "2026-03-07", amount:  2000, currency: "EUR", type: "Cash Deposit",  concept: "Unknown"});
```

### Block 7g: Create Additional Evidence

```cypher
MERGE (:Evidence {id: "EVD-007", type: "SIM Card", description: "Prepaid SIM registered to a false name, last tower ping Patraix 00:15", location_found: "Almacén Industrial Rioja exterior"});
MERGE (:Evidence {id: "EVD-008", type: "Glove",    description: "Right-hand latex glove with partial DNA trace, cupboard near Gallery Room 3", location_found: "Gallery Room 3 Corridor"});
MERGE (:Evidence {id: "EVD-009", type: "Key Fob",  description: "Rental car fob matching plate 3310-RTV, found in Hotel Valentia parking area", location_found: "Hotel Valentia"});
```

### Block 8: Create Person-to-Location Relationships (WORKS_AT / VISITED)

```cypher
// Works at
MATCH (p:Person {name: "Martina Soler"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Carlos Vidal"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Rosa Ferrer"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Elena Marchetti"}), (l:Location {name: "Galería Marchetti"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Iván Bosch"}), (l:Location {name: "Taller Iván Bosch"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Nadia Orlov"}), (l:Location {name: "Tienda Nadia Orlov"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Sara Montoya"}), (l:Location {name: "Bar El Rincón"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Inspector Dávila"}), (l:Location {name: "Comisaría Central"})
MERGE (p)-[:WORKS_AT]->(l);

MATCH (p:Person {name: "Officer Sanz"}), (l:Location {name: "Comisaría Central"})
MERGE (p)-[:WORKS_AT]->(l);

// Visited the museum (legitimate prior visits)
MATCH (p:Person {name: "Andres Fuentes"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-20", time: "11:00", purpose: "Private viewing"}]->(l);

MATCH (p:Person {name: "Elena Marchetti"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-02-28", time: "09:30", purpose: "Restoration assessment"}]->(l);

MATCH (p:Person {name: "Félix Castillo"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-01", time: "16:00", purpose: "Gala attendance"}]->(l);

MATCH (p:Person {name: "Iván Bosch"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-02", time: "08:45", purpose: "Electrical maintenance contract"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "14:00", purpose: "Tourist visit"}]->(l);

// Visited the warehouse (key location)
MATCH (p:Person {name: "Iván Bosch"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "21:00", purpose: "Unknown"}]->(l);

MATCH (p:Person {name: "Lucía Peñas"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "21:30", purpose: "Unknown"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}), (l:Location {name: "Almacén Industrial Rioja"})
MERGE (p)-[:VISITED {date: "2026-03-04", time: "01:00", purpose: "Unknown"}]->(l);

// Visited other locations (alibis and connections)
MATCH (p:Person {name: "Andres Fuentes"}), (l:Location {name: "Hotel Valentia"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "20:00", purpose: "Business dinner"}]->(l);

MATCH (p:Person {name: "Tomás Reig"}), (l:Location {name: "Bar El Rincón"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "19:00", purpose: "Drinks"}]->(l);

MATCH (p:Person {name: "Pablo Ruiz"}), (l:Location {name: "Parking Mestalla"})
MERGE (p)-[:VISITED {date: "2026-03-03", time: "22:00", purpose: "Fare pickup"}]->(l);

MATCH (p:Person {name: "Nadia Orlov"}), (l:Location {name: "Puerto de Valencia"})
MERGE (p)-[:VISITED {date: "2026-03-05", time: "07:00", purpose: "Shipment collection"}]->(l);
```

### Block 9: Create Vehicle Ownership and Sightings

```cypher
// Ownership
MATCH (p:Person {name: "Iván Bosch"}), (v:Vehicle {plate: "4782-KLM"})
MERGE (p)-[:OWNS]->(v);

MATCH (p:Person {name: "Andres Fuentes"}), (v:Vehicle {plate: "9901-ABX"})
MERGE (p)-[:OWNS]->(v);

MATCH (p:Person {name: "Lucía Peñas"}), (v:Vehicle {plate: "1144-ZZP"})
MERGE (p)-[:OWNS]->(v);

MATCH (p:Person {name: "Nadia Orlov"}), (v:Vehicle {plate: "5530-GHT"})
MERGE (p)-[:OWNS]->(v);

MATCH (p:Person {name: "Tomás Reig"}), (v:Vehicle {plate: "7723-NNQ"})
MERGE (p)-[:OWNS]->(v);

// Vehicle sightings
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
```

### Block 10: Create Phone Call Relationships

```cypher
// Calls made on the night of the crime
MATCH (p:Person {name: "Iván Bosch"}), (c:PhoneCall {id: "CALL-001"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-001"}), (p:Person {name: "Lucía Peñas"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Lucía Peñas"}), (c:PhoneCall {id: "CALL-002"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-002"}), (p:Person {name: "Iván Bosch"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Tomás Reig"}), (c:PhoneCall {id: "CALL-003"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-003"}), (p:Person {name: "Nadia Orlov"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Carlos Vidal"}), (c:PhoneCall {id: "CALL-004"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-004"}), (p:Person {name: "Martina Soler"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Iván Bosch"}), (c:PhoneCall {id: "CALL-005"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-005"}), (p:Person {name: "Tomás Reig"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Nadia Orlov"}), (c:PhoneCall {id: "CALL-006"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-006"}), (p:Person {name: "Félix Castillo"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Iván Bosch"}), (c:PhoneCall {id: "CALL-007"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-007"}), (p:Person {name: "Lucía Peñas"})
MERGE (c)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Carlos Vidal"}), (c:PhoneCall {id: "CALL-008"})
MERGE (p)-[:MADE_CALL]->(c);
MATCH (c:PhoneCall {id: "CALL-008"}), (p:Person {name: "Rosa Ferrer"})
MERGE (c)-[:RECEIVED_BY]->(p);
```

### Block 11: Create Financial Transaction Relationships

```cypher
// TXN-001: Félix Castillo pays Andres Fuentes (art consultation)
MATCH (p:Person {name: "Félix Castillo"}), (t:FinancialTransaction {id: "TXN-001"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-001"}), (p:Person {name: "Andres Fuentes"})
MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-002: Cash deposit from Tomás Reig (unknown origin)
MATCH (p:Person {name: "Tomás Reig"}), (t:FinancialTransaction {id: "TXN-002"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-002"}), (p:Person {name: "Tomás Reig"})
MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-003: Museum pays Iván Bosch for electrical work
MATCH (p:Person {name: "Martina Soler"}), (t:FinancialTransaction {id: "TXN-003"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-003"}), (p:Person {name: "Iván Bosch"})
MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-004 and TXN-005: Large transfers to Nadia Orlov after theft
MATCH (p:Person {name: "Félix Castillo"}), (t:FinancialTransaction {id: "TXN-004"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-004"}), (p:Person {name: "Nadia Orlov"})
MERGE (t)-[:RECEIVED_BY]->(p);

MATCH (p:Person {name: "Andres Fuentes"}), (t:FinancialTransaction {id: "TXN-005"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-005"}), (p:Person {name: "Nadia Orlov"})
MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-006: Cash withdrawal by Iván Bosch after theft
MATCH (p:Person {name: "Iván Bosch"}), (t:FinancialTransaction {id: "TXN-006"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-006"}), (p:Person {name: "Iván Bosch"})
MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-007: Lucía Peñas receives transport payment from Iván Bosch
MATCH (p:Person {name: "Iván Bosch"}), (t:FinancialTransaction {id: "TXN-007"})
MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-007"}), (p:Person {name: "Lucía Peñas"})
MERGE (t)-[:RECEIVED_BY]->(p);
```

### Block 12: Create KNOWS Relationships

```cypher
MATCH (a:Person {name: "Iván Bosch"}), (b:Person {name: "Tomás Reig"})
MERGE (a)-[:KNOWS {since: 2018, context: "Neighborhood"}]->(b);

MATCH (a:Person {name: "Iván Bosch"}), (b:Person {name: "Lucía Peñas"})
MERGE (a)-[:KNOWS {since: 2022, context: "Work contact"}]->(b);

MATCH (a:Person {name: "Tomás Reig"}), (b:Person {name: "Nadia Orlov"})
MERGE (a)-[:KNOWS {since: 2020, context: "Antique market"}]->(b);

MATCH (a:Person {name: "Nadia Orlov"}), (b:Person {name: "Félix Castillo"})
MERGE (a)-[:KNOWS {since: 2015, context: "Art world"}]->(b);

MATCH (a:Person {name: "Andres Fuentes"}), (b:Person {name: "Félix Castillo"})
MERGE (a)-[:KNOWS {since: 2010, context: "Art Collector network"}]->(b);

MATCH (a:Person {name: "Andres Fuentes"}), (b:Person {name: "Elena Marchetti"})
MERGE (a)-[:KNOWS {since: 2019, context: "Art gallery circuit"}]->(b);

MATCH (a:Person {name: "Elena Marchetti"}), (b:Person {name: "Martina Soler"})
MERGE (a)-[:KNOWS {since: 2021, context: "Museum restoration contract"}]->(b);

MATCH (a:Person {name: "Carlos Vidal"}), (b:Person {name: "Rosa Ferrer"})
MERGE (a)-[:KNOWS {since: 2023, context: "Colleagues"}]->(b);

MATCH (a:Person {name: "Iván Bosch"}), (b:Person {name: "Carlos Vidal"})
MERGE (a)-[:KNOWS {since: 2026, context: "Electrical work at museum"}]->(b);

MATCH (a:Person {name: "Pablo Ruiz"}), (b:Person {name: "Tomás Reig"})
MERGE (a)-[:KNOWS {since: 2024, context: "Taxi fare - regular customer"}]->(b);
```

### Block 13: Create Evidence Relationships

```cypher
// Evidence found at locations
MATCH (e:Evidence {id: "EVD-001"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-002"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-003"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-004"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-005"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-006"}), (l:Location {name: "Museo de Arte Moderno de Valencia"})
MERGE (e)-[:FOUND_AT]->(l);

// Evidence linked to persons
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
```

### Block 14: Link Criminal Records

```cypher
MATCH (p:Person {name: "Nadia Orlov"}), (r:CriminalRecord {id: "REC-001"})
MERGE (p)-[:HAS_RECORD]->(r);

MATCH (p:Person {name: "Andres Fuentes"}), (r:CriminalRecord {id: "REC-002"})
MERGE (p)-[:HAS_RECORD]->(r);

MATCH (p:Person {name: "Tomás Reig"}), (r:CriminalRecord {id: "REC-003"})
MERGE (p)-[:HAS_RECORD]->(r);

MATCH (p:Person {name: "Félix Castillo"}), (r:CriminalRecord {id: "REC-004"})
MERGE (p)-[:HAS_RECORD]->(r);
```

### Step 1.1 - Verify the Data Loaded Correctly

Run this before proceeding to the investigation:

```cypher
MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;
```

Expected output:

| label | count |
|---|---|
| Person | 17 |
| Location | 15 |
| PhoneCall | 12 |
| FinancialTransaction | 11 |
| Evidence | 9 |
| Vehicle | 6 |
| CriminalRecord | 5 |
| Painting | 1 |

**Total nodes: 76**

```cypher
MATCH ()-[r]->()
RETURN type(r) AS relationship_type, count(r) AS count
ORDER BY count DESC;
```

> **Checkpoint**: Confirm you have 56 nodes and a full set of relationships before continuing.

---

## Part 2 - Getting Acquainted with the Data (15 minutes)

Before investigating, explore the database structure. These queries help you understand what you are working with.

### Exercise 2.1 - View the Full Graph

```cypher
MATCH (n)
RETURN n
LIMIT 80;
```

Click on nodes in the Neo4j Desktop visualization to see their properties.

### Exercise 2.2 - Count People by Role

Write a query to count how many persons exist for each role.

```cypher
// Hint: use MATCH, RETURN, and count()
```

Expected result: you should see roles such as Suspect, Museum staff, Police, Witness.

### Exercise 2.3 - List All Locations

Find all locations and return their name, type, and district, ordered by district.

```cypher
// Your query here
```

### Exercise 2.4 - Explore Suspects

Find all persons who are NOT police officers and NOT museum staff — these are the potential suspects.

```cypher
// Hint: use WHERE NOT p.role IN [...]
```

### Exercise 2.5 - View Evidence Summary

Return a list of all evidence items: their id, type, description, and confidence of person linkage.

```cypher
MATCH (e:Evidence)-[l:LINKED_TO]->(p:Person)
RETURN e.id, e.type, e.description, l.confidence AS confidence, p.name AS linked_person;
```

> **Discussion**: What do you notice about which person appears most in the evidence linkage?

---

## Part 3 - First Lines of Investigation (20 minutes)

### Exercise 3.1 - Who Was at the Museum?

Find all persons who visited the museum, including the date and purpose of their visit.

```cypher
// Your query here - use MATCH with VISITED relationship and Museum location
```

### Exercise 3.2 - Alibi Check: Who Was Somewhere Else That Night?

Find persons who visited a location other than the museum on the night of March 3rd (2026-03-03).

```cypher
// Hint: filter by a relationship property date AND exclude a specific location using <>
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType)
WHERE r.date = "YYYY-MM-DD"
  AND b.name <> "Excluded Location"
RETURN a.name, b.name, r.time;
```

> **Investigation note**: An alibi at a different location at the same time as the theft does not necessarily clear a suspect.

### Exercise 3.3 - Phone Activity Near the Museum

The theft happened between 22:00 and 00:30. Find all phone calls made from towers in the Ciutat Vella district during that window.

```cypher
// Hint: chain sender → PhoneCall → receiver and filter by a property on the middle node
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE b.property = "value"
RETURN a.name, b.time, b.duration_seconds, c.name
ORDER BY b.time;
```

Which suspects were making calls in the Ciutat Vella district - the same district as the museum - that night?

### Exercise 3.4 - The Warehouse Connection

The warehouse "Almacén Industrial Rioja" is critical. Find everyone who visited it, and whether any vehicle was spotted there.

```cypher
// Part A: match a Person to a specific Location by name and return relationship properties
MATCH (a:NodeType)-[r:RELATIONSHIP]->(b:NodeType {name: "Specific Location"})
RETURN a.name, r.date, r.time, r.purpose;
```

```cypher
// Part B: chain two MATCH clauses — Vehicle → Location, then Person → Vehicle
MATCH (a:NodeType)-[r:RELATIONSHIP1]->(b:NodeType {name: "Specific Location"})
MATCH (c:NodeType)-[:RELATIONSHIP2]->(a)
RETURN c.name, a.plate, a.color, a.model, r.date, r.time;
```

> **Discussion**: Is there overlap between the people and the vehicle owners?

### Exercise 3.5 - Suspects with Criminal Records

Find all persons who have prior criminal records, and show the offense and year.

```cypher
// Your query here
```

---

## Part 4 - Following the Money (15 minutes)

### Exercise 4.1 - Large Transactions After the Theft

The theft occurred on March 3rd. Find all financial transactions dated March 4th or later, ordered by amount descending.

```cypher
// Hint: chain sender → transaction → receiver and filter by a date property on the middle node
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE b.date >= "YYYY-MM-DD"
RETURN a.name, c.name, b.amount, b.date, b.concept
ORDER BY b.amount DESC;
```

> **Question**: Who received the largest sums after the theft? What does the concept say?

### Exercise 4.2 - Follow the Money Chain

Using the `KNOWS` network, find if the people who received money after the theft are connected to each other.

```cypher
// Hint: use a variable-length relationship [*1..3] to find paths up to 3 hops long
// Anchor both ends by name using WHERE
MATCH path = (a:NodeType)-[:RELATIONSHIP*1..3]-(b:NodeType)
WHERE a.name = "Person A" AND b.name = "Person B"
RETURN path;
```

How many steps separate Iván Bosch from Félix Castillo through social connections?

### Exercise 4.3 - Who Paid for Services Before the Theft?

Find transactions made before March 3rd and identify who they connect.

```cypher
// Hint: use < on a date string to filter for events before a given date
MATCH (a:NodeType)-[:RELATIONSHIP1]->(b:NodeType)-[:RELATIONSHIP2]->(c:NodeType)
WHERE b.date < "YYYY-MM-DD"
RETURN a.name, c.name, b.amount, b.date, b.concept;
```

> **Investigation note**: Notice who received a payment for "Electrical services" — and cross-reference with who had access to the museum's electrical system.

### Exercise 4.4 - Transportation Payment

Find the transaction labeled "Transport services" and identify who sent and received it, and when.

```cypher
// Your query here - filter FinancialTransaction by concept
```

---

## Part 5 - Connecting the Dots (15 minutes)

### Exercise 5.1 - Suspect Network Map

Visualize the social connections among all persons who are NOT police officers.

```cypher
// Hint: assign the pattern to a path variable to return a graph visualization
// Exclude multiple role values with <> and AND
MATCH path = (a:NodeType)-[:RELATIONSHIP]-(b:NodeType)
WHERE a.property <> "value1" AND a.property <> "value2"
  AND b.property <> "value1" AND b.property <> "value2"
RETURN path;
```

Look at the graph visualization. Who is the most connected node in this social web?

### Exercise 5.2 - The White Van

Evidence EVD-006 shows a white van near the museum at 23:05. Trace it:

```cypher
// Hint: chain three MATCH clauses — evidence → suspect, suspect → vehicle, vehicle → locations
// A list comprehension [(a)-[r]->(b) | r.property][0] retrieves a relationship property inline
MATCH (a:NodeType {id: "value"})-[:RELATIONSHIP1]->(b:NodeType)
MATCH (b)-[:RELATIONSHIP2]->(c:NodeType)
MATCH (c)-[:RELATIONSHIP3]->(d:NodeType)
RETURN b.name, c.plate, d.name,
       [(c)-[r:RELATIONSHIP3]->(d) | r.time][0] AS time
ORDER BY time;
```

Trace the route of the white van that night - where was it spotted and in what order?

### Exercise 5.3 - Full Evidence Fingerprint

Count how many pieces of evidence are linked to each person, ordered by evidence count descending.

```cypher
// Hint: use count() to aggregate per person and collect() to list all values in a group
MATCH (a:NodeType)-[:RELATIONSHIP]->(b:NodeType)
RETURN b.name, count(a) AS total, collect(a.property) AS list
ORDER BY total DESC;
```

> **Discussion**: Which person has the most pieces of evidence pointing to them?

### Exercise 5.4 - Complete Path from Evidence to Money

Try to construct a full path connecting the physical crime scene evidence to a financial beneficiary.

```cypher
// Hint: chain many nodes in one MATCH to build a multi-hop path
// Each arrow is a different relationship type connecting a different node type
MATCH path = (a:Type1)-[:REL1]->(b:Type2)-[:REL2]->(c:Type3)
             -[:REL3]->(d:Type4)-[:REL4]->(e:Type5)
             -[:REL5]->(f:Type6)
RETURN b.name, d.name, f.name, e.amount, e.concept, e.date
ORDER BY e.amount DESC
LIMIT 5;
```

> **Discussion**: Can you name the three roles in this chain? Who executed the theft, who organized transport, and who received the stolen goods?

---

## Part 6 - The Verdict (5 minutes)

You have followed the evidence. Now write your conclusion.

### Exercise 6.1 - Build the Case

Write a single Cypher query that returns the most incriminating profile: the person with the most evidence linked, who visited the museum before the crime, owned the vehicle spotted at the museum, made phone calls in the Ciutat Vella tower that night, and received a financial payment from the museum before the incident.

```cypher
// Hint: use multiple OPTIONAL MATCH clauses, one per signal
// Use WITH to compute counts with count(DISTINCT x) before filtering
// Arithmetic in RETURN creates a combined score column
MATCH (a:NodeType)
OPTIONAL MATCH (b:NodeType)-[:REL1]->(a)
OPTIONAL MATCH (a)-[r1:REL2]->(c:NodeType {name: "value"})
OPTIONAL MATCH (a)-[:REL3]->(d:NodeType)-[:REL4]->(c)
OPTIONAL MATCH (a)-[:REL5]->(e:NodeType)
  WHERE e.property = "value" AND e.date = "YYYY-MM-DD"
OPTIONAL MATCH (f:NodeType)-[:REL6]->(a)
  WHERE f.date <= "YYYY-MM-DD"
WITH a,
     count(DISTINCT b) AS signal1,
     count(DISTINCT r1) AS signal2,
     count(DISTINCT d) AS signal3,
     count(DISTINCT e) AS signal4,
     count(DISTINCT f) AS signal5
WHERE signal1 > 0
RETURN a.name, signal1, signal2, signal3, signal4, signal5,
       (signal1 + signal2 + signal3 + signal4 + signal5) AS total_score
ORDER BY total_score DESC
LIMIT 5;
```

### The Criminal

> **SPOILER - Only read after completing all exercises**

<details>
<summary>Click to reveal the answer</summary>

The thief is **Iván Bosch**.

Evidence:
- He had legitimate access to the museum via an electrical maintenance contract (visited March 2nd).
- His white Ford Transit (plate 4782-KLM) was spotted near the museum at 23:05, then at the warehouse at 23:50.
- His boot size and boot model match footprint EVD-002.
- His workshop supplies match the epoxy residue on the wire cutters (EVD-003).
- A hardware store receipt from March 2nd links to him (EVD-005).
- He made 3 phone calls that night from towers in Ciutat Vella and Patraix - both near the museum and the warehouse.
- He called Lucía Peñas (his driver) twice that night and Tomás Reig once.
- He received a payment of 800 EUR for "Electrical services" from the museum three days before the theft - explaining how he learned the alarm layout.
- He paid Lucía Peñas 1200 EUR on March 5th for "Transport services" - paying his accomplice.
- He withdrew 9500 EUR in cash on March 5th.

**The network**: Iván Bosch planned and executed the theft. Lucía Peñas drove the van. Tomás Reig received the painting at the warehouse. Nadia Orlov was the fence, coordinating the sale to Félix Castillo, who bankrolled the operation through Andres Fuentes.

</details>

---

## Reflection Questions

Answer these individually after completing the lab:

1. How did the graph model help you trace connections that would have been difficult in a relational database with JOIN queries?

2. What is the difference between a `MATCH` path and a raw `WHERE` filter when investigating linked data?

3. In Exercise 5.4 you traced a path across 4 node types. How many JOIN operations would that have required in SQL?

4. What properties on relationships (such as `date`, `time`, `confidence`) proved most useful during the investigation?

5. Which single Cypher query gave you the most useful investigative insight, and why?

---

## Bonus Challenges

These are optional for students who finish early.

### Bonus A - Shortest Path Between Suspects

Find the shortest path between Iván Bosch and Félix Castillo using any relationship type.

```cypher
// Hint: shortestPath() takes a variable-length [*] pattern between two anchored nodes
MATCH path = shortestPath(
  (a:NodeType {name: "..."})-[*]-(b:NodeType {name: "..."})
)
RETURN path;
```

### Bonus B - Degree Centrality

Calculate how many direct relationships each person has (degree centrality). This reveals the most "connected" actors in the criminal network.

```cypher
// Hint: use an anonymous node () and undirected relationship to count all neighbours
MATCH (a:NodeType)
OPTIONAL MATCH (a)-[r]-()
RETURN a.name, a.role, count(r) AS connections
ORDER BY connections DESC;
```

### Bonus C - Timeline Reconstruction

Reconstruct the full timeline of the night of March 3rd by combining vehicle sightings, phone calls, and location visits, sorted chronologically.

```cypher
// Hint: UNION ALL merges results from multiple MATCH clauses — all must return the same column names
// Use + to concatenate date and time strings into one sortable column
MATCH (a)-[r1]->(b)
WHERE r1.date = "YYYY-MM-DD" OR r1.date = "YYYY-MM-DD"
RETURN r1.date + " " + r1.time AS datetime, "Type A" AS event_type, a.name AS actor, b.name AS location

UNION ALL

MATCH (c)-[r2]->(d)
WHERE r2.date = "YYYY-MM-DD" OR r2.date = "YYYY-MM-DD"
RETURN r2.date + " " + r2.time AS datetime, "Type B" AS event_type, c.name AS actor, d.name AS location

ORDER BY datetime;
```

### Bonus D - Identify the Isolated Suspect

Rosa Ferrer's role is suspicious because she received a phone call from Carlos Vidal after midnight. Determine whether Rosa Ferrer is connected to the rest of the criminal network, and whether there is any indirect path linking her to Iván Bosch within 3 hops.

---

## Part 7 - Extended Investigation (bonus exercises using the expanded dataset)

### Exercise 7.1 - Trace the Stolen Painting

The painting has its own node. Find every person, location, and transaction connected to it.

```cypher
// Hint: use multiple OPTIONAL MATCH clauses from the same central node to gather connected information
// OPTIONAL MATCH returns null columns when no match is found, rather than dropping the row
MATCH (a:NodeType {id: "value"})
OPTIONAL MATCH (b:NodeType)-[:RELATIONSHIP1]->(a)
OPTIONAL MATCH (a)-[:RELATIONSHIP2]->(c:NodeType)
OPTIONAL MATCH (d:NodeType)-[:RELATIONSHIP3]->(a)
RETURN a.property, b.name, c.name, d.name;
```

### Exercise 7.2 - The Pre-Crime Planning Chain

Iván Bosch made two phone calls before the theft to gather information. Find those calls and their recipients.

```cypher
// Hint: filter by a date on the relationship or intermediate node, anchor the start node by name
MATCH (a:NodeType {name: "Specific Person"})-[:REL1]->(b:NodeType)-[:REL2]->(c:NodeType)
WHERE b.date < "YYYY-MM-DD"
RETURN b.id, b.date, b.time, c.name, c.role
ORDER BY b.date, b.time;
```

> **Discussion**: What information could Jorge Molina have provided that would have helped plan the heist?

### Exercise 7.3 - The Full Logistics Chain

Map the complete chain from theft executor to final receiver, including the courier layer.

```cypher
// Hint: build a multi-hop pattern mixing different relationship and node types in one MATCH
// Use a reverse arrow <-[:REL]- when the direction in the graph points the other way
MATCH (a:NodeType)-[:REL1]->(b:NodeType)-[:REL2]->(c:NodeType {property: "value"})
      <-[:REL3]-(d:NodeType)
WHERE a.name = "Specific Person"
RETURN a.name, b.name, c.name, d.name;
```

### Exercise 7.4 - Red Herring Check: Andres Fuentes's Alibi

Andres Fuentes claims he was at a business dinner. Verify whether the evidence supports or challenges that alibi.

```cypher
// Step A: use | inside a relationship type to match either of two relationship types in one pattern
MATCH (a:NodeType {name: "Specific Person"})-[:REL1|REL2]->(b:NodeType)-[r:REL3]->(c:NodeType)
WHERE r.date = "YYYY-MM-DD"
RETURN b.plate, b.model, c.name, r.time;
```

```cypher
// Step B: filter by receiver name rather than sender name
MATCH (a:NodeType)-[:REL1]->(b:NodeType)-[:REL2]->(c:NodeType {name: "Specific Person"})
RETURN a.name, b.date, b.time, b.duration_seconds;
```

> **Investigation note**: The rental car places Fuentes at the private club earlier that evening. Does this overlap with his stated alibi?

### Exercise 7.5 - Show the Complete Criminal Network

Draw the full network of persons connected by KNOWS relationships, annotated with any criminal record.

```cypher
// Hint: use OPTIONAL MATCH for both optional relationships, then WITH to collect results per person
// collect(DISTINCT x) gathers non-null values into a list; size() counts list elements
MATCH (a:NodeType)
OPTIONAL MATCH (a)-[:REL1]->(b:NodeType)
OPTIONAL MATCH (a)-[:REL2]-(c:NodeType)
WITH a, collect(DISTINCT b.property) AS list1, collect(DISTINCT c.name) AS list2
RETURN a.name, a.role, list1, size(list2) AS connection_count
ORDER BY connection_count DESC;
```

```cypher
// Your query here
```

---

## Summary

In this lab you:

- Loaded a complex real-world scenario with 56 nodes and multiple relationship types
- Used basic MATCH queries to explore persons, locations, and roles
- Used path traversal to follow connections through a social network
- Used temporal filtering on relationship properties (date, time) to establish timelines
- Used aggregation to score suspects by evidence count
- Traced a multi-hop financial chain from perpetrator to buyer
- Used UNION ALL to reconstruct a crime timeline from heterogeneous event types
- Identified the criminal through converging evidence in the graph
