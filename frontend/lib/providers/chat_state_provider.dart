import 'package:flutter_riverpod/flutter_riverpod.dart';

final isChatScreenOpenProvider = StateProvider.autoDispose<bool>((ref) => false);