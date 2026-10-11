// RecipeDetailsScreen - écran de détails
// Correspondance avec RecipeDetailsScreen.swift

import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Linking,
  Alert,
} from 'react-native';
import { Image } from 'expo-image';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { StatusBar } from 'expo-status-bar';
import { Ionicons } from '@expo/vector-icons';
import Animated, {
  FadeInDown,
  useSharedValue,
  withSpring,
} from 'react-native-reanimated';
import { colors, radius, HP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from '../components/Pressable';
import { IngredientsList } from '../components/IngredientsList';
import { mealsApi } from '../services/mealsApi';
import { useFavoritesStore } from '../store/favoritesStore';
import { RootStackParamList } from '../navigation/AppNavigator';
import { Meal } from '../types';

type RecipeDetailsScreenProps = NativeStackScreenProps<
  RootStackParamList,
  'RecipeDetails'
>;

const AnimatedPressable = Animated.createAnimatedComponent(CustomPressable);

export const RecipeDetailsScreen: React.FC<RecipeDetailsScreenProps> = ({
  route,
  navigation,
}) => {
  const { mealId } = route.params;
  const [meal, setMeal] = useState<Meal | null>(null);
  const [loading, setLoading] = useState(true);
  const { isFavorite, toggleFavorite } = useFavoritesStore();

  const scale = useSharedValue(1);

  useEffect(() => {
    loadMeal();
  }, [mealId]);

  const loadMeal = async () => {
    try {
      setLoading(true);
      const data = await mealsApi.lookupById(mealId);
      setMeal(data);
    } catch (error) {
      Alert.alert('Error', 'Failed to load recipe details');
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const handleFavoritePress = () => {
    if (meal) {
      toggleFavorite(meal);
      scale.value = withSpring(scale.value === 1 ? 1.2 : 1, {
        damping: 12,
        stiffness: 90,
      });
    }
  };

  const handleYoutubePress = async () => {
    if (meal?.strYoutube) {
      const youtubeUrl = meal.strYoutube;
      try {
        const supported = await Linking.canOpenURL('youtube://');
        if (supported) {
          await Linking.openURL(`youtube://${youtubeUrl.split('v=')[1]}`);
        } else {
          await Linking.openURL(youtubeUrl);
        }
      } catch (error) {
        await Linking.openURL(youtubeUrl);
      }
    }
  };

  const handleSourcePress = async () => {
    if (meal?.strSource) {
      await Linking.openURL(meal.strSource);
    }
  };

  if (loading || !meal) {
    return (
      <View style={styles.loadingContainer}>
        <Text>Loading...</Text>
      </View>
    );
  }

  const favorite = isFavorite(meal.idMeal);

  return (
    <View style={styles.container}>
      <StatusBar style="light" />
      <ScrollView
        style={styles.scrollView}
        showsVerticalScrollIndicator={false}
      >
        <Image
          source={{ uri: meal.strMealThumb || undefined }}
          style={styles.heroImage}
          contentFit="cover"
          cachePolicy="disk"
        />

        <View style={styles.topBar}>
          <AnimatedPressable
            style={styles.iconButton}
            onPress={handleBack}
            entering={FadeInDown.delay(200).springify()}
          >
            <Ionicons name="arrow-back" size={HP(2)} color={colors.accent} />
          </AnimatedPressable>

          <AnimatedPressable
            style={styles.iconButton}
            onPress={handleFavoritePress}
            entering={FadeInDown.delay(250).springify()}
          >
            <Animated.View style={{ transform: [{ scale }] }}>
              <Ionicons
                name={favorite ? 'heart' : 'heart-outline'}
                size={HP(2)}
                color={favorite ? colors.accent : colors.neutral500}
              />
            </Animated.View>
          </AnimatedPressable>
        </View>

        <View style={styles.sheet}>
          <Animated.View
            style={styles.header}
            entering={FadeInDown.delay(300).springify()}
          >
            <Text style={typography.detailMealName}>{meal.strMeal}</Text>
            <Text style={typography.detailArea}>{meal.strArea}</Text>
          </Animated.View>

          <Animated.View
            style={styles.linksContainer}
            entering={FadeInDown.delay(350).springify()}
          >
            {meal.strYoutube && (
              <CustomPressable
                style={styles.linkButton}
                onPress={handleYoutubePress}
              >
                <View style={styles.linkIcon}>
                  <Ionicons
                    name="logo-youtube"
                    size={HP(2)}
                    color={colors.neutral700}
                  />
                </View>
                <Text style={typography.detailArea}>Watch on YouTube</Text>
                <Ionicons
                  name="arrow-forward"
                  size={HP(1.4)}
                  color={colors.neutral700}
                />
              </CustomPressable>
            )}

            {meal.strSource && (
              <CustomPressable
                style={styles.linkButton}
                onPress={handleSourcePress}
              >
                <View style={styles.linkIcon}>
                  <Ionicons
                    name="globe-outline"
                    size={HP(2)}
                    color={colors.neutral700}
                  />
                </View>
                <Text style={typography.detailArea}>View Source</Text>
                <Ionicons
                  name="arrow-forward"
                  size={HP(1.4)}
                  color={colors.neutral700}
                />
              </CustomPressable>
            )}
          </Animated.View>

          <Animated.View
            entering={FadeInDown.delay(400).springify()}
          >
            <Text style={typography.detailSectionTitle}>Ingredients</Text>
            <IngredientsList meal={meal} />
          </Animated.View>

          <Animated.View
            style={styles.instructionsContainer}
            entering={FadeInDown.delay(450).springify()}
          >
            <Text style={typography.detailSectionTitle}>Instructions</Text>
            <Text style={typography.instructions}>{meal.strInstructions}</Text>
          </Animated.View>
        </View>
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  heroImage: {
    width: '100%',
    height: HP(45),
  },
  topBar: {
    position: 'absolute',
    top: HP(14),
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
  },
  iconButton: {
    width: HP(4),
    height: HP(4),
    borderRadius: HP(2),
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
  },
  sheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: radius.sheet,
    borderTopRightRadius: radius.sheet,
    marginTop: -46,
    paddingTop: HP(3),
    paddingHorizontal: 16,
    paddingBottom: 30,
  },
  header: {
    gap: 2,
    marginBottom: 24,
  },
  linksContainer: {
    gap: 12,
    marginBottom: 24,
  },
  linkButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    backgroundColor: colors.cardPlaceholder,
    padding: 12,
    borderRadius: 16,
  },
  linkIcon: {
    width: HP(3),
    height: HP(3),
    borderRadius: 10,
    backgroundColor: 'rgba(64, 64, 64, 0.1)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  instructionsContainer: {
    gap: 12,
  },
});
