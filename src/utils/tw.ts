import { create } from 'twrnc';

// La config est en JS (allowJs) : require la rend compatible avec create().
// eslint-disable-next-line @typescript-eslint/no-require-imports
const tw = create(require('../../tailwind.config.js'));

/** Instance twrnc du projet, utilisée sous le nom `className` : className`flex-1 ...`. */
export const className = tw;

export default tw;