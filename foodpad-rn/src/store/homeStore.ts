// Store Zustand pour l'écran Home
// Gère les catégories, recettes, filtres et états de chargement

import { create } from 'zustand';
import { Category, Meal, RecipeFilter } from '../types';
import { mealsApi } from '../services/mealsApi';

interface HomeState {
  categories: Category[];
  meals: Meal[];
  activeCategory: string;
  searchQuery: string;
  filter: RecipeFilter;
  loading: boolean;
  error: string | null;

  setCategories: (categories: Category[]) => void;
  setMeals: (meals: Meal[]) => void;
  setActiveCategory: (category: string) => void;
  setSearchQuery: (query: string) => void;
  setFilter: (filter: RecipeFilter) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;

  loadCategories: () => Promise<void>;
  loadMeals: (category?: string) => Promise<void>;
  searchMeals: (query: string) => Promise<void>;
}

export const useHomeStore = create<HomeState>((set, get) => ({
  categories: [],
  meals: [],
  activeCategory: 'Beef',
  searchQuery: '',
  filter: { category: 'Beef', favoritesOnly: false },
  loading: false,
  error: null,

  setCategories: (categories) => set({ categories }),
  setMeals: (meals) => set({ meals }),
  setActiveCategory: (category) => set({ activeCategory: category }),
  setSearchQuery: (query) => set({ searchQuery: query }),
  setFilter: (filter) => set({ filter }),
  setLoading: (loading) => set({ loading }),
  setError: (error) => set({ error }),

  loadCategories: async () => {
    try {
      set({ loading: true, error: null });
      const categories = await mealsApi.getCategories();
      set({ categories, loading: false });
    } catch (error) {
      set({ error: 'Failed to load categories', loading: false });
    }
  },

  loadMeals: async (category?: string) => {
    const cat = category || get().activeCategory;
    try {
      set({ loading: true, error: null });
      const meals = await mealsApi.filterByCategory(cat);
      set({ meals, loading: false });
    } catch (error) {
      set({ error: 'Failed to load meals', loading: false });
    }
  },

  searchMeals: async (query) => {
    try {
      set({ loading: true, error: null });
      const meals = await mealsApi.search(query);
      set({ meals, loading: false });
    } catch (error) {
      set({ error: 'Search failed', loading: false });
    }
  },
}));
