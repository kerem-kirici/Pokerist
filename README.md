# Pokerist 🃏

A beautiful, modern Texas Hold'em poker hand analyzer for iOS built with SwiftUI. Analyze your poker hands, calculate win probabilities, and see what hands can beat you - all with a stunning liquid glass UI design.

## ✨ Features

- **Real-time Hand Analysis**: Instantly evaluates your current poker hand
- **Win Probability Calculator**: Simulates 10,000 games to calculate your winning chances
- **Opponent Hand Analysis**: Shows what hands can beat you and their probabilities
- **Possible Hands Calculator**: Displays your potential draws and their probabilities
- **Smart Card Selection**: Prevents selecting duplicate cards across player and community cards
- **Swipe to Delete**: Intuitive gesture to remove cards
- **Dark & Light Mode**: Fully supports both appearance modes with adaptive UI
- **Liquid Glass Design**: Modern, elegant UI with frosted glass effects

## 📱 Screenshots

### Light Mode

<table>
  <tr>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Light Home.png" width="250" alt="Light Home Screen"/>
      <br/>
      <b>Home Screen</b>
      <br/>
      Card selection with current hand badge
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Light Info.png" width="250" alt="Light Analysis View"/>
      <br/>
      <b>Analysis View</b>
      <br/>
      Win probability and hand analysis
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Light Delete.png" width="250" alt="Light Swipe Delete"/>
      <br/>
      <b>Swipe to Delete</b>
      <br/>
      Intuitive card removal
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Light Sheet Half.png" width="250" alt="Light Card Picker Half"/>
      <br/>
      <b>Card Picker (Half)</b>
      <br/>
      Detent-based card selection
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Light Sheet Full.png" width="250" alt="Light Card Picker Full"/>
      <br/>
      <b>Card Picker (Full)</b>
      <br/>
      Expanded card selection view
    </td>
    <td align="center">
    </td>
  </tr>
</table>

### Dark Mode

<table>
  <tr>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Dark Home.png" width="250" alt="Dark Home Screen"/>
      <br/>
      <b>Home Screen</b>
      <br/>
      Beautiful dark theme
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Dark Info.png" width="250" alt="Dark Analysis View"/>
      <br/>
      <b>Analysis View</b>
      <br/>
      Detailed hand breakdown
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Dark Delete.png" width="250" alt="Dark Swipe Delete"/>
      <br/>
      <b>Swipe to Delete</b>
      <br/>
      Intuitive card removal
    </td>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Dark Sheet Half.png" width="250" alt="Dark Card Picker Half"/>
      <br/>
      <b>Card Picker (Half)</b>
      <br/>
      Smart card selection
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="Pokerist/Photos/Simulator Screenshot - iPhone 17 Pro - Dark Sheet Full.png" width="250" alt="Dark Card Picker Full"/>
      <br/>
      <b>Card Picker (Full)</b>
      <br/>
      Full selection interface
    </td>
    <td align="center">
    </td>
    <td align="center">
    </td>
  </tr>
</table>

## 🎮 How to Use

1. **Select Your Cards**: Tap the "+" buttons to select your two hole cards
2. **Add Community Cards**: Add the flop, turn, and river as they're revealed
3. **View Analysis**: See your current hand, win probability, and detailed statistics
4. **Expand Details**: Tap on analysis cards to see:
   - Opponent hands that can beat you
   - Your possible improved hands
   - Example cards for each scenario
5. **Delete Cards**: Swipe up on any card to remove it

## 🏗️ Architecture

The app follows modern SwiftUI best practices with a clean, modular architecture:

### Project Structure

```
Pokerist/
├── Components/          # Reusable UI components
│   ├── CardView.swift
│   ├── SelectCardButton.swift
│   ├── CardPickerSheet.swift
│   ├── CurrentHandBadge.swift
│   ├── WinProbabilityCard.swift
│   ├── PossibleHandsCard.swift
│   ├── ProbabilityMeter.swift
│   ├── ProbabilityText.swift
│   └── RequiredCardsView.swift
├── Views/               # Screen-level views
│   ├── YourHand.swift
│   ├── CommunityCards.swift
│   └── InformationSection.swift
├── Models/              # Business logic
│   ├── GameState.swift
│   └── PokerHandAnalyzer.swift
└── Types/               # Type definitions
    └── PlayingCardTypes.swift
```

### Key Design Patterns

- **Observable State Management**: Using `@Observable` for reactive state updates
- **Redux-like Pattern**: Centralized state management with `GameState`
- **Async/Await**: Background calculations with Task-based concurrency
- **Caching**: Smart caching of expensive calculations
- **Component Composition**: Highly reusable, modular components

## 🧮 Hand Evaluation

The analyzer evaluates all standard poker hands:

1. **Royal Flush** 👑
2. **Straight Flush**
3. **Four of a Kind**
4. **Full House** 🏠
5. **Flush**
6. **Straight**
7. **Three of a Kind**
8. **Two Pair**
9. **One Pair**
10. **High Card**

## 🎯 Win Probability Algorithm

The win probability is calculated using **Monte Carlo simulation**:

- Simulates **10,000 random games** for statistical accuracy
- Considers all possible opponent hole cards
- Deals remaining community cards randomly
- Evaluates final hands to determine winners
- Runs asynchronously to keep UI responsive

## 🎨 Design Philosophy

- **Liquid Glass UI**: Modern frosted glass effects with subtle gradients
- **Adaptive Color**: Dynamic colors based on probability (green/orange/red)
- **Smooth Animations**: Spring-based animations for natural feel
- **Gesture-Driven**: Intuitive swipe-to-delete and expandable cards
- **Accessibility**: Full VoiceOver support with descriptive labels

## 🛠️ Technical Highlights

### Smart Card Selection
- **Duplicate Prevention**: Automatically disables already-selected cards
- **Live Validation**: Real-time feedback on card availability
- **Edit Mode**: Seamlessly edit existing cards without conflicts

### Performance Optimizations
- **Async Calculations**: Heavy computations run in background
- **Result Caching**: Cached results based on card combinations
- **Task Cancellation**: Automatic cleanup when cards change
- **Lazy Loading**: Analysis only loads when needed

### UI/UX Features
- **Expandable Cards**: Tap to reveal detailed information
- **Loading States**: Smooth loading animations
- **Empty States**: Helpful messages when no data available
- **Error Handling**: Graceful error states with retry options

## 📋 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/kerem-kirici/Pokerist.git
   ```

2. Open the project in Xcode:
   ```bash
   cd Pokerist
   open Pokerist.xcodeproj
   ```

3. Build and run on simulator or device (⌘R)

## 🧪 Testing

The project includes:
- Unit tests for poker hand evaluation
- UI tests for critical user flows
- Preview providers for component development

Run tests with `⌘U` in Xcode.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is available under the MIT License.

## 👨‍💻 Author

**Kerem Kirici**
- GitHub: [@kerem-kirici](https://github.com/kerem-kirici)

## 🙏 Acknowledgments

- Card designs inspired by modern UI/UX principles
- Monte Carlo simulation algorithm for probability calculations
- SwiftUI for the amazing declarative UI framework

---

**Made with ♥️ and SwiftUI**

