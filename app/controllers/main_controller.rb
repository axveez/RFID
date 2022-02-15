class MainController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:login,:logout]
  def index

  end

  def setting
    
  end

  def login
    flash.now[:error]=nil
    flash.now[:success]=nil
    if session[:auth]
      redirect_to "/"
    else

      if params[:username].present? and params[:password].present?
        params[:username] = params[:username].to_s[0..10]
        params[:password] = params[:password].to_s[0..100]
        query="select ENCRYPT('#{params[:password]}','#{params[:username]}') "
        password = ActiveRecord::Base.connection.execute(query).first[0]
        user = SysAccount.find_by(:user=> params[:username].downcase, :password=> password)
        if user.present?
          # flash.now[:success]="AAAAA"
          case user.status
          when "active"
            session[:auth]=true
            session[:id]=user.id
            session[:name]=user.name
            session[:duty_plant_id]=[]
            session[:duty_plant_id]+=[[user.hrd_employee.duty_plant_name_1,user.hrd_employee.duty_plant_1]] if user.hrd_employee.duty_plant_1.present?
            session[:duty_plant_id]+=[[user.hrd_employee.duty_plant_name_2,user.hrd_employee.duty_plant_2]] if user.hrd_employee.duty_plant_2.present?
            session[:duty_plant_id]+=[[user.hrd_employee.duty_plant_name_3,user.hrd_employee.duty_plant_3]] if user.hrd_employee.duty_plant_3.present?
            session[:duty_plant_id]+=[[user.hrd_employee.duty_plant_name_4,user.hrd_employee.duty_plant_4]] if user.hrd_employee.duty_plant_4.present?

            feature_acceptence = ["wh_spb1"]

            session.delete(:permission)
            (1..4).each do |sys_plant_id|
              permission=SysAccountPermission.where(:sys_account_id=>user.id, :feature=> feature_acceptence,:sys_plant_id=>sys_plant_id).where(:status=>'active')
              if permission.present?
                session[:permission] = Hash.new
                permission.each do  |p|
                  session[:permission][p.feature]=p.attributes
                  session[:permission][p.feature].delete('id')
                  session[:permission][p.feature].delete('sys_account_id')
                  #session[:permission][p.feature].delete('sys_plant_id')
                  session[:permission][p.feature].delete('feature')
                  session[:permission][p.feature].delete('feature_group')
                  session[:permission][p.feature].delete('created_at')
                  session[:permission][p.feature].delete('created_by')
                  session[:permission][p.feature].delete('updated_at')
                  session[:permission][p.feature].delete('updated_by')
                end
              end
            end

            redirect_to "/"
          else
            flash.now[:error]="Acccount is suspended"
          end
        else
          flash.now[:error]="Username or Password is wrong"
        end
      end
    end
  end

  def logout
    begin
      reset_session
    rescue
    end
    redirect_to root_path
  end
end
