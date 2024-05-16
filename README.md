# Intrinsic Value
[![Lint and Tests Validation](https://github.com/Appjetive/intrinsic_value/actions/workflows/lint-tests-check.yml/badge.svg)](https://github.com/Appjetive/intrinsic_value/actions/workflows/lint-tests-check.yml)

## Description

This Dart project offers tools for financial analysis, specifically focusing on the valuation of companies and projecting their growth potential. With a user-friendly command-line interface, it enables users to calculate the intrinsic value of a company based on fundamental financial metrics and to estimate its future growth trajectory.

Key features include:

- **Intrinsic Value Calculation:** Utilizing fundamental financial data such as cash flow, P/E ratio, and cash reserves, the project computes the intrinsic value of a company. Users can customize inputs like growth rate, projection period, discount rate, and safety margin to tailor the analysis according to their investment strategy.

- **Annual Growth Projection:** By specifying minimum and maximum values, users can project the annual growth of a company over a defined period. This feature aids in evaluating the growth potential of an investment opportunity and assists in making informed investment decisions.


### Setup

Follow these steps to set up the project:

1. Install dependencies:
```bash
dart pub get
```

2. Run build_runner to generate code:
```bash
dart run build_runner build
```

3. Check code format:
```bash
dart format -o none --set-exit-if-changed .
```

4. Check linting rules:
```bash
flutter analyze --no-pub
```

5. Run tests:
```bash
dart test
```


## Usage

### Calculate Intrinsic Value (iv)

To calculate the intrinsic value of a company, use the following command:

```bash
./bin/main.dart iv --stock ./stocks/oc -g 15 -y 5 -f 30 -d 15
Where:
--stock is a file containing the following structure (all values are required):
makefile
Copy code
currentYear=2022 # The year to start calculating
cashInCurrentYear=60.01 # Company cash flow
multiplierAvgPastYears=20 # Average P/E ratio
cashOnHand=113.76 # Cash after deductions
-g is the yearly growth rate in percentage (optional)
-y is the number of years for projection (optional)
-d is the discount rate in percentage (optional)
-f is the safety margin in percentage (optional)
```

### Calculate Annual Growth (ag)

To calculate the annual growth of a company, use the following command:

```bash
./bin/main.dart ag --min 136 --max 160 -y 1
Where:

--min is the minimum value
--max is the maximum value
-y is the number of years for growth calculation
```


### Contributing
If you want to contribute to this project, feel free to submit issues or pull requests.

### License
This project is licensed under the [BSD-3-Clause license](https://github.com/Appjetive/intrinsic_value/blob/main/LICENSE).
