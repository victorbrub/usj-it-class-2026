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

