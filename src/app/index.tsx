import { Image, Pressable, Text } from "react-native";
import Animated, { FadeIn, FadeInDown, FadeInUp } from "react-native-reanimated";

import { className } from "@/utils/tw";
import { useRouter } from "expo-router";

export default function Index() {
  const router = useRouter();

  return (
    <Pressable
      onPress={() => router.push("/home")}
      style={className`flex-1 items-center justify-center bg-orange-500 dark:bg-dark-background`}
    >
      <Animated.View
        entering={FadeIn.duration(800)}
        style={className`items-center`}
      >
        <Image
          source={require("@/assets/images/logo.png")}
          style={className`w-70 h-60`}
        />
      </Animated.View>
      <Animated.View entering={FadeInDown.delay(250).duration(600).springify()}>
        <Text
          style={className`text-5xl font-montserrat-bold -mt-8 text-white dark:text-dark-text`}
        >
          Foodpad
        </Text>
      </Animated.View>
      <Animated.View entering={FadeInUp.delay(450).duration(600).springify()}>
        <Text
          style={className`text-lg font-montserrat-semibold text-white dark:text-dark-text`}
        >
          Your recipe in your pocket!
        </Text>
      </Animated.View>
    </Pressable>
  );
}
