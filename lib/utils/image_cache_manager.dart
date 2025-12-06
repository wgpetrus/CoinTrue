import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

/// Cache Manager customizado para ícones de criptomoedas
/// 
/// Configurado para manter imagens por 30 dias e até 200 arquivos.
class CryptoImageCacheManager {
  static const key = 'cryptoImageCache';
  
  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // Mantém por 30 dias
      maxNrOfCacheObjects: 200, // Até 200 imagens
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
  
  /// Verifica se uma imagem está em cache
  static Future<bool> isInCache(String url) async {
    try {
      final fileInfo = await instance.getFileFromCache(url);
      final inCache = fileInfo != null;
      debugPrint('🖼️ [CACHE] $url: ${inCache ? "HIT" : "MISS"}');
      return inCache;
    } catch (e) {
      debugPrint('❌ [CACHE] Error checking cache: $e');
      return false;
    }
  }
}
