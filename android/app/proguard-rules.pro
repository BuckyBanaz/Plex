# Paste any contents of build/.../missing_rules.txt here (if present)
# (R8 will sometimes generate exact rules — if you have that file, paste it above)

# Keep Stripe push provisioning classes referenced by the bridge
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivity* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningActivityStarter* { *; }
-keep class com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider { *; }
-keep class com.stripe.android.pushProvisioning.EphemeralKeyUpdateListener { *; }

# Keep react-native stripe bridge push provisioning classes (if present)
-keep class com.reactnativestripesdk.pushprovisioning.** { *; }

# Keep Stripe SDK core classes (conservative; prevents R8 from removing reflection-used code)
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }

# Keep reactnative stripe bridge classes (safe)
-keep class com.reactnativestripesdk.** { *; }

# Avoid warnings from Stripe libs (optional but helpful)
-dontwarn com.stripe.**
-dontwarn com.reactnativestripesdk.**

# Keep native/jni and JS interface members often used by reflection
-keepclassmembers class * {
    native <methods>;
}
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
