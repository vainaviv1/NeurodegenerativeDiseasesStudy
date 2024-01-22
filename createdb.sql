DROP DATABASE IF EXISTS ndd;
CREATE DATABASE IF NOT EXISTS ndd;
USE ndd;

-- DISEASE
DROP TABLE IF EXISTS disease;
CREATE TABLE disease (
    disease_id int PRIMARY KEY NOT NULL,
    disease_name varchar(50) NOT NULL
);

-- INTERACTOR 
DROP TABLE IF EXISTS interactor;
CREATE TABLE interactor (
	interactor_id int PRIMARY KEY NOT NULL,
	disease_id int NOT NULL,
    accession varchar(20),
    name varchar(50),
    preferred_id varchar(50),
    type varchar(20),
    species varchar(50),
    description varchar(200), 
    -- KEY preferred_id (preferred_id), 
    CONSTRAINT fk_interactor_disease FOREIGN KEY (disease_id) REFERENCES disease (disease_id)
);

-- INTERACTION
DROP TABLE IF EXISTS interaction;
CREATE TABLE interaction (
    interaction_id int PRIMARY KEY NOT NULL,
    disease_id int NOT NULL,
    molecule_a varchar(50),
    molecule_b varchar(50),
	identifier_a varchar(50),
    identifier_b varchar(50),
    species_a varchar(50),
    species_b varchar(50),
    host_organism varchar(100),
    positive_interaction tinyint(1),
    detection_method varchar(50),
    interaction_type varchar(20),
    confidence_value float,
    CONSTRAINT fk_interaction_disease FOREIGN KEY (disease_id) REFERENCES disease (disease_id)
    -- CONSTRAINT fk_interaction_id_a_interactor FOREIGN KEY (identifier_a) REFERENCES interactor (preferred_id),
    -- CONSTRAINT fk_interaction_id_b_interactor FOREIGN KEY (identifier_b) REFERENCES interactor (preferred_id)
);

-- RECEPTOR
DROP TABLE IF EXISTS receptor;
CREATE TABLE receptor (
	receptor_id int PRIMARY KEY NOT NULL,
	disease_id int NOT NULL,
    pdb_id varchar(30) NOT NULL,
    source varchar(50),
    class varchar(50),
    ligands varchar(100),
    CONSTRAINT fk_receptor_disease FOREIGN KEY (disease_id) REFERENCES disease (disease_id)
);

-- GENE
DROP TABLE IF EXISTS gene;
CREATE TABLE gene (
	gene_id int PRIMARY KEY NOT NULL,
	disease_id int NOT NULL,
    molecule_a varchar(50) NOT NULL,
    molecule_b varchar(50),
    type_a varchar(20),
    type_b varchar(20),
    host_organism varchar(100),
    positive_interaction tinyint(1),
    CONSTRAINT fk_gene_disease FOREIGN KEY (disease_id) REFERENCES disease (disease_id)
);

-- Import the data in (change the path name to where your files are located).
set global local_infile=ON;

LOAD DATA LOCAL 
INFILE '/Users/tanisha/Downloads/raw_data/disease.csv'
INTO TABLE disease
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA LOCAL 
INFILE '/Users/tanisha/Downloads/raw_data/interactor.csv'
INTO TABLE interactor
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;


LOAD DATA LOCAL 
INFILE '/Users/tanisha/Downloads/raw_data/interaction.csv'
INTO TABLE interaction
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA LOCAL 
INFILE '/Users/tanisha/Downloads/raw_data/receptor.csv'
INTO TABLE receptor
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA LOCAL 
INFILE '/Users/tanisha/Downloads/raw_data/gene.csv'
INTO TABLE gene
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 ROWS;
