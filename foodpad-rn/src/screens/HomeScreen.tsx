// HomeScreen - écran principal
// Correspondance avec HomeScreen.swift

import React, { useEffect, useRef, useState } from 'react';
import { View, ScrollView, StyleSheet, Text } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { useHomeStore } from '../store/homeStore';
import { useFavoritesStore } from '../store/favoritesStore';
import { HomeHeader } from '../components/HomeHeader';
import { HomeHeadline } from '../components/HomeHeadline';
import { SearchBar } from '../components/SearchBar';
import { CategoryBar } from '../components/CategoryBar';
import { MasonryGrid } from '../components/MasonryGrid';
import { FilterSheet } from '../components/FilterSheet';
import { RootStackParamList } from '../navigation/AppNavigator';
import { Meal } from '../types';
import { typography } from '../theme/typography';
import { colors, HP } from '../theme/tokens';

type HomeScreenProps = NativeStackScreenProps<RootStackParamList, 'Home'>;

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation }) => {
  const {
    categories,
    meals,
    activeCategory,
    searchQuery,
    filter,
    loading,
    error,
    loadCategories,
    loadMeals,
    searchMeals,
    setActiveCategory,
    setSearchQuery,
    setFilter,
  } = useHomeStore();

  const { favorites, isFavorite } = useFavoritesStore();

  const searchTimeoutRef = useRef<number | undefined>(undefined);
  const [filterVisible, setFilterVisible] = useState(false);
  const [tempCategory, setTempCategory] = useState(activeCategory);
  const [tempFavoritesOnly, setTempFavoritesOnly] = useState(filter.favoritesOnly);

  useEffect(() => {
    loadCategories();
    loadMeals(activeCategory);
    useFavoritesStore.getState().loadFavorites();
  }, []);

  useEffect(() => {
    if (searchQuery.length > 0) {
      clearTimeout(searchTimeoutRef.current);
      searchTimeoutRef.current = setTimeout(() => {
        searchMeals(searchQuery);
      }, 400);
    } else {
      loadMeals(activeCategory);
    }
    return () => clearTimeout(searchTimeoutRef.current);
  }, [searchQuery, activeCategory]);

  const handleCategorySelect = (category: string) => {
    setActiveCategory(category);
    setSearchQuery('');
    loadMeals(category);
  };

  const handleFilterPress = () => {
    setTempCategory(activeCategory);
    setTempFavoritesOnly(filter.favoritesOnly);
    setFilterVisible(true);
  };

  const handleFilterApply = () => {
    setActiveCategory(tempCategory);
    setFilter({ category: tempCategory, favoritesOnly: tempFavoritesOnly });
    setSearchQuery('');
    loadMeals(tempCategory);
    setFilterVisible(false);
  };

  const handleFilterReset = () => {
    setTempCategory('Beef');
    setTempFavoritesOnly(false);
  };

  const handleMealPress = (meal: Meal) => {
    navigation.navigate('RecipeDetails', { mealId: meal.idMeal });
  };

  const handleAvatarPress = () => {
    navigation.navigate('Favorites');
  };

  const filteredMeals = filter.favoritesOnly
    ? meals.filter((m) => isFavorite(m.idMeal))
    : meals;

  return (
    <View style={styles.container}>
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.headerSection}>
          <HomeHeader
            onFilterPress={handleFilterPress}
            onAvatarPress={handleAvatarPress}
            favoritesCount={favorites.length}
            filterActive={filter.favoritesOnly}
          />
          <HomeHeadline />
        </View>

        <SearchBar
          value={searchQuery}
          onChangeText={setSearchQuery}
          onClear={() => setSearchQuery('')}
        />

        <CategoryBar
          categories={categories}
          activeCategory={activeCategory}
          onSelectCategory={handleCategorySelect}
        />

        {error && (
          <View style={styles.errorBanner}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        {loading ? (
          <View style={styles.loadingContainer}>
            <Text>Loading...</Text>
          </View>
        ) : (
          <>
            {searchQuery.length === 0 && (
              <Text style={[typography.recipesCount, styles.recipesCount]}>
                {filteredMeals.length} Recipes
              </Text>
            )}
            <MasonryGrid meals={filteredMeals} onMealPress={handleMealPress} />
          </>
        )}
      </ScrollView>

      <FilterSheet
        visible={filterVisible}
        onClose={() => setFilterVisible(false)}
        categories={categories}
        selectedCategory={tempCategory}
        onCategorySelect={setTempCategory}
        favoritesOnly={tempFavoritesOnly}
        onFavoritesToggle={() => setTempFavoritesOnly(!tempFavoritesOnly)}
        onApply={handleFilterApply}
        onReset={handleFilterReset}
      />
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
    gap: 24,
  },
  headerSection: {
    gap: 2,
  },
  recipesCount: {
    marginTop: 8,
  },
  errorBanner: {
    backgroundColor: colors.neutral700,
    borderRadius: 12,
    padding: 12,
  },
  errorText: {
    color: '#fff',
    fontSize: 12,
  },
  loadingContainer: {
    paddingTop: 80,
    height: HP(30),
    justifyContent: 'center',
    alignItems: 'center',
  },
});
