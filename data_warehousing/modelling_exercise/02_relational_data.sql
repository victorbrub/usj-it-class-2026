-- Author: Víctor Barceló
-- =============================================================================
-- Relational Model - Data Population
-- =============================================================================
-- Generates realistic football league data:
--   20 clubs, 500 players, 15 seasons (2010/11-2024/25),
--   5700 matches, ~16000 goals, ~34000 cards
-- Uses a fixed random seed (0.42) for reproducibility.
-- =============================================================================

DO $$
DECLARE
    -- Club data arrays (20 Spanish-league-style clubs)
    v_club_names TEXT[] := ARRAY[
        'FC Barcelona',   'Real Madrid CF',  'Atletico Madrid', 'Valencia CF',
        'Sevilla FC',     'Real Betis',      'Villarreal CF',   'Athletic Club',
        'Real Sociedad',  'Celta Vigo',      'Getafe CF',       'Osasuna',
        'Rayo Vallecano', 'UD Almeria',      'Cadiz CF',        'Girona FC',
        'Granada CF',     'Deportivo Alaves','Levante UD',      'Espanyol'
    ];
    v_cities TEXT[] := ARRAY[
        'Barcelona',  'Madrid',      'Madrid',    'Valencia',
        'Seville',    'Seville',     'Villarreal','Bilbao',
        'San Sebastian','Vigo',      'Getafe',    'Pamplona',
        'Madrid',     'Almeria',     'Cadiz',     'Girona',
        'Granada',    'Vitoria',     'Valencia',  'Barcelona'
    ];
    v_stadiums TEXT[] := ARRAY[
        'Camp Nou',           'Santiago Bernabeu', 'Metropolitano',     'Mestalla',
        'Ramon Sanchez-Pizjuan','Benito Villamarin','Estadio Ceramica', 'San Mames',
        'Reale Arena',        'Balaidos',          'Coliseum A. Perez', 'El Sadar',
        'Estadio Vallecas',   'Power Horse Stadium','Nuevo Mirandilla',  'Montilivi',
        'Nuevo Los Carmenes', 'Mendizorroza',      'Estadio Ciutat',    'RCDE Stadium'
    ];
    v_capacities INT[] := ARRAY[
        99354, 81044, 68456, 49430,
        43883, 60721, 23500, 53289,
        39500, 29000, 17700, 23576,
        14708, 15000, 22000, 13500,
        19336, 19840, 25354, 40000
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

    -- Season computed on the fly (2010/11 through 2024/25 = 15 seasons)
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
    s_idx INT;
    h_idx INT;
    a_idx INT;
    g_idx INT;
    c_idx INT;
BEGIN
    PERFORM setseed(0.42);

    -- -------------------------------------------------------------------------
    -- Clubs
    -- -------------------------------------------------------------------------
    FOR h_idx IN 1..20 LOOP
        INSERT INTO relational.clubs (name, city, country, founded, stadium, capacity)
        VALUES (
            v_club_names[h_idx],
            v_cities[h_idx],
            'Spain',
            1890 + (random() * 90)::INT,
            v_stadiums[h_idx],
            v_capacities[h_idx]
        );
    END LOOP;

    SELECT ARRAY_AGG(club_id ORDER BY club_id) INTO v_club_ids
    FROM relational.clubs;

    -- -------------------------------------------------------------------------
    -- Players (25 per club, 500 total)
    -- -------------------------------------------------------------------------
    FOR h_idx IN 1..20 LOOP
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
    -- Seasons (2010/11 through 2024/25, generated dynamically)
    -- Each season: starts 12-Aug of year Y, ends 4-Jun of year Y+1
    -- -------------------------------------------------------------------------
    FOR s_idx IN 0..14 LOOP
        v_season_year  := 2010 + s_idx;
        v_season_name  := v_season_year::TEXT || '/'
                          || LPAD(((v_season_year % 100) + 1)::TEXT, 2, '0');
        v_season_start := make_date(v_season_year,     8, 12);
        v_season_end   := make_date(v_season_year + 1, 6,  4);
        INSERT INTO relational.seasons (name, start_date, end_date)
        VALUES (v_season_name, v_season_start, v_season_end);
    END LOOP;

    -- -------------------------------------------------------------------------
    -- Matches, Goals, and Cards
    -- 20 clubs x 19 opponents x 15 seasons = 5700 matches
    -- -------------------------------------------------------------------------
    FOR s_idx IN 0..14 LOOP
        v_season_year  := 2010 + s_idx;
        v_season_name  := v_season_year::TEXT || '/'
                          || LPAD(((v_season_year % 100) + 1)::TEXT, 2, '0');
        v_season_start := make_date(v_season_year,     8, 12);
        v_season_end   := make_date(v_season_year + 1, 6,  4);
        v_season_days  := v_season_end - v_season_start;

        SELECT season_id INTO v_season_id
        FROM relational.seasons WHERE name = v_season_name;

        FOR h_idx IN 1..20 LOOP
            FOR a_idx IN 1..20 LOOP
                CONTINUE WHEN h_idx = a_idx;

                v_home_id := v_club_ids[h_idx];
                v_away_id := v_club_ids[a_idx];

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
                        (v_capacities[h_idx] * (0.60 + random() * 0.40))::INT),
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
    END LOOP;         -- s_idx (0..14, seasons 2010/11-2024/25)

    RAISE NOTICE 'Data generation complete:';
    RAISE NOTICE '  Clubs:   %', (SELECT COUNT(*) FROM relational.clubs);
    RAISE NOTICE '  Players: %', (SELECT COUNT(*) FROM relational.players);
    RAISE NOTICE '  Seasons: %', (SELECT COUNT(*) FROM relational.seasons);
    RAISE NOTICE '  Matches: %', (SELECT COUNT(*) FROM relational.matches);
    RAISE NOTICE '  Goals:   %', (SELECT COUNT(*) FROM relational.goals);
    RAISE NOTICE '  Cards:   %', (SELECT COUNT(*) FROM relational.cards);
END;
$$;

-- Update statistics for the query planner
ANALYZE relational.clubs;
ANALYZE relational.players;
ANALYZE relational.seasons;
ANALYZE relational.matches;
ANALYZE relational.goals;
ANALYZE relational.cards;
