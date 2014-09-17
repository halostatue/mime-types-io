
/*
class TestMIMETypes < Minitest::Test
  def setup
    @mime_types = MIME::Types.new
    @mime_types.add(MIME::Type.new(['text/plain', %w(txt)]),
                    MIME::Type.new(['image/jpeg', %w(jpg jpeg)]),
                    MIME::Type.new('application/x-wordperfect6.1'),
                    MIME::Type.new('content-type' => 'application/x-www-form-urlencoded', 'registered' => true),
                    MIME::Type.new(['application/x-gzip', %w(gz)]),
                    MIME::Type.new(['application/gzip', %W(gz)]))
  end

  def test_enumerable
    assert(@mime_types.any? {|type| type.content_type == 'text/plain'})
  end

  def test_index_with_mime_type
    xtxp = MIME::Type.new('x-text/x-plain')
    assert_includes(@mime_types[xtxp], 'text/plain')
    assert_equal(1, @mime_types[xtxp].size)
  end

  def test_index_with_regex
    assert_includes(@mime_types[/plain/], 'text/plain')
    assert_equal(1, @mime_types[/plain/].size)
  end

  def test_index_with_string
    assert_includes(@mime_types['text/plain'], 'text/plain')
    assert_equal(1, @mime_types['text/plain'].size)
  end

  def test_index_with_complete_flag
    assert_empty(@mime_types['text/vnd.fly', complete: true])
    refute_empty(@mime_types['text/plain', complete: true])
  end

  def test_index_with_registered_flag
    assert_empty(@mime_types['application/x-wordperfect6.1',
                             registered: true])
    refute_empty(@mime_types['application/x-www-form-urlencoded',
                             registered: true])
    refute_empty(@mime_types['application/gzip', registered: true])
    refute_equal(@mime_types['application/gzip'].size,
                 @mime_types['application/gzip', registered: true])
  end

  def test_index_with_platform_flag
    assert_deprecated("MIME::Types#[]", "using the :platform flag") do
      assert_empty(MIME::Types['text/plain', platform: true])
    end
  end
  def test_add
    eruby = MIME::Type.new("application/x-eruby") do |t|
      t.extensions = "rhtml"
      t.encoding = "8bit"
    end

    @mime_types.add(eruby)

    assert_equal(@mime_types['application/x-eruby'], [eruby])
  end

  def test_type_for
    assert_equal(%w(application/gzip application/x-gzip),
                 @mime_types.type_for('gz'))
    assert_equal(%w(image/jpeg), MIME::Types.of('foo.jpeg'))
    assert_equal(%w(image/jpeg text/plain),
                 MIME::Types.type_for(%w(foo.txt foo.jpeg)))
    assert_equal(@mime_types.of('gif', true), @mime_types['image/gif'])
    assert_empty(MIME::Types.type_for('coverallsjson'))
    assert_deprecated("MIME::Types#type_for", "using the platform parameter") do
      assert_empty(MIME::Types.type_for('jpeg', true))
    end
    assert_empty(@mime_types.type_for('zzz'))
  end

  def test_count
    assert_equal(6, @mime_types.count)
  end

  # This tests the instance implementation through the class implementation.
  def test_add_type_variant
    xtxp = MIME::Type.new('x-text/x-plain')
    assert_deprecated("MIME::Types#add_type_variant", "and will be private") do
      @mime_types.add_type_variant(xtxp)
    end
    assert_includes(@mime_types['text/plain'], xtxp)
  end

  def test_data_version
    assert_equal(MIME::Type::VERSION, @mime_types.data_version)
  end

  # This tests the instance implementation through the class implementation.
  def test_index_extensions
    xtxp = MIME::Type.new(['x-text/x-plain', %w(tzt)])
    assert_deprecated("MIME::Types#index_extensions", "and will be private") do
      @mime_types.index_extensions(xtxp)
    end
    assert_includes(@mime_types.of('tzt'), xtxp)
  end

  def test_defined_types
    assert_deprecated("MIME::Types#defined_types") do
      assert_empty(MIME::Types.new.defined_types)
    end
    refute_empty(@mime_types.defined_types)
  end
end

class TestMIMETypesQueryClassMethods < Minitest::Test
  def setup
    MIME::Types.send(:load_default_mime_types)
  end

  def test_enumerable
    assert(MIME::Types.any? {|type| type.content_type == 'text/plain'})
  end

  def test_load_from_file
    fn = File.expand_path('../fixture/old-data', __FILE__)
    assert_deprecated("MIME::Types.load_from_file") do
      MIME::Types.load_from_file(fn)
    end
  end

  def test_index_with_mime_type
    xtxp = MIME::Type.new('x-text/x-plain')
    assert_includes(MIME::Types[xtxp], 'text/plain')
    assert_equal(1, MIME::Types[xtxp].size)
  end

  def test_index_with_regex
    assert_includes(MIME::Types[/plain/], 'text/plain')
    assert_equal(1, MIME::Types[/plain/].size)
  end

  def test_index_with_string
    assert_includes(MIME::Types['text/plain'], 'text/plain')
    assert_equal(1, MIME::Types['text/plain'].size)
  end

  def test_index_with_complete_flag
    assert_empty(MIME::Types['application/1d-interleaved-parityfec', complete: true])
    refute_empty(MIME::Types['text/plain', complete: true])
  end

  def test_index_with_registered_flag
    assert_empty(MIME::Types['application/x-wordperfect6.1',
                             registered: true])
    refute_empty(MIME::Types['application/x-www-form-urlencoded',
                             registered: true])
    refute_empty(MIME::Types['application/gzip', registered: true])
    refute_equal(MIME::Types['application/gzip'].size,
                 MIME::Types['application/gzip', registered: true])
  end

  def test_index_with_platform_flag
    assert_deprecated("MIME::Types#[]", "using the :platform flag") do
      assert_empty(MIME::Types['text/plain', platform: true])
    end
  end

  def test_type_for
    assert_equal(%w(application/xml text/xml), MIME::Types.type_for('xml'))
    assert_equal(%w(image/gif), MIME::Types.of('foo.gif'))
    assert_equal(%w(application/xml image/gif text/xml),
                 MIME::Types.type_for(%w(xml gif)))
    assert_deprecated("MIME::Types#type_for", "using the platform parameter") do
      assert_empty(MIME::Types.type_for('gif', true))
    end
    assert_empty(MIME::Types.type_for('zzz'))
  end

  def test_count
    assert(MIME::Types.count.nonzero?,
           "A lot of types are expected to be known.")
  end

  def test_cache_file
    ENV['RUBY_MIME_TYPES_CACHE'] = 'foo'
    assert_deprecated("MIME::Types.cache_file") do
      assert_equal('foo', MIME::Types.cache_file)
    end
    ENV.delete('RUBY_MIME_TYPES_CACHE')
    assert_nil(MIME::Types.cache_file)
  end
end

class TestMIMETypesClassMethods < Minitest::Test
  def setup
    MIME::Types.instance_variable_set(:@__types__, nil)
    MIME::Types.send(:load_default_mime_types)
  end

  def test_add_with_type
    MIME::Types.add(MIME::Type.new("application/x-eruby"))
    refute_empty(MIME::Types['application/x-eruby'])
  end

  def test_add_with_types
    mt = MIME::Types.new
    mt.add MIME::Type.new("application/x-eruby")
    MIME::Types.add(mt)
    refute_empty(MIME::Types['application/x-eruby'])
  end

  def test_add_with_array
    MIME::Types.add([MIME::Type.new("application/x-eruby")])
    refute_empty(MIME::Types['application/x-eruby'])
  end

  def test_add_with_noise_suppression
    assert_silent do
      MIME::Types.add(MIME::Type.new("application/x-eruby"))
    end
    assert_output(nil, %r{application/x-eruby is already registered}) do
      MIME::Types.add(MIME::Type.new("application/x-eruby"))
    end
    assert_silent do
      MIME::Types.add(MIME::Type.new("application/x-eruby"), :silent)
    end
  end

  def test_add_type_variant
    xtxp = MIME::Type.new('x-text/x-plain')
    assert_deprecated("MIME::Types#add_type_variant", "and will be private") do
      MIME::Types.add_type_variant(xtxp)
    end
    assert_includes(MIME::Types['text/plain'], xtxp)
  end

  def test_index_extensions
    xtxp = MIME::Type.new(['x-text/x-plain', %w(tzt)])
    assert_deprecated("MIME::Types#index_extensions", "and will be private") do
      MIME::Types.index_extensions(xtxp)
    end
    assert_includes(MIME::Types.of('tzt'), xtxp)
  end
end
*/
