class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    # authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @q = User.search(params[:q])
    @users = @q.result.includes(:profile, :company, :roles).order('updated_at DESC').page(params[:page]).per_page(20)
  end

  def show
    @user = User.find(params[:id])
    @profile = @user.profile
    @all_roles = Role.all
  end
  
  def new
    @user = User.new
    @user.build_profile(company_id: params[:c], branch_id: params[:b])
    if params[:c].present?
      @branches = Branch.where(company_id: params[:c])
    else
      @branches = []
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_path, :notice => "Account created. Please wait for E-Bid to authorize your account."
    else
      @user.build_profile
      @company_type = Role.find(2, 3)
      @branches = []
      flash[:error] = "Please complete the required info."
      render :action => 'new'
    end
  end

  def edit
    store_location
    if can? :edit, :users
      @user = User.find(params[:id])
      @company_type = Role.find(1, 2, 3)
    else
      @user = current_user
      @company_type = Role.find(2, 3)
    end
    if can? :access, :all
      @branches = Branch.scoped
    else
      @branches = Branch.where(company_id: @user.company.id)
    end
  end

  def update
    # if current_user.has_role?('admin')
    #   @user = User.find(params[:id])
    #   @company_type = Role.find(1, 2, 3)
    # else
    #   @user = current_user
    #   @company_type = Role.find(2, 3)
    # end
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated user."
      redirect_back_or_default @user.company
    else
      render :action => 'edit'
    end
  end

end
