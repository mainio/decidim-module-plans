# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::OptionallyTranslatableAttributes do
  subject { form_class.from_params(params) }

  let(:default_locale) { "en" }
  let(:available_locales) { %w(en ca es) }
  let(:form_class) do
    Class.new(Decidim::Form) do
      include Decidim::Plans::OptionallyTranslatableAttributes

      mimic :content

      optionally_translatable_attribute :ota, String
      optionally_translatable_validate_presence :ota

      optionally_translatable_attribute :cond, String
      optionally_translatable_validate_presence :cond, if: :test_cond

      optionally_translatable_attribute :condproc, String
      optionally_translatable_validate_presence :condproc, if: proc { true }

      def test_cond
        true
      end
    end
  end
  let(:params) do
    {
      ota: { en: "English value" },
      ota_en: "English value",
      cond: { en: "English cond value" },
      cond_en: "English cond value",
      condproc: { en: "English cond value" },
      condproc_en: "English condproc value"
    }
  end

  before do
    allow(Decidim).to receive(:available_locales).and_return(available_locales)

    # rubocop:disable RSpec/SubjectStub
    allow(subject).to receive(:default_locale).and_return(default_locale)
    allow(subject).to receive(:component).and_return(component)
    # rubocop:enable RSpec/SubjectStub
  end

  context "with multilingual answers" do
    let(:component) { create(:plan_component, :with_multilingual_answers) }

    it "is valid" do
      expect(subject).to be_valid
    end

    context "when the default locale does not have values" do
      let(:default_locale) { "ca" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end
  end

  context "with single language answers" do
    let(:component) { create(:plan_component) }

    it "is valid" do
      expect(subject).to be_valid
    end

    context "when the default locale does not have values" do
      let(:default_locale) { "ca" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
