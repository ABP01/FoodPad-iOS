// Design system tokens - source de vérité pour FoodPad
// Valeurs extraites de Theme.swift, Typography.swift et Responsive.swift

import { Dimensions, DimensionValue } from 'react-native';

// Couleurs
export const colors = {
  accent: '#f64e32',
  neutral500: '#737373',
  neutral600: '#525252',
  neutral700: '#404040',
  neutral800: '#262626',
  pillInactive: 'rgba(0,0,0,0.10)',
  cardPlaceholder: 'rgba(0,0,0,0.05)',
  gradient: ['transparent', 'rgba(0,0,0,0.9)'] as const,
} as const;

// Rayons de bordure
export const radius = {
  card: 35,
  sheet: 50,
  search: 12,
  link: 16,
  icon: 10,
} as const;

// Graisses de police
export const weight = {
  regular: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
  heavy: '800',
} as const;

// hp / wp : POURCENTAGE d'écran
// Suivi des changements d'orientation
let dimensions = Dimensions.get('window');

Dimensions.addEventListener('change', ({ window }) => {
  dimensions = window;
});

export const HP = (n: number): number => (n / 100) * dimensions.height;
export const WP = (n: number): number => (n / 100) * dimensions.width;

// Espacements
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
} as const;
