# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/SubjectStub
describe Decidim::Plans::OptionallyTranslatableAttributes do
  let(:locale) { "en" }
  let(:available_locales) { %w(en fi sv) }
  let(:subject) { form_class.from_params(params) }
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
      ota_en: "English value",
      cond_en: "English cond value",
      condproc_en: "English condproc value"
    }
  end

  before do
    allow(subject).to receive(:default_locale).and_return(locale)
    allow(subject).to receive(:component).and_return(component)
    allow(subject).to receive(:available_locales).and_return(available_locales)
  end

  context "with multilingual answers" do
    let(:component) { create(:plan_component, :with_multilingual_answers) }

    it "does not copy the answers" do
      expect(subject).not_to receive(:ota_fi=)
      expect(subject).not_to receive(:ota_sv=)
      expect(subject).not_to receive(:cond_fi=)
      expect(subject).not_to receive(:cond_sv=)
      expect(subject).not_to receive(:condproc_fi=)
      expect(subject).not_to receive(:condproc_sv=)
      subject.valid?
    end
  end

  context "with single language answers" do
    let(:component) { create(:plan_component) }

    it "copies the answers to other languages" do
      expect(subject).to receive(:ota_fi=).with(params[:ota_en])
      expect(subject).to receive(:ota_sv=).with(params[:ota_en])
      expect(subject).to receive(:cond_fi=).with(params[:cond_en])
      expect(subject).to receive(:cond_sv=).with(params[:cond_en])
      expect(subject).to receive(:condproc_fi=).with(params[:condproc_en])
      expect(subject).to receive(:condproc_sv=).with(params[:condproc_en])
      subject.valid?
    end
  end
end
# rubocop:enable RSpec/SubjectStub
