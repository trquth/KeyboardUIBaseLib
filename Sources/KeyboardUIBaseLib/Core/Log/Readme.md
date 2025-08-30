Basic Logging with Tags:

LogUtil.d("UI", "View loaded successfully")
LogUtil.e("NETWORK", "Connection failed")
LogUtil.i("KEYBOARD", "Key pressed: A")

Tag-Based Filtering:

// Skip noisy debug tags during production
LogUtil.skipTags(["VERBOSE_DEBUG", "UI_DETAIL", "ANIMATION"])

// Only show critical logs
LogUtil.setAllowedTags(["ERROR", "WARNING", "CRITICAL"])

// Skip specific component logs
LogUtil.skipTag("NETWORK_VERBOSE")

// Clear filters to see everything again
LogUtil.clearSkippedTags()
LogUtil.clearAllowedTags()

Development vs Production:
#if DEBUG
// Show everything in development
LogUtil.configure(level: .verbose, enabled: true)
LogUtil.clearAllowedTags()
#else
// Only show important logs in production
LogUtil.configure(level: .warning, enabled: true)
LogUtil.setAllowedTags(["ERROR", "WARNING", "CRITICAL"])
#endif
