# mime-types-io

| ---- | -------------------------------------------- |
| code | [https://github.com/halostatue/mime-types-io/][code] |
| bugs | [https://github.com/halostatue/mime-types-io/issues][issues] |

## Description

The `mime-types-io` library provides a library and registry for information
about MIME content type definitions. It can be used to determine defined
filename extensions for MIME types, or to use filename extensions to look up
the likely MIME type definitions.

MIME content types are used in MIME-compliant communications, as in e-mail or
HTTP traffic, to indicate the type of content which is transmitted. The
`mime-types-io` library provides the ability for detailed information about
MIME entities (provided as an enumerable collection of MimeType objects) to be
determined and used programmatically. There are many types defined by RFCs and
vendors, so the list is long but by definition incomplete; don't hesitate to
to add additional type definitions (see [Contributing][contributing]). The
primary sources for MIME type definitions found in `mime-types-io` is the IANA
collection of registrations (see below for the link), RFCs, and W3C
recommendations.

This is release 1.0, ported from the Ruby release
([halostatue/mime-types][hmt]).

## Synopsis

MIME types are used in MIME entities, as in email or HTTP traffic. It is
useful at times to have information available about MIME types (or, inversely,
about files). A MimeType stores the known information about one MIME type.

```io
    plaintext := MimeTypes["text/plain"]
    # returns list(text/plain)
    text := plaintext first

    text mediaType println            # => text
    text subType println              # => plain
    text extensions join(" ") println # => asc c cc h hh…
    text encoding println             # => quoted-printable
    text isBinary println             # => false
    text isAscii println              # => true
    text isObsolete println           # => false
    text isRegistered println         # => true
    text isLike("text/plain") println # => true
    MimeType simplifiedFor("x-appl/x-zip") println
                                      # => "appl/zip"
```

## `mime-types-io` Modified Semantic Versioning

The `mime-types-io` library has one version number, but this single version
number tracks both API changes and registry data changes; this is not wholly
compatible with all aspects of [Semantic Versioning][semver]; removing a MIME
type from the registry *could* be considered a breaking change under some
interpretations of semantic versioning (as lookups for that particular type
would no longer work by default).

`mime-types-io` uses a modified semantic versioning scheme. Given the version
MAJOR.MINOR:

1. If an incompatible API (code) change is made, the MAJOR version will be
   incremented, MINOR will be set to zero, and PATCH will be reset to the
   implied zero.

2. If an API (code) feature is added that does not break compatibilty OR if
   there are MIME types added, removed, or changed in the registry, the MINOR
   version will be incremented and PATCH will be reset to the implied zero.

3. If there is a bugfix to a feature added in the most recent MAJOR.MINOR
   release, OR if purely typographical errors are fixed in MIME types, the
   implied PATCH value will be incremented resulting in MAJOR.MINOR.PATCH.

In practical terms, there should be a MINOR release roughly monthly to track
updated or changed MIME types from the official IANA registry. This does not
indicate when new API features have been added, but all minor versions of
`mime-types-io` 1.x will be backwards compatible; the interfaces marked deprecated
will not be removed until at least `mime-types-io` 2.x or possibly later.

## Licence

`mime-types-io` is under the MIT licence. See [Licence][licence].

[code]: https://github.com/halostatue/mime-types-io/
[issues]: https://github.com/halostatue/mime-types-io/issues
[hmt]: https://github.com/halostatue/mime-types/
[contributing]: Contributing.md
[licence]: Licence.md
[semver]: http://semver.org/
