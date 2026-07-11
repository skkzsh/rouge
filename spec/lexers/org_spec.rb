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
  end
end
