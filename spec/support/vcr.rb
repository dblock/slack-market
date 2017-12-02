require 'vcr'

require 'vcr'
require 'zlib'
require 'stringio'
require 'psych'

# A custom VCR serializer for prettier YAML output
module StyledYAML
  # Tag strings to be output using literal style
  def self.literal(obj)
    obj.extend LiteralScalar
    obj
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2795688
  module LiteralScalar
    def yaml_style
      Psych::Nodes::Scalar::LITERAL
    end
  end

  # Tag Hashes or Arrays to be output all on one line
  def self.inline(obj)
    case obj
    when Hash  then obj.extend FlowMapping
    when Array then obj.extend FlowSequence
    else
      warn "#{self}: unrecognized type to inline (#{obj.class.name})"
    end
    obj
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2790832
  module FlowMapping
    def yaml_style
      Psych::Nodes::Mapping::FLOW
    end
  end

  # http://www.yaml.org/spec/1.2/spec.html#id2790320
  module FlowSequence
    def yaml_style
      Psych::Nodes::Sequence::FLOW
    end
  end

  # Custom tree builder class to recognize scalars tagged with `yaml_style`
  class TreeBuilder < Psych::TreeBuilder
    attr_writer :next_sequence_or_mapping_style

    def initialize(*args)
      super
      @next_sequence_or_mapping_style = nil
    end

    def next_sequence_or_mapping_style(default_style)
      style = @next_sequence_or_mapping_style || default_style
      @next_sequence_or_mapping_style = nil
      style
    end

    def scalar(value, anchor, tag, plain, quoted, style)
      if style_any?(style) && value.respond_to?(:yaml_style) && (style = value.yaml_style)
        if style_literal? style
          plain = false
          quoted = true
        end
      end
      super
    end

    def style_any?(style)
      Psych::Nodes::Scalar::ANY == style
    end

    def style_literal?(style)
      Psych::Nodes::Scalar::LITERAL == style
    end

    %w[sequence mapping].each do |type|
      class_eval <<-RUBY
        def start_#{type}(anchor, tag, implicit, style)
          style = next_sequence_or_mapping_style(style)
          super
        end
      RUBY
    end
  end

  # Custom tree class to handle Hashes and Arrays tagged with `yaml_style`
  class YAMLTree < Psych::Visitors::YAMLTree
    %w[Hash Array Psych_Set Psych_Omap].each do |klass|
      class_eval <<-RUBY
        def visit_#{klass} o
          if o.respond_to? :yaml_style
            @emitter.next_sequence_or_mapping_style = o.yaml_style
          end
          super
        end
      RUBY
    end
  end

  # A Psych.dump alternative that uses the custom TreeBuilder
  def self.dump(obj, io = nil, options = {})
    real_io = io || StringIO.new(''.encode('utf-8'))
    visitor = YAMLTree.new(options, TreeBuilder.new)
    visitor << obj
    ast = visitor.tree

    begin
      ast.yaml real_io
    rescue
      # The `yaml` method was introduced in later versions, so fall back to
      # constructing a visitor
      Psych::Visitors::Emitter.new(real_io).accept ast
    end

    io ? io : real_io.string
  end

  def self.file_extension
    'yml'
  end

  def self.deserialize(string)
    Psych.load string
  end

  def self.serialize(obj)
    if obj.respond_to?(:has_key?) && obj.key?('http_interactions')
      obj['http_interactions'].each do |i|
        literal i['response']['body']['string']
        inline i['response']['status']
      end
    end
    dump obj
  end
end

VCR.configure do |vcr|
  vcr.cassette_library_dir = 'spec/fixtures/slack'
  vcr.hook_into :webmock
  vcr.default_cassette_options = { record: :new_episodes }
  vcr.configure_rspec_metadata!
  vcr.ignore_localhost = true
  vcr.cassette_serializers[:styled_yaml] = StyledYAML
  vcr.default_cassette_options = { serialize_with: :styled_yaml }

  bin2ascii = lambda { |value|
    if value && value.encoding.name == 'ASCII-8BIT'
      value.force_encoding('us-ascii')
    end
    value
  }

  normalize_headers = lambda { |headers|
    headers.keys.each do |key|
      value = headers[key]

      if key.encoding.name == 'ASCII-8BIT'
        old_key = key
        key = bin2ascii.call(key.dup)
        headers.delete(old_key)
        headers[key] = value
      end

      Array(value).each { |v| bin2ascii.call(v) }
      headers[key] = value[0] if Array === value && value.size < 2
    end
  }

  vcr.before_record do |i|
    if (enc = i.response.headers['Content-Encoding']) && Array(enc).first == 'gzip'
      i.response.body = Zlib::GzipReader.new(StringIO.new(i.response.body), encoding: 'ASCII-8BIT').read
      i.response.update_content_length_header
      i.response.headers.delete 'Content-Encoding'
    end

    type, charset = Array(i.response.headers['Content-Type']).join(',').split(';')

    i.response.body.force_encoding(Regexp.last_match(1)) if charset =~ /charset=(\S+)/

    bin2ascii.call(i.response.status.message)

    if type =~ /[\/+]json$/ || type == 'text/javascript'
      begin
        data = JSON.parse i.response.body
      rescue
        # warn "VCR: JSON parse error for Content-type #{type}"
      else
        i.response.body = JSON.pretty_generate data
        i.response.update_content_length_header
      end
    end

    normalize_headers.call(i.request.headers)
    normalize_headers.call(i.response.headers)
  end
end
