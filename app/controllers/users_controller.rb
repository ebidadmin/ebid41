class UsersController < ApplicationController
  # before_filter :authenticate_user!

  def index
    # authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @q = User.search(params[:q])
    @users = @q.result.includes(:profile, :company, :roles).order('updated_at DESC').page(params[:page]).per_page(20)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    store_location
    if current_user.has_role? :admin
      @user = User.find(params[:id])
      @company_type = Role.find(1, 2, 3)
    else
      @user = current_user
      @company_type = Role.find(2, 3)
    end
    @branches = Branch.where(company_id: @user.company.id)
  end

  def update
    if current_user.has_role?('admin')
      @user = User.find(params[:id])
      @company_type = Role.find(1, 2, 3)
    else
      @user = current_user
      @company_type = Role.find(2, 3)
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_back_or_default :back #redirect_to @user
    else
      render :action => 'edit'
    end
  end

end
