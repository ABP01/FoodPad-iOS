// FilterSheet - feuille de filtres
// Correspondance avec FilterSheet.swift

import React from 'react';
import { View, Text, StyleSheet, Modal } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from './Pressable';
import { Category } from '../types';

interface FilterSheetProps {
  visible: boolean;
  onClose: () => void;
  categories: Category[];
  selectedCategory: string;
  onCategorySelect: (category: string) => void;
  favoritesOnly: boolean;
  onFavoritesToggle: () => void;
  onApply: () => void;
  onReset: () => void;
}

export const FilterSheet: React.FC<FilterSheetProps> = ({
  visible,
  onClose,
  categories,
  selectedCategory,
  onCategorySelect,
  favoritesOnly,
  onFavoritesToggle,
  onApply,
  onReset,
}) => {
  return (
    <Modal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={styles.overlay}>
        <View style={styles.sheet}>
          <View style={styles.header}>
            <Text style={typography.detailSectionTitle}>Filters</Text>
            <CustomPressable onPress={onClose}>
              <Ionicons name="close" size={HP(2)} color={colors.neutral500} />
            </CustomPressable>
          </View>

          <View style={styles.section}>
            <Text style={typography.detailArea}>Category</Text>
            <View style={styles.categoryList}>
              {categories.map((category) => (
                <CustomPressable
                  key={category.idCategory}
                  style={[
                    styles.categoryItem,
                    selectedCategory === category.strCategory &&
                      styles.categoryItemSelected,
                  ]}
                  onPress={() => onCategorySelect(category.strCategory)}
                >
                  <Text
                    style={[
                      typography.categoryLabel,
                      selectedCategory === category.strCategory &&
                        styles.categoryItemSelectedText,
                    ]}
                  >
                    {category.strCategory}
                  </Text>
                  {selectedCategory === category.strCategory && (
                    <Ionicons
                      name="checkmark"
                      size={HP(1.6)}
                      color={colors.accent}
                    />
                  )}
                </CustomPressable>
              ))}
            </View>
          </View>

          <View style={styles.section}>
            <View style={styles.toggleRow}>
              <Text style={typography.detailArea}>Favorites Only</Text>
              <CustomPressable
                style={[
                  styles.toggle,
                  favoritesOnly && styles.toggleActive,
                ]}
                onPress={onFavoritesToggle}
              >
                {favoritesOnly && (
                  <Ionicons name="checkmark" size={HP(1.6)} color="#fff" />
                )}
              </CustomPressable>
            </View>
          </View>

          <View style={styles.buttons}>
            <CustomPressable style={styles.resetButton} onPress={onReset}>
              <Text style={typography.categoryLabel}>Reset</Text>
            </CustomPressable>
            <CustomPressable style={styles.applyButton} onPress={onApply}>
              <Text style={[typography.categoryLabel, { color: '#fff' }]}>
                Apply
              </Text>
            </CustomPressable>
          </View>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  sheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 50,
    borderTopRightRadius: 50,
    padding: 16,
    paddingBottom: 32,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  section: {
    marginBottom: 24,
  },
  categoryList: {
    gap: 8,
  },
  categoryItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 12,
    backgroundColor: colors.cardPlaceholder,
    borderRadius: 12,
  },
  categoryItemSelected: {
    backgroundColor: colors.accent + '10',
    borderWidth: 1,
    borderColor: colors.accent,
  },
  categoryItemSelectedText: {
    color: colors.accent,
  },
  toggleRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  toggle: {
    width: 48,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.pillInactive,
    justifyContent: 'center',
    alignItems: 'center',
  },
  toggleActive: {
    backgroundColor: colors.accent,
  },
  buttons: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  resetButton: {
    flex: 1,
    paddingVertical: 12,
    backgroundColor: colors.cardPlaceholder,
    borderRadius: 12,
    alignItems: 'center',
  },
  applyButton: {
    flex: 1,
    paddingVertical: 12,
    backgroundColor: colors.accent,
    borderRadius: 12,
    alignItems: 'center',
  },
});
