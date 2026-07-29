# ML Kit Text Recognition ProGuard / R8 rules
-dontwarn com.google.mlkit.vision.text.**
-keep class com.google.mlkit.vision.text.** { *; }

# TensorFlow Lite (tflite_flutter) ProGuard / R8 rules
#
# R8 fails the release build with "Missing class
# org.tensorflow.lite.gpu.GpuDelegateFactory$Options". The TFLite Java wrapper
# references the GPU delegate unconditionally, but the GPU delegate artifact is a
# separate optional dependency this app does not ship — inference runs on CPU via
# XNNPACK. So the reference is genuinely absent rather than mis-stripped, and
# silencing it is correct; adding the GPU artifact would grow the APK for a
# delegate that is never used.
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
