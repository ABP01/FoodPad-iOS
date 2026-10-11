// FavoritesScreen - écran des favoris
// Correspondance avec FavoritesScreen.swift

import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { colors, HP, WP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from '../components/Pressable';
import { MasonryGrid } from '../components/MasonryGrid';
import { useFavoritesStore } from '../store/favoritesStore';
import { RootStackParamList } from '../navigation/AppNavigator';
import { mealsApi } from '../services/mealsApi';
import { Meal } from '../types';

type FavoritesScreenProps = NativeStackScreenProps<RootStackParamList, 'Favorites'>;

export const FavoritesScreen: React.FC<FavoritesScreenProps> = ({
  navigation,
}) => {
  const { favorites, loadFavorites, removeAll, isFavorite } = useFavoritesStore();
  const [favoriteMeals, setFavoriteMeals] = React.useState<Meal[]>([]);

  useEffect(() => {
    loadFavorites();
  }, []);

  useEffect(() => {
    loadFavoriteMeals();
  }, [favorites]);

  const loadFavoriteMeals = async () => {
    if (favorites.length === 0) {
      setFavoriteMeals([]);
      return;
    }

    try {
      const meals = await Promise.all(
        favorites.map((fav) => mealsApi.lookupById(fav.id))
      );
      setFavoriteMeals(meals);
    } catch (error) {
      console.error('Failed to load favorite meals:', error);
    }
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const handleClearFavorites = () => {
    Alert.alert(
      'Remove all favorites?',
      'This cannot be undone.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Remove All',
          style: 'destructive',
          onPress: () => removeAll(),
        },
      ]
    );
  };

  const handleMealPress = (meal: Meal) => {
    navigation.navigate('RecipeDetails', { mealId: meal.idMeal });
  };

  const handleBrowseRecipes = () => {
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <CustomPressable style={styles.backButton} onPress={handleBack}>
            <Ionicons
              name="chevron-back"
              size={HP(2)}
              color={colors.accent}
            />
          </CustomPressable>

          <Text style={[typography.homeHeadline, styles.title]}>
            My Favorites
          </Text>

          <View style={{ width: HP(4) }} />

          {favorites.length > 0 && (
            <CustomPressable
              style={styles.trashButton}
              onPress={handleClearFavorites}
            >
              <Ionicons name="trash-outline" size={HP(2)} color={colors.neutral500} />
            </CustomPressable>
          )}
        </View>

        {favorites.length === 0 ? (
          <View style={styles.emptyState}>
            <Ionicons
              name="heart-outline"
              size={HP(8)}
              color={colors.accent + '59'}
            />
            <Text style={typography.detailMealName}>No Favorites Yet</Text>
            <Text style={[typography.instructions, styles.emptyText]}>
              Tap the heart on any recipe to keep it here for later.
            </Text>
            <CustomPressable
              style={styles.browseButton}
              onPress={handleBrowseRecipes}
            >
              <Text style={typography.welcomeButton}>Browse Recipes</Text>
            </CustomPressable>
          </View>
        ) : (
          <MasonryGrid meals={favoriteMeals} onMealPress={handleMealPress} />
        )}
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingHorizontal: 16,
    paddingTop: 56,
    paddingBottom: 50,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 24,
  },
  backButton: {
    width: HP(4),
    height: HP(4),
    borderRadius: HP(2),
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    flex: 1,
    color: colors.neutral800,
  },
  trashButton: {
    width: HP(4),
    height: HP(4),
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyState: {
    alignItems: 'center',
    paddingTop: HP(12),
    gap: 16,
  },
  emptyText: {
    color: colors.neutral500,
    textAlign: 'center',
    paddingHorizontal: 32,
  },
  browseButton: {
    backgroundColor: '#fff',
    paddingVertical: HP(1.2),
    paddingHorizontal: WP(4),
    borderRadius: HP(1.5),
    alignItems: 'center',
    marginTop: HP(8),
  },
});
