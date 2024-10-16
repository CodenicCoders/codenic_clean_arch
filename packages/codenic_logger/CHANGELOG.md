## 4.1.2
- Add `MessageLogPrinter.splitTextByCharacterCount` to control the number of 
characters per line when printing logs.

## 4.1.1
- Downgrade `meta` from `1.16.0` to `1.15.0`.

## 4.1.0
- JSON encode the `data` field in `MessageLog` when printing logs.

## 4.0.2
- Bump dependency versions.
- Deprecate `MessageLogPrinter.printTime`.

## 4.0.1
- Bump `logger` from `2.0.1` to `2.0.2+1`.
- Bump `meta` from `1.9.1` to `1.11.0`.

## 4.0.0
- Bump `logger` from `1.3.0` to `2.0.1` (Includes breaking changes)
- Replace `codenicLogger.verbose` with `codenicLogger.trace`
- Replace `codenicLogger.wtf` with `codenicLogger.fatal`

## 3.0.0
- Migrate to Dart 3

## 2.0.4
- Upload `logger` to `1.3.0`

## 2.0.3
- Downgrade `meta` to `1.8.0`

## 2.0.2
- Bump dependencies

## 2.0.1
- Update documentation link in README.md

## 2.0.0
- Deprecate `stackTraceBlocklistRegex` in favor of `stackTraceBlocklist`
- Create `stackTraceBlocklist` for excluding lines from stack trace
- Update `README.md`
- Add `copyWith` method on `CodenicLogger` and `MessageLogPrinter`

## 1.0.1
- Update README.md
## 1.0.0
- Major release

## 1.0.0-dev1
- Modify constructor of `CodenicLogger`
- Allow blocklisting of stack trace lines via regex
## 0.6.1
- Bump dependencies
## 0.6.0

– Bump dependencies

## 0.5.5

- Promote from `dev` to `stable`

## 0.5.5-dev.1

- BUG FIX: The `MessageLogPrinter` should not throw an exception when used in 
an `Isolate`

## 0.5.4

- BUG FIX: Stack trace should not show `codenic_logger` file traces in Flutter 
web

## 0.5.3

- Add docs on constructors
- Bump `test` from `1.19.5` to `1.20.1`

## 0.5.2

- Fix printing long log outputs loses color

## 0.5.1

- Export `MessageLogPrinter`

## 0.5.0

– Create `MessageLogPrinter` to change default log output

## 0.4.2

– Update README.md

## 0.4.1

– Update README.md

## 0.4.0

– Redesign `MessageLog`

## 0.3.0

– Make the `data` field in `MessageLog` non-nullable

## 0.2.1

– Update README.md

## 0.2.0

– Add data in `MessageLog`

## 0.1.0

- First release
