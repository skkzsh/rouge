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
        rule %r/[^\n]+/, Text
        rule %r/\n/, Text
      end
    end
  end
end
