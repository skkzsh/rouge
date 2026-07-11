# -*- coding: utf-8 -*- #
# frozen_string_literal: true

describe Rouge::Lexers::Org do
  let(:subject) { Rouge::Lexers::Org.new }

  describe 'guessing' do
    include Support::Guessing

    it 'guesses by filename' do
      assert_guess :filename => 'foo.org'
    end

    it 'guesses by mimetype' do
      assert_guess :mimetype => 'text/org'
    end
  end

  describe 'lexing' do
    include Support::Lexing

    describe 'punctuation' do
      it 'recognizes Punctuation tokens' do
        [
          "-----\n",
          "- item\n",
          "+ item\n",
          "  - nested\n",
          "1. item\n",
          "1) item\n",
          "  1. nested\n",
          "- [ ] unchecked\n",
          "- [X] checked\n",
          "- [-] partial\n",
          "+ [ ] unchecked plus\n",
          "1. [ ] unchecked ordered\n",
          "1. [X] checked ordered\n",
          "|-------+-------|\n",
          "| Item  | Price |\n",
        ].each do |text|
          assert_has_token("Punctuation", text)
        end
      end

      it 'does not treat edge cases as Punctuation' do
        [
          "----\n",
          "-item\n",
          "+item\n",
          "1 item\n",
          "1.item\n",
          "1)item\n",
          "foo | bar\n",
        ].each do |text|
          deny_has_token("Punctuation", text)
        end
      end
    end

    describe 'headings' do
      it 'recognizes Generic::Heading tokens' do
        assert_has_token("Generic.Heading", "* Heading 1\n")
      end

      it 'recognizes Generic::Subheading tokens' do
        [
          "** Heading 2\n",
          "*** Heading 3\n",
          "**** Heading 4\n",
          "***** Heading 5\n",
          "****** Heading 6\n",
        ].each do |text|
          assert_has_token("Generic.Subheading", text)
        end
      end

      it 'does not treat edge cases as headings' do
        [
          " * Not heading\n",
          "*NoSpace\n",
        ].each do |text|
          deny_has_token("Generic.Heading", text)
          deny_has_token("Generic.Subheading", text)
        end
      end

      describe 'COMMENT keyword' do
        it 'recognizes Comment tokens' do
          [
            "* COMMENT Not exported\n",
            "** COMMENT Sub not exported\n",
          ].each do |text|
            assert_has_token("Comment", text)
          end
        end

        it 'recognizes Generic::Subheading alongside Comment' do
          assert_has_token("Generic.Subheading", "** COMMENT Sub not exported\n")
        end

        it 'does not treat edge cases as the COMMENT keyword' do
          [
            "* COMMENTother\n",
            "* comment lower\n",
            "* Heading COMMENT inline\n",
          ].each do |text|
            deny_has_token("Comment", text)
          end
        end
      end
    end

    describe 'metadata' do
      it 'recognizes Name::Tag tokens' do
        [
          "#+TITLE: Sample\n",
          "#+AUTHOR: Tester\n",
          "#+LANGUAGE: ja\n",
          "#+OPTIONS: toc:nil\n",
          "#+RESULTS:\n",
          "#+TBLFM: formula\n",
          "  #+TITLE: Indented\n",
        ].each do |text|
          assert_has_token("Name.Tag", text)
        end
      end

      it 'does not treat edge cases as Name::Tag' do
        [
          "#+ TITLE: Sample\n",
          "#+TITLE : Sample\n",
        ].each do |text|
          deny_has_token("Name.Tag", text)
        end
      end
    end

    describe 'links' do
      it 'recognizes the link and description of a bracket link with description' do
        text = "[[https://example.com][Example link]]\n"
        assert_has_token("Punctuation", text)
        assert_has_token("Name.Attribute", text)
        assert_has_token("Name.Tag", text)
      end

      it 'recognizes the brackets and link of a bracket link as Punctuation and Name::Attribute' do
        text = "[[./img/cat.png]]\n"
        assert_has_token("Punctuation", text)
        assert_has_token("Name.Attribute", text)
      end

      it 'recognizes the brackets and link of an angle-bracket link as Punctuation and Name::Attribute' do
        text = "<https://example.com>\n"
        assert_has_token("Punctuation", text)
        assert_has_token("Name.Attribute", text)
      end

      it 'does not treat edge cases as links' do
        [
          "[[incomplete\n",
          "<not a link>\n",
        ].each do |text|
          deny_has_token("Name.Attribute", text)
        end
      end

      it 'recognizes bare links as Name::Attribute' do
        [
          "https://example.com\n",
          "http://localhost\n",
        ].each do |text|
          assert_has_token("Name.Attribute", text)
        end
      end

      it 'excludes trailing punctuation from bare links' do
        assert_tokens_equal "See https://example.com.\n",
          ["Text", "See "],
          ["Name.Attribute", "https://example.com"],
          ["Text", ".\n"]
      end
    end

    describe 'emphasis' do
      it 'recognizes Generic::Strong tokens in emphasis' do
        [
          "*bold*\n",
          "*bold text*\n",
          "inline *bold* text\n",
        ].each do |text|
          assert_has_token("Generic.Strong", text)
        end
      end

      it 'recognizes Generic::Emph tokens in emphasis' do
        [
          "/italic/\n",
          "/italic text/\n",
          "_underline_\n",
          "_underlined text_\n",
        ].each do |text|
          assert_has_token("Generic.Emph", text)
        end
      end

      it 'recognizes Generic::Deleted tokens in emphasis' do
        [
          "+strike+\n",
          "+strike text+\n",
        ].each do |text|
          assert_has_token("Generic.Deleted", text)
        end
      end

      it 'recognizes Literal::String tokens in verbatim emphasis' do
        [
          "=verbatim=\n",
          "=verbatim text=\n",
        ].each do |text|
          assert_has_token("Literal.String", text)
        end
      end

      it 'recognizes Literal::String::Backtick tokens in code emphasis' do
        [
          "~code~\n",
          "~inline code~\n",
        ].each do |text|
          assert_has_token("Literal.String.Backtick", text)
        end
      end

      it 'recognizes Literal::String::Interpol tokens in sub/superscript' do
        [
          "a ^{sup} text\n",
          "a _{sub} text\n",
        ].each do |text|
          assert_has_token("Literal.String.Interpol", text)
        end
      end

      it 'does not treat edge cases as emphasis' do
        [
          "* bold *\n",
          "a*b*c\n",
          "1 + 2 + 3\n",
        ].each do |text|
          deny_has_token("Generic.Strong", text)
          deny_has_token("Generic.Emph", text)
          deny_has_token("Generic.Deleted", text)
        end
      end
    end

    describe 'comments' do
      it 'recognizes Comment tokens' do
        [
          "# This is a comment\n",
          "  # indented comment\n",
        ].each do |text|
          assert_has_token("Comment", text)
        end
      end

      it 'does not treat edge cases as Comment' do
        [
          "#NoSpace\n",
        ].each do |text|
          deny_has_token("Comment", text)
        end
      end

      it 'recognizes Comment tokens in block comments' do
        [
          <<~ORG,
            #+BEGIN_COMMENT
            hidden
            #+END_COMMENT
          ORG
          <<~ORG,
            #+begin_comment
            hidden
            #+end_comment
          ORG
        ].each do |text|
          assert_has_token("Comment", text)
        end
      end
    end

    describe 'quote blocks' do
      it 'recognizes Punctuation tokens in quote blocks' do
        [
          <<~ORG,
            #+BEGIN_QUOTE
            Here is an QUOTE.
            #+END_QUOTE
          ORG
          <<~ORG,
            #+begin_quote
            Here is an quote.
            #+end_quote
          ORG
        ].each do |text|
          assert_has_token("Punctuation", text)
        end
      end

      it 'recognizes emphasis tokens inside quote blocks' do
        text = <<~ORG
          #+BEGIN_QUOTE
          This is *bold* and /italic/.
          #+END_QUOTE
        ORG
        assert_has_token("Generic.Strong", text)
        assert_has_token("Generic.Emph", text)
      end
    end

    describe 'examples' do
      it 'recognizes Literal::String tokens in inline examples' do
        [
          ": This is an inline example\n",
          "  : indented inline example\n",
        ].each do |text|
          assert_has_token("Literal.String", text)
        end
      end

      it 'recognizes Literal::String tokens in example blocks' do
        [
          <<~ORG,
            #+BEGIN_EXAMPLE
            Here is an EXAMPLE.
            #+END_EXAMPLE
          ORG
          <<~ORG,
            #+begin_example
            Here is an example.
            #+end_example
          ORG
        ].each do |text|
          assert_has_token("Literal.String", text)
        end
      end
    end
  end
end
