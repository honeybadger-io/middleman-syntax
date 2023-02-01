require 'middleman-syntax/formatters'

module Middleman
  module Syntax
    module Highlighter
      mattr_accessor :options

      # A helper module for highlighting code
      def self.highlight(code, language=nil, opts={})
        raw_lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText

        if options[:escape]
          # #reset! is normally called once by #lex, but since #lex is never
          # called on the raw lexer, we need to call it manually. (The escape
          # lexer only calls #continue_lex)
          # See https://github.com/rouge-ruby/rouge/blob/a4ed658d2778a3e2d3e68873f7221b91149a2ed4/lib/rouge/lexer.rb#LL468C7-L468C13
          # and https://github.com/rouge-ruby/rouge/blob/a4ed658d2778a3e2d3e68873f7221b91149a2ed4/lib/rouge/lexers/escape.rb#L44
          #
          # Otherwise you'll get weird errors w/ some lexers:
          #
          #   NoMethodError: undefined method `continue_lex' for nil:NilClass
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:424:in `delegate'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/lexers/jsx.rb:44:in `block (2 levels) in <class:JSX>'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:364:in `instance_exec'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:364:in `block in step'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:346:in `each'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:346:in `step'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/regex_lexer.rb:327:in `stream_tokens'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/lexer.rb:480:in `continue_lex'
          #     ~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/rouge-3.30.0/lib/rouge/lexers/escape.rb:44:in `block in stream_tokens'
          raw_lexer.reset!

          escape_options = options[:escape].is_a?(Hash) ? options[:escape] : {}

          # See https://github.com/rouge-ruby/rouge/pull/1152
          Rouge::Formatter.enable_escape!
          lexer = Rouge::Lexers::Escape.new(
            start: escape_options.fetch(:start, "<!"),
            end: escape_options.fetch(:end, "!>"),
            lang: raw_lexer
          )
        else
          lexer = raw_lexer
        end

        highlighter_options = options.to_h.merge(opts)
        highlighter_options[:css_class] = [highlighter_options[:css_class], raw_lexer.tag].join(" ")
        lexer_options = highlighter_options.delete(:lexer_options)

        formatter = Middleman::Syntax::Formatters::HTML.new(highlighter_options)
        formatter.format(lexer.lex(code, lexer_options))
      end
    end
  end
end
