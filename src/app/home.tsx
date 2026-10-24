import BellIcon from "@/assets/BellIcon";
import PersonIcon from "@/assets/PersonIcon";
import SearchIcon from "@/assets/SearchIcon";
import { className } from "@/utils/tw";
import { FlatList, Image, Text, TextInput, View } from "react-native";
import categories from "../../assets/data/categories.json";

export default function Home() {
  return (
    <View>
      {/* Header */}
      <View style={className`p-5 py-15 flex-row items-center justify-between`}>
        <PersonIcon />
        <BellIcon />
      </View>
      {/* Header */}

      {/* Content */}
      <View style={className`p-5 pt-0`}>
        <Text style={className`text-lg font-semibold`}>Hello, Armel!</Text>
        <Text style={className`text-3xl font-bold`}>
          Make your own meals, stay at{" "}
          <Text style={className`text-orange-500`}>Home</Text>
        </Text>
      </View>
      {/* Content */}

      {/* Search Input */}
      <View
        style={className`bg-gray-200 rounded-full p-1 mx-5 flex-row items-center justify-between gap-2`}
      >
        <TextInput
          placeholder="Search any recipe"
          style={className`flex-1 text-lg p-3 font-montserrat-semibold text-gray-500 rounded-l-full`}
        />
        <View style={className`rounded-full p-3`}>
          <SearchIcon />
        </View>
      </View>
      {/* Search Input */}

      {/* Categories */}
      <View>
        <FlatList
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={className`p-5`}
          data={categories}
          keyExtractor={(item) => item.idCategory}
          renderItem={({ item }) => (
            <View style={className`p-2`}>
              <Image
                source={{ uri: item.strCategoryThumb }}
                style={className`w-15 h-12 rounded-full`}
              />
              <Text
                style={className`text-gray-500 text-center font-semibold mt-1`}
              >
                {item.strCategory}
              </Text>
            </View>
          )}
        />
      </View>
      {/* Categories */}

      {/* Recipes */}
      <View>
        <Text style={className`px-5 text-3xl font-semibold`}>Recipes</Text>
        <View style={className`flex-row justify-between px-5 pt-2`}>
          <View>
            <Image
              source={{ uri: categories[0]?.strCategoryThumb }}
              style={className`h-42 w-42 rounded-lg`}
            />
            <Text style={className`font-semibold text-gray-500 mt-1`}>
              {categories[0]?.strCategory}
            </Text>
          </View>
          <View>
            <Image
              source={{ uri: categories[0]?.strCategoryThumb }}
              style={className`h-42 w-42 rounded-lg`}
            />
            <Text style={className`font-semibold text-gray-500 mt-1`}>
              {categories[0]?.strCategory}
            </Text>
          </View>
        </View>
      </View>
      {/* Recipes */}
    </View>
  );
}
