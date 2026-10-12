import { View, Text } from "react-native";

import BellIcon from "@/assets/BellIcon";
import PersonIcon from "@/assets/PersonIcon";
import { className } from "@/utils/tw";

export default function Home() {
  return (
    <View>
      {/* Header */}
      <View style={className`p-5 py-15 flex-row items-center justify-between `}>
        <PersonIcon />
        <BellIcon />
      </View>
      {/* Header */}

      {/* Content */}
       <View style={className`p-5 pt-0`}>
        <Text style={className`text-lg font-semibold`}>Hello, Armel!</Text>
        <Text style={className`text-3xl font-bold`}>Make your own meals, stay at <Text style={className`text-orange-500`}>Home</Text></Text>
       </View>
      {/* Content */}
    </View>
  );
}
