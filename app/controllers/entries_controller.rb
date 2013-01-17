class EntriesController < ApplicationController
  before_filter :initialize_cart, :only => [:show, :edit]

  def index
    @q = Entry.search(params[:q])
    @entries = @q.result.find_status(params[:s]).includes([:user => :profile], :car_brand, :car_model, :bids, :messages, :orders, :variance).paginate(page: params[:page], per_page: 12)#.order('bid_until DESC')
    @companies = Company.where(primary_role: 2).includes(:users).order('users.username ASC')

    if params[:q] && params[:q][:car_brand_id_eq].present?
      @car_models = CarModel.where(car_brand_id: params[:q][:car_brand_id_eq])
    else
      @car_models = []
    end
  end

  def show
    @entry = Entry.find(params[:id])
    @line_items = @entry.line_items.includes(:car_part, :bids, :order).order('status DESC')
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @entry }
    end
  end

  def new
    @entry = Entry.new
    @car_models = @car_variants = []
    @entry.term_id = 4 # default credit term is 30 days

    if params[:variant] # displays proper fields after creation of new variant
      @saved_variant = CarVariant.find(params[:variant])
      @entry.car_brand_id = @saved_variant.car_brand_id
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @entry.car_model_id = @saved_variant.car_model_id
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.car_variant_id = @saved_variant.id
    end
  end

  def create
    @entry = current_user.entries.build(params[:entry])
    if current_user.company.entries << @entry
      flash[:notice] = "Successfully created entry."
      redirect_to add_photos_entry_path(@entry)
   else
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.term_id = params[:entry][:term_id]
      render 'new'
    end
  end
  
  def add_photos
    session['referer'] = request.env["HTTP_REFERER"]
    @entry = Entry.find(params[:id])
  end
  
  def edit
    session['referer'] = request.env["HTTP_REFERER"]
    @entry = Entry.find(params[:id])
    @photos = @entry.photos
    @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
    @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
    @entry.photos.build if @entry.photos.nil?
  end

  def update
    @entry = Entry.find(params[:id])
    if @entry.update_attributes(params[:entry])
      flash[:notice] = "Successfully updated entry."
      respond_to do |format|
       if can? :access, :all
         format.html { redirect_to @entry }
       else
         format.html { redirect_to buyer_show_path(@entry) }
       end
      end
    else
      @car_models = CarModel.where(car_brand_id: @entry.car_brand_id)
      @car_variants = CarVariant.where(car_model_id: @entry.car_model_id)
      @entry.photos.build if @entry.photos.nil?
      render 'edit'
    end
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy

    respond_to do |format|
      format.html { 
        if can? :access, :all
          redirect_to redirect_back_or_default entries_path
        else
          redirect_to redirect_back_or_default buyer_entries_path(s: nil)
        end 
        }
      format.json { head :no_content }
    end
  end

  def put_online
    @entry = Entry.find(params[:id], include: [:line_items => :car_part])
    if @entry
      flash[:notice] = @entry.put_online 
      redirect_to :back
    else
      flash[:error] = "Wait! Your entry is not yet complete. Please complete the photos and parts before you proceed."
      redirect_to :back
    end
  end

  def reveal 
    @entry = Entry.find(params[:id])
    unless @entry.bids.blank?
      if @entry.status == 'Re-bidding'
        flash[:notice] = @entry.reveal2
      else
        flash[:notice] = @entry.reveal
      end
    else
      flash[:warning] = "Sorry, there no bids to reveal."
    end 
    redirect_to :back
  end

  def rebid
    @entry = Entry.find(params[:id])
    flash[:notice] = @entry.rebid
    Message.for_rebidding(current_user, @entry)
    redirect_to :back
  end
  
end
