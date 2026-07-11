import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_policy.dart';
import '../services/ad_service.dart';

/// Widget réutilisable pour afficher des bannières publicitaires
/// Usage: AdBannerWidget(placement: 'home')
class AdBannerWidget extends StatefulWidget {
  /// Identifiant de l'emplacement pour le tracking
  final String placement;

  /// Hauteur personnalisée (par défaut: 50)
  final double height;

  /// Marge personnalisée
  final EdgeInsets margin;

  const AdBannerWidget({
    super.key,
    required this.placement,
    this.height = 50,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoading = true;
  bool _shouldShow = false;

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  Future<void> _initAd() async {
    final allowed = await AdPolicy.canShow(AdFormat.banner);

    if (!mounted) return;

    if (!allowed) {
      print('[AdBannerWidget-${widget.placement}] 🚫 Masquée (AdPolicy)');
      setState(() {
        _isLoading = false;
        _shouldShow = false;
      });
      return;
    }

    try {
      print('[AdBannerWidget-${widget.placement}] 🔄 Chargement bannière...');
      final ad = await AdService.createBannerAd();

      if (!mounted) {
        ad?.dispose();
        return;
      }

      if (ad != null) {
        setState(() {
          _bannerAd = ad;
          _isLoading = false;
          _shouldShow = true;
        });
        print('[AdBannerWidget-${widget.placement}] ✅ Bannière prête');
      } else {
        setState(() {
          _isLoading = false;
          _shouldShow = false;
        });
        print(
            '[AdBannerWidget-${widget.placement}] ⚠️ Bannière non disponible');
      }
    } catch (e) {
      print('[AdBannerWidget-${widget.placement}] ❌ Erreur: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _shouldShow = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShow && !_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isLoading) {
      return Container(
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      height: widget.height,
      margin: widget.margin,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
