# Flutter Wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Drift / SQLite native rules
-keep class com.simonbinder.sqlite3.** { *; }
-keep class io.simonbinder.sqlite3.** { *; }
-keep class net.sqlcipher.** { *; }
-keepclassmembers class * extends package:drift/drift.dart { *; }

# Flutter Secure Storage
-keep class com.it_effekt.flutter_secure_storage.** { *; }

# Share Plus & Path Provider
-keep class dev.fluttercommunity.plus.share.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Core / SplitCompat R8 rules
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
