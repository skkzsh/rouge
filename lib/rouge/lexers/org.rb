# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Org < RegexLexer
      title "Org"
      desc "Org mode (orgmode.org)"
      tag 'org'
      aliases 'org-mode', 'orgmode'
      filenames '*.org'
      mimetypes 'text/org'

      state :root do
        # horizontal rules
        rule %r/^[ \t]*-{5,}\s*$/, Punctuation

        # headings
        rule %r/^(\*+)([ \t])(COMMENT(?=[ \t]|$))?([^\n]*)/ do |m|
          heading_tok = m[1].length == 1 ? Generic::Heading : Generic::Subheading
          token heading_tok, m[1] + m[2]
          token Comment, m[3] if m[3]
          token heading_tok, m[4]
        end

        # dynamic blocks
        rule %r/^([ \t]*)(#\+BEGIN:)([ \t]*)(\w+)?([^\n]*\n)/i do |m|
          token Comment::Preproc, m[1] + m[2]
          token Text, m[3] if m[3] && !m[3].empty?
          token Name::Label, m[4] if m[4]
          token Text, m[5]
          push :dynamic_block
        end

        # in-buffer settings (metadata keywords)
        rule %r/^[ \t]*#\+\w+:/, Name::Tag

        # comments
        rule %r/^[ \t]*#[ \t][^\n]*/, Comment

        # comment blocks
        rule %r/^[ \t]*#\+BEGIN_COMMENT\b/i, Comment, :comment_block

        # example blocks
        rule %r/^[ \t]*#\+BEGIN_EXAMPLE\b/i, Literal::String, :example_block

        # source blocks
        rule %r/^([ \t]*)(#\+BEGIN_SRC)([ \t]*)(\w+)?([^\n]*\n)/i do |m|
          token Literal::String, m[1] + m[2]
          token Text, m[3] if m[3] && !m[3].empty?
          token Name::Label, m[4] if m[4]
          token Text, m[5]

          lang = (m[4] || "").strip
          sublexer =
            begin
              if lang.empty?
                PlainText.new(@options.merge(:token => Str::Backtick))
              else
                Lexer.find_fancy(lang, nil, @options) || PlainText.new(@options.merge(:token => Str::Backtick))
              end
            rescue Guesser::Ambiguous => e
              e.alternatives.first.new(@options)
            end
          sublexer.reset!

          push do
            rule %r/^[ \t]*#\+END_SRC\b/i, Literal::String, :pop!
            rule %r/[^\n]+/ do |mb|
              delegate sublexer, mb[0]
            end
            rule %r/\n/ do |mb|
              delegate sublexer, mb[0]
            end
          end
        end

        # export blocks
        rule %r/^([ \t]*)(#\+BEGIN_EXPORT)([ \t]*)(\w+)?([^\n]*\n)/i do |m|
          token Comment::Preproc, m[1] + m[2]
          token Text, m[3] if m[3] && !m[3].empty?
          token Name::Label, m[4] if m[4]
          token Text, m[5]
          push :export_block
        end

        # paragraph blocks (quote, center, verse, etc.)
        rule %r/^[ \t]*#\+BEGIN_(\w+)\b/i do |m|
          token Punctuation, m[0]
          block_type = m[1]
          push do
            rule %r/^[ \t]*#\+END_#{block_type}\b/i, Punctuation, :pop!
            mixin :inline
          end
        end

        # inline examples
        rule %r/^[ \t]*:[ \t][^\n]*/, Literal::String

        # checkboxes (unordered, ordered)
        rule %r/^[ \t]*[-+][ \t]\[[ X-]\]/, Punctuation
        rule %r/^[ \t]*\d+[.)][ \t]\[[ X-]\]/, Punctuation

        # lists (unordered, ordered)
        rule %r/^[ \t]*[-+](?=[ \t])/, Punctuation
        rule %r/^[ \t]*\d+[.)](?=[ \t])/, Punctuation

        # inline formatting (links, emphasis, text)
        mixin :inline
      end

      state :inline do
        # table (separators, rows)
        rule %r/^[ \t]*\|[-|\+]*[ \t]*$/, Punctuation
        rule %r/^[ \t]*\|[^\n]*/, Punctuation

        # links ([[link][description]], [[link]], <link>)
        rule %r/(\[\[)([^\]\[\n]+)(\]\[)([^\]\[\n]+)(\]\])/ do
          groups Punctuation, Name::Attribute, Punctuation, Name::Tag, Punctuation
        end
        rule %r/(\[\[)([^\]\[\n]+)(\]\])/ do
          groups Punctuation, Name::Attribute, Punctuation
        end
        rule %r/(<)(\w+:[^\s<>\n]+)(>)/ do
          groups Punctuation, Name::Attribute, Punctuation
        end

        # bare links
        rule %r/\bhttps?:\/\/[^\s<>()\[\]]*[^\s<>()\[\].,;:!?'"]/, Name::Attribute

        # emphasis (bold, italic, underline, strike-through, verbatim, code, superscript, subscript)
        rule %r/(?<![\w*])\*([^\s*]|[^\s*](?:\\.|[^*\n])*?[^\s*])\*(?![\w*])/, Generic::Strong
        rule %r/(?<![\w\/])\/([^\s\/]|[^\s\/](?:\\.|[^\/\n])*?[^\s\/])\/(?![\w\/])/, Generic::Emph
        rule %r/(?<![\w_])_([^\s_{]|[^\s_](?:\\.|[^_\n])*?[^\s_])_(?![\w_])/, Generic::Emph
        rule %r/(?<![\w+])\+([^\s+]|[^\s+](?:\\.|[^+\n])*?[^\s+])\+(?![\w+])/, Generic::Deleted
        rule %r/(?<![\w=])=([^\s=]|[^\s=](?:\\.|[^=\n])*?[^\s=])=(?![\w=])/, Literal::String
        rule %r/(?<![\w~])~([^\s~]|[^\s~](?:\\.|[^~\n])*?[^\s~])~(?![\w~])/, Literal::String::Backtick
        rule %r/\^\{[^}\n]*\}/, Literal::String::Interpol
        rule %r/_\{[^}\n]*\}/, Literal::String::Interpol

        # escape sequences outside emphasis context
        rule %r/\\./, Str::Escape

        # everything else
        rule %r/(?:(?!https?:\/\/)[^*\/+=~^_{\n\\])+/, Text
        rule %r/\n/, Text
        rule %r/./, Text
      end

      state :comment_block do
        rule %r/^[ \t]*#\+END_COMMENT\b/i, Comment, :pop!
        rule %r/[^\n]+/, Comment
        rule %r/\n/, Comment
      end

      state :example_block do
        rule %r/^[ \t]*#\+END_EXAMPLE\b/i, Literal::String, :pop!
        rule %r/[^\n]+/, Literal::String
        rule %r/\n/, Literal::String
      end

      state :export_block do
        rule %r/^[ \t]*#\+END_EXPORT\b/i, Comment::Preproc, :pop!
        rule %r/[^\n]+/, Literal::String
        rule %r/\n/, Literal::String
      end

      state :dynamic_block do
        rule %r/^[ \t]*#\+END:/i, Comment::Preproc, :pop!
        mixin :inline
      end
    end
  end
end
