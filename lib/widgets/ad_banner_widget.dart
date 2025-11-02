import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/premium_service.dart';

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
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _checkPremiumAndLoadAd();
  }

  Future<void> _checkPremiumAndLoadAd() async {
    // Vérifier si l'utilisateur est premium
    _isPremium = await PremiumService.isPremiumUser();

    if (_isPremium) {
      print(
          '[AdBannerWidget-${widget.placement}] 🚫 Utilisateur premium - aucune pub');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Charger la bannière
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    try {
      print('[AdBannerWidget-${widget.placement}] 🔄 Chargement bannière...');

      final ad = await AdService.createBannerAd();

      if (ad != null && mounted) {
        setState(() {
          _bannerAd = ad;
          _isLoading = false;
        });

        // Charger l'annonce
        await _bannerAd!.load();
        print('[AdBannerWidget-${widget.placement}] ✅ Bannière chargée');
      } else {
        setState(() {
          _isLoading = false;
        });
        print(
            '[AdBannerWidget-${widget.placement}] ⚠️ Impossible de créer la bannière');
      }
    } catch (e) {
      print('[AdBannerWidget-${widget.placement}] ❌ Erreur chargement: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
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
    // Ne rien afficher si premium ou erreur de chargement
    if (_isPremium || (_bannerAd == null && !_isLoading)) {
      return const SizedBox.shrink();
    }

    // Afficher un placeholder pendant le chargement
    if (_isLoading) {
      return Container(
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      );
    }

    // Afficher la bannière
    return Container(
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}





