# VRS interoperability proving ground

This branch is a controlled interoperability laboratory built on the NIST JAIN-SIP 1.2 Reference Implementation.

## First principle

Preserve a reproducible baseline before changing SIP behavior.

The repository does not own the proving infrastructure. Instead, it exposes a small, deterministic runner contract at `ci/vrs-baseline.sh`. External CI is responsible for cloning the exact commit, provisioning the declared historical toolchain, invoking that contract, preserving evidence, and reporting the result.

The inherited Ant build pins `javac.source=1.5` and `javac.target=1.5`. A JDK/build modernization is therefore a separate migration and must not be mixed with protocol fixes.

## External CI contract

The baseline runner expects:

- JDK 8;
- Apache Ant with its JUnit task available;
- `svnversion` from Subversion, because the inherited build invokes it while generating version metadata; and
- Git.

The inherited build inputs used by `make` / `runtck` are repository-local and are preflighted by the runner:

- `lib/log4j-1.2.15.jar`
- `lib/junit-3.8.1.jar`
- `ant-tasks/lib/ant.jar`
- `ant-tasks/lib/jdom.jar`
- `ant-build-config.properties`
- `tck.properties`

The runner executes:

1. `ant make`
2. `ant runtck`

External CI should preserve, when present:

- `test-reports/`
- `logs/`
- generated JARs
- `version.txt`
- `TIMESTAMP`

The CI system should also bind those artifacts to the tested Git commit and record the toolchain versions used for the run.

### Historical version metadata

`generate-version` runs `svnversion` and then feeds `version.txt` to the inherited `VersionerTask`. A Git checkout is not a Subversion working copy, so that value is not a trustworthy source identity; the historical task may fall back to its legacy numeric default when naming generated artifacts.

For this proving ground, the exact Git commit supplied and independently verified by external CI is authoritative. `version.txt`, `TIMESTAMP`, and legacy versioned JAR names are preserved only as build evidence. They must not be interpreted as revision identity.

### TCK isolation

The inherited TCK self-test binds to loopback and uses fixed SIP ports `5060` and `6050`. The external Jenkins `jsip-jdk8` worker should therefore be configured as a single-executor lane, with no unrelated SIP workload sharing those ports during a run.

The baseline `runtck` target excludes TCP, TLS, and SCTP call-flow tests. Those transports belong in later, explicit interoperability slices rather than being silently folded into the historical baseline.

## Evidence model

Each interoperability finding should eventually be represented as:

1. a minimized SIP fixture or deterministic call-flow scenario;
2. an observed failure against the unmodified baseline;
3. a narrowly scoped implementation change;
4. a regression test demonstrating the corrected behavior; and
5. preserved external-CI artifacts sufficient to inspect the result.

## Intended coverage

The proving ground is expected to grow around VRS/iTRS-relevant signaling behavior, including:

- INVITE / provisional response / final response / ACK flows;
- CANCEL and BYE handling;
- re-INVITE and dialog mutation;
- retransmissions and transaction timing;
- malformed or unusual but field-observed SIP messages;
- TCP, TLS, UDP, and WebSocket transport behavior where applicable;
- B2BUA and proxy interaction patterns; and
- reproducible captures derived from interoperability testing.

## Wiretap boundary

Sandia Wiretap is transport plumbing for reaching a test network path; it is not the canonical SIP recorder or fixture format for this proving ground.

When Wiretap is used, capture or observation happens separately at a controlled lab endpoint. Raw network captures are transient evidence only. A committed regression fixture should contain the smallest sanitized SIP signaling needed to reproduce the behavior, plus enough provenance to relate it to the controlled observation without retaining subscriber data, credentials, production addresses, or unrelated payloads.

## Scope discipline

The baseline branch must not silently normalize, rewrite, or "improve" observed SIP traffic. Captures and fixtures should preserve the behavior under investigation, with sanitization limited to secrets and personally identifiable information.

Evidence gathered over Wiretap-enabled test paths should be minimized before committing. Do not commit WireGuard keys, credentials, production identifiers, subscriber data, or raw captures containing sensitive information.

## Sequence

1. Establish the historical build and TCK baseline through external CI.
2. Preserve evidence from that baseline and bind it to the tested commit.
3. Add deterministic interoperability fixtures without changing stack behavior.
4. Introduce one protocol fix at a time, each tied to a failing fixture.
5. Modernize the Java/build toolchain separately once the inherited baseline is understood.
