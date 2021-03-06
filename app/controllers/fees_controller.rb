class FeesController < ApplicationController
  def index
    @q = Fee.find_type(params[:t]).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).paginate(page: params[:page], per_page: 20)
    
    @branch = Branch.find(params[:q][:buyer_branch_id_eq]).name if params[:q] && params[:q][:buyer_branch_id_eq].present?
    buyer_present?
    seller_present?
    
    if params[:q] && params[:q][:buyer_company_id_matches].present?
      @branches = Branch.where(company_id: params[:q][:buyer_company_id_matches])
    else
      @branches = []
    end
  end

  def show
    @fee = Fee.find(params[:id])
  end

  def new
    @fee = Fee.new
  end

  def create
    @fee = Fee.new(params[:fee])
    if @fee.save
      redirect_to @fee, :notice => "Successfully created fee."
    else
      render :action => 'new'
    end
  end

  def edit
    @fee = Fee.find(params[:id])
  end

  def update
    @fee = Fee.find(params[:id])
    if @fee.update_attributes(params[:fee])
      redirect_to @fee, :notice  => "Successfully updated fee."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @fee = Fee.find(params[:id])
    @fee.destroy
    redirect_to fees_url, :notice => "Successfully destroyed fee."
  end

  def print
    if can? :access, :all
      @q = Fee.find_type(params[:t]).filter_period(params[:q]).search(params[:q])
    elsif can? :access, :buyer
      @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    elsif can? :access, :seller 
      @q = Fee.find_type(params[:t]).by_this_seller(current_user.company).filter_period(params[:q]).search(params[:q])
    end
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], :seller_company)#.paginate(page: params[:page], per_page: 15)
    
    @branch = Branch.find(params[:q][:buyer_branch_id_eq]).name if params[:q] && params[:q][:buyer_branch_id_eq].present?
    buyer_present?
    seller_present?
    render layout: 'print'
  end
end
