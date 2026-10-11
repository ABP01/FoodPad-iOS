// API Service pour TheMealDB
// Correspondance avec MealService.swift

import axios from 'axios';
import { Category, Meal } from '../types';

const BASE_URL = 'https://www.themealdb.com/api/json/v1/1';

export const mealsApi = {
  // GET /categories.php
  async getCategories(): Promise<Category[]> {
    const response = await axios.get(`${BASE_URL}/categories.php`);
    return response.data.categories;
  },

  // GET /filter.php?c={cat}
  async filterByCategory(category: string): Promise<Meal[]> {
    const response = await axios.get(`${BASE_URL}/filter.php`, {
      params: { c: category },
    });
    return response.data.meals;
  },

  // GET /lookup.php?i={id}
  async lookupById(id: string): Promise<Meal> {
    const response = await axios.get(`${BASE_URL}/lookup.php`, {
      params: { i: id },
    });
    const meals = response.data.meals;
    if (!meals || meals.length === 0) {
      throw new Error('Meal not found');
    }
    return meals[0];
  },

  // GET /search.php?s={q}
  async search(query: string): Promise<Meal[]> {
    const response = await axios.get(`${BASE_URL}/search.php`, {
      params: { s: query },
    });
    return response.data.meals || [];
  },
};
