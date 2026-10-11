// RecipeDetailsScreen - écran de détails
// Correspondance avec RecipeDetailsScreen.swift

import React from 'react';
import { View, Text } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '../navigation/AppNavigator';

type RecipeDetailsScreenProps = NativeStackScreenProps<RootStackParamList, 'RecipeDetails'>;

export const RecipeDetailsScreen: React.FC<RecipeDetailsScreenProps> = () => {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>Recipe Details - Coming Soon</Text>
    </View>
  );
};
