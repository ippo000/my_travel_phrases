import 'dart:async';
import 'package:flutter/material.dart';

class LoadingWithTips extends StatefulWidget {
  const LoadingWithTips({super.key});

  @override
  State<LoadingWithTips> createState() => _LoadingWithTipsState();
}

class _LoadingWithTipsState extends State<LoadingWithTips> {
  int currentTipIndex = 0;
  Timer? tipTimer;

  final List<String> irishTips = [
    '🍀 「Sláinte」で乾杯します',
    '🌧️ 雨が多いので傘は必需品',
    '🍺 ギネスビール発祥の地',
    '🎵 パブでライブ演奏を楽しめます',
    '🏰 ダブリン城は800年の歴史',
    '📚 トリニティカレッジの図書館',
    '🌊 モハーの断崖は絶景スポット',
    '🍀 シャムロックは国のシンボル',
    '🥔 アイリッシュシチューが有名',
    '🎭 親しみやすい人が多い',
    '☘️ 聖パトリックの日は祝日',
    '🏛️ 「文学の都」ダブリン',
    '🐑 田園風景に羊がたくさん',
    '🌈 雨上がりによく虹が見える',
    '🎪 アイリッシュダンスが有名',
    '🏺 世界最古のウイスキー',
    '🚌 2階建てバスが便利',
    '🎨 美術館や博物館が豊富',
    '🌿 「エメラルドの島」',
    '🎯 「craic」で楽しい時間'
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    tipTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          currentTipIndex = (currentTipIndex + 1) % irishTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    tipTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI処理中...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'アイルランド豆知識',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    irishTips[currentTipIndex],
                    key: ValueKey(currentTipIndex),
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}