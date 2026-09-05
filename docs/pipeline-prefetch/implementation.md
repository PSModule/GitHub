---
ms.title: GitHub pipeline prefetch - Implementation
description: Settings and integration contracts for adopting the reusable prefetch pattern in the GitHub PowerShell module.
---

# GitHub pipeline prefetch - Implementation

This profile maps the reusable pattern to the GitHub module. Other modules replace this profile while retaining the [specification](spec.md).

## Design

[Pipeline prefetch design](design.md) owns the execution model, adapter contract, and lifecycle.

## Settings

| Setting | Value | Applies to | Rationale |
| --- | --- | --- | --- |
| Prefetch default | Enabled for eligible paginated list operations | Public list commands and their helpers | Consistent module-wide behavior |
| `NoPrefetch` | Public switch; absent means prefetch is enabled | Eligible public producers | Explicit opt-out propagated through every wrapper |
| `PrefetchPageCapacity` | Private setting; default 1; positive integer | One logical enumeration | One future page overlaps retrieval without the draft's larger node queue |
| `PerPage` | Existing endpoint-specific setting and limits | Requests | Prefetch does not change GitHub page size |
| Request concurrency | One logical page request per enumeration | Producer | Cursor-dependent retrieval remains ordered |
| Platform support | GitHub's declared PowerShell LTS support on Windows, macOS, and Linux | Complete contract | No platform-specific degradation |

With capacity one, the enumeration retains at most one foreground page and one future page, including an in-flight response. This is not a fixed byte limit.

The node-count `QueueCapacity` explored in [PSModule/GitHub#645](https://github.com/PSModule/GitHub/pull/645) is not an alias for `PrefetchPageCapacity`. Any externally consumed setting retains its existing meaning or receives an explicit compatibility migration.

## Public behavior

These examples express the target API:

```powershell
Get-GitHubRepository -Owner 'octocat' |
    Select-Object -First 10

Get-GitHubRepository -Owner 'octocat' -NoPrefetch |
    Select-Object -First 10
```

The first invocation can retrieve unused repositories within the lookahead bound. The second does not fetch ahead. Both emit `GitHubRepository` objects in source order.

Mutation commands, such as `Remove-GitHubRepository`, do not gain a background mutation worker. Their `ShouldProcess`, `WhatIf`, and confirmation behavior remain on the normal downstream path.

## Names and identifiers

| Element | Contract | Owner |
| --- | --- | --- |
| `Get-GitHubRepository` and other eligible public list commands | Resolve and propagate `NoPrefetch`; retain public parameter sets and output types | Public command |
| `Get-GitHubMyRepositories` | Select the `viewer.repositories` connection and create `GitHubRepository` objects in the foreground | Repository adapter |
| `Get-GitHubRepositoryListByOwner` | Select the `repositoryOwner.repositories` connection and preserve filters | Repository adapter |
| Shared page coordinator | Own scheduling and lifetime without GitHub-specific response logic | Private reusable pattern |
| Shared single-request primitive | Perform one logical request using common API policy; do not auto-follow pagination | Private transport extracted behind existing API entry points |
| `Invoke-GitHubAPI` | Preserve its response-envelope contract and use the REST adapter for eligible pagination | REST API facade |
| `Invoke-GitHubGraphQLQuery` | Preserve raw-query behavior and GraphQL response classification | GraphQL API facade |

The single-request primitive is shared by both synchronous and prefetched pagination. Simply invoking an already-auto-paginating `Invoke-GitHubAPI` from the worker is insufficient: it gives two layers ownership of pagination.

## Adapter mappings

| Concern | REST adapter | GraphQL connection adapter |
| --- | --- | --- |
| Eligibility | Known read-only list operation | Module-owned read-only query with one explicitly selected connection |
| Source continuation | Validated next relation from the response | `pageInfo.hasNextPage` and `pageInfo.endCursor` |
| Resource items | Endpoint-specific array or wrapper property | Selected connection's `nodes` |
| Empty page | Continue if a next relation exists | Continue if `hasNextPage` is true and the cursor advances |
| Invalid continuation | Surface an invalid or non-advancing next relation | Surface missing connection, missing required page information, or missing/non-advancing cursor |
| Raw API output | One existing API response envelope per page | Existing raw query returns `data`; connection-item mode is a distinct explicit contract |

REST response envelopes retain `Request`, `Response`, `Headers`, `StatusCode`, and `StatusDescription` where those fields are part of the existing contract. High-level list commands continue to unwrap and construct their established resource types.

GraphQL response classification is shared, not reimplemented inside a producer script. A response with both `data` and `errors` preserves the module's partial-data warnings; an error-only response remains terminating. Invalid selected-connection data is classified before any of that page's nodes are emitted.

Arbitrary calls to `Invoke-GitHubGraphQLQuery` do not become automatic connection enumerations. The helper may execute mutations or queries with multiple unrelated connections. Known list wrappers select a trusted read-only connection adapter; a generic `ConnectionPath` alone does not establish read-only eligibility.

## Request policy and authentication

The transport reuses the configured API endpoint, API version, user agent, HTTP behavior, retry count, retry interval, response metadata, and error classification. It preserves rate-limit and server-directed retry behavior rather than adding a second retry loop.

The worker initializes the same module build and resolves its private adapter in module scope. It obtains worker-owned request state for the selected context rather than sharing a mutable foreground context object.

Token refresh uses the existing auth-type-specific policy and synchronization. For user access tokens, callers of `Update-GitHubUserAccessToken` adopt the returned context when required; a refreshed context can replace an earlier object. A long enumeration does not rely on one startup-only plaintext token snapshot.

Interactive authentication is resolved before background work. If reauthentication is required during enumeration and cannot complete noninteractively, the invocation surfaces an actionable authentication failure.

## Requirement crosswalk

| Requirement | Satisfied by |
| --- | --- |
| FR1 | Default-on settings and `NoPrefetch` forwarding on every eligible public/private path |
| FR2, FR3 | Page adapters, unchanged raw envelopes, and foreground resource construction |
| FR4, NFR1 | Single producer and reserved future-page capacity |
| FR5 | Shared one-request transport and shared GraphQL response classification |
| FR6 | Independent terminal state plus ordered foreground stream handling |
| FR7, NFR2 | Cancellation-aware request/backoff/capacity waits and complete worker teardown |
| FR8 | Invocation-owned filters/context and coordinated shared credential state |
| FR9 | Endpoint-specific live-pagination documentation and no speculative mutations |
| NFR3 | Redacted transport diagnostics and no credential-bearing coordination records |
| NFR4 | Contract scenarios on the module's declared platform matrix |

## Integration boundaries

Adoption includes all eligible REST and GraphQL list paths, not only repository connections. A command returning one result, a consumer accepting pipeline input, or a mutating operation is not automatically eligible.

Stable-source fixtures establish parity and complete pagination independently of prefetch. Known defects in an existing sequential paginator are corrected and identified as correctness changes, not preserved as expected output.

Listing repositories while deleting them is not a snapshot operation. Cursor pagination can still be sensitive to remote changes; neither fetch-ahead nor opt-out promises complete mutation-safe enumeration.

## Source context

- [PSModule/GitHub#644](https://github.com/PSModule/GitHub/issues/644) records the cross-module motivation and shared-transport direction.
- [PSModule/GitHub#645](https://github.com/PSModule/GitHub/pull/645) provides the repository-connection prototype.
- [API transport source](https://github.com/PSModule/GitHub/blob/31206e3dac0d3d84bf3eb5f75a8b5123d7e7730e/src/functions/public/API/Invoke-GitHubAPI.ps1) shows response envelopes and automatic REST pagination.
- [GraphQL facade source](https://github.com/PSModule/GitHub/blob/31206e3dac0d3d84bf3eb5f75a8b5123d7e7730e/src/functions/public/API/Invoke-GitHubGraphQLQuery.ps1) shows raw-query and partial-response behavior.
