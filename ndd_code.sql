USE ndd;

-- 1. Write a query that finds all interactions with a confidence value of at least (0.80).
	SELECT *
	FROM interaction
	WHERE confidence_value >= 0.80;


-- 2. Write a query that gets each disease and its corresponding genes. Include the disease_id, gene_a, gene_b, and pos_interaction columns in your query.
	SELECT disease.disease_id, gene.molecule_a AS 'gene_a', gene.molecule_b AS 'gene_b', gene.positive_interaction
	FROM disease
	JOIN gene ON disease.disease_id = gene.disease_id;


-- 3. Write a query that retrieves the two most popular host organisms for Parkinson's disease.
SELECT host_organism, COUNT(*) AS num_times_appeared
FROM interaction
WHERE disease_id = (SELECT disease_id FROM disease WHERE disease_id = 3)
GROUP BY host_organism
ORDER BY num_times_appeared DESC
LIMIT 2;


-- 4. Write a query that orders the diseases from greatest to least (in terms of positively associated genes).
SELECT d.disease_id, COUNT(*) AS num_positive_genes
FROM disease d
JOIN gene g ON d.disease_id = g.disease_id
WHERE g.positive_interaction = 1
GROUP BY d.disease_id
ORDER BY num_positive_genes DESC;


-- 5. Order the interaction types from most popular to least popular for each disease.
SELECT disease_id, interaction_type, COUNT(*) AS interaction_count
FROM interaction
GROUP BY disease_id, interaction_type
ORDER BY disease_id, interaction_count DESC;


-- 6. Write a query that gets the receptor sources that appear less than 50 times in the table.
SELECT receptor.disease_id, receptor.source, COUNT(*) AS receptor_source_count
FROM receptor
GROUP BY receptor.source, receptor.disease_id
HAVING receptor_source_count < 50
ORDER BY receptor_source_count DESC;


-- 7. Find the set of proteins that are associated with all three diseases (i.e. found in the records of all three diseases).
SELECT molecule_a as 'protein_a', molecule_b as 'protein_b'
FROM gene
GROUP BY protein_a, protein_b
HAVING COUNT(DISTINCT disease_id) = 3;


-- 8. What receptors (and their corresponding ligands) are associated with Huntington’s and Parkinson’s diseases?
SELECT receptor.receptor_id, receptor.pdb_id, receptor.source, receptor.class, receptor.ligands, disease.disease_name
FROM receptor
JOIN disease ON receptor.disease_id = disease.disease_id
WHERE disease.disease_name IN ('Huntington’s', 'Parkinson’s');


-- 9. Write a query that calculates the average confidence value for each disease, for all records with a
-- confidence value of at least (0.80).
SELECT AVG(confidence_value) AS 'avg_confidence', disease.disease_name
FROM interaction
LEFT JOIN disease ON (interaction.disease_id = disease.disease_id)
WHERE interaction.confidence_value >= 0.80
GROUP BY disease.disease_name;


-- 10. What are the interactions involved with Alzheimer’s disease whose host organism is any cell from the human
-- body, ordered by the number of occurrences of each host organism (based on the conditions)?
SELECT interaction.host_organism, COUNT(*) AS 'num_host_occurrences'
FROM interaction
WHERE interaction.disease_id = (SELECT disease_id FROM disease WHERE disease.disease_id = 2)
    AND interaction.host_organism LIKE '%Homo sapiens%'
GROUP BY interaction.host_organism
ORDER BY num_host_occurrences DESC;


-- 11. Write a query that finds the interactors for Alzheimer's disease whose species does not contain the keywords 'Homo sapiens'.
SELECT disease_id, name, type AS interactor_type, species, description
FROM interactor
WHERE species NOT LIKE '%Homo sapiens%' AND disease_id = 1
GROUP BY interactor_id, name, type, species, description
ORDER BY name;


-- 12. What are the top two most common receptor sources and classes for each of the two diseases mentioned in this question (Alzheimer's and Parkinson's)?
SELECT disease.disease_id, receptor.source AS receptor_source, receptor.class AS receptor_class, COUNT(*) AS 'occurrence_count'
FROM receptor
JOIN disease ON receptor.disease_id = disease.disease_id
WHERE disease.disease_id = 1 OR disease.disease_id = 3
GROUP BY disease.disease_id, receptor.source, receptor.class
ORDER BY occurrence_count DESC
LIMIT 4;


-- 13. Write a query that determines the most studied disease, by ordering the number of interactions from greatest to least.
SELECT
    disease.disease_name,
    COUNT(DISTINCT interaction.interaction_id) AS 'num_interactions'
FROM disease
LEFT JOIN interaction ON disease.disease_id = interaction.disease_id
GROUP BY disease.disease_name
ORDER BY num_interactions DESC;


-- 14. Write a trigger that prevents a gene with the same molecules from being inserted again (i.e. prevents gene duplication in the database).
DELIMITER //
DROP TRIGGER IF EXISTS prevent_duplicate_genes;
CREATE TRIGGER prevent_duplicate_genes
BEFORE INSERT ON gene
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM gene WHERE molecule_a = NEW.molecule_a AND molecule_b = NEW.molecule_b) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate genes cannot be added to the gene table.';
    END IF;
END;
//
DELIMITER ;

-- Test cases for the trigger:
-- Test case 1: Inserting a new gene (should pass)
INSERT INTO gene (gene_id, disease_id, molecule_a, molecule_b, type_a, type_b, host_organism, positive_interaction)
VALUES (2388, 3, 'EIF4A3', 'MAGOH', 'protein', 'protein', 'In vitro', 0);

-- Query to delete the newly inserted gene, for data consistency purposes.
DELETE FROM gene
ORDER BY gene_id DESC
LIMIT 1;

-- Test case 2: Inserting a duplicate gene (should fail)
INSERT INTO gene (gene_id, disease_id, molecule_a, molecule_b, type_a, type_b, host_organism, positive_interaction)
VALUES (2288, 3, 'RPS3', 'il8_human_gene', 'protein', 'gene', 'Homo sapiens Jurkat', 1);



-- 15. Write a stored procedure that can obtain relevant gene information about a particular gene (when the gene_id is provided as a parameter).
-- Assuming gene_id is the primary key
DELIMITER //
DROP PROCEDURE IF EXISTS GetGeneInformation;
CREATE PROCEDURE GetGeneInformation(IN gene_id_param INT)
BEGIN
    SELECT *
    FROM gene
    WHERE gene_id = gene_id_param;
END;
//
DELIMITER ;

-- Test cases for the stored procedure:
-- Test case 1: Calling a gene that exists in the gene table (should pass)
call GetGeneInformation(857);

-- Test case 2: Calling a gene that does not exist in the gene table (should not return any record)
call GetGeneInformation(4536);
