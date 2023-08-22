/*Queries that provide answers to the questions FROM all projects.*/
SELECT
  *
FROM
  animals
WHERE
  name LIKE '%mon';

SELECT
  name
FROM
  animals
WHERE
  EXTRACT(
    YEAR
    FROM
      date_of_birth
  ) BETWEEN 2016 AND 2019;

SELECT
  name
FROM
  animals
WHERE
  neutered = true
  AND escape_attempts < 3;

SELECT
  date_of_birth
FROM
  animals
WHERE
  name = 'Pikachu'
  OR name = 'Agumon';

SELECT
  name,
  escape_attempts
FROM
  animals
WHERE
  weight_kg > 10.5;

SELECT
  *
FROM
  animals
WHERE
  neutered = 't';

SELECT
  *
FROM
  animals
WHERE
  name != 'Gabumon';

SELECT
  *
FROM
  animals
WHERE
  weight_kg >= 10.4
  AND weight_kg <= 17.3;

-- QUWERY AND UPDATE ANIMALS TABLE
BEGIN;

ALTER TABLE animals
RENAME COLUMN species TO unspecified;

ROLLBACK;

BEGIN;

UPDATE animals
SET
  species = 'digimon'
WHERE
  name LIKE '%mon';

UPDATE animals
SET
  species = 'pokemon'
WHERE
  species ISNULL;

COMMIT;

BEGIN;

DELETE FROM animals;

ROLLBACK;

BEGIN;

DELETE FROM animals
WHERE
  date_of_birth > '2022-01-01';

SAVEPOINT DELETE_JAN;

UPDATE animals
SET
  weight_kg = weight_kg * -1;

ROLLBACK DELETE_JAN;

UPDATE animals
SET
  weight_kg = weight_kg * -1
WHERE
  weight_kg < 0;

COMMIT;

-- How many animals are there?
SELECT
  COUNT(*)
FROM
  animals;

-- How many animals have never tried to escape?
SELECT
  COUNT(*)
FROM
  animals
WHERE
  escape_attempts = 0;

-- What is the average weight of animals?
SELECT
  AVG(weight_kg)
FROM
  animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT
  neutered,
  MAX(escape_attempts)
FROM
  animals
GROUP BY
  neutered;

-- What is the minimum and maximum weight of each type of animal?
SELECT
  MIN(weight_kg),
  MAX(weight_kg),
  species
FROM
  animals
GROUP BY
  species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT
  AVG(escape_attempts),
  species
FROM
  animals
WHERE
  EXTRACT(
    YEAR
    FROM
      date_of_birth
  ) BETWEEN 1990 AND 2000
GROUP BY
  species;

-- QUERY MULTIPLE TABLES(USING JOIN)
-- What animals belong to Melody Pond?
SELECT name, full_name FROM animals as a full JOIN owners as o ON a.id = o.id WHERE o.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT a.name, s.name FROM animals as a full JOIN species as s ON a.species_id = s.id WHERE s.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT o.full_name, a.name FROM animals as a full outer JOIN owners as o ON a.owner_id = o.id;

-- How many animals are there per species?
SELECT s.name, COUNT(a.species_id) FROM animals as a full JOIN species as s ON a.species_id = s.id GROUP BY s.name;

-- List all Digimon owned by Jennifer Orwell.
SELECT a.name, s.name as species, o.full_name FROM animals as a right JOIN species as s ON a.species_id = s.id full JOIN owners as o ON a.owner_id = o.id WHERE s.name = 'Digimon' and o.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
SELECT a.name as pet_name, a.escape_attempts, o.full_name FROM animals as a inner JOIN owners as o ON o.id = a.owner_id WHERE o.full_name = 'Dean Winchester' and a.escape_attempts = 0;

-- Who owns the most animals?
SELECT o.full_name, count(a.owner_id) as animals_count FROM animals as a inner JOIN owners as o ON o.id = a.owner_id GROUP BY o.full_name ORDER BY animals_count DESC;

-------------------------
-- Who was the last animal seen by William Tatcher?
SELECT a.name AS animal_name, vt.date_of_visit AS latest_date, v.name AS vet_name FROM visits vt JOIN animals a ON a.id = vt.animal_id JOIN vets v ON v.id = vt.vet_id WHERE vt.date_of_visit = ( SELECT MAX(date_of_visit) FROM visits WHERE vet_id = (SELECT id FROM vets WHERE name = 'William Tatcher') )
AND v.name = 'William Tatcher';
-- How many different animals did Stephanie Mendez see?
SELECT a.name animal_name,v.name vet_name FROM visits vt JOIN animals a ON a.id = vt.animal_id JOIN vets v ON v.id = vt.vet_id WHERE v.name = 'Stephanie Mendez';
-- List all vets and their specialties, including vets with no specialties.
SELECT v.name vet_name,s.name specialization FROM vets v left JOIN specializations sp ON v.id = sp.vet_id left JOIN species s ON s.id = sp.species_id;
-- List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name animal_name,vt.date_of_visit,v.name vet_name FROM vets v JOIN visits vt ON vt.vet_id = v.id JOIN animals a ON a.id = vt.animal_id WHERE vt.date_of_visit between '2020-04-01' and '2020-08-30' and v.name = 'Stephanie Mendez';
-- What animal has the most visits to vets?
SELECT a.name animal_name,v.name to_vet,count(vt.animal_id) visit_count FROM visits vt JOIN animals a ON a.id = vt.animal_id JOIN vets v ON v.id = vt.vet_id GROUP BY a.name,v.name ORDER BY count(vt.animal_id) DESC limit 1;
-- Who was Maisy Smith's first visit?
SELECT a.name animal_name,v.name vet_name,min(vt.date_of_visit) earliest_date FROM visits vt JOIN animals a ON a.id = vt.animal_id JOIN vets v ON v.id = vt.vet_id WHERE vt.date_of_visit = (SELECT min(date_of_visit) FROM visits WHERE vet_id = (SELECT id FROM vets WHERE name = 'Maisy Smith')) GROUP BY a.name,v.name;
-- Details for most recent visit: animal information, vet information, and date of visit.
SELECT a.name Animal_name,a.date_of_birth Animal_DOB,a.escape_attempts Animal_Escape_Attempts,a.neutered Animal_Neutered,a.weight_kg Animal_Weight_Kg,v.name Vet_Name,v.date_of_graduation Vet_date_of_graduation,vt.date_of_visit Date_Of_Visit FROM visits vt JOIN animals a ON a.id = vt.animal_id JOIN vets v ON v.id = vt.vet_id WHERE vt.date_of_visit = (SELECT max(date_of_visit) FROM visits);
-- How many visits were with a vet that did not specialize in that animal's species?
SELECT v.name,count(vt.vet_id) FROM visits vt JOIN vets v ON v.id = vt.vet_id WHERE vt.vet_id = (SELECT id FROM vets v left JOIN specializations sp ON v.id = sp.vet_id WHERE vet_id is null) GROUP BY v.name;
-- What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT v.name vet_name,count(*) visit_count,s.name should_specialize_in FROM visits vt JOIN vets v ON v.id = vt.vet_id JOIN animals a ON a.id = vt.animal_id JOIN species s ON a.species_id = s.id WHERE v.name = 'Maisy Smith' GROUP BY v.name,s.name ORDER BY visit_count DESC;

-------------------------

EXPLAIN ANALYZE SELECT COUNT(*) FROM visits where animal_id = 4;
CREATE INDEX animal_id_asc ON visits(animal_id ASC);
DROP INDEX animal_id_asc;

EXPLAIN ANALYZE SELECT * FROM visits where vet_id = 2;
CREATE INDEX vet_id_asc ON visits(vet_id ASC);
DROP INDEX vet_id_asc;
