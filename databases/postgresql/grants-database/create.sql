-- Create Grants table
CREATE TABLE IF NOT EXISTS Grants (
    idgrant      SERIAL PRIMARY KEY,
    title        VARCHAR(255) NOT NULL,
    source       VARCHAR(255),
    starting     DATE,
    ending       DATE,
    amount       DECIMAL(10, 2)
);

-- Create Professors table
CREATE TABLE IF NOT EXISTS Professors (
    ssnProfessor VARCHAR(20) PRIMARY KEY,
    name         VARCHAR(255) NOT NULL
);

-- Create Participate table
-- DROP TABLE Participate
CREATE TABLE IF NOT EXISTS Participate (
    idparticipate SERIAL PRIMARY KEY,
    idgrant       INT NOT NULL,
    ssnProfessor   VARCHAR(20) NOT NULL,
    FOREIGN KEY (idgrant)     REFERENCES Grants(idgrant),
    FOREIGN KEY (ssnProfessor) REFERENCES Professors(ssnProfessor)
);

-- Create Emails table
CREATE TABLE IF NOT EXISTS Emails (
    idemail      SERIAL PRIMARY KEY,
    email        VARCHAR(255) NOT NULL,
    ssnProfessor VARCHAR(20) NOT NULL,
    FOREIGN KEY (ssnProfessor) REFERENCES Professors(ssnProfessor)
);

-- Create Students table
CREATE TABLE IF NOT EXISTS Students (

    dni          VARCHAR(20) PRIMARY KEY,
    graduate     BOOLEAN,
    idgrant      INT NOT NULL,
    ssnProfessor VARCHAR(20) NOT NULL,
    FOREIGN KEY (idgrant)      REFERENCES Grants(idgrant),
    FOREIGN KEY (ssnProfessor) REFERENCES Professors(ssnProfessor)
);


INSERT INTO professors(ssnProfessor, name) VALUES (1,'Felipe Jimenez');

INSERT INTO professors(ssnProfessor, name) VALUES (2,'Andrea Martinez');


INSERT INTO grants (idgrant, title, source, starting, ending, amount)
VALUES (111,'Subvention for teaching material', 'Aragon Government','2019-06-22 12:00:00','2022-06-22 23:59:00', 2000.0);
INSERT INTO grants (idgrant, title, source, starting, ending, amount)
VALUES (222,'Grant for courses', 'Universidad San Jorge','2020-09-15 00:00:00','2020-06-30 23:59:00', 800.0);
INSERT INTO grants (idgrant, title, source, starting, ending, amount)
VALUES (333,'Subvention for conferences', 'Ministry of Economy and Competitiveness','2020-01-01 08:00:00','2024-12-31 23:59:00', 10000.0);
