import { Text, type TextProps } from 'react-native';

import type { ThemeColor } from '@/constants/theme';
import { className } from '@/utils/tw';

export type ThemedTextProps = TextProps & {
  type?: 'default' | 'title' | 'small' | 'smallBold' | 'subtitle' | 'link' | 'linkPrimary' | 'code';
  themeColor?: ThemeColor;
};

/** Classes Tailwind (twrnc) appliquées selon la variante typographique. */
const typeClasses: Record<NonNullable<ThemedTextProps['type']>, string> = {
  default: 'font-montserrat text-base leading-6',
  title: 'font-montserrat-bold text-5xl leading-[52px]',
  small: 'font-montserrat text-sm leading-5',
  smallBold: 'font-montserrat-bold text-sm leading-5',
  subtitle: 'font-montserrat-semibold text-[32px] leading-[44px]',
  link: 'font-montserrat text-sm leading-[30px]',
  linkPrimary: 'font-montserrat text-sm leading-[30px] text-primary',
  code: 'font-mono text-xs',
};

/** Classes Tailwind (twrnc) appliquées selon la couleur de thème. */
const colorClasses: Record<ThemeColor, string> = {
  text: 'text-foreground dark:text-dark-foreground',
  background: 'text-background dark:text-dark-background',
  backgroundElement: 'text-background-element dark:text-dark-element',
  backgroundSelected: 'text-background-selected dark:text-dark-selected',
  textSecondary: 'text-foreground-secondary dark:text-dark-secondary',
};

export function ThemedText({ style, type = 'default', themeColor, ...rest }: ThemedTextProps) {
  return (
    <Text
      style={[className.style(colorClasses[themeColor ?? 'text'], typeClasses[type]), style]}
      {...rest}
    />
  );
}