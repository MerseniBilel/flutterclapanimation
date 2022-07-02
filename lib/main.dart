import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

enum ScoreWidgetStatus { HIDDEN, BECOMING_VISIBLE, BECOMING_INVISIBLE }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int counter = 0;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
  final duration = const Duration(milliseconds: 400);
  final oneSecond = const Duration(seconds: 1);
  late AnimationController scoreInAnimationController,
      scoreOutAnimationController;
  late Animation scoreOutPosition;

  @override
  void initState() {
    super.initState();

    scoreInAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    scoreInAnimationController.addListener(() {
      setState(() {});
    });

    scoreInAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
        scoreOutAnimationController.forward(from: 0.0);
      }
    });

    scoreOutAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    scoreOutPosition = Tween<double>(
      begin: 200.0,
      end: 250.0,
    ).animate(CurvedAnimation(
        parent: scoreOutAnimationController, curve: Curves.easeOut));

    scoreOutPosition.addListener(() {
      setState(() {});
    });

    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });
  }

  void startAnimation() {
    if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN) {
      scoreInAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    }
    setState(() {
      counter++;
    });
  }

  @override
  void dispose() {
    super.dispose();
    scoreInAnimationController.dispose();
    scoreOutAnimationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          centerTitle: true,
          elevation: 0,
          title: const Text("Clap Animation"),
        ),
        body: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PinkScore(
                scoreInAnimationController: scoreInAnimationController,
                counter: counter,
                scoreWidgetStatus: _scoreWidgetStatus,
                scoreOutPosition: scoreOutPosition,
                scoreOutAnimationController: scoreOutAnimationController,
              ),
              Positioned(
                child: GestureDetector(
                  onTap: () => startAnimation(),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.pink, width: 1.0),
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(color: Colors.pink, blurRadius: 8.0)
                        ]),
                    padding: const EdgeInsets.all(10.0),
                    child: const ImageIcon(
                      AssetImage("assets/clap.png"),
                      size: 40,
                      color: Colors.pink,
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class PinkScore extends StatelessWidget {
  PinkScore({
    Key? key,
    required this.scoreInAnimationController,
    required this.scoreOutPosition,
    required this.scoreOutAnimationController,
    required this.counter,
    required this.scoreWidgetStatus,
  }) : super(key: key);

  final AnimationController scoreInAnimationController;
  final Animation scoreOutPosition;
  final AnimationController scoreOutAnimationController;
  final int counter;
  final ScoreWidgetStatus scoreWidgetStatus;

  double scorePosition = 0;
  double scoreOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    switch (scoreWidgetStatus) {
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.BECOMING_VISIBLE:
        scorePosition = scoreInAnimationController.value * 190;
        scoreOpacity = scoreInAnimationController.value;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scoreOpacity = 1.0 - scoreOutAnimationController.value;
        scorePosition = scoreOutPosition.value; 
        break;
    }
    return Positioned(
      bottom: scorePosition,
      child: Opacity(
        opacity: scoreOpacity,
        child: Container(
          alignment: Alignment.center,
          height: 100.0,
          width: 100.0,
          decoration: const ShapeDecoration(
            shape: CircleBorder(side: BorderSide.none),
            color: Colors.pink,
          ),
          child: Text(
            "+ $counter",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
