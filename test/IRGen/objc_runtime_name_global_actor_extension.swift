// RUN: %target-swift-frontend %s -target %target-swift-5.1-abi-triple -emit-ir | %FileCheck %s

// REQUIRES: objc_interop
// REQUIRES: concurrency

// Regression test: the OldRemangler used to read a nonexistent Index payload
// on GlobalActorFunctionType nodes when building the ObjC runtime name for a
// class whose declaration context contained a global-actor-qualified function
// type. On asserts builds the compiler crashed; on release builds the name
// was silently corrupt.

protocol Handling: AnyObject {}

struct Wrapper<T> {}

extension Wrapper where T == @MainActor () -> Void {
  // The ObjC runtime name for this class encodes the extension context,
  // including the MainActor global actor qualifier on the function type.
  // Check that the mangled name contains `YCs9MainActor` (the `Y` marker
  // followed by `Cs9MainActor`, i.e. Swift.MainActor).
  // CHECK: _IVARS__TtCe{{[0-9]+}}{{[A-Za-z0-9_]+}}FYCs9MainActor
  final class Container {
    var handler: (any Handling)?
  }
}
