## 3.0.1
- Update documentation link in README.md

## 3.0.0
- Make use cases focus on simple CRUD operations
  - Deprecate `BatchRunner`
  - Deprecate `Paginator`
- Add return type in `Runner.run()`
- Add return type in `Watcher.watch()`
- Add extension methods `getRightOrNull` and `getLeftOrNull` in `Either`
- Update README.md

## 2.1.0

- Add `params`, `leftParams` and `rightParams` in all use cases
- Bump dependencies
- Update README.md

## 2.0.2

- BUGFIX: Do not emit state when respective use case is closed
- Bump dependencies

## 2.0.0

- Reduce generic types of `Watcher` and `Paginator`
- Bump dependencies

## 1.0.0

- Migrate from `dartz` to `fpdart`

## 0.1.0

- Bump dependencies
- Move from `dev` to `stable`

## 0.1.0-dev.8

- Make annotation `template` and `macro` contain class name suffix

## 0.1.0-dev.6/7

- Export `equatable` package
- Export `ensure_async.dart` and `base.dart` file

## 0.1.0-dev.5

- Remove `L` and `R` generic types in `BatchRunner`, `BatchRunResult` and
  `UseCaseFactory`

## 0.1.0-dev.4

- Export `bloc` package

## 0.1.0-dev.3

- Add cover image in README.md

## 0.1.0-dev.2

- Add documentation in README.md

## 0.1.0-dev.1

- First release
