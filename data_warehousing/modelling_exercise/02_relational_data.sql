-- Author: Víctor Barceló
-- =============================================================================
-- Relational Model - Data Population
-- =============================================================================
-- Generates realistic football league data for TEN leagues:
--   Spanish La Liga         (clubs   1-20)
--   English Premier League  (clubs  21-40)
--   German Bundesliga       (clubs  41-60)
--   Italian Serie A         (clubs  61-80)
--   French Ligue 1          (clubs  81-100)
--   Portuguese Primeira Liga (clubs 101-120)
--   Dutch Eredivisie        (clubs 121-140)
--   Turkish Super Lig       (clubs 141-160)
--   Scottish Premiership    (clubs 161-180)
--   Belgian Pro League      (clubs 181-200)
--
--   200 clubs, 5000 players, 50 seasons (1975/76-2024/25),
--   190000 matches, ~532000 goals, ~1140000 cards
-- Uses a fixed random seed (0.42) for reproducibility.
-- =============================================================================

DO $$
DECLARE
    -- Club data arrays (60 clubs: 20 Spanish + 20 English + 20 German)
    v_club_names TEXT[] := ARRAY[
        -- Spanish La Liga (1-20)
        'FC Barcelona',    'Real Madrid CF',   'Atletico Madrid',  'Valencia CF',
        'Sevilla FC',      'Real Betis',       'Villarreal CF',    'Athletic Club',
        'Real Sociedad',   'Celta Vigo',       'Getafe CF',        'Osasuna',
        'Rayo Vallecano',  'UD Almeria',       'Cadiz CF',         'Girona FC',
        'Granada CF',      'Deportivo Alaves', 'Levante UD',       'Espanyol',
        -- English Premier League (21-40)
        'Manchester City', 'Liverpool FC',     'Arsenal FC',       'Manchester United',
        'Chelsea FC',      'Tottenham Hotspur','Newcastle United', 'Aston Villa',
        'West Ham United', 'Brighton & Hove',  'Wolverhampton',    'Crystal Palace',
        'Brentford FC',    'Fulham FC',        'Everton FC',       'Nottm Forest',
        'Leicester City',  'Leeds United',     'Southampton FC',   'Burnley FC',
        -- German Bundesliga (41-60)
        'Borussia Dortmund','Bayern Munich',   'RB Leipzig',       'Bayer Leverkusen',
        'Eintracht Frankfurt','VfL Wolfsburg', 'SC Freiburg',      'Union Berlin',
        'Borussia M-Gladbach','VfB Stuttgart', '1899 Hoffenheim',  'FC Augsburg',
        'FC Cologne',      'Mainz 05',         'VfL Bochum',       'Darmstadt 98',
        'FC Heidenheim',   'Werder Bremen',    'Hamburger SV',     'Schalke 04',
        -- Italian Serie A (61-80)
        'Juventus FC',      'AC Milan',         'Inter Milan',      'AS Roma',
        'SSC Napoli',       'SS Lazio',         'Atalanta BC',      'ACF Fiorentina',
        'Torino FC',        'Udinese Calcio',   'US Sassuolo',      'Bologna FC',
        'Hellas Verona',    'UC Sampdoria',     'Cagliari Calcio',  'US Lecce',
        'AC Monza',         'Empoli FC',        'Spezia Calcio',    'Cremonese FC',
        -- French Ligue 1 (81-100)
        'Paris Saint-Germain','Olympique Marseille','Olympique Lyon','AS Monaco',
        'LOSC Lille',       'RC Lens',          'OGC Nice',         'Stade Rennais',
        'FC Nantes',        'RC Strasbourg',    'Stade Reims',      'Montpellier HSC',
        'Stade Brest',      'FC Lorient',       'Clermont Foot',    'Toulouse FC',
        'FC Metz',          'Le Havre AC',      'Angers SCO',       'ESTAC Troyes',
        -- Portuguese Primeira Liga (101-120)
        'SL Benfica',       'FC Porto',         'Sporting CP',      'SC Braga',
        'Vitoria SC',       'Boavista FC',      'Estoril Praia',    'Casa Pia AC',
        'FC Famalicao',     'Pacos Ferreira',   'FC Arouca',        'GD Chaves',
        'Gil Vicente FC',   'Moreirense FC',    'Portimonense',     'SC Santa Clara',
        'FC Vizela',        'CS Maritimo',      'CD Nacional',      'Estrela Amadora',
        -- Dutch Eredivisie (121-140)
        'AFC Ajax',         'PSV Eindhoven',    'Feyenoord',        'AZ Alkmaar',
        'FC Twente',        'FC Utrecht',       'Vitesse Arnhem',   'FC Groningen',
        'SC Heerenveen',    'Sparta Rotterdam', 'NEC Nijmegen',     'Fortuna Sittard',
        'RKC Waalwijk',     'SC Cambuur',       'FC Emmen',         'PEC Zwolle',
        'Go Ahead Eagles',  'Excelsior',        'Heracles Almelo',  'Willem II',
        -- Turkish Super Lig (141-160)
        'Galatasaray',      'Fenerbahce',       'Besiktas',         'Trabzonspor',
        'Bursaspor',        'Basaksehir FK',    'Konyaspor',        'Sivasspor',
        'Antalyaspor',      'Kayserispor',      'Alanyaspor',       'Gaziantep FK',
        'Hatayspor',        'Caykur Rizespor',  'Kasimpasa',        'Fatih Karagumruk',
        'Ankaragucu',       'Pendikspor',       'Adana Demirspor',  'Giresunspor',
        -- Scottish Premiership (161-180)
        'Celtic FC',        'Rangers FC',       'Heart of Midlothian','Hibernian FC',
        'Aberdeen FC',      'Motherwell FC',    'St Johnstone',     'Livingston FC',
        'Dundee United',    'Kilmarnock FC',    'St Mirren',        'Ross County',
        'Dundee FC',        'Hamilton Academical','Inverness CT',   'Partick Thistle',
        'Dunfermline Ath',  'Queens Park',      'Falkirk FC',       'Airdrieonians FC',
        -- Belgian Pro League (181-200)
        'Club Brugge',      'RSC Anderlecht',   'Standard Liege',   'AA Gent',
        'Royal Antwerp',    'KRC Genk',         'Cercle Brugge',    'Royale Union SG',
        'Westerlo',         'Sint-Truiden',     'AS Eupen',         'KV Mechelen',
        'OH Leuven',        'RWDM Brussels',    'Sporting Charleroi','RFC Seraing',
        'KV Kortrijk',      'Zulte Waregem',    'Beerschot VA',     'Lommel SK'
    ];
    v_cities TEXT[] := ARRAY[
        -- Spanish La Liga
        'Barcelona',      'Madrid',        'Madrid',         'Valencia',
        'Seville',        'Seville',       'Villarreal',     'Bilbao',
        'San Sebastian',  'Vigo',          'Getafe',         'Pamplona',
        'Madrid',         'Almeria',       'Cadiz',          'Girona',
        'Granada',        'Vitoria',       'Valencia',       'Barcelona',
        -- English Premier League
        'Manchester',     'Liverpool',     'London',         'Manchester',
        'London',         'London',        'Newcastle',      'Birmingham',
        'London',         'Brighton',      'Wolverhampton',  'London',
        'London',         'London',        'Liverpool',      'Nottingham',
        'Leicester',      'Leeds',         'Southampton',    'Burnley',
        -- German Bundesliga
        'Dortmund',       'Munich',        'Leipzig',        'Leverkusen',
        'Frankfurt',      'Wolfsburg',     'Freiburg',       'Berlin',
        'Monchengladbach','Stuttgart',     'Sinsheim',       'Augsburg',
        'Cologne',        'Mainz',         'Bochum',         'Darmstadt',
        'Heidenheim',     'Bremen',        'Hamburg',        'Gelsenkirchen',
        -- Italian Serie A
        'Turin',          'Milan',         'Milan',          'Rome',
        'Naples',         'Rome',          'Bergamo',        'Florence',
        'Turin',          'Udine',         'Sassuolo',       'Bologna',
        'Verona',         'Genoa',         'Cagliari',       'Lecce',
        'Monza',          'Empoli',        'La Spezia',      'Cremona',
        -- French Ligue 1
        'Paris',          'Marseille',     'Lyon',           'Monaco',
        'Lille',          'Lens',          'Nice',           'Rennes',
        'Nantes',         'Strasbourg',    'Reims',          'Montpellier',
        'Brest',          'Lorient',       'Clermont-Ferrand','Toulouse',
        'Metz',           'Le Havre',      'Angers',         'Troyes',
        -- Portuguese Primeira Liga
        'Lisbon',         'Porto',         'Lisbon',         'Braga',
        'Guimaraes',      'Porto',         'Estoril',        'Lisbon',
        'Famalicao',      'Pacos de Ferreira','Arouca',      'Chaves',
        'Barcelos',       'Moreira de Conegos','Portimao',   'Ponta Delgada',
        'Vizela',         'Funchal',       'Funchal',        'Amadora',
        -- Dutch Eredivisie
        'Amsterdam',      'Eindhoven',     'Rotterdam',      'Alkmaar',
        'Enschede',       'Utrecht',       'Arnhem',         'Groningen',
        'Heerenveen',     'Rotterdam',     'Nijmegen',       'Sittard',
        'Waalwijk',       'Leeuwarden',    'Emmen',          'Zwolle',
        'Deventer',       'Rotterdam',     'Almelo',         'Tilburg',
        -- Turkish Super Lig
        'Istanbul',       'Istanbul',      'Istanbul',       'Trabzon',
        'Bursa',          'Istanbul',      'Konya',          'Sivas',
        'Antalya',        'Kayseri',       'Alanya',         'Gaziantep',
        'Hatay',          'Rize',          'Istanbul',       'Istanbul',
        'Ankara',         'Istanbul',      'Adana',          'Giresun',
        -- Scottish Premiership
        'Glasgow',        'Glasgow',       'Edinburgh',      'Edinburgh',
        'Aberdeen',       'Motherwell',    'Perth',          'Livingston',
        'Dundee',         'Kilmarnock',    'Paisley',        'Dingwall',
        'Dundee',         'Hamilton',      'Inverness',      'Glasgow',
        'Dunfermline',    'Glasgow',       'Falkirk',        'Airdrie',
        -- Belgian Pro League
        'Bruges',         'Brussels',      'Liege',          'Ghent',
        'Antwerp',        'Genk',          'Bruges',         'Brussels',
        'Westerlo',       'Sint-Truiden',  'Eupen',          'Mechelen',
        'Leuven',         'Brussels',      'Charleroi',      'Seraing',
        'Kortrijk',       'Waregem',       'Antwerp',        'Lommel'
    ];
    v_countries TEXT[] := ARRAY[
        -- Spanish La Liga
        'Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain',
        'Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain','Spain',
        -- English Premier League
        'England','England','England','England','England','England','England','England',
        'England','England','England','England','England','England','England','England',
        'England','England','England','England',
        -- German Bundesliga
        'Germany','Germany','Germany','Germany','Germany','Germany','Germany','Germany',
        'Germany','Germany','Germany','Germany','Germany','Germany','Germany','Germany',
        'Germany','Germany','Germany','Germany',
        -- Italian Serie A
        'Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy',
        'Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy','Italy',
        -- French Ligue 1
        'France','France','France','France','France','France','France','France','France','France',
        'France','France','France','France','France','France','France','France','France','France',
        -- Portuguese Primeira Liga
        'Portugal','Portugal','Portugal','Portugal','Portugal','Portugal','Portugal','Portugal',
        'Portugal','Portugal','Portugal','Portugal','Portugal','Portugal','Portugal','Portugal',
        'Portugal','Portugal','Portugal','Portugal',
        -- Dutch Eredivisie
        'Netherlands','Netherlands','Netherlands','Netherlands','Netherlands','Netherlands',
        'Netherlands','Netherlands','Netherlands','Netherlands','Netherlands','Netherlands',
        'Netherlands','Netherlands','Netherlands','Netherlands','Netherlands','Netherlands',
        'Netherlands','Netherlands',
        -- Turkish Super Lig
        'Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey',
        'Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey','Turkey',
        -- Scottish Premiership
        'Scotland','Scotland','Scotland','Scotland','Scotland','Scotland','Scotland','Scotland',
        'Scotland','Scotland','Scotland','Scotland','Scotland','Scotland','Scotland','Scotland',
        'Scotland','Scotland','Scotland','Scotland',
        -- Belgian Pro League
        'Belgium','Belgium','Belgium','Belgium','Belgium','Belgium','Belgium','Belgium',
        'Belgium','Belgium','Belgium','Belgium','Belgium','Belgium','Belgium','Belgium',
        'Belgium','Belgium','Belgium','Belgium'
    ];
    v_stadiums TEXT[] := ARRAY[
        -- Spanish La Liga
        'Camp Nou',             'Santiago Bernabeu',    'Metropolitano',        'Mestalla',
        'Ramon Sanchez-Pizjuan','Benito Villamarin',    'Estadio Ceramica',     'San Mames',
        'Reale Arena',          'Balaidos',             'Coliseum A. Perez',    'El Sadar',
        'Estadio Vallecas',     'Power Horse Stadium',  'Nuevo Mirandilla',     'Montilivi',
        'Nuevo Los Carmenes',   'Mendizorroza',         'Estadio Ciutat',       'RCDE Stadium',
        -- English Premier League
        'Etihad Stadium',       'Anfield',              'Emirates Stadium',     'Old Trafford',
        'Stamford Bridge',      'Tottenham Hotspur Std','St James Park',        'Villa Park',
        'London Stadium',       'Amex Stadium',         'Molineux',             'Selhurst Park',
        'Gtech Community Std',  'Craven Cottage',       'Goodison Park',        'City Ground',
        'King Power Stadium',   'Elland Road',          'St Marys Stadium',     'Turf Moor',
        -- German Bundesliga
        'Signal Iduna Park',    'Allianz Arena',        'Red Bull Arena',       'BayArena',
        'Deutsche Bank Park',   'Volkswagen Arena',     'Europa-Park Stadion',  'Alte Forsterei',
        'Borussia-Park',        'MHPArena',             'PreZero Arena',        'WWK Arena',
        'RheinEnergieStadion',  'MEWA Arena',           'Vonovia Ruhrstadion',  'Merck-Stadion',
        'Voith-Arena',          'Weserstadion',         'Volksparkstadion',     'Veltins-Arena',
        -- Italian Serie A
        'Juventus Stadium',     'San Siro',             'San Siro',             'Stadio Olimpico',
        'Diego Armando Maradona','Stadio Olimpico',     'Gewiss Stadium',       'Artemio Franchi',
        'Grande Torino',        'Dacia Arena',          'Mapei Stadium',        'Renato Dall''Ara',
        'M. Bentegodi',         'Luigi Ferraris',       'Unipol Domus',         'Via del Mare',
        'U-Power Stadium',      'Carlo Castellani',     'Alberto Picco',        'Giovanni Zini',
        -- French Ligue 1
        'Parc des Princes',     'Orange Velodrome',     'Groupama Stadium',     'Stade Louis II',
        'Stade Pierre-Mauroy',  'Stade Bollaert-Delelis','Allianz Riviera',     'Roazhon Park',
        'Stade de la Beaujoire','Stade de la Meinau',   'Stade Auguste-Delaune','Stade de la Mosson',
        'Stade Francis-Le Ble', 'Stade du Moustoir',   'Stade Gabriel-Montpied','Stadium de Toulouse',
        'Stade Saint-Symphorien','Stade Oceane',        'Stade Raymond-Kopa',   'Stade de l''Aube',
        -- Portuguese Primeira Liga
        'Estadio da Luz',       'Estadio do Dragao',    'Estadio Jose Alvalade','Estadio Municipal Braga',
        'Estadio Dom A. Henriques','Estadio do Bessa',  'Estadio A. Coimbra Mota','Estadio Pina Manique',
        'Estadio Municipal Famalicao','Estadio Capital do Movel','Estadio Municipal Arouca','Estadio M. Branco Teixeira',
        'Estadio Cidade de Barcelos','Estadio Com. J. Freitas','Estadio Municipal Portimao','Estadio de Sao Miguel',
        'Estadio do FC Vizela', 'Estadio dos Barreiros','Estadio da Madeira',   'Estadio Jose Gomes',
        -- Dutch Eredivisie
        'Johan Cruijff ArenA',  'Philips Stadion',      'De Kuip',              'AFAS Stadion',
        'Grolsch Veste',        'Stadion Galgenwaard',  'GelreDome',            'Euroborg',
        'Abe Lenstra Stadion',  'Het Kasteel',          'Goffertstadion',       'Fortuna Sittard Stadion',
        'Mandemakers Stadion',  'Cambuur Stadion',      'De Oude Meerdijk',     'MAC3Park Stadion',
        'De Adelaarshorst',     'Van Donge De Roo Stad.','Polman Stadion',      'Koning Willem II Stad.',
        -- Turkish Super Lig
        'Nef Stadium',          'Sukru Saracoglu',      'Vodafone Park',        'Senol Gunes Stadyumu',
        'Timsah Arena',         'Basaksehir F.T. Stad.','Konya Buyuksehir Stad.','Sivas 4 Eylul Stad.',
        'Antalya Stadyumu',     'Kadir Has Stadyumu',   'Bahcesehir Ok. Stad.', 'Kalyon Stadyumu',
        'Hatay Stadyumu',       'Caykur Didi Stadyumu', 'Recep T. Erdogan Stad.','Olimpiyat Stadyumu',
        'Eryaman Stadyumu',     'Pendik Stadyumu',      'Yeni Adana Stadyumu',  'Giresun Stadyumu',
        -- Scottish Premiership
        'Celtic Park',          'Ibrox Stadium',        'Tynecastle Park',      'Easter Road',
        'Pittodrie Stadium',    'Fir Park',             'McDiarmid Park',       'Tony Macaroni Arena',
        'Tannadice Park',       'Rugby Park',           'SMiSA Stadium',        'Global Energy Stadium',
        'Dens Park',            'New Douglas Park',     'Caledonian Stadium',   'Firhill Stadium',
        'East End Park',        'Hampden Park',         'The Falkirk Stadium',  'Excelsior Stadium',
        -- Belgian Pro League
        'Jan Breydel Stadium',  'Lotto Park',           'Stade Maurice Dufrasne','Ghelamco Arena',
        'Bosuilstadion',        'Cegeka Arena',         'Jan Breydel Stadium',  'Joseph Marien Stadium',
        'Het Kuipje',           'Stayen',               'Kehrweg Stadion',      'AFAS Stadion Mechelen',
        'Den Dreef',            'Edmond Machtens',      'Stade Pays de Charleroi','Stade du Pairay',
        'Guldensporenstadion',  'Elindus Arena',        'Bosuilstadion',        'Soevereinenstadion'
    ];
    v_capacities INT[] := ARRAY[
        -- Spanish La Liga
        99354, 81044, 68456, 49430,
        43883, 60721, 23500, 53289,
        39500, 29000, 17700, 23576,
        14708, 15000, 22000, 13500,
        19336, 19840, 25354, 40000,
        -- English Premier League
        53400, 61000, 60704, 74310,
        40834, 62850, 52200, 42682,
        62500, 31800, 31750, 25486,
        17250, 25700, 39414, 30455,
        32261, 37792, 32505, 21944,
        -- German Bundesliga
        81365, 75024, 47069, 30210,
        58000, 30000, 34700, 22012,
        54057, 60441, 30150, 30660,
        50000, 34034, 27599, 17000,
        15000, 42100, 57000, 62271,
        -- Italian Serie A
        41507, 75923, 75923, 72698,
        54726, 72698, 21300, 43147,
        27958, 25144, 21525, 38279,
        39211, 36534, 16416, 33876,
        18568, 16284, 12218, 20010,
        -- French Ligue 1
        47929, 67394, 59186, 18523,
        49712, 38223, 35624, 29778,
        35322, 29228, 20900, 32900,
        15097, 18930, 11980, 33150,
        25000, 25178, 18542, 19680,
        -- Portuguese Primeira Liga
        65647, 50476, 50095, 30286,
        30171, 28263,  8000,  8000,
         8000,  8000,  8000,  8000,
        11982,  6500, 12504, 12000,
         6500,  8000,  5132, 10500,
        -- Dutch Eredivisie
        54900, 35000, 51117, 17023,
        30205, 24500, 21225, 22329,
        26100, 11000, 12500, 12500,
         7500, 10000,  9000, 12500,
         8000,  4000, 12500, 14700,
        -- Turkish Super Lig
        52652, 50530, 41903, 40800,
        43332, 17319, 42276, 15900,
        32527, 32864, 11200, 33600,
        23000, 12500, 15500, 75735,
        19209, 15000, 25000,  8500,
        -- Scottish Premiership
        60411, 50817, 20099, 20421,
        20866, 13742, 10673, 10005,
        14223, 17899,  7882,  6618,
        11506,  5765,  7750, 10102,
        11998, 25233,  7939, 10101,
        -- Belgian Pro League
        29042, 26000, 27670, 20000,
        16190, 23718, 29042,  8000,
         8000, 14600,  8000, 13000,
        10000,  8000, 15000,  8000,
         9399,  8000, 12000,  8000
    ];

    -- Player name pools
    v_first_names TEXT[] := ARRAY[
        'Carlos','Miguel','Juan','Luis','Fernando',
        'Pedro','Roberto','Diego','Marco','Alexis',
        'David','Marc','Sergio','Jordi','Pablo',
        'Antoine','Kevin','Thomas','Lucas','Enzo',
        'Luka','Ivan','Mario','Andres','Alvaro'
    ];
    v_last_names TEXT[] := ARRAY[
        'Garcia','Martinez','Lopez','Sanchez','Gonzalez',
        'Perez','Rodriguez','Hernandez','Jimenez','Ramirez',
        'Torres','Flores','Morales','Cruz','Reyes',
        'Suarez','Vargas','Mendoza','Castillo','Vega',
        'Costa','Silva','Santos','Lima','Ferreira'
    ];
    v_nationalities TEXT[] := ARRAY[
        'Spanish','Brazilian','Argentine','French','German',
        'Portuguese','English','Dutch','Croatian','Colombian',
        'Uruguayan','Senegalese','Moroccan','Italian','Belgian'
    ];
    -- Position distribution: 3 GK, 7 DEF, 9 MID, 6 FWD = 25 per squad
    v_positions TEXT[] := ARRAY[
        'GK','GK','GK',
        'DEF','DEF','DEF','DEF','DEF','DEF','DEF',
        'MID','MID','MID','MID','MID','MID','MID','MID','MID',
        'FWD','FWD','FWD','FWD','FWD','FWD'
    ];
    -- Goal type distribution: ~72% normal, ~14% penalty, ~14% free_kick
    v_goal_types TEXT[] := ARRAY[
        'normal','normal','normal','normal','normal','penalty','free_kick'
    ];

    -- Season computed on the fly
    v_season_year   INT;
    v_season_name   TEXT;
    v_season_start  DATE;
    v_season_end    DATE;

    -- Working variables
    v_club_ids     INT[];
    v_home_players INT[];
    v_away_players INT[];
    v_home_id      INT;
    v_away_id      INT;
    v_match_id     INT;
    v_season_id    INT;
    v_home_goals   INT;
    v_away_goals   INT;
    v_scorer       INT;
    v_assister     INT;
    v_season_days  INT;
    v_r            DOUBLE PRECISION;

    -- Loop indices
    l_idx INT;  -- league index (0=Spanish, 1=English, 2=German)
    s_idx INT;
    h_idx INT;
    a_idx INT;
    g_idx INT;
    c_idx INT;
BEGIN
    PERFORM setseed(0.42);

    -- -------------------------------------------------------------------------
    -- Clubs (200 total: 20 clubs per league x 10 leagues)
    -- -------------------------------------------------------------------------
    FOR h_idx IN 1..200 LOOP
        INSERT INTO relational.clubs (name, city, country, founded, stadium, capacity)
        VALUES (
            v_club_names[h_idx],
            v_cities[h_idx],
            v_countries[h_idx],
            1880 + (random() * 110)::INT,
            v_stadiums[h_idx],
            v_capacities[h_idx]
        );
    END LOOP;

    SELECT ARRAY_AGG(club_id ORDER BY club_id) INTO v_club_ids
    FROM relational.clubs;

    -- -------------------------------------------------------------------------
    -- Players (25 per club, 5000 total)
    -- -------------------------------------------------------------------------
    FOR h_idx IN 1..200 LOOP
        FOR a_idx IN 1..25 LOOP
            INSERT INTO relational.players
                (first_name, last_name, birth_date, nationality, position, club_id)
            VALUES (
                v_first_names[1 + (random() * 24)::INT],
                v_last_names [1 + (random() * 24)::INT],
                '1990-01-01'::DATE + (random() * 4015)::INT,   -- born 1990-2001
                v_nationalities[1 + (random() * 14)::INT],
                v_positions[a_idx],
                v_club_ids[h_idx]
            );
        END LOOP;
    END LOOP;

    -- -------------------------------------------------------------------------
    -- Seasons (1975/76 through 2024/25, generated dynamically)
    -- Each season: starts 12-Aug of year Y, ends 4-Jun of year Y+1
    -- -------------------------------------------------------------------------
    FOR s_idx IN 0..49 LOOP
        v_season_year  := 1975 + s_idx;
        v_season_name  := v_season_year::TEXT || '/'
                          || LPAD(((v_season_year % 100 + 1) % 100)::TEXT, 2, '0');
        v_season_start := make_date(v_season_year,     8, 12);
        v_season_end   := make_date(v_season_year + 1, 6,  4);
        INSERT INTO relational.seasons (name, start_date, end_date)
        VALUES (v_season_name, v_season_start, v_season_end);
    END LOOP;

    -- -------------------------------------------------------------------------
    -- Matches, Goals, and Cards
    -- 10 leagues x 20 clubs x 19 opponents x 50 seasons = 190000 matches
    -- -------------------------------------------------------------------------
    FOR s_idx IN 0..49 LOOP
        v_season_year  := 1975 + s_idx;
        v_season_name  := v_season_year::TEXT || '/'
                          || LPAD(((v_season_year % 100 + 1) % 100)::TEXT, 2, '0');
        v_season_start := make_date(v_season_year,     8, 12);
        v_season_end   := make_date(v_season_year + 1, 6,  4);
        v_season_days  := v_season_end - v_season_start;

        SELECT season_id INTO v_season_id
        FROM relational.seasons WHERE name = v_season_name;

        -- Iterate over each of the 10 leagues (offset 0,20,40,...180 in v_club_ids)
        FOR l_idx IN 0..9 LOOP

        FOR h_idx IN 1..20 LOOP
            FOR a_idx IN 1..20 LOOP
                CONTINUE WHEN h_idx = a_idx;

                v_home_id := v_club_ids[l_idx * 20 + h_idx];
                v_away_id := v_club_ids[l_idx * 20 + a_idx];

                -- Score generation (slight home advantage)
                v_r := random();
                v_home_goals := CASE
                    WHEN v_r < 0.22 THEN 0
                    WHEN v_r < 0.52 THEN 1
                    WHEN v_r < 0.76 THEN 2
                    WHEN v_r < 0.92 THEN 3
                    ELSE 4
                END;

                v_r := random();
                v_away_goals := CASE
                    WHEN v_r < 0.28 THEN 0
                    WHEN v_r < 0.58 THEN 1
                    WHEN v_r < 0.80 THEN 2
                    WHEN v_r < 0.95 THEN 3
                    ELSE 4
                END;

                INSERT INTO relational.matches
                    (season_id, home_club_id, away_club_id, match_date, attendance,
                     home_goals, away_goals)
                VALUES (
                    v_season_id,
                    v_home_id,
                    v_away_id,
                    v_season_start + (random() * v_season_days)::INT,
                    GREATEST(8000,
                        (v_capacities[l_idx * 20 + h_idx] * (0.60 + random() * 0.40))::INT),
                    v_home_goals,
                    v_away_goals
                )
                RETURNING match_id INTO v_match_id;

                -- Players eligible to score: MID and FWD
                SELECT ARRAY_AGG(player_id ORDER BY random())
                INTO v_home_players
                FROM relational.players
                WHERE club_id = v_home_id AND position IN ('MID','FWD');

                SELECT ARRAY_AGG(player_id ORDER BY random())
                INTO v_away_players
                FROM relational.players
                WHERE club_id = v_away_id AND position IN ('MID','FWD');

                -- Home goals
                FOR g_idx IN 1..v_home_goals LOOP
                    v_scorer := v_home_players[
                        1 + (random() * (array_length(v_home_players,1) - 1))::INT
                    ];
                    v_assister := NULL;
                    IF random() > 0.28 THEN
                        v_assister := v_home_players[
                            1 + (random() * (array_length(v_home_players,1) - 1))::INT
                        ];
                        IF v_assister = v_scorer THEN v_assister := NULL; END IF;
                    END IF;

                    INSERT INTO relational.goals
                        (match_id, scorer_id, assist_id, club_id, minute, goal_type)
                    VALUES (
                        v_match_id, v_scorer, v_assister, v_home_id,
                        1 + (random() * 89)::INT,
                        v_goal_types[1 + (random() * 6)::INT]
                    );
                END LOOP;

                -- Away goals
                FOR g_idx IN 1..v_away_goals LOOP
                    v_scorer := v_away_players[
                        1 + (random() * (array_length(v_away_players,1) - 1))::INT
                    ];
                    v_assister := NULL;
                    IF random() > 0.28 THEN
                        v_assister := v_away_players[
                            1 + (random() * (array_length(v_away_players,1) - 1))::INT
                        ];
                        IF v_assister = v_scorer THEN v_assister := NULL; END IF;
                    END IF;

                    INSERT INTO relational.goals
                        (match_id, scorer_id, assist_id, club_id, minute, goal_type)
                    VALUES (
                        v_match_id, v_scorer, v_assister, v_away_id,
                        1 + (random() * 89)::INT,
                        v_goal_types[1 + (random() * 6)::INT]
                    );
                END LOOP;

                -- Cards: use DEF, MID, FWD players (not GK)
                SELECT ARRAY_AGG(player_id ORDER BY random())
                INTO v_home_players
                FROM relational.players
                WHERE club_id = v_home_id AND position IN ('DEF','MID','FWD');

                SELECT ARRAY_AGG(player_id ORDER BY random())
                INTO v_away_players
                FROM relational.players
                WHERE club_id = v_away_id AND position IN ('DEF','MID','FWD');

                -- Home cards (1-3 per match)
                FOR c_idx IN 1..(1 + (random() * 2)::INT) LOOP
                    INSERT INTO relational.cards
                        (match_id, player_id, club_id, card_type, minute)
                    VALUES (
                        v_match_id,
                        v_home_players[
                            1 + (random() * (array_length(v_home_players,1) - 1))::INT
                        ],
                        v_home_id,
                        CASE WHEN random() > 0.88 THEN 'red' ELSE 'yellow' END,
                        1 + (random() * 89)::INT
                    );
                END LOOP;

                -- Away cards (1-3 per match)
                FOR c_idx IN 1..(1 + (random() * 2)::INT) LOOP
                    INSERT INTO relational.cards
                        (match_id, player_id, club_id, card_type, minute)
                    VALUES (
                        v_match_id,
                        v_away_players[
                            1 + (random() * (array_length(v_away_players,1) - 1))::INT
                        ],
                        v_away_id,
                        CASE WHEN random() > 0.88 THEN 'red' ELSE 'yellow' END,
                        1 + (random() * 89)::INT
                    );
                END LOOP;

            END LOOP; -- a_idx (away club)
        END LOOP;     -- h_idx (home club)
        END LOOP;     -- l_idx (league 0..9)
    END LOOP;         -- s_idx (0..49, seasons 1975/76-2024/25)

    RAISE NOTICE 'Data generation complete:';
    RAISE NOTICE '  Clubs:   %', (SELECT COUNT(*) FROM relational.clubs);
    RAISE NOTICE '  Players: %', (SELECT COUNT(*) FROM relational.players);
    RAISE NOTICE '  Seasons: %', (SELECT COUNT(*) FROM relational.seasons);
    RAISE NOTICE '  Matches: %', (SELECT COUNT(*) FROM relational.matches);
    RAISE NOTICE '  Goals:   %', (SELECT COUNT(*) FROM relational.goals);
    RAISE NOTICE '  Cards:   %', (SELECT COUNT(*) FROM relational.cards);
END;
$$;

-- Cluster relational tables so rows with the same season/match/player
-- are physically adjacent — improves analytical scan performance.
CLUSTER relational.matches USING idx_matches_season;
CLUSTER relational.goals   USING idx_goals_match;
CLUSTER relational.cards   USING idx_cards_player;

-- Update statistics for the query planner after clustering
ANALYZE relational.clubs;
ANALYZE relational.players;
ANALYZE relational.seasons;
ANALYZE relational.matches;
ANALYZE relational.goals;
ANALYZE relational.cards;
