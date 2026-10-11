// HomeHeadline - titre "Food You Love"
// Correspondance avec HomeHeadline dans Components.swift

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme/tokens';
import { typography } from '../theme/typography';

export const HomeHeadline: React.FC = () => {
  return (
    <View style={styles.container}>
      <Text style={typography.homeHeadline}>Food You </Text>
      <Text style={[typography.homeHeadlineAccent, { color: colors.accent }]}>
        Love
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 2,
  },
});
