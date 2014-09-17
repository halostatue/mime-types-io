// Bug in true/false JSON support. Let's patch it.
if(true hasSlot("asJson") not, true asJson := method(asString))
if(false hasSlot("asJson") not, false asJson := method(asString))
if(nil hasSlot("asJson") not, nil asJson := method("null"))

// The definition of one MIME content-type.

MimeType := Object clone do(
  VERSION := method("1.0")

  simplifiedFor := method(value,
    if(MEDIA_TYPE_RE matchesIn(value asString) count isNil,
      InvalidContentType(value)
    )

    value split("/") map(part,
      part := part lowercase
      if(part findSeq("x-") == 0, part := part replaceFirstSeq("x-", "") lowercase)
      part
    ) join("/")
  )

  # Builds a MimeType object from the provided MIME Content Type value—
  # 'text/plain' or 'applicaton/x-eruby'. The constructed object is yielded to
  # an optional block for additional configuration, such as associating
  # extensions and encoding information.
  #
  # * When provided a Map or a MimeType, the MimeType will be constructed with
  #   #init_with.
  # * When provided an Array, the MimeType will be constructed only using the
  #   first two elements of the array as the content type and extensions.
  # * Otherwise, the content_type will be used as a string.
  with := method(value,
    if(value isKindOf(MimeType), value := MimeType asMap)
    result := if(value isKindOf(Map),
      self clone initWithMap(value)
      ,
      if(value isKindOf(List),
        self clone initWithList(value)
        ,
        self clone initWithList(list(value))
      )
    )
    result
  )
  
  isLike := method(other,
    if(other hasSlot(simplified),
      return(simplified == other simplified)
      ,
      return(simplified == MimeType simplifiedFor(other))
    )
  )

  isObsolete := method(self obsolete not not)
  isRegistered := method(
    if(self registered isNil,
      partRegistered(self rawMediaType) and partRegistered(self rawSubType)
      ,
      self registered not not
    )
  )

  isBinary := method(BINARY_ENCODINGS contains(self encoding))
  isAscii := method(isBinary not)
  isSignature := method(self signature not not)
  isComplete := method(self extensions isNotEmpty)

  urls := method(
    xrefs map(xrefType, values,
      if(xrefType == "rfc",
        values map(data, "http://www.iana.org/go/" .. data)
        ,
        if(xrefType == "draft",
          values map(data,
            if(data findSeq("RFC") == 0, data replaceFirstSeq("RFC", "draft"))
            "http://www.iana.org/go/" .. data
          )
          ,
          if(xrefType == "rfc-errata",
            values map(data,
              "http://www.rfc-editor.org/errata_search.php?eid=" .. data
            )
            ,
            if(xrefType == "person",
              values map(data,
                "http://www.iana.org/assignments/media-types/media-types.xhtml#" ..
                data
              )
              ,
              if(xrefType == "template",
                values map(data,
                  "http://www.iana.org/assignments/media-types/" .. data
                )
                ,
                if(xrefType == "uri" or xrefType == "text", values, nil)
              )
            )
          )
        )
      )
    ) remove(nil) flatten
  )

  asString := method(self contentType)
  asJson := method(asMap asJson)
  asMap := method(
    m := Map clone
    m atPut("content-type", self contentType)
    if(self docs isNotEmpty, m atPut("docs", self docs))
    m atPut("encoding", self encoding)
    if(self extensions isNotEmpty, m atPut("extensions", self extensions))
    if(self isObsolete,
      m atPut("obsolete", self isObsolete)
      if(self useInstead isNotEmpty, m atPut("use-instead", self useInstead))
    )
    if(self xrefs isNotEmpty, m atPut("xrefs", self xrefs))
    m atPut("registered", self isRegistered)
    if(self isSignature, m atPut("signature", self isSignature))
    m
  )

  partRegistered := method(value, value findSeq("x-") != 0)

  compare := method(other,
    if(other hasSlot(contentType),
      return contentType lowercase compare(other contentType lowercase)
      ,
      return simplified compare(MimeType simplifiedFor(other asString))
    )
  )

  priorityCompare := method(other,
    pc := simplified compare(other simplified)
    if(pc != 0, return pc)
    if(isRegistered != other isRegistered, return if(isRegistered, -1, 1))
    if(isComplete != other isComplete, return(isComplete, -1, 1))
    if(isObsolete != other isObsolete, return(isObsolete, 1, -1))
    if(isObsolete and useInstead != otherUseInstead,
      if(useInstead isNil, return 1)
      if(other useInstead isNil, return -1)
      return useInstead compare(other useInstead)
      ,
      return 0
    )
  )

  InvalidContentType := method(invalidType,
    Exception raise("Invalid Content-Type #{invalidType}" interpolate)
  )

  InvalidEncoding := method(encoding,
    Exception raise("Invalid Encoding #{encoding}" interpolate)
  )

  MEDIA_TYPE_RE := Regex with("([-\\w.+]+)/([-\\w.+]*)")
  UNREGISTERED_RE := Regex with("[Xx]-")
  DEFAULT_ENCODINGS := list(nil, "default")
  BINARY_ENCODINGS := list("base64", "8bit")
  TEXT_ENCODINGS := list("7bit", "quoted-printable")
  VALID_ENCODINGS := list(DEFAULT_ENCODINGS, BINARY_ENCODINGS, TEXT_ENCODINGS) flatten

  contentType := nil
  rawMediaType := nil
  rawSubType := nil
  simplified := nil
  mediaType := nil
  subType := nil

  obsolete := false
  registered := nil
  signature := nil
  encoding := DEFAULT_ENCODINGS last
  useInstead := List clone
  extensions := List clone
  docs := List clone
  xrefs := Map clone

  setContentType := method(value,
    matches := MEDIA_TYPE_RE matchesIn(value)

    if(matches count isNil,
      InvalidContentType(value)
      ,
      matches := matches last
    )

    self contentType := value
    self rawMediaType := matches captures at(1)
    self rawSubType := matches captures at(2)
    self simplified := MimeType simplifiedFor(value)

    matches := MEDIA_TYPE_RE matchesIn(self simplified) last
    self mediaType := matches captures at(1)
    self subType := matches captures at(2)

    self contentType
  )

  setExtensions := method(values,
    self extensions := list(values) flatten remove(nil) sortInPlace unique
  )

  addExtensions := method(values,
    setExtensions(list(self extensions, values))
  )

  setEncoding := method(value,
    if(DEFAULT_ENCODINGS contains(value),
      self encoding := self defaultEncoding,
      if(BINARY_ENCODINGS contains(value) or TEXT_ENCODINGS contains(value),
        self encoding := value
        ,
        InvalidEncoding(value)
      )
    )
  )

  defaultEncoding := method(
    if(self mediaType == "text", TEXT_ENCODINGS last, BINARY_ENCODINGS first)
  )

  initWithMap := method(coder,
    setContentType(coder at("content-type"))
    if(coder hasKey("docs"), self docs := coder at("docs"))
    setEncoding(coder at("encoding"))
    setExtensions(coder at("extensions"))
    self obsolete := coder at("obsolete")
    self registered := coder at("registered")
    self signature := coder at("signature")
    if(coder hasKey("xrefs"), self xrefs := coder at("xrefs"))
    if(coder hasKey("use-instead"), self use_instead := coder at("use-instead"))
    self
  )

  initWithList := method(value,
    setContentType(value at(0))
    setExtensions(list(value slice(1)) flatten)
    self
  )
)

tp := MimeType with(list("text/plain", "txt", "md"))
