# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :display_banner?, :sinai_authn_check, :add_legacy_views, :cors_preflight_check, :set_default_sort, :display_term_of_use?
  after_action :cors_set_access_control_headers

  def add_legacy_views
    prepend_view_path "app/views_legacy"
    prepend_view_path "app/views" # already there, but needs to be in front of views_legacy
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    return unless request.method == :options

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = '1728000'
    render text: '', content_type: 'text/plain'
  end

  def display_banner?
    if banner_cookie?
      @beta_banner_display_option = "none"
    else
      @beta_banner_display_option = "block"
      set_banner_cookie
    end
  end

  def sinai_authn_check
    return true if [version_path].include?(request.path) || sinai_authenticated_1year?
    if ENV['SINAI_ID_BYPASS'] # skip auth in development
      cookies[:sinai_authenticated_1year] = 'true'
      return true
    end
    # check_document_paths
    return unless ucla_token?
    set_auth_cookies
    redirect_to cookies[:requested_path]
  end

  # def check_document_paths
  #   redirect_to redirect_target if params[:id] && [solr_document_path(params[:id])].include?(request.path) # check if someone bookmarked the show page
  # end

  def banner_cookie?
    cookies[:banner_display_option]
  end

  def set_banner_cookie
    cookies[:banner_display_option] = "banner_off"
  end

  def set_default_sort
    # set sort to be relevance if keyword search is not empty
    params[:sort] ||= 'score desc' unless params[:q].to_s.empty?
  end

  def sinai_authenticated_1year?
    cookies[:sinai_authenticated_1year]
  end

  def ucla_token?
    # second version in case url params not parsable
    token_from_emel = params[:token] || request.fullpath.split(/\?token=/)[1]
    token = SinaiToken.find_by(sinai_token: token_from_emel) if token_from_emel
    authorized = token && cookies[:requested_path].present? || false

    token&.destroy
    authorized
  end

  def set_auth_cookies
    cookies[:sinai_authenticated_1year] = {
      value: create_encrypted_string.unpack('H*')[0].upcase,
      expires: Time.zone.now + 1.year,
      domain: ENV['DOMAIN']
    }
    cookies[:initialization_vector] = {
      value: cipher_iv.unpack('H*')[0].upcase,
      expires: Time.zone.now + 1.year,
      domain: ENV['DOMAIN']
    }
  end

  # TERMS OF USE MODAL
  def term_of_use_cookie?
    cookies[:set_modal]
  end

  def set_term_of_use_cookie
    cookies[:set_modal] = {
      value: 'Set this Modal',
      expires: Time.zone.now + 90.days
    }
  end

  def display_term_of_use?
    if term_of_use_cookie?
      @term_of_use_modal_option = "none"
    else
      @term_of_use_modal_option = "flex"
      set_term_of_use_cookie
    end
  end
  # End Terms of Use Modal

  def create_encrypted_string
    cipher.encrypt
    cipher.key = ENV['CIPHER_KEY']
    cipher.iv = cipher_iv
    cipher.update("Authenticated #{Time.zone.today}") + cipher.final
  end

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout 'blacklight'

  protect_from_forgery with: :exception

  rescue_from Blacklight::AccessControls::AccessDenied, with: :render_404

  def render_404
    render file: Rails.root.join('public', '404.html'), status: :not_found, layout: false
  end

  private

    def cipher
      @cipher ||= OpenSSL::Cipher::AES256.new :CBC
    end

    def cipher_iv
      @iv ||= cipher.random_iv
    end

  # def redirect_target
  #   cookies[:request_original_url] = request.original_url
  #   "/"
  # end
end
