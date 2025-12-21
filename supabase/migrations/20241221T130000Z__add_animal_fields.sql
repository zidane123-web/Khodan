-- 20241221T130000Z__add_animal_fields.sql
-- Ajouter les nouveaux champs au modèle Animal : race, couleur, poids actuel

-- Ajouter les nouveaux champs à la table animals
ALTER TABLE public.animals
  ADD COLUMN IF NOT EXISTS race TEXT,
  ADD COLUMN IF NOT EXISTS color TEXT,
  ADD COLUMN IF NOT EXISTS current_weight DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS last_weight_date DATE;

-- Index pour recherche par race (utile pour les statistiques par race)
CREATE INDEX IF NOT EXISTS idx_animals_race ON public.animals(race);

-- Commentaires pour documentation
COMMENT ON COLUMN public.animals.race IS 'Race du lapin (ex: Fauve de Bourgogne, Californien)';
COMMENT ON COLUMN public.animals.color IS 'Couleur du pelage (ex: Fauve, Blanc, Noir panné)';
COMMENT ON COLUMN public.animals.current_weight IS 'Poids actuel en kg (dernière pesée)';
COMMENT ON COLUMN public.animals.last_weight_date IS 'Date de la dernière pesée';
