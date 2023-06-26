# frozen_string_literal: true

module Decidim
  module Plans
    autoload :ContentBodyFieldType, "decidim/api/content_body_field_type"
    autoload :ContentMutationAttributes, "decidim/api/content_mutation_attributes"
    autoload :ContentSubject, "decidim/api/content_subject"
    autoload :ContentType, "decidim/api/content_type"
    autoload :MapPointType, "decidim/api/map_point_type"
    autoload :PlanInputFilter, "decidim/api/plan_input_filter"
    autoload :PlanInputSort, "decidim/api/plan_input_sort"
    autoload :PlanMutationType, "decidim/api/plan_mutation_type"
    autoload :PlanType, "decidim/api/plan_type"
    autoload :PlansType, "decidim/api/plans_type"
    autoload :ResourceLinkSubject, "decidim/api/resource_link_subject"
    autoload :SectionType, "decidim/api/section_type"

    module ContentMutation
      autoload :ContentAttributes, "decidim/api/content_mutation/content_attributes"
      autoload :FieldAreaScopeAttributes, "decidim/api/content_mutation/field_area_scope_attributes"
      autoload :FieldAttachmentsAttributes, "decidim/api/content_mutation/field_attachments_attributes"
      autoload :FieldCategoryAttributes, "decidim/api/content_mutation/field_category_attributes"
      autoload :FieldCheckboxAttributes, "decidim/api/content_mutation/field_checkbox_attributes"
      autoload :FieldCurrencyAttributes, "decidim/api/content_mutation/field_currency_attributes"
      autoload :FieldImageAttachmentsAttributes, "decidim/api/content_mutation/field_image_attachments_attributes"
      autoload :FieldMapPointAttributes, "decidim/api/content_mutation/field_map_point_attributes"
      autoload :FieldNumberAttributes, "decidim/api/content_mutation/field_number_attributes"
      autoload :FieldProposalsAttributes, "decidim/api/content_mutation/field_proposals_attributes"
      autoload :FieldScopeAttributes, "decidim/api/content_mutation/field_scope_attributes"
      autoload :FieldTagsAttributes, "decidim/api/content_mutation/field_tags_attributes"
      autoload :FieldTextAttributes, "decidim/api/content_mutation/field_text_attributes"
    end

    module SectionContent
      autoload :ContentType, "decidim/api/section_content/content_type"
      autoload :FieldAreaScopeType, "decidim/api/section_content/field_area_scope_type"
      autoload :FieldAttachmentsType, "decidim/api/section_content/field_attachments_type"
      autoload :FieldCategoryType, "decidim/api/section_content/field_category_type"
      autoload :FieldCheckboxType, "decidim/api/section_content/field_checkbox_type"
      autoload :FieldCurrencyType, "decidim/api/section_content/field_currency_type"
      autoload :FieldImageAttachmentsType, "decidim/api/section_content/field_image_attachments_type"
      autoload :FieldMapPointType, "decidim/api/section_content/field_map_point_type"
      autoload :FieldNumberType, "decidim/api/section_content/field_number_type"
      autoload :FieldScopeType, "decidim/api/section_content/field_scope_type"
      autoload :FieldTagsType, "decidim/api/section_content/field_tags_type"
      autoload :FieldTextType, "decidim/api/section_content/field_text_type"
      autoload :LinkProposalsType, "decidim/api/section_content/link_proposals_type"
    end

    module Api
      autoload :ContentInterface, "decidim/plans/api/content_interface"
    end
  end
end
