class VarCompaniesController < ApplicationController
  def index
    @var_companies = VarCompany.all
  end

  def show
    @var_company = VarCompany.find(params[:id])
  end

  def new
    @var_company = VarCompany.new
  end

  def create
    # raise params.to_yaml
    @var_company = VarCompany.new(params[:var_company])
    respond_to do |format|
      if @var_company.save
        format.html { redirect_back_or_default @var_company; flash[:notice] = "Successfully created var company." }
        format.js { redirect_to  action: :close, vc: @var_company.id }
      else
        format.html { render 'new' }
        format.js { render action: :add }
      end
    end
  end

  def edit
    @var_company = VarCompany.find(params[:id])
  end

  def update
    @var_company = VarCompany.find(params[:id])
    if @var_company.update_attributes(params[:var_company])
      redirect_to @var_company, :notice  => "Successfully updated var company."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @var_company = VarCompany.find(params[:id])
    @var_company.destroy
    redirect_to var_companies_url, :notice => "Successfully destroyed var company."
  end
  
  def add
    store_location
    @var_company = VarCompany.new(creator_id: current_user.id)
  end
  
  def close
    @var_companies = VarCompany.order(:name)
    respond_to do |format|
      format.js
    end
  end
end
