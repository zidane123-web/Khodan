-- Pedigree generation helper (ancestors up to 4 generations)
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET default_tablespace = '';
SET default_table_access_method = heap;

DROP FUNCTION IF EXISTS public.fn_pedigree_tree(uuid, integer);

CREATE FUNCTION public.fn_pedigree_tree(
  p_breeder_id uuid,
  p_generations integer DEFAULT 4
) RETURNS TABLE (
  profile_id uuid,
  breeder_id uuid,
  generation integer,
  relation_path text,
  relation_side text,
  relation_label text,
  tag_id text,
  display_name text,
  registered_name text,
  sex text,
  status text,
  birth_date date,
  entry_date date,
  cage_number text,
  origin text,
  species_id bigint,
  missing boolean,
  last_mating_date date,
  last_kindling_date date,
  last_weaning_date date,
  node jsonb
) LANGUAGE plpgsql STABLE
SET search_path TO public
AS $function$
DECLARE
  v_max_generations integer := LEAST(GREATEST(COALESCE(p_generations, 4), 0), 4);
BEGIN
  IF p_breeder_id IS NULL THEN
    RETURN;
  END IF;

  PERFORM 1
  FROM public.animals a
  WHERE a.id = p_breeder_id
    AND a.deleted_at IS NULL;

  IF NOT FOUND THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH RECURSIVE tree (
    profile_id,
    generation,
    relation_path,
    relation_side,
    breeder_id,
    sire_id,
    dam_id,
    birth_date,
    breeder_data,
    tag_id,
    registered_name,
    sex,
    status,
    entry_date,
    cage_number,
    origin,
    species_id,
    missing
  ) AS (
    SELECT
      a.profile_id,
      0,
      ''::text,
      'root'::text,
      a.id,
      a.sire_id,
      a.dam_id,
      a.birth_date,
      to_jsonb(a),
      a.tag_id,
      a.name,
      a.sex,
      a.status,
      a.entry_date,
      a.cage_number,
      a.origin,
      a.species_id,
      FALSE
    FROM public.animals a
    WHERE a.id = p_breeder_id
      AND a.deleted_at IS NULL

    UNION ALL

    SELECT
      COALESCE(parent.profile_id, tree.profile_id),
      tree.generation + 1,
      tree.relation_path || branch.relation,
      branch.relation,
      parent.id,
      parent.sire_id,
      parent.dam_id,
      parent.birth_date,
      CASE
        WHEN parent.id IS NULL THEN NULL
        ELSE to_jsonb(parent)
      END,
      parent.tag_id,
      parent.name,
      parent.sex,
      parent.status,
      parent.entry_date,
      parent.cage_number,
      parent.origin,
      parent.species_id,
      parent.id IS NULL
    FROM tree
    CROSS JOIN LATERAL (
      VALUES ('P', tree.sire_id),
             ('M', tree.dam_id)
    ) AS branch(relation, parent_id)
    LEFT JOIN public.animals parent
      ON parent.id = branch.parent_id
      AND parent.deleted_at IS NULL
    WHERE tree.generation < v_max_generations
  )
  SELECT
    tree.profile_id,
    tree.breeder_id,
    tree.generation,
    tree.relation_path,
    tree.relation_side,
    CASE
      WHEN tree.generation = 0 THEN 'Sujet'
      WHEN tree.generation = 1 AND tree.relation_side = 'P' THEN 'Pere'
      WHEN tree.generation = 1 AND tree.relation_side = 'M' THEN 'Mere'
      WHEN tree.generation = 2 AND tree.relation_path LIKE 'P%' THEN 'Grand-parent paternel'
      WHEN tree.generation = 2 AND tree.relation_path LIKE 'M%' THEN 'Grand-parent maternel'
      WHEN tree.generation = 3 AND tree.relation_path LIKE 'P%' THEN 'Arriere-grand-parent paternel'
      WHEN tree.generation = 3 AND tree.relation_path LIKE 'M%' THEN 'Arriere-grand-parent maternel'
      WHEN tree.relation_path LIKE 'P%' THEN 'Ancetre paternel'
      WHEN tree.relation_path LIKE 'M%' THEN 'Ancetre maternel'
      ELSE 'Ancetre'
    END AS relation_label,
    tree.tag_id,
    CASE
      WHEN tree.breeder_id IS NULL THEN NULL
      ELSE COALESCE(NULLIF(tree.registered_name, ''), tree.tag_id)
    END AS display_name,
    tree.registered_name,
    tree.sex,
    tree.status,
    tree.birth_date,
    tree.entry_date,
    tree.cage_number,
    tree.origin,
    tree.species_id,
    tree.missing,
    stats.last_mating_date,
    stats.last_kindling_date,
    stats.last_weaning_date,
    tree.breeder_data
  FROM tree
  LEFT JOIN LATERAL (
    SELECT
      MAX(br.mating_date) AS last_mating_date,
      MAX(br.kindling_date) AS last_kindling_date,
      MAX(br.weaning_date) AS last_weaning_date
    FROM public.breeding_records br
    WHERE tree.breeder_id IS NOT NULL
      AND br.deleted_at IS NULL
      AND br.profile_id = tree.profile_id
      AND (br.doe_id = tree.breeder_id OR br.buck_id = tree.breeder_id)
  ) stats ON TRUE
  ORDER BY tree.generation, tree.relation_path;
END;
$function$;

COMMENT ON FUNCTION public.fn_pedigree_tree(uuid, integer) IS
  'Return pedigree information (up to 4 generations) for a breeder/animal, including placeholders for missing ancestors.';
