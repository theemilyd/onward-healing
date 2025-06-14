# Achievement System & Progress Tracking Guide

## Overview
This document explains how the Onward app's achievement system, streak calculation, and progress indicators work to provide meaningful feedback while preventing overwhelming mass unlocks.

## Achievement System

### Problem Solved
Previously, if a user downloaded the app after 7 days of no contact, they would unlock multiple achievements at once (1-day, 3-day, 7-day), which could be overwhelming and less meaningful.

### Solution: Progressive Unlocking
The new system only unlocks achievements in logical progression:

1. **Sequential Unlocking**: Users must unlock the 1-day achievement before the 3-day, 3-day before 7-day, etc.
2. **Achievement Tracking**: Each achievement has a unique ID and is tracked in `UserProfile.unlockedAchievementIds`
3. **Smart Checking**: `shouldUnlockAchievement()` method prevents mass unlocking

### Achievement Categories

#### Time-Based Achievements
- **Milestones**: 1, 3, 7, 14, 21, 30, 60, 90, 180, 365 days
- **Logic**: Based on `daysSinceNoContact` but unlocked progressively
- **Example**: If user starts at 10 days, they'll unlock 1-day first, then 3-day, then 7-day over time

#### Streak Achievements  
- **Milestones**: 3, 7, 14, 30 day streaks
- **Logic**: Based on consecutive days of app activity (journaling, SOS usage)
- **Tracking**: Uses `dailyActivityDates` array to calculate real streaks

#### Other Categories
- **Journaling**: Based on number of journal entries
- **Consistency**: Based on consistency score percentage
- **Self-Care**: Based on self-care score percentage
- **Emergency SOS**: Based on number of SOS chat sessions
- **Emotional Language**: Based on language pattern analysis
- **App Engagement**: Based on active days count
- **Special**: Combination achievements for major milestones

## Streak Calculation

### Current Streak Logic
The streak system tracks consecutive days of meaningful app engagement:

1. **Activity Recording**: `recordDailyActivity()` is called when user:
   - Opens the app (tracked in `PersistenceService.trackDailyAppUsage()`)
   - Creates a journal entry
   - Uses SOS chat features

2. **Streak Calculation**: `getCurrentStreak()` method:
   - Looks at `dailyActivityDates` array
   - Counts consecutive days backwards from today/yesterday
   - Allows 1-day grace period (if active yesterday but not today, streak continues)
   - Returns 0 if no recent activity

3. **Performance**: Only keeps last 90 days of activity data

### Next Goal Calculation
- **Time-based**: Shows next milestone (3→7→14→30 days, etc.)
- **Streak-based**: Shows next streak goal (+7 days from current)
- **Dynamic**: Updates based on current progress

## Progress Indicators

### Emotional Landscape Graph
**What it shows**: 7-day emotional stability trend
**Calculation components**:
1. **Base Stability**: 0.3 starting + 0.01 per day of no contact
2. **Consistency Bonus**: Up to 20% based on app usage regularity  
3. **Self-Care Bonus**: Up to 15% based on self-care activities
4. **Daily Trend**: Slight upward progression over the week
5. **Realistic Variation**: Small random fluctuations for authenticity

### Strength Indicators

#### Consistency Score (0-100%)
**Measures**: How regularly user engages with healing activities
**Components**:
- Journal consistency: Up to 40% (entries per day)
- App usage consistency: Up to 30% (SOS sessions per day)
- Time bonus: Up to 30% (persistence over longer periods)

#### Self-Care Score (0-100%)  
**Measures**: How well user is taking care of themselves
**Components**:
- App engagement: Up to 40% (using app when needed)
- Journal self-care: Up to 30% (writing as self-care)
- Milestone achievements: Up to 30% (celebrating progress)

#### Emotional Stability Score (0-100%)
**Measures**: Overall emotional healing progress
**Components**:
- Time stability: Up to 50% (gradual improvement over time)
- Consistency bonus: Up to 25% (regular engagement helps)
- Self-care bonus: Up to 25% (self-care improves stability)

## Implementation Details

### Key Files
- `UserProfile.swift`: Core data model with achievement tracking
- `ProgressView.swift`: Achievement display and unlocking logic
- `PersistenceService.swift`: Activity tracking and data persistence

### Database Schema Updates
New fields added to `UserProfile`:
- `lastAchievementCheckDate: Date`
- `unlockedAchievementIds: [String]`
- `dailyActivityDates: [Date]`

### Migration Considerations
Existing users will have empty achievement arrays, so they'll start unlocking achievements progressively from their current state.

## User Experience Benefits

1. **Meaningful Progress**: Achievements feel earned rather than automatically granted
2. **Sustained Engagement**: Progressive unlocking encourages continued app usage
3. **Realistic Feedback**: Scores reflect actual behavior patterns
4. **Motivation**: Clear next goals provide direction for continued growth
5. **Celebration**: Each achievement unlock feels special and intentional

## Future Enhancements

1. **Personalized Milestones**: Custom goals based on user's specific situation
2. **Seasonal Adjustments**: Different scoring during holidays or difficult periods
3. **Community Features**: Anonymous progress comparisons with other users
4. **Advanced Analytics**: More sophisticated emotional pattern recognition
5. **Gamification**: Badges, levels, and other engagement mechanics 