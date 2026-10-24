import BellIcon from "@/assets/BellIcon";
import PersonIcon from "@/assets/PersonIcon";
import SearchIcon from "@/assets/SearchIcon";
import { className } from "@/utils/tw";
import { useMealDbLists } from "@/hooks/use-mealdb-lists";
import { useMealFilter } from "@/hooks/use-meal-filter";
import { useMealSearch } from "@/hooks/use-meal-search";
import { useRandomMeals } from "@/hooks/use-random-meals";
import { getCategoryThumb, getMealThumb } from "@/services/mealdb";
import { useRouter } from "expo-router";
import { useMemo, useState } from "react";
import {
  ActivityIndicator,
  Image,
  Pressable,
  ScrollView,
  Text,
  TextInput,
  View,
} from "react-native";

type FilterTab = "category" | "area" | "ingredient";

export default function Home() {
  const router = useRouter();
  const { categories, areas, ingredients, loading: listsLoading } = useMealDbLists();
  const [activeTab, setActiveTab] = useState<FilterTab>("category");
  const [selected, setSelected] = useState<{ type: FilterTab; value: string } | null>(
    null,
  );
  const [searchQuery, setSearchQuery] = useState("");

  const filter = useMemo(
    () => (selected ? { type: selected.type, value: selected.value } : null),
    [selected],
  );
  const { meals: filteredMeals, loading: mealsLoading, error: filterError } = useMealFilter(filter);
  const { meals: searchedMeals, loading: searchLoading, error: searchError } = useMealSearch(searchQuery);
  const { meals: randomMeals, loading: randomLoading } = useRandomMeals(8);

  const isSearching = searchQuery.trim().length > 0;
  const isFiltering = Boolean(selected);
  const meals = isSearching ? searchedMeals : isFiltering ? filteredMeals : randomMeals;
  const mealsLoadingState = isSearching ? searchLoading : isFiltering ? mealsLoading : randomLoading;
  const errorState = isSearching ? searchError : isFiltering ? filterError : null;

  const tabs: { key: FilterTab; label: string }[] = [
    { key: "category", label: "Categories" },
    { key: "area", label: "Area" },
    { key: "ingredient", label: "Ingredients" },
  ];

  const listData = useMemo(() => {
    try {
      if (activeTab === "area") {
        return (Array.isArray(areas) ? areas : [])
          .map((a) => a?.strArea)
          .filter((v): v is string => typeof v === "string" && v.trim().length > 0);
      }
      if (activeTab === "ingredient") {
        return (Array.isArray(ingredients) ? ingredients : [])
          .map((i) => i?.strIngredient)
          .filter((v): v is string => typeof v === "string" && v.trim().length > 0);
      }
      return (Array.isArray(categories) ? categories : [])
        .map((c) => c?.strCategory)
        .filter((v): v is string => typeof v === "string" && v.trim().length > 0);
    } catch {
      return [];
    }
  }, [activeTab, areas, categories, ingredients]);

  const handleSelect = (value: string) => {
    if (selected?.type === activeTab && selected.value === value) {
      setSelected(null);
      return;
    }
    setSelected({ type: activeTab, value });
  };

  return (
    <ScrollView
      showsVerticalScrollIndicator={false}
      contentContainerStyle={className`pb-10`}
    >
      {/* Header */}
      <View style={className`p-5 py-15 flex-row items-center justify-between`}>
        <PersonIcon />
        <BellIcon />
      </View>
      {/* Header */}

      {/* Content */}
      <View style={className`p-5 pt-0 -mt-10`}>
        <Text style={className`text-lg font-semibold`}>Hello, Armel!</Text>
        <Text style={className`text-3xl font-bold`}>
          Make your own meals, stay at{" "}
          <Text style={className`text-orange-500`}>Home</Text>
        </Text>
      </View>
      {/* Content */}

      {/* Search Input */}
      <View
        style={className`bg-gray-200 rounded-full mx-5 flex-row items-center overflow-hidden`}
      >
        <TextInput
          placeholder="Search any recipe"
          value={searchQuery}
          onChangeText={(text) => {
            setSearchQuery(text);
            if (text.trim()) {
              setSelected(null);
            }
          }}
          returnKeyType="search"
          autoCorrect={false}
          placeholderTextColor="#6b7280"
          style={className`flex-1 h-12 px-4 text-base font-montserrat-semibold text-gray-700`}
        />
        <Pressable onPress={() => setSearchQuery("")} style={className`px-4 h-12 items-center justify-center`}>
          <SearchIcon />
        </Pressable>
      </View>
      {/* Search Input */}

      {!isSearching ? (
        <>
          {/* Tabs */}
          <View style={className`flex-row gap-2 px-5 mt-6`}>
            {tabs.map((tab) => {
              const isActive = activeTab === tab.key;
              return (
                <Pressable
                  key={tab.key}
                  onPress={() => {
                    setActiveTab(tab.key);
                    setSelected(null);
                  }}
                  style={className`px-4 py-2 rounded-full ${
                    isActive ? "bg-orange-500" : "bg-gray-200"
                  }`}
                >
                  <Text
                    style={className`font-semibold ${
                      isActive ? "text-white" : "text-gray-600"
                    }`}
                  >
                    {tab.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
          {/* Tabs */}

          {/* Lists */}
          <View>
            {Array.isArray(listData) && listData.length > 0 ? (
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                contentContainerStyle={className`p-5`}
              >
                {listData.slice(0, 100).map((item, index) => {
                  const value = typeof item === "string" ? item.trim() : String(item || "").trim();
                  if (!value) return null;
                  const isSelected = selected?.type === activeTab && selected.value === value;
                  try {
                    return (
                      <Pressable
                        key={`${activeTab}-${value}-${index}`}
                        onPress={() => handleSelect(value)}
                        style={className`p-2`}
                      >
                        {activeTab === "category" ? (
                          <Image
                            source={{ uri: getCategoryThumb(value) }}
                            style={className`w-15 h-12 rounded-full ${
                              isSelected ? "border-2 border-orange-500" : ""
                            }`}
                          />
                        ) : (
                          <View
                            style={className`w-15 h-12 rounded-full items-center justify-center bg-gray-200 ${
                              isSelected ? "border-2 border-orange-500" : ""
                            }`}
                          >
                            <Text style={className`font-semibold text-gray-700`} numberOfLines={1}>
                              {value.slice(0, 2).toUpperCase()}
                            </Text>
                          </View>
                        )}
                        <Text
                          style={className`text-gray-500 text-center font-semibold mt-1 ${
                            isSelected ? "text-orange-500" : ""
                          }`}
                          numberOfLines={1}
                        >
                          {value}
                        </Text>
                      </Pressable>
                    );
                  } catch {
                    return null;
                  }
                })}
              </ScrollView>
            ) : null}
            {listsLoading ? <ActivityIndicator style={className`pb-2`} /> : null}
          </View>
          {/* Lists */}
        </>
      ) : null}

      {/* Recipes */}
      <View>
        <Text style={className`px-5 mt-2 text-3xl font-semibold`}>
          {isSearching ? "Résultats" : "Recipes"}
        </Text>
        <View style={className`px-5 pt-4 gap-4`}>
          {mealsLoadingState ? (
            <ActivityIndicator />
          ) : errorState ? (
            <Text style={className`text-red-500`}>{errorState}</Text>
          ) : meals.length === 0 ? (
            <Text style={className`text-gray-500`}>
              {isSearching
                ? "Aucun résultat pour cette recherche."
                : isFiltering
                ? "Aucune recette trouvée pour ce filtre."
                : "Aucune recette aléatoire disponible."}
            </Text>
          ) : (
            (Array.isArray(meals) ? meals : []).slice(0, 80).map((meal, idx) => {
              if (!meal?.idMeal) return null;
              try {
                return (
                  <Pressable
                    key={String(meal.idMeal) + idx}
                    onPress={() => router.push(`/meal/${meal.idMeal}`)}
                    style={className`flex-row items-center gap-4`}
                  >
                    <Image
                      source={{ uri: getMealThumb(meal.strMealThumb) }}
                      style={className`h-20 w-24 rounded-xl`}
                    />
                    <View style={className`flex-1`}>
                      <Text style={className`text-lg font-semibold`} numberOfLines={1}>
                        {meal.strMeal}
                      </Text>
                    </View>
                  </Pressable>
                );
              } catch {
                return null;
              }
            })
          )}
        </View>
      </View>
      {/* Recipes */}
    </ScrollView>
  );
}
