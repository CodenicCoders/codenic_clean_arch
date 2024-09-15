## 4.1.0
- Add `code` in `Failure` to store the error code.

## 4.0.1
- Fix: `printOutput` parameter in `ExceptionConverter.observe` and 
`ExceptionConverter.convert` does not disable output printing.

## 4.0.0
- Bump dependency versions.
- Add `printOutput` boolean parameter to `ExceptionConverter.observe` and `ExceptionConverter.convert` to print the returned output of the task as part of the `MessageLog.data` keyed by `__output__`.
- Remove exception handling in `ExceptionConverter.convert` and move it to the new
  `ExceptionConverter.logException` method.

## 3.2.0
- Add `EitherExtension` for easier access of left and right values

## 3.1.2
- Bump `codenic_logger` from `4.0.0` to `4.0.1`
- Rethrow error with stacktrace

## 3.1.1
- Bump dependencies

## 3.1.0
- BUGFIX: `ExceptionConverter.exceptionEquals` now correctly compares `Exception` instances

## 3.0.0
- Migrate to Dart 3

## 2.0.3
- Update default `Failure` message

## 2.0.2
- Upgrade `codenic_logger` to `2.0.4`

## 2.0.1
- Remove unused `printResult` in `ExceptionConverterSuite`

## 2.0.0
- Remove `Failure` generic type in `ExceptionConverter`

## 1.0.3
- Upgrade `codenic_logger` to `2.0.3`

## 1.0.2
- Bump dependencies
- Use `FutureOr` in `ExceptionConverter.observe` and `ExceptionConverter.observe` `task` parameters.
- Deprecate `ExceptionConverter.observeSync` and `ExceptionConverterSuite.observeSync`

## 1.0.1
- Update documentation link in README.md

## 1.0.0
- Initial version