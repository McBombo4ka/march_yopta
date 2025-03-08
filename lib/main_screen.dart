import 'dart:math';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final List<_AnimatedImage> _animatedImages = [];
  final GlobalKey _buttonKey = GlobalKey();
  bool _shouldShowCase = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenShowcase = prefs.getBool('hasSeenShowcase') ?? false;

    if (!hasSeenShowcase) {
      setState(() {
        _shouldShowCase = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([_buttonKey]);
        prefs.setBool('hasSeenShowcase', true); // Сохранить флаг
      });
    }
  }
  void _addImage() {
    setState(() {
      final random = Random();

      double a = random.nextDouble() * -16 + 8; // случайное значение для оси X
      double b = random.nextDouble() * -16 + 8; // случайное значение для оси Y

      // Создаем и добавляем новый анимированный виджет картинки
      _animatedImages.add(_AnimatedImage(
        key: UniqueKey(),
        startOffset: const Offset(0, 0),
        endOffset: Offset(a, b),
        vsync: this,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Showcase(
                key: _buttonKey,
                description: "Нажми на меня!",
                child: const Text(
                  "С 8 марта!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            )
          ]),
          // Все анимированные картинки, созданные по нажатию
          ..._animatedImages,
          // Текст "С днём рождения"
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Освобождаем все контроллеры
    super.dispose();
  }
}

// Класс, представляющий одну анимированную картинку
class _AnimatedImage extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final TickerProvider vsync;

  const _AnimatedImage({
    required Key key,
    required this.startOffset,
    required this.endOffset,
    required this.vsync,
  }) : super(key: key);

  @override
  State<_AnimatedImage> createState() => _AnimatedImageState();
}

class _AnimatedImageState extends State<_AnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;
  late int imageNumber;

  // Добавьте метод для генерации случайного числа в диапазоне от 1 до 8
  int _generateRandomImageNumber() {
    return Random().nextInt(8) + 1; // Генерация числа от 1 до 8
  }

  @override
  void initState() {
    super.initState();

    imageNumber = _generateRandomImageNumber(); // Генерация номера изображения

    _controller = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startOffset,
      end: widget.endOffset,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _positionAnimation.value * 100,
            child: Image.asset(
              "assets/images/march_$imageNumber.jpg",
              width: 150,
            ),
          ),
        );
      },
    );
  }
}
