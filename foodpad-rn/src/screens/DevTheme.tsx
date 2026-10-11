// Écran-témoin du design system
// Correspondance avec DesignSystemPreview.swift

import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { colors, radius, HP, WP } from '../theme/tokens';
import { typography } from '../theme/typography';

export const DevTheme: React.FC = () => {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={[styles.sectionTitle, typography.detailSectionTitle]}>Colors</Text>
      <View style={styles.colorRow}>
        <View style={[styles.colorSwatch, { backgroundColor: colors.accent }]}>
          <Text style={styles.colorLabel}>Accent</Text>
        </View>
        <View style={[styles.colorSwatch, { backgroundColor: colors.neutral500 }]}>
          <Text style={styles.colorLabel}>Neutral 500</Text>
        </View>
        <View style={[styles.colorSwatch, { backgroundColor: colors.neutral600 }]}>
          <Text style={styles.colorLabel}>Neutral 600</Text>
        </View>
      </View>
      <View style={styles.colorRow}>
        <View style={[styles.colorSwatch, { backgroundColor: colors.neutral700 }]}>
          <Text style={styles.colorLabel}>Neutral 700</Text>
        </View>
        <View style={[styles.colorSwatch, { backgroundColor: colors.neutral800 }]}>
          <Text style={styles.colorLabel}>Neutral 800</Text>
        </View>
        <View style={[styles.colorSwatch, { backgroundColor: colors.pillInactive }]}>
          <Text style={styles.colorLabel}>Pill Inactive</Text>
        </View>
      </View>

      <Text style={[styles.sectionTitle, typography.detailSectionTitle]}>Typography</Text>
      <Text style={typography.welcomeTitle}>Welcome Title</Text>
      <Text style={typography.welcomeSubtitle}>Welcome Subtitle</Text>
      <Text style={typography.homeHeadline}>Home Headline</Text>
      <Text style={[typography.homeHeadlineAccent, { color: colors.accent }]}>
        Home Headline Accent
      </Text>
      <Text style={typography.searchPlaceholder}>Search Placeholder</Text>
      <Text style={typography.categoryLabel}>Category Label</Text>
      <Text style={typography.recipesCount}>14 Recipes</Text>
      <Text style={typography.recipeCardTitle}>Recipe Card Title</Text>
      <Text style={typography.detailMealName}>Detail Meal Name</Text>
      <Text style={typography.detailArea}>Japanese</Text>
      <Text style={typography.detailSectionTitle}>Ingredients</Text>
      <Text style={typography.ingredientName}>Chicken</Text>
      <Text style={typography.ingredientMeasure}>1 kg</Text>
      <Text style={typography.instructions}>Instructions text here</Text>

      <Text style={[styles.sectionTitle, typography.detailSectionTitle]}>Spacing (hp/wp)</Text>
      <View style={styles.spacingDemo}>
        <View style={[styles.box, { height: HP(5), width: WP(40) }]}>
          <Text style={styles.boxLabel}>5hp × 40wp</Text>
        </View>
        <View style={[styles.box, { height: HP(10), width: WP(40) }]}>
          <Text style={styles.boxLabel}>10hp × 40wp</Text>
        </View>
        <View style={[styles.box, { height: HP(15), width: WP(40) }]}>
          <Text style={styles.boxLabel}>15hp × 40wp</Text>
        </View>
      </View>

      <Text style={[styles.sectionTitle, typography.detailSectionTitle]}>Border Radius</Text>
      <View style={styles.radiusRow}>
        <View style={[styles.radiusBox, { borderRadius: radius.card }]}>
          <Text style={styles.radiusLabel}>Card (35)</Text>
        </View>
        <View style={[styles.radiusBox, { borderRadius: radius.sheet }]}>
          <Text style={styles.radiusLabel}>Sheet (50)</Text>
        </View>
        <View style={[styles.radiusBox, { borderRadius: radius.search }]}>
          <Text style={styles.radiusLabel}>Search (12)</Text>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    padding: 16,
  },
  sectionTitle: {
    marginTop: 24,
    marginBottom: 12,
  },
  colorRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  colorSwatch: {
    width: 100,
    height: 100,
    borderRadius: 12,
    justifyContent: 'center',
    alignItems: 'center',
  },
  colorLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#fff',
  },
  spacingDemo: {
    gap: 12,
    marginBottom: 12,
  },
  box: {
    backgroundColor: colors.cardPlaceholder,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 8,
  },
  boxLabel: {
    fontSize: 12,
    color: colors.neutral700,
  },
  radiusRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 12,
  },
  radiusBox: {
    width: 80,
    height: 80,
    backgroundColor: colors.cardPlaceholder,
    justifyContent: 'center',
    alignItems: 'center',
  },
  radiusLabel: {
    fontSize: 10,
    color: colors.neutral700,
  },
});
