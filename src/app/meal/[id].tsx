import { getMealById, getMealThumb, type MealDetail as MealDetailType } from "@/services/mealdb";
import { className } from "@/utils/tw";
import { useLocalSearchParams, useRouter } from "expo-router";
import { useEffect, useState } from "react";
import { ActivityIndicator, Image, Pressable, ScrollView, Text, View } from "react-native";

export default function MealDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const [meal, setMeal] = useState<MealDetailType | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const mealId = Array.isArray(id) ? id[0] : id;
    if (!mealId) {
      queueMicrotask(() => {
        setMeal(null);
        setError("Recette introuvable");
        setLoading(false);
      });
      return;
    }
    let cancelled = false;

    queueMicrotask(() => {
      if (cancelled) return;
      setLoading(true);
      setError(null);
      setMeal(null);
    });

    getMealById(String(mealId))
      .then((result) => {
        if (cancelled) return;
        if (!result) {
          setError("Recette introuvable");
          setMeal(null);
          return;
        }
        setMeal(result);
      })
      .catch((cause: unknown) => {
        if (cancelled) return;
        setError(cause instanceof Error ? cause.message : "Erreur de chargement");
        setMeal(null);
      })
      .finally(() => {
        if (cancelled) return;
        setLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [id]);

  const ingredients: { name: string; measure: string }[] = [];
  if (meal) {
    for (let i = 1; i <= 20; i++) {
      const name = meal[`strIngredient${i}`];
      const measure = meal[`strMeasure${i}`];
      if (name && String(name).trim()) {
        ingredients.push({
          name: String(name).trim(),
          measure: measure && String(measure).trim() ? String(measure).trim() : "",
        });
      }
    }
  }

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      contentContainerStyle={className`pb-10`}
    >
      <View style={className`p-5 pt-12 flex-row items-center gap-4`}>
        <Pressable onPress={() => router.back()} style={className`px-3 py-2`}>
          <Text style={className`text-lg`}>←</Text>
        </Pressable>
        <Text style={className`text-xl font-semibold flex-1`} numberOfLines={1}>
          {meal?.strMeal ?? "Recette"}
        </Text>
      </View>

      {loading ? (
        <ActivityIndicator style={className`mt-10`} />
      ) : error ? (
        <Text style={className`px-5 text-red-500`}>{error}</Text>
      ) : meal ? (
        <>
          <Image
            source={{ uri: getMealThumb(meal.strMealThumb, "large") }}
            style={className`w-full h-72`}
          />
          <View style={className`p-5 rounded-t-2xl bg-white gap-4`}>
            <View style={className`flex-row gap-2`}>
              {meal.strCategory ? (
                <View style={className`px-3 py-1 rounded-full bg-orange-100`}>
                  <Text style={className`text-orange-600`}>{meal.strCategory}</Text>
                </View>
              ) : null}
              {meal.strArea ? (
                <View style={className`px-3 py-1 rounded-full bg-gray-200`}>
                  <Text style={className`text-gray-700`}>{meal.strArea}</Text>
                </View>
              ) : null}
            </View>

            <View>
              <Text style={className`text-2xl font-semibold mb-2`}>Ingrédients</Text>
              <View style={className`gap-2`}>
                {ingredients.map((ing, idx) => (
                  <View
                    key={`${ing.name}-${idx}`}
                    style={className`flex-row justify-between border-b border-gray-200 pb-1`}
                  >
                    <Text style={className`text-gray-800`}>{ing.name}</Text>
                    <Text style={className`text-gray-500`}>{ing.measure}</Text>
                  </View>
                ))}
              </View>
            </View>

            <View>
              <Text style={className`text-2xl font-semibold mb-2`}>Instructions</Text>
              <Text style={className`text-gray-700 leading-6`}>
                {meal.strInstructions && meal.strInstructions.trim()
                  ? meal.strInstructions
                  : "Aucune instruction disponible."}
              </Text>
            </View>
          </View>
        </>
      ) : null}
    </ScrollView>
  );
}
