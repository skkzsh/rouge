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

        # in-buffer settings (metadata keywords)
        rule %r/^[ \t]*#\+\w+:/, Name::Tag

        # comments
        rule %r/^[ \t]*#[ \t][^\n]*/, Comment

        # comment blocks
        rule %r/^[ \t]*#\+BEGIN_COMMENT\b/i, Comment, :comment_block

        # example blocks
        rule %r/^[ \t]*#\+BEGIN_EXAMPLE\b/i, Literal::String, :example_block

        # inline examples
        rule %r/^[ \t]*:[ \t][^\n]*/, Literal::String

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

        # checkboxes (unordered, ordered)
        rule %r/^[ \t]*[-+][ \t]\[[ X-]\]/, Punctuation
        rule %r/^[ \t]*\d+[.)][ \t]\[[ X-]\]/, Punctuation

        # lists (unordered, ordered)
        rule %r/^[ \t]*[-+](?=[ \t])/, Punctuation
        rule %r/^[ \t]*\d+[.)](?=[ \t])/, Punctuation

        # everything else
        rule %r/[^\n]+/, Text
        rule %r/\n/, Text
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
    end
  end
end
