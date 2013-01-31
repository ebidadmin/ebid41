class CompaniesController < ApplicationController
  load_and_authorize_resource

  def index
    @companies = Company.all
  end

  def show
    @company = Company.find(params[:id])
    @friends = @company.friends
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(params[:company])
    if @company.save
      redirect_to @company, :notice => "Successfully created company."
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @company = Company.find(params[:id])
  end

  def update
    # raise params.to_yaml
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:notice] = "Successfully updated company."
      redirect_back_or_default @company
    else
      render :action => 'edit'
    end
  end

  def destroy
    @company = Company.find(params[:id])
    if @company.entries.present? || @company.bids.present?
      @company.destroy # WARNING: should not DESTROY IF WITH ENTRIES/BIDS
    else
      
    end
    redirect_to companies_url, :notice => "Successfully destroyed company."
  end
  
  def selected
    @branches = Branch.where(company_id: params[:id]).order(:name)
  end
  
  
end
