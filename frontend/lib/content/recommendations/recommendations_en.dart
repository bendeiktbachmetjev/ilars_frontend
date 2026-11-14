// English translation of the Lithuanian original (recommendations_lt.dart).
import '../../models/recommendations.dart';

const RecommendationsContent recommendationsEn = RecommendationsContent(
  diet: DietContent(
    title:
        'Dietary recommendations for patients who develop low anterior resection syndrome (LARS) after removal of the rectum',
    intro: [
      'After removal of the rectum, patients may have frequent bowel movements, an urgent need to open their bowels, stool leakage or trouble controlling gas. The right choice of foods and dishes, and a diet tailored to each person, is one of the most important tools for easing these unpleasant symptoms.',
      'Here are general dietary recommendations, as well as recommendations arranged by the main food groups.',
    ],
    generalTitle: 'General dietary recommendations',
    generalTips: [
      RecTip(
        id: 'general.portions',
        title: 'Eat small portions often.',
        detail:
            'Instead of 3 large meals a day, choose 5–6 small ones. This helps spread the flow of food evenly through the digestive tract and reduces the load on the bowel.',
      ),
      RecTip(
        id: 'general.chew',
        title: 'Chew your food very well.',
        detail:
            'Digestion starts in the mouth. Well-chewed food is absorbed more easily and irritates the digestive tract less.',
      ),
      RecTip(
        id: 'general.fluids',
        title:
            'Do not drink large amounts of fluids during meals, but drink enough between meals.',
        detail:
            'Fluids speed up the movement of food through the bowel, so drink them 30–60 minutes after a meal.',
      ),
      RecTip(
        id: 'general.diary',
        title: 'Keep a food diary.',
        detail:
            'Everyone’s body reacts differently. Write down which foods you ate and how you felt – this will make it easier to find the foods that suit you best.',
      ),
    ],
    groupsTitle: 'Food groups',
    groups: [
      FoodGroup(
        id: 'meat',
        title: 'Meat, fish, eggs, poultry',
        subtitle: 'A source of high-quality protein',
        intro:
            'Protein is essential for the body to recover after surgery. But when choosing meat, it is important to consider how fatty it is and how it is cooked.',
        advice: [
          FoodAdvice(
            id: 'meat.rec',
            level: RecLevel.recommended,
            text:
                'Lean meat: chicken, turkey, lean beef, as well as white fish and boiled eggs.',
            note:
                'It is better to boil, stew or oven-bake food without too much fat.',
          ),
          FoodAdvice(
            id: 'meat.limit',
            level: RecLevel.limit,
            text:
                'Fatty meat: pork, fatty sausages, smoked, salted or heavily processed meat.',
            note: 'Fatty food stimulates the bowel and can cause diarrhoea.',
          ),
        ],
      ),
      FoodGroup(
        id: 'grains',
        title: 'Bread, grains, pasta',
        subtitle: 'A source of complex carbohydrates',
        intro:
            'Carbohydrates give you energy. But a lot of fibre is not recommended, because it can make the unpleasant symptoms of low anterior resection syndrome (LARS) worse.',
        advice: [
          FoodAdvice(
            id: 'grains.rec',
            level: RecLevel.recommended,
            text:
                'White rice, oat porridge, semolina, white bread or low-fat biscuits (especially in the first months after surgery or during flare-ups).',
            note: 'These foods help thicken the stool and slow down the bowel.',
          ),
          FoodAdvice(
            id: 'grains.limit',
            level: RecLevel.limit,
            text:
                'Wholegrain products, rye bread, bran and whole, unground grains.',
            note:
                'Although fibre is good for your health, insoluble fibre speeds up the bowel. So avoid high-fibre foods at first, and limit them later.',
          ),
        ],
      ),
      FoodGroup(
        id: 'produce',
        title: 'Fruit and vegetables',
        intro:
            'Vegetables and fruit provide the body with vitamins. But some of them can cause a build-up of gas and bloating.',
        advice: [
          FoodAdvice(
            id: 'produce.rec',
            level: RecLevel.recommended,
            text:
                'Boiled, stewed or baked vegetables without skins or seeds (for example carrots, zucchini, pumpkin). Suitable fruit: bananas, baked apples without skins.',
            note:
                'Bananas are especially useful because they help firm up the stool.',
          ),
          FoodAdvice(
            id: 'produce.limit',
            level: RecLevel.limit,
            text:
                'Raw vegetables, especially broccoli, Brussels sprouts, cauliflower, fresh cabbage and sauerkraut. Also onions, garlic, legumes (beans, broad beans, lentils, chickpeas, peas), leeks, radishes and citrus fruits, which can irritate the lining of the bowel.',
          ),
        ],
      ),
      FoodGroup(
        id: 'dairy',
        title: 'Dairy products',
        intro:
            'Dairy products can be hard to digest, because after surgery or treatment the body often handles lactose (milk sugar) less well for a while.',
        advice: [
          FoodAdvice(
            id: 'dairy.rec.fermented',
            level: RecLevel.recommended,
            text:
                'Fermented dairy products (natural yogurt, kefir, buttermilk) in small amounts.',
            note:
                'The good bacteria they contain help keep the gut flora healthy.',
          ),
          FoodAdvice(
            id: 'dairy.rec.alternatives',
            level: RecLevel.recommended,
            text: 'Lactose-free products or hard cheeses are also an option.',
          ),
          FoodAdvice(
            id: 'dairy.limit',
            level: RecLevel.limit,
            text: 'High-fat milk and sweet cream products.',
          ),
        ],
      ),
      FoodGroup(
        id: 'fats',
        title: 'Fats and oils',
        advice: [
          FoodAdvice(
            id: 'fats.rec',
            level: RecLevel.recommended,
            text: 'Olive oil, flaxseed oil.',
            note: 'Use them in small amounts, added to meals.',
          ),
          FoodAdvice(
            id: 'fats.limit',
            level: RecLevel.limit,
            text:
                'Butter, margarine, lard, fatty sauces, mayonnaise, fast food and deep-fried dishes.',
            note: 'They slow down digestion or cause sudden diarrhoea.',
          ),
        ],
      ),
      FoodGroup(
        id: 'drinks',
        title: 'Drinks and spices',
        advice: [
          FoodAdvice(
            id: 'drinks.rec',
            level: RecLevel.recommended,
            text: 'Still water, weak black tea or herbal tea.',
            note: 'Drinks should be at room temperature.',
          ),
          FoodAdvice(
            id: 'drinks.limit.caffeine',
            level: RecLevel.limit,
            text:
                'Drinks with caffeine (strong coffee, black tea, energy drinks) and alcohol.',
            note:
                'Caffeine and carbonation (fizz) stimulate the bowel and bring on an urgent need to open the bowels.',
          ),
          FoodAdvice(
            id: 'drinks.limit.juice',
            level: RecLevel.limit,
            text: 'Fruit juices (especially citrus, plum and apple juice).',
            note:
                'Because they contain a lot of fructose (fruit sugar) and acids.',
          ),
          FoodAdvice(
            id: 'drinks.limit.spices',
            level: RecLevel.limit,
            text:
                'Hot spices, chilli peppers, hot paprika, horseradish, mustard.',
          ),
        ],
      ),
      FoodGroup(
        id: 'sugar',
        title: 'Sugar and sweets',
        advice: [
          FoodAdvice(
            id: 'sugar.limit.sugar',
            level: RecLevel.limit,
            text: 'Sugar, honey, jams.',
            note:
                'A lot of sugar draws water into the bowel and can cause diarrhoea.',
          ),
          FoodAdvice(
            id: 'sugar.limit.sweets',
            level: RecLevel.limit,
            text: 'Chocolate, confectionery, cakes and pastries.',
          ),
          FoodAdvice(
            id: 'sugar.limit.sweeteners',
            level: RecLevel.limit,
            text:
                'Products containing artificial sweeteners (sorbitol, xylitol, mannitol).',
            note:
                'They are often found in chewing gum and sugar-free sweets. They have a strong laxative effect.',
          ),
        ],
      ),
      FoodGroup(
        id: 'fatty',
        title: 'Fatty and processed food',
        advice: [
          FoodAdvice(
            id: 'fatty.avoid.fried',
            level: RecLevel.avoid,
            text:
                'Deep-fried food and food fried in fat (French fries, meat fried in batter and so on).',
          ),
          FoodAdvice(
            id: 'fatty.avoid.meats',
            level: RecLevel.avoid,
            text:
                'Fatty meat products: cured pork fat, fatty pork, fatty sausages, smoked meat products.',
          ),
          FoodAdvice(
            id: 'fatty.avoid.sauces',
            level: RecLevel.avoid,
            text: 'Fatty sauces: mayonnaise, ready-made sauces with additives.',
          ),
        ],
      ),
    ],
    reintroduction: RecTip(
      id: 'reintroduction',
      title: 'Bringing foods back into your diet',
      detail:
          'Over time, you can try to shorten the list of foods you have given up or limited. A few months after surgery, you can try bringing foods back into your diet one at a time, in very small amounts. If your LARS symptoms do not get worse within 24 hours, you can keep that food in your diet.',
    ),
  ),
  exercise: ExerciseContent(
    title:
        'Exercise programme and physical activity recommendations for iLARS patients',
    goalsTitle: 'Programme goals',
    goals: [
      RecTip(
        id: 'goal.activity',
        title: 'Make sure you are physically active.',
        detail:
            'The aim is to reach 150–300 minutes of physical activity a week by walking, as recommended by the World Health Organization (WHO).',
      ),
      RecTip(
        id: 'goal.pelvic',
        title: 'Improve how your pelvic floor muscles work.',
      ),
    ],
    sections: [
      ExerciseSection(
        id: 'activity',
        title: 'Physical activity',
        exercises: [
          Exercise(
            id: 'walk',
            title: 'Therapeutic walking',
            numbered: false,
            dose: ['At least 20–\u206030\u00a0min a day'],
            steps: [
              'Walk outdoors.',
              'It is important to walk at a pace that takes effort and makes you breathe faster.',
              'Whenever possible, take the stairs instead of the lift.',
            ],
          ),
        ],
      ),
      ExerciseSection(
        id: 'training',
        title: 'Specialised training',
        badge: 'about 30\u00a0min',
        exercises: [
          Exercise(
            id: 'squat',
            title: 'Modified chair squat',
            dose: [
              '3 sets of 10–\u206015\u00a0reps',
              'Rest 60–\u206090\u00a0s between sets',
            ],
            steps: [
              'Use a sturdy, stable chair without wheels.',
              'Sit down on the chair slowly and in a controlled way.',
              'Stand up from the chair, knees straight.',
              'Keep your back straight as you stand up.',
              'If this is difficult, use a chair with a higher seat, or you may support yourself with your hands on the armrests.',
            ],
          ),
          Exercise(
            id: 'adductor',
            title:
                'Strengthening exercises for the adductors (inner thigh muscles)',
            dose: ['3 sets of 10–\u206015\u00a0reps'],
            steps: [
              'Use a small ball or an exercise device made for this (the “aid”).',
              'With control, squeeze the aid between your knees, hold the squeeze for 2–3 seconds, then slowly release.',
              'You can do them lying on your back or sitting.',
              'The movement must be controlled. Avoid jerking and straining.',
            ],
          ),
          Exercise(
            id: 'massage',
            title: 'Self-massage and/or rolling of the inner ankle area',
            steps: [
              'Massage the inner ankle area of both legs, where the tibial nerve lies close to the surface of the skin.',
              'Use a massage roller, a hard ball or your hands.',
              'Massage the inner ankle area with circular movements (the tibial nerve runs close to the skin here).',
              'If you feel tingling or pain, reduce the pressure.',
            ],
          ),
          Exercise(
            id: 'kegel',
            title: 'Kegel exercises',
            requiresUnlock: true,
            dose: [
              'At least 60 times a day (3\u00a0sessions\u00a0of\u00a020)',
              'Recommended: 120 times a day (3\u00a0sessions\u00a0of\u00a040)',
            ],
            steps: [
              'Tighten your pelvic floor muscles to 50% of your strongest squeeze and hold for 10 seconds. If you cannot hold for 10 seconds, hold for a shorter time, but the goal is 10 seconds.',
              'Do them lying on your back or sitting.',
              'After each session of Kegel exercises, do diaphragmatic (belly) breathing exercises for 2–3 minutes.',
            ],
          ),
        ],
      ),
    ],
  ),
);
