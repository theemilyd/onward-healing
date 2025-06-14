# RevenueCat Integration Setup Guide

## Overview
Onward uses RevenueCat for subscription management with the following pricing:
- **Weekly**: $6.99/week with 3-day free trial
- **Yearly**: $49.99/year (50% off, no trial)

## Setup Steps

### 1. RevenueCat Dashboard Setup
1. Create account at [app.revenuecat.com](https://app.revenuecat.com)
2. Create new app for "Onward"
3. Copy your API key from Dashboard > API Keys
4. Update `RevenueCatConfig.apiKey` in the code

### 2. App Store Connect Setup
Create these in-app purchase products:

**Weekly Subscription:**
- Product ID: `onward_weekly_6_99`
- Type: Auto-renewable subscription
- Price: $6.99 USD
- Duration: 1 week
- Free trial: 3 days

**Yearly Subscription:**
- Product ID: `onward_yearly_49_99`
- Type: Auto-renewable subscription  
- Price: $49.99 USD
- Duration: 1 year
- No free trial

### 3. RevenueCat Configuration
1. **Products**: Add both product IDs to RevenueCat
2. **Entitlements**: Create "premium" entitlement, attach both products
3. **Offerings**: Create packages:
   - Package ID: "weekly" → onward_weekly_6_99
   - Package ID: "yearly" → onward_yearly_49_99

### 4. Testing
1. Create sandbox test users in App Store Connect
2. Test purchases in simulator/device
3. Verify subscription status in RevenueCat dashboard

### 5. Features Controlled by Subscription

**Free Tier:**
- ✅ Complete Dashboard
- ✅ 30-Day Fresh Start Program  
- ✅ AI Chat (always free)
- ✅ 3 Journal entries per week
- ✅ Basic insights (current week)

**Premium Tier:**
- ✅ Unlimited journal entries
- ✅ All healing programs (60-day, 90-day, specialized)
- ✅ Complete insights & analytics
- ✅ Data export

## Code Integration

The integration is already complete with:
- `SubscriptionManager`: Handles purchases and subscription status
- `PaywallTrigger`: Controls when to show paywall
- `PaywallView`: Beautiful subscription UI
- Paywall checks throughout the app (journal, programs, etc.)

## Files Modified
- `SubscriptionManager.swift` - Core subscription logic
- `PaywallView.swift` - Subscription UI
- `PaywallTrigger.swift` - Paywall display logic
- `RevenueCatConfig.swift` - Configuration
- `MainTabView.swift` - Added paywall modifier
- `JournalView.swift` - Added journal entry limits

## Next Steps
1. Replace API key in `RevenueCatConfig.swift`
2. Set up App Store Connect products
3. Configure RevenueCat dashboard
4. Test with sandbox users
5. Submit for App Store review 