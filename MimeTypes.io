# MimeTypes is a registry of MIME types. It is both a class (created with
# MimeTypes.new) and a default registry (loaded automatically or through
# interactions with MimeTypes.[] and MimeTypes.type_for).
#
# == The Default mime-types Registry
#
# The default mime-types registry is loaded automatically when the library
# is required (<tt>require 'mime/types'</tt>), but it may be lazily loaded
# (loaded on first use) with the use of the environment variable
# +RUBY_MIME_TYPES_LAZY_LOAD+ having any value other than +false+. The
# initial startup is about 14× faster (~10 ms vs ~140 ms), but the
# registry will be loaded at some point in the future.
#
# The default mime-types registry can also be loaded from a Marshal cache
# file specific to the version of MimeTypes being loaded. This will be
# handled automatically with the use of a file referred to in the
# environment variable +RUBY_MIME_TYPES_CACHE+. MimeTypes will attempt to
# load the registry from this cache file (MIME::Type::Cache.load); if it
# cannot be loaded (because the file does not exist, there is an error, or
# the data is for a different version of mime-types), the default registry
# will be loaded from the normal JSON version and then the cache file will
# be *written* to the location indicated by +RUBY_MIME_TYPES_CACHE+. Cache
# file loads just over 4½× faster (~30 ms vs ~140 ms).
# loads.
#
# Notes:
# * The loading of the default registry is *not* atomic; when using a
#   multi-threaded environment, it is recommended that lazy loading is not
#   used and mime-types is loaded as early as possible.
# * Cache files should be specified per application in a multiprocess
#   environment and should be initialized during deployment or before
#   forking to minimize the chance that the multiple processes will be
#   trying to write to the same cache file at the same time, or that two
#   applications that are on different versions of mime-types would be
#   thrashing the cache.
# * Unless cache files are preinitialized, the application using the
#   mime-types cache file must have read/write permission to the cache file.
#
# == Usage
#  require 'mime/types'
#
#  plaintext = MimeTypes['text/plain']
#  print plaintext.media_type           # => 'text'
#  print plaintext.sub_type             # => 'plain'
#
#  puts plaintext.extensions.join(" ")  # => 'asc txt c cc h hh cpp'
#
#  puts plaintext.encoding              # => 8bit
#  puts plaintext.binary?               # => false
#  puts plaintext.ascii?                # => true
#  puts plaintext.obsolete?             # => false
#  puts plaintext.registered?           # => true
#  puts plaintext == 'text/plain'       # => true
#  puts MIME::Type.simplified('x-appl/x-zip') # => 'appl/zip'
MimeTypesCollection := Object clone do(
  VERSION := method(MimeType VERSION)

  typeVariants := Map clone
  extensionIndex := Map clone

  count := method(typeVariants values reduce(m, o, m + o size, 0))
  foreach := method(// [optional index,] value, message
    iname := nil
    name := call argAt(0) name
    offset := 1

    if(call argCount == 3,
      iname := call argAt(0) name
      name := call argAt(1) name
      offset := 2
    )

    index := -1
    result := nil

    typeVariants foreach(variants,
      variants foreach(variant,
        index := index + 1
        if(iname isNil not, call sender setSlot(iname, index))
        call sender setSlot(name, variant)
        call evalArgAt(offset)
      )
    )
    result
  )

  squareBrackets := method(
    id := call evalArgAt(0)
    flags := list(call message arguments slice(1)) flatten

    matches := if(id isKindOf(MimeType),
      typeVariants at(id simplified),
      if(id isKindOf(Regex),
        _match(id)
        ,
        typeVariants at(MimeType simplify(id))
      )
    )

    _pruneMatches(matches, flags) \
      sortInPlaceBy(block(a, b, a priority_compare(b)))
  )

  typeFor := method(filename,
    names := list(filename) flatten
    names map(name,
      name := File with(name asMutable lowercase) name split(".") last
      extensionIndex at(name)
    ) flatten remove(nil) \
      sortInPlaceBy(block(a, b, a priority_compare(b))) unique
  )
  of := method(filename, typeFor(filename))

  add := method(types,
    types := list(types) flatten
    quiet := types last == "silent" or types last == true
    types foreach(mimeType,
      if(mimeType == true or mimeType == false or mimeType isNil or mimeType isKindOf(Sequence)) \
      then(continue) \
      else(if(mimeType isKindOf(MimeTypes)) \
        then(add(list(mimeType typeVariants values, quiet) flatten)) \
        else(if(mimeType isKindOf(List)) \
          then(add(list(mimeType, quiet) flatten)) \
          else(addType(mimeType, quiet))
        )
      )
    )
  )

  addType := method(
    mimeType := call evalArgAt(0)

    if(call evalArgAt(1) not, // noisy
      if(typeVariants at(mimeType simplified, List clone) contains(mimeType),
        "Type " .. mimeType asString ..
          " is already registered as a variant of " ..
          mimeType simplified asString ..
          "." println
      )
    )

    _addTypeVariant(mimeType)
    _indexExtensions(mimeType)
  )

  _pruneMatches := method(matches, flags,
    if(flags contains("complete"), matches selectInPlace(isComplete))
    if(flags contains("registered"), matches selectInPlace(isRegistered))
    matches
  )

  _match := method(pattern,
    typeVariants select(k, v, pattern matchesIn(k) count) values flatten
  )

  _addTypeVariant := method(mimeType,
    if(typeVariants hasKey(mimeType simplified) not,
      typeVariants atPut(mimeType simplified, List clone)
    )
    typeVariants at(mimeType simplified) append(mimeType)
  )

  _indexExtensions := method(mimeType,
    mimeType extensions foreach(ext,
      if(extensionIndex hasKey(ext) not, extensionIndex atPut(ext, List clone))
      extensionIndex at(ext) append(mimeType)
    )
  )
)

MimeTypes := MimeTypesCollection clone
MimeTypes do(
  clone := MimeTypes

  method(path,
    path := if(path isNil, "data", path)
    dir := Directory with(path)
    dir recursiveFilesOfTypes(list("json")) sort foreach(file,
      items := Yajl parseJson(file asBuffer)
      items mapInPlace(item, MimeType with(item)
      )
      add(list(items, "silent"))
    )
  ) call(System getEnvironmentVariable("IO_MIME_TYPES_DATA"))
)
