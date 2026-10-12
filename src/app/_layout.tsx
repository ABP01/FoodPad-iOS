import { useFonts } from "expo-font";
import { Stack } from "expo-router";
import { useDeviceContext } from "twrnc";

import { className } from "@/utils/tw";

export default function RootLayout() {
  // Active les préfixes dépendants du contexte (dark:, breakpoints, plateforme)
  useDeviceContext(className);

  // Charge Montserrat (nécessaire pour Expo Go / web ; le plugin expo-font
  // l'embarque aussi au build natif).
  const [fontsLoaded, fontError] = useFonts({
    "Montserrat-Regular": require("@/assets/fonts/Montserrat-Regular.ttf"),
    "Montserrat-SemiBold": require("@/assets/fonts/Montserrat-SemiBold.ttf"),
    "Montserrat-Bold": require("@/assets/fonts/Montserrat-Bold.ttf"),
  });

  if (!fontsLoaded && !fontError) return null;

  return <Stack screenOptions={{ headerShown: false }} />;
}
