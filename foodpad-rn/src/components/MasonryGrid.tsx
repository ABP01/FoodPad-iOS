// MasonryGrid - grille maçonnerie à 2 colonnes
// Correspondance avec MasonryGrid.swift - algorithme déterministe

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { colors, HP, WP } from '../theme/tokens';
import { Meal } from '../types';
import { RecipeCard } from './RecipeCard';

interface MasonryGridProps {
  meals: Meal[];
  onMealPress: (meal: Meal) => void;
}

export const MasonryGrid: React.FC<MasonryGridProps> = ({ meals, onMealPress }) => {
  // Algorithme déterministe : colonne la plus courte, égalité → gauche
  const { leftColumn, rightColumn } = splitColumns(meals);

  return (
    <View style={styles.container}>
      <View style={styles.column}>
        {leftColumn.map((meal, index) => (
          <RecipeCard
            key={meal.idMeal}
            meal={meal}
            index={index * 2}
            onPress={() => onMealPress(meal)}
          />
        ))}
      </View>
      <View style={styles.column}>
        {rightColumn.map((meal, index) => (
          <RecipeCard
            key={meal.idMeal}
            meal={meal}
            index={index * 2 + 1}
            onPress={() => onMealPress(meal)}
          />
        ))}
      </View>
    </View>
  );
};

// Fonction utilitaire pour répartir les recettes en 2 colonnes
function splitColumns(meals: Meal[]): { leftColumn: Meal[]; rightColumn: Meal[] } {
  const leftColumn: Meal[] = [];
  const rightColumn: Meal[] = [];

  meals.forEach((meal, index) => {
    const height = index % 3 === 0 ? HP(25) : HP(35);
    const leftHeight = leftColumn.reduce((sum, m, i) => {
      return sum + (i % 3 === 0 ? HP(25) : HP(35));
    }, 0);
    const rightHeight = rightColumn.reduce((sum, m, i) => {
      return sum + (i % 3 === 0 ? HP(25) : HP(35));
    }, 0);

    if (leftHeight <= rightHeight) {
      leftColumn.push(meal);
    } else {
      rightColumn.push(meal);
    }
  });

  return { leftColumn, rightColumn };
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 16,
  },
  column: {
    flex: 1,
    gap: 16,
  },
});
