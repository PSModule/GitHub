---
ms.title: Pipeline prefetch
description: A reusable contract for fetching paginated results while downstream pipeline commands process earlier results.
---

# Pipeline prefetch

Eligible paginated result producers fetch ahead by default, retain normal pipeline output, and expose an explicit opt-out. The pattern overlaps data retrieval with downstream work; it does not make downstream commands parallel.

These documents describe intended behavior and target APIs, not a claim that the capability is already implemented in a released module.

| Document | Purpose | Reuse |
| --- | --- | --- |
| [Specification](spec.md) | Required behavior, limits, and acceptance scenarios | Shared across modules without service-specific changes |
| [Design](design.md) | Producer, foreground emitter, pagination adapter, and shared transport | Reusable execution pattern |
| [GitHub implementation profile](implementation.md) | Parameter contract, defaults, and GitHub integration points | Replace with the adopting module's profile |

## Applicability

Prefetch belongs in commands that produce paginated results, whether invoked alone or as part of a pipeline. Accepting pipeline input is not itself a reason to prefetch. Mutation commands and downstream consumers keep their existing execution behavior.

## Adoption

1. Keep the specification as the shared contract, linking to an authoritative copy or recording the revision of a vendored copy.
2. Supply a module profile defining eligible operations, output shapes, continuation rules, transport policy, and cancellation support.
3. Reuse the design through a module-private implementation or an existing owned library; no additional public runtime dependency is required.
4. Implement the specification's scenarios in the module's existing test framework, including execution in the actual background context.

The GitHub profile specializes the pattern. It is not a dependency of another module's adoption.

## Motivation

- [PSModule/GitHub#644](https://github.com/PSModule/GitHub/issues/644) describes pagination pauses during downstream processing.
- [PSModule/GitHub#645](https://github.com/PSModule/GitHub/pull/645) explores a GraphQL repository-list producer.
