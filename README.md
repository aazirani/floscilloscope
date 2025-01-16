# floscilloscope

A customizable oscilloscope widget for Flutter, providing features such as dynamic chart rendering, threshold manipulation, zooming and panning, customizable axes, support for multiple data series, and interactive threshold sliders.

[![Stars](https://img.shields.io/github/stars/aazirani/floscilloscope?label=Stars&style=flat)][repo]
[![Forks](https://img.shields.io/github/forks/aazirani/floscilloscope?label=Forks&style=flat)][repo]
[![Watchers](https://img.shields.io/github/watchers/aazirani/floscilloscope?label=Watchers&style=flat)][repo]
[![Contributors](https://img.shields.io/github/contributors/aazirani/floscilloscope?label=Contributors&style=flat)][repo]

[![GitHub last commit](https://img.shields.io/github/last-commit/aazirani/floscilloscope?label=Last+Commit&style=flat)][repo]
[![GitHub issues](https://img.shields.io/github/issues/aazirani/floscilloscope?label=Issues&style=flat)][issues]
[![GitHub pull requests](https://img.shields.io/github/issues-pr/aazirani/floscilloscope?label=Pull+Requests&style=flat)][pulls]
[![GitHub License](https://img.shields.io/github/license/aazirani/floscilloscope?label=License&style=flat)][license]

## Table of Contents

- [floscilloscope](#floscilloscope)
    - [Table of Contents](#table-of-contents)
    - [Features](#features)
    - [Installation](#installation)
    - [Usage](#usage)
        - [Using `SimpleOscilloscope` Widget](#using-simpleoscilloscope-widget)
        - [Using `AlternativeSimpleOscilloscope` Widget](#using-alternativesimpleoscilloscope-widget)
        - [Configuring `OscilloscopeAxisChartData`](#configuring-oscilloscopeaxischartdata)
    - [Contributing](#contributing)
    - [License](#license)
    - [Sponsor Me](#sponsor-me)
    - [Connect With Me](#connect-with-me)

## Features

- **Dynamic Chart Rendering:** Visualize data points in real-time with smooth transitions.
- **Threshold Lines and Sliders:** Easily set and adjust threshold values interactively.
- **Zooming and Panning:** Navigate through data with intuitive zoom and pan gestures. (AlternativeSimpleOscilloscope only)
- **Customizable Axes:** Define labels, units, and scales for both horizontal and vertical axes.
- **Multiple Data Series Support:** Display multiple lines with customizable colors for comprehensive data analysis.
- **Extra Plot Lines:** Add additional horizontal lines for markers or reference points.
- **Interactive Threshold Manipulation:** Double-tap to reset thresholds or open dialogs for precise adjustments.
- **Optimized Performance:** Efficient rendering with `RepaintBoundary` and optimized widget structures.
- **Multiple Chart Libraries:** Possibility to use the syncfusion_flutter_charts as well as the fl_chart package, depending on your preference.

## Installation

Add `floscilloscope` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  floscilloscope:
  git:
    url: https://github.com/aazirani/floscilloscope
    ref: main
```

Then run `flutter pub get` to fetch the package.

## Usage

### Using `SimpleOscilloscope` Widget

The `SimpleOscilloscope` widget provides a straightforward oscilloscope chart with essential features like threshold lines and sliders. It uses the fl_chart package.

```dart
import 'package:flutter/material.dart';
import 'package:floscilloscope/floscilloscope.dart';

class OscilloscopeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data points
    final data = [
      FlSpot(0, 0),
      FlSpot(1, 1),
      FlSpot(2, 0.5),
      FlSpot(3, 1.5),
      FlSpot(4, 1),
      FlSpot(5, 2),
    ];

    final oscilloscopeData = OscilloscopeAxisChartData(
      dataPoints: [data],
      horizontalAxisLabel: 'Time',
      verticalAxisLabel: 'Amplitude',
      horizontalAxisUnit: 's',
      verticalAxisUnit: 'V',
      threshold: 1.0,
      onThresholdValueChanged: (value) {
        print('Threshold updated to: $value');
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text('Simple Oscilloscope Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SimpleOscilloscope(
          oscilloscopeAxisChartData: oscilloscopeData,
        ),
      ),
    );
  }
}
```

### Using `AlternativeSimpleOscilloscope` Widget

The `AlternativeSimpleOscilloscope` offers additional customization options and different interaction behaviors compared to the `SimpleOscilloscope`. It uses the syncfusion_flutter_charts package.

```dart
import 'package:flutter/material.dart';
import 'package:floscilloscope/floscilloscope.dart';

class AlternativeOscilloscopeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Sample data points for multiple series
    final dataSeries1 = [
      FlSpot(0, 0),
      FlSpot(1, 2),
      FlSpot(2, 1),
      FlSpot(3, 3),
      FlSpot(4, 2),
    ];

    final dataSeries2 = [
      FlSpot(0, 1),
      FlSpot(1, 3),
      FlSpot(2, 2),
      FlSpot(3, 4),
      FlSpot(4, 3),
    ];

    final oscilloscopeData = OscilloscopeAxisChartData(
      dataPoints: [dataSeries1, dataSeries2],
      horizontalAxisLabel: 'Time',
      verticalAxisLabel: 'Voltage',
      horizontalAxisUnit: 'ms',
      verticalAxisUnit: 'V',
      threshold: 2.5,
      colors: [Colors.blue, Colors.red],
      onThresholdValueChanged: (value) {
        print('Threshold updated to: $value');
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text('Alternative Oscilloscope Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AlternativeSimpleOscilloscope(
          oscilloscopeAxisChartData: oscilloscopeData,
        ),
      ),
    );
  }
}
```

### Configuring `OscilloscopeAxisChartData`

Customize the oscilloscope's appearance and behavior using the `OscilloscopeAxisChartData` class.

```dart
final oscilloscopeData = OscilloscopeAxisChartData(
  dataPoints: [dataSeries1, dataSeries2],
  numberOfDivisions: 5,
  horizontalAxisLabel: 'Time',
  verticalAxisLabel: 'Voltage',
  horizontalAxisUnit: 'ms',
  verticalAxisUnit: 'V',
  horizontalAxisValuePerDivision: 1.0,
  verticalAxisValuePerDivision: 1.0,
  updateButtonLabel: 'Apply',
  cancelButtonLabel: 'Dismiss',
  thresholdLabel: 'Voltage Threshold',
  isThresholdVisible: true,
  onThresholdValueChanged: (value) {
    // Handle threshold value change
  },
  colors: [Colors.green, Colors.orange],
  isThresholdSliderActive: true,
  threshold: 2.0,
  thresholdDragStepSize: 0.1,
  extraPlotLines: {
    1.5: Colors.grey,
    2.5: Colors.black,
  },
);
```

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please follow these steps:

1. **Fork the Repository:** Click the [Fork](https://github.com/aazirani/floscilloscope/fork) button at the top right of this repository's page.
2. **Clone Your Fork:**
   ```bash
   git clone https://github.com/your-username/floscilloscope.git
   ```
3. **Create a Branch:**
   ```bash
   git checkout -b feature/YourFeatureName
   ```
4. **Make Your Changes:** Implement your feature or bug fix.
5. **Commit Your Changes:**
   ```bash
   git commit -m "Add your descriptive commit message"
   ```
6. **Push to Your Fork:**
   ```bash
   git push origin feature/YourFeatureName
   ```
7. **Submit a Pull Request:** Navigate to the [original repository](https://github.com/aazirani/floscilloscope) and click the "New pull request" button.

Please ensure your code follows the project's coding standards and includes appropriate tests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Sponsor Me

By sponsoring my efforts, you're not merely contributing to the development of my projects; you're investing in their growth and sustainability.

Your support empowers me to dedicate more time and resources to improving the project's features, addressing issues, and ensuring its continued relevance in the rapidly evolving landscape of technology.

Your sponsorship directly fuels innovation, fosters a vibrant community, and helps maintain the project's high standards of quality. Together, we can shape the future of these projects and make a lasting impact in the open-source community.

Thank you for considering sponsoring my work!

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/aazirani)

## Connect With Me

[![GitHub: aazirani](https://img.shields.io/badge/aazirani-EFF7F6?logo=GitHub&logoColor=333&link=https://www.github.com/aazirani)][github]
[![Instagram: aazirani](https://img.shields.io/badge/aazirani-EFF7F6?logo=Instagram&link=https://www.instagram.com/aazirani)][instagram]
[![Twitter: aazirani](https://img.shields.io/badge/aazirani-EFF7F6?logo=X&logoColor=333&link=https://x.com/aazirani)][twitter]

[pub]: https://pub.dev/packages/floscilloscope
[github]: https://github.com/aazirani
[twitter]: https://twitter.com/aazirani
[instagram]: https://instagram.com/aazirani
[releases]: https://github.com/aazirani/floscilloscope/releases
[repo]: https://github.com/aazirani/floscilloscope
[issues]: https://github.com/aazirani/floscilloscope/issues
[license]: https://github.com/aazirani/floscilloscope/blob/master/LICENSE
[pulls]: https://github.com/aazirani/floscilloscope/pulls