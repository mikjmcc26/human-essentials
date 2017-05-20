class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :authorize_user

  def current_organization
    # FIXME: should be short_name so that we get "/pdx/blah" rather than "/123/blah"
  	@organization ||= Organization.find_by(short_name: params[:organization_id])
  end
  helper_method :current_organization

  def organization_url_options(options={})
    options.merge(organization_id: current_organization.to_param)
  end
  helper_method :organization_url_options

  # override Rails' default_url_options to ensure organization_id is added to
  # each URL generated
  def default_url_options(options = {})
    if current_organization.present? && !options.has_key?(:organization_id)
      options[:organization_id] = current_organization.to_param
    elsif current_user && !current_user.is_superadmin? && current_user.organization.present?
      options[:organization_id] = current_user.organization.to_param
    end
    options
  end

  def authorize_user
    verboten! unless current_organization.id == current_user.organization_id
  end

  def not_found!
    respond_to do |format|
      format.html { render template: "errors/404", layout: "layouts/application", status: 404 }
      format.json { render nothing: true, status: 404 }
    end
  end

  def verboten!
    respond_to do |format|
      format.html { render template: "errors/403", layout: "layouts/application", status: 403 }
      format.json { render nothing: true, status: 403 }
    end
  end

  def omgwtfbbq!
    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'layouts/error', status: 500 }
      format.json { render nothing: true, status: 500 }
    end
  end

  # rescue_from CanCan::AccessDenied do |exception|
    # respond_to do |format|
      # format.json { head :forbidden, content_type: 'text/html' }
      # format.html { redirect_to main_app.root_url, notice: exception.message }
      # format.js   { head :forbidden, content_type: 'text/html' }
    # end
  # end
end
