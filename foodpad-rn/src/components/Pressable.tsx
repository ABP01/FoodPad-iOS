// Pressable avec animation scale/opacity
// Correspondance avec PressableStyle dans SwiftUI

import React from 'react';
import { Pressable, PressableProps, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  Easing,
} from 'react-native-reanimated';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

interface CustomPressableProps extends PressableProps {
  children: React.ReactNode;
}

export const CustomPressable: React.FC<CustomPressableProps> = ({
  children,
  style,
  ...props
}) => {
  const scale = useSharedValue(1);
  const opacity = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  const handlePressIn = () => {
    scale.value = withTiming(0.94, {
      duration: 120,
      easing: Easing.out(Easing.ease),
    });
    opacity.value = withTiming(0.85, {
      duration: 120,
      easing: Easing.out(Easing.ease),
    });
  };

  const handlePressOut = () => {
    scale.value = withTiming(1, {
      duration: 120,
      easing: Easing.out(Easing.ease),
    });
    opacity.value = withTiming(1, {
      duration: 120,
      easing: Easing.out(Easing.ease),
    });
  };

  return (
    <AnimatedPressable
      style={[animatedStyle, style]}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      {...props}
    >
      {children}
    </AnimatedPressable>
  );
};
