## 0.0.1

* Initial release.

## 1.0.0

* Updated README file to describe the package further.
* Added support for multiple datasets.
* Added a threshold slider.
* Added support for the fl_chart and syncfusion_flutter_charts.

## 1.0.1

* Updated the dependencies.
* Added some more comments.

## 1.0.2

* Changed the description of the package.
* Added the changelog text for more points.

## 1.0.3

* Updated the dependencies.

## 1.0.4

* The alternative oscilloscope does not use FlSpot from fl_chart anymore, but a custom OscilloscopePoint class.
* Added test cases.
* Added more comments and documentation.

## 1.0.5

* Fixed some formatting issues in the code.

## 1.0.6

* Bug fixes

## 1.1.0

* Added RTL layout support by forcing LTR directionality on chart and slider rows in both SimpleOscilloscope and AlternativeSimpleOscilloscope.

## 1.1.1

* Fixed threshold dialog text field displaying negative values incorrectly in RTL locales.

## 1.1.3

* Threshold is now parent-controlled when no `onThresholdValueChanged` callback is supplied. In `SimpleOscilloscope` and `AlternativeSimpleOscilloscope`, finishing a threshold slider drag or submitting the threshold dialog without a callback now reverts the internal threshold to the `threshold` prop instead of silently committing the dragged value and desyncing from the source of truth. Provide `onThresholdValueChanged` to make threshold changes persistent.
* Exposed `SimpleOscilloscopeState` publicly (matching `AlternativeSimpleOscilloscopeState`) with a `@visibleForTesting currentThresholdValue` getter/setter so the threshold state can be asserted in tests.

## 1.1.2

* Fixed stale trailing points remaining on the `AlternativeSimpleOscilloscope` chart when a series is replaced with a shorter list. Data updates are now pushed through `ChartSeriesController.updateDataSource`, which also avoids a full `SfCartesianChart` rebuild on data-only changes.
* Added `AlternativeSimpleOscilloscopeState.clearData()` to immediately clear all rendered data, and exposed the state class publicly so it can be reached through a `GlobalKey`.
* Upgraded the Syncfusion dependencies (`syncfusion_flutter_charts`, `syncfusion_flutter_core`, `syncfusion_flutter_sliders`) from `^33.2.3` to `^34.1.33` in both the package and the example app.
* Fixed stale data persisting on `AlternativeSimpleOscilloscope` after the number of series changes. Surviving series now get a generation-keyed rebuild so their `ChartSeriesController` is recaptured (otherwise `updateDataSource` was silently skipped and stale points remained).
* Fixed a threshold drag being reverted on every data-tick rebuild in both `SimpleOscilloscope` and `AlternativeSimpleOscilloscope`. Threshold change detection now compares the previous vs new widget instead of state vs widget.
* Wrapped the `AlternativeSimpleOscilloscope` chart in a `RepaintBoundary` for streaming paint isolation.
* Added a streaming (timer-driven) example that exercises the real-time update path of both oscilloscopes.
* Cleanup: removed a dead `identical()` guard, switched to plain `GlobalKey` types, re-measure slider padding when axis config changes, reuse an index buffer for data updates, and use `Object.hash` for `OscilloscopePoint.hashCode`.
* BREAKING (minor): made `calculateZoomedMin`/`calculateZoomedMax` private (they were undocumented internal helpers).