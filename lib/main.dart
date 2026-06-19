import 'package:flutter/material.dart';
import 'package:dog_friendly_map/utils/translations.dart';

void main() {
  runApp(const MyApp());
}

// === БЛОК 1: СВЯЗКА ИЗ ДВУХ КЛАССОВ ДЛЯ MYAPP ===

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
} // <-- ТУТ МЫ ЗАКРЫЛИ ПЕРВЫЙ КЛАСС!

// Теперь второй класс стоит РЯДОМ, а не внутри
class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Метод build переехал СЮДА — внутрь класса состояния
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog-Friendly Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: _themeMode, // <-- ИСПРАВЛЕНО: заменили ";" на запятую

      // ИСПРАВЛЕНО: убрали "const", так как данные динамические
      home: MainMapScreen(
        currentThemeMode: _themeMode,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}


// === БЛОК 2: СВЯЗКА ДЛЯ ЭКРАНА КАРТЫ (ПРИНИМАЕТ НАСТРОЙКИ) ===

class MainMapScreen extends StatefulWidget {
  // ИСПРАВЛЕНО: Научили класс принимать переменные сверху (наши "пропсы")
  final ThemeMode currentThemeMode;
  final VoidCallback onThemeToggle;

  const MainMapScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeToggle,
  });

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  
  String _currentLang = 'ru';

  final List<String> _categories = ['cafe', 'restaurant', 'park', 'playground'];
String _selectedCategory = 'cafe'; // И тут тоже системное слово! 

  void _toggleLanguage() {
    setState(() {
      if (_currentLang == 'ru') {
        _currentLang = 'en';
      } else if (_currentLang == 'en') {
        _currentLang = 'ua';
      } else {
        _currentLang = 'ru';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Создаем удобную булеву переменную для проверки темы
    final isDark = widget.currentThemeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [

          // СЛОЙ 1: Заглушка под будущую карту (теперь меняет цвет!)
          Container(
            width: double.infinity,
            height: double.infinity,
            // Если тема темная — красим в темно-серый, если светлая — в светло-серый
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  // Text(
                  //   'нюхай хуй',
                  //   style: TextStyle(
                  //     color: isDark ? Colors.grey[400] : Colors.grey,
                  //     fontSize: 18,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // СЛОЙ 2: Верхняя панель управления (Поиск и Фильтры)
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Строка поиска
                Card(
                  elevation: 4,
                  // Меняем цвет карточки поиска под тему
                  color: isDark ? Colors.grey[850] : Colors.white,
                  child: TextField(
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: AppTranslations.data[_currentLang]!['search_hint']!,
                      hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Горизонтальный список фильтров
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(AppTranslations.data[_currentLang]![category]!),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // СЛОЙ 3: Кнопка-переключатель темы
          Positioned(
            bottom: 40,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: isDark ? Colors.green[700] : Colors.green,
              onPressed: () {
                widget.onThemeToggle();
              },
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white,
              ),
            ),
          ),

          // СЛОЙ 4: Кнопка переключения языка
          Positioned(
            bottom: 40,
            left: 16, // Ставим слева, чтобы не налезла на кнопку темы
            child: FloatingActionButton(
              // Важно: если на экране две таких кнопки, им нужны разные теги, иначе Flutter ругнется
              heroTag: 'lang_btn', 
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              onPressed: _toggleLanguage, // Вызываем нашу функцию из Шага 1
              child: Text(
                // Выводим текущий язык большими буквами (RU, EN, UA)
                _currentLang.toUpperCase(), 
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // --------------------------------

        ],
      ),
    );
  }
}