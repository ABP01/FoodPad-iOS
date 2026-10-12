import { Image, Pressable, Text } from "react-native";

import { className } from "@/utils/tw";
import { useRouter } from "expo-router";

export default function Index() {
  const router = useRouter();

  return (
    <Pressable
      onPress={() => router.push("/home")}
      style={className`flex-1 items-center justify-center bg-orange-500 dark:bg-dark-background`}
    >
      <Image
        source={require("@/assets/images/logo.png")}
        style={className`w-70 h-60`}
      />
      <Text
        style={className`text-5xl font-montserrat-bold text-white dark:text-dark-text`}
      >
        Foodpad
      </Text>
      <Text
        style={className`text-lg font-montserrat-semibold text-white dark:text-dark-text`}
      >
        Your recipe in your pocket!
      </Text>
    </Pressable>
  );
}
