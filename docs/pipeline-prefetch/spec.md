---
ms.title: Pipeline prefetch - Spec
description: Eligible paginated result producers overlap retrieval and consumption without changing their output contract.
---

# Pipeline prefetch - Spec

Eligible paginated result producers fetch ahead by default while downstream commands consume earlier results. Callers retain ordered streaming output, bounded resource use, established request policies, and an explicit opt-out. The contract applies across modules and services.

## Problem

An ordinary pipeline streams objects but processes its stages synchronously. A paginated producer can therefore wait for downstream processing of one page's objects before requesting the next page. Source latency and downstream latency accumulate even when their work could overlap.

Collecting all results first replaces that delay with startup latency and potentially unbounded memory use. Neither behavior provides bounded fetch-ahead.

## Outcomes and impact

- **Outcome:** Paginated retrieval overlaps downstream work without requiring caller-managed concurrency.
- **DORA:** Shared acceptance criteria reduce duplicated pagination defects and lead time when adopting the pattern in another module.
- **Domain signal:** Time waiting for a next page decreases in workloads containing both source latency and downstream work; time to first item and total request count remain visible.

## Users and jobs

| User | Job |
| --- | --- |
| Pipeline caller | Process results as they arrive without managing background execution |
| Module author | Apply one behavior consistently across paginated list commands |
| Operator | Bound speculative requests and stop work when results are no longer needed |

## Scope

**In scope**

- Read-only paginated result producers, including object-returning and page-returning interfaces.
- Default-on fetch-ahead, a consistent opt-out, and propagation through command wrappers.
- Ordering, request policy, cancellation, diagnostics, and resource bounds.

**Out of scope**

- Parallel downstream processing, speculative mutations, and automatic concurrency for every command accepting pipeline input.
- Source-specific snapshot guarantees, durable caching, and resumable background jobs.
- Changes to the PowerShell pipeline engine.

## Non-goals

- Prefetch does not promise a speedup for every workload; it creates an opportunity to overlap independent work.
- Prefetch does not make a changing remote collection into a stable snapshot.
- Prefetch does not require a shared public module or prescribe how implementations are packaged.

## Functional requirements

### FR1 - Apply the default consistently and honor opt-out {#fr1}

Every eligible paginated result producer MUST enable prefetch by default and expose the same documented opt-out within its module. Wrappers MUST preserve that choice. With prefetch disabled, the invocation MUST NOT perform speculative next-page requests.

Eligibility requires read-only page retrieval, valid continuation handling, bounded responses, and support for the cancellation contract. Exceptions MUST be documented by operation; worker failures MUST NOT silently change execution mode.

#### Behavioral scenarios

```gherkin
Scenario: A wrapper preserves opt-out
  Given a list command delegates pagination to shared helpers
  When the caller disables prefetch
  Then every helper preserves that choice
  And the next page is not requested while earlier results block downstream
```

### FR2 - Preserve streaming and output contracts {#fr2}

The producer MUST emit available results without waiting for the complete collection. Output types, property shapes, item enumeration, and documented metadata MUST remain compatible with non-prefetched execution. Internal coordination records MUST NOT appear on the success stream.

#### Behavioral scenarios

```gherkin
Scenario: The first page is usable independently
  Given the first page is available and a later page is blocked
  When the caller consumes results
  Then first-page items arrive before the later page completes
  And each item has the established public output type and shape
```

### FR3 - Preserve ordered and complete enumeration {#fr3}

For a stable source, prefetch MUST return the same ordered results as non-prefetched execution. It MUST NOT introduce loss or duplication when retrying a page. An empty page with a valid continuation MUST NOT end enumeration. A missing required continuation or an unchanged next continuation MUST produce a pagination error rather than silent truncation or repeated requests.

#### Behavioral scenarios

```gherkin
Scenario: An empty page has a successor
  Given a page has no items and has a valid next continuation
  When enumeration continues
  Then the next page is requested
  And its items retain source order
```

### FR4 - Overlap retrieval with consumption {#fr4}

With prefetch enabled, spare capacity, a known continuation, and no transport-policy delay, the producer MUST be able to request the next page while downstream processing is blocked on an earlier item. It MUST NOT require the caller to make downstream commands concurrent.

#### Behavioral scenarios

```gherkin
Scenario: Downstream work does not prevent next-page retrieval
  Given the first page is available and another page exists
  And downstream processing pauses on the first item
  When prefetch capacity is available
  Then retrieval of the next page starts before downstream processing resumes
```

### FR5 - Preserve request and response policies {#fr5}

Prefetched and non-prefetched retrieval MUST use the same authentication, refresh, retry, throttling, endpoint, timeout, and response-classification policies. Prefetch MUST NOT multiply an existing retry budget or reinterpret partial success as complete failure. A page MUST be classified before its results become eligible for output.

#### Behavioral scenarios

```gherkin
Scenario: A retryable response does not duplicate output
  Given the transport permits a bounded retry for a failed page request
  When that request succeeds on retry
  Then the existing retry and delay policy is honored
  And that page's results are emitted once
```

### FR6 - Surface failures at the correct stream boundary {#fr6}

An unrecoverable retrieval or pagination failure MUST surface after previously accepted pages and before any results from the failed page, unless the caller stops earlier. Previously emitted results are not rolled back. Established warning and partial-result behavior MUST remain intact.

Initialization and background-execution failures MUST also surface; an empty queue MUST NOT be mistaken for successful completion. Intentional caller cancellation MUST NOT become a fabricated retrieval error.

#### Behavioral scenarios

```gherkin
Scenario: Retrieval fails after accepted results
  Given two pages are accepted and the next page fails permanently
  When the caller consumes the enumeration to completion
  Then accepted results are emitted in order
  And the failure is reported once at the failed page boundary
  And the invocation does not report successful complete enumeration
```

### FR7 - Stop when results are no longer wanted {#fr7}

Early downstream termination, downstream failure, explicit cancellation, and producer-owned result limits MUST stop further retrieval. After stop is observed, no new page request or retry may begin. In-progress work MUST be canceled and invocation-owned resources released within the cancellation contract.

Prefetch MAY retrieve results that are never consumed, within its declared bound. It MUST NOT intentionally retrieve pages known to be unnecessary for a producer-owned limit.

#### Behavioral scenarios

```gherkin
Scenario: The caller only needs a prefix
  Given more pages exist than the caller needs
  When downstream stops after the required prefix
  Then no further page request starts after stop is observed
  And cancellation of speculative work does not replace the caller's stop reason
```

### FR8 - Isolate invocation state {#fr8}

Concurrent enumerations MUST retain their own filters, continuation, endpoint selection, and authentication identity. Fetch-ahead MUST NOT mutate caller-owned request inputs or expose ordinary downstream state to concurrent modification. Shared transport or credential coordination MUST remain safe across invocations.

#### Behavioral scenarios

```gherkin
Scenario: Two contexts enumerate concurrently
  Given two invocations use different identities and filters
  When both retrieve multiple pages
  Then each request uses its invocation's identity and filters
  And neither invocation changes the other's continuation or caller-owned inputs
```

### FR9 - State live-collection limitations {#fr9}

The module MUST document whether each source provides snapshot or live enumeration. Prefetch MUST NOT claim stronger consistency than the source provides or introduce speculative writes. Disabling prefetch MUST remain available for callers that require non-prefetched request timing, but MUST NOT be described as a cure for mutation-sensitive pagination.

#### Behavioral scenarios

```gherkin
Scenario: Results are mutated while enumeration continues
  Given the source provides live rather than snapshot pagination
  When downstream changes the collection being listed
  Then the module makes no guarantee against source-induced omissions or duplicates
  And prefetch itself performs no mutation
```

## Non-functional requirements

### NFR1 - Bound lookahead and retained data {#nfr1}

The module MUST declare a finite positive page capacity, C. No more than C future pages may be queued, held for publication, or in flight in total, in addition to one page being consumed. At most one logical page retrieval may be in flight per enumeration.

The implementation MUST NOT retain a second unbounded result or diagnostic history. A page-count bound is not a byte bound; the module MUST document source page-size limits and any additional payload limit it enforces.

#### Behavioral scenarios

```gherkin
Scenario: A blocked consumer applies backpressure
  Given capacity is one future page
  And downstream is blocked on the active page
  When the future page has been retrieved
  Then no third page request starts until future-page capacity becomes available
  And no more than two pages are retained by that enumeration
```

### NFR2 - Make cancellation bounded and observable {#nfr2}

With a controllable, cancellation-aware source, all invocation-owned background work and pending reads MUST finish within five seconds of stop. Production adapters MUST document finite request, retry, and shutdown bounds; they MUST NOT depend on an uninterruptible operation to satisfy this contract.

#### Behavioral scenarios

```gherkin
Scenario: Cancellation interrupts a blocked request
  Given the source is waiting indefinitely until released or canceled
  When the caller stops the enumeration
  Then the request observes cancellation
  And no invocation-owned background work remains after five seconds
```

### NFR3 - Keep credentials out of diagnostics {#nfr3}

Prefetch MUST introduce zero credential values into emitted diagnostics, exception messages, or persisted coordination data. Logs MAY identify a request, page, or invocation, but MUST NOT expose credentials or unredacted sensitive request payloads.

#### Behavioral scenarios

```gherkin
Scenario: A request fails with diagnostics enabled
  Given authentication contains a unique synthetic secret marker
  When a request fails with verbose and debug diagnostics enabled
  Then the marker appears in no diagnostic, exception message, or persisted artifact
```

### NFR4 - Preserve the supported platform matrix {#nfr4}

Every adopting module MUST satisfy the contract on 100 percent of its declared supported runtime and operating-system combinations. Prefetch MUST NOT silently become unavailable on one supported platform.

#### Behavioral scenarios

```gherkin
Scenario: An adopter supports multiple platforms
  Given the adopter declares its supported runtime and operating-system matrix
  When the shared contract scenarios run on each combination
  Then output, ordering, opt-out, bounds, and cancellation meet the same requirements
```

## Acceptance criteria

```gherkin
# AC1 - Verifies: FR2, FR3, FR4, NFR1
Scenario: A slow consumer receives a complete ordered stream
  Given a stable multi-page source and capacity of one future page
  When downstream pauses during each page
  Then retrieval overlaps those pauses
  And capacity remains bounded
  And the final ordered results match non-prefetched enumeration

# AC2 - Verifies: FR5, FR6, FR7, NFR2
Scenario: Downstream fails while retrieval is backing off
  Given a next-page request is waiting under the shared retry policy
  When downstream raises an error
  Then retry waiting and background retrieval are canceled
  And cleanup completes within the cancellation contract
  And the downstream error remains the primary failure

# AC3 - Verifies: FR1, FR2, FR3, FR8
Scenario: A second module adopts the same contract
  Given two modules have different output types and continuation formats
  When both enumerate stable fixtures with and without prefetch
  Then both preserve their public result contracts
  And both honor the same opt-out behavior through their wrappers
```

## Constraints and assumptions

- **Constraint:** Source request policies and read-only eligibility take precedence over fetch-ahead.
- **Constraint:** Prefetch preserves ordinary synchronous downstream execution.
- **Assumption:** A source declares a bounded page response and meaningful continuation semantics.
- **Assumption:** Stable-source equivalence does not imply consistency while remote data changes.

## Dependencies

- An adopter-owned definition of eligible operations, response classification, and cancellation behavior.
- Source-specific fixtures and the adopting module's existing test framework.

## Where this connects

- [Design](design.md) describes how the contract is delivered.
- [GitHub implementation profile](implementation.md) maps it to one adopting module.
