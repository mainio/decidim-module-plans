# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to the tags related to plans.
      class TagsController < Admin::ApplicationController
        include TranslatableAttributes

        helper_method :plan, :tags

        def index
          enforce_permission_to :read, :plan_tag

          respond_to do |format|
            format.html do
              render :index
            end
            format.json do
              return render json: [] unless params.has_key?(:term)

              tags = OrganizationTags.new(current_organization).query.where(
                "name ->> '#{current_locale}' ILIKE ?",
                "%#{params[:term]}%"
              ).where.not(
                id: plan.tags.pluck(:id)
              )
              render json: tags.map { |t| [t.id, translated_attribute(t.name)] }
            end
          end
        end

        def new
          enforce_permission_to :create, :plan_tags

          dummy_tag = Tag.new(organization: current_organization)
          dummy_tag.name = {}
          current_organization.available_locales.map do |locale|
            dummy_tag.name[locale] = params[:name]
          end

          @form = form(Admin::TagForm).from_model(dummy_tag)
          @form.back_to_plan = true if params[:back_to_plan].to_i == 1
        end

        def create
          enforce_permission_to :create, :plan_tags
          @form = form(Admin::TagForm).from_params(params)

          Admin::CreateTag.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("create.success", scope: i18n_flashes_scope)

              return redirect_to taggings_plan_path(plan) if @form.back_to_plan

              redirect_to plan_tags_path(plan)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("create.invalid", scope: i18n_flashes_scope)
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :edit, :plan_tags, tag: tag
          @form = form(Admin::TagForm).from_model(tag)
        end

        def update
          enforce_permission_to :edit, :plan_tags, tag: tag

          @form = form(Admin::TagForm).from_params(params)
          Admin::UpdateTag.call(@form, @tag) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: i18n_flashes_scope)
              redirect_to plan_tags_path(plan)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: i18n_flashes_scope)
              render :edit
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :plan_tags, tag: tag

          Admin::DestroyTag.call(@tag, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("destroy.success", scope: i18n_flashes_scope)
              redirect_to plan_tags_path(plan)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("destroy.error", scope: i18n_flashes_scope)
              redirect_to plan_tags_path(plan)
            end
          end
        end

        private

        def i18n_flashes_scope
          "decidim.plans.admin.tags"
        end

        def tag
          @tag ||= Tag.where(organization: current_organization).find(params[:id])
        end

        def plan
          @plan ||= Plan.where(component: current_component).find(params[:plan_id])
        end

        def tags
          @tags ||= OrganizationTags.new(
            current_organization
          ).query.page(params[:page]).per(30)
        end
      end
    end
  end
end
