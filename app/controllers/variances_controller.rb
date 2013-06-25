class VariancesController < ApplicationController
  def index
    @q = Variance.search(params[:q])
    @variances = @q.result.includes(:user, :company, :var_company).order('created_at DESC').paginate(page: params[:page], per_page: 15)
    @companies = Company.where(primary_role: 2).includes(:users).order('users.username ASC')
  end

  def show
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.variance
    
    @ebid_lower = @variance.var_items.where{{var_net.gt => 0}}
    @ebid_higher = @variance.var_items.where{{var_net.lt => 0}}
    @same = @variance.var_items.where{{var_net.eq => 0}}
 
    @no_ebid_manual_only = @variance.var_items.where{ (var_total > 0) & (bid_id == nil) }
    @with_ebid_no_manual =  @variance.var_items.where{ (var_total == nil) & (bid_id != nil) }

    @savings_rate = (@variance.var_items.sum(:var_net).abs.to_f/@variance.var_items.sum(:var_total).to_f) * 100
    @projected_savings = @with_ebid_no_manual.sum(&:total) / (1 + @savings_rate)
    render layout: 'print'
  end

  def new
    store_location
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.build_variance(var_company_id: params[:vc])
    @variance.var_items.build

    @var_companies = VarCompany.order(:name)
    @available_discounts = Variance::DISCOUNTS.collect { |d| [d + '%', d ] }
  end

  def create
    # raise params.to_yaml
    @entry = Entry.find(params[:entry_id])
    @variance = @entry.build_variance(params[:variance])
    @variance.populate(current_user, params[:variance][:discount], @entry)
    if current_user.variances << @variance
      redirect_to variance_path(@variance, entry_id: @entry)
    else
      @var_companies = VarCompany.order(:name)
      @available_discounts = Variance::DISCOUNTS.collect { |d| [d + '%', d ] }
      render 'new'
    end
  end

  def edit
    @variance = Variance.find(params[:id])
    @entry = @variance.entry
    @var_companies = VarCompany.order(:name)
    @available_discounts = Variance::DISCOUNTS.collect { |d| [d + '%', d ] }
  end

  def update
    @variance = Variance.find(params[:id])
    if @variance.update_attributes(params[:variance])
      redirect_to @variance, :notice  => "Successfully updated variance."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @variance = Variance.find(params[:id])
    @variance.destroy
    flash[:notice] = "Deleted Variance"
    redirect_back_or_default variances_url
  end
  
  def summarize
    # if params[:q]
      @company = Company.find(5)
    # end
    
    @variances = @company.variances

    @var_items ||= VarItem.where(variance_id: @variances)

    @ebid_lower = @var_items.where('var_net > 0')
    @ebid_higher = @var_items.where('var_net < 0')
    @same = @var_items.where(var_net: 0)
    
    @with_ebid_and_manual = @ebid_lower + @ebid_higher + @same
    @no_ebid_manual_only = @var_items.where('var_total > 0 AND bid_id IS NULL') 
    @with_ebid_no_manual =  @var_items.where('var_total IS NULL AND bid_id IS NOT NULL')
    
    entries = Entry.where(id: @variances.collect(&:entry_id))
    @li = entries.sum(:line_items_count)
    @no_ebid_no_manual = @li - @var_items.count
    

    savings_factor = (@var_items.sum(:var_net).abs.to_f/@var_items.sum(:var_total).to_f)
    @savings_rate = savings_factor * 100
    @projected_canvass = @with_ebid_no_manual.sum(:total) / (1 - savings_factor)
    @projected_savings = @projected_canvass * savings_factor
    
    @orders = @company.orders
    render :layout => 'print'
  end
end
