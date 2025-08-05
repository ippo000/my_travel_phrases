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
    '🍀 アイルランドでは「Sláinte」（スローンチェ）で乾杯します',
    '🌧️ アイルランドは雨が多いので、傘は必需品です',
    '🍺 ギネスビールはアイルランドが発祥の地です',
    '🎵 アイルランドは音楽の国。パブでライブ演奏を楽しめます',
    '🏰 ダブリン城は800年以上の歴史があります',
    '📚 トリニティカレッジには美しい図書館があります',
    '🌊 モハーの断崖は絶景スポットとして有名です',
    '🍀 シャムロック（三つ葉のクローバー）は国のシンボルです',
    '🥔 アイリッシュシチューは伝統的な家庭料理です',
    '🎭 アイルランド人は話し上手で親しみやすい人が多いです',
    '☘️ 聖パトリックの日（3月17日）は国民の祝日です',
    '🏛️ ダブリンは「文学の都」として知られています',
    '🐑 アイルランドの田園風景には羊がたくさんいます',
    '🌈 雨上がりによく虹が見えることで有名です',
    '🎪 アイルランドの伝統舞踊「アイリッシュダンス」は世界的に有名です',
    '🏺 アイルランドウイスキーは世界最古のウイスキーの一つです',
    '🚌 ダブリンの2階建てバスは観光にも便利です',
    '🎨 アイルランドには多くの美術館や博物館があります',
    '🌿 アイルランドは「エメラルドの島」と呼ばれています',
    '🎯 アイルランド人は「craic」（クラック）という言葉で楽しい時間を表現します'
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    tipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          const Text(
            'AI処理中...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'アイルランド豆知識',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    irishTips[currentTipIndex],
                    key: ValueKey(currentTipIndex),
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 1,
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