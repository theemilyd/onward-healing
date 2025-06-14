# App Store Submission Checklist - Onward

## 🚨 **Critical Issues to Avoid Rejection**

### **Issue #1: In-App Purchase Features Not Working**
- ✅ **Debug Logging Added**: Subscription status changes are now logged for review
- ✅ **Immediate Feature Unlock**: Features unlock immediately after purchase via notification system
- ✅ **Feature Access Methods**: All premium features have clear access control methods
- ✅ **Testing Required**: Test all premium features after purchase in sandbox environment

### **Issue #2: Missing Terms of Use**
- ✅ **Terms of Use Created**: `TERMS_OF_USE.md` with comprehensive subscription terms
- ✅ **Privacy Policy Created**: `PRIVACY_POLICY.md` with detailed data handling
- ✅ **App Store Connect Setup**: Add links to these documents in App Store Connect

---

## 📋 **Complete Pre-Submission Checklist**

### **1. App Store Connect Setup**
- [ ] **App Information**
  - [ ] App name: "Onward - Healing Journey"
  - [ ] Subtitle: Clear, under 30 characters
  - [ ] Keywords: Relevant, comma-separated
  - [ ] Description: Highlights free vs premium features
  
- [ ] **Subscription Products**
  - [ ] Weekly: `onward_weekly_6_99` ($6.99/week, 3-day trial)
  - [ ] Yearly: `onward_yearly_49_99` ($49.99/year)
  - [ ] Both products approved and active

- [ ] **Required Links**
  - [ ] Terms of Use: Link to hosted `TERMS_OF_USE.md`
  - [ ] Privacy Policy: Link to hosted `PRIVACY_POLICY.md`
  - [ ] Support URL: Working customer support page

### **2. RevenueCat Configuration**
- [ ] **Products Match**
  - [ ] RevenueCat product IDs match App Store Connect
  - [ ] Entitlement: "premium"
  - [ ] Packages: "weekly", "yearly"
  
- [ ] **API Keys**
  - [ ] Production API key configured
  - [ ] Sandbox testing completed successfully

### **3. Feature Testing (CRITICAL)**
Test each premium feature after purchase:

- [ ] **Journal Features**
  - [ ] Free users limited to 3 entries/week ✓
  - [ ] Premium users have unlimited entries ✓
  - [ ] Counter resets weekly ✓
  
- [ ] **Program Access**
  - [ ] Free users can access 30-day program ✓
  - [ ] Premium users can access all programs ✓
  - [ ] 60-day and 90-day programs locked for free users ✓
  
- [ ] **Insights Access**
  - [ ] Free users see current week only ✓
  - [ ] Premium users see complete history ✓
  
- [ ] **Data Export**
  - [ ] Free users see paywall ✓
  - [ ] Premium users can export data ✓

### **4. Subscription Flow Testing**
- [ ] **Purchase Flow**
  - [ ] Weekly subscription with trial works ✓
  - [ ] Yearly subscription works ✓
  - [ ] Features unlock immediately after purchase ✓
  - [ ] Restore purchases works ✓
  
- [ ] **Trial Behavior**
  - [ ] 3-day trial only available for weekly ✓
  - [ ] No charge during trial period ✓
  - [ ] Features work during trial ✓
  
- [ ] **Cancellation**
  - [ ] Users can cancel in iOS Settings ✓
  - [ ] Features remain active until period ends ✓

### **5. App Metadata**
- [ ] **Screenshots**
  - [ ] Show both free and premium features
  - [ ] Include paywall screenshot
  - [ ] Highlight subscription benefits
  
- [ ] **App Description**
  - [ ] Clearly states free vs premium features
  - [ ] Mentions subscription pricing
  - [ ] Includes trial information
  
- [ ] **App Preview Video** (Optional but recommended)
  - [ ] Shows app functionality
  - [ ] Demonstrates premium features

### **6. Legal Compliance**
- [ ] **Terms of Use**
  - [ ] Hosted at accessible URL
  - [ ] Includes subscription terms
  - [ ] Mentions auto-renewal
  - [ ] Covers refund policy
  
- [ ] **Privacy Policy**
  - [ ] Hosted at accessible URL
  - [ ] Describes data collection
  - [ ] Mentions RevenueCat usage
  - [ ] Includes user rights

### **7. Technical Requirements**
- [ ] **iOS Compatibility**
  - [ ] Minimum iOS version specified
  - [ ] Tested on multiple device sizes
  - [ ] No crashes or major bugs
  
- [ ] **Performance**
  - [ ] App launches quickly
  - [ ] Smooth navigation
  - [ ] Responsive UI
  
- [ ] **Accessibility**
  - [ ] VoiceOver support
  - [ ] Proper contrast ratios
  - [ ] Accessible button sizes

### **8. Content Guidelines**
- [ ] **Medical Disclaimers**
  - [ ] Clear that app is not medical advice ✓
  - [ ] Encourages professional help when needed ✓
  
- [ ] **Age Rating**
  - [ ] Appropriate age rating selected
  - [ ] Content suitable for rating
  
- [ ] **Sensitive Content**
  - [ ] Mental health content handled appropriately
  - [ ] No harmful or dangerous advice

---

## 🧪 **Final Testing Protocol**

### **Sandbox Testing (Required)**
1. **Create Test User**: In App Store Connect
2. **Install App**: On test device with sandbox account
3. **Test Weekly Purchase**: With 3-day trial
4. **Verify Features Unlock**: Check all premium features work
5. **Test Yearly Purchase**: On different test account
6. **Test Restore**: Delete and reinstall app, restore purchases
7. **Test Cancellation**: Cancel subscription, verify access continues until expiry

### **Production Testing (After Approval)**
1. **Monitor Logs**: Check subscription debug logs
2. **User Feedback**: Monitor for feature access issues
3. **Analytics**: Track subscription conversion rates
4. **Support**: Be ready to help users with subscription issues

---

## 📝 **App Store Connect Submission Notes**

### **Review Notes for Apple**
Include this in your submission notes:

```
SUBSCRIPTION TESTING NOTES:

1. Premium Features:
   - Journal: Unlimited entries for subscribers (vs 3/week free)
   - Programs: All programs for subscribers (vs 30-day only free)
   - Insights: Complete history for subscribers (vs current week free)
   - Export: Data export for subscribers only

2. Test Accounts:
   - Use sandbox test users to verify subscription functionality
   - All premium features unlock immediately after purchase
   - Debug logging enabled for troubleshooting

3. Legal Compliance:
   - Terms of Use: [Your hosted URL]
   - Privacy Policy: [Your hosted URL]
   - Both documents include required subscription terms

4. RevenueCat Integration:
   - Subscription management handled by RevenueCat
   - Products: onward_weekly_6_99, onward_yearly_49_99
   - Entitlement: "premium"
```

---

## ✅ **Final Checklist Before Submission**

- [ ] All premium features tested and working
- [ ] Terms of Use and Privacy Policy hosted and linked
- [ ] Subscription products created and approved in App Store Connect
- [ ] RevenueCat configured with production API key
- [ ] App metadata complete with clear feature descriptions
- [ ] Screenshots show both free and premium features
- [ ] Sandbox testing completed successfully
- [ ] No crashes or major bugs
- [ ] Medical disclaimers included
- [ ] Debug logging enabled for review process

**Once all items are checked, you're ready to submit! 🚀** 