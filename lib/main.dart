import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const SlidePuzzleApp());
}

class SlidePuzzleApp extends StatelessWidget {
  const SlidePuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slide Puzzle',
      theme: ThemeData(
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SlidePuzzle(),
    );
  }
}

class SlidePuzzle extends StatefulWidget {
  const SlidePuzzle({super.key});

  @override
  _SlidePuzzleState createState() => _SlidePuzzleState();
}

class _SlidePuzzleState extends State<SlidePuzzle> {
  late List<int?> tiles;
  final int numberOfItems = 41;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    tiles = List<int?>.generate(numberOfItems, (index) => index + 1)
      ..add(null); // Inicializa aqui
    tiles.shuffle(); // Embaralha o tabuleiro ao iniciar
    _loadInterstitialAd(); // Carrega o anúncio ao iniciar
    _showInterstitialAd(); // Mostra o anúncio ao abrir o app
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-5885833079588983/6256670248',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdReady) {
      _interstitialAd?.show();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      _loadInterstitialAd();
    }
  }

  bool canMove(int index) {
    int emptyIndex = tiles.indexOf(null);
    int row = index ~/ 6;
    int col = index % 6;
    int emptyRow = emptyIndex ~/ 6;
    int emptyCol = emptyIndex % 6;
    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void moveTile(int index) {
    if (canMove(index)) {
      setState(() {
        int emptyIndex = tiles.indexOf(null);
        tiles[emptyIndex] = tiles[index];
        tiles[index] = null;
      });
      if (isWinning()) {
        _showInterstitialAd();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Você venceu!'),
              content: const Text('Parabéns, você organizou as peças!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void resetGame() {
    setState(() {
      tiles = List<int?>.generate(numberOfItems, (index) => index + 1)
        ..add(null);
      tiles.shuffle();
    });
  }

  bool isWinning() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    int itemCount = tiles.length; // Total de peças
    int columns = 6; // Número de colunas
    double size = (MediaQuery.of(context).size.width - 40) / columns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Slide Puzzle'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size * (itemCount / columns).ceil() +
                50, // Altura baseada na quantidade de itens
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns, // Número de colunas
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                if (tiles[index] == null) {
                  return Container(color: Colors.black); // Espaço vazio
                } else {
                  return GestureDetector(
                    onTap: () => moveTile(index),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: Colors.white, // Cor da peça
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${tiles[index]}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // Texto preto
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: resetGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.black, // Botão preto
            ),
            child: const Text('Reiniciar Jogo'),
          ),
        ],
      ),
    );
  }
}
