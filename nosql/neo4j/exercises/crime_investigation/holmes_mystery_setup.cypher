// =============================================================================
// The Whitechapel Poisoning - Database Setup
// A Sherlock Holmes-inspired murder mystery
// London, November 17th, 1895
//
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

CREATE CONSTRAINT carriage_id IF NOT EXISTS
FOR (c:Carriage) REQUIRE c.id IS UNIQUE;


// --- STEP 3: PERSONS --------------------------------------------------------

// Victim
MERGE (:Person {name: "Edmund Hartwell",        role: "Victim / Clockmaker",      age: 67, address: "23 Montague Street, Whitechapel"});

// Investigators
MERGE (:Person {name: "Sherlock Holmes",         role: "Consulting Detective",     age: 41, address: "221B Baker Street"});
MERGE (:Person {name: "Dr. John Watson",         role: "Police Surgeon",           age: 43, address: "221B Baker Street"});
MERGE (:Person {name: "Inspector Lestrade",      role: "Lead Investigator",        age: 46, address: "Scotland Yard, Westminster"});
MERGE (:Person {name: "Constable Briggs",        role: "Crime Scene Officer",      age: 28, address: "Scotland Yard, Westminster"});

// Suspects
MERGE (:Person {name: "Reginald Fitch",          role: "Business Partner",         age: 54, address: "8 Threadneedle Court, City of London"});
MERGE (:Person {name: "Lady Vivienne Ashworth",  role: "Socialite / Widow",        age: 44, address: "Ashworth House, Mayfair"});
MERGE (:Person {name: "Thomas Morrow",           role: "Clockmaker's Apprentice",  age: 22, address: "Whitechapel Lodgings"});
MERGE (:Person {name: "Cornelius Vane",          role: "Apothecary",               age: 58, address: "Vane's Apothecary, Whitechapel"});
MERGE (:Person {name: "Jack Finch",              role: "Street Dealer",            age: 31, address: "Unknown, Whitechapel"});
MERGE (:Person {name: "Professor Aldous Cray",   role: "Rival Inventor",           age: 60, address: "Greenwich Observatory"});

// Witnesses / Others
MERGE (:Person {name: "Adelaide Hartwell",       role: "Victim's Daughter",        age: 35, address: "12 Belgrave Mews"});
MERGE (:Person {name: "Mrs. Agnes Doyle",        role: "Housekeeper",              age: 55, address: "23 Montague Street, Whitechapel"});
MERGE (:Person {name: "Father Donahue",          role: "Parish Priest",            age: 62, address: "St. Mary's Presbytery, Whitechapel"});


// --- STEP 4: LOCATIONS ------------------------------------------------------

MERGE (:Location {name: "23 Montague Street",          type: "Private Residence",  district: "Whitechapel"});
MERGE (:Location {name: "The Criterion Bar",            type: "Restaurant & Bar",   district: "Piccadilly"});
MERGE (:Location {name: "Vane's Apothecary",            type: "Pharmacy",           district: "Whitechapel"});
MERGE (:Location {name: "Fitch & Hartwell Clockworks",  type: "Workshop",           district: "City of London"});
MERGE (:Location {name: "The Diogenes Club",            type: "Gentlemen's Club",   district: "Pall Mall"});
MERGE (:Location {name: "St. Bartholomew's Hospital",   type: "Hospital",           district: "Smithfield"});
MERGE (:Location {name: "Scotland Yard",                type: "Police Station",     district: "Westminster"});
MERGE (:Location {name: "Whitechapel Market",           type: "Market",             district: "Whitechapel"});
MERGE (:Location {name: "12 Belgrave Mews",             type: "Private Residence",  district: "Belgravia"});
MERGE (:Location {name: "The Dockside Warehouse",       type: "Warehouse",          district: "Limehouse"});
MERGE (:Location {name: "Paddington Station",           type: "Railway Station",    district: "Paddington"});
MERGE (:Location {name: "Greenwich Observatory",        type: "Research Institute", district: "Greenwich"});


// --- STEP 5: CARRIAGES ------------------------------------------------------

MERGE (:Carriage {id: "BLACK-HANSOM-01", type: "Hansom Cab",    color: "Black",   description: "Hired from Chiswick Carriage Co., evening of Nov 17"});
MERGE (:Carriage {id: "LANDAU-ASH-02",  type: "Landau",        color: "Burgundy",description: "Lady Ashworth's private landau"});
MERGE (:Carriage {id: "HACKNEY-HAR-03", type: "Hackney Coach", color: "Brown",   description: "Adelaide Hartwell's family coach"});
MERGE (:Carriage {id: "POLICE-BM-04",   type: "Black Maria",   color: "Black",   description: "Scotland Yard police transport"});
MERGE (:Carriage {id: "CART-FIN-05",    type: "Delivery Cart", color: "Grey",    description: "Used by Jack Finch for street trade"});


// --- STEP 6: COMMUNICATIONS -------------------------------------------------
// Telegrams, letters, and notes sent around the time of the murder.

MERGE (:Communication {id: "COMM-001", type: "Telegram",     date: "1895-11-17", time: "19:00", content: "Must speak tonight. Matter of utmost urgency. — R.F."});
MERGE (:Communication {id: "COMM-002", type: "Letter",       date: "1895-11-15", time: "09:00", content: "Mr. Hartwell, your debt to my late husband's estate remains unresolved. — V.A."});
MERGE (:Communication {id: "COMM-003", type: "Telegram",     date: "1895-11-16", time: "14:30", content: "Require the usual arrangement. Thursday. Payment as agreed."});
MERGE (:Communication {id: "COMM-004", type: "Forged Note",  date: "1895-11-17", time: "17:00", content: "Thomas — admit Mr. Fitch at any hour tonight. Do not disturb me. — E.H."});
MERGE (:Communication {id: "COMM-005", type: "Telegram",     date: "1895-11-17", time: "22:45", content: "Father found dead in his study. Come at once. — Adelaide Hartwell"});
MERGE (:Communication {id: "COMM-006", type: "Letter",       date: "1895-11-10", time: "11:00", content: "If you proceed with dissolving our partnership, I shall be forced to take matters into my own hands. — R.F."});
MERGE (:Communication {id: "COMM-007", type: "Telegram",     date: "1895-11-18", time: "08:00", content: "Package ready for collection. Dockside Warehouse, Limehouse. Come before noon."});
MERGE (:Communication {id: "COMM-008", type: "Letter",       date: "1895-11-12", time: "10:00", content: "Dear Hartwell, this so-called patent of yours is a clear theft of my prior work at Greenwich. — Prof. A. Cray"});


// --- STEP 7: FINANCIAL TRANSACTIONS (November 1895) -------------------------

MERGE (:FinancialTransaction {id: "TXN-001", date: "1895-11-14", amount:    12, currency: "GBP", type: "Cash Payment",    concept: "Pharmaceutical supplies"});
MERGE (:FinancialTransaction {id: "TXN-002", date: "1895-11-20", amount:   200, currency: "GBP", type: "Banker's Draft",  concept: "Partial debt settlement"});
MERGE (:FinancialTransaction {id: "TXN-003", date: "1895-11-18", amount:  3000, currency: "GBP", type: "Wire Transfer",   concept: "Transfer to Belgian account"});
MERGE (:FinancialTransaction {id: "TXN-004", date: "1895-11-18", amount:    25, currency: "GBP", type: "Cash Payment",    concept: "Services rendered"});
MERGE (:FinancialTransaction {id: "TXN-005", date: "1895-11-30", amount:  5000, currency: "GBP", type: "Estate Transfer", concept: "Will: bequest to Adelaide Hartwell"});
MERGE (:FinancialTransaction {id: "TXN-006", date: "1895-11-25", amount:  8000, currency: "GBP", type: "Insurance Claim", concept: "Business partnership life policy payout"});
MERGE (:FinancialTransaction {id: "TXN-007", date: "1895-11-17", amount:     5, currency: "GBP", type: "Cash Payment",    concept: "Carriage hire, evening of Nov 17"});


// --- STEP 8: EVIDENCE -------------------------------------------------------

MERGE (:Evidence {id: "EVD-001", type: "Personal Item",   description: "Silver walking stick handle engraved 'R.F.'",                       location_found: "Study floor, near writing desk"});
MERGE (:Evidence {id: "EVD-002", type: "Personal Item",   description: "Monogrammed handkerchief initialled 'R.F.'",                        location_found: "Study fireplace"});
MERGE (:Evidence {id: "EVD-003", type: "Toxicology",      description: "Arsenic traces identified in porcelain teacup",                      location_found: "Study side table"});
MERGE (:Evidence {id: "EVD-004", type: "Footprint",       description: "Size 44 boot print, custom Lobb's of St. James's Street",           location_found: "Garden entrance, soft earth"});
MERGE (:Evidence {id: "EVD-005", type: "Document",        description: "Torn letter fragment: '...take matters into my own hands. — R.F.'",  location_found: "Study fireplace grate"});
MERGE (:Evidence {id: "EVD-006", type: "Witness Account", description: "Black hansom cab seen outside 23 Montague Street at 21:30",          location_found: "Street level, reported by Mrs. Doyle"});


// --- STEP 9: CRIMINAL RECORDS -----------------------------------------------

MERGE (:CriminalRecord {id: "REC-001", offense: "Fraudulent business dealings",     year: 1889, sentenced: false});
MERGE (:CriminalRecord {id: "REC-002", offense: "Receiving stolen goods",           year: 1893, sentenced: true});
MERGE (:CriminalRecord {id: "REC-003", offense: "Assault at a public house",        year: 1892, sentenced: false});
MERGE (:CriminalRecord {id: "REC-004", offense: "Forgery of pharmaceutical ledger", year: 1887, sentenced: false});


// --- STEP 10: WORKS_AT RELATIONSHIPS ----------------------------------------

MATCH (p:Person {name: "Reginald Fitch"}),        (l:Location {name: "Fitch & Hartwell Clockworks"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Edmund Hartwell"}),        (l:Location {name: "Fitch & Hartwell Clockworks"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Thomas Morrow"}),          (l:Location {name: "Fitch & Hartwell Clockworks"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Cornelius Vane"}),         (l:Location {name: "Vane's Apothecary"})           MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Mrs. Agnes Doyle"}),       (l:Location {name: "23 Montague Street"})          MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Inspector Lestrade"}),     (l:Location {name: "Scotland Yard"})               MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Constable Briggs"}),       (l:Location {name: "Scotland Yard"})               MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Professor Aldous Cray"}),  (l:Location {name: "Greenwich Observatory"})       MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Jack Finch"}),             (l:Location {name: "The Dockside Warehouse"})      MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 11: VISITED RELATIONSHIPS -----------------------------------------

// Fitch visits the crime scene twice — once before for business, once the night of the murder
MATCH (p:Person {name: "Reginald Fitch"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-15", time: "15:00", purpose: "Business discussion with Hartwell"}]->(l);

MATCH (p:Person {name: "Reginald Fitch"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "21:00", purpose: "Private meeting, admitted by Morrow per forged note"}]->(l);

MATCH (p:Person {name: "Reginald Fitch"}), (l:Location {name: "The Diogenes Club"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "19:30", purpose: "Club dinner — claimed full-evening alibi, departed early"}]->(l);

MATCH (p:Person {name: "Lady Vivienne Ashworth"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "18:00", purpose: "Dinner invitation with Hartwell"}]->(l);

MATCH (p:Person {name: "Lady Vivienne Ashworth"}), (l:Location {name: "The Criterion Bar"})
MERGE (p)-[:VISITED {date: "1895-11-16", time: "20:00", purpose: "Social engagement"}]->(l);

MATCH (p:Person {name: "Thomas Morrow"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "20:30", purpose: "Evening duties, admitted Fitch per note believed genuine"}]->(l);

MATCH (p:Person {name: "Adelaide Hartwell"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "22:30", purpose: "Routine evening visit, discovered body"}]->(l);

MATCH (p:Person {name: "Sherlock Holmes"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "09:00", purpose: "Crime scene investigation at Lestrade's request"}]->(l);

MATCH (p:Person {name: "Dr. John Watson"}), (l:Location {name: "St. Bartholomew's Hospital"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "11:00", purpose: "Post-mortem examination of Edmund Hartwell"}]->(l);

MATCH (p:Person {name: "Jack Finch"}), (l:Location {name: "The Dockside Warehouse"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "10:00", purpose: "Package collection"}]->(l);

MATCH (p:Person {name: "Jack Finch"}), (l:Location {name: "Whitechapel Market"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "18:00", purpose: "Usual rounds, confirmed by stall holders"}]->(l);

MATCH (p:Person {name: "Professor Aldous Cray"}), (l:Location {name: "Paddington Station"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "17:00", purpose: "Departure to Oxford — confirmed alibi by station master"}]->(l);


// --- STEP 12: CARRIAGE OWNERSHIP AND SIGHTINGS ------------------------------

MATCH (p:Person {name: "Reginald Fitch"}),        (c:Carriage {id: "BLACK-HANSOM-01"}) MERGE (p)-[:OWNS]->(c);
MATCH (p:Person {name: "Lady Vivienne Ashworth"}), (c:Carriage {id: "LANDAU-ASH-02"})  MERGE (p)-[:OWNS]->(c);
MATCH (p:Person {name: "Adelaide Hartwell"}),      (c:Carriage {id: "HACKNEY-HAR-03"}) MERGE (p)-[:OWNS]->(c);
MATCH (p:Person {name: "Inspector Lestrade"}),     (c:Carriage {id: "POLICE-BM-04"})   MERGE (p)-[:OWNS]->(c);
MATCH (p:Person {name: "Jack Finch"}),             (c:Carriage {id: "CART-FIN-05"})    MERGE (p)-[:OWNS]->(c);

MATCH (c:Carriage {id: "BLACK-HANSOM-01"}), (l:Location {name: "23 Montague Street"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-17", time: "21:30"}]->(l);

MATCH (c:Carriage {id: "BLACK-HANSOM-01"}), (l:Location {name: "The Dockside Warehouse"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-18", time: "09:45"}]->(l);

MATCH (c:Carriage {id: "LANDAU-ASH-02"}), (l:Location {name: "23 Montague Street"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-17", time: "18:00"}]->(l);

MATCH (c:Carriage {id: "POLICE-BM-04"}), (l:Location {name: "23 Montague Street"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-18", time: "00:30"}]->(l);

MATCH (c:Carriage {id: "CART-FIN-05"}), (l:Location {name: "The Dockside Warehouse"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-18", time: "10:15"}]->(l);


// --- STEP 13: COMMUNICATION RELATIONSHIPS -----------------------------------

MATCH (p:Person {name: "Reginald Fitch"}),        (c:Communication {id: "COMM-001"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-001"}),          (p:Person {name: "Edmund Hartwell"})      MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Lady Vivienne Ashworth"}), (c:Communication {id: "COMM-002"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-002"}),          (p:Person {name: "Edmund Hartwell"})      MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Reginald Fitch"}),         (c:Communication {id: "COMM-003"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-003"}),          (p:Person {name: "Cornelius Vane"})       MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Reginald Fitch"}),         (c:Communication {id: "COMM-004"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-004"}),          (p:Person {name: "Thomas Morrow"})        MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Adelaide Hartwell"}),      (c:Communication {id: "COMM-005"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-005"}),          (p:Person {name: "Inspector Lestrade"})   MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Reginald Fitch"}),         (c:Communication {id: "COMM-006"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-006"}),          (p:Person {name: "Edmund Hartwell"})      MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Reginald Fitch"}),         (c:Communication {id: "COMM-007"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-007"}),          (p:Person {name: "Jack Finch"})            MERGE (c)-[:ADDRESSED_TO]->(p);

MATCH (p:Person {name: "Professor Aldous Cray"}),  (c:Communication {id: "COMM-008"}) MERGE (p)-[:SENT_MESSAGE]->(c);
MATCH (c:Communication {id: "COMM-008"}),          (p:Person {name: "Edmund Hartwell"})      MERGE (c)-[:ADDRESSED_TO]->(p);


// --- STEP 14: FINANCIAL TRANSACTION RELATIONSHIPS ---------------------------

// TXN-001: Fitch pays Vane for pharmaceutical supplies (arsenic, 3 days before murder)
MATCH (p:Person {name: "Reginald Fitch"}),        (t:FinancialTransaction {id: "TXN-001"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-001"}),   (p:Person {name: "Cornelius Vane"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-002: Lady Ashworth pays debt to Adelaide (Hartwell estate), post-mortem
MATCH (p:Person {name: "Lady Vivienne Ashworth"}),(t:FinancialTransaction {id: "TXN-002"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-002"}),   (p:Person {name: "Adelaide Hartwell"})  MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-003: Fitch transfers £3000 abroad (flight money, day after murder)
MATCH (p:Person {name: "Reginald Fitch"}),        (t:FinancialTransaction {id: "TXN-003"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-003"}),   (p:Person {name: "Reginald Fitch"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-004: Fitch pays Jack Finch for services rendered (delivering stolen pocket watch)
MATCH (p:Person {name: "Reginald Fitch"}),        (t:FinancialTransaction {id: "TXN-004"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-004"}),   (p:Person {name: "Jack Finch"})           MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-005: Hartwell estate bequeaths £5000 to Adelaide (will execution)
MATCH (p:Person {name: "Edmund Hartwell"}),       (t:FinancialTransaction {id: "TXN-005"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-005"}),   (p:Person {name: "Adelaide Hartwell"})   MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-006: Fitch files and receives life partnership insurance payout (post-murder)
MATCH (p:Person {name: "Reginald Fitch"}),        (t:FinancialTransaction {id: "TXN-006"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-006"}),   (p:Person {name: "Reginald Fitch"})      MERGE (t)-[:RECEIVED_BY]->(p);

// TXN-007: Fitch pays carriage hire company (proves he hired BLACK-HANSOM-01)
MATCH (p:Person {name: "Reginald Fitch"}),        (t:FinancialTransaction {id: "TXN-007"}) MERGE (p)-[:SENT_TRANSACTION]->(t);
MATCH (t:FinancialTransaction {id: "TXN-007"}),   (p:Person {name: "Reginald Fitch"})      MERGE (t)-[:RECEIVED_BY]->(p);


// --- STEP 15: KNOWS RELATIONSHIPS -------------------------------------------

MATCH (a:Person {name: "Reginald Fitch"}),        (b:Person {name: "Edmund Hartwell"})       MERGE (a)-[:KNOWS {since: 1878, context: "Business partners, Fitch & Hartwell Clockworks"}]->(b);
MATCH (a:Person {name: "Reginald Fitch"}),         (b:Person {name: "Cornelius Vane"})        MERGE (a)-[:KNOWS {since: 1885, context: "Pharmacy supplier, recurring payments"}]->(b);
MATCH (a:Person {name: "Reginald Fitch"}),         (b:Person {name: "Jack Finch"})             MERGE (a)-[:KNOWS {since: 1891, context: "Criminal underworld contact"}]->(b);
MATCH (a:Person {name: "Reginald Fitch"}),         (b:Person {name: "Lady Vivienne Ashworth"}) MERGE (a)-[:KNOWS {since: 1890, context: "London society acquaintance"}]->(b);
MATCH (a:Person {name: "Lady Vivienne Ashworth"}), (b:Person {name: "Edmund Hartwell"})        MERGE (a)-[:KNOWS {since: 1888, context: "Creditor-debtor relationship"}]->(b);
MATCH (a:Person {name: "Thomas Morrow"}),          (b:Person {name: "Edmund Hartwell"})        MERGE (a)-[:KNOWS {since: 1893, context: "Apprentice and master"}]->(b);
MATCH (a:Person {name: "Adelaide Hartwell"}),      (b:Person {name: "Edmund Hartwell"})        MERGE (a)-[:KNOWS {since: 1860, context: "Father and daughter"}]->(b);
MATCH (a:Person {name: "Sherlock Holmes"}),        (b:Person {name: "Inspector Lestrade"})     MERGE (a)-[:KNOWS {since: 1881, context: "Professional collaboration"}]->(b);
MATCH (a:Person {name: "Sherlock Holmes"}),        (b:Person {name: "Dr. John Watson"})        MERGE (a)-[:KNOWS {since: 1881, context: "Friend and colleague"}]->(b);
MATCH (a:Person {name: "Cornelius Vane"}),         (b:Person {name: "Jack Finch"})             MERGE (a)-[:KNOWS {since: 1890, context: "Black market dealings"}]->(b);


// --- STEP 16: EVIDENCE -> LOCATION AND EVIDENCE -> PERSON -------------------

MATCH (e:Evidence {id: "EVD-001"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-002"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-003"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-004"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-005"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);
MATCH (e:Evidence {id: "EVD-006"}), (l:Location {name: "23 Montague Street"}) MERGE (e)-[:FOUND_AT]->(l);

MATCH (e:Evidence {id: "EVD-001"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "high",   basis: "Initials R.F.; custom silver handle traced to Asprey & Co., City of London — Fitch is a client"}]->(p);

MATCH (e:Evidence {id: "EVD-002"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "high",   basis: "Initials R.F.; same linen supplier as Fitch's known handkerchiefs, confirmed by Holmes"}]->(p);

MATCH (e:Evidence {id: "EVD-003"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "medium", basis: "Arsenic sourced from Vane's Apothecary; Fitch paid Vane three days before murder (TXN-001)"}]->(p);

MATCH (e:Evidence {id: "EVD-004"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "high",   basis: "Size 44, Lobb's of St James's Street; Fitch confirmed as client in Lobb's order ledger"}]->(p);

MATCH (e:Evidence {id: "EVD-005"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "high",   basis: "Handwriting matched by Holmes to letter COMM-006, signed R.F., same ink and hand"}]->(p);

MATCH (e:Evidence {id: "EVD-006"}), (p:Person {name: "Reginald Fitch"})
MERGE (e)-[:LINKED_TO {confidence: "high",   basis: "BLACK-HANSOM-01 hired by Fitch per Chiswick Carriage Co. ledger (TXN-007); matches cab description"}]->(p);


// --- STEP 17: CRIMINAL RECORDS ----------------------------------------------

MATCH (p:Person {name: "Reginald Fitch"}),        (r:CriminalRecord {id: "REC-001"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Jack Finch"}),             (r:CriminalRecord {id: "REC-002"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Thomas Morrow"}),          (r:CriminalRecord {id: "REC-003"}) MERGE (p)-[:HAS_RECORD]->(r);
MATCH (p:Person {name: "Cornelius Vane"}),         (r:CriminalRecord {id: "REC-004"}) MERGE (p)-[:HAS_RECORD]->(r);


// --- STEP 18: ADDITIONAL SUSPECTS ------------------------------------------
// Five new suspects to increase relational complexity and deepen the web of
// connections. None of them are the killer — they serve as red herrings,
// witnesses, and secondary links that make the graph harder to resolve at a glance.

MERGE (:Person {name: "Nathaniel Greaves",  role: "Solicitor",                   age: 49, address: "Gray's Inn, Holborn"});
MERGE (:Person {name: "Harriet Bowden",     role: "Lodging House Keeper",         age: 51, address: "Whitechapel Lodgings"});
MERGE (:Person {name: "Edwin Locket",       role: "Insurance Broker",             age: 45, address: "Lloyd's, City of London"});
MERGE (:Person {name: "Miriam Vane",        role: "Apothecary's Assistant",       age: 26, address: "Vane's Apothecary, Whitechapel"});
MERGE (:Person {name: "Sebastian Morrow",   role: "Dockworker / Petty Criminal",  age: 27, address: "Limehouse Docks"});


// --- STEP 19: ADDITIONAL LOCATIONS ------------------------------------------

MERGE (:Location {name: "Gray's Inn",           type: "Legal Chambers",  district: "Holborn"});
MERGE (:Location {name: "Lloyd's of London",    type: "Insurance Market",district: "City of London"});
MERGE (:Location {name: "Whitechapel Lodgings", type: "Boarding House",  district: "Whitechapel"});


// --- STEP 20: WORKS_AT FOR NEW PERSONS --------------------------------------

MATCH (p:Person {name: "Nathaniel Greaves"}), (l:Location {name: "Gray's Inn"})            MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Edwin Locket"}),      (l:Location {name: "Lloyd's of London"})     MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Miriam Vane"}),       (l:Location {name: "Vane's Apothecary"})     MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Sebastian Morrow"}),  (l:Location {name: "The Dockside Warehouse"}) MERGE (p)-[:WORKS_AT]->(l);
MATCH (p:Person {name: "Harriet Bowden"}),    (l:Location {name: "Whitechapel Lodgings"})  MERGE (p)-[:WORKS_AT]->(l);


// --- STEP 21: VISITED FOR NEW PERSONS ---------------------------------------

MATCH (p:Person {name: "Nathaniel Greaves"}), (l:Location {name: "23 Montague Street"})
MERGE (p)-[:VISITED {date: "1895-11-19", time: "10:00", purpose: "Reading of the will, summoned by Adelaide Hartwell"}]->(l);

MATCH (p:Person {name: "Nathaniel Greaves"}), (l:Location {name: "Fitch & Hartwell Clockworks"})
MERGE (p)-[:VISITED {date: "1895-11-10", time: "14:00", purpose: "Formal notice of partnership dissolution served to Fitch on behalf of Hartwell"}]->(l);

MATCH (p:Person {name: "Edwin Locket"}),      (l:Location {name: "Lloyd's of London"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "09:30", purpose: "Fitch filed the life partnership insurance claim within hours of the murder being reported"}]->(l);

MATCH (p:Person {name: "Edwin Locket"}),      (l:Location {name: "Fitch & Hartwell Clockworks"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "11:00", purpose: "Confirmed claim details with Fitch in person at the workshop"}]->(l);

MATCH (p:Person {name: "Miriam Vane"}),       (l:Location {name: "Vane's Apothecary"})
MERGE (p)-[:VISITED {date: "1895-11-14", time: "15:00", purpose: "Present when arsenic powder was dispensed — sole other witness to TXN-001"}]->(l);

MATCH (p:Person {name: "Miriam Vane"}),       (l:Location {name: "Whitechapel Market"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "19:00", purpose: "Evening walk — may have observed carriage or persons near the Montague Street scene"}]->(l);

MATCH (p:Person {name: "Sebastian Morrow"}),  (l:Location {name: "The Dockside Warehouse"})
MERGE (p)-[:VISITED {date: "1895-11-18", time: "10:00", purpose: "Routine dock shift — present when Fitch's package was collected by Jack Finch"}]->(l);

MATCH (p:Person {name: "Harriet Bowden"}),    (l:Location {name: "Whitechapel Market"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "20:00", purpose: "Evening shopping, confirmed by market vendors"}]->(l);

MATCH (p:Person {name: "Harriet Bowden"}),    (l:Location {name: "Whitechapel Lodgings"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "21:00", purpose: "At home all evening — states she heard Morrow return briefly before 20:30"}]->(l);


// --- STEP 22: EMPLOYED_BY ---------------------------------------------------
// Direct employment relationships between persons (not just WORKS_AT a Location).

MATCH (a:Person {name: "Thomas Morrow"}),    (b:Person {name: "Edmund Hartwell"})
MERGE (a)-[:EMPLOYED_BY {since: 1893, position: "Clockmaker's Apprentice", wage: "12 shillings per week"}]->(b);

MATCH (a:Person {name: "Miriam Vane"}),      (b:Person {name: "Cornelius Vane"})
MERGE (a)-[:EMPLOYED_BY {since: 1891, position: "Apothecary's Assistant", relation: "Uncle's employ"}]->(b);

MATCH (a:Person {name: "Mrs. Agnes Doyle"}), (b:Person {name: "Edmund Hartwell"})
MERGE (a)-[:EMPLOYED_BY {since: 1880, position: "Housekeeper", wage: "18 shillings per week"}]->(b);


// --- STEP 23: RELATED_TO (family ties) --------------------------------------

MATCH (a:Person {name: "Sebastian Morrow"}), (b:Person {name: "Thomas Morrow"})
MERGE (a)-[:RELATED_TO {relation: "Older brother"}]->(b);

MATCH (a:Person {name: "Thomas Morrow"}),    (b:Person {name: "Sebastian Morrow"})
MERGE (a)-[:RELATED_TO {relation: "Younger brother"}]->(b);

MATCH (a:Person {name: "Adelaide Hartwell"}),(b:Person {name: "Edmund Hartwell"})
MERGE (a)-[:RELATED_TO {relation: "Daughter"}]->(b);

MATCH (a:Person {name: "Edmund Hartwell"}),  (b:Person {name: "Adelaide Hartwell"})
MERGE (a)-[:RELATED_TO {relation: "Father"}]->(b);

MATCH (a:Person {name: "Miriam Vane"}),      (b:Person {name: "Cornelius Vane"})
MERGE (a)-[:RELATED_TO {relation: "Niece"}]->(b);

MATCH (a:Person {name: "Cornelius Vane"}),   (b:Person {name: "Miriam Vane"})
MERGE (a)-[:RELATED_TO {relation: "Uncle"}]->(b);


// --- STEP 24: REPRESENTED_BY (legal counsel) --------------------------------

MATCH (a:Person {name: "Edmund Hartwell"}),       (b:Person {name: "Nathaniel Greaves"})
MERGE (a)-[:REPRESENTED_BY {since: 1880, matter: "Estate planning, will, and Clockworks partnership deed"}]->(b);

MATCH (a:Person {name: "Reginald Fitch"}),        (b:Person {name: "Nathaniel Greaves"})
MERGE (a)-[:REPRESENTED_BY {since: 1889, matter: "Defence counsel in 1889 fraudulent dealing investigation"}]->(b);

MATCH (a:Person {name: "Adelaide Hartwell"}),     (b:Person {name: "Nathaniel Greaves"})
MERGE (a)-[:REPRESENTED_BY {since: 1895, matter: "Executor of father's estate and probate proceedings"}]->(b);

MATCH (a:Person {name: "Professor Aldous Cray"}), (b:Person {name: "Nathaniel Greaves"})
MERGE (a)-[:REPRESENTED_BY {since: 1894, matter: "Patent infringement claim against Hartwell's escapement mechanism"}]->(b);


// --- STEP 25: OWES_DEBT_TO --------------------------------------------------

MATCH (a:Person {name: "Edmund Hartwell"}), (b:Person {name: "Lady Vivienne Ashworth"})
MERGE (a)-[:OWES_DEBT_TO {amount: 400, currency: "GBP", since: "1888", context: "Unreturned investment returns from late Lord Ashworth's estate"}]->(b);

MATCH (a:Person {name: "Thomas Morrow"}),   (b:Person {name: "Harriet Bowden"})
MERGE (a)-[:OWES_DEBT_TO {amount: 3, currency: "GBP", since: "1895-10", context: "Two months of unpaid rent at Whitechapel Lodgings"}]->(b);

MATCH (a:Person {name: "Cornelius Vane"}),  (b:Person {name: "Jack Finch"})
MERGE (a)-[:OWES_DEBT_TO {amount: 10, currency: "GBP", since: "1893", context: "Outstanding balance on black market supply arrangement"}]->(b);


// --- STEP 26: INSURED_BY ----------------------------------------------------

MATCH (a:Person {name: "Reginald Fitch"}),  (b:Person {name: "Edwin Locket"})
MERGE (a)-[:INSURED_BY {policy: "Life Partnership Policy No. 4471", sum_insured: 8000, currency: "GBP", year_signed: 1888, beneficiary: "Surviving partner"}]->(b);


// --- STEP 27: PROVIDES_ALIBI_FOR --------------------------------------------

MATCH (a:Person {name: "Harriet Bowden"}),  (b:Person {name: "Thomas Morrow"})
MERGE (a)-[:PROVIDES_ALIBI_FOR {date: "1895-11-17", time: "20:00", statement: "Morrow returned to his rooms briefly before going out; back by 20:30"}]->(b);

MATCH (a:Person {name: "Father Donahue"}),  (b:Person {name: "Mrs. Agnes Doyle"})
MERGE (a)-[:PROVIDES_ALIBI_FOR {date: "1895-11-17", time: "18:00", statement: "Mrs. Doyle attended evening mass at St. Mary's and departed at 19:00"}]->(b);


// --- STEP 28: KNOWS FOR NEW PERSONS AND ADDITIONAL CROSS-LINKS --------------

MATCH (a:Person {name: "Nathaniel Greaves"}), (b:Person {name: "Edmund Hartwell"})
MERGE (a)-[:KNOWS {since: 1880, context: "Solicitor-client: managed will and Clockworks partnership deed for fifteen years"}]->(b);

MATCH (a:Person {name: "Nathaniel Greaves"}), (b:Person {name: "Reginald Fitch"})
MERGE (a)-[:KNOWS {since: 1889, context: "Defence counsel in fraud case; later became aware of the partnership dissolution"}]->(b);

MATCH (a:Person {name: "Nathaniel Greaves"}), (b:Person {name: "Adelaide Hartwell"})
MERGE (a)-[:KNOWS {since: 1880, context: "Estate executor and legal representative for Adelaide"}]->(b);

MATCH (a:Person {name: "Nathaniel Greaves"}), (b:Person {name: "Lady Vivienne Ashworth"})
MERGE (a)-[:KNOWS {since: 1890, context: "London society; assisted with late Lord Ashworth's estate matters"}]->(b);

MATCH (a:Person {name: "Nathaniel Greaves"}), (b:Person {name: "Professor Aldous Cray"})
MERGE (a)-[:KNOWS {since: 1894, context: "Represents Cray in patent infringement proceedings against Hartwell"}]->(b);

MATCH (a:Person {name: "Edwin Locket"}),      (b:Person {name: "Reginald Fitch"})
MERGE (a)-[:KNOWS {since: 1888, context: "Sold and has administered Fitch's life partnership insurance policy since 1888"}]->(b);

MATCH (a:Person {name: "Edwin Locket"}),      (b:Person {name: "Nathaniel Greaves"})
MERGE (a)-[:KNOWS {since: 1885, context: "Professional network, City of London financial and legal circles"}]->(b);

MATCH (a:Person {name: "Harriet Bowden"}),    (b:Person {name: "Thomas Morrow"})
MERGE (a)-[:KNOWS {since: 1893, context: "Landlady-tenant relationship at Whitechapel Lodgings"}]->(b);

MATCH (a:Person {name: "Harriet Bowden"}),    (b:Person {name: "Sebastian Morrow"})
MERGE (a)-[:KNOWS {since: 1893, context: "Sebastian made frequent visits to his brother Thomas at the lodging house"}]->(b);

MATCH (a:Person {name: "Harriet Bowden"}),    (b:Person {name: "Jack Finch"})
MERGE (a)-[:KNOWS {since: 1892, context: "Neighbourhood acquaintance; Bowden suspicious of dealings near lodgings"}]->(b);

MATCH (a:Person {name: "Miriam Vane"}),       (b:Person {name: "Cornelius Vane"})
MERGE (a)-[:KNOWS {since: 1885, context: "Uncle and niece; works daily at his apothecary in Whitechapel"}]->(b);

MATCH (a:Person {name: "Miriam Vane"}),       (b:Person {name: "Jack Finch"})
MERGE (a)-[:KNOWS {since: 1893, context: "Romantic acquaintance; has passed pharmacy stock information to Finch"}]->(b);

MATCH (a:Person {name: "Miriam Vane"}),       (b:Person {name: "Sebastian Morrow"})
MERGE (a)-[:KNOWS {since: 1894, context: "Social acquaintance met through Jack Finch's Whitechapel circle"}]->(b);

MATCH (a:Person {name: "Sebastian Morrow"}),  (b:Person {name: "Thomas Morrow"})
MERGE (a)-[:KNOWS {since: 1868, context: "Brothers, raised together in Whitechapel"}]->(b);

MATCH (a:Person {name: "Sebastian Morrow"}),  (b:Person {name: "Jack Finch"})
MERGE (a)-[:KNOWS {since: 1890, context: "Criminal network — dock theft and contraband fencing in Limehouse"}]->(b);

MATCH (a:Person {name: "Sebastian Morrow"}),  (b:Person {name: "Cornelius Vane"})
MERGE (a)-[:KNOWS {since: 1892, context: "Black market dealings: stolen pharmaceutical ingredients"}]->(b);

MATCH (a:Person {name: "Father Donahue"}),    (b:Person {name: "Adelaide Hartwell"})
MERGE (a)-[:KNOWS {since: 1885, context: "Parish priest, Adelaide's confessor and spiritual adviser"}]->(b);

MATCH (a:Person {name: "Father Donahue"}),    (b:Person {name: "Mrs. Agnes Doyle"})
MERGE (a)-[:KNOWS {since: 1880, context: "Parish community; Mrs. Doyle a faithful parishioner of St. Mary's"}]->(b);

MATCH (a:Person {name: "Father Donahue"}),    (b:Person {name: "Edmund Hartwell"})
MERGE (a)-[:KNOWS {since: 1875, context: "Parishioner; made occasional charitable donations to St. Mary's"}]->(b);

MATCH (a:Person {name: "Mrs. Agnes Doyle"}),  (b:Person {name: "Thomas Morrow"})
MERGE (a)-[:KNOWS {since: 1893, context: "Household colleagues at 23 Montague Street"}]->(b);

MATCH (a:Person {name: "Constable Briggs"}),  (b:Person {name: "Jack Finch"})
MERGE (a)-[:KNOWS {since: 1893, context: "Briggs made the arrest when Finch was charged with receiving stolen goods"}]->(b);

MATCH (a:Person {name: "Constable Briggs"}),  (b:Person {name: "Sebastian Morrow"})
MERGE (a)-[:KNOWS {since: 1894, context: "Briggs questioned Morrow in connection with the Limehouse dock theft"}]->(b);


// --- STEP 29: ORPHAN RESOLUTION ---------------------------------------------
// "12 Belgrave Mews" was the only node with zero relationships.
// Adelaide Hartwell lives there; her coach departed from there on the night of
// the murder and was seen outside 23 Montague Street when she discovered the body.

MATCH (p:Person {name: "Adelaide Hartwell"}), (l:Location {name: "12 Belgrave Mews"})
MERGE (p)-[:VISITED {date: "1895-11-17", time: "21:45", purpose: "Home — departed for 23 Montague Street after growing concern for her father"}]->(l);

MATCH (c:Carriage {id: "HACKNEY-HAR-03"}), (l:Location {name: "23 Montague Street"})
MERGE (c)-[:SPOTTED_AT {date: "1895-11-17", time: "22:30"}]->(l);


// --- STEP 30: VERIFY --------------------------------------------------------

MATCH (n)
RETURN labels(n) AS label, count(n) AS count
ORDER BY count DESC;

// Expected:
// Person                 19
// Location               15
// Communication           8
// FinancialTransaction    7
// Evidence                6
// Carriage                5
// CriminalRecord          4
// Total nodes: 64
