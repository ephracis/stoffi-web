# frozen_string_literal: true
module I18nHelper
  # Check whether a translation key exists.
  def t?(key)
    I18n.t key, raise: true
  rescue
    false
  end

  # Get the flag image name for the current locale.
  def current_flag
    lang I18n.locale
  end

  # Get the flag image name for a given locale.
  def flag(locale)
    case locale.to_s
    when 'sv' then 'se'
    when 'en' then 'us'
    else locale.to_s
    end
  end
end
