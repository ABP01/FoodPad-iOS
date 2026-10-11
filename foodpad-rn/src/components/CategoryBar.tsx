// CategoryBar - barre de catégories horizontale
// Correspondance avec CategoryBar dans Components.swift

import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { Image } from 'expo-image';
import { colors, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { Category } from '../types';
import { CustomPressable } from './Pressable';

interface CategoryBarProps {
  categories: Category[];
  activeCategory: string;
  onSelectCategory: (category: string) => void;
}

export const CategoryBar: React.FC<CategoryBarProps> = ({
  categories,
  activeCategory,
  onSelectCategory,
}) => {
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      contentContainerStyle={styles.content}
    >
      {categories.map((category) => (
        <CustomPressable
          key={category.idCategory}
          style={[
            styles.category,
            activeCategory === category.strCategory && styles.activeCategory,
          ]}
          onPress={() => onSelectCategory(category.strCategory)}
        >
          <Image
            source={{ uri: category.strCategoryThumb || undefined }}
            style={styles.categoryImage}
            contentFit="cover"
            cachePolicy="disk"
          />
          <Text
            style={[
              typography.categoryLabel,
              activeCategory === category.strCategory && styles.activeLabel,
            ]}
          >
            {category.strCategory}
          </Text>
        </CustomPressable>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  content: {
    gap: 16,
    paddingHorizontal: 15,
  },
  category: {
    backgroundColor: colors.pillInactive,
    borderRadius: 12,
    padding: 6,
    alignItems: 'center',
    gap: 4,
  },
  activeCategory: {
    backgroundColor: colors.accent,
  },
  categoryImage: {
    width: HP(6),
    height: HP(6),
    borderRadius: HP(3),
  },
  activeLabel: {
    color: '#fff',
  },
});
