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
