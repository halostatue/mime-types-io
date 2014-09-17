## Contributing

I value any contribution to `mime-types-io` you can provide: a bug report, a
feature request, or code contributions.

`mime-types-io` is a relatively new codebase, but is based on my Ruby
implementation, and I have a few guidelines:

* Code changes *will* *not* be accepted without tests. The test suite is
  [iospec2][iospec2], which is recorded as a submodule.
* Match my coding style.
* Use a thoughtfully-named topic branch that contains your change. Rebase your
  commits into logical chunks as necessary.
* Use [quality commit messages][qcm].
* Do not change the version number; when your patch is accepted and a release
  is made, the version will be updated at that point.
* Submit a GitHub pull request with your changes.
* New or changed behaviours require new or updated documentation.

=== Adding or Modifying MIME Types

The mime-types registry is loaded from a JSON file in +data+, which has been
copied from the Ruby source at [halostatue/mime-types][hmt].  It is not
considered editable and cannot be compared in a pull request. New or modified
MIME types should be edited in the appropriate YAML file under `type-lists` in
the Ruby source. The format is as shown below for the `application/xml` MIME
type in `type-lists/application.yml`.

  - !ruby/object:MIME::Type
    content-type: application/xml
    encoding: 8bit
    extensions:
    - xml
    - xsl
    references:
    - IANA
    - RFC3023
    xrefs: !ruby/hash:MIME::Types::Container
      rfc:
      - rfc3023
    registered: true

There are other fields that can be added, matching the fields discussed in the
documentation for MIME::Type. Pull requests for MIME types on
[halostatue/mime-types][hmt] should just contain the changes to the YAML files
for the new or modified MIME types; I will convert the YAML files to JSON
prior to a new release. I would rather not have to verify that the JSON
matches the YAML changes, which is why it is not necessary to convert for the
pull request.

=== Test Dependencies

`mime-types-io` uses [quag/iospec2][iospec2] for testing and has been
submoduled here. There is a `Makefile` that will ensure that everything works
and run `iospec`.

=== Workflow

Here's the most direct way to get your work merged into the project:

* Fork the project.
* Clone down your fork (`git clone git://github.com/<username>/mime-types-io.git`).
* Create a topic branch to contain your change (`git checkout -b
  my_awesome_feature`).
* Hack away, add tests. Not necessarily in that order.
* Make sure everything still passes by running +rake+.
* If necessary, rebase your commits into logical chunks, without errors.
* Push the branch up (`git push origin my_awesome_feature`).
* Create a pull request against `halostatue/mime-types-io` and describe what
  your change does and the why you think it should be merged.

=== Contributors

* Austin Ziegler created mime-types-io.

[iospec2]: https://github.com/quag/iospec2
[qcm]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[hmt]: https://github.com/halostatue/mime-types
