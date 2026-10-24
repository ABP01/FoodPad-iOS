import { useEffect, useRef, useState } from "react";

import { getRandomMeals, type MealSummary } from "@/services/mealdb";

type RandomMealsState = {
  meals: MealSummary[];
  loading: boolean;
  error: string | null;
  reload: () => void;
};

export function useRandomMeals(count: number): RandomMealsState {
  const [meals, setMeals] = useState<MealSummary[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [reloadKey, setReloadKey] = useState(0);
  const requestIdRef = useRef(0);

  useEffect(() => {
    const requestId = ++requestIdRef.current;
    let cancelled = false;

    queueMicrotask(() => {
      if (cancelled || requestIdRef.current !== requestId) return;
      setLoading(true);
      setError(null);
    });

    getRandomMeals(count)
      .then((nextMeals) => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setMeals(Array.isArray(nextMeals) ? nextMeals : []);
        if (!Array.isArray(nextMeals) || nextMeals.length === 0) {
          setError("Impossible de charger des recettes aléatoires");
        }
      })
      .catch((cause: unknown) => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setError(cause instanceof Error ? cause.message : "Impossible de charger des recettes");
        setMeals([]);
      })
      .finally(() => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [count, reloadKey]);

  return {
    meals,
    loading,
    error,
    reload: () => setReloadKey((k) => k + 1),
  };
}
