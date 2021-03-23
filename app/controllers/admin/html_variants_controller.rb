module Admin
  class HtmlVariantsController < Admin::ApplicationController
    layout "admin"

    def index
      relation = if params[:state] == "mine"
                   current_user.html_variants.order(created_at: :desc)
                 elsif params[:state] == "admin"
                   HtmlVariant.where(published: true, approved: false).order(created_at: :desc)
                 elsif params[:state].present?
                   HtmlVariant.where(published: true, approved: true, group: params[:state]).order(success_rate: :desc)
                 else
                   HtmlVariant.where(published: true, approved: true).order(success_rate: :desc)
                 end

      @html_variants = relation.includes(:user).page(params[:page]).per(30)
    end

    def new
      @html_variant = HtmlVariant.new
      return unless params[:fork_id]

      @fork = HtmlVariant.find(params[:fork_id])
      @html_variant.name = "#{@fork.name} FORK-#{rand(10_000)}"
      @html_variant.html = @fork.html
    end

    def show
      @html_variant = HtmlVariant.find(params[:id])
      render layout: "application"
    end

    def edit
      @html_variant = HtmlVariant.find(params[:id])
    end

    def create
      @html_variant = HtmlVariant.new(html_variant_params)
      @html_variant.user_id = current_user.id

      if @html_variant.save
        flash[:success] = "HTML Variant has been created!"
        if FeatureFlag.enabled?(:admin_restructure)
          redirect_to admin_customization_html_variants_path(state: "mine")
        else
          redirect_to admin_html_variants_path(state: "mine")
        end
      else
        flash[:danger] = @html_variant.errors_as_sentence
        if FeatureFlag.enabled?(:admin_restructure)
          redirect_to new_admin_customization_html_variant_path
        else
          render new_admin_html_variant_path
        end
      end
    end

    def update
      @html_variant = HtmlVariant.find(params[:id])

      if @html_variant.update(html_variant_params)
        flash[:success] = "HTML Variant has been updated!"
        if FeatureFlag.enabled?(:admin_restructure)
          redirect_to edit_admin_customization_html_variant_path(@html_variant)
        else
          redirect_to edit_admin_html_variant_path(@html_variant)
        end
      else
        flash[:danger] = @html_variant.errors_as_sentence
        # TODO: @ridhwana to add a feature flag
        render :edit
      end
    end

    def destroy
      @html_variant = HtmlVariant.find(params[:id])

      if @html_variant.destroy
        flash[:success] = "HTML Variant has been deleted!"
        if FeatureFlag.enabled?(:admin_restructure)
          redirect_to admin_customization_html_variants_path
        else
          redirect_to admin_html_variants_path
        end
      else
        flash[:danger] = "Something went wrong with deleting the HTML Variant."
        # TODO: @ridhwana to add a feature flag
        render :edit
      end
    end

    private

    def html_variant_params
      params.permit(:html, :name, :published, :approved, :target_tag, :group)
    end

    def authorize_admin
      authorize HtmlVariant, :access?, policy_class: InternalPolicy
    end
  end
end
