/*Queries that provide answers to the questions from all projects.*/
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
where
  name LIKE '%mon';

UPDATE animals
SET
  species = 'pokemon'
where
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
SELECT name, full_name FROM animals as a full join owners as o on a.id = o.id where o.full_name = 'Melody Pond';

-- List of all animals that are pokemon (their type is Pokemon).
SELECT a.name, s.name FROM animals as a full join species as s on a.species_id = s.id where s.name = 'Pokemon';

-- List all owners and their animals, remember to include those that don't own any animal.
SELECT o.full_name, a.name from animals as a full outer join owners as o on a.owner_id = o.id;

-- How many animals are there per species?
SELECT s.name, COUNT(a.species_id) FROM animals as a full join species as s on a.species_id = s.id GROUP BY s.name;

-- List all Digimon owned by Jennifer Orwell.
select a.name, s.name as species, o.full_name from animals as a right join species as s on a.species_id = s.id full join owners as o on a.owner_id = o.id where s.name = 'Digimon' and o.full_name = 'Jennifer Orwell';

-- List all animals owned by Dean Winchester that haven't tried to escape.
select a.name as pet_name, a.escape_attempts, o.full_name from animals as a inner join owners as o on o.id = a.owner_id where o.full_name = 'Dean Winchester' and a.escape_attempts = 0;

-- Who owns the most animals?
select o.full_name, count(a.owner_id) as animals_count from animals as a inner join owners as o on o.id = a.owner_id group by o.full_name order by animals_count desc;