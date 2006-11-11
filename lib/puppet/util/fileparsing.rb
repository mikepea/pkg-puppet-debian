# A mini-language for parsing files.  This is only used file the ParsedFile
# provider, but it makes more sense to split it out so it's easy to maintain
# in one place.
#
# You can use this module to create simple parser/generator classes.  For instance,
# the following parser should go most of the way to parsing /etc/passwd:
#
#   class Parser
#       include Puppet::Util::FileParsing
#       record_line :user, :fields => %w{name password uid gid gecos home shell},
#           :separator => ":"
#   end
#
# You would use it like this:
#
#   parser = Parser.new
#   lines = parser.parse(File.read("/etc/passwd"))
#
#   lines.each do |type, hash| # type will always be :user, since we only have one
#       p hash
#   end
#
# Each line in this case would be a hash, with each field set appropriately.
# You could then call 'parser.to_line(hash)' on any of those hashes to generate
# the text line again.

module Puppet::Util::FileParsing
    include Puppet::Util
    attr_writer :line_separator, :trailing_separator

    # Clear all existing record definitions.  Only used for testing.
    def clear_records
        @record_types.clear
        @record_order.clear
    end

    # Try to match a specific text line.
    def handle_text_line(line, hash)
        if line =~ hash[:match]
            return {:record_type => hash[:name], :line => line}
        else
            return nil
        end
    end

    # Try to match a record.
    def handle_record_line(line, hash)
        if hash[:match]
        else
            ret = {}
            hash[:fields].zip(line.split(hash[:separator])) do |param, value|
                ret[param] = value
            end
            ret[:record_type] = hash[:name]
            return ret
        end
    end

    def line_separator
        unless defined?(@line_separator)
            @line_separator = "\n"
        end

        @line_separator
    end

    # Split text into separate lines using the record separator.
    def lines(text)
        # Remove any trailing separators, and then split based on them
        text.sub(/#{self.line_separator}\Q/,'').split(self.line_separator)
    end

    # Split a bunch of text into lines and then parse them individually.
    def parse(text)
        lines(text).collect do |line|
            parse_line(line)
        end
    end

    # Handle parsing a single line.
    def parse_line(line)
        unless records?
            raise Puppet::DevError, "No record types defined; cannot parse lines"
        end

        @record_order.each do |name|
            hash = @record_types[name]
            unless hash
                raise Puppet::DevError, "Did not get hash for %s: %s" %
                    [name, @record_types.inspect]
            end
            method = "handle_%s_line" % hash[:type]
            if respond_to?(method)
                if result = send(method, line, hash)
                    return result
                end
            else
                raise Puppet::DevError, "Somehow got invalid line type %s" % hash[:type]
            end
        end

        return nil
    end

    # Define a new type of record.  These lines get split into hashes.
    def record_line(name, options)
        unless options.include?(:fields)
            raise ArgumentError, "Must include a list of fields"
        end

        invalidfields = [:record_type, :target, :on_disk]
        options[:fields] = options[:fields].collect do |field|
            r = symbolize(field)
            if invalidfields.include?(r)
                raise ArgumentError.new("Cannot have fields named %s" % r)
            end
            r
        end

        options[:separator] ||= /\s+/

        # Unless they specified a string-based joiner, just use a single
        # space as the join value.
        unless options[:separator].is_a?(String) or options[:joiner]
            options[:joiner] = " "
        end

        new_line_type(name, :record, options)
    end

    # Are there any record types defined?
    def records?
        defined?(@record_types) and ! @record_types.empty?
    end

    # Define a new type of text record.
    def text_line(name, options)
        unless options.include?(:match)
            raise ArgumentError, "You must provide a :match regex for text lines"
        end

        new_line_type(name, :text, options)
    end

    # Generate a file from a bunch of hash records.
    def to_file(records)
        text = records.collect { |record| to_line(record) }.join(line_separator)

        if trailing_separator
            text += line_separator
        end

        return text
    end

    # Convert our parsed record into a text record.
    def to_line(details)
        unless type = @record_types[details[:record_type]]
            raise ArgumentError, "Invalid record type %s" % details[:record_type]
        end

        case type[:type]
        when :text: return details[:line]
        else
            joinchar = type[:joiner] || type[:separator]

            return type[:fields].collect { |field| details[field].to_s }.join(joinchar)
        end
    end

    # Whether to add a trailing separator to the file.  Defaults to true
    def trailing_separator
        if defined? @trailing_separator
            return @trailing_separator
        else
            return true
        end
    end

    private
    # Define a new type of record.
    def new_line_type(name, type, options)
        @record_types ||= {}
        @record_order ||= []

        name = symbolize(name)

        if @record_types.include?(name)
            raise ArgumentError, "Line type %s is already defined" % name
        end

        options[:name] = name
        options[:type] = type
        @record_types[name] = options
        @record_order << name

        return options
    end
end

# $Id$