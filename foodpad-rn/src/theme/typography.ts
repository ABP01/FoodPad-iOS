// Typography styles - correspondance exacte avec Typography.swift
import { HP } from './tokens';
import { weight } from './tokens';

export const typography = {
  // Welcome
  welcomeTitle: {
    fontSize: HP(5),
    fontWeight: weight.heavy,
    letterSpacing: 4,
  },
  welcomeSubtitle: {
    fontSize: HP(2.5),
    fontWeight: weight.medium,
    letterSpacing: 2,
  },
  welcomeButton: {
    fontSize: HP(2.2),
    fontWeight: weight.medium,
  },

  // Home
  homeHeadline: {
    fontSize: HP(3.5),
    fontWeight: weight.bold,
  },
  homeHeadlineAccent: {
    fontSize: HP(3.5),
    fontWeight: weight.heavy,
  },
  searchPlaceholder: {
    fontSize: HP(1.7),
    fontWeight: weight.regular,
    letterSpacing: 2,
  },
  categoryLabel: {
    fontSize: HP(1.6),
    fontWeight: weight.regular,
  },
  recipesCount: {
    fontSize: HP(2),
    fontWeight: weight.semibold,
  },

  // Recipe Card
  recipeCardTitle: {
    fontSize: HP(2.2),
    fontWeight: weight.semibold,
  },

  // Details
  detailMealName: {
    fontSize: HP(3),
    fontWeight: weight.bold,
  },
  detailArea: {
    fontSize: HP(2),
    fontWeight: weight.medium,
  },
  detailSectionTitle: {
    fontSize: HP(2.5),
    fontWeight: weight.bold,
  },
  ingredientName: {
    fontSize: HP(1.7),
    fontWeight: weight.medium,
  },
  ingredientMeasure: {
    fontSize: HP(1.7),
    fontWeight: weight.heavy,
  },
  instructions: {
    fontSize: HP(1.7),
    fontWeight: weight.regular,
  },
} as const;
