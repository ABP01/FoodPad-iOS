// HomeHeader - header avec filtres et avatar
// Correspondance avec HomeHeader dans Components.swift

import React from 'react';
import { View, Text, StyleSheet, Image } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { colors, HP, WP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from './Pressable';

interface HomeHeaderProps {
  onFilterPress: () => void;
  favoritesCount: number;
  filterActive: boolean;
}

export const HomeHeader: React.FC<HomeHeaderProps> = ({
  onFilterPress,
  favoritesCount,
  filterActive,
}) => {
  return (
    <View style={styles.container}>
      <CustomPressable style={styles.filterButton} onPress={onFilterPress}>
        <Ionicons
          name="options-outline"
          size={HP(2.2)}
          color={filterActive ? colors.accent : colors.neutral500}
        />
        {filterActive && <View style={styles.filterDot} />}
      </CustomPressable>

      <View style={styles.avatarContainer}>
        <Image
          source={require('../../assets/avatar.png')}
          style={styles.avatar}
        />
        {favoritesCount > 0 && (
          <View style={styles.badge}>
            <Text style={styles.badgeText}>{favoritesCount}</Text>
          </View>
        )}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  filterButton: {
    width: HP(5),
    height: HP(5),
    justifyContent: 'center',
    alignItems: 'center',
  },
  filterDot: {
    position: 'absolute',
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: colors.accent,
    top: 4,
    right: 4,
  },
  avatarContainer: {
    position: 'relative',
  },
  avatar: {
    width: HP(5),
    height: HP(5),
    borderRadius: HP(2.5),
  },
  badge: {
    position: 'absolute',
    top: -6,
    right: -6,
    backgroundColor: colors.accent,
    minWidth: 14,
    height: 14,
    borderRadius: 7,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 4,
  },
  badgeText: {
    fontSize: 9,
    fontWeight: 'bold',
    color: '#fff',
  },
});
