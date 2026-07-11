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
      it 'recognizes horizontal rules' do
        assert_has_token("Punctuation", "-----\n")
      end

      it 'does not recognize horizontal rules' do
        deny_has_token("Punctuation", "----\n")
      end
    end
  end
end
