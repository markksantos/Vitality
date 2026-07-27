// Which capture gets which caption, and the brand the frames are drawn in.
// Rendered by ../../_pipeline/marketing/scripts/render.mjs.

export default {
  appName: 'Vitality',
  tagline: 'Meals, pantry, and training in one place — with the nutrition maths done for you.',
  icon: 'icon.png',

  // Sampled from the app icon and the accent green the UI draws with, not
  // eyeballed from a screenshot.
  brand: {
    bgHi: '#F7F9F7',
    bg: '#EDF2EE',
    bgLo: '#DBE5DC',
    ink: '#101A13',
    inkSoft: '#5C6A60',
    accent: '#22C55E',
    bezel: ['#33403A', '#122A1C', '#2A382F'],
    font: 'Inter',
  },

  phoneShots: [
    {
      out: '01-home.png',
      shot: 'shots/01-home.png',
      chip: 'Today',
      headline: 'Calories and macros,\n{already counted}',
      sub: 'Three rings against your own targets, and the day’s meals underneath.',
    },
    {
      out: '02-meals.png',
      shot: 'shots/02-meals.png',
      chip: 'Meals',
      headline: 'Every meal broken\n{down to the gram}',
      sub: 'Protein, carbs, fat and fibre per meal and per item, without a spreadsheet.',
    },
    {
      out: '03-pantry.png',
      shot: 'shots/03-pantry.png',
      chip: 'Pantry',
      headline: 'Know what you\n{already have}',
      sub: 'Pantry, fridge and freezer, sorted by category, with expiry dates tracked.',
    },
    {
      out: '04-fitness.png',
      shot: 'shots/04-fitness.png',
      chip: 'Fitness',
      headline: 'Training and eating,\n{in one app}',
      sub: 'Workouts logged alongside your food, with Apple Health for steps and activity.',
    },
    {
      out: '05-analytics.png',
      shot: 'shots/05-analytics.png',
      chip: 'Trends',
      headline: 'A week you can\n{actually read}',
      sub: 'Averages, nutrition trends, and where the calories actually came from.',
    },
  ],

  beats: [
    { shot: 'shots/01-home.png', caption: 'Your day, already counted', seconds: 3.4 },
    { shot: 'shots/02-meals.png', caption: 'Every meal, to the gram', seconds: 3.2 },
    { shot: 'shots/03-pantry.png', caption: 'Know what you already have', seconds: 3.2 },
    { shot: 'shots/04-fitness.png', caption: 'Training logged alongside food', seconds: 3.2 },
    { shot: 'shots/05-analytics.png', caption: 'Trends you can read', seconds: 3.2 },
  ],
};
