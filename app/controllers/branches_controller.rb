class BranchesController < ApplicationController
  load_and_authorize_resource

  def index
    @branches = Branch.all
  end

  def show
    @branch = Branch.find(params[:id])
  end

  def new
    store_location
    @branch = Branch.new(company_id: params[:c])
  end

  def create
    @branch = Branch.new(params[:branch])
    if @branch.save
      flash[:notice] = "Successfully created branch."
      redirect_back_or_default @branch.company
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @branch = Branch.find(params[:id])
  end

  def update
    @branch = Branch.find(params[:id])
    if @branch.update_attributes(params[:branch])
      flash[:notice] = "Successfully updated branch."
      redirect_back_or_default @branch.company
    else
      render :action => 'edit'
    end
  end

  def destroy
    @branch = Branch.find(params[:id])
    @branch.destroy
    redirect_to branches_url, :notice => "Successfully destroyed branch."
  end
end
