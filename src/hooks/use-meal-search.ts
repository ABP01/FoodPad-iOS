import { useEffect, useRef, useState } from "react";

import { searchMealsByName, type MealSummary } from "@/services/mealdb";

type MealSearchState = {
  meals: MealSummary[];
  loading: boolean;
  error: string | null;
};

export function useMealSearch(query: string): MealSearchState {
  const [meals, setMeals] = useState<MealSummary[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const requestIdRef = useRef(0);

  const q = query.trim();

  useEffect(() => {
    if (!q) {
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

    const timeout = setTimeout(() => {
      searchMealsByName(q)
        .then((nextMeals) => {
          if (cancelled || requestIdRef.current !== requestId) return;
          setMeals(Array.isArray(nextMeals) ? nextMeals : []);
        })
        .catch((cause: unknown) => {
          if (cancelled || requestIdRef.current !== requestId) return;
          setError(cause instanceof Error ? cause.message : "Erreur de recherche");
          setMeals([]);
        })
        .finally(() => {
          if (cancelled || requestIdRef.current !== requestId) return;
          setLoading(false);
        });
    }, 250);

    return () => {
      cancelled = true;
      clearTimeout(timeout);
    };
  }, [q]);

  return { meals, loading, error };
}
