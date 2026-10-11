import { Text, View } from 'react-native';

export default function Index() {
  return (
    <View className="flex-1 items-center justify-center bg-background">
      <Text className="font-montserrat-bold text-4xl text-foreground dark:text-dark-foreground">
        Welcome to the Index
      </Text>
    </View>
  );
}