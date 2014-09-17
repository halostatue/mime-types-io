#! /usr/bin/env iospec2/iospec

describe(MimeType,
  describe(simplify, "simplify",
    simplify("does not change already simplified strings",
      verify("text/plain" == MimeType simplify("text/plain"))
      verify("image/jpeg" == MimeType simplify("image/jpeg"))
    )

    simplify("simplifies extension types",
      verify("application/msword" == MimeType simplify("application/x-msword"))
      verify("application/msword" == MimeType simplify("x-application/msword"))
    )

    simplify("lowercases the results",
      verify("text/vcard" == MimeType simplify("text/vCard"))
      verify("text/vcard" == MimeType simplify("text/X-vCard"))
    )

    simplify("does not remove a non-starting extension marker",
      verify("text-x/vcard-x" == MimeType simplify("text-x/vcard-x"))
    )

    simplify("raises an exception for an invalid type",
      r := nil
      e := try(MimeType simplify("text"))
      e catch(Exception,
        verify(e error == "Invalid Content-Type text")
      )
    )
  )

  describe(isAscii, "isAscii",
    isAscii("detects default ASCII types",
      verify(MimeType with("text/plain") isAscii)
      verify(MimeType with("text/vCard") isAscii)
    )

    isAscii("detects default binary types",
      verify(MimeType with("application/x-msword") isAscii not)
      verify(MimeType with("image/jpeg") isAscii not)
    )
  )

  describe(isBinary, "isBinary",
    isBinary("detects default ASCII types",
      verify(MimeType with("text/plain") isBinary not)
      verify(MimeType with("text/vCard") isBinary not)
    )

    isBinary("detects default binary types",
      verify(MimeType with("application/x-msword") isBinary)
      verify(MimeType with("image/jpeg") isBinary)
    )
  )

  describe(isSignature, "isSignature",
    isSignature("reports the signature slot properly",
      verify(MimeType with("text/plain") isSignature not)
      verify(
        MimeType with("application/pkcs7") do(signature := true) isSignature
      )
    )
  )

  describe(isComplete, "isComplete",
    isComplete("says a type is complete if there are extensions",
      yaml := MimeType with(list("text/x-yaml", "yaml", "yml")) do(
        encoding := "8bit"
      )
      verify(yaml isComplete)
    )

    isComplete("says a type is not complete if there are no extensions",
      yaml := MimeType with("text/x-yaml") do(
        encoding := "8bit"
      )
      verify(yaml isComplete not)
    )
  )

  describe(construction, "construction",
    construction("sets the simplified slot properly",
      verify("text/plain" == MimeType with("text/plain") simplified)
      verify(
        "application/msword" == MimeType with("application/x-msword") simplified
      )
      verify(
        "application/msword" == MimeType with("x-application/msword") simplified
      )
      verify(
        "application/msx-word" == MimeType with("application/msx-word") simplified
      )
    )

    construction("sets the subType slot properly",
      verify("plain" == MimeType with("text/plain") subType)
      verify("msword" == MimeType with("application/x-msword") subType)
      verify("msword" == MimeType with("x-application/msword") subType)
      verify("msx-word" == MimeType with("application/msx-word") subType)
    )

    construction("sets the contentType slot properly",
      verify("text/plain" == MimeType with("text/plain") contentType)
      verify("application/x-msword" == MimeType with("application/x-msword") contentType)
      verify("x-application/msword" == MimeType with("x-application/msword") contentType)
      verify("application/msx-word" == MimeType with("application/msx-word") contentType)
    )
  )

  describe(asMap, "asMap",
    asMap("provides the correct minimal keys",
      t := MimeType with("a/b")
      m := t asMap

      keys := list("content-type", "registered", "encoding")
      keys foreach(key, verify(m hasKey(key)))
    )

    asMap("provides the correct extra keys",
      t := MimeType with("a/b") do(
        docs := list("Something")
        addExtensions("b")
        obsolete := true
        useInstead := list("c/d")
        signature := true
      )
      m := t asMap
      keys := list("docs", "extensions", "obsolete", "use-instead", "signature")
      keys foreach(key, verify(m hasKey(key)))
    )
  )

  describe(asJson, "asJson",
    asJson("provides the correct output",
      j := MimeType with("a/b")
      e := MimeType with(Yajl parseJson(j asJson))
      verify(j compare(e) == 0)
    )
  )

  describe(asString, "asString",
    asString("provides the correct output",
      m := MimeType with("text/plain")
      verify("text/plain" == "#{m}" interpolate)
    )
  )

  /*
  def test_CMP # '<=>'
    assert(MIME::Type.new('text/plain') == MIME::Type.new('text/plain'))
    assert(MIME::Type.new('text/plain') != MIME::Type.new('image/jpeg'))
    assert(MIME::Type.new('text/plain') == 'text/plain')
    assert(MIME::Type.new('text/plain') != 'image/jpeg')
    assert(MIME::Type.new('text/plain') > MIME::Type.new('text/html'))
    assert(MIME::Type.new('text/plain') > 'text/html')
    assert(MIME::Type.new('text/html') < MIME::Type.new('text/plain'))
    assert(MIME::Type.new('text/html') < 'text/plain')
    assert('text/html' == MIME::Type.new('text/html'))
    assert('text/html' < MIME::Type.new('text/plain'))
    assert('text/plain' > MIME::Type.new('text/html'))
  end

  def test_encoding
    assert_equal('quoted-printable', MIME::Type.new('text/plain').encoding)
    assert_equal('base64', MIME::Type.new('image/jpeg').encoding)
    assert_equal('base64', MIME::Type.new('application/x-msword').encoding)
    assert_equal('quoted-printable', MIME::Type.new('text/vCard').encoding)
    assert_equal('base64', MIME::Type.new('application/pkcs7-mime').encoding)
  end

  def test_encoding_equals
    yaml = make_yaml_mime_type
    assert_equal('8bit', yaml.encoding)
    yaml.encoding = 'base64'
    assert_equal('base64', yaml.encoding)
    yaml.encoding = :default
    assert_equal('quoted-printable', yaml.encoding)
    begin
      yaml.encoding = 'binary'
    rescue MIME::Type::InvalidEncoding => ex
      assert_equal('Invalid Encoding "binary" (valid values are [nil, :default, "base64", "8bit", "7bit", "quoted-printable"]).', ex.message)
    end
  end

  def test_default_encoding
    %w(text/plain text/html).each { |mt|
      assert_equal('quoted-printable', MIME::Type.new(mt).default_encoding)
    }
    %w(image/jpeg applicatoin/pkcs7-mime).each { |mt|
      assert_equal('base64', MIME::Type.new(mt).default_encoding)
    }
  end

  def test_like_eh
    assert(MIME::Type.new('text/plain').like?(MIME::Type.new('text/plain')))
    assert(MIME::Type.new('text/plain').like?(MIME::Type.new('text/x-plain')))
    refute(MIME::Type.new('text/plain').like?(MIME::Type.new('image/jpeg')))
    assert(MIME::Type.new('text/plain').like?('text/plain'))
    assert(MIME::Type.new('text/plain').like?('text/x-plain'))
    refute(MIME::Type.new('text/plain').like?('image/jpeg'))
  end

  def test_media_type
    assert_equal('text', MIME::Type.new('text/plain').media_type)
    assert_equal('image', MIME::Type.new('image/jpeg').media_type)
    assert_equal('application', MIME::Type.new('application/x-msword').media_type)
    assert_equal('text', MIME::Type.new('text/vCard').media_type)
    assert_equal('application', MIME::Type.new('application/pkcs7-mime').media_type)
    assert_equal('chemical', MIME::Type.new('x-chemical/x-pdb').media_type)
    assert_equal('appl', @applzip.media_type)
  end

  def test_obsolete_eh
    type = MIME::Type.new('content-type' => 'test/type',
                          'obsolete'     => true)
    assert(type.obsolete?)
    refute(make_yaml_mime_type.obsolete?)
  end

  def assert_priority(l, e, r)
    assert_equal(-1, l.first.priority_compare(l.last))
    assert_equal(0, e.first.priority_compare(e.last))
    assert_equal(1, r.first.priority_compare(r.last))
  end

  def test_priority_compare
    tl, te, tr = make('text/1'), make('text/1'), make('text/2')
    assert_priority([tl, tr], [tl, te], [tr, tl])

    tl.registered = te.registered = true
    tr = make(tl) { |t| t.registered = false }
    assert_priority([tl, tr], [tl, te], [tr, tl])

    tl.system = te.system = nil
    tr = make(tl) { |t| t.system = /#{RUBY_PLATFORM}/ }
    assert_priority([tl, tr], [tl, te], [tr, tl])

    tl.extensions = te.extensions = %w(1)
    tr = make(tl) { |t| t.extensions = nil }
    assert_priority([tl, tr], [tl, te], [tr, tl])

    tl.obsolete = te.obsolete = false
    tr = make(tl) { |t| t.obsolete = true }
    assert_priority([tl, tr], [tl, te], [tr, tl])

    tl.obsolete = te.obsolete = true
    tl.use_instead = te.use_instead = 'abc/xyz'
    tr = make(tl) { |t| t.use_instead = nil }
    assert_priority([tl, tr], [tl, te], [tr, tl])
    tr.use_instead = 'abc/zzz'
    assert_priority([tl, tr], [tl, te], [tr, tl])
  end

  def test_raw_media_type
    assert_equal('text', MIME::Type.new('text/plain').raw_media_type)
    assert_equal('image', MIME::Type.new('image/jpeg').raw_media_type)
    assert_equal('application', MIME::Type.new('application/x-msword').raw_media_type)
    assert_equal('text', MIME::Type.new('text/vCard').raw_media_type)
    assert_equal('application', MIME::Type.new('application/pkcs7-mime').raw_media_type)
    assert_equal('x-chemical', MIME::Type.new('x-chemical/x-pdb').raw_media_type)
    assert_equal('x-appl', @applzip.raw_media_type)
  end

  def test_raw_sub_type
    assert_equal('plain', MIME::Type.new('text/plain').raw_sub_type)
    assert_equal('jpeg', MIME::Type.new('image/jpeg').raw_sub_type)
    assert_equal('x-msword', MIME::Type.new('application/x-msword').raw_sub_type)
    assert_equal('vCard', MIME::Type.new('text/vCard').raw_sub_type)
    assert_equal('pkcs7-mime', MIME::Type.new('application/pkcs7-mime').raw_sub_type)
    assert_equal('x-zip', @applzip.raw_sub_type)
  end

  def test_registered_eh
    assert(MIME::Type.new('text/plain').registered?)
    assert(MIME::Type.new('image/jpeg').registered?)
    refute(MIME::Type.new('application/x-msword').registered?)
    assert(MIME::Type.new('text/vCard').registered?)
    assert(MIME::Type.new('application/pkcs7-mime').registered?)
    refute(@applzip.registered?)
    refute(MIME::Types['image/webp'].first.registered?)
    # Temporarily broken: requires the new data format to be enabled.
    assert(MIME::Types['application/x-www-form-urlencoded'].first.registered?)
  end

  */
)
