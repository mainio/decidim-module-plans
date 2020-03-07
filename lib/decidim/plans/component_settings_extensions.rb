# frozen_string_literal: true

# Extend the SettingsManifest types
types = Decidim::SettingsManifest::Attribute::TYPES.merge(
  plan_state: { klass: String, default: nil }
)
Decidim::SettingsManifest::Attribute.send(:remove_const, :TYPES)
Decidim::SettingsManifest::Attribute::TYPES = types.freeze

# Redefine the validations
Decidim::SettingsManifest::Attribute.class_eval do
  _validators.reject! { |key, _| key == :type }

  _validate_callbacks.each do |callback|
    _validate_callbacks.delete(callback) if callback.raw_filter.attributes == [:type]
  end

  validates :type, inclusion: { in: types.keys }
end
