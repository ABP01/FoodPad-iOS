// SearchBar - barre de recherche
// Correspondance avec SearchBar dans Components.swift

import React from 'react';
import { View, TextInput, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from './Pressable';

interface SearchBarProps {
  value: string;
  onChangeText: (text: string) => void;
  onClear: () => void;
}

export const SearchBar: React.FC<SearchBarProps> = ({
  value,
  onChangeText,
  onClear,
}) => {
  return (
    <View style={styles.container}>
      <View style={styles.searchIconContainer}>
        <Ionicons name="search" size={HP(1.6)} color={colors.neutral500} />
      </View>
      <TextInput
        placeholder="Search recipes..."
        placeholderTextColor={colors.neutral800}
        value={value}
        onChangeText={onChangeText}
        style={[styles.input, typography.searchPlaceholder]}
      />
      {value.length > 0 && (
        <CustomPressable onPress={onClear}>
          <Ionicons name="close-circle" size={HP(2)} color={colors.neutral500} />
        </CustomPressable>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    padding: 6,
    backgroundColor: '#fff',
    borderWidth: 1,
    borderColor: '#000',
    borderRadius: 12,
  },
  searchIconContainer: {
    width: HP(3),
    height: HP(3),
    borderRadius: HP(1.5),
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  input: {
    flex: 1,
    color: colors.neutral800,
  },
});
