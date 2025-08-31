# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }

# Keep TTS
-keep class com.tundralabs.fluttertts.** { *; }

# Keep AdMob
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep SharedPreferences
-keep class androidx.preference.** { *; }

# Keep Lottie
-keep class com.airbnb.lottie.** { *; }

# Keep AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }

# Keep Google Fonts
-keep class androidx.core.content.res.** { *; }

# Keep Confetti
-keep class com.github.jinatonic.confetti.** { *; }

# Keep URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# Keep Share Plus
-keep class io.flutter.plugins.share.** { *; }

# Keep In-App Purchase
-keep class com.android.billingclient.** { *; }

# Keep Shimmer
-keep class com.facebook.shimmer.** { *; }

# Keep Animated Text Kit
-keep class com.anilbeesetti.nextxylevel.** { *; }

# Keep Flutter SVG
-keep class com.github.brianegan.flutter_svg.** { *; }

# Keep Cached Network Image
-keep class com.github.brianegan.cached_network_image.** { *; }

# Keep Flame
-keep class flame.** { *; }

# Keep Staggered Animations
-keep class com.mobiten.flutter_staggered_animations.** { *; }

# General Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R8 rules
-keepattributes InnerClasses
-keep class **.R$* {
    public static <fields>;
}

# Keep Play Core classes
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep missing classes from R8 error
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.OnFailureListener { *; }
-keep class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keep class com.google.android.play.core.tasks.Task { *; } 