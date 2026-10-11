// WelcomeScreen - écran d'accueil
// Correspondance avec WelcomeScreen.swift

import React from 'react';
import { View, Text, StyleSheet, ImageBackground } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import LottieView from 'lottie-react-native';
import { colors, HP, WP } from '../theme/tokens';
import { typography } from '../theme/typography';
import { CustomPressable } from '../components/Pressable';
import { RootStackParamList } from '../navigation/AppNavigator';

type WelcomeScreenProps = NativeStackScreenProps<RootStackParamList, 'Welcome'>;

export const WelcomeScreen: React.FC<WelcomeScreenProps> = ({ navigation }) => {
  return (
    <View style={styles.container}>
      <StatusBar style="light" />
      <ImageBackground
        source={require('../../assets/background.png')}
        style={styles.background}
        resizeMode="cover"
      >
        <View style={styles.overlay}>
          <View style={styles.content}>
            <LottieView
              source={require('../../assets/lottie/food-logo.json')}
              style={styles.lottie}
              autoPlay
              loop
            />
            <Text style={[typography.welcomeTitle, { marginTop: HP(10) }]}>FoodPad</Text>
            <Text style={[typography.welcomeSubtitle, { marginTop: HP(2) }]}>
              Explore some delicious Food
            </Text>
          </View>

          <View style={styles.buttonContainer}>
            <CustomPressable
              style={styles.button}
              onPress={() => navigation.navigate('Home')}
            >
              <Text style={typography.welcomeButton}>Get Started</Text>
            </CustomPressable>
          </View>
        </View>
      </ImageBackground>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.accent,
  },
  background: {
    flex: 1,
  },
  overlay: {
    flex: 1,
    backgroundColor: colors.accent,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  lottie: {
    width: WP(40),
    height: HP(40),
  },
  buttonContainer: {
    marginBottom: HP(5),
    paddingHorizontal: WP(5),
  },
  button: {
    backgroundColor: '#fff',
    paddingVertical: HP(1.5),
    paddingHorizontal: WP(5),
    borderRadius: HP(1.5),
    alignItems: 'center',
  },
});
