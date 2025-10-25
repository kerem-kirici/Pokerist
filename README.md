# Pokerist 🃏

A beautiful, modern Texas Hold'em poker hand analyzer for iOS built with SwiftUI. Analyze your poker hands, calculate win probabilities against up to 6 opponents, and see what hands can beat you - all with a stunning liquid glass UI design.

## ✨ Features

- **Real-time Hand Analysis**: Instantly evaluates your current poker hand
- **Win Probability Calculator**: Simulates 10,000 games to calculate your winning chances
- **Multi-Player Analysis**: Support for up to 6 opponents with detailed win probability calculations
- **Advanced Opponent Hand Analysis**: Input opponent hands and see comprehensive win probability breakdowns
- **Smart Possible Hands Calculator**: Displays distinct draw scenarios with accurate card requirements
- **Intelligent Hand Separation**: Each possible hand type shows separate entries for different draw paths
- **Accurate Card Requirements**: Shows exact card counts needed (e.g., "8, 8" for trips)
- **Smart Card Selection**: Prevents selecting duplicate cards across player and community cards
- **Swipe to Delete**: Intuitive gesture to remove cards
- **Dark & Light Mode**: Fully supports both appearance modes with adaptive UI
- **Liquid Glass Design**: Modern, elegant UI with frosted glass effects

## 🎯 Multi-Player Hand Analysis

Pokerist includes advanced **multi-player hand analysis** that supports up to **6 opponents** for comprehensive tournament and cash game analysis.

### How Multi-Player Analysis Works

1. **Add Opponent Hands**: 
   - Tap the "+" button in the opponent section
   - Select 2 hole cards for each opponent
   - **Support for up to 6 opponents** for comprehensive analysis

2. **Real-time Win Probability**:
   - **Your Win Probability**: Shows your chances of winning against all opponents
   - **Opponent Win Probabilities**: Individual win chances for each opponent
   - **Hand Rankings**: See which hand would win in each scenario

3. **Detailed Hand Breakdown**:
   - **Opponent Hand Types**: Shows what hands each opponent could have
   - **Example Cards**: Displays specific hole card combinations
   - **Probability Distribution**: How likely each hand type is
   - **Beating Analysis**: Which opponent hands can beat you

### Example Scenario

**Your Hand**: A♠ K♠  
**Community Cards**: 7♣ 8♦ 9♥  
**Opponent 1**: J♠ 10♣ (Straight draw)  
**Opponent 2**: 7♠ 7♥ (Three of a kind)  

**Results**:
- **Your Win Probability**: 35%
- **Opponent 1 Win**: 45% (needs 6 or J for straight)
- **Opponent 2 Win**: 20% (needs 7 for four of a kind)

### Advanced Features

- **Monte Carlo Simulation**: 10,000 simulations for accurate probabilities
- **Multi-Player Support**: Analyze up to 6 opponents simultaneously
- **Hand Strength Comparison**: Detailed tie-break analysis
- **Dynamic Updates**: Probabilities update as you add/remove opponents
- **Visual Hand Display**: See exact cards for each opponent
- **Probability Meter**: Color-coded win probability indicators

### Use Cases

- **Tournament Analysis**: Compare your hand against up to 6 opponents
- **Cash Game Strategy**: Understand your position against the field
- **Multi-Way Pot Analysis**: Analyze complex scenarios with multiple players
- **Learning Tool**: See how different hands perform in multi-way pots
- **Decision Making**: Make informed betting decisions based on win probabilities

## 📱 Screenshots

### Light Mode

<table>
  <tr>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Home.png" width="250" alt="Light Home Screen"/>
      <br/>
      <b>Home Screen</b>
      <br/>
      Card selection with current hand badge
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Info.png" width="250" alt="Light Analysis View"/>
      <br/>
      <b>Analysis View</b>
      <br/>
      Win probability and hand analysis
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Info Details.png" width="250" alt="Dark Card Picker Full"/>
      <br/>
      <b>Analysis Details</b>
      <br/>
      Hand breakdown details
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Delete.png" width="250" alt="Light Swipe Delete"/>
      <br/>
      <b>Swipe to Delete</b>
      <br/>
      Intuitive card removal
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Sheet Half.png" width="250" alt="Light Card Picker Half"/>
      <br/>
      <b>Card Picker (Half)</b>
      <br/>
      Detent-based card selection
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Sheet Full.png" width="250" alt="Light Card Picker Full"/>
      <br/>
      <b>Card Picker (Full)</b>
      <br/>
      Expanded card selection view
    </td>
  </tr>
</table>

### Dark Mode

<table>
  <tr>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Home.png" width="250" alt="Dark Home Screen"/>
      <br/>
      <b>Home Screen</b>
      <br/>
      Beautiful dark theme
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Info.png" width="250" alt="Dark Analysis View"/>
      <br/>
      <b>Analysis View</b>
      <br/>
      Detailed hand breakdown
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Info Details.png" width="250" alt="Dark Card Picker Full"/>
      <br/>
      <b>Analysis Details</b>
      <br/>
      Hand breakdown details
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Delete.png" width="250" alt="Dark Swipe Delete"/>
      <br/>
      <b>Swipe to Delete</b>
      <br/>
      Intuitive card removal
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Sheet Half.png" width="250" alt="Dark Card Picker Half"/>
      <br/>
      <b>Card Picker (Half)</b>
      <br/>
      Smart card selection
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Sheet Full.png" width="250" alt="Dark Card Picker Full"/>
      <br/>
      <b>Card Picker (Full)</b>
      <br/>
      Full selection interface
    </td>
  </tr>
</table>

### Opponent Analysis

<table>
  <tr>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Opponent Home.png" width="250" alt="Dark Opponent Home"/>
      <br/>
      <b>Opponent Analysis in Dark Mode</b>
      <br/>
      Multi-player hand analysis
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Light Opponent Home.png" width="250" alt="Light Opponent Home"/>
      <br/>
      <b>Opponent Analysis in Light Mode</b>
      <br/>
      Allows up to 6 opponents
    </td>
    <td align="center">
      <img src="Photos/Simulator Screenshot - iPhone 17 Pro - Dark Opponent Info.png" width="250" alt="Dark Opponent Analysis View"/>
      <br/>
      <b>Analysis Information</b>
      <br/>
      Gives specific win probabilities for each player
    </td>
  </tr>
</table>

## 🎮 How to Use

### Basic Hand Analysis
1. **Select Your Cards**: Tap the "+" buttons to select your two hole cards
2. **Add Community Cards**: Add the flop, turn, and river as they're revealed
3. **View Analysis**: See your current hand, win probability, and detailed statistics
4. **Expand Details**: Tap on analysis cards to see:
   - Opponent hands that can beat you
   - Your possible improved hands with distinct draw scenarios
   - Exact card requirements for each hand type
   - Example cards for each scenario
5. **Delete Cards**: Swipe up on any card to remove it

### Multi-Player Analysis (Up to 6 Opponents)
1. **Add Opponents**: Tap the "+" button in the opponent section
2. **Select Opponent Cards**: Choose 2 hole cards for each opponent (up to 6 opponents)
3. **View Win Probabilities**: See your chances against each opponent
4. **Analyze Hand Strength**: Compare your hand to opponent possibilities
5. **Make Strategic Decisions**: Use probability data for betting decisions

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
│   ├── OpponentHandView.swift
│   ├── PlaceholderCard.swift
│   ├── PossibleHandsCard.swift
│   ├── ProbabilityMeter.swift
│   ├── ProbabilityText.swift
│   ├── RequiredCardsView.swift
│   └── WinProbabilityCard.swift
├── Views/               # Screen-level views
│   ├── AgainstOpponentView.swift
│   ├── CommunityCards.swift
│   ├── InformationSection.swift
│   └── YourHand.swift
├── Models/              # Business logic
│   ├── GameState.swift
│   └── PokerHandAnalyzer.swift
├── Types/               # Type definitions
│   └── PlayingCardTypes.swift
├── Assets.xcassets/     # App assets and images
├── ContentView.swift    # Main app view
└── PokeristApp.swift   # App entry point
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

## 🎯 Advanced Analysis Algorithms

### Win Probability Calculation
The win probability is calculated using **Monte Carlo simulation**:

- Simulates **10,000 random games** for statistical accuracy
- Considers all possible opponent hole cards
- Deals remaining community cards randomly
- Evaluates final hands to determine winners
- Runs asynchronously to keep UI responsive

### Smart Possible Hands Analysis
The possible hands calculator uses **intelligent separation logic**:

- **Distinct Draw Scenarios**: Each unique draw path gets its own entry
- **Accurate Card Requirements**: Shows exact cards needed (e.g., "8, 8" for trips)
- **Separate Straight Draws**: Different straight draws (needing 4 vs 9) appear as separate entries
- **Hand-Specific Logic**: Different hand types use appropriate card counting
- **Probability Distribution**: Evenly distributes probability among distinct outcomes

### Example: Smart Hand Separation

**Before (Combined):**
```
Straight: Need [4, 9] - 26% probability
```

**After (Separated):**
```
Straight: Need [4] - 13% probability
Straight: Need [9] - 13% probability
```

**For Three of a Kind:**
```
Three of a Kind: Need [8, 8] - 12% probability
```

This ensures each distinct draw scenario is clearly displayed as a separate possible hand entry.

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
- **Smart Hand Separation**: Efficient grouping of distinct draw scenarios
- **Optimized Probability Distribution**: Even division among separate outcomes

### UI/UX Features
- **Expandable Cards**: Tap to reveal detailed information
- **Loading States**: Smooth loading animations
- **Empty States**: Helpful messages when no data available
- **Error Handling**: Graceful error states with retry options
- **Clear Hand Separation**: Distinct entries for different draw scenarios
- **Intuitive Card Requirements**: Clear display of exact cards needed

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

