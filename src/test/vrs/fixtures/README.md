# VRS interoperability fixtures

This directory is for minimized, deterministic SIP signaling fixtures used to reproduce VRS/iTRS interoperability behavior.

No fixture is evidence merely because it came from a capture. The committed fixture is a deliberately minimized reproduction object whose bytes, provenance, and relationship to the observed failure are reviewable.

## Directory shape

Each fixture gets its own directory:

```text
<fixture-id>/
  manifest.json
  0001-peer-to-sut.sip
  0002-sut-to-peer.sip
  ...
```

`manifest.json` follows `../fixture.schema.json` and records message order, direction, transport, message SHA-256 values, and bounded provenance.

`.sip` files are marked `-text` in `.gitattributes`. Git must preserve their bytes exactly, including CRLF framing and intentionally malformed syntax.

## Source boundary

Preferred fixture sources, in order:

1. synthetic messages that reproduce the behavior;
2. controlled-lab observations containing no real subscriber data; or
3. a minimized derivative of controlled evidence when the behavior cannot be reproduced synthetically.

Sandia Wiretap may be listed in `source.networkPath` when it provided the network path to a controlled lab endpoint. Wiretap is not the capture tool and no WireGuard private key or generated Wiretap configuration belongs in a fixture.

Raw `.pcap` / `.pcapng`, WireGuard configuration, private keys, certificates, production identifiers, subscriber data, and unrelated application payloads are forbidden here and are ignored by the directory-level `.gitignore` as a last guardrail.

## Minimization rule

Preserve every byte relevant to the failure. Remove everything else only when doing so cannot alter the behavior under test.

A redaction may be described in `manifest.json` only when the redacted field is not failure-relevant. The schema requires `failureRelevant: false` for recorded redactions. If a value implicated in the failure is sensitive, do not commit a transformed version and pretend it is equivalent; reproduce the condition synthetically instead.

Pay particular attention to:

- CRLF versus LF;
- header ordering and duplication;
- compact header forms;
- whitespace and folding;
- malformed but tolerated syntax;
- `Content-Length` and body byte count;
- URI escaping;
- Via branch, CSeq, Call-ID and tag relationships;
- retransmission identity; and
- inter-message timing when timing is part of the failure.

Do not automatically reserialize a captured SIP message before preserving it. Parser/serializer normalization can erase the defect we are trying to reproduce.

## Provenance

For controlled-lab-derived fixtures, `source.evidenceSha256` may bind the minimized fixture to an externally retained evidence object. The source evidence itself stays outside this repository and can be admitted separately through the WindAnvil evidence path.

`source.networkPath[].configSha256` may identify a non-secret configuration object by digest. Never commit the configuration itself if it contains WireGuard keys, credentials, production routes, or other sensitive material.

## Test sequencing

The first fixture PR after the historical baseline is proven should contain:

1. one minimized fixture;
2. a regression test that fails against the proven unmodified baseline for the observed reason; and
3. no production SIP implementation change.

The protocol fix follows in a separate commit or PR, with the same fixture turning green. This preserves the evidence chain:

```text
observation -> minimized bytes -> red test -> minimal fix -> green test
```
