import { View, type ViewProps } from 'react-native';

import type { ThemeColor } from '@/constants/theme';

export type ThemedViewProps = ViewProps & {
  lightColor?: string;
  darkColor?: string;
  type?: ThemeColor;
};

/** Classes Tailwind (NativeWind) appliquées selon la couleur de thème. */
const colorClasses: Record<ThemeColor, string> = {
  background: 'bg-background dark:bg-dark-background',
  backgroundElement: 'bg-background-element dark:bg-dark-element',
  backgroundSelected: 'bg-background-selected dark:bg-dark-selected',
  text: 'bg-foreground dark:bg-dark-foreground',
  textSecondary: 'bg-foreground-secondary dark:bg-dark-secondary',
};

export function ThemedView({
  style,
  className,
  lightColor,
  darkColor,
  type,
  ...otherProps
}: ThemedViewProps) {
  return (
    <View
      className={[colorClasses[type ?? 'background'], className].filter(Boolean).join(' ')}
      style={style}
      {...otherProps}
    />
  );
}