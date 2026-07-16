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
        rule %r/^(\*+)[ \t][^\n]*/ do |m|
          if m[1].length == 1
            token Generic::Heading, m[0]
          else
            token Generic::Subheading, m[0]
          end
        end

        # in-buffer settings (metadata keywords)
        rule %r/^[ \t]*#\+\w+:/, Name::Tag

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
    end
  end
end
