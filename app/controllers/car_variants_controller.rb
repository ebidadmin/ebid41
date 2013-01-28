class CarVariantsController < ApplicationController
  include ActionView::Helpers::TextHelper 
  
  def index
    @q = CarVariant.search(params[:q])
    @car_variants = @q.result.includes(:car_brand, :car_model, :entries).order(:car_brand_id).paginate(page: params[:page], per_page: 20)
  end

  def show
    @car_variant = CarVariant.find(params[:id])
  end

  def new
    @car_variant = CarVariant.new(creator_id: current_user.id)
    @car_models = []
  end

  def create
    @car_variant = CarVariant.new(params[:car_variant])
    if @car_variant.save
      flash[:success] = "Added new variant."
      if can? :access, :all
        redirect_to :back
      else
        redirect_to new_user_entry_path(current_user, variant: @car_variant )
      end
    else
      render :action => 'new'
    end
  end

  def edit
    store_location
    @car_variant = CarVariant.find(params[:id])
    @car_models = CarModel.where(car_brand_id: @car_variant.car_brand_id)
  end

  def update
    @car_variant = CarVariant.find(params[:id])
    if @car_variant.update_attributes(params[:car_variant])
      redirect_back_or_default @car_variant.car_model
    else
      render :action => 'edit'
    end
  end

  def destroy
    store_location
    @car_variant = CarVariant.find(params[:id])
    @car_variant.destroy
    redirect_back_or_default @orig_variant.car_model
  end
  
  def transfer
    store_location
    @car_variant = CarVariant.find(params[:id], include: [:entries => :user])
  end
  
  def confirm_transfer
    # raise params.to_yaml
    @orig_variant = CarVariant.find(params[:orig_id])
    @new_variant = CarVariant.find(params[:new_id])
    @entries = Entry.where(car_variant_id: params[:orig_id])
    flash[:notice] = "Transferred #{pluralize @entries.size, 'entry'} from #{@orig_variant.name} to #{@new_variant.name}"
    @entries.update_all(car_variant_id: params[:new_id])
    CarVariant.reset_counters @orig_variant.id, :entries
    CarVariant.reset_counters @new_variant.id, :entries
    redirect_back_or_default @orig_variant.car_model
  end
end
