// Mock data pour le développement et les tests
// Correspondance avec MockMealService.swift

import { Category, Meal } from '../types';

export const mockCategories: Category[] = [
  {
    idCategory: '1',
    strCategory: 'Beef',
    strCategoryThumb: 'https://www.themealdb.com/images/category/beef.png',
    strCategoryDescription: 'Beef is the culinary name for meat from cattle.',
  },
  {
    idCategory: '2',
    strCategory: 'Chicken',
    strCategoryThumb: 'https://www.themealdb.com/images/category/chicken.png',
    strCategoryDescription: 'Chicken is a type of domesticated fowl.',
  },
  {
    idCategory: '3',
    strCategory: 'Seafood',
    strCategoryThumb: 'https://www.themealdb.com/images/category/seafood.png',
    strCategoryDescription: 'Seafood is any form of sea life regarded as food.',
  },
];

export const mockMeals: Meal[] = [
  {
    idMeal: '52772',
    strMeal: 'Teriyaki Chicken Casserole',
    strMealThumb: 'https://www.themealdb.com/images/media/meals/wvpspp1468256328.jpg',
    strCategory: 'Chicken',
    strArea: 'Japanese',
    strInstructions: 'Preheat oven to 180°C (350°F).',
    strYoutube: 'https://www.youtube.com/watch?v=4vZ7lX2-0-s',
    strSource: null,
    strIngredient1: 'Chicken',
    strMeasure1: '1 kg',
    strIngredient2: 'Soy Sauce',
    strMeasure2: '1/2 cup',
    strIngredient3: null,
    strMeasure3: null,
    strIngredient4: null,
    strMeasure4: null,
    strIngredient5: null,
    strMeasure5: null,
    strIngredient6: null,
    strMeasure6: null,
    strIngredient7: null,
    strMeasure7: null,
    strIngredient8: null,
    strMeasure8: null,
    strIngredient9: null,
    strMeasure9: null,
    strIngredient10: null,
    strMeasure10: null,
    strIngredient11: null,
    strMeasure11: null,
    strIngredient12: null,
    strMeasure12: null,
    strIngredient13: null,
    strMeasure13: null,
    strIngredient14: null,
    strMeasure14: null,
    strIngredient15: null,
    strMeasure15: null,
    strIngredient16: null,
    strMeasure16: null,
    strIngredient17: null,
    strMeasure17: null,
    strIngredient18: null,
    strMeasure18: null,
    strIngredient19: null,
    strMeasure19: null,
    strIngredient20: null,
    strMeasure20: null,
  },
  {
    idMeal: '52771',
    strMeal: 'Spicy Arrabiata Penne',
    strMealThumb: 'https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg',
    strCategory: 'Vegetarian',
    strArea: 'Italian',
    strInstructions: 'Bring a large pot of water to a boil.',
    strYoutube: 'https://www.youtube.com/watch?v=1Is7Tj7QpL0',
    strSource: null,
    strIngredient1: 'Penne',
    strMeasure1: '400g',
    strIngredient2: 'Tomato Sauce',
    strMeasure2: '500ml',
    strIngredient3: null,
    strMeasure3: null,
    strIngredient4: null,
    strMeasure4: null,
    strIngredient5: null,
    strMeasure5: null,
    strIngredient6: null,
    strMeasure6: null,
    strIngredient7: null,
    strMeasure7: null,
    strIngredient8: null,
    strMeasure8: null,
    strIngredient9: null,
    strMeasure9: null,
    strIngredient10: null,
    strMeasure10: null,
    strIngredient11: null,
    strMeasure11: null,
    strIngredient12: null,
    strMeasure12: null,
    strIngredient13: null,
    strMeasure13: null,
    strIngredient14: null,
    strMeasure14: null,
    strIngredient15: null,
    strMeasure15: null,
    strIngredient16: null,
    strMeasure16: null,
    strIngredient17: null,
    strMeasure17: null,
    strIngredient18: null,
    strMeasure18: null,
    strIngredient19: null,
    strMeasure19: null,
    strIngredient20: null,
    strMeasure20: null,
  },
];

export const mockMealsApi = {
  async getCategories(): Promise<Category[]> {
    return mockCategories;
  },
  async filterByCategory(category: string): Promise<Meal[]> {
    return mockMeals.filter(m => m.strCategory === category);
  },
  async lookupById(id: string): Promise<Meal> {
    const meal = mockMeals.find(m => m.idMeal === id);
    if (!meal) throw new Error('Meal not found');
    return meal;
  },
  async search(query: string): Promise<Meal[]> {
    const q = query.toLowerCase();
    return mockMeals.filter(m =>
      m.strMeal?.toLowerCase().includes(q)
    );
  },
};
