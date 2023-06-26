# frozen_string_literal: true

module Decidim
  module Plans
    # This class acts as a manifest for plan layouts.
    #
    # The plan layouts control how the plan view and how the form look like.
    # Both these views are defined as cells.
    #
    # The default layout should be sufficient for most cases. Customizing the
    # views may come handy if you want to have multiple different plan
    # components in the same instance which are laid out differently.
    class LayoutManifest
      include ActiveModel::Model
      include Virtus.model

      attribute :name, Symbol
      attribute :public_name_key, String
      attribute :form_layout, String, default: "decidim/plans/plan_form"
      attribute :view_layout, String, default: "decidim/plans/plan_view"
      attribute :index_layout, String, default: "decidim/plans/plan_index"
      attribute :card_layout, String, default: "decidim/plans/plan_m"

      validates :name, :public_name_key, :form_layout, :view_layout, presence: true
    end
  end
end
