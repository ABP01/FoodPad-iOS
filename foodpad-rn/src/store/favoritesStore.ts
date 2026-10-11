// Store Zustand pour les favoris
// Correspondance avec FavoritesStore.swift - persistance v2

import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { FavoriteEntry, Meal } from '../types';

const FAVORITES_KEY = 'foodpad_favorites_v2';

interface FavoritesState {
  favorites: FavoriteEntry[];
  loadFavorites: () => Promise<void>;
  toggleFavorite: (meal: Meal) => Promise<void>;
  removeAll: () => Promise<void>;
  isFavorite: (id: string) => boolean;
}

export const useFavoritesStore = create<FavoritesState>((set, get) => ({
  favorites: [],

  loadFavorites: async () => {
    try {
      const data = await AsyncStorage.getItem(FAVORITES_KEY);
      if (data) {
        set({ favorites: JSON.parse(data) });
      }
    } catch (error) {
      console.error('Failed to load favorites:', error);
    }
  },

  toggleFavorite: async (meal: Meal) => {
    const { favorites } = get();
    const entry: FavoriteEntry = {
      id: meal.idMeal,
      name: meal.strMeal || '',
      thumbnailURL: meal.strMealThumb || '',
    };

    const existingIndex = favorites.findIndex(f => f.id === meal.idMeal);
    let newFavorites: FavoriteEntry[];

    if (existingIndex >= 0) {
      // Remove
      newFavorites = favorites.filter(f => f.id !== meal.idMeal);
    } else {
      // Add (keep insertion order)
      newFavorites = [...favorites, entry];
    }

    set({ favorites: newFavorites });

    try {
      await AsyncStorage.setItem(FAVORITES_KEY, JSON.stringify(newFavorites));
    } catch (error) {
      console.error('Failed to save favorites:', error);
    }
  },

  removeAll: async () => {
    set({ favorites: [] });
    try {
      await AsyncStorage.removeItem(FAVORITES_KEY);
    } catch (error) {
      console.error('Failed to clear favorites:', error);
    }
  },

  isFavorite: (id: string) => {
    return get().favorites.some(f => f.id === id);
  },
}));
