import { useCallback, useEffect, useRef, useState } from "react";

import { getMealsByFilter, type MealFilter, type MealSummary } from "@/services/mealdb";

type MealFilterState = {
  meals: MealSummary[];
  loading: boolean;
  error: string | null;
  reload: () => void;
};

/** Charge les recettes filtrées par catégorie/zone/ingrédient. */
export function useMealFilter(filter: MealFilter | null): MealFilterState {
  const [meals, setMeals] = useState<MealSummary[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const requestIdRef = useRef(0);

  const type = filter?.type ?? null;
  const value = filter?.value ?? null;

  useEffect(() => {
    if (!type || !value) {
      requestIdRef.current += 1;
      queueMicrotask(() => {
        setMeals([]);
        setError(null);
        setLoading(false);
      });
      return;
    }

    const requestId = ++requestIdRef.current;
    let cancelled = false;

    queueMicrotask(() => {
      if (cancelled || requestIdRef.current !== requestId) return;
      setLoading(true);
      setError(null);
    });

    getMealsByFilter({ type, value })
      .then((nextMeals) => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setMeals(Array.isArray(nextMeals) ? nextMeals : []);
      })
      .catch((cause: unknown) => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setError(
          cause instanceof Error ? cause.message : "Impossible de charger les recettes",
        );
        setMeals([]);
      })
      .finally(() => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [type, value, reloadKey]);

  const reload = useCallback(() => setReloadKey((key) => key + 1), []);

  return { meals, loading, error, reload };
}
