import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Appconstant/app_colors.dart';
import 'Appconstant/carrom_board_painter.dart';
import 'Appconstant/vec_2.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  // Physics
  late PhysicsEngine _physics;
  late List<PhysicsPiece> _pieces;
  late PhysicsPiece _striker;
  Timer? _gameLoop;

  // State
  int _currentPlayer = 1;
  bool _isAiming = true;
  bool _isMoving = false;
  double _strikerX = 5.0;
  double _aimAngle = -90.0;
  double _power = 0.5;

  // Scores
  int _p1Score = 0;
  int _p2Score = 0;
  bool queenPotted = false;
  final bool queenCovered = false;

  // Drag state
  Offset? _dragStart;
  bool _isDraggingStriker = false;
  bool _isDraggingAim = false;

  // UI animations
  late AnimationController _turnAnimController;
  late Animation<double> turnAnim;
  late AnimationController _scoreAnimController;
  String? _lastEvent;
  bool gameOver = false;
  String _statusMessage = "Player 1's Turn — Aim & Flick!";

  // Board display area
  double _boardSize = 340.0;
  Offset _boardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _turnAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
     turnAnim = CurvedAnimation(
        parent: _turnAnimController, curve: Curves.elasticOut);
    _scoreAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _initGame();
  }

  void _initGame() {
    _pieces = [];
    final positions = PhysicsEngine.getInitialPiecePositions();

    // Queen at center (id=0)
    _pieces.add(PhysicsPiece(id: 0, type: 'queen', pos: positions[0]));

    // Inner ring: alternating black/white
    final innerTypes = ['black', 'white', 'black', 'white', 'black', 'white'];
    for (int i = 0; i < 6; i++) {
      _pieces.add(PhysicsPiece(id: i + 1, type: innerTypes[i], pos: positions[i + 1]));
    }

    // Outer ring: alternating
    final outerTypes = ['white', 'black', 'white', 'black', 'white', 'black',
      'white', 'black', 'white', 'black', 'white', 'black'];
    for (int i = 0; i < 12; i++) {
      _pieces.add(PhysicsPiece(id: i + 7, type: outerTypes[i], pos: positions[i + 7]));
    }

    // FIX: Create striker FIRST, then initialize _physics with it
    // This prevents LateInitializationError when _resetStriker tries to update _physics
    final sy = _currentPlayer == 1
        ? GameConfig.player1StrikerY
        : GameConfig.player2StrikerY;
    _striker = PhysicsPiece(id: 99, type: 'striker', pos: Vec2(_strikerX, sy));
    _striker.active = true;

    _physics = PhysicsEngine(pieces: _pieces, striker: _striker);
    _physics.onPiecePotted = _onPiecePotted;
  }

  void _resetStriker() {
    final sy = _currentPlayer == 1
        ? GameConfig.player1StrikerY
        : GameConfig.player2StrikerY;
    _striker = PhysicsPiece(id: 99, type: 'striker', pos: Vec2(_strikerX, sy));
    _striker.active = true;
    // Safe to access _physics here — it's always initialized before _resetStriker
    // is called after the first _initGame()
    _physics.striker = _striker;
  }

  void _onPiecePotted(int pieceId, bool isStriker) {
    if (isStriker) {
      // Penalty: opponent gets 1 point
      if (_currentPlayer == 1) {
        _p2Score += 1;
        _showEvent('Scratch! P2 +1');
      } else {
        _p1Score += 1;
        _showEvent('Scratch! P1 +1');
      }
      // Return striker
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _striker.active = true;
            _striker.pos = Vec2(_strikerX,
                _currentPlayer == 1 ? GameConfig.player1StrikerY : GameConfig.player2StrikerY);
          });
        }
      });
      return;
    }

    final piece = _pieces.firstWhere((p) => p.id == pieceId, orElse: () => _pieces[0]);

    if (piece.type == 'queen') {
      queenPotted = true;
      _showEvent('Queen potted! Cover it!');
      if (_currentPlayer == 1) {
        _p1Score += GameConfig.queenPoints;
      } else {
        _p2Score += GameConfig.queenPoints;
      }
    } else {
      final isOwnPiece = (_currentPlayer == 1 && piece.type == 'black') ||
          (_currentPlayer == 2 && piece.type == 'white');

      if (isOwnPiece) {
        if (_currentPlayer == 1) {
          _p1Score += GameConfig.coinPoints;
          _showEvent('P1 potted! +1');
        } else {
          _p2Score += GameConfig.coinPoints;
          _showEvent('P2 potted! +1');
        }
      } else {
        // Potted opponent's piece - penalty
        if (_currentPlayer == 1) {
          _p2Score += GameConfig.coinPoints;
          _showEvent('P1 foul! P2 +1');
        } else {
          _p1Score += GameConfig.coinPoints;
          _showEvent('P2 foul! P1 +1');
        }
      }
    }
  }

  void _showEvent(String msg) {
    setState(() => _lastEvent = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _lastEvent = null);
    });
  }

  void _shoot() {
    if (!_isAiming || _isMoving) return;
    setState(() {
      _isAiming = false;
      _isMoving = true;
    });
    _striker.active = true;
    _striker.pos = Vec2(_strikerX,
        _currentPlayer == 1 ? GameConfig.player1StrikerY : GameConfig.player2StrikerY);
    _physics.striker = _striker;
    _physics.applyStrikerImpulse(_aimAngle, _power);
    _startGameLoop();
  }

  void _startGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _physics.step();
      if (mounted) setState(() {});

      if (!_physics.anyMoving) {
        timer.cancel();
        _onTurnEnd();
      }
    });
  }

  void _onTurnEnd() {
    final activePieces = _pieces.where((p) => p.active && p.type != 'striker').length;
    if (activePieces == 0 || _p1Score + _p2Score >= 24) {
      setState(() => gameOver = true);
      return;
    }

    _currentPlayer = _currentPlayer == 1 ? 2 : 1;
    setState(() {
      _isAiming = true;
      _isMoving = false;
      // Reset angle to valid range for the new player to avoid Slider assertion error
      // Player 1 shoots upward: -175 to -5 degrees
      // Player 2 shoots downward: 5 to 175 degrees
      _aimAngle = _currentPlayer == 1 ? -90.0 : 90.0;
      _power = 0.5;
      _statusMessage = "Player $_currentPlayer's Turn — Aim & Flick!";
    });
    _resetStriker();
    _turnAnimController.forward(from: 0);
  }

  // Convert screen offset to world coordinates
  Vec2 _screenToWorld(Offset screen) {
    final bx = screen.dx - _boardOffset.dx;
    final by = screen.dy - _boardOffset.dy;
    const margin = 28.0;
    return Vec2(
      (bx - margin) / (_boardSize / GameConfig.worldSize),
      (by - margin) / (_boardSize / GameConfig.worldSize),
    );
  }

  void _onPanStart(DragStartDetails d) {
    if (!_isAiming) return;
    final world = _screenToWorld(d.globalPosition - Offset(0, 0));
    final strikerWorld = Vec2(_strikerX,
        _currentPlayer == 1 ? GameConfig.player1StrikerY : GameConfig.player2StrikerY);
    final dist = (Vec2(world.x, world.y) - strikerWorld).length;

    if (dist < GameConfig.strikerRadius * 2.5) {
      _isDraggingStriker = true;
    } else {
      _isDraggingAim = true;
    }
    _dragStart = d.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_isAiming) return;

    if (_isDraggingStriker) {
      // Move striker horizontally
      final world = _screenToWorld(d.globalPosition);
      setState(() {
        _strikerX = world.x.clamp(
          GameConfig.strikerMinX + GameConfig.strikerRadius,
          GameConfig.strikerMaxX - GameConfig.strikerRadius,
        );
      });
    } else if (_isDraggingAim) {
      // Calculate aim angle from drag direction
      if (_dragStart != null) {
        final delta = d.globalPosition - _dragStart!;
        if (delta.distance > 5) {
          setState(() {
            _aimAngle = atan2(delta.dy, delta.dx) * 180 / pi;
            // Clamp for player direction
            if (_currentPlayer == 1) {
              // Player 1 can shoot upward (roughly -180 to 0)
            }
            // Power based on drag distance
            _power = (delta.distance / 100).clamp(0.1, 1.0);
          });
        }
      }
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isDraggingAim && !_isMoving) {
      _shoot();
    }
    _isDraggingStriker = false;
    _isDraggingAim = false;
    _dragStart = null;
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _turnAnimController.dispose();
    _scoreAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _boardSize = min(screenSize.width - 32, screenSize.height * 0.55);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0A00), Color(0xFF2D1500), Color(0xFF1A0A00)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildScoreBar(),
                const SizedBox(height: 8),
                if (_lastEvent != null) _buildEventBanner(),
                _buildBoard(screenSize),
                const SizedBox(height: 8),
                _buildControls(),
                const SizedBox(height: 8),
                _buildStatusBar(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.gold, size: 18),
            ),
          ),
          Text(
            'CARROM KING',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                 gameOver = false;
                _p1Score = 0;
                _p2Score = 0;
                _currentPlayer = 1;
                _isAiming = true;
                _isMoving = false;
                queenPotted = false;
                _strikerX = 5.0;
                _aimAngle = -90.0;
                _power = 0.5;
                _statusMessage = "Player 1's Turn — Aim & Flick!";
                _initGame();
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgMid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.refresh, color: AppColors.gold, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPlayerCard(1, _p1Score, _currentPlayer == 1),
          const SizedBox(width: 12),
          _buildVsChip(),
          const SizedBox(width: 12),
          _buildPlayerCard(2, _p2Score, _currentPlayer == 2),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int player, int score, bool active) {
    final color = player == 1 ? AppColors.player1Color : AppColors.player2Color;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active
                ? [color.withValues(alpha: 0.25), color.withValues(alpha:0.1)]
                : [AppColors.bgMid, AppColors.bgMid],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color : AppColors.gold.withValues(alpha: 0.15),
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)]
              : [],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(active ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: active ? color : Colors.white38, size: 14),
                const SizedBox(width: 6),
                Text(
                  'PLAYER $player',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: active ? color : Colors.white54,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$score',
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: active ? color : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        'VS',
        style: GoogleFonts.cinzel(
          fontSize: 14,
          color: AppColors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventBanner() {
    return AnimatedOpacity(
      opacity: _lastEvent != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent.withValues(alpha: 0.8), AppColors.accentLight.withValues(alpha: 0.6)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _lastEvent ?? '',
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBoard(Size screenSize) {
    return LayoutBuilder(builder: (context, constraints) {
      final boardSize = min(constraints.maxWidth - 16.0, 380.0);
      _boardSize = boardSize;

      return GestureDetector(
        onPanStart: (d) {
          // Adjust for board position
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            _boardOffset = box.localToGlobal(Offset.zero);
          }
          _onPanStart(DragStartDetails(
            globalPosition: d.globalPosition,
            localPosition: d.localPosition,
          ));
        },
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                size: Size(boardSize, boardSize),
                painter: CarromBoardPainter(
                  pieces: _buildPieceData(),
                  striker: _buildStrikerData(),
                  aimAngle: _aimAngle,
                  power: _power,
                  showAim: _isAiming,
                  currentPlayer: _currentPlayer,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<PieceData> _buildPieceData() {
    return _pieces.map((p) => PieceData(
      x: p.pos.x,
      y: p.pos.y,
      type: p.type,
      active: p.active,
      id: p.id,
    )).toList();
  }

  StrikerData _buildStrikerData() {
    if (!_striker.active && !_isAiming) return StrikerData.zero();
    final sy = _currentPlayer == 1
        ? GameConfig.player1StrikerY
        : GameConfig.player2StrikerY;
    return StrikerData(
      x: _isAiming ? _strikerX : _striker.pos.x,
      y: _isAiming ? sy : _striker.pos.y,
    );
  }

  Widget _buildControls() {
    if (!_isAiming || _isMoving) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pieces moving...',
              style: GoogleFonts.rajdhani(
                color: AppColors.gold.withValues(alpha: 0.7),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Angle control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _controlLabel('ANGLE', '${_aimAngle.toStringAsFixed(0)}°'),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.gold,
                    inactiveTrackColor: AppColors.gold.withValues(alpha: 0.2),
                    thumbColor: AppColors.gold,
                    overlayColor: AppColors.gold.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _currentPlayer == 1
                        ? _aimAngle.clamp(-175.0, -5.0)
                        : _aimAngle.clamp(5.0, 175.0),
                    min: _currentPlayer == 1 ? -175.0 : 5.0,
                    max: _currentPlayer == 1 ? -5.0 : 175.0,
                    onChanged: (v) => setState(() => _aimAngle = v),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Power control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _controlLabel('POWER', '${(_power * 100).toStringAsFixed(0)}%'),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Color.lerp(Colors.green, Colors.red, _power)!,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Color.lerp(Colors.green, Colors.red, _power)!,
                    overlayColor: Colors.white10,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _power,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) => setState(() => _power = v),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Striker position
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _controlLabel('POS', ''),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.strikerColor,
                    inactiveTrackColor: AppColors.strikerColor.withValues(alpha: 0.2),
                    thumbColor: AppColors.strikerColor,
                    overlayColor: AppColors.strikerColor.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _strikerX,
                    min: GameConfig.strikerMinX + GameConfig.strikerRadius,
                    max: GameConfig.strikerMaxX - GameConfig.strikerRadius,
                    onChanged: (v) => setState(() => _strikerX = v),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Shoot button
        GestureDetector(
          onTap: _shoot,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.strikerBorder],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sports_handball, color: Colors.black87, size: 22),
                const SizedBox(width: 8),
                Text(
                  'FLICK!',
                  style: GoogleFonts.rajdhani(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _controlLabel(String label, String value) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: Colors.white38,
              letterSpacing: 1.5,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.bgMid.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPlayer == 1 ? AppColors.player1Color : AppColors.player2Color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_currentPlayer == 1 ? AppColors.player1Color : AppColors.player2Color)
                        .withValues(alpha:0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _statusMessage,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}