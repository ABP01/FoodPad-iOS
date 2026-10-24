const BASE_URL = "https://www.themealdb.com/api/json/v1/1";

type ListResponse<T> = { meals: T[] | null };

export type Category = {
  strCategory: string;
};

export type Area = {
  strArea: string;
  strCountry?: string;
};

export type Ingredient = {
  idIngredient: string;
  strIngredient: string;
  strDescription?: string;
  strType?: string | null;
};

export type MealSummary = {
  idMeal: string;
  strMeal: string;
  strMealThumb: string;
};

export type MealDetail = {
  idMeal: string;
  strMeal: string;
  strMealThumb: string;
  strCategory: string | null;
  strArea: string | null;
  strInstructions: string | null;
  strTags: string | null;
  strYoutube: string | null;
  [key: string]: string | null;
};

export type MealFilter = {
  type: "category" | "area" | "ingredient";
  value: string;
};

const FILTER_PARAMS: Record<MealFilter["type"], string> = {
  category: "c",
  area: "a",
  ingredient: "i",
};

async function getList<T>(endpoint: string): Promise<T[]> {
  const response = await fetch(`${BASE_URL}/${endpoint}`, {
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`MealDB request failed (${response.status})`);
  }

  const data = (await response.json()) as ListResponse<T>;
  return Array.isArray(data?.meals) ? data.meals : [];
}

/** Toutes les catégories (`list.php?c=list`). */
export function getCategories() {
  return getList<Category>("list.php?c=list");
}

/** Toutes les zones géographiques (`list.php?a=list`). */
export function getAreas() {
  return getList<Area>("list.php?a=list");
}

/** Tous les ingrédients (`list.php?i=list`). */
export function getIngredients() {
  return getList<Ingredient>("list.php?i=list");
}

/** Recettes filtrées par catégorie, zone ou ingrédient principal (`filter.php`). */
export function getMealsByFilter({ type, value }: MealFilter) {
  const normalized =
    type === "ingredient" ? value.trim().replace(/\s+/g, "_") : value.trim();

  return getList<MealSummary>(
    `filter.php?${FILTER_PARAMS[type]}=${encodeURIComponent(normalized)}`,
  ).then((meals) => (Array.isArray(meals) ? meals : []));
}

/** Recherche par nom (`search.php?s=`). */
export async function searchMealsByName(query: string): Promise<MealSummary[]> {
  const q = query.trim();
  if (!q) return [];
  const response = await fetch(
    `${BASE_URL}/search.php?s=${encodeURIComponent(q)}`,
    { headers: { Accept: "application/json" } },
  );

  if (!response.ok) {
    throw new Error(`MealDB request failed (${response.status})`);
  }

  const data = (await response.json()) as { meals: MealDetail[] | null };
  if (!Array.isArray(data?.meals)) return [];
  return data.meals
    .filter((m) => m?.idMeal && m?.strMeal)
    .map((m) => ({
      idMeal: String(m.idMeal),
      strMeal: String(m.strMeal),
      strMealThumb: String(m.strMealThumb || ""),
    }));
}

/** Recette aléatoire (`random.php`). */
export async function getRandomMeal(): Promise<MealSummary | null> {
  const response = await fetch(`${BASE_URL}/random.php`, { headers: { Accept: "application/json" } });
  if (!response.ok) {
    throw new Error(`MealDB request failed (${response.status})`);
  }
  const data = (await response.json()) as { meals: MealDetail[] | null };
  const meal = Array.isArray(data?.meals) ? data.meals[0] : null;
  if (!meal?.idMeal || !meal?.strMeal) return null;
  return {
    idMeal: String(meal.idMeal),
    strMeal: String(meal.strMeal),
    strMealThumb: String(meal.strMealThumb || ""),
  };
}

/** Sélection de recettes aléatoires. */
export async function getRandomMeals(count: number): Promise<MealSummary[]> {
  const results: MealSummary[] = [];
  const seen = new Set<string>();
  const attempts = Math.max(count * 3, count);
  for (let i = 0; i < attempts && results.length < count; i++) {
    try {
      const meal = await getRandomMeal();
      if (meal && !seen.has(meal.idMeal)) {
        seen.add(meal.idMeal);
        results.push(meal);
      }
    } catch {
      // ignore individual failures
    }
  }
  return results;
}

/** Détails complets d'un plat (`lookup.php?i=`). */
export async function getMealById(id: string): Promise<MealDetail | null> {
  const response = await fetch(
    `${BASE_URL}/lookup.php?i=${encodeURIComponent(id)}`,
    { headers: { Accept: "application/json" } },
  );

  if (!response.ok) {
    throw new Error(`MealDB request failed (${response.status})`);
  }

  const data = (await response.json()) as { meals: MealDetail[] | null };
  return Array.isArray(data?.meals) ? data.meals[0] ?? null : null;
}

/** Les URLs de catégories/ingrédients sont dérivées de leur nom. */
function toSlug(value: string) {
  return value.trim().toLowerCase().replace(/\s+/g, "_");
}

export function getCategoryThumb(category: string) {
  return `https://www.themealdb.com/images/category/${toSlug(category)}.png`;
}

export function getIngredientThumb(ingredient: string) {
  return `https://www.themealdb.com/images/ingredients/${toSlug(ingredient)}.png`;
}

/** Ajoute la variante `/preview` ou `/medium` à une URL d'image de plat. */
export function getMealThumb(url: string, size: "small" | "medium" | "large" = "medium") {
  if (!url) return url;
  if (url.endsWith("/small") || url.endsWith("/medium") || url.endsWith("/large")) {
    return url.replace(/\/(small|medium|large)$/, `/${size}`);
  }
  if (url.includes("/preview")) {
    return url.replace("/preview", `/${size}`);
  }
  return `${url}/${size}`;
}

