// IngredientsList - liste des ingrédients
// Correspondance avec la section ingrédients de RecipeDetailsScreen

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { Meal } from '../types';

interface IngredientsListProps {
  meal: Meal;
}

export const IngredientsList: React.FC<IngredientsListProps> = ({ meal }) => {
  const ingredients: { name: string; measure: string }[] = [];

  // Extraire les ingrédients et mesures (20 paires possibles)
  for (let i = 1; i <= 20; i++) {
    const ingredient = meal[`strIngredient${i}` as keyof Meal];
    const measure = meal[`strMeasure${i}` as keyof Meal];

    if (ingredient && ingredient.trim() !== '') {
      ingredients.push({
        name: ingredient,
        measure: measure || '',
      });
    }
  }

  return (
    <View style={styles.container}>
      {ingredients.map((item, index) => (
        <View key={index} style={styles.ingredientRow}>
          <View style={styles.bullet} />
          <Text style={typography.ingredientName}>{item.name}</Text>
          <Text style={typography.ingredientMeasure}>{item.measure}</Text>
        </View>
      ))}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    gap: 8,
  },
  ingredientRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    paddingLeft: 12,
  },
  bullet: {
    width: HP(1.5),
    height: HP(1.5),
    borderRadius: HP(0.75),
    backgroundColor: colors.accent,
  },
});
