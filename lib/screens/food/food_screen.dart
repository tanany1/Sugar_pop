import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class Meal {
  final String name;
  final String description;
  final List<String> ingredients;
  final String preparation;
  final String imageUrl;
  final String nutritionalInfo;

  Meal({
    required this.name,
    required this.description,
    required this.ingredients,
    required this.preparation,
    required this.imageUrl,
    this.nutritionalInfo = '',
  });
}

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Food Recipes'),
        centerTitle: true,
        backgroundColor: AppColors.primary1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryCard(
              title: 'Adult Meals',
              description: 'Healthy meals for adults with diabetes',
              color: AppColors.primary3,
              icon: Icons.restaurant,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealsListScreen(
                      category: 'adult',
                      title: 'Adult Meals',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            CategoryCard(
              title: 'Children Meals',
              description: 'Special healthy meals for children',
              color: AppColors.primary3,
              icon: Icons.child_care,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealsListScreen(
                      category: 'children',
                      title: 'Children Meals',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class MealsListScreen extends StatelessWidget {
  final String category;
  final String title;

  const MealsListScreen({
    super.key,
    required this.category,
    required this.title,
  });

  List<Meal> get meals {
    if (category == 'adult') {
      return [
        Meal(
          name: 'Grilled Eggplant Moussaka',
          description: 'Healthy Egyptian dish for diabetics. Grilled eggplant with vegetables in a tomato sauce.',
          ingredients: [
            '2 eggplants, sliced',
            '1 green pepper',
            '2 grated tomatoes',
            '1 chopped onion',
            '1 tablespoon olive oil',
            'Garlic, salt, cumin'
          ],
          preparation: 'Grill the eggplant and pepper in the oven. In a pan, sauté the onion and garlic with oil, add tomatoes and spices. Stir the mixture and add the grilled vegetables. Let it simmer and serve.',
          imageUrl: 'https://www.feastingathome.com/wp-content/uploads/2013/03/epplant-moussaka-227.jpg',
        ),
        Meal(
          name: 'Healthy Brown Koshari',
          description: 'A diabetic-friendly version of the traditional Egyptian dish made with brown rice and whole wheat pasta.',
          ingredients: [
            '½ cup brown lentils',
            '½ cup brown rice',
            '¼ cup whole wheat pasta',
            'Light tomato sauce',
            'Baked onions (no frying)'
          ],
          preparation: 'Boil the lentils and pasta. Cook the rice with the lentils. Serve with the sauce and baked onions.',
          imageUrl: 'https://images.squarespace-cdn.com/content/v1/57dd5fb1d1758eccab1961da/1555574539929-42BZKKDKLHPWGUSLWR51/P1370166-2.jpg',
        ),
        Meal(
          name: 'Chicken Okra Tagine',
          description: 'A flavorful tagine dish with lean chicken and okra, perfect for diabetes management.',
          ingredients: [
            '200g okra',
            '1 chicken breast, diced',
            '2 grated tomatoes',
            'Onion and garlic',
            '1 tablespoon olive oil',
            'Spices (dried coriander, black pepper, cinnamon)'
          ],
          preparation: 'Sauté the onion and garlic, add chicken until browned. Add tomatoes, okra, and spices. Pour into a tagine dish and bake until fully cooked.',
          imageUrl: 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2',
        ),
        Meal(
          name: 'Quinoa Vegetable Salad',
          description: 'A nutritious salad with quinoa and fresh vegetables.',
          ingredients: [
            '½ cup washed quinoa',
            '1 cup water',
            'Chopped cucumber',
            'Cherry tomatoes',
            'Colorful bell peppers',
            '1 tablespoon olive oil',
            'Juice of half a lemon',
            'Salt and dried mint'
          ],
          preparation: 'Boil quinoa until cooked. Drain and let it cool. Add vegetables, olive oil, and lemon juice. Mix ingredients and serve cold.',
          imageUrl: 'https://images.unsplash.com/photo-1505576399279-565b52d4ac71',
          nutritionalInfo: 'Calories: 220 | Carbohydrates: 25g',
        ),
        Meal(
          name: 'Healthy Lentil Soup',
          description: 'A nutritious soup with red lentils and vegetables.',
          ingredients: [
            '½ cup red lentils',
            '1 grated carrot',
            '1 small onion',
            '1 tablespoon olive oil',
            'Spices: cumin, turmeric, black pepper',
            '2 cups water or vegetable stock'
          ],
          preparation: 'Sauté onion in olive oil, add carrot, lentils, and spices. Add water and let boil, then blend with an immersion blender.',
          imageUrl: 'https://images.unsplash.com/photo-1547592180-85f173990554',
          nutritionalInfo: 'Calories: 180 | Carbohydrates: 28g',
        ),
        Meal(
          name: 'Herb Grilled Chicken',
          description: 'Lean grilled chicken breast with aromatic herbs.',
          ingredients: [
            'Skinless chicken breast',
            'Lemon juice',
            '1 tablespoon olive oil',
            'Crushed garlic',
            'Rosemary, thyme, black pepper'
          ],
          preparation: 'Marinate the chicken and let it sit for 30 minutes. Grill on a grill pan or bake in the oven until cooked through.',
          imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435',
          nutritionalInfo: 'Calories: 200 | Carbohydrates: 0g',
        ),
      ];
    } else {
      return [
        Meal(
          name: 'Oatmeal and Banana Pancakes',
          description: 'Kid-friendly diabetic pancakes made with oats and banana.',
          ingredients: [
            '½ ripe banana',
            '1 egg',
            '2 tablespoons ground oats',
            'Sprinkle of cinnamon'
          ],
          preparation: 'Mix all ingredients and cook on a non-stick pan. Serve with a little yogurt or fresh fruit pieces.',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaalN-0qarKeDQ-fN5LIM6MluQuv0JD_tGSQ&s',
        ),
        Meal(
          name: 'Tuna and Potato Balls',
          description: 'Tasty bite-sized tuna and potato balls for children.',
          ingredients: [
            '1 small boiled potato',
            '½ can drained tuna',
            '1 egg',
            'Chopped parsley, sprinkle of cumin'
          ],
          preparation: 'Mix all ingredients, shape into small balls, and bake in the oven until browned. Suitable as a light meal or dinner.',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTG_wmRo2CXfG1ToYgvd0QTb1qiEKySpFwfgQ&s',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return MealCard(
            name: meal.name,
            description: meal.description,
            imageUrl: meal.imageUrl,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailScreen(meal: meal),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailScreen extends StatelessWidget {
  final Meal meal;

  const MealDetailScreen({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              meal.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 80),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.ingredients
                        .map((ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preparation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.preparation,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (meal.nutritionalInfo.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Nutritional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      meal.nutritionalInfo,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}