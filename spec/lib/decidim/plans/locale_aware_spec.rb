# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::LocaleAware do
  let(:locale) { "en" }
  let(:available_locales) { %w(en fi sv) }
  let(:subject) { klass.new }
  let(:klass) do
    Class.new do
      include Decidim::Plans::LocaleAware

      def fetch_current_locale
        current_locale
      end

      def fetch_available_locales
        available_locales
      end

      def current_organization
        nil
      end
    end
  end
  let(:organization) { double }

  describe ".current_locale" do
    it "calls I18n.locale" do
      expect(I18n).to receive(:locale).and_return(locale)
      expect(klass.current_locale).to be(locale)
    end
  end

  describe "#current_locale" do
    it "calls I18n.locale" do
      expect(I18n).to receive(:locale).and_return(locale)
      expect(subject.fetch_current_locale).to be(locale)
    end
  end

  describe "#available_locales" do
    it "fetches available locales from Decidim" do
      expect(Decidim).to receive(:available_locales).and_return(available_locales)
      expect(subject.fetch_available_locales).to be(available_locales)
    end

    it "with current organization available" do
      expect(subject).to receive(:available_locales).and_return(available_locales)
      expect(Decidim).not_to receive(:available_locales)
      expect(subject.fetch_available_locales).to be(available_locales)
    end
  end
end
