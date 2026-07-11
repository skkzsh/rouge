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
  end
end
