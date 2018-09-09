# frozen_string_literal: true

module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale
    begin
      locale = begin
        if respond_to?(:user_signed_in?) && user_signed_in?
          current_user.locale
        else
          session[:locale] ||= default_locale
        end
      end
    rescue I18n::InvalidLocale
      locale = default_locale
    end

    I18n.with_locale(locale) do
      yield
    end
  end

  def default_locale
    if ENV['DEFAULT_LOCALE'].present?
      I18n.default_locale
    else
      request_locale || I18n.default_locale
    end
  end

  def request_locale
    preferred_locale || compatible_locale
  end

  def preferred_locale
    http_accept_language.preferred_language_from(available_locales)
  end

  def compatible_locale
    http_accept_language.compatible_language_from(available_locales)
  end

  def available_locales
    I18n.available_locales.reverse
  end
end
