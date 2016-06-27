# Copyright (c) 2015 Simplare

# Handle requests to static pages.
class StaticController < ApplicationController
  
  add_breadcrumb I18n.t('breadcrumbs.home'), '/', except: :music
  
  def contact
    add_breadcrumb I18n.t('breadcrumbs.contact'), contact_path
  end
  
  def legal
    add_breadcrumb I18n.t('breadcrumbs.contact'), legal_path
  end
  
  def about
    add_breadcrumb I18n.t('breadcrumbs.about'), about_path
  end

  def youtube
    render layout: false
  end
  
  def barebone
    render text: 'this is a barebone page used for performance testing'
  end

  def donate
    redirect_to 'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=82AJWHA5KKCZL'
  end
  
  def mail
    if !params[:name] or params[:name].length < 2
      flash[:error] = t("static.contact.form.errors.name")
      render action: 'contact'
        
    elsif !params[:email] or params[:email].match(/^([a-z0-9_.\-]+)@([a-z0-9\-.]+)\.([a-z.]+)$/i).nil?
      flash[:error] = t("static.contact.form.errors.email")
      render action: 'contact'
        
    elsif !params[:subject] or params[:subject].length < 4
      flash[:error] = t("static.contact.form.errors.subject") 
      render action: 'contact'
        
    elsif !params[:message] or params[:message].length < 20
      flash[:error] = t("static.contact.form.errors.message")
      render action: 'contact'

    elsif !verify_recaptcha
      flash[:error] = t("static.contact.form.errors.captcha")
      render action: 'contact'
      
    else
      SystemMailer.contact(domain: "stoffiplayer.com",
                     subject: params[:subject],
                     from: params[:email],
                     name: params[:name],
                     message: params[:message]).deliver_later

      flash[:success] = t("static.contact.form.success")
      redirect_to action: 'contact'
    end
  end
  
end
