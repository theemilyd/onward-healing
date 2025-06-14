# Onward App - Subscription Setup Checklist

## 📋 Complete Setup Guide

### ✅ **Step 1: App Store Connect Setup**

#### Create Your App
- [ ] Go to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Sign in with Apple Developer account
- [ ] Click "My Apps" → "+" → "New App"
- [ ] Fill in details:
  - **Platform:** iOS
  - **Name:** Onward
  - **Primary Language:** English
  - **Bundle ID:** `com.emily.onwardapp-new`
  - **SKU:** `onward-app`

#### Create In-App Purchase Products
- [ ] Go to your app → **Features** → **In-App Purchases**
- [ ] Create **Weekly Subscription:**
  - **Reference Name:** `Onward Weekly Premium`
  - **Product ID:** `onward_weekly_6_99` ⚠️ **EXACT MATCH REQUIRED**
  - **Subscription Group:** "Premium Subscriptions" (create new)
  - **Duration:** 1 Week
  - **Price:** $6.99 USD
  - **Free Trial:** 3 days
  - **Display Name:** "Weekly Premium"
  - **Description:** "Full access to all premium features"

- [ ] Create **Yearly Subscription:**
  - **Reference Name:** `Onward Yearly Premium`
  - **Product ID:** `onward_yearly_49_99` ⚠️ **EXACT MATCH REQUIRED**
  - **Subscription Group:** "Premium Subscriptions" (same as above)
  - **Duration:** 1 Year
  - **Price:** $49.99 USD
  - **Free Trial:** None
  - **Display Name:** "Yearly Premium"
  - **Description:** "Full access to all premium features - Best Value!"

#### Submit Products for Review
- [ ] Add screenshots and descriptions for both products
- [ ] Submit both products for review (can take 24-48 hours)

---

### ✅ **Step 2: RevenueCat Setup**

#### Create Account & App
- [ ] Go to [RevenueCat](https://app.revenuecat.com)
- [ ] Create account or sign in
- [ ] Create new project: "Onward"
- [ ] Add iOS app:
  - **App Name:** Onward
  - **Bundle ID:** `com.emily.onwardapp-new`
  - **Link App Store Connect account**

#### Configure Products
- [ ] Go to **Products** tab
- [ ] Import from App Store Connect (after approval) OR manually add:
  - `onward_weekly_6_99`
  - `onward_yearly_49_99`

#### Create Entitlements
- [ ] Go to **Entitlements** tab
- [ ] Create entitlement: `premium`
- [ ] Attach both products to this entitlement

#### Create Offerings
- [ ] Go to **Offerings** tab
- [ ] Create offering: `default`
- [ ] Add packages:
  - **Package ID:** `weekly` → **Product:** `onward_weekly_6_99`
  - **Package ID:** `yearly` → **Product:** `onward_yearly_49_99`

#### Get API Key
- [ ] Go to **API Keys** tab
- [ ] Copy **Public SDK Key** (starts with `appl_`)

---

### ✅ **Step 3: Update App Code**

#### Update RevenueCat Configuration
- [ ] Open `onward/Onward/Core/Configuration/RevenueCatConfig.swift`
- [ ] Replace `"your_revenuecat_api_key_here"` with your actual API key
- [ ] Verify all product IDs match exactly

#### Test Configuration
- [ ] Build and run the app
- [ ] Check console for: "✅ RevenueCat configuration looks good!"
- [ ] If you see "⚠️ RevenueCat API key not configured!" - update the API key

---

### ✅ **Step 4: Testing**

#### Create Sandbox Test Users
- [ ] Go to App Store Connect → **Users and Access** → **Sandbox Testers**
- [ ] Create test users with different Apple IDs
- [ ] Sign out of App Store on test device
- [ ] Sign in with sandbox test account

#### Test Purchases
- [ ] Run app on device (not simulator)
- [ ] Trigger paywall (try to create 4th journal entry)
- [ ] Test both weekly and yearly purchases
- [ ] Test free trial functionality
- [ ] Test restore purchases
- [ ] Verify premium features unlock

---

### ✅ **Step 5: App Store Submission**

#### Prepare for Review
- [ ] Add app metadata (description, keywords, screenshots)
- [ ] Include subscription terms in app description
- [ ] Add privacy policy URL
- [ ] Test on multiple devices and iOS versions

#### Submit for Review
- [ ] Upload build to App Store Connect
- [ ] Submit app + in-app purchases for review
- [ ] Respond to any reviewer feedback

---

## 🚨 **Critical Notes**

### Product ID Requirements
- **MUST MATCH EXACTLY:** `onward_weekly_6_99` and `onward_yearly_49_99`
- These are hardcoded in your app - any typos will break purchases

### Bundle ID
- **Your Bundle ID:** `com.emily.onwardapp-new`
- Must match across App Store Connect, RevenueCat, and Xcode

### Testing Requirements
- **Must test on real device** (not simulator)
- **Must use sandbox test users**
- **Must test all purchase flows**

---

## 🆘 **Troubleshooting**

### Common Issues
1. **"Product not found"** → Check product IDs match exactly
2. **"Invalid product"** → Products not approved in App Store Connect
3. **"Sandbox user required"** → Sign in with sandbox test account
4. **"Network error"** → Check RevenueCat API key is correct

### Getting Help
- RevenueCat docs: https://docs.revenuecat.com
- Apple docs: https://developer.apple.com/in-app-purchase/
- Test with sandbox users before going live

---

## ✅ **Current Status**

- [x] Code implementation complete
- [x] RevenueCat integration ready
- [ ] App Store Connect setup (your next step)
- [ ] RevenueCat dashboard configuration
- [ ] Testing with sandbox users
- [ ] App Store submission

**Next Action:** Set up your app in App Store Connect with the exact product IDs listed above! 