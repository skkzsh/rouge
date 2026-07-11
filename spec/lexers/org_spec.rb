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
end
