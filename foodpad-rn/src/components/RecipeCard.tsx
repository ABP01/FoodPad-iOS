// RecipeCard - carte de recette
// Correspondance avec RecipeCard.swift

import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { colors, radius, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { Meal } from '../types';
import { CustomPressable } from './Pressable';

interface RecipeCardProps {
  meal: Meal;
  index: number;
  onPress: () => void;
}

export const RecipeCard: React.FC<RecipeCardProps> = ({ meal, index, onPress }) => {
  const height = index % 3 === 0 ? HP(25) : HP(35);
  const offset = index % 2 === 0 ? 8 : 0;
  const truncatedName =
    meal.strMeal && meal.strMeal.length > 20
      ? meal.strMeal.slice(0, 20) + '…'
      : meal.strMeal || '';

  return (
    <CustomPressable
      style={[styles.container, { height, marginRight: offset }]}
      onPress={onPress}
    >
      <Image
        source={{ uri: meal.strMealThumb || undefined }}
        style={[styles.image, { height }]}
        resizeMode="cover"
      />
      <LinearGradient
        colors={colors.gradient}
        start={{ x: 0.5, y: 0 }}
        end={{ x: 0.5, y: 1 }}
        style={styles.gradient}
      />
      <Text style={[typography.recipeCardTitle, styles.title]}>{truncatedName}</Text>
    </CustomPressable>
  );
};

const styles = StyleSheet.create({
  container: {
    borderRadius: radius.card,
    overflow: 'hidden',
    position: 'relative',
  },
  image: {
    width: '100%',
    borderRadius: radius.card,
  },
  gradient: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    height: HP(20),
    borderBottomLeftRadius: radius.card,
    borderBottomRightRadius: radius.card,
  },
  title: {
    position: 'absolute',
    bottom: 28,
    left: 8,
    maxWidth: '80%',
    color: '#fff',
  },
});
