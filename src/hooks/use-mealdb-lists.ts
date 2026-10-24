import { useCallback, useEffect, useRef, useState } from "react";

import {
  getAreas,
  getCategories,
  getIngredients,
  type Area,
  type Category,
  type Ingredient,
} from "@/services/mealdb";

type MealDbLists = {
  categories: Category[];
  areas: Area[];
  ingredients: Ingredient[];
  loading: boolean;
  error: string | null;
  reload: () => void;
};

/** Charge une seule fois les listes Categories / Areas / Ingredients. */
export function useMealDbLists(): MealDbLists {
  const [categories, setCategories] = useState<Category[]>([]);
  const [areas, setAreas] = useState<Area[]>([]);
  const [ingredients, setIngredients] = useState<Ingredient[]>([]);
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

    Promise.allSettled([getCategories(), getAreas(), getIngredients()])
      .then((results) => {
        if (cancelled || requestIdRef.current !== requestId) return;
        const [categoriesRes, areasRes, ingredientsRes] = results;

        setCategories(categoriesRes.status === "fulfilled" && Array.isArray(categoriesRes.value) ? categoriesRes.value : []);
        setAreas(areasRes.status === "fulfilled" && Array.isArray(areasRes.value) ? areasRes.value : []);
        setIngredients(
          ingredientsRes.status === "fulfilled" && Array.isArray(ingredientsRes.value) ? ingredientsRes.value : [],
        );

        const errors = results
          .filter((r): r is PromiseRejectedResult => r.status === "rejected")
          .map((r) => (r.reason instanceof Error ? r.reason.message : String(r.reason)));
        if (errors.length > 0 && categoriesRes.status !== "fulfilled" && areasRes.status !== "fulfilled" && ingredientsRes.status !== "fulfilled") {
          setError("Impossible de charger les données");
        }
      })
      .finally(() => {
        if (cancelled || requestIdRef.current !== requestId) return;
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [reloadKey]);

  const reload = useCallback(() => setReloadKey((key) => key + 1), []);

  return { categories, areas, ingredients, loading, error, reload };
}
