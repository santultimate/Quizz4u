import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/enhanced_purchase_service.dart';
import '../services/premium_service.dart';
import '../services/translation_service.dart';

class EnhancedPremiumScreen extends StatefulWidget {
  const EnhancedPremiumScreen({super.key});

  @override
  State<EnhancedPremiumScreen> createState() => _EnhancedPremiumScreenState();
}

class _EnhancedPremiumScreenState extends State<EnhancedPremiumScreen>
    with TickerProviderStateMixin {
  bool _isPremium = false;
  bool _isLoading = false;
  List<String> _benefits = [];
  Map<String, ProductDetails> _subscriptionOptions = {};

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadPremiumStatus();
    _initializePurchaseService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _loadPremiumStatus() async {
    final isPremium = await PremiumService.isPremiumUser();
    // Récupérer les bénéfices traduits
    final benefits = [
      TranslationService.translate('benefit_ad_free'),
      TranslationService.translate('benefit_xp_bonus'),
      TranslationService.translate('benefit_honest_stats'),
      TranslationService.translate('benefit_exclusive_badges'),
    ];

    setState(() {
      _isPremium = isPremium;
      _benefits = benefits;
    });
  }

  Future<void> _initializePurchaseService() async {
    try {
      await EnhancedPurchaseService.initialize();
      final subscriptions = EnhancedPurchaseService.getSubscriptionOptions();

      setState(() {
        _subscriptionOptions = subscriptions;
      });
    } catch (e) {
      print('[EnhancedPremiumScreen] ❌ Erreur initialisation: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple[700],
        title: Text(
          TranslationService.translate('premium_title'),
          style: const TextStyle(
            fontFamily: 'Signatra',
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isPremium ? _buildPremiumUserView() : _buildUpgradeView(),
    );
  }

  Widget _buildUpgradeView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Message d'info mode test (si aucun produit disponible)
            if (_subscriptionOptions.isEmpty)
              Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        TranslationService.translate('test_mode_message'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // En-tête premium avec animation
            _buildAnimatedHeader(),

            const SizedBox(height: 30),

            // Tableau comparatif Gratuit vs Premium
            _buildComparisonTable(),

            const SizedBox(height: 30),

            // Options d'achat
            _buildPurchaseOptions(),

            const SizedBox(height: 30),

            // Avantages premium
            _buildBenefitsSection(),

            const SizedBox(height: 30),

            // Garantie et sécurité
            _buildSecuritySection(),

            const SizedBox(height: 20),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('comparison_title'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          // En-têtes du tableau
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  TranslationService.translate('features_label'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  TranslationService.translate('free_label'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    TranslationService.translate('premium_label'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),

          // Lignes de comparaison (bénéfices réellement livrés)
          _buildComparisonRow(
              TranslationService.translate('ads_premium'),
              TranslationService.translate('ads_free'),
              TranslationService.translate('ads_premium_value')),
          _buildComparisonRow(
              TranslationService.translate('benefit_xp_bonus'),
              TranslationService.translate('no'),
              TranslationService.translate('yes')),
          _buildComparisonRow(
              TranslationService.translate('benefit_honest_stats'),
              TranslationService.translate('basic'),
              TranslationService.translate('complete')),
          _buildComparisonRow(
              TranslationService.translate('exclusive_badges'),
              TranslationService.translate('no'),
              TranslationService.translate('yes')),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, String free, String premium) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontFamily: 'Raleway',
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontFamily: 'Raleway',
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                premium,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.amber,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  TranslationService.translate('unlock_premium'),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontFamily: 'Signatra',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationService.translate('premium_access'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPurchaseOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('choose_your_option'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Achat unique premium
          _buildPurchaseOption(
            title: TranslationService.translate('lifetime_premium'),
            price: EnhancedPurchaseService.getFormattedPrice(),
            description: TranslationService.translate('lifetime_premium_desc'),
            icon: Icons.diamond,
            isRecommended: true,
            onTap: () => _purchasePremium(),
          ),

          const SizedBox(height: 15),

          // Options d'abonnement si disponibles
          if (_subscriptionOptions.isNotEmpty) ...[
            for (final entry in _subscriptionOptions.entries)
              _buildPurchaseOption(
                title: entry.key == 'monthly'
                    ? TranslationService.translate('monthly_subscription')
                    : TranslationService.translate('annual_subscription'),
                price: entry.value.price,
                description: entry.key == 'monthly'
                    ? TranslationService.translate('monthly_subscription_desc')
                    : TranslationService.translate('annual_subscription_desc'),
                icon: entry.key == 'monthly'
                    ? Icons.calendar_month
                    : Icons.calendar_today,
                isRecommended: false,
                onTap: () => _purchaseSubscription(entry.value.id),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPurchaseOption({
    required String title,
    required String price,
    required String description,
    required IconData icon,
    required bool isRecommended,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isRecommended
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isRecommended
                  ? Colors.amber
                  : Colors.white.withValues(alpha: 0.3),
              width: isRecommended ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRecommended
                      ? Colors.amber
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isRecommended ? Colors.black : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isRecommended ? Colors.amber : Colors.white,
                              fontFamily: 'Raleway',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'TOP',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontFamily: 'Raleway',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isRecommended ? Colors.amber : Colors.white,
                  fontFamily: 'Raleway',
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('premium_benefits'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ..._benefits.take(6).map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          if (_benefits.length > 6)
            Text(
              TranslationService.translateWithParams(
                  'and_more_benefits', {'count': '${_benefits.length - 6}'}),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.security,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationService.translate('secure_payment'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TranslationService.translate('secure_payment_desc'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Raleway',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Restaurer les achats
        TextButton.icon(
          onPressed: _isLoading ? null : _restorePurchases,
          icon: const Icon(Icons.restore, color: Colors.amber),
          label: Text(
            TranslationService.translate('restore_purchases'),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontFamily: 'Raleway',
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Continuer gratuitement
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            TranslationService.translate('continue_free'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              fontFamily: 'Raleway',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumUserView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Badge premium
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  TranslationService.translate('premium_user'),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'Signatra',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationService.translate('premium_user_desc'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Raleway',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Toutes les fonctionnalités
          _buildAllFeaturesSection(),
        ],
      ),
    );
  }

  Widget _buildAllFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationService.translate('all_your_features'),
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ..._benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EnhancedPurchaseService.purchasePremium(
        onSuccess: (details) {
          setState(() {
            _isLoading = false;
            _isPremium = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(TranslationService.translate('subscription_activated')),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onCancel: () {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(TranslationService.translate('subscription_cancelled')),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );

      if (!success) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _purchaseSubscription(String productId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EnhancedPurchaseService.purchaseSubscription(
        productId,
        onSuccess: (details) {
          setState(() {
            _isLoading = false;
            _isPremium = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(TranslationService.translate('subscription_activated')),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onCancel: () {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(TranslationService.translate('subscription_cancelled')),
              backgroundColor: Colors.orange,
            ),
          );
        },
      );

      if (!success) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await EnhancedPurchaseService.restorePurchases();

      setState(() {
        _isLoading = false;
      });

      if (success) {
        setState(() {
          _isPremium = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Achats restaurés avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ℹ️ Aucun achat à restaurer'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
