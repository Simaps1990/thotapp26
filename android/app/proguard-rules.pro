# ============================================================
# THOT — ProGuard / R8 rules
# ============================================================
# Flutter framework: Flutter's own rules are bundled with the gradle plugin.
# Plugins below need explicit rules to survive R8 minification.
# ============================================================

# --- Flutter's reflection-based plugin registry ---
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# --- RevenueCat (purchases_flutter) ---
-keep class com.revenuecat.purchases.** { *; }
-keepclassmembers class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# --- flutter_local_notifications ---
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# --- audio_streamer / noise_meter ---
-keep class com.cinemate.audio_streamer.** { *; }
-dontwarn com.cinemate.audio_streamer.**

# --- audioplayers ---
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# --- in_app_update ---
-keep class de.ffuf.in_app_update.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# --- home_widget ---
-keep class es.antonborri.home_widget.** { *; }

# --- file_picker ---
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# --- image_picker ---
-keep class io.flutter.plugins.imagepicker.** { *; }

# --- url_launcher ---
-keep class io.flutter.plugins.urllauncher.** { *; }

# --- path_provider ---
-keep class io.flutter.plugins.pathprovider.** { *; }

# --- shared_preferences ---
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# --- flutter_secure_storage ---
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# --- vibration ---
-keep class de.timestack.flutter_vibration.** { *; }
-keep class com.benjaminabel.vibration.** { *; }

# --- printing / pdf ---
-keep class net.nfet.flutter.printing.** { *; }

# --- local_auth ---
-keep class io.flutter.plugins.localauth.** { *; }
-keep class androidx.biometric.** { *; }

# --- Keep model classes (THOT data layer) ---
# Models are JSON-serialized in/out — keep their fields readable.
-keep class fr.thotbook.app.** { *; }

# --- Kotlin reflection ---
-keepattributes Signature, RuntimeVisibleAnnotations, RuntimeInvisibleAnnotations,
                RuntimeVisibleParameterAnnotations, RuntimeInvisibleParameterAnnotations,
                AnnotationDefault, EnclosingMethod, InnerClasses

# --- Suppress harmless warnings ---
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
